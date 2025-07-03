from flask import Flask, request, jsonify
import sqlite3
from datetime import datetime
import re

app = Flask(__name__)

def get_db():
    conn = sqlite3.connect('bookings.db')
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS appointments
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                 name TEXT NOT NULL,
                 email TEXT NOT NULL,
                 datetime TEXT NOT NULL)''')
    c.execute("CREATE INDEX IF NOT EXISTS idx_email ON appointments (email)")
    c.execute("CREATE INDEX IF NOT EXISTS idx_datetime ON appointments (datetime)")
    conn.commit()
    conn.close()

def is_valid_email(email):
    return re.match(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$", email)

@app.route('/book', methods=['POST'])
def book_appointment():
    data = request.json
    try:
        name = data['name'].strip()
        email = data['email'].strip()
        datetime_str = data['datetime'].strip()

        if not (name and email and datetime_str):
            return jsonify({"status": "error", "message": "All fields are required"}), 400

        if not is_valid_email(email):
            return jsonify({"status": "error", "message": "Invalid email format"}), 400

        conn = get_db()
        c = conn.cursor()
        c.execute("SELECT id FROM appointments WHERE email=? AND datetime=?", (email, datetime_str))
        if c.fetchone():
            conn.close()
            return jsonify({"status": "error", "message": "You already booked this slot!"}), 400

        c.execute("INSERT INTO appointments (name, email, datetime) VALUES (?, ?, ?)",
                 (name, email, datetime_str))
        conn.commit()
        conn.close()

        return jsonify({"status": "success", "message": "Booked successfully!"})

    except Exception as e:
        return jsonify({"status": "error", "message": "Server error"}), 500

if __name__ == '__main__':
    init_db()
    app.run(debug=True)
