"""Generates the Rishta Ads launcher icons (pink heart) into an Android res folder.

Run by the GitHub Actions workflow after `flutter create`:
    pip install pillow
    python3 tools/generate_icons.py android/app/src/main/res
"""
import math
import os
import sys

from PIL import Image, ImageDraw

PINK = (255, 64, 129, 255)
WHITE = (255, 255, 255, 255)
SUPERSAMPLE = 4

RES_DIR = sys.argv[1] if len(sys.argv) > 1 else "android/app/src/main/res"

# Legacy launcher icon size (px) and adaptive foreground size (108 dp) per density.
LEGACY = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
FOREGROUND = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}


def heart_points(cx, cy, width, steps=400):
    """Classic heart curve, centred on (cx, cy) and `width` pixels wide."""
    points = []
    scale = width / 32.0
    for i in range(steps):
        t = 2 * math.pi * i / steps
        x = 16 * math.sin(t) ** 3
        y = (13 * math.cos(t) - 5 * math.cos(2 * t)
             - 2 * math.cos(3 * t) - math.cos(4 * t))
        points.append((cx + x * scale, cy - (y + 2.5) * scale))
    return points


def render(px, heart_ratio, background=None, rounded=False):
    big = px * SUPERSAMPLE
    image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    if background is not None:
        if rounded:
            draw.rounded_rectangle([0, 0, big - 1, big - 1],
                                   radius=int(big * 0.22), fill=background)
        else:
            draw.rectangle([0, 0, big - 1, big - 1], fill=background)
    draw.polygon(heart_points(big / 2, big / 2, big * heart_ratio), fill=WHITE)
    return image.resize((px, px), Image.Resampling.LANCZOS)


def save(image, folder, name):
    path = os.path.join(RES_DIR, folder)
    os.makedirs(path, exist_ok=True)
    image.save(os.path.join(path, name))


def main():
    for density, px in LEGACY.items():
        save(render(px, 0.55, background=PINK, rounded=True),
             "mipmap-" + density, "ic_launcher.png")
    for density, px in FOREGROUND.items():
        save(render(px, 0.40), "mipmap-" + density, "ic_launcher_foreground.png")

    adaptive_dir = os.path.join(RES_DIR, "mipmap-anydpi-v26")
    os.makedirs(adaptive_dir, exist_ok=True)
    with open(os.path.join(adaptive_dir, "ic_launcher.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            '</adaptive-icon>\n'
        )

    values_dir = os.path.join(RES_DIR, "values")
    os.makedirs(values_dir, exist_ok=True)
    with open(os.path.join(values_dir, "ic_launcher_background.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<resources>\n'
            '    <color name="ic_launcher_background">#FF4081</color>\n'
            '</resources>\n'
        )
    print("Launcher icons written to", RES_DIR)


if __name__ == "__main__":
    main()
