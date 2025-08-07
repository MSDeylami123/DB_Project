# 🧳 Travel Ticket Reservation System

This project is a  Travel Ticket Reservation System that allows users to book tickets for flights, trains, and buses. The system handles user management, ticket reservations, payments, and allows data analysis using stored procedures and queries.

---

## 📚 Project Phases

### Phase 1: Database Design
- Designed an **ERD (Entity Relationship Diagram)** to show core entities and relationships.
- Created normalized SQL tables for:
  - `Users`
  - `Tickets`
  - `Reservations`
  - `Payments`
  - `Flights`, `Trains`, `Buses`

### Phase 2: Advanced SQL Implementation
- Normalized all tables to **Third Normal Form (3NF)**.
- Created **indexes**,**primary keys**, **foreign keys** and **other constraints** to ensure data integrity.
- Added other supporting tables
- Developed **analytical queries** for:
  - Revenue analysis
  - Most popular routes
  - Active users
  - Reservation trends
  - And...
- Wrote **stored procedures** for:
  - Ticket reservation automation
  - Cancellation and refund processes
  - Data cleanup (expired reservations)
  - And...

### Phase 3: Backend Development
- Developed a **Python Flask backend**.
- Integrated the backend with the MySQL database.
- Exposed RESTful API endpoints for:
  - User registration & login
  - Ticket search and booking
  - Reservation management
  - Payment processing
- Included background processes (e.g., reservation expiration cleanup).

---

## 🛠️ Tech Stack

- **Backend**: Python (Flask)
- **Database**: MySQL
- **Auth**: JWT
- **OTP**: Email/SMS-compatible
- **Cache & Background Jobs**: Redis
- **API Testing**: cURL

---

## 📁 Project Structure

```
Python/
├── app.py
├── db.py
├── requirements.txt
├── routes/
│   ├── flights.py
│   ├── otp.py
│   ├── reports.py
│   ├── reservations.py
│   ├── support.py
│   ├── tickets.py
│   └── users.py
└── __pycache__/
```

---


## 🔁 Redis Setup & Configuration

### 🧰 How to Set Up and Run a Redis Server

1. **Install Redis**:

   On Ubuntu/Debian:
   ```bash
   sudo apt update
   sudo apt install redis-server
   ```

   On macOS (using Homebrew):
   ```bash
   brew install redis
   ```

   On Windows:
   Use the [Memurai Redis fork](https://www.memurai.com/) or run Redis via WSL or Docker.

2. **Start Redis**:
   ```bash
   redis-server
   ```

3. **Verify Redis is running**:
   ```bash
   redis-cli ping
   # Response should be: PONG
   ```

### 🔌 How to Connect Redis to the Project

In your `.env` file, set the Redis connection URL:

```
REDIS_URL=redis://localhost:6379
```

In Python, connect using:

```python
import redis
redis_client = redis.StrictRedis.from_url(os.getenv("REDIS_URL"))
```

Redis is used to temporarily store and manage OTPs and handle expiration of reservations using a background cleanup thread.

---

## 🚀 How to Run

After setting up Redis, the backend server is started by running the following command in the terminal:

```terminal
python app.py
```
---

## 📬 Full API List with Input & Output Description

| Endpoint | Method | Description | Input | Output |
|----------|--------|-------------|-------|--------|
| `/otp/request-otp` | POST | Request an OTP for login/signup | `contact` (email or phone) | JSON: success message |
| `/otp/verify-otp` | POST | Verify OTP code | `contact`, `otp` | JWT token (if valid) |
| `/users/signup` | POST | Register a new user | `firstName`, `lastName`, `email`, `password`, `userType` | Success message |
| `/users/login` | POST | Log in with email and password | `email`, `password` | JWT token |
| `/users/update-profile` | PUT | Update user profile info | fields like `firstName`, `city`, etc. | Success or error |
| `/tickets/cities` | GET | Get list of available cities | Header: JWT | List of cities |
| `/tickets/search` | POST | Search for available tickets | `origin`, `destination`, `filters`, etc. | Matching tickets |
| `/tickets/<id>` | GET | Get specific ticket details | Ticket ID in URL | Ticket info |
| `/reservations/reserve` | POST | Reserve a ticket | `ticketID` | Reservation ID or error |
| `/reservations/my` | GET | View current user's reservations | Header: JWT | List of reservations |
| `/reservations/pay` | POST | Make payment | `reservationID`, `paymentMethod` | Confirmation |
| `/reservations/purchased` | GET | View purchased tickets | Header: JWT | List of tickets |
| `/reservations/penalty/<id>` | GET | Check penalty for cancellation | Reservation ID in URL | Penalty amount |
| `/reservations/cancel` | POST | Cancel a reservation | `reservationID` | Status |
| `/reports/submit` | POST | Submit a report | `ticketID`, `reservationID`, `category`, `text` | Status |
| `/reports/my` | GET | View personal reports | Header: JWT | List of reports |
| `/support/admin/reports` | GET | Admin view of all reports | Admin JWT | List of reports |
| `/support/admin/reports/respond` | POST | Respond to a report | `ReportID`, `Answer`, `ProcessingStatus` | Status |
| `/support/reservations` | GET | View all reservations (admin) | Admin JWT | List of reservations |
| `/support/reservations/cancel` | POST | Cancel any reservation (admin) | `ReservationID` | Status |
| `/support/payments/cancelled` | GET | View cancelled payments | Admin JWT | List of transactions |

---

## 🧪 How to Test APIs

### Using Curl

See the **🧪 API Testing (cURL Examples)** section above for real command examples.

Make sure to replace:
- `<TICKET_ID>` or `<ReservationID>` with actual values
- `YOUR_JWT_TOKEN` with your real token

Ensure your backend server is running on `http://localhost:5000` or adjust the URL as needed.

```bash
# Clone the repository
git clone https://github.com/your-username/travel-ticket-system.git
cd travel-ticket-system

# Set up the environment
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt

# Start the Flask server
python app.py
ee
