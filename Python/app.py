from flask import Flask
from flask_cors import CORS
from flask_bcrypt import Bcrypt
from db import init_db
import threading
import time


# --------------------- Flask App ---------------------
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "http://localhost:5173"}})

# --------------------- Initialize MySQL ---------------------
mysql = init_db(app)
app.mysql = mysql

# --------------------- Initialize Bcrypt ---------------------
bcrypt = Bcrypt(app)
app.bcrypt = bcrypt

# --------------------- Register Blueprints ---------------------
from routes.users import users_bp
from routes.flights import flights_bp
from routes.reservations import reservations_bp
from routes.otp import otp_bp
from routes.tickets import tickets_bp, start_es_sync
from routes.reports import report_bp
from routes.support import support_bp

app.register_blueprint(users_bp)
app.register_blueprint(flights_bp)
app.register_blueprint(otp_bp)
app.register_blueprint(tickets_bp)
app.register_blueprint(reservations_bp)
app.register_blueprint(report_bp)
app.register_blueprint(support_bp)

# --------------------- Background Task: Cancel Expired Reservations ---------------------
def cancel_expired_reservations():
    with app.app_context():
        while True:
            try:
                cur = app.mysql.connection.cursor()
                cur.execute("""
                    UPDATE Reservation
                    SET ReservationStatus = 'Canceled'
                    WHERE ReservationStatus = 'Reserved' AND ExpirationTime < NOW()
                """)
                app.mysql.connection.commit()
                cur.close()
            except Exception as e:
                print(f"[Reservation Cleaner] Error: {e}")
            time.sleep(30)  # Check every 30 seconds

# Start reservation cleaner thread
cleaner_thread = threading.Thread(target=cancel_expired_reservations, daemon=True)
cleaner_thread.start()

# --------------------- Start Elasticsearch Sync ---------------------
# Sync tickets from MySQL to Elasticsearch every 5 minutes
# --------------------- Start Elasticsearch Sync ---------------------
# Sync tickets from MySQL to Elasticsearch every 40 seconds
with app.app_context():
    start_es_sync(app,interval=40)

# --------------------- Test Route ---------------------
@app.route("/")
def home():
    return "Hello from backend!"

# --------------------- Run App ---------------------
if __name__ == '__main__':
    app.run(debug=True, port=5000)
