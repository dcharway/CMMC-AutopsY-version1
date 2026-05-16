"""Generate the CMMC Autopsy app icon at 1024x1024 plus the Android
adaptive-icon foreground / background. Run: python3 scripts/build_icon.py
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = Path(__file__).resolve().parents[1] / "assets" / "icon"
OUT.mkdir(parents=True, exist_ok=True)

SIZE = 1024

NAVY = (3, 2, 19, 255)            # #030213 — matches the app bar
NAVY_LIGHT = (12, 14, 38, 255)
GOLD_OUTER = (208, 158, 36, 255)  # darker rim
GOLD_MID = (245, 196, 70, 255)
GOLD_LIGHT = (255, 235, 150, 255)
GOLD_HIGHLIGHT = (255, 251, 219, 255)
SHIELD_BLUE = (37, 99, 235, 255)  # #2563EB
SHIELD_BLUE_DK = (24, 64, 156, 255)
GREEN = (22, 163, 74, 255)
WHITE = (255, 255, 255, 255)


def radial_gradient(size: int, inner: tuple[int, int, int, int],
                    outer: tuple[int, int, int, int]) -> Image.Image:
    img = Image.new("RGBA", (size, size), outer)
    px = img.load()
    cx = cy = size / 2
    max_r = math.hypot(cx, cy)
    for y in range(size):
        for x in range(size):
            r = math.hypot(x - cx, y - cy) / max_r
            r = min(1.0, r)
            px[x, y] = (
                int(inner[0] + (outer[0] - inner[0]) * r),
                int(inner[1] + (outer[1] - inner[1]) * r),
                int(inner[2] + (outer[2] - inner[2]) * r),
                255,
            )
    return img


def draw_shield(draw: ImageDraw.ImageDraw, cx: float, cy: float, w: float,
                fill, outline=None, outline_w: int = 0):
    h = w * 1.15
    top = cy - h / 2
    bottom = cy + h / 2
    left = cx - w / 2
    right = cx + w / 2
    mid = cy + h * 0.2
    pts = [
        (left, top + h * 0.18),
        (cx, top),
        (right, top + h * 0.18),
        (right, mid),
        (cx, bottom),
        (left, mid),
    ]
    draw.polygon(pts, fill=fill, outline=outline, width=outline_w)


def build_badge(size: int, with_background: bool = True) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if with_background:
        # Rounded square navy backdrop (iOS-style; Android masks to circle)
        radius = int(size * 0.22)
        bg = radial_gradient(size, NAVY_LIGHT, NAVY)
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            (0, 0, size, size), radius=radius, fill=255
        )
        img.paste(bg, (0, 0), mask)
        draw = ImageDraw.Draw(img)

    # ---- Outer gold ring ----
    pad = int(size * 0.08)
    coin_box = (pad, pad, size - pad, size - pad)

    # Drop shadow under the coin
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse(
        (coin_box[0] + 8, coin_box[1] + 14, coin_box[2] + 8, coin_box[3] + 14),
        fill=(0, 0, 0, 120),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=18))
    img.alpha_composite(shadow)

    # Outer rim — radial gold
    rim_size = coin_box[2] - coin_box[0]
    rim = radial_gradient(rim_size, GOLD_LIGHT, GOLD_OUTER)
    rim_mask = Image.new("L", (rim_size, rim_size), 0)
    ImageDraw.Draw(rim_mask).ellipse((0, 0, rim_size, rim_size), fill=255)
    img.paste(rim, (coin_box[0], coin_box[1]), rim_mask)
    draw = ImageDraw.Draw(img)

    # Inner gold band
    inset = int(size * 0.032)
    band_box = (
        coin_box[0] + inset, coin_box[1] + inset,
        coin_box[2] - inset, coin_box[3] - inset,
    )
    draw.ellipse(band_box, fill=GOLD_MID)

    # Highlight crescent on the rim (gives the coin depth)
    hl = Image.new("RGBA", (rim_size, rim_size), (0, 0, 0, 0))
    hl_draw = ImageDraw.Draw(hl)
    hl_draw.ellipse(
        (rim_size * 0.07, rim_size * 0.04, rim_size * 0.93, rim_size * 0.55),
        fill=(255, 255, 255, 90),
    )
    hl = hl.filter(ImageFilter.GaussianBlur(radius=12))
    hl.putalpha(Image.eval(hl.split()[3], lambda v: int(v * 0.85)))
    composite_mask = Image.new("L", (rim_size, rim_size), 0)
    ImageDraw.Draw(composite_mask).ellipse((0, 0, rim_size, rim_size), fill=255)
    img.paste(hl, (coin_box[0], coin_box[1]), composite_mask)
    draw = ImageDraw.Draw(img)

    # Inner navy disc
    disc_inset = int(size * 0.105)
    disc_box = (
        coin_box[0] + disc_inset, coin_box[1] + disc_inset,
        coin_box[2] - disc_inset, coin_box[3] - disc_inset,
    )
    draw.ellipse(disc_box, fill=NAVY)

    # Subtle inner ring
    ring_inset = int(size * 0.115)
    ring_box = (
        coin_box[0] + ring_inset, coin_box[1] + ring_inset,
        coin_box[2] - ring_inset, coin_box[3] - ring_inset,
    )
    draw.ellipse(ring_box, outline=GOLD_LIGHT, width=max(2, size // 256))

    # ---- Shield in the center ----
    cx = cy = size / 2
    shield_w = size * 0.36
    # Shield drop shadow
    shadow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdr = ImageDraw.Draw(shadow_layer)
    draw_shield(sdr, cx, cy + size * 0.012, shield_w, fill=(0, 0, 0, 140))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=8))
    img.alpha_composite(shadow_layer)

    draw_shield(draw, cx, cy, shield_w, fill=SHIELD_BLUE,
                outline=GOLD_LIGHT, outline_w=max(3, size // 220))
    # Subtle inner highlight on shield
    inner_w = shield_w * 0.78
    draw_shield(draw, cx, cy - size * 0.005, inner_w, fill=SHIELD_BLUE_DK)

    # Checkmark
    check_w = shield_w * 0.46
    cw = max(int(size * 0.025), 6)
    p1 = (cx - check_w * 0.45, cy + size * 0.005)
    p2 = (cx - check_w * 0.05, cy + size * 0.055)
    p3 = (cx + check_w * 0.55, cy - size * 0.06)
    draw.line([p1, p2], fill=GREEN, width=cw, joint="curve")
    draw.line([p2, p3], fill=GREEN, width=cw, joint="curve")

    # ---- AUTOPSY wordmark ----
    label = "AUTOPSY"
    font_size = int(size * 0.085)
    font = _load_bold(font_size)
    tw = draw.textlength(label, font=font)
    th = font_size
    label_y = size * 0.74 - th / 2

    # Banner under the badge
    banner_h = th + size * 0.045
    banner_y = label_y - size * 0.022
    banner_left = cx - tw / 2 - size * 0.06
    banner_right = cx + tw / 2 + size * 0.06
    draw.rounded_rectangle(
        (banner_left, banner_y, banner_right, banner_y + banner_h),
        radius=banner_h / 2,
        fill=NAVY,
        outline=GOLD_LIGHT,
        width=max(2, size // 320),
    )
    # Text shadow + fill
    draw.text((cx - tw / 2 + 2, label_y + 2), label, font=font,
              fill=(0, 0, 0, 160))
    draw.text((cx - tw / 2, label_y), label, font=font, fill=GOLD_HIGHLIGHT)

    return img


def _load_bold(px: int) -> ImageFont.FreeTypeFont:
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, px)
    return ImageFont.load_default()


def main() -> None:
    icon = build_badge(SIZE, with_background=True)
    icon.save(OUT / "icon.png")

    fg = build_badge(SIZE, with_background=False)
    fg.save(OUT / "icon_foreground.png")

    bg = Image.new("RGBA", (SIZE, SIZE), NAVY)
    bg.save(OUT / "icon_background.png")

    print(f"Wrote 3 icon files to {OUT}")


if __name__ == "__main__":
    main()
