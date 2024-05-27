from PIL import ImageDraw, Image, ImageFont, ImageFilter
from images import download
import io
from datetime import datetime
from dataclasses import dataclass
from typing import Optional


# r,g,b separated to make incrementing/decrementing individal color intensities easier
@dataclass
class SubGradient:
    percentage: int = 0
    r: int = 0xFF
    g: int = 0xFF
    b: int = 0xFF
    opacity: float = 1  # not functional atm


def generate_image(
    *,
    image_id: str,
    user_image_id: str,
    username: str,
    date: str,
    completed_thing_name: Optional[str] = None,
):
    base = Image.new(mode="RGB", size=(1024, 1024))
    base.paste(0xC7ECEE, (0, 0, base.width, base.height))
    draw_gradient(
        base,
        [
            SubGradient(percentage=23, r=0xAB, g=0xAB, b=0xFC, opacity=0.9),
            SubGradient(percentage=43, r=0xC9, g=0xA7, b=0xFD, opacity=0.6),
            SubGradient(percentage=63, r=0xF1, g=0xD6, b=0xFE, opacity=0.3),
            SubGradient(percentage=75, r=0xFA, g=0xE6, b=0xFF, opacity=0.3),
            SubGradient(percentage=100, r=0xFD, g=0xFD, b=0xFF, opacity=1.0),
        ],
    )

    s3_im = get_s3_image(image_id).resize((512, 512))
    radius = 25
    add_corners(s3_im, radius)
    sh = drop_shadow(
        s3_im,
        iterations=60,
        border=68,
        background=0x000000,
        shadow=(0, 0, 0, 150),
        offset=(0, 0),
    )
    offset = (-62, -62)
    image_pos = (
        int(base.width / 2 - base.width / 4),
        int(base.height / 2 - base.height / 4),
    )
    base.paste(sh, (image_pos[0] + offset[0], image_pos[1] + offset[1]), sh)
    base.paste(s3_im, image_pos, s3_im)

    font = ImageFont.truetype("fonts/Inter-Bold.ttf", size=62)
    text_shadow(
        bg=base,
        text=completed_thing_name,
        font=font,
        text_color="purple",
        xy=(512, 95),
        anchor="mm",
    )

    font = ImageFont.truetype("fonts/Inter-Bold.ttf", size=40)
    text_shadow(
        bg=base,
        text=datetime.fromisoformat(date).strftime("%d %B"),
        font=font,
        text_color=0x8134CE,
        xy=(512, 165),
        anchor="mm",
    )

    tbox = text_shadow(
        bg=base,
        text=username,
        font=font,
        text_color=(0x61, 0x61, 0xFC),
        xy=(512, 790 + 100),
        anchor="mm",
    )

    profile_pic = get_s3_image(user_image_id).resize((64, 64))
    image_pos = (tbox[0] - 70, tbox[1] - 16)
    profile_pic = add_corners(profile_pic, 33)
    ellipse_shadow(
        base, (image_pos[0], image_pos[1], image_pos[0] + 68, image_pos[1] + 68)
    )
    base.paste(profile_pic, image_pos, profile_pic)
    add_outline(base, profile_pic, image_pos, width=4)

    output = io.BytesIO()
    base.save(output, format="png")
    output.seek(0)
    return output


def ellipse_shadow(bg: Image, bounds):
    shadow_color = (0, 0, 0, 150)
    iterations = 5
    offset = (6, 6)
    blurred = Image.new("RGBA", bg.size)  # type: ignore
    draw = ImageDraw.Draw(blurred)
    draw.ellipse(bounds, fill=shadow_color)
    for n in range(0, iterations):
        blurred = blurred.filter(ImageFilter.BLUR)

    bg.paste(blurred, blurred)  # type: ignore


