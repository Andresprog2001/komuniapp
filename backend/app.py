from flask import Flask, request, jsonify, send_from_directory
import pymysql
from pymysql import Error
from flask_cors import CORS
import bcrypt
import jwt
import json
import os
import uuid  # Módulo para generar identificadores únicos (UUIDs)
import datetime
from functools import wraps
# <<-- CAMBIO CLAVE AQUÍ
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Obtiene el directorio del script actual (donde está app.py)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Ruta absoluta en el servidor donde se almacenarán los archivos subidos por los usuarios
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)  # Crea la carpeta si no existe

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['SECRET_KEY'] = 'komuniapp_super_secreto_jwt_key_12345'

# --- Configuración de la Base de Datos MySQL ---
DB_CONFIG = {
    'host': '127.0.0.1',
    'database': 'komuniapp',
    'user': 'root',
    'password': '',
    'port': 3306
}


# <<-- FUNCIONES DE HASHING Y VERIFICACIÓN CON BCRYPT -->>
def hash_password(password):
    """
    Hashea una contraseña usando bcrypt.
    El salt se genera automáticamente con gensalt().
    """
    # bcrypt.gensalt() genera un nuevo salt para cada hash
    # .encode('utf-8') es necesario para convertir la cadena a bytes
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hashed.decode('utf-8')  # Decodifica a string para guardar en la DB


def check_password(password, hashed_password):
    """
    Verifica una contraseña contra un hash bcrypt almacenado.
    """
    # Ambos deben ser bytes para la comparación
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

# <<-- DECORADOR PARA PROTEGER RUTAS CON JWT -->>


def jwt_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        # JWT se espera en el encabezado Authorization como "Bearer <token>"
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            if auth_header.startswith('Bearer '):
                token = auth_header.split(' ')[1]

        if not token:
            return jsonify({'message': 'Token JWT faltante!'}), 401

        try:
            # Decodifica el token usando la clave secreta
            data = jwt.decode(
                token, app.config['SECRET_KEY'], algorithms=['HS256'])
            # Pasa el user_id decodificado a la función de la ruta
            request.current_user_id = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'Token JWT expirado!'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'message': 'Token JWT inválido!'}), 401
        except Exception as e:
            print(f"Error inesperado al decodificar JWT: {e}")
            return jsonify({'message': 'Error de autenticación.'}), 401

        return f(*args, **kwargs)
    return decorated

# --- Endpoint de Registro de Usuario ---


@app.route('/api/register', methods=['POST'])
def register_user():

    conn = None
    cursor = None
    try:
        data = request.get_json()

        if not data:
            return jsonify({'message': 'Datos JSON no proporcionados'}), 400
        name = data.get('name')
        email = data.get('email')
        password = data.get('password')
        gender = data.get('gender')

        hashed_password = hash_password(password)

        if not all([name, email, password, gender]):
            return jsonify({'message': 'Faltan campos obligatorios (full_name, email, password, gender)'}), 400

        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()

        # <<-- NUEVA VERIFICACIÓN DE EMAIL EXISTENTE -->>
        cursor.execute(
            "SELECT email FROM register_users WHERE email = %s", (email,))
        existing_user = cursor.fetchone()

        if existing_user:
            # 409 Conflict
            return jsonify({'message': 'El correo electrónico ya está registrado.'}), 409

        if conn.open:
            # Para depuración

            cursor = conn.cursor()

            sql = """
            INSERT INTO register_users (name, email, password, gender, created_at)
            VALUES (%s, %s, %s, %s, NOW())
            """
            values = (name, email, hashed_password, gender)

            cursor.execute(sql, values)

            conn.commit()

            return jsonify({'message': 'Usuario registrado exitosamente!'}), 201

    except Error as e:
        print(f"Error de MySQL (PyMySQL): {str(e)}")
        return jsonify({'message': f'Error en la base de datos: {e}'}), 500
    except Exception as e:
        print(f"Error general: {str(e)}")
        return jsonify({'message': f'Error interno del servidor: {e}'}), 500
    finally:
        if cursor:
            cursor.close()
        if conn and conn.open:
            conn.close()


# --- ENDPOINT para Inicio de Sesión ---


