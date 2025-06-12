from flask import Blueprint, request, jsonify, current_app
import jwt
from functools import wraps

report_bp = Blueprint('reports', __name__, url_prefix='/reports')

JWT_SECRET = 'your_jwt_secret_key_here'
JWT_ALGORITHM = 'HS256'

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


# 1. submit
@report_bp.route('/submit', methods=['POST'])
@login_required
def submit_report():
    data = request.get_json()
    ticket_id = data.get('ticketID')
    reservation_id = data.get('reservationID')
    category = data.get('reportCategory')
    text = data.get('reportText')

    if not category or not text:
        return jsonify({"message": "Category and report text are required."}), 400

    try:
        cur = current_app.mysql.connection.cursor()
        cur.execute("""
            INSERT INTO Reports (UserID, TicketID, ReservationID, ReportCategory, ReportText)
            VALUES (%s, %s, %s, %s, %s)
        """, (request.user_id, ticket_id, reservation_id, category, text))

        current_app.mysql.connection.commit()
        cur.close()
        return jsonify({"message": "Report submitted successfully."}), 201

    except Exception as e:
        return jsonify({"message": f"Error submitting report: {str(e)}"}), 500

# 2. see reports

@report_bp.route('/my', methods=['GET'])
@login_required
def get_my_reports():
    try:
        cur = current_app.mysql.connection.cursor()
        cur.execute("""
            SELECT ReportID, TicketID, ReservationID, ReportCategory, ReportText, ProcessingStatus
            FROM Reports
            WHERE UserID = %s
            ORDER BY ReportID DESC
        """, (request.user_id,))
        rows = cur.fetchall()
        cur.close()

        columns = ['ReportID', 'TicketID', 'ReservationID', 'ReportCategory', 'ReportText', 'ProcessingStatus']
        return jsonify([dict(zip(columns, row)) for row in rows]), 200

    except Exception as e:
        return jsonify({"message": f"Error retrieving reports: {str(e)}"}), 500


