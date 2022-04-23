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

if sys.platform == "darwin":
    print("On MacOSX")
    from Foundation import NSURL
    from AppKit import (
        NSWorkspace,
        NSScreen,
        NSWorkspaceDesktopImageScalingKey,
        NSImageScaleProportionallyUpOrDown,
        NSWorkspaceDesktopImageAllowClippingKey,
    )
if sys.platform == "linux":
    print("On Linux")


# helpful:
# http://inventwithpython.com/blog/2013/09/30/downloading-imgur-posts-linked-from-reddit-with-python/
# http://tadhg.com/wp/2009/06/29/python-script-to-change-os-x-desktop-backgrounds/

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
    "movieposterporn",
    "RetroFuturism",
    "imaginaryhistory",
    "ImaginaryTechnology",
    "auroraporn",
    "LandscapeAstro",
    "StarshipPorn",
    "AlbumArtPorn",
    "ArtPorn",
    "OrganizationPorn",
    "MapPorn",
    "FossilPorn",
    "desertporn",
    "seaporn",
    "waterporn",
    "WeatherPorn",
    "ViewPorn",
    "ExposurePorn",
    "HellscapePorn",
    "GeekPorn",
    "AdrenalinePorn",
    "ClimbingPorn",
    "BonsaiPorn",
    "MushroomPorn",
    "geologyporn",
    "minimalist_art",
    "romanticism",
    "ancient_art",
    "Medievalart",
    "painting",
    "MuseumPorn",
    "SculpturePorn",
    "BattlePaintings",
    "ArtefactPorn",
]
REDDIT_PW = os.environ["REDDIT_PW"]
REDDIT_UN = os.environ["REDDIT_UN"]
REDDIT_CLIENT_ID = os.environ["REDDIT_CLIENT_ID"]
REDDIT_CLIENT_SECRET = os.environ["REDDIT_CLIENT_SECRET"]
NASA_APOD_KEY = os.environ["NASA_APOD"]
NASA_APOD_URL = f"https://api.nasa.gov/planetary/apod?api_key={NASA_APOD_KEY}"
TODAY = datetime.date.today().strftime("%Y%B%d")
YESTERDAY = (datetime.date.today() - datetime.timedelta(1)).strftime("%Y%B%d")


def download_pic(URL):
    urllib.request.urlretrieve(URL, f"{DIR}/{TODAY}.jpg")


def get_reddit():
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


def get_apod():
    r = requests.get(NASA_APOD_URL)
    download_pic(r.json()["url"])


# Deleting the old stuff
def delete_olds():
    if os.path.isfile(f"{DIR}/{YESTERDAY}.jpg"):
        print(f"Deleting desktop background from {YESTERDAY}.")
        os.remove(f"{DIR}/{YESTERDAY}.jpg")
    else:
        print(f"There is no desktop image from {YESTERDAY}.")


def change_desktop_background(file):
    # Setting the desktop background
    print("Now changing desktop background...")

    if sys.platform == "darwin":
        # make image options dictionary
        options = {
            NSWorkspaceDesktopImageScalingKey: NSImageScaleProportionallyUpOrDown,
            NSWorkspaceDesktopImageAllowClippingKey: True,
        }
        ws = NSWorkspace.sharedWorkspace()
        file_url = NSURL.fileURLWithPath_(file)
        for screen in NSScreen.screens():
            (result, error) = ws.setDesktopImageURL_forScreen_options_error_(
                file_url, screen, options, None
            )

    if sys.platform == "linux":
        print("...on Linux")
        # https://linuxconfig.org/set-wallpaper-on-ubuntu-20-04-using-command-line
        print(f"File path is file:////{file}")
        os.system(
            f"gsettings set org.gnome.desktop.background picture-uri file:///{file}"
        )
        # TODO: Delete a today wal color scheme, if exists, so it refreshes every time I run this
        os.system(f"wal -i {file}")


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
