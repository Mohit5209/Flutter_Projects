import base64
import os
import mimetypes
from google import genai
from google.genai import types


def save_binary_file(file_name, data):
    with open(file_name, "wb") as f:
        f.write(data)


def generate_response(user_input):
    client = genai.Client(
        api_key=os.environ.get("GEMINI_API_KEY"),
    )

    model = "gemini-2.0-flash-exp-image-generation"

    system_instructions = """Behave like an AI assistant aka a Chatbot which answers questions like a human. 
                            Your name is Bakasur. The name Bakasur (also spelled Bakasura) comes from Indian mythology, specifically from the epic Mahabharata.
                            Bakasur was a rakshasa (a demon or ogre) known for his immense strength and insatiable hunger. 
                            You are similar because of your immense strength in knowledge and insatiable hunger to learn more.
                            Introduce yourself by only telling your name afterwards if the user asks more about you then you tell about yourself more.
                            Contact for help:
                            Mohit
                            Gmail address = 'mohitbhai12348@mail.com'
                            """

    contents = [
        types.Content(
            role="model",
            parts=[
                types.Part.from_text(text=system_instructions),
            ],
        ),
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text=user_input),
            ],
        ),
    ]

    generate_content_config = types.GenerateContentConfig(
        response_modalities=[
            "image",
            "text",
        ],
        response_mime_type="text/plain",
    )

    response_text = ""
    for chunk in client.models.generate_content_stream(
        model=model,
        contents=contents,
        config=generate_content_config,
    ):
        if chunk.candidates is None or chunk.candidates[0].content is None or chunk.candidates[0].content.parts is None:
            continue
        if chunk.candidates[0].content.parts[0].inline_data:
            file_name = "generated_file"
            inline_data = chunk.candidates[0].content.parts[0].inline_data
            file_extension = mimetypes.guess_extension(inline_data.mime_type)
            save_binary_file(
                f"{file_name}{file_extension}", inline_data.data
            )
            response_text += f"File of mime type {inline_data.mime_type} saved to: {file_name}{file_extension}\n"
        else:
            response_text += chunk.text

    return response_text


if __name__ == "__main__":
    print("Chatbot is running. Type 'exit' to quit.")
    while True:
        user_input = input("You: ")
        if user_input.lower() == "bye" or user_input.lower() == "exit" or user_input.lower() == "goodbye":
            print("Goodbye!")
            break
        print(generate_response(user_input))
