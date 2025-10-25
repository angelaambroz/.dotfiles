#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
"""
Enrich scrobbles database with Last.fm artist metadata.
"""

import sqlite3
import requests
import time
from pathlib import Path
import os

# Configuration
LASTFM_API_KEY = os.environ["LASTFM_KEY"]
LASTFM_SECRET = os.environ["LASTFM_SECRET"]
LASTFM_USERNAME = os.environ["LASTFM_USERNAME"]
DB_PATH = Path(__file__).parent / "lastfm_archive.db"
LASTFM_API_URL = "http://ws.audioscrobbler.com/2.0/"


def add_metadata_columns(conn):
    """Add columns for artist metadata."""
    cursor = conn.cursor()

    # Add columns if they don't exist
    try:
        cursor.execute("ALTER TABLE scrobbles ADD COLUMN artist_tags TEXT")
    except sqlite3.OperationalError:
        pass  # Column already exists

    try:
        cursor.execute("ALTER TABLE scrobbles ADD COLUMN kid_music INTEGER DEFAULT 0")
    except sqlite3.OperationalError:
        pass

    conn.commit()


def get_artist_tags(artist_name: str, api_key: str):
    """Get top tags for an artist."""
    params = {
        "method": "artist.gettoptags",
        "artist": artist_name,
        "api_key": api_key,
        "format": "json",
        "limit": 10,
    }

    try:
        response = requests.get(LASTFM_API_URL, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()

        tags = data.get("toptags", {}).get("tag", [])
        if isinstance(tags, dict):
            tags = [tags]

        return [tag["name"].lower() for tag in tags if "name" in tag]
    except Exception as e:
        print(f"  Error fetching tags for {artist_name}: {e}")
        return []


def enrich_artists(conn, api_key, min_plays: int = 5):
    """Fetch and store tags for all unique artists."""
    cursor = conn.cursor()

    # Only enrich artists with 5+ plays (probably ~500-1000 artists?)
    cursor.execute(
        """
        SELECT artist, COUNT(*) as plays
        FROM scrobbles
        WHERE artist_tags IS NULL
        GROUP BY artist
        HAVING plays >= ?
        ORDER BY plays DESC
    """,
        (min_plays,),
    )

    artists = [row[0] for row in cursor.fetchall()]
    total = len(artists)

    print(f"Found {total} artists to enrich")

    KID_TAGS = {
        "children",
        "kids",
        "childrens music",
        "kids music",
        "lullaby",
        "lullabies",
        "nursery rhymes",
        "educational",
        "toddler",
        "baby",
        "preschool",
    }

    for i, artist in enumerate(artists, 1):
        print(f"[{i}/{total}] {artist}")

        tags = get_artist_tags(artist, api_key)
        tags_str = ",".join(tags) if tags else ""

        # Check if kid music
        is_kid = 1 if (set(tags) & KID_TAGS) else 0

        # Update all scrobbles by this artist
        cursor.execute(
            """
            UPDATE scrobbles
            SET artist_tags = ?, kid_music = ?
            WHERE artist = ?
        """,
            (tags_str, is_kid, artist),
        )

        conn.commit()

        # Be nice to Last.fm API
        time.sleep(0.2)

    print("\nEnrichment complete!")


def main():
    conn = sqlite3.connect(DB_PATH)

    # Add columns
    print("Adding metadata columns...")
    add_metadata_columns(conn)

    # Enrich
    print("\nFetching artist metadata from Last.fm...")
    enrich_artists(conn, LASTFM_API_KEY)

    conn.close()


if __name__ == "__main__":
    main()
