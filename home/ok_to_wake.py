"""
Making a programmatic, (wifi-connected?) OK to wake clock

May 2022


TODO:
    - Add start and end times
    - Button to start nap
    - Seasonal art (ASCII art?)
"""

import time
from datetime import datetime
import colorsys
from unicornhatmini import UnicornHATMini

uh = UnicornHATMini()

# 100% is VERY BRIGHT
uh.set_brightness(0.3)

WAKE_TIME = [7, 0]
SLEEP_TIME = [18, 30]
OK_TO_WAKE_GREEN = (89, 100, 89)


# This is straight from the tutorial
# https://learn.pimoroni.com/article/getting-started-with-unicorn-hat-mini#making-it-rainbow
spacing = 360.0 / 34.0
hue = 0

while True:
    hue = int(time.time() * 100) % 360
    for x in range(17):
        offset = x * spacing
        h = ((hue + offset) % 360) / 360.0
        r, g, b = [int(c * 255) for c in colorsys.hsv_to_rgb(h, 1.0, 1.0)]
        for y in range(7):
            uh.set_pixel(x, y, r, g, b)
    uh.show()
    time.sleep(0.05)
