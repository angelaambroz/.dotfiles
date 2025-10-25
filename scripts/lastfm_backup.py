#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
#    "ipython"
# ]
# ///
"""
Archive Last.fm scrobbles to local SQLite database.
Designed to run as scheduled job (cron/systemd timer).
"""

import json
import sqlite3
import requests
import time
from datetime import datetime
from pathlib import Path
import sys
import os

# Configuration
LASTFM_API_KEY = os.environ["LASTFM_KEY"]
LASTFM_SECRET = os.environ["LASTFM_SECRET"]
LASTFM_USERNAME = os.environ["LASTFM_USERNAME"]
DB_PATH = Path(__file__).parent / "lastfm_archive.db"
LASTFM_API_URL = "http://ws.audioscrobbler.com/2.0/"


def init_db(db_path: Path):
    """Create database and tables if they don't exist."""
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS scrobbles (
            timestamp INTEGER PRIMARY KEY,
            artist TEXT NOT NULL,
            album TEXT,
            track TEXT NOT NULL,
            album_mbid TEXT,
            artist_mbid TEXT,
            track_mbid TEXT,
            loved INTEGER DEFAULT 0,
            date_archived TEXT NOT NULL
        )
    """
    )

    cursor.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_artist ON scrobbles(artist)
    """
    )
    cursor.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_track ON scrobbles(track)
    """
    )
    cursor.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_timestamp ON scrobbles(timestamp)
    """
    )

    conn.commit()
    return conn


def get_last_archived_timestamp(conn):
    """Get the most recent timestamp we've already archived."""
    cursor = conn.cursor()
    cursor.execute("SELECT MAX(timestamp) FROM scrobbles")
    result = cursor.fetchone()[0]
    return result if result else 0


def fetch_recent_tracks(
    username: str, api_key: str, from_timestamp: int, page: int = 1, retries: int = 3
):
    """Fetch tracks from Last.fm API with retry logic."""
    params = {
        "method": "user.getrecenttracks",
        "user": username,
        "api_key": api_key,
        "format": "json",
        "limit": 200,
        "page": page,
        "from": from_timestamp,
        "extended": 1,
    }

    for attempt in range(retries):
        try:
            response = requests.get(LASTFM_API_URL, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            if attempt < retries - 1:
                wait_time = 2 ** attempt  # 1s, 2s, 4s
                print(f"  API error (attempt {attempt + 1}/{retries}): {e}")
                print(f"  Retrying in {wait_time}s...")
                time.sleep(wait_time)
            else:
                raise  # Give up after all retries


def insert_scrobbles(conn, scrobbles):
    """Insert scrobbles into database, ignoring duplicates."""
    cursor = conn.cursor()
    archived_timestamp = datetime.now().isoformat()

    inserted = 0
    for scrobble in scrobbles:
        # Skip "now playing" tracks
        if "@attr" in scrobble and scrobble["@attr"].get("nowplaying") == "true":
            continue

        # Sometimes Last.fm returns inconsistent structures, so be defensive
        try:
            timestamp = int(scrobble["date"]["uts"])

            # Artist can be dict with 'name' or just a string
            artist_data = scrobble.get("artist", {})
            if isinstance(artist_data, dict):
                artist = artist_data.get("name", "Unknown Artist")
                artist_mbid = artist_data.get("mbid", "")
            else:
                artist = str(artist_data)
                artist_mbid = ""

            # Album can be dict with '#text' or just a string
            album_data = scrobble.get("album", {})
            if isinstance(album_data, dict):
                album = album_data.get("#text", "")
                album_mbid = album_data.get("mbid", "")
            else:
                album = str(album_data) if album_data else ""
                album_mbid = ""

            track = scrobble.get("name", "Unknown Track")
            track_mbid = scrobble.get("mbid", "")
            loved = 1 if scrobble.get("loved") == "1" else 0

            cursor.execute(
                """
                INSERT INTO scrobbles 
                (timestamp, artist, album, track, album_mbid, artist_mbid, track_mbid, loved, date_archived)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
                (
                    timestamp,
                    artist,
                    album,
                    track,
                    album_mbid,
                    artist_mbid,
                    track_mbid,
                    loved,
                    archived_timestamp,
                ),
            )
            inserted += 1

        except (KeyError, ValueError, TypeError) as e:
            # Log problematic scrobbles but don't crash
            print(f"Warning: Skipping malformed scrobble: {e}", file=sys.stderr)
            continue
        except sqlite3.IntegrityError:
            # Duplicate timestamp, skip silently
            pass

    conn.commit()
    return inserted


def main():
    print(f"Starting Last.fm archival at {datetime.now()}")

    # Initialize database
    conn = init_db(DB_PATH)

    # Get last archived timestamp to avoid re-downloading everything
    last_timestamp = get_last_archived_timestamp(conn)
    print(
        f"Last archived timestamp: {last_timestamp} ({datetime.fromtimestamp(last_timestamp) if last_timestamp else 'Never'})"
    )

    # Fetch and store tracks
    page = 1
    total_inserted = 0

    while True:
        print(f"Fetching page {page}...")
        try:
            data = fetch_recent_tracks(
                LASTFM_USERNAME, LASTFM_API_KEY, last_timestamp, page
            )
        except requests.exceptions.RequestException as e:
            print(f"Error fetching data: {e}", file=sys.stderr)
            break

        tracks = data.get("recenttracks", {}).get("track", [])
        if not tracks:
            break

        # Insert into database
        inserted = insert_scrobbles(conn, tracks)
        total_inserted += inserted
        print(f"  Inserted {inserted} new scrobbles from page {page}")

        # Check if we're on the last page
        total_pages = int(data["recenttracks"]["@attr"]["totalPages"])
        if page >= total_pages:
            break

        page += 1
        time.sleep(0.3)  # Be nice to Last.fm API

    conn.close()
    print(f"Archive complete. Total new scrobbles: {total_inserted}")

    # Print some stats
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM scrobbles")
    total = cursor.fetchone()[0]
    cursor.execute("SELECT MIN(timestamp), MAX(timestamp) FROM scrobbles")
    min_ts, max_ts = cursor.fetchone()
    conn.close()

    print(f"Database now contains {total:,} total scrobbles")
    if min_ts and max_ts:
        print(
            f"Date range: {datetime.fromtimestamp(min_ts)} to {datetime.fromtimestamp(max_ts)}"
        )


if __name__ == "__main__":
    main()
