from flask import Blueprint, request, jsonify, current_app
from datetime import datetime, timedelta
import jwt
from functools import wraps

reservations_bp = Blueprint('reservations', __name__, url_prefix='/reservations')

# JWT config
JWT_SECRET = 'your_jwt_secret_key_here'
JWT_ALGORITHM = 'HS256'

# Decorator

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return jsonify({"message": "Missing Authorization header"}), 401
        try:
            token = auth_header.split(" ")[1]
            payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
            request.user_id = payload["user_id"]
        except Exception:
            return jsonify({"message": "Invalid or expired token"}), 401
        return f(*args, **kwargs)
    return decorated

# 1. Reserve a ticket
@reservations_bp.route('/reserve', methods=['POST'])
@login_required
def reserve_ticket():
    data = request.get_json()
    ticket_id = data.get('ticketID')
    user_id = request.user_id

    try:
        cur = current_app.mysql.connection.cursor()

        # Check if ticket is already reserved and not expired
        cur.execute("""
            SELECT 1 FROM Reservation
            WHERE TicketID = %s AND ReservationStatus = 'Reserved' AND ExpirationTime > NOW()
            LIMIT 1
        """, (ticket_id,))
        if cur.fetchone():
            cur.close()
            return jsonify({"message": "Ticket is already reserved by someone else."}), 409

        # Insert reservation with ExpirationTime 10 minutes from now (calculated by DB)
        cur.execute("""
            INSERT INTO Reservation (UserID, TicketID, ReservationStatus, ExpirationTime)
            VALUES (%s, %s, 'Reserved', DATE_ADD(NOW(), INTERVAL 10 MINUTE))
        """, (user_id, ticket_id))

        current_app.mysql.connection.commit()
        cur.close()

        return jsonify({"message": "Ticket reserved for 10 minutes."}), 201

    except Exception as e:
        return jsonify({"message": f"Error reserving ticket: {str(e)}"}), 500

# 2. Cancel expired reservations (can be triggered manually or set on cronjob)
@reservations_bp.route('/cleanup', methods=['POST'])
@login_required
def cancel_expired():
    try:
        cur = current_app.mysql.connection.cursor()

        cur.execute("""
            UPDATE Reservation
            SET ReservationStatus = 'Canceled'
            WHERE ReservationStatus = 'Reserved' AND ExpirationTime < NOW()
        """)

        affected = cur.rowcount
        current_app.mysql.connection.commit()
        cur.close()

        return jsonify({"message": f"{affected} expired reservations canceled."}), 200

    except Exception as e:
        return jsonify({"message": f"Error cleaning up expired reservations: {str(e)}"}), 500

# 3. View reservations (active & history)
@reservations_bp.route('/my', methods=['GET'])
@login_required
def view_reservations():
    user_id = request.user_id

    try:
        cur = current_app.mysql.connection.cursor()

        cur.execute("""
            SELECT r.ReservationID, r.TicketID, r.ReservationStatus,
                   r.ReservationTime, r.ExpirationTime,
                   t.Origin, t.Destination, t.DepartureTime, t.VehicleType
            FROM Reservation r
            JOIN Ticket t ON r.TicketID = t.TicketID
            WHERE r.UserID = %s
            ORDER BY r.ReservationTime DESC
        """, (user_id,))

        rows = cur.fetchall()
        cur.close()

        columns = [
            "ReservationID", "TicketID", "ReservationStatus",
            "ReservationTime", "ExpirationTime",
            "Origin", "Destination", "DepartureTime", "VehicleType"
        ]

        reservations = [dict(zip(columns, row)) for row in rows]

        # Separate active vs history
        active = [r for r in reservations if r["ReservationStatus"] == "Reserved"]
        history = [r for r in reservations if r["ReservationStatus"] != "Reserved"]

        return jsonify({"active": active, "history": history}), 200

    except Exception as e:
        return jsonify({"message": f"Error retrieving reservations: {str(e)}"}), 500
