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
    rijks_key: str

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
            nasa_key=os.environ["NASA_APOD_KEY"],
            rijks_key=os.environ["RIJKSMUSEUM_API_KEY"]
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

def get_rijksmuseum() -> Path:
    """Download random artwork from the Rijksmuseum in Amsterdam"""
    try:
        # Get a random artwork with an image
        params = {
            "key": config.rijks_key,
            "format": "json",
            "type": "painting",
            "imgonly": True,
            "ps": 1,  # page size
            "p": random.randint(1, 100),  # random page
        }
        response = requests.get("https://www.rijksmuseum.nl/api/en/collection", params=params)
        response.raise_for_status()
        data = response.json()
        
        if data["artObjects"]:
            artwork = data["artObjects"][0]
            image_url = artwork["webImage"]["url"]
            output_path = config.script_dir / f"{config.today}.jpg"
            download_pic(image_url, output_path)
            logger.info(f"Downloaded: {artwork['title']} by {artwork.get('principalOrFirstMaker', 'Unknown')}")
            return output_path
        raise ValueError("No artwork found")
    except requests.RequestException as e:
        logger.error(f"Rijksmuseum download failed: {e}")
        raise

def get_art_institute_chicago() -> Path:
    """Download random artwork from Art Institute of Chicago"""
    try:
        # First get a random artwork ID with an image
        params = {
            "limit": 1,
            "page": random.randint(1, 100),
            "fields": "id,title,image_id,artist_title",
            "has_images": True
        }
        response = requests.get("https://api.artic.edu/api/v1/artworks", params=params)
        response.raise_for_status()
        data = response.json()
        
        if data["data"]:
            artwork = data["data"][0]
            image_id = artwork["image_id"]
            image_url = f"https://www.artic.edu/iiif/2/{image_id}/full/843,/0/default.jpg"
            
            output_path = config.script_dir / f"{config.today}.jpg"
            download_pic(image_url, output_path)
            logger.info(f"Downloaded: {artwork['title']} by {artwork.get('artist_title', 'Unknown')}")
            return output_path
        raise ValueError("No artwork found")
    except requests.RequestException as e:
        logger.error(f"Art Institute of Chicago download failed: {e}")
        raise

def get_cleveland_museum() -> Path:
    """Download random artwork from Cleveland Museum of Art"""
    try:
        # Get a random artwork with an image
        params = {
            "has_image": 1,
            "limit": 1,
            "skip": random.randint(1, 1000)
        }
        response = requests.get("https://openaccess-api.clevelandart.org/api/artworks/", params=params)
        response.raise_for_status()
        data = response.json()
        
        if data["data"]:
            artwork = data["data"][0]
            image_url = artwork["images"]["web"]["url"]
            output_path = config.script_dir / f"{config.today}.jpg"
            download_pic(image_url, output_path)
            logger.info(f"Downloaded: {artwork['title']} by {artwork.get('creators', [{'description': 'Unknown'}])[0]['description']}")
            return output_path
        raise ValueError("No artwork found")
    except requests.RequestException as e:
        logger.error(f"Cleveland Museum download failed: {e}")
        raise

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
        description="Set desktop wallpaper from various museum collections"
    )
    source_group = parser.add_mutually_exclusive_group()
    source_group.add_argument("-r", "--rijks", action="store_true", 
                            help="Use Rijksmuseum as source")
    source_group.add_argument("-a", "--artic", action="store_true", 
                            help="Use Art Institute of Chicago as source")
    source_group.add_argument("-c", "--cleveland", action="store_true", 
                            help="Use Cleveland Museum of Art as source")
    source_group.add_argument("-n", "--nasa", action="store_true", 
                            help="Use NASA APOD as source")
    args = parser.parse_args()

    try:
        if args.rijks:
            wallpaper_path = get_rijksmuseum()
        elif args.artic:
            wallpaper_path = get_art_institute_chicago()
        elif args.cleveland:
            wallpaper_path = get_cleveland_museum()
        elif args.nasa:
            wallpaper_path = get_apod()
        else:
            wallpaper_path = random.choice([
                get_rijksmuseum, get_art_institute_chicago,
                get_cleveland_museum, get_apod
            ])()

        delete_old_wallpaper()
        change_desktop_background(wallpaper_path)
        logger.info("Wallpaper updated successfully")
    except Exception as e:
        logger.error(f"Failed to update wallpaper: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
