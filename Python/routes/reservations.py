from flask import Blueprint, request, jsonify, current_app

reservations_bp = Blueprint('reservations', __name__, url_prefix='/reservations')

@reservations_bp.route('/make', methods=['POST'])
def make_reservation():
    data = request.get_json()
    user_id = data.get('UserID')
    ticket_id = data.get('TicketID')
    expiration = data.get('ExpirationTime')  # Format: 'YYYY-MM-DD HH:MM:SS'

    cur = current_app.mysql.connection.cursor()
    cur.execute("""
        INSERT INTO Reservation (ReservationID, UserID, TicketID, ReservationStatus, ExpirationTime)
        VALUES (NULL, %s, %s, 'Reserved', %s)
    """, (user_id, ticket_id, expiration))
    current_app.mysql.connection.commit()
    cur.close()

    return jsonify({"message": "Reservation successful"}), 201

@reservations_bp.route('/<int:user_id>', methods=['GET'])
def get_user_reservations(user_id):
    cur = current_app.mysql.connection.cursor()
    query = """
        SELECT r.ReservationID, r.ReservationStatus, r.ReservationTime, t.Origin, t.Destination, t.DepartureTime
        FROM Reservation r
        JOIN Ticket t ON r.TicketID = t.TicketID
        WHERE r.UserID = %s
    """
    cur.execute(query, (user_id,))
    reservations = cur.fetchall()
    cur.close()

    return jsonify(reservations)
