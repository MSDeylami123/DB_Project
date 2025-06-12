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
            WHERE TicketID = %s AND (
                (ReservationStatus = 'Reserved' AND ExpirationTime > NOW()) OR
                (ReservationStatus = 'Confirmed')
            )
            LIMIT 1
        """, (ticket_id,))
        if cur.fetchone():
            cur.close()
            return jsonify({"message": "Ticket is already reserved or sold."}), 409


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

# 4. Pay for a reserved ticket
@reservations_bp.route('/pay', methods=['POST'])
@login_required
def pay_for_ticket():
    data = request.get_json()
    reservation_id = data.get('reservationID')
    payment_method = data.get('paymentMethod')
    user_id = request.user_id

    valid_methods = ['Wallet', 'Bank Card', 'Cryptocurrency']
    is_valid = payment_method in valid_methods

    try:
        cur = current_app.mysql.connection.cursor()

        # Check reservation validity
        cur.execute("""
            SELECT r.TicketID, r.ReservationStatus, r.ExpirationTime, t.Price
            FROM Reservation r
            JOIN Ticket t ON r.TicketID = t.TicketID
            WHERE r.ReservationID = %s AND r.UserID = %s
        """, (reservation_id, user_id))
        reservation = cur.fetchone()

        if not reservation:
            return jsonify({"message": "Reservation not found."}), 404

        ticket_id, status, expiration, price = reservation

        if status != 'Reserved':
            return jsonify({"message": "Only reserved tickets can be paid for."}), 400

        if expiration < datetime.now():
            return jsonify({"message": "Reservation has expired."}), 400

        # Determine payment status
        payment_status = 'Successful' if is_valid else 'Failed'

        payment_method = payment_method if is_valid else 'Wallet'

        # Insert into Payment table
        cur.execute("""
            INSERT INTO Payment (UserID, ReservationID, Amount, PaymentMethod, PaymentStatus)
            VALUES (%s, %s, %s, %s, %s)
        """, (user_id, reservation_id, price, payment_method, payment_status))

        # If successful, update reservation status
        if is_valid:
            cur.execute("""
                UPDATE Reservation
                SET ReservationStatus = 'Paid'
                WHERE ReservationID = %s AND UserID = %s
            """, (reservation_id, user_id))

        current_app.mysql.connection.commit()
        cur.close()

        if is_valid:
            return jsonify({"message": "Payment successful. Ticket confirmed."}), 200
        else:
            return jsonify({"message": "Payment failed: Invalid payment method."}), 200

    except Exception as e:
        return jsonify({"message": f"Error processing payment: {str(e)}"}), 500


# 5.see purchased tickets
@reservations_bp.route('/purchased', methods=['GET'])
@login_required
def get_purchased_tickets():
    user_id = request.user_id
    try:
        cur = current_app.mysql.connection.cursor()

        cur.execute("""
            SELECT r.ReservationID, r.TicketID, r.ReservationStatus,
                   t.Origin, t.Destination, t.DepartureTime, t.VehicleType,
                   p.PaymentStatus, p.PaymentTime
            FROM Reservation r
            JOIN Ticket t ON r.TicketID = t.TicketID
            LEFT JOIN Payment p ON r.ReservationID = p.ReservationID
            WHERE r.UserID = %s AND p.PaymentStatus = 'Successful'
            ORDER BY t.DepartureTime ASC
        """, (user_id,))

        rows = cur.fetchall()
        cur.close()

        columns = [
            "ReservationID", "TicketID", "ReservationStatus",
            "Origin", "Destination", "DepartureTime", "VehicleType",
            "PaymentStatus", "PaymentTime"
        ]

        tickets = [dict(zip(columns, row)) for row in rows]

        # Classify tickets by status
        upcoming = []
        canceled = []
        used = []

        now = datetime.now()

        for ticket in tickets:
            dep_time = ticket["DepartureTime"]
            status = ticket["ReservationStatus"]

            if status == "Canceled":
                canceled.append(ticket)
            elif status == "Paid" and dep_time > now:
                upcoming.append(ticket)
            elif status == "Paid" and dep_time <= now:
                used.append(ticket)

        return jsonify({
            "upcoming": upcoming,
            "canceled": canceled,
            "used": used
        }), 200

    except Exception as e:
        return jsonify({"message": f"Error fetching purchased tickets: {str(e)}"}), 500

# 6. see penalty
@reservations_bp.route('/penalty/<int:reservation_id>', methods=['GET'])
@login_required
def check_cancellation_penalty(reservation_id):
    user_id = request.user_id

    try:
        cur = current_app.mysql.connection.cursor()

        cur.execute("""
            SELECT r.ReservationStatus, t.DepartureTime, t.Price, f.AirlineName, tr.StarRating, b.BusCompany
            FROM Reservation r
            JOIN Ticket t ON r.TicketID = t.TicketID
            LEFT JOIN Flight f ON t.TicketID = f.TicketID
            LEFT JOIN Train tr ON t.TicketID = tr.TicketID
            LEFT JOIN Bus b ON t.TicketID = b.TicketID
            WHERE r.ReservationID = %s AND r.UserID = %s
        """, (reservation_id, user_id))

        res = cur.fetchone()
        cur.close()

        if not res:
            return jsonify({"message": "Reservation not found."}), 404

        status, departure_time, price, airline, star_rating, bus_company = res

        if status != 'Paid':
            return jsonify({"message": "Only paid tickets can be cancelled."}), 400

        time_diff = departure_time - datetime.now()
        hours_left = time_diff.total_seconds() / 3600

        # Determine penalty %
        if hours_left > 48:
            penalty_pct = 10
        elif 24 < hours_left <= 48:
            penalty_pct = 50
        elif hours_left <= 24:
            penalty_pct = 80
        else:
            penalty_pct = 100  # past departure? no refund

        refund_amount = float(price) * (1 - penalty_pct / 100)

        # You can customize penalty based on airline, star_rating, bus_company here

        return jsonify({
            "PenaltyPercentage": penalty_pct,
            "RefundAmount": round(refund_amount, 2),
            "Price": price,
            "HoursLeft": round(hours_left, 2)
        }), 200

    except Exception as e:
        return jsonify({"message": f"Error checking penalty: {str(e)}"}), 500

# 7. cancel

@reservations_bp.route('/cancel', methods=['POST'])
@login_required
def cancel_ticket():
    data = request.get_json()
    reservation_id = data.get('reservationID')
    user_id = request.user_id

    try:
        cur = current_app.mysql.connection.cursor()

        # Get reservation and ticket price
        cur.execute("""
            SELECT r.ReservationStatus, t.DepartureTime, t.Price
            FROM Reservation r
            JOIN Ticket t ON r.TicketID = t.TicketID
            WHERE r.ReservationID = %s AND r.UserID = %s
        """, (reservation_id, user_id))
        res = cur.fetchone()

        if not res:
            return jsonify({"message": "Reservation not found."}), 404

        status, departure_time, price = res

        if status != 'Paid':
            return jsonify({"message": "Only paid tickets can be cancelled."}), 400

        time_diff = departure_time - datetime.now()
        hours_left = time_diff.total_seconds() / 3600

        # Determine penalty %
        if hours_left > 48:
            penalty_pct = 10
        elif 24 < hours_left <= 48:
            penalty_pct = 50
        elif hours_left <= 24:
            penalty_pct = 80
        else:
            return jsonify({"message": "Cannot cancel after departure."}), 400

        refund_amount = float(price) * (1 - penalty_pct / 100)

        # Update reservation status
        cur.execute("""
            UPDATE Reservation
            SET ReservationStatus = 'Canceled'
            WHERE ReservationID = %s AND UserID = %s
        """, (reservation_id, user_id))

        # Add refund to user's wallet balance
        # Assuming you have a UserWallet table: UserID, Balance (DECIMAL)
        cur.execute("""
            UPDATE UserWallet
            SET Balance = Balance + %s
            WHERE UserID = %s
        """, (refund_amount, user_id))

        current_app.mysql.connection.commit()
        cur.close()

        return jsonify({
            "message": "Ticket cancelled successfully.",
            "RefundAmount": round(refund_amount, 2),
            "PenaltyPercentage": penalty_pct
        }), 200

    except Exception as e:
        return jsonify({"message": f"Error cancelling ticket: {str(e)}"}), 500

