"""
Changing the desktop wallpaper programmatically, for fun.
"""

import os
import sys
import argparse
import random
import datetime
import urllib.request

import praw
import requests

if sys.platform == "linux":
    print("Hi! You're on a Linux machine, good for u")


# Some globals
DIR = os.path.split(os.path.abspath(__file__))[0]
SUBREDDITS = [
    "museum",
    "ColorizedHistory",
    "MacroPorn",
    "FuturePorn",
    "spaceporn",
    "historyporn",
    "ImaginaryLandscapes",
    "MapPorn",
    "FossilPorn",
    "WeatherPorn",
    "minimalist_art",
    "romanticism",
    "Medievalart",
    "painting",
    "MuseumPorn",
]
REDDIT_PW = os.environ["REDDIT_PW"]
REDDIT_UN = os.environ["REDDIT_UN"]
REDDIT_CLIENT_ID = os.environ["REDDIT_CLIENT_ID"]
REDDIT_CLIENT_SECRET = os.environ["REDDIT_CLIENT_SECRET"]
NASA_APOD_KEY = os.environ["NASA_APOD"]
NASA_APOD_URL = f"https://api.nasa.gov/planetary/apod?api_key={NASA_APOD_KEY}"
TODAY = datetime.date.today().strftime("%Y%b%d")
YESTERDAY = (datetime.date.today() - datetime.timedelta(1)).strftime("%Y%b%d")


def download_pic(URL: str) -> None:
    """Downloading the picture from the URL"""
    print(f"Downloading to {DIR}/{TODAY}.jpg")
    urllib.request.urlretrieve(URL, f"{DIR}/{TODAY}.jpg")


def get_reddit() -> None:
    """
    Downloading a picture from Reddit

    TODO: Get the most popular of the responses
    """
    sub = random.choice(SUBREDDITS)
    print(f"Today's chosen subreddit is /r/{sub}!")
    r = praw.Reddit(
        client_id=REDDIT_CLIENT_ID,
        client_secret=REDDIT_CLIENT_SECRET,
        user_agent=f"osx:museum-desktop.personal-app:v0.1 (by /u/{REDDIT_UN})",
        username=REDDIT_UN,
        password=REDDIT_PW,
    )
    good_url = [
        x.url for x in r.subreddit(sub).top("month", limit=3) if "jpg" or "png" in x
    ][0]
    download_pic(good_url)


def get_apod() -> None:
    """
    Downloading NASA's space pic of the day
    """
    r = requests.get(NASA_APOD_URL)
    download_pic(r.json()["url"])


# Deleting the old stuff
def delete_olds() -> None:
    """
    Look in the museum directory, delete yesterday's picture
    """
    if os.path.isfile(f"{DIR}/{YESTERDAY}.jpg"):
        print(f"Deleting desktop background from {YESTERDAY}.")
        os.remove(f"{DIR}/{YESTERDAY}.jpg")
    else:
        print(f"There is no desktop image from {YESTERDAY}.")


def change_desktop_background(file: str) -> None:
    """
    Updating the background, based on the inferred OS
    """
    # Setting the desktop background
    print("Now changing desktop background...")

    if sys.platform == "linux":
        print("...on Linux")
        command = (
                f'echo "regolith.wallpaper.file: {file}" > ~/.config/regolith2/Xresources'
        )

        wal_config_dir = "/home/angelaambroz/.cache/wal/schemes/"
        wal_config = f"_home_angelaambroz__dotfiles_system_{file[-13:-4]}_jpg_dark_None_None_1.1.0.json"
        print(wal_config)
        if wal_config in os.listdir(wal_config_dir):
            command += f"; rm -r {wal_config_dir}/{wal_config}"
        command += "; regolith-look refresh"
        command += f"; wal -i {file}"


        print(f"Running command: {command}")
        os.system(command)
    else:
        print("Where are you?")


# TO DOs:
# 1. delete all previous day backgrounds, not just yesterday's (use timedate?)
# 4. resize to fit screen

if __name__ == "__main__":
    PARSER = argparse.ArgumentParser(description="Choosing which image source to use.")
    PARSER.add_argument("-r", dest="reddit", action="store_false")
    PARSER.add_argument("-n", dest="nasa", action="store_false")
    ARGS = PARSER.parse_args()

    if ARGS.reddit and ARGS.nasa:
        print("You can only pick one")

    if ARGS.reddit:
        get_reddit()
    elif ARGS.nasa:
        get_apod()
    else:
        random.choice([get_reddit(), get_apod()])

    delete_olds()
    change_desktop_background(f"{DIR}/{TODAY}.jpg")
