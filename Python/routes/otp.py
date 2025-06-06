from flask import Blueprint, request, jsonify, current_app
import random
import redis
import jwt
import datetime

#Auth

otp_bp = Blueprint('otp_bp', __name__)

redis_client = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)
OTP_TTL = 300  # 5 minutes

# JWT Config - make sure these match your users.py
JWT_SECRET = 'your_jwt_secret_key_here'
JWT_ALGORITHM = 'HS256'
JWT_EXP_DELTA_SECONDS = 3600

def send_otp(contact, otp):
    print(f"[DEV] Sending OTP {otp} to {contact}")
    return True

@otp_bp.route('/otp/request-otp', methods=['POST'])
def request_otp():
    data = request.get_json()
    contact = data.get('contact')

    if not contact:
        return jsonify({"message": "Contact (email or phone) is required"}), 400

    cur = current_app.mysql.connection.cursor()
    cur.execute("SELECT * FROM User WHERE Email = %s OR Phone = %s", (contact, contact))
    user = cur.fetchone()
    cur.close()

    if not user:
        return jsonify({"message": "User not found. Please sign up first."}), 404

    otp = str(random.randint(100000, 999999))
    redis_client.setex(f"otp:{contact}", OTP_TTL, otp)
    send_otp(contact, otp)

    return jsonify({"message": "OTP sent successfully"}), 200

@otp_bp.route('/otp/verify-otp', methods=['POST'])
def verify_otp():
    data = request.get_json()
    contact = data.get('contact')
    submitted_otp = data.get('otp')

    if not contact or not submitted_otp:
        return jsonify({"message": "Contact and OTP are required"}), 400

    stored_otp = redis_client.get(f"otp:{contact}")
    if not stored_otp:
        return jsonify({"message": "OTP expired or not found"}), 400

    if stored_otp == submitted_otp:
        redis_client.delete(f"otp:{contact}")

        # Get user info to get user_id
        cur = current_app.mysql.connection.cursor()
        cur.execute("SELECT UserID FROM User WHERE Email = %s OR Phone = %s", (contact, contact))
        user = cur.fetchone()
        cur.close()

        if not user:
            return jsonify({"message": "User not found"}), 404

        user_id = user[0]

        # Create JWT token exactly like in users.py
        payload = {
            'user_id': user_id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(seconds=JWT_EXP_DELTA_SECONDS)
        }
        token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

        return jsonify({
            "message": "OTP verified successfully",
            "token": token
        }), 200
    else:
        return jsonify({"message": "Incorrect OTP"}), 401
