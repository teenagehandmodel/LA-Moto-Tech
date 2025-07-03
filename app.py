@app.route('/book', methods=['POST'])
@validate_json
def book_appointment():
    data = request.json
    required_fields = ['name', 'email', 'phone', 'bike_model', 'service_type', 'datetime']

    for field in required_fields:
        if not data.get(field):
            return jsonify({"status": "error", "message": f"Missing field: {field}"}), 400

    if not validate_phone(data['phone']):
        return jsonify({"status": "error", "message": "Invalid phone number"}), 400

    try:
        conn = get_db()
        c = conn.cursor()

        c.execute('''
            INSERT INTO appointments (name, email, phone, bike_model, service_type, datetime, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            data['name'],
            data['email'],
            data['phone'],
            data['bike_model'],
            data['service_type'],
            data['datetime'],
            data.get('notes', '')
        ))

        conn.commit()
        conn.close()

        # Send SMS confirmation
        sms_message = f"Hi {data['name']}, your service appointment for your {data['bike_model']} has been booked for {data['datetime']}."
        send_confirmation_sms(data['phone'], sms_message)

        return jsonify({"status": "success", "message": "Appointment booked successfully!"}), 200

    except Exception as e:
        app.logger.error(f"Error booking appointment: {str(e)}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500