@app.route('/api/login', methods=['POST'])
def login_user():
    conn = None
    cursor = None

    try:
        data = request.get_json()
        if not data:
            return jsonify({'message': 'Datos JSON no proporcionados'}), 400

        email = data.get('email')
        password = data.get('password')

        if not all([email, password]):
            return jsonify({'message': 'Faltan campos obligatorios (email, contraseña)'}), 400

        # Encripta la contraseña ingresada por el usuario para compararla con el hash almacenado

        conn = pymysql.connect(**DB_CONFIG)
        # Para obtener resultados como diccionario
        cursor = conn.cursor(pymysql.cursors.DictCursor)

        # Buscar usuario por email
        sql = "SELECT id, email, password FROM register_users WHERE email = %s"
        cursor.execute(sql, (email,))
        user = cursor.fetchone()

        # Verifica si el usuario existe y si la contraseña hasheada coincide
        if user and check_password(password, user['password']):
            # <<-- GENERAR TOKEN JWT -->>
            token_payload = {
                'user_id': user['id'],
                # Token expira en 20 minutos
                'exp': datetime.datetime.utcnow() + datetime.timedelta(minutes=50)
            }
            token = jwt.encode(
                token_payload, app.config['SECRET_KEY'], algorithm='HS256')

            return jsonify({
                'message': 'Inicio de sesión exitoso',
                'token': token  # <<-- DEVOLVER EL TOKEN AL FRONTEND -->>
            }), 200
        else:
            # 401 Unauthorized
            return jsonify({'message': 'Credenciales incorrectas'}), 401

    except Error as e:
        error_message = str(e)
        print(f"Error de MySQL (PyMySQL) en login: {error_message}")
        return jsonify({'message': f'Error en la base de datos de login: {error_message}'}), 500
    except Exception as e:
        error_message = str(e)
        print(f"Error general en login: {error_message}")
        return jsonify({'message': f'Error interno del servidor: {error_message}'}), 500
    finally:
        if cursor:
            cursor.close()
        if conn and conn.open:
            conn.close()


# ---  ENDPOINT para Contenido Educativo ---


@app.route('/api/contents', methods=['GET', 'POST'])
@jwt_required
def contents_list():
    conn = None
    cursor = None
    try:
        conn = pymysql.connect(**DB_CONFIG)
        # Para obtener resultados como diccionarios
        cursor = conn.cursor(pymysql.cursors.DictCursor)
        if request.method == 'GET':
            cursor.execute(
                "SELECT id, title, description, author, category, file_url, user_id FROM contents")
            contents = cursor.fetchall()
            return jsonify(contents), 200

        elif request.method == 'POST':
            data = request.get_json()

            if not data:
                return jsonify({'message': 'Datos JSON no proporcionados'}), 400

            title = data.get('title')
            description = data.get('description')
            author = data.get('author')
            category = data.get('category')
            user_id = request.current_user_id

            if not all([title, description, author, category]):
                return jsonify({'message': 'Faltan campos obligatorios para el contenido'}), 400

            original_filename = data.get('file_url')
            file_bytes_str = data.get('file_bytes')

            # Obtiene la extensión (ej. .pdf, .jpg)
            file_extension = os.path.splitext(original_filename)[1]

            try:
                # Convertir la cadena de texto de los bytes(json) a una lista de enteros(python)
                byte_list = json.loads(file_bytes_str)

                # Convertir la lista de enteros a un objeto 'bytes' real
                binary_data = bytes(byte_list)

            except (json.JSONDecodeError, ValueError) as e:
                return jsonify({'message': f'Error al procesar los bytes del archivo: {e}'}), 400

            # Genera un nombre único con UUID
            filename_to_save = str(uuid.uuid4()) + file_extension

            file_path = os.path.join(
                app.config['UPLOAD_FOLDER'], filename_to_save)

            try:
                # 3. Guardar los bytes binarios en el archivo
                with open(file_path, 'wb') as f:  # 'wb' para escribir en binario
                    # crea el archivo y escribe los datos binarios
                    f.write(binary_data)
            except IOError as e:
                return jsonify({'message': f'Error al guardar el archivo en el servidor: {e}'}), 500

            public_url = f"http://localhost:3000/uploads/{filename_to_save}"

            sql = """
            INSERT INTO contents (title, description, author, category, file_url, user_id,created_at)
            VALUES (%s, %s, %s, %s, %s, %s, NOW())
            """
            values = (title, description, author, category,
                      public_url, user_id)

            cursor.execute(sql, values)
            conn.commit()
            return jsonify({'message': 'Contenido cargado exitosamente!'}), 201

    except Error as e:
        error_message = str(e)
        print(f"Error de MySQL (PyMySQL) en contenidos: {error_message}")
        return jsonify({'message': f'Error en la base de datos de contenidos: {error_message}'}), 500
    except Exception as e:
        try:
            error_message = str(e)
        except Exception:
            error_message = "Error desconocido del servidor de contenidos."

        print(f"Error general en contenidos: {error_message}")
        return jsonify({'message': f'Error interno del servidor de contenidos: {error_message}'}), 500
    finally:
        if cursor:
            cursor.close()
        if conn and conn.open:
            conn.close()

#  NUEVO ENDPOINT PARA EL PERFIL DE USUARIO BUSCADO POR ID


@app.route('/api/profile', methods=['GET'])
@jwt_required  # Protege este endpoint con JWT
def get_user_profile():
    conn = None
    cursor = None
    user_id = request.current_user_id
    if not user_id:
        return jsonify({'message': 'ID de usuario no proporcionado en el token JWT'}), 400

    try:
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor(pymysql.cursors.DictCursor)

        # Buscar usuario por ID
        sql = "SELECT id, name, email, gender, created_at FROM register_users WHERE id = %s"
        cursor.execute(sql, (user_id,))
        user = cursor.fetchone()

        if not user:
            return jsonify({'message': 'Perfil de usuario no encontrado'}), 404

        created_at_str = user['created_at'].strftime('%Y-%m-%d %H:%M:%S') if isinstance(
            user['created_at'], datetime.datetime) else str(user['created_at'])

        profile_data = {
            'name': user['name'],
            'email': user['email'],
            'created_at': created_at_str,
            'gender': user['gender']
        }
        print(f"ID de usuario del token JWT: ", profile_data)

        return jsonify(profile_data), 200

    except Error as e:
        error_message = str(e)
        print(f"Error de MySQL (PyMySQL) en perfil: {error_message}")
        return jsonify({'message': f'Error en la base de datos del perfil: {error_message}'}), 500
    except Exception as e:
        error_message = str(e)
        print(f"Error general en perfil: {error_message}")
        return jsonify({'message': f'Error interno del servidor de perfil: {error_message}'}), 500
    finally:
        if cursor:
            cursor.close()
        if conn and conn.open:
            conn.close()