# https://stackoverflow.com/a/34926008
def draw_ellipse(image, bounds, width=1, outline="white", antialias=4):
    """Improved ellipse drawing function, based on PIL.ImageDraw."""

    # Use a single channel image (mode='L') as mask.
    # The size of the mask can be increased relative to the imput image
    # to get smoother looking results.
    mask = Image.new(
        size=[int(dim * antialias) for dim in image.size], mode="L", color="black"
    )
    draw = ImageDraw.Draw(mask)

    # draw outer shape in white (color) and inner shape in black (transparent)
    for offset, fill in (width / -2.0, "white"), (width / 2.0, "black"):
        left, top = [(value + offset) * antialias for value in bounds[:2]]
        right, bottom = [(value - offset) * antialias for value in bounds[2:]]
        draw.ellipse([left, top, right, bottom], fill=fill)

    # downsample the mask using PIL.Image.LANCZOS
    # (a high-quality downsampling filter).
    mask = mask.resize(image.size, Image.LANCZOS)  # type: ignore
    # paste outline color to input image through the mask
    image.paste(outline, mask=mask)


def add_outline(bg: Image, im: Image, pos: tuple[int, int], width=6):
    circle_x0 = pos[0]
    circle_y0 = pos[1]
    circle_x1 = pos[0] + im.width  # type: ignore
    circle_y1 = pos[1] + im.height  # type: ignore
    draw_ellipse(
        bg, [circle_x0, circle_y0, circle_x1, circle_y1], width=width, outline="navy"
    )


def text_shadow(bg: Image, text: str, font, text_color, xy: tuple[int, int], anchor):
    shadow_color = (0, 0, 0, 155)
    iterations = 5
    offset = (0, 6)
    blurred = Image.new("RGBA", bg.size)  # type: ignore
    draw = ImageDraw.Draw(blurred)
    draw.text(
        (xy[0] + offset[0], xy[1] + offset[1]),
        text=text,
        fill=shadow_color,
        font=font,
        anchor=anchor,
    )
    for n in range(0, iterations):
        blurred = blurred.filter(ImageFilter.BLUR)

    bg.paste(blurred, blurred)  # type: ignore
    draw = ImageDraw.Draw(bg)
    draw.text(xy, text=text, fill=text_color, font=font, anchor=anchor)
    return blurred.getbbox()


# Credit: https://enzircle.hashnode.dev/image-beautifier-in-python
# Modified to make shadows work for rounded images
def drop_shadow(
    image, offset=(5, 5), background=0xFFFFFF, shadow=0x444444, border=8, iterations=3
):
    """
    Add a gaussian blur drop shadow to an image.
    image       - The image to overlay on top of the shadow.
    offset      - Offset of the shadow from the image as an (x,y) tuple.
                  Can be positive or negative.
    background  - Background colour behind the image.
    shadow      - Shadow colour (darkness).
    border      - Width of the border around the image.  This must be wide
                enough to account for the blurring of the shadow.
    iterations  - Number of times to apply the filter.  More iterations
                produce a more blurred shadow, but increase processing time.
    """
    # Create the backdrop image -- a box in the background colour with a
    # shadow on it.
    totalWidth = image.size[0] + abs(offset[0]) + 2 * border
    totalHeight = image.size[1] + abs(offset[1]) + 2 * border
    back = Image.new("RGBA", (totalWidth, totalHeight), background)
    # Place the shadow, taking into account the offset from the image
    shadowLeft = border + max(offset[0], 0)
    shadowTop = border + max(offset[1], 0)
    back.paste(
        shadow,
        [shadowLeft, shadowTop, shadowLeft + image.size[0], shadowTop + image.size[1]],
    )
    # Apply the filter to blur the edges of the shadow.  Since a small kernel
    # is used, the filter must be applied repeatedly to get a decent blur.
    n = 0
    while n < iterations:
        back = back.filter(ImageFilter.BLUR)
        n += 1

    # just return the shadow so we can have image and shadow as separate images
    return back


