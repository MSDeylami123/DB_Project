from flask import Blueprint, request, jsonify, current_app
import jwt
import redis
from functools import wraps

# Blueprint
tickets_bp = Blueprint('tickets', __name__, url_prefix='/tickets')

# JWT Config
JWT_SECRET = 'your_jwt_secret_key_here'
JWT_ALGORITHM = 'HS256'

# Redis Client
redis_client = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

# Decorator to protect routes
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

# 4. List of Cities
@tickets_bp.route('/cities', methods=['GET'])
@login_required
def get_cities():
    try:
        cur = current_app.mysql.connection.cursor()
        cur.execute("SELECT DISTINCT Origin FROM Ticket")
        origins = [row[0] for row in cur.fetchall()]

        cur.execute("SELECT DISTINCT Destination FROM Ticket")
        destinations = [row[0] for row in cur.fetchall()]
        cur.close()

        return jsonify({"origins": origins, "destinations": destinations}), 200
    except Exception as e:
        return jsonify({"message": f"Error retrieving cities: {str(e)}"}), 500

# 5. Search Tickets
@tickets_bp.route('/search', methods=['POST'])
@login_required
def search_tickets():
    data = request.get_json()
    origin = data.get('origin')
    destination = data.get('destination')
    date = data.get('date')
    vehicle_type = data.get('vehicleType')
    filters = data.get('filters', {})

    query = "SELECT TicketID, Origin, Destination, DepartureTime, ArrivalTime, Price, VehicleType, TravelClass, CarrierID FROM Ticket WHERE 1=1"
    params = []

    if origin:
        query += " AND Origin = %s"
        params.append(origin)
    if destination:
        query += " AND Destination = %s"
        params.append(destination)
    if date:
        query += " AND DATE(DepartureTime) = %s"
        params.append(date)
    if vehicle_type:
        query += " AND VehicleType = %s"
        params.append(vehicle_type)

    # Optional filters
    if 'price_min' in filters:
        query += " AND Price >= %s"
        params.append(filters['price_min'])
    if 'price_max' in filters:
        query += " AND Price <= %s"
        params.append(filters['price_max'])
    if 'departure_after' in filters:
        query += " AND TIME(DepartureTime) >= %s"
        params.append(filters['departure_after'])
    if 'class' in filters:
        query += " AND TravelClass = %s"
        params.append(filters['class'])

    try:
        cur = current_app.mysql.connection.cursor()
        cur.execute(query, tuple(params))
        rows = cur.fetchall()
        cur.close()

        tickets = []
        for row in rows:
            tickets.append({
                "ticketID": row[0],
                "origin": row[1],
                "destination": row[2],
                "departureTime": row[3].isoformat(),
                "arrivalTime": row[4].isoformat(),
                "price": float(row[5]),
                "vehicleType": row[6],
                "travelClass": row[7],
                "carrierID": row[8]
            })

        return jsonify({"tickets": tickets}), 200

    except Exception as e:
        return jsonify({"message": f"Error searching tickets: {str(e)}"}), 500

# 6. Ticket Details
@tickets_bp.route('/<int:ticket_id>', methods=['GET'])
@login_required
def ticket_details(ticket_id):
    try:
        cur = current_app.mysql.connection.cursor()
        query = """
            SELECT TicketID, Origin, Destination, DepartureTime, ArrivalTime, Price, VehicleType, TravelClass, CarrierID
            FROM Ticket
            WHERE TicketID = %s
        """
        cur.execute(query, (ticket_id,))
        row = cur.fetchone()
        cur.close()

        if not row:
            return jsonify({"message": "Ticket not found"}), 404

        details = {
            "ticketID": row[0],
            "origin": row[1],
            "destination": row[2],
            "departureTime": row[3].isoformat(),
            "arrivalTime": row[4].isoformat(),
            "price": float(row[5]),
            "vehicleType": row[6],
            "travelClass": row[7],
            "carrierID": row[8]
        }

        return jsonify(details), 200

    except Exception as e:
        return jsonify({"message": f"Error retrieving ticket details: {str(e)}"}), 500