# Ruta para servir archivos desde la carpeta 'uploads'


@app.route('/uploads/<path:filename>')
def serve_uploaded_file(filename):
    # send_from_directory de Flask es la función clave para servir archivos
    return send_from_directory(UPLOAD_FOLDER, filename)

# Ruta para inscribir usuarios en un contenido educativo


@app.route('/api/inscribe_content', methods=['POST'])
def inscribe_content():
    data = request.get_json()
    user_id = data.get('userId')
    content_id = data.get('contentId')

    if not content_id:
        return jsonify({'error': 'No se puede inscribir ya que el conocimiento fue eliminado recientemente'}), 400

    conn = None
    try:
        conn = pymysql.connect(**DB_CONFIG)
        with conn.cursor() as cursor:

            values = (user_id, content_id)

            if data.get('consult'):
                sql = """
                SELECT id FROM content_inscriptions WHERE id_user = %s AND id_content = %s
                """
                cursor.execute(sql, values)
                existing_inscription = cursor.fetchone()

                if existing_inscription:

                    # Si existe, el usuario ya esta inscrito
                    return jsonify({'isRegistered': True, 'message': 'El usuario ya está inscrito en este contenido.'}), 200
                else:
                    print("Inscripción no encontrada.")
                    # Si no existe, el usuario no está inscrito
                    return jsonify({'isRegistered': False, 'message': 'El usuario NO está inscrito en este contenido.'}), 200

            else:

                sql = """
                INSERT INTO content_inscriptions (id_user, id_content, created_at)
                VALUES (%s, %s, NOW())
                """
                values = (user_id, content_id)

                cursor.execute(sql, values)
                conn.commit()  # Confirma los cambios en la base de datos

                # 201 Created
                return jsonify({'message': 'Inscripción exitosa'}), 201

    except pymysql.Error as e:

        print(f"Error de base de datos durante la inscripción: {e}")

        return jsonify({'error': f'Error en la base de datos: {str(e)}'}), 500
    except Exception as e:
        print(f"Error inesperado durante la inscripción: {e}")
        return jsonify({'error': f'Error interno del servidor: {str(e)}'}), 500
    finally:
        if conn:  # Asegúrate de cerrar la conexión
            conn.close()

# <<<< ENDPOINT PARA OBTENER LOS CONTENIDOS INSCRITOS DEL USUARIO >>>>


@app.route('/api/registered_contents', methods=['GET'])
@jwt_required  # <<<< ¡IMPORTANTE! PROTEGE ESTE ENDPOINT CON JWT >>>>
def get_user_registered_contents():
    conn = None
    cursor = None
    try:
        # Obtiene el ID del usuario del token JWT que fue decodificado por jwt_required
        user_id = request.current_user_id

        conn = pymysql.connect(**DB_CONFIG)
        # Para obtener resultados como diccionarios
        cursor = conn.cursor(pymysql.cursors.DictCursor)

        # Consulta SQL para obtener los detalles de los contenidos
        # a los que el usuario está inscrito.
        # Hacemos un JOIN entre 'contents' y 'content_inscriptions'
        sql = """
        SELECT
            c.id,
            c.title,
            c.description,
            c.author,
            c.category,
            c.file_url,
            c.user_id as creator_user_id,
            ci.created_at as inscription_date
        FROM contents c
        JOIN content_inscriptions ci ON c.id = ci.id_content
        WHERE ci.id_user = %s
        ORDER BY ci.created_at DESC
        """
        cursor.execute(sql, (user_id,))
        registered_contents = cursor.fetchall()

        if not registered_contents:
            # Devuelve 200 con lista vacía o mensaje
            return jsonify({'message': 'No se encontraron contenidos inscritos para este usuario.'}), 200

        return jsonify(registered_contents), 200

    except Error as e:
        error_message = str(e)
        print(
            f"Error de MySQL (PyMySQL) al obtener contenidos inscritos: {error_message}")
        return jsonify({'message': f'Error en la base de datos al obtener contenidos inscritos: {error_message}'}), 500
    except Exception as e:
        error_message = str(e)
        print(
            f"Error general al obtener contenidos inscritos: {error_message}")
        return jsonify({'message': f'Error interno del servidor al obtener contenidos inscritos: {error_message}'}), 500
    finally:
        if cursor:
            cursor.close()
        if conn and conn.open:
            conn.close()


# --- Ejecutar la Aplicación Flask ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)
