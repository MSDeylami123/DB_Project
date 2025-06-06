from flask import Blueprint, jsonify, current_app

flights_bp = Blueprint('flights', __name__, url_prefix='/flights')

@flights_bp.route('/', methods=['GET'])
def get_flights():
    cur = current_app.mysql.connection.cursor()
    query = """
        SELECT f.VehicleID, f.FlightNumber, t.Origin, t.Destination, t.DepartureTime, t.ArrivalTime,
               t.Price, f.AirlineName, f.FlightClass, f.Stops
        FROM Flight f
        JOIN Ticket t ON f.TicketID = t.TicketID
    """
    cur.execute(query)
    flights = cur.fetchall()
    cur.close()

    return jsonify(flights)
