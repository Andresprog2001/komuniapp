from flask import Flask, request, jsonify
import pymysql
from pymysql import Error  # Importamos Error desde PyMySQL

app = Flask(__name__)

# --- Configuración de la Base de Datos MySQL ---
DB_CONFIG = {
    'host': '127.0.0.1',
    'database': 'komuniapp',
    'user': 'root',
    'password': '',
    'port': 3306
}

# --- Endpoint de Registro de Usuario ---


@app.route('/api/register', methods=['POST'])
def register_user():
    conn = None
    cursor = None
    try:
        data = request.get_json()  # Obtiene los datos JSON enviados por Flutter

        # Validar que los datos necesarios estén presentes
        if not data:
            return jsonify({'message': 'Datos JSON no proporcionados'}), 400

        full_name = data.get('full_name')
        email = data.get('email')
        password = data.get('password')
        gender = data.get('gender')
        terms_accepted = data.get('terms_accepted')

        if not all([full_name, email, password, gender, terms_accepted is not None]):
            return jsonify({'message': 'Faltan campos obligatorios (full_name, email, password, gender, terms_accepted)'}), 400

        # Conectar a la base de datos
        conn = pymysql.connect(**DB_CONFIG)
        if conn.open:
            cursor = conn.cursor()

            # Consulta SQL para insertar el nuevo usuario
            sql = """
            INSERT INTO users (full_name, email, password, gender, terms_accepted)
            VALUES (%s, %s, %s, %s, %s)
            """
            values = (full_name, email, password, gender, terms_accepted)

            cursor.execute(sql, values)
            conn.commit()  # Confirma los cambios en la base de datos

            # 201 Created
            return jsonify({'message': 'Usuario registrado exitosamente!'}), 201

    except Error as e:  # <<-- Captura errores específicos de PyMySQL
        print(f"Error de MySQL (PyMySQL): {e}")
        return jsonify({'message': f'Error en la base de datos: {e}'}), 500
    except Exception as e:
        print(f"Error general: {e}")
        return jsonify({'message': f'Error interno del servidor: {e}'}), 500
    finally:
        if cursor:
            cursor.close()
        if conn and conn.open:  # <<-- Cierra la conexión usando .open
            conn.close()


# --- Ejecutar la Aplicación Flask ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)
