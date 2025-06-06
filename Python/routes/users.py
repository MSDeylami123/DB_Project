from flask import Blueprint, request, jsonify, current_app
import jwt
import datetime
import redis

users_bp = Blueprint('users', __name__, url_prefix='/users')

# JWT Config
JWT_SECRET = 'your_jwt_secret_key_here'
JWT_ALGORITHM = 'HS256'
JWT_EXP_DELTA_SECONDS = 3600

# Redis Client
redis_client = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

@users_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()

    first_name = data.get('firstName')
    last_name = data.get('lastName')
    email = data.get('email')
    phone = data.get('phone')
    password = data.get('password')
    user_type = data.get('userType', 'Passenger')
    city = data.get('city', None)

    if not all([first_name, last_name, password]) or (email is None and phone is None):
        return jsonify({"message": "Missing required fields (name, password, email or phone)"}), 400

    password_hash = current_app.bcrypt.generate_password_hash(password).decode('utf-8')

    try:
        cur = current_app.mysql.connection.cursor()
        sql = """
            INSERT INTO User (FirstName, LastName, Email, Phone, UserType, City, PasswordHash)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (first_name, last_name, email, phone, user_type, city, password_hash))
        current_app.mysql.connection.commit()
        user_id = cur.lastrowid
        cur.close()

        # Cache user info in Redis
        redis_client.hset(f"user:{email}", mapping={
            "firstName": first_name,
            "lastName": last_name,
            "phone": phone or "",
            "city": city or "",
            "userType": user_type
        })

    except Exception as e:
        current_app.mysql.connection.rollback()
        return jsonify({"message": f"Error registering user: {str(e)}"}), 400

    payload = {
        'user_id': user_id,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(seconds=JWT_EXP_DELTA_SECONDS)
    }
    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

    return jsonify({"message": "User registered successfully", "token": token}), 201


@users_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"message": "Email and password are required"}), 400

    try:
        cur = current_app.mysql.connection.cursor()
        cur.execute("SELECT UserID, PasswordHash FROM User WHERE Email=%s", (email,))
        row = cur.fetchone()
        cur.close()

        if row:
            user_id, password_hash = row[0], row[1]
            if current_app.bcrypt.check_password_hash(password_hash, password):
                payload = {
                    'user_id': user_id,
                    'exp': datetime.datetime.utcnow() + datetime.timedelta(seconds=JWT_EXP_DELTA_SECONDS)
                }
                token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)
                return jsonify({"message": "Login successful", "token": token}), 200

        return jsonify({"message": "Invalid credentials"}), 401

    except Exception as e:
        return jsonify({"message": f"Login error: {str(e)}"}), 500


@users_bp.route('/update-profile', methods=['PUT'])
def update_profile():
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        return jsonify({"message": "Missing Authorization header"}), 401

    try:
        token = auth_header.split(" ")[1]
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        user_id = payload['user_id']
    except Exception:
        return jsonify({"message": "Invalid or expired token"}), 401

    data = request.get_json()
    first_name = data.get('firstName')
    last_name = data.get('lastName')
    phone = data.get('phone')
    city = data.get('city')

    try:
        cur = current_app.mysql.connection.cursor()
        cur.execute("""
            UPDATE User SET FirstName=%s, LastName=%s, Phone=%s, City=%s WHERE UserID=%s
        """, (first_name, last_name, phone, city, user_id))
        current_app.mysql.connection.commit()

        # Fetch email to update Redis cache
        cur.execute("SELECT Email FROM User WHERE UserID=%s", (user_id,))
        row = cur.fetchone()
        cur.close()

        if row:
            email = row[0]
            redis_client.hset(f"user:{email}", mapping={
                "firstName": first_name,
                "lastName": last_name,
                "phone": phone or "",
                "city": city or ""
            })

        return jsonify({"message": "Profile updated successfully"}), 200

    except Exception as e:
        current_app.mysql.connection.rollback()
        return jsonify({"message": f"Error updating profile: {str(e)}"}), 500
