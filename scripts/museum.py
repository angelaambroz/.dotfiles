"""
Changing the desktop wallpaper programmatically, for fun.
"""

from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
import argparse
import logging
import platform
import random
import sys
import urllib.request
from typing import Optional

import praw
import requests

logging.basicConfig(level=logging.INFO, 
                   format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class Config:
    """Configuration for the wallpaper changer"""
    script_dir: Path
    today: str
    yesterday: str
    reddit_pw: str 
    reddit_un: str
    reddit_client_id: str
    reddit_client_secret: str
    nasa_key: str

    @classmethod
    def from_env(cls) -> 'Config':
        """Create config from environment variables"""
        import os
        today = date.today()
        return cls(
            script_dir=Path(__file__).parent,
            today=today.strftime("%Y%b%d"),
            yesterday=(today - timedelta(1)).strftime("%Y%b%d"),
            reddit_pw=os.environ["REDDIT_PW"],
            reddit_un=os.environ["REDDIT_UN"], 
            reddit_client_id=os.environ["REDDIT_CLIENT_ID"],
            reddit_client_secret=os.environ["REDDIT_CLIENT_SECRET"],
            nasa_key=os.environ["NASA_APOD_KEY"]
        )

config = Config.from_env()

match platform.system().lower():
    case "linux":
        logger.info("Running on Linux")
    case other:
        logger.warning(f"Unsupported platform: {other}")
SUBREDDITS = frozenset({
    "museum", "ColorizedHistory", "MacroPorn", "FuturePorn",
    "spaceporn", "historyporn", "ImaginaryLandscapes", "MapPorn",
    "FossilPorn", "WeatherPorn", "minimalist_art", "romanticism",
    "Medievalart", "painting", "MuseumPorn",
})

def download_pic(url: str, output_path: Path) -> None:
    """Download an image from a URL to the specified path"""
    logger.info(f"Downloading to {output_path}")
    try:
        urllib.request.urlretrieve(url, output_path)
    except (urllib.error.URLError, urllib.error.HTTPError) as e:
        logger.error(f"Failed to download image: {e}")
        raise

def get_reddit() -> Path:
    """Download a picture from Reddit and return its path"""
    sub = random.choice(list(SUBREDDITS))
    logger.info(f"Selected subreddit: /r/{sub}")
    
    reddit = praw.Reddit(
        client_id=config.reddit_client_id,
        client_secret=config.reddit_client_secret,
        user_agent=f"linux:museum-desktop:v0.2 (by /u/{config.reddit_un})",
        username=config.reddit_un,
        password=config.reddit_pw,
    )
    
    try:
        submissions = reddit.subreddit(sub).top("month", limit=10)
        image_urls = [
            post.url for post in submissions 
            if any(post.url.lower().endswith(ext) for ext in ('.jpg', '.png'))
        ]
        if not image_urls:
            raise ValueError(f"No suitable images found in /r/{sub}")
            
        output_path = config.script_dir / f"{config.today}.jpg"
        download_pic(image_urls[0], output_path)
        return output_path
    except Exception as e:
        logger.error(f"Reddit download failed: {e}")
        raise

def get_apod() -> Path:
    """Download NASA's Astronomy Picture of the Day and return its path"""
    url = f"https://api.nasa.gov/planetary/apod?api_key={config.nasa_key}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        output_path = config.script_dir / f"{config.today}.jpg"
        download_pic(data["url"], output_path)
        return output_path
    except requests.RequestException as e:
        logger.error(f"APOD download failed: {e}")
        raise

def delete_old_wallpaper() -> None:
    """Delete yesterday's wallpaper if it exists"""
    old_path = config.script_dir / f"{config.yesterday}.jpg"
    if old_path.exists():
        logger.info(f"Deleting old wallpaper: {old_path}")
        old_path.unlink()
    else:
        logger.info("No old wallpaper found")

def change_desktop_background(file_path: Path) -> None:
    """Update the desktop background based on the platform"""
    logger.info("Changing desktop background...")

    match platform.system().lower():
        case "linux":
            command = (
                f'echo "regolith.wallpaper.file: {file_path}" > ~/.config/regolith3/Xresources'
                "; regolith-look refresh"
            )
            logger.info(f"Running command: {command}")
            if sys.system(command) != 0:
                raise RuntimeError("Failed to change wallpaper")
        case other:
            raise NotImplementedError(f"Platform not supported: {other}")


def main() -> None:
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Set desktop wallpaper from Reddit or NASA APOD"
    )
    source_group = parser.add_mutually_exclusive_group()
    source_group.add_argument("-r", "--reddit", action="store_true", 
                            help="Use Reddit as source")
    source_group.add_argument("-n", "--nasa", action="store_true", 
                            help="Use NASA APOD as source")
    args = parser.parse_args()

    try:
        if args.reddit:
            wallpaper_path = get_reddit()
        elif args.nasa:
            wallpaper_path = get_apod()
        else:
            wallpaper_path = random.choice([get_reddit, get_apod])()

        delete_old_wallpaper()
        change_desktop_background(wallpaper_path)
        logger.info("Wallpaper updated successfully")
    except Exception as e:
        logger.error(f"Failed to update wallpaper: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