# https://stackoverflow.com/a/11291419
def add_corners(im, rad):
    circle = Image.new("L", (rad * 2, rad * 2), 0)
    # draw_ellipse(circle, (0, 0, rad * 2 - 1, rad * 2 - 1), fill=255)
    draw = ImageDraw.Draw(circle)
    draw.ellipse((0, 0, rad * 2 - 1, rad * 2 - 1), fill=255)
    alpha = Image.new("L", im.size, 255)
    w, h = im.size
    alpha.paste(circle.crop((0, 0, rad, rad)), (0, 0))
    alpha.paste(circle.crop((0, rad, rad, rad * 2)), (0, h - rad))
    alpha.paste(circle.crop((rad, 0, rad * 2, rad)), (w - rad, 0))
    alpha.paste(circle.crop((rad, rad, rad * 2, rad * 2)), (w - rad, h - rad))
    im.putalpha(alpha)
    return im


def get_s3_image(image_id: str):
    img_response = download(image_id)
    stream = io.BytesIO(img_response.content)
    return Image.open(stream)


def draw_gradient(im: Image, stops: list[SubGradient]):
    old = (stops[0].r, stops[0].g, stops[0].b)
    start = 0

    for g in stops:
        end = round((g.percentage / 100) * im.height)  # type: ignore
        draw_subgradient(
            im=im, c1=old, c2=(g.r, g.g, g.b), start=start, end=end, opacity=g.opacity
        )
        start = end
        old = (g.r, g.g, g.b)


def rgb_tuple(hex_string: str) -> tuple[int, int, int]:
    r = int(hex_string[0:2], 16)
    g = int(hex_string[2:4], 16)
    b = int(hex_string[4:6], 16)
    return (r, g, b)


# Draws background gradient from color 1 -> color 2
def draw_subgradient(
    im: Image,
    c1: tuple[int, int, int],
    c2: tuple[int, int, int],
    start: int,
    end: int,
    opacity: float,
):
    draw = ImageDraw.Draw(im)
    fill = c1

    c_freq_r = change_freq(c1[0], c2[0], end - start)
    c_freq_g = change_freq(c1[1], c2[1], end - start)
    c_freq_b = change_freq(c1[2], c2[2], end - start)

    cfr_counter = start + c_freq_r
    cfg_counter = start + c_freq_g
    cfb_counter = start + c_freq_b

    increment_r = c1[0] < c2[0]
    increment_g = c1[1] < c2[1]
    increment_b = c1[2] < c2[2]

    # Draw a horizontal line on each x from 0 -> image height. Line incrementally approaches destination color.
    for x in range(start, end):
        stop_r = has_reached_end(fill[0], c2[0], increment_r)
        stop_g = has_reached_end(fill[1], c2[1], increment_g)
        stop_b = has_reached_end(fill[2], c2[2], increment_b)

        r = fill[0]
        g = fill[1]
        b = fill[2]

        if x > cfr_counter and not stop_r:
            r = new_color(r, increment_r, 0)
            cfr_counter += c_freq_r
        if x > cfg_counter and not stop_g:
            g = new_color(g, increment_g, 0)
            cfg_counter += c_freq_g
        if x > cfb_counter and not stop_b:
            b = new_color(b, increment_b, 0)
            cfb_counter += c_freq_b

        fill = (r, g, b)

        draw.line([(0, x), (im.width, x)], fill=fill, width=0)  # type: ignore


def divides(a: int, b: int):
    if a == 0:
        return False
    return a % b == 0


# Change frequency determines how many iterations between 0 and the images height it will take before an intensity of a color is changed
# It returns an int which means the value is going to be rounded, but it works well enough.
def change_freq(a: int, b: int, height: int) -> float:
    if a == b:
        return 11
    return height / abs(a - b)


def new_color(color: int, up: bool, index: int) -> int:
    if up:
        color += 1
    else:
        color -= 1
    return color


def has_reached_end(color1: int, color2, up: bool):
    if up:
        return color1 >= color2
    else:
        return color1 <= color2
