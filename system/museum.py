import os
import random
import datetime
import urllib.request

import praw
import requests

from Foundation import NSURL
from AppKit import (
    NSWorkspace,
    NSScreen,
    NSWorkspaceDesktopImageScalingKey,
    NSImageScaleProportionallyUpOrDown,
    NSWorkspaceDesktopImageAllowClippingKey,
)


# helpful:
# http://inventwithpython.com/blog/2013/09/30/downloading-imgur-posts-linked-from-reddit-with-python/
# http://tadhg.com/wp/2009/06/29/python-script-to-change-os-x-desktop-backgrounds/

# Some globals
DIR = os.getcwd()
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
NASA_APOD_URL = "https://api.nasa.gov/planetary/apod?api_key={}".format(NASA_APOD_KEY)
TODAY = datetime.date.today().strftime("%Y%B%d")
YESTERDAY = (datetime.date.today() - datetime.timedelta(1)).strftime("%Y%B%d")


def download_pic(URL):
    urllib.request.urlretrieve(URL, "{}/{}.jpg".format(DIR, TODAY))


def get_reddit():
    sub = random.choice(SUBREDDITS)
    print("Today's chosen subreddit is /r/{}!".format(sub))
    r = praw.Reddit(
        client_id=REDDIT_CLIENT_ID,
        client_secret=REDDIT_CLIENT_SECRET,
        user_agent="osx:museum-desktop.personal-app:v0.1 (by /u/{})".format(REDDIT_UN),
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
    if os.path.isfile("{}/{}.jpg".format(DIR, YESTERDAY)):
        print("Deleting desktop background from {}.".format(YESTERDAY))
        os.remove("{}/{}.jpg".format(DIR, YESTERDAY))
    else:
        print("There is no desktop image from {}.".format(YESTERDAY))


# Setting the desktop background
def change_desktop_background(file):
    print("Now changing desktop background...")
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


get_reddit()
# get_apod()
delete_olds()
change_desktop_background("{}/{}.jpg".format(DIR, TODAY))

# TO DOs:
# 1. delete all previous day backgrounds, not just yesterday's (use timedate?)
# 4. resize to fit screen
