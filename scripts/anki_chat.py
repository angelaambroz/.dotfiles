import json
import sys
import httpx
import asyncio
from typing import Dict, List, Optional

MODEL = "mistral"


class AnkiChatAssistant:
    def __init__(
        self,
        anki_connect_url: str = "http://localhost:8765",
        ollama_url: str = "http://localhost:11434",
        model: str = MODEL,
        debug: bool = False,
    ):
        self.anki_connect_url = anki_connect_url
        self.ollama_url = ollama_url
        self.model = model
        self.messages: List[Dict[str, str]] = []
        self.debug = debug

    async def get_card_content(self, card_id: int) -> Dict:
        """Fetch card content from Anki"""
        async with httpx.AsyncClient(timeout=60.0) as client:  # 60 second timeout
            response = await client.post(
                self.anki_connect_url,
                json={
                    "action": "cardsInfo",
                    "version": 6,
                    "params": {"cards": [card_id]},
                },
            )
            card_info = response.json()
            if card_info["error"]:
                raise Exception(f"AnkiConnect error: {card_info['error']}")
            return card_info["result"][0]

    async def chat_with_card(self, card_id: int, user_msg: str) -> str:
        """Chat about a specific card"""
        try:
            # Get card content if this is first message
            if not self.messages:
                card = await self.get_card_content(card_id)
                # Set up initial context with card content
                self.messages = [
                    {
                        "role": "system",
                        "content": (
                            "You are a helpful AI tutor. The student is studying an Anki flashcard. "
                            "Help them understand the card content by answering their questions clearly and concisely."
                        ),
                    },
                    {
                        "role": "assistant",
                        "content": (
                            f"I'm looking at your Anki card:\n"
                            f"Front: {card['fields']['Front']['value']}\n"
                            f"Back: {card['fields']['Back']['value']}\n"
                            f"What questions do you have about this material?"
                        ),
                    },
                ]

            # Add user message to context
            self.messages.append({"role": "user", "content": user_msg})

            # Get response from Ollama
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.ollama_url}/api/chat",
                    json={
                        "model": self.model,
                        "messages": self.messages,
                        "stream": False,
                        "options": {"temperature": 0.7, "top_p": 0.9},
                    },
                )

                response_data = response.json()
                ai_response = response_data["message"]["content"]
                self.messages.append({"role": "assistant", "content": ai_response})
                return ai_response
        except httpx.ReadTimeout:
            return "Error: Ollama server not responding. Is it running? Try 'ollama serve' in another terminal."
        except httpx.ConnectError:
            return "Error: Couldn't connect to Ollama. Is it installed and running?"
        except Exception as e:
            return f"Error: Something went wrong - {str(e)}"


async def main():
    assistant = AnkiChatAssistant(model="mistral", debug=True)  # enable debug mode

    try:
        # First check if we can connect to AnkiConnect
        card_id = int(input("Enter Anki card ID: "))
        try:
            await assistant.get_card_content(card_id)
        except Exception as e:
            print(f"\nError connecting to Anki: {e}")
            print("Is Anki running with AnkiConnect addon installed?")
            return

        # Try to connect to Ollama
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{assistant.ollama_url}/api/version")
                print(f"\nOllama version: {response.json()['version']}")
        except Exception as e:
            print(f"\nError connecting to Ollama: {e}")
            print("Is ollama serve running?")
            return

        while True:
            user_input = input("\nYour question (or 'quit' to exit): ")
            if user_input.lower() == "quit":
                break

            response = await assistant.chat_with_card(card_id, user_input)
            print(f"\nAssistant: {response}")
    except Exception as e:
        print(f"Unexpected error: {e}")
        import traceback

        traceback.print_exc()


if __name__ == "__main__":
    asyncio.run(main())
