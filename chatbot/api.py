from flask import Flask, request, jsonify
from chatbot import generate_response
import os
import logging
from datetime import datetime
import time

# Configure logging
def setup_logging():
    # Create logs directory if it doesn't exist
    current_date = datetime.now()
    log_dir = os.path.join('logs', str(current_date.year), 
                          str(current_date.month).zfill(2), 
                          str(current_date.day).zfill(2))
    os.makedirs(log_dir, exist_ok=True)
    
    # Create log file path
    log_file = os.path.join(log_dir, 'api.log')
    
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()  # Also print to console
        ]
    )
    
    return logging.getLogger(__name__)

# Initialize logger
logger = setup_logging()

app = Flask(__name__)

@app.route('/chat', methods=['POST'])
def chat():
    start_time = time.time()
    logger.info("Received new chat request")
    
    try:
        # Get JSON data from request
        data = request.get_json()
        logger.debug(f"Request data: {data}")
        
        # Validate input
        if not data:
            logger.warning("No data provided in request")
            return jsonify({
                'status': 'error',
                'message': 'No data provided'
            }), 400
            
        if 'message' not in data:
            logger.warning("Message field missing in request")
            return jsonify({
                'status': 'error',
                'message': 'Message field is required'
            }), 400
            
        # Get user message
        user_message = data['message'].strip()
        logger.info(f"Processing message: {user_message}")
        
        # Validate message is not empty
        if not user_message:
            logger.warning("Empty message received")
            return jsonify({
                'status': 'error',
                'message': 'Message cannot be empty'
            }), 400
            
        # Generate response from chatbot
        logger.info("Generating chatbot response")
        bot_response = generate_response(user_message)
        logger.info("Response generated successfully")
        
        # Calculate response time
        response_time = time.time() - start_time
        logger.info(f"Request completed in {response_time:.2f} seconds")
        
        # Return success response
        return jsonify({
            'status': 'success',
            'user_message': user_message,
            'bot_response': bot_response
        })
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        return jsonify({
            'status': 'error',
            'message': f'An error occurred: {str(e)}'
        }), 500

if __name__ == '__main__':
    # Configuration
    HOST = '0.0.0.0'  # Listen on all network interfaces
    PORT = 5000       # Default port
    
    # You can override these with environment variables
    HOST = os.environ.get('FLASK_HOST', HOST)
    PORT = int(os.environ.get('FLASK_PORT', PORT))
    
    logger.info(f"Starting server on {HOST}:{PORT}")
    app.run(host=HOST, port=PORT, debug=True) 