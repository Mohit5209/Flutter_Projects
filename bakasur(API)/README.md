# Chatbot API

A REST API for interacting with the Bakasur chatbot, powered by Google's Gemini AI.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set up environment variables:
```bash
export GEMINI_API_KEY='your-api-key-here'
export FLASK_HOST='0.0.0.0'  # Optional, defaults to 0.0.0.0
export FLASK_PORT=5000      # Optional, defaults to 5000
```

3. Run the server:
```bash
python api.py
```

## API Endpoint

### Chat with the Bot

Send a message to the chatbot and get a response.

**URL:** `/chat`

**Method:** `POST`

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
    "message": "Hello, who are you?"
}
```

**Success Response:**
- **Code:** 200 OK
- **Content:**
```json
{
    "status": "success",
    "user_message": "Hello, who are you?",
    "bot_response": "Hello! I am Bakasur..."
}
```

**Error Responses:**
- **Code:** 400 Bad Request
- **Content:**
```json
{
    "status": "error",
    "message": "Message field is required"
}
```

- **Code:** 500 Internal Server Error
- **Content:**
```json
{
    "status": "error",
    "message": "An error occurred: [error details]"
}
```

## Logging

The API automatically logs all requests and responses to a structured log directory:
```
logs/
  └── year/
      └── month/
          └── day/
              └── api.log
```

Logs include:
- Timestamp
- Log level (INFO, WARNING, ERROR)
- Request details
- Response time
- Error messages (if any)

## Example Usage

Using curl:
```bash
curl -X POST http://localhost:5000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, who are you?"}'
```

Using Python requests:
```python
import requests

response = requests.post(
    'http://localhost:5000/chat',
    json={'message': 'Hello, who are you?'}
)
print(response.json())
```

## Environment Variables

- `GEMINI_API_KEY`: Your Google Gemini API key (required)
- `FLASK_HOST`: Host to run the server on (optional, defaults to 0.0.0.0)
- `FLASK_PORT`: Port to run the server on (optional, defaults to 5000)

## Dependencies

- Flask==3.0.2
- google-generativeai==0.3.2
- python-dotenv==1.0.1

## Notes

- The server runs in debug mode by default
- Logs are automatically created in the `logs` directory
- The chatbot's name is Bakasur, inspired by Indian mythology
- The API is designed to be simple and easy to use 