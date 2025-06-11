from flask import Flask, request, jsonify
import pymysql
from pymysql import Error
from flask_cors import CORS
import bcrypt
import jwt
import datetime
from functools import wraps
# <<-- CAMBIO CLAVE AQUÍ
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

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
                'exp': datetime.datetime.utcnow() + datetime.timedelta(minutes=20)
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
            file_url = data.get('file_url')
            user_id = request.current_user_id

            if not all([title, description, author, category, file_url]):
                return jsonify({'message': 'Faltan campos obligatorios para el contenido'}), 400

            sql = """
            INSERT INTO contents (title, description, author, category, file_url, user_id,created_at)
            VALUES (%s, %s, %s, %s, %s, %s, NOW())
            """
            values = (title, description, author, category,
                      file_url, user_id)

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


# --- Ejecutar la Aplicación Flask ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)
