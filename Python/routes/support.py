from flask import Blueprint, request, jsonify, current_app
import jwt
from functools import wraps

support_bp = Blueprint('support', __name__, url_prefix='/support')

# JWT config (replace with your actual secret and algorithm)
JWT_SECRET = 'your_jwt_secret_key_here'
JWT_ALGORITHM = 'HS256'

# Decorator to require login and decode user_id from JWT token
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

# Decorator to require support role by querying DB
def support_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        user_id = getattr(request, 'user_id', None)
        if not user_id:
            return jsonify({"message": "Unauthorized"}), 401
        cur = current_app.mysql.connection.cursor()
        cur.execute("SELECT UserType FROM User WHERE UserID = %s", (user_id,))
        result = cur.fetchone()
        cur.close()
        if not result or result[0] != 'Support':
            return jsonify({"message": "Support access required"}), 403
        return f(*args, **kwargs)
    return decorated

# 1. View all reports
@support_bp.route('/admin/reports', methods=['GET'])
@login_required
@support_required
def view_all_reports():
    cur = current_app.mysql.connection.cursor()
    try:
        cur.execute("""
            SELECT r.*, u.FirstName, u.LastName
            FROM Reports r
            JOIN User u ON r.UserID = u.UserID
            ORDER BY FIELD(r.ProcessingStatus, 'Pending', 'Reviewed'), r.ReportID DESC
        """)
        reports = cur.fetchall()
        columns = [desc[0] for desc in cur.description]
        reports_list = [dict(zip(columns, row)) for row in reports]
    finally:
        cur.close()
    return jsonify(reports_list)

# 2. Respond to a report (update ProcessingStatus)
@support_bp.route('/admin/reports/respond', methods=['POST'])
@login_required
@support_required
def respond_to_report():
    data = request.get_json()
    report_id = data.get("ReportID")
    new_status = data.get("ProcessingStatus")
    answer = data.get("Answer")  # New field (optional)

    if not report_id or new_status not in ['Reviewed', 'Pending']:
        return jsonify({"error": "Invalid input"}), 400

    cur = current_app.mysql.connection.cursor()
    try:
        if answer is not None:
            cur.execute("""
                UPDATE Reports 
                SET ProcessingStatus = %s, Answer = %s 
                WHERE ReportID = %s
            """, (new_status, answer, report_id))
        else:
            cur.execute("""
                UPDATE Reports 
                SET ProcessingStatus = %s 
                WHERE ReportID = %s
            """, (new_status, report_id))

        current_app.mysql.connection.commit()
    except Exception as e:
        current_app.mysql.connection.rollback()
        return jsonify({"error": f"Database error: {str(e)}"}), 500
    finally:
        cur.close()

    return jsonify({"message": "Report updated"})


# 1. View all reservations
@support_bp.route('/reservations', methods=['GET'])
@login_required
@support_required
def get_all_reservations():
    cur = current_app.mysql.connection.cursor()
    try:
        cur.execute("""
            SELECT r.ReservationID, r.TicketID, r.ReservationStatus,
                   r.ReservationTime, r.ExpirationTime,
                   t.Origin, t.Destination, t.DepartureTime, t.VehicleType,
                   u.FirstName, u.LastName
            FROM Reservation r
            JOIN Ticket t ON r.TicketID = t.TicketID
            JOIN User u ON r.UserID = u.UserID
            ORDER BY r.ReservationTime DESC
        """)
        reservations = cur.fetchall()
        columns = [desc[0] for desc in cur.description]
        reservations_list = [dict(zip(columns, row)) for row in reservations]
    finally:
        cur.close()
    return jsonify(reservations_list)

# 2. Cancel any reservation
@support_bp.route('/reservations/cancel', methods=['POST'])
@login_required
@support_required
def cancel_any_reservation():
    data = request.get_json()
    reservation_id = data.get('ReservationID')

    if not reservation_id:
        return jsonify({"message": "ReservationID is required"}), 400

    cur = current_app.mysql.connection.cursor()
    try:
        # Check reservation exists
        cur.execute("SELECT ReservationStatus FROM Reservation WHERE ReservationID = %s", (reservation_id,))
        res = cur.fetchone()
        if not res:
            return jsonify({"message": "Reservation not found"}), 404

        current_status = res[0]
        if current_status == 'Canceled':
            return jsonify({"message": "Reservation is already canceled"}), 400

        # Update reservation status to Canceled
        cur.execute("UPDATE Reservation SET ReservationStatus = 'Canceled' WHERE ReservationID = %s", (reservation_id,))
        current_app.mysql.connection.commit()
    except Exception as e:
        current_app.mysql.connection.rollback()
        return jsonify({"message": f"Database error: {str(e)}"}), 500
    finally:
        cur.close()

    return jsonify({"message": "Reservation cancelled successfully"})

# 3. View all cancelled payments
@support_bp.route('/payments/cancelled', methods=['GET'])
@login_required
@support_required
def get_cancelled_payments():
    cur = current_app.mysql.connection.cursor()
    try:
        cur.execute("""
            SELECT p.PaymentID, p.UserID, p.ReservationID, p.Amount, p.PaymentMethod, p.PaymentStatus, p.PaymentTime,
                   u.FirstName, u.LastName
            FROM Payment p
            JOIN User u ON p.UserID = u.UserID
            WHERE p.PaymentStatus IN ('Canceled', 'Failed')
            ORDER BY p.PaymentTime DESC
        """)
        payments = cur.fetchall()
        columns = [desc[0] for desc in cur.description]
        payments_list = [dict(zip(columns, row)) for row in payments]
    finally:
        cur.close()
    return jsonify(payments_list)