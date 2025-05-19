"""
A quick script to help me with my 'Your Life in Weeks' poster
"""

import os
import argparse
from datetime import datetime, timedelta


def num_weeks(start_date: str, end_date: str) -> int:
    """
    Calculate the number of weeks between two dates.

    Args:
        start_date: Start date in YYYY-MM-DD format
        end_date: End date in YYYY-MM-DD format

    Returns:
        Number of weeks between the dates (rounded down to integer)

    Raises:
        ValueError: If dates are in incorrect format
    """
    try:
        start_date_obj = datetime.strptime(start_date, "%Y-%m-%d")
        end_date_obj = datetime.strptime(end_date, "%Y-%m-%d")
        return int((end_date_obj - start_date_obj).days / 7)
    except ValueError as e:
        raise ValueError(f"Invalid date format. Please use YYYY-MM-DD format: {e}")


def main() -> None:
    """Parse command line arguments and calculate weeks between dates."""
    birthdate = os.environ.get("BIRTHDATE")
    current_year = datetime.now().year

    parser = argparse.ArgumentParser(
        description="Calculate number of weeks between two dates, useful for 'Your Life in Weeks' visualization."
    )
    parser.add_argument(
        "-s",
        "--start_date",
        type=str,
        default=birthdate,
        help="Start date in YYYY-MM-DD format (defaults to BIRTHDATE environment variable)",
    )
    parser.add_argument(
        "-e",
        "--end_date",
        type=str,
        default=f"{current_year}-01-01",
        help=f"End date in YYYY-MM-DD format (defaults to January 1st of current year)",
    )

    args = parser.parse_args()

    if not args.start_date:
        print(
            "Error: No start date provided. Set BIRTHDATE environment variable or use --start_date"
        )
        return

    try:
        result = num_weeks(args.start_date, args.end_date)
        print(f"{result:,.0f} weeks") if result > 0 else print(result)
    except ValueError as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
