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
- **ORM / Querying**: Raw SQL + SQLAlchemy (optional)
- **Authentication**: JWT (JSON Web Tokens)
- **Caching / Async Tasks**: Redis (for reservation expiration handling)

---

## 🚀 How to Run (Dev)

> _Coming soon: add your instructions here or let me know to write them for you._

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
