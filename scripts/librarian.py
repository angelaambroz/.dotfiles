import sqlite3
import logging
import csv
import re
import argparse
import random
from typing import Dict, List, Any

import anthropic
import pandas as pd

# Configuration constants
DATABASE_PATH = "metadata_working.db"
MODEL_NAME = "claude-opus-4-20250514"
RAW_RESPONSES_CSV = "raw_responses.csv"
PARSED_RESPONSES_CSV = "parsed_responses.csv"
QUERY = """
select
	b.id,
	b.title,
	b.author_sort as author,
	t.name as tags
from books b
left join books_tags_link btl on b.id = btl.book
left join tags t on btl.tag = t.id
"""

MAIN_PROMPT = """You are a world-class librarian. Respond with the top 3 most likely categories for this book (in decreasing order of generality), as well as 1-2 sentences describing the book. Your response should be in the form: CATEGORIES = ["Fiction", "Science fiction", "Dystopia"], NOTES = "This book is an eco thriller featuring feminist and anarchist themes"."""

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def get_books_data(db_path: str) -> List[Dict[str, Any]]:
    """
    Fetch book data from the SQLite database.

    Args:
        db_path: Path to the SQLite database

    Returns:
        List of book records as dictionaries
    """
    try:
        conn = sqlite3.connect(db_path)
        df = pd.read_sql(QUERY, conn)
        conn.close()
        return df.to_dict(orient="records")
    except sqlite3.Error as e:
        logger.error(f"Database error: {e}")
        raise


def get_book_categorization(
    client: anthropic.Anthropic, book: Dict[str, Any]
) -> Dict[str, Any]:
    """
    Get AI categorization for a single book.

    Args:
        client: Anthropic client instance
        book: Dictionary containing book metadata

    Returns:
        Dictionary with book ID and AI response
    """
    text = f"Title: {book['title']}, Author: {book['author']}, Existing tags: {book['tags']}"

    try:
        message = client.messages.create(
            model=MODEL_NAME,
            max_tokens=1000,
            temperature=1,
            system=MAIN_PROMPT,
            messages=[{"role": "user", "content": [{"type": "text", "text": text}]}],
        )
        return {"id": book["id"], "response": message.content[0].text}
    except Exception as e:
        logger.error(f"API error for book {book['id']}: {e}")
        return {"id": book["id"], "response": f"Error: {str(e)}"}


def process_books(books: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Process all books to get categorizations and save each response immediately.

    Args:
        books: List of book dictionaries

    Returns:
        List of responses with book IDs and categorizations
    """
    client = anthropic.Anthropic()
    responses = []

    # Start the loop, and open and close the file within the loop
    for i, book in enumerate(books):
        logger.info(f"Processing book {i+1}/{len(books)}: {book['title']}")
        response = get_book_categorization(client, book)
        responses.append(response)

        with open(RAW_RESPONSES_CSV, "a", newline="", encoding="utf-8") as csvfile:
            fieldnames = ["id", "response"]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writerow(response)
            logger.info(f"Saved response for book {book['id']} to {RAW_RESPONSES_CSV}")
    

    return responses


def parse_responses(responses: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Parse the AI responses to extract categories and notes.

    Args:
        responses: List of response dictionaries with book IDs and API responses

    Returns:
        List of dictionaries with book IDs, categories, and notes
    """
    parsed_data = []

    for response in responses:
        book_id = response["id"]
        response_text = response["response"]

        # Initialize default values
        categories = []
        notes = ""

        try:
            # Extract categories using regex
            categories_match = re.search(
                r"CATEGORIES\s*=\s*(\[.*?\])", response_text, re.DOTALL
            )
            if categories_match:
                categories_str = categories_match.group(1)
                # Clean up and convert to string representation
                categories = categories_str.replace("\n", " ").strip()

            # Extract notes using regex
            notes_match = re.search(r'NOTES\s*=\s*"(.*?)"', response_text, re.DOTALL)
            if notes_match:
                notes = notes_match.group(1).replace("\n", " ").strip()

            parsed_data.append(
                {"id": book_id, "categories": categories, "notes": notes}
            )
        except Exception as e:
            logger.error(f"Error parsing response for book {book_id}: {e}")
            parsed_data.append(
                {"id": book_id, "categories": "", "notes": f"Error parsing: {str(e)}"}
            )

    return parsed_data


def save_parsed_responses_to_csv(
    parsed_data: List[Dict[str, Any]], csv_path: str
) -> None:
    """
    Save parsed responses to a CSV file.

    Args:
        parsed_data: List of dictionaries with book IDs, categories, and notes
        csv_path: Path to save the CSV file
    """
    try:
        with open(csv_path, "w", newline="", encoding="utf-8") as csvfile:
            fieldnames = ["id", "categories", "notes"]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

            writer.writeheader()
            for item in parsed_data:
                writer.writerow(item)

        logger.info(f"Parsed responses saved to {csv_path}")
    except Exception as e:
        logger.error(f"Error saving parsed responses to CSV: {e}")


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Book categorization tool")
    parser.add_argument(
        "--test-single", action="store_true", help="Test with a single random book"
    )
    return parser.parse_args()


def main():
    """Main execution function."""
    try:
        args = parse_args()
        logger.info("Starting book categorization process")
        books = get_books_data(DATABASE_PATH)
        logger.info(f"Retrieved {len(books)} books from database")

        if args.test_single:
            # Select a random book for testing
            test_book = random.choice(books)
            logger.info(
                f"Testing with a single book: {test_book['title']} by {test_book['author']}"
            )

            # Process just this one book
            client = anthropic.Anthropic()
            response = get_book_categorization(client, test_book)
            responses = [response]

            # Print the response for immediate feedback
            logger.info(f"Response for test book:\n{response['response']}")
            
        else:
            # Process all books (CSV is written inside this function now)
            responses = process_books(books)

        # Parse responses and save to CSV
        parsed_data = parse_responses(responses)
        save_parsed_responses_to_csv(parsed_data, PARSED_RESPONSES_CSV)

        logger.info(f"Completed processing {len(responses)} books")

        return responses
    except Exception as e:
        logger.error(f"Error in main execution: {e}")
        return []


if __name__ == "__main__":
    main()
