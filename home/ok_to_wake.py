"""
Making a programmatic, (wifi-connected?) OK to wake clock

May 2022


TODO:
    - Add start and end times
    - Button to start nap
    - Seasonal art (ASCII art?)
"""

import time
from typing import List, Tuple
from datetime import datetime
import colorsys
from unicornhatmini import UnicornHATMini


WAKE_TIME = [7, 0]
SLEEP_TIME = [18, 30]
GREEN = (0, 50, 0)
WHITE = (100, 100, 100)

SLEEPING_FACE = [(5, 3), (6, 3), (12, 3), (13, 3), (9, 5)]
AWAKE_FACE = [(6, 2), (6, 3), (8, 4), (9, 5), (10, 4), (12, 2), (12, 3)]


def make_rainbow(unicorn: UnicornHATMini, seconds: int = 5):
    """
    Make a fun waking-up rainbow
    """

    # This is straight from the tutorial
    # https://learn.pimoroni.com/article/getting-started-with-unicorn-hat-mini#making-it-rainbow
    spacing = 360.0 / 34.0
    hue = 0

    stime = time.time()
    etime = stime + 5

    while stime < etime:
        stime = time.time()
        hue = int(time.time() * 100) % 360
        for x in range(17):
            offset = x * spacing
            h = ((hue + offset) % 360) / 360.0
            r, g, b = [int(c * 255) for c in colorsys.hsv_to_rgb(h, 1.0, 1.0)]
            for y in range(7):
                unicorn.set_pixel(x, y, r, g, b)

        # keep the waking face in the center of the rainbow
        for xy_pair in AWAKE_FACE:
            unicorn.set_pixel(*xy_pair, *WHITE)

        unicorn.show()
        time.sleep(0.05)


def make_state_face(unicorn: UnicornHATMini, face_type: List[Tuple]):
    """
    This is the resting, non-changing face
    """

    # turn the select x,y pairs white
    # everything else is off
    unicorn.clear()

    for xy_pair in face_type:
        unicorn.set_pixel(*xy_pair, *WHITE)

    return unicorn


def make_waking_face(unicorn: UnicornHATMini):
    """How long to show the green-backgrounded awake face"""

    # green background
    for x in range(17):
        for y in range(7):
            unicorn.set_pixel(x, y, *GREEN)

    # white waking face
    for xy_pair in AWAKE_FACE:
        unicorn.set_pixel(*xy_pair, *WHITE)

    return unicorn


def unicorn(
    wake_time: List[int] = WAKE_TIME,
    sleep_time: List[int] = SLEEP_TIME,
    testing: bool = True,
):
    """ """

    uh = UnicornHATMini()

    # For testing, just cycle through all the faces
    if testing:
        while True:
            uh.set_brightness(0.1)
            uh = make_state_face(uh, SLEEPING_FACE)
            uh.show()
            time.sleep(5)
            uh.set_brightness(0.1)
            make_rainbow(uh)
            uh.set_brightness(0.2)
            uh = make_waking_face(uh)
            uh.show()
            time.sleep(5)
            uh.set_brightness(0.3)
            uh = make_state_face(uh, AWAKE_FACE)
            uh.show()
            time.sleep(5)


if __name__ == "__main__":
    unicorn()
