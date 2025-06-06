from flask import Flask
from flask_cors import CORS
from flask_bcrypt import Bcrypt
from db import init_db

app = Flask(__name__)
CORS(app)

# Initialize DB
mysql = init_db(app)
app.mysql = mysql

# Initialize Bcrypt once here
bcrypt = Bcrypt(app)

# Make bcrypt globally accessible via app context
app.bcrypt = bcrypt

# Register routes
from routes.users import users_bp
from routes.flights import flights_bp
from routes.reservations import reservations_bp
from routes.otp import otp_bp
from routes.tickets import tickets_bp

app.register_blueprint(users_bp)
app.register_blueprint(flights_bp)
app.register_blueprint(reservations_bp)
app.register_blueprint(otp_bp)
app.register_blueprint(tickets_bp)

if __name__ == '__main__':
    app.run(debug=True)
