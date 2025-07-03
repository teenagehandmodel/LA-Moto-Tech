# Add requirements.txt
cat > requirements.txt << 'EOL'
flask
EOL

# Add .gitignore
cat > .gitignore << 'EOL'
bookings.db
__pycache__/
*.pyc
.EOL

# Enhance app.py with better error handling
cat > app.py << 'EOL'
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
    conn.commit()
    conn.close()

def is_valid_email(email):
    return re.match(r"[^@]+@[^@]+\.[^@]+", email)

@app.route('/book', methods=['POST'])
def book_appointment():
    data = request.json
    try:
        name = data['name'].strip()
        email = data['email'].strip()
        datetime_str = data['datetime'].strip()

        if not name or not email or not datetime_str:
            return jsonify({"status": "error", "message": "All fields are required"}), 400

        if not is_valid_email(email):
            return jsonify({"status": "error", "message": "Invalid email"}), 400

        try:
            datetime.strptime(datetime_str, '%Y-%m-%dT%H:%M')
        except ValueError:
            return jsonify({"status": "error", "message": "Invalid date format"}), 400

        conn = get_db()
        c = conn.cursor()
        c.execute("INSERT INTO appointments (name, email, datetime) VALUES (?, ?, ?)",
                  (name, email, datetime_str))
        conn.commit()
        conn.close()

        return jsonify({"status": "success", "message": "Appointment booked!"})

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    init_db()
    app.run(debug=True)
EOL

# Enhance script.js with loading states
cat > script.js << 'EOL'
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('booking-form');
    const confirmationDiv = document.getElementById('confirmation');
    const submitBtn = form.querySelector('button[type="submit"]');
    
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        submitBtn.disabled = true;
        submitBtn.textContent = "Booking...";
        
        const bookingData = {
            name: document.getElementById('name').value.trim(),
            email: document.getElementById('email').value.trim(),
            datetime: document.getElementById('datetime').value.trim()
        };
        
        try {
            const response = await fetch('http://localhost:5000/book', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(bookingData)
            });
            const result = await response.json();
            
            if (result.status === "success") {
                confirmationDiv.innerHTML = `✅ ${result.message}`;
                confirmationDiv.style.color = "green";
                form.reset();
            } else {
                confirmationDiv.innerHTML = `❌ ${result.message}`;
                confirmationDiv.style.color = "red";
            }
        } catch (error) {
            confirmationDiv.innerHTML = "❌ Failed to connect to server";
            confirmationDiv.style.color = "red";
            console.error('Error:', error);
        } finally {
            submitBtn.disabled = false;
            submitBtn.textContent = "Book Now";
        }
    });
    
    // Auto-focus first input
    document.getElementById('name').focus();
});
EOL