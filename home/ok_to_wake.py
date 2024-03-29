"""
Making a programmatic OK to wake clock

May 2022


TODO:
    - Add start and end times
    - Seasonal art (ASCII art?)
"""

import time
from typing import List, Tuple
from datetime import datetime
import colorsys
from gpiozero import Button
from signal import pause
from unicornhatmini import UnicornHATMini


WAKE_TIME = [7, 0]
SLEEP_TIME = [18, 30]
NAP_DURATION_MINS = 0.1
GREEN = (0, 5, 0)
WHITE = (100, 100, 100)

BUTTON_MAP = {5: "A", 6: "B", 16: "X", 24: "Y"}

button_a = Button(5)
button_b = Button(6)
button_x = Button(16)
button_y = Button(24)

SLEEPING_FACE = [(4, 2), (5, 2), (11, 2), (12, 2), (8, 4)]
AWAKE_FACE = [
    (4, 1),
    (4, 2),
    (5, 1),
    (5, 2),
    (7, 4),
    (8, 5),
    (9, 4),
    (11, 1),
    (11, 2),
    (12, 1),
    (12, 2),
]


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


def pressed(button):
    """Just testing that the buttons work"""
    button_name = BUTTON_MAP[button.pin.number]
    print(f"Button {button_name} pressed!")


def unicorn(
    wake_time: List[int] = WAKE_TIME,
    sleep_time: List[int] = SLEEP_TIME,
    testing: bool = True,
):
    """The actual schedule"""

    uh = UnicornHATMini()
    uh.set_brightness(0.3)
    nap_time = False

    while True:
        now = time.time()

        # Check if it's currently naptime
        if nap_time:
            if now >= (nap_start_time + NAP_DURATION_MINS * 60):
                nap_time = False
                uh = make_waking_face(uh)
                uh.show()

                # "Wake up" for 15 mins
                # During this time, the clock is unresponsive
                # time.sleep(60 * 15)
                time.sleep(10)

                # You are now awake
                uh = make_state_face(uh, AWAKE_FACE)
            else:
                uh = make_state_face(uh, SLEEPING_FACE)
        else:
            uh = make_state_face(uh, AWAKE_FACE)

        uh.show()

        if button_a.is_pressed:
            print("Nap starting!")
            nap_time = True
            nap_start_time = time.time()
            print(f"Time is {nap_start_time}")
            uh = make_state_face(uh, SLEEPING_FACE)
            uh.show()

        time.sleep(0.1)


if __name__ == "__main__":
    unicorn()

#     try:
#         button_a.when_pressed = pressed
#         button_b.when_pressed = pressed
#         button_x.when_pressed = pressed
#         button_y.when_pressed = pressed

#         pause()

#     except KeyboardInterrupt:
#         button_a.close()
#         button_b.close()
#         button_x.close()
#         button_y.close()
