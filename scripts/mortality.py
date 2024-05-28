"""
A quick script to help me with my 'Your Life in Weeks' poster
"""

import os
import argparse
from datetime import datetime, timedelta


def num_weeks(start_date, end_date):
    start_date_dt = os.environ.get("BIRTHDATE", start_date)
    start_date = datetime.strptime(start_date_dt, "%Y-%m-%d")
    end_date = datetime.strptime(end_date, "%Y-%m-%d")
    return (end_date - start_date).days / 7


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calculate number of weeks")
    parser.add_argument(
        "--start_date", type=str, default="2020-01-01", help="Start date"
    )
    parser.add_argument("--end_date", type=str, default="2021-01-01", help="End date")
    print(num_weeks(**vars(parser.parse_args())))
