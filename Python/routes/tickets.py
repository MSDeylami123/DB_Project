from flask import Blueprint, request, jsonify, current_app
import jwt
import redis
from functools import wraps
from elasticsearch import Elasticsearch
import threading
import time

# --------------------- Blueprint ---------------------
tickets_bp = Blueprint('tickets', __name__, url_prefix='/tickets')

# --------------------- JWT Config ---------------------
JWT_SECRET = 'your_jwt_secret_key_here'
JWT_ALGORITHM = 'HS256'

# --------------------- Redis ---------------------
redis_client = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

# --------------------- Elasticsearch client ---------------------
es = Elasticsearch(
    ["http://localhost:9200"],
    basic_auth=("elastic", "YOUR_ELASTIC_PASSWORD"),  # replace with your password
    verify_certs=False
)
ES_INDEX = "tickets"

# --------------------- JWT Decorator ---------------------
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

# --------------------- Utility: Index ticket into Elasticsearch ---------------------
def index_ticket_es(ticket):
    try:
        es.index(
            index=ES_INDEX,
            id=ticket["TicketID"],
            document=ticket
        )
    except Exception as e:
        print(f"[ES SYNC ERROR] Failed to index ticket {ticket['TicketID']}: {str(e)}")

# --------------------- 4. List of Cities ---------------------
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

# --------------------- 5. Search Tickets (Elasticsearch) ---------------------
@tickets_bp.route('/search', methods=['POST'])
@login_required
def search_tickets():
    data = request.get_json()
    origin = data.get('origin')
    destination = data.get('destination')
    date = data.get('date')
    vehicle_type = data.get('vehicleType')
    filters = data.get('filters', {})

    es_query = {"bool": {"must": []}}

    if origin:
        es_query["bool"]["must"].append({"match": {"Origin": origin}})
    if destination:
        es_query["bool"]["must"].append({"match": {"Destination": destination}})
    if date:
        es_query["bool"]["must"].append({"match": {"DepartureTime": date}})
    if vehicle_type:
        es_query["bool"]["must"].append({"match": {"VehicleType": vehicle_type}})

    if filters.get("price_min") or filters.get("price_max"):
        price_filter = {}
        if filters.get("price_min"):
            price_filter["gte"] = filters["price_min"]
        if filters.get("price_max"):
            price_filter["lte"] = filters["price_max"]
        es_query["bool"]["must"].append({"range": {"Price": price_filter}})

    if filters.get("departure_after"):
        es_query["bool"]["must"].append({"range": {"DepartureTime": {"gte": filters["departure_after"]}}})
    if filters.get("class"):
        es_query["bool"]["must"].append({"match": {"TravelClass": filters["class"]}})

    try:
        res = es.search(index=ES_INDEX, query=es_query)
        tickets = []
        for hit in res['hits']['hits']:
            t = hit["_source"]
            # Transform keys to match frontend expectations
            tickets.append({
                "ticketID": t["TicketID"],
                "origin": t["Origin"],
                "destination": t["Destination"],
                "vehicleType": t["VehicleType"],
                "travelClass": t["TravelClass"],
                "price": float(t["Price"]),
                "departureTime": t["DepartureTime"].isoformat() if hasattr(t["DepartureTime"], "isoformat") else t["DepartureTime"],
                "arrivalTime": t["ArrivalTime"].isoformat() if hasattr(t["ArrivalTime"], "isoformat") else t["ArrivalTime"]
            })
        return jsonify({"tickets": tickets}), 200
    except Exception as e:
        return jsonify({"message": f"Error searching tickets: {str(e)}"}), 500

# --------------------- 6. Ticket Details ---------------------
@tickets_bp.route('/<int:ticket_id>', methods=['GET'])
@login_required
def ticket_details(ticket_id):
    try:
        cur = current_app.mysql.connection.cursor()
        cur.execute("""
            SELECT TicketID, Origin, Destination, DepartureTime, ArrivalTime, Price,
                   VehicleType, TravelClass, Capacity
            FROM Ticket
            WHERE TicketID = %s
        """, (ticket_id,))
        row = cur.fetchone()

        if not row:
            cur.close()
            return jsonify({"message": "Ticket not found"}), 404

        ticket = dict(zip(
            ["TicketID","Origin","Destination","DepartureTime","ArrivalTime",
             "Price","VehicleType","TravelClass","Capacity"], row
        ))

        details = {
            "ticketID": ticket["TicketID"],
            "origin": ticket["Origin"],
            "destination": ticket["Destination"],
            "departureTime": ticket["DepartureTime"].isoformat(),
            "arrivalTime": ticket["ArrivalTime"].isoformat(),
            "price": float(ticket["Price"]),
            "vehicleType": ticket["VehicleType"],
            "travelClass": ticket["TravelClass"],
            "capacity": ticket["Capacity"],
            "facilities": None
        }

        vehicle_type = ticket["VehicleType"].lower()

        if vehicle_type == 'plane':
            cur.execute("""
                SELECT AirlineName, FlightNumber, Facilities
                FROM Flight
                WHERE TicketID = %s
            """, (ticket_id,))
            row = cur.fetchone()
            if row:
                details["airlineName"] = row[0]
                details["flightNumber"] = row[1]
                details["facilities"] = row[2]

        elif vehicle_type == 'train':
            cur.execute("""
                SELECT StarRating, CompartmentOption, Facilities
                FROM Train
                WHERE TicketID = %s
            """, (ticket_id,))
            row = cur.fetchone()
            if row:
                details["trainStarRating"] = row[0]
                details["trainCompartmentOption"] = row[1]
                details["facilities"] = row[2]

        elif vehicle_type == 'bus':
            cur.execute("""
                SELECT BusCompany, SeatsPerRow, Facilities
                FROM Bus
                WHERE TicketID = %s
            """, (ticket_id,))
            row = cur.fetchone()
            if row:
                details["busCompany"] = row[0]
                details["busSeatsPerRow"] = row[1]
                details["facilities"] = row[2]

        cur.close()
        return jsonify(details), 200

    except Exception as e:
        return jsonify({"message": f"Error retrieving ticket details: {str(e)}"}), 500

# --------------------- 7. Bulk Index Existing Tickets ---------------------
def index_all_tickets():
    try:
        cur = current_app.mysql.connection.cursor()
        cur.execute("SELECT * FROM Ticket")
        rows = cur.fetchall()
        columns = [desc[0] for desc in cur.description]

        for row in rows:
            ticket = dict(zip(columns, row))
            index_ticket_es(ticket)
        cur.close()
        print("[ES SYNC] All tickets indexed.")
    except Exception as e:
        print(f"[ES SYNC ERROR] Failed to index all tickets: {str(e)}")

# --------------------- 8. Background Sync Thread ---------------------
def es_sync_background(app, interval=300):
    """Background thread to index all tickets every `interval` seconds"""
    while True:
        try:
            with app.app_context():
                index_all_tickets()
        except Exception as e:
            print(f"[ES SYNC ERROR] {str(e)}")
        time.sleep(interval)

def start_es_sync(app, interval=300):
    """Start background thread for ES sync"""
    thread = threading.Thread(target=es_sync_background, args=(app, interval), daemon=True)
    thread.start()
    print("[ES SYNC] Background sync thread started.")
