from flask import Flask
from flask_cors import CORS
from flask_bcrypt import Bcrypt
from db import init_db
import threading
import time
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Initialize DB
mysql = init_db(app)
app.mysql = mysql

# Initialize Bcrypt once here
bcrypt = Bcrypt(app)
app.bcrypt = bcrypt

# Register routes
from routes.users import users_bp
from routes.flights import flights_bp
from routes.reservations import reservations_bp
from routes.otp import otp_bp
from routes.tickets import tickets_bp

app.register_blueprint(users_bp)
app.register_blueprint(flights_bp)
app.register_blueprint(otp_bp)
app.register_blueprint(tickets_bp)
app.register_blueprint(reservations_bp)

# === Background task to cancel expired reservations ===
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

# Start background thread
cleaner_thread = threading.Thread(target=cancel_expired_reservations, daemon=True)
cleaner_thread.start()

if __name__ == '__main__':
    app.run(debug=True)
