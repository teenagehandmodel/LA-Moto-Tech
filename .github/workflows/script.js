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
