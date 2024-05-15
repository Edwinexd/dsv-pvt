import PIL.Image
import schemas
from PIL import ImageDraw, Image, ImageFont, ImageFilter
from pilmoji import Pilmoji
from images import download
from pydantic import BaseModel
import io
from dataclasses import dataclass


@dataclass
class SubGradient:
    percentage: int = 0
    r: int = 0xFF
    g: int = 0xFF
    b: int = 0xFF
    opacity: float = 1

# TODO: refactor and remove commented code...
def generate_image(**data):
    # TODO: assert some sort of standard for kwargs e.g.
    # {title: "foo", user: "bar", image_id: "sna"...}

    #s = Image.new(mode="RGBA", size=(1024, 1024))
    base = Image.new(mode="RGB", size=(1024, 1024))
    base.paste(0xc7ecee, (0, 0, base.width, base.height))
    draw_gradient(
        base,
        [
            SubGradient(percentage=23, r=0xAB, g=0xAB, b=0xFC, opacity=0.9),
            SubGradient(percentage=43, r=0xAA, g=0x6C, b=0xFC, opacity=0.6),
            SubGradient(percentage=63, r=0xD2, g=0x78, b=0xFC, opacity=0.3),
            SubGradient(percentage=75, r=0xEE, g=0xAC, b=0xFF, opacity=0.3),
            SubGradient(percentage=100, r=0xFD, g=0xFD, b=0xFF, opacity=1.0),
        ],
    )
    s3_im = get_s3_image(data["image_id"])
    #testbg = Image.new(mode="RGB", size=(512,512))
    #testbg.paste(0xcc98db, (0,0,testbg.width,testbg.height))
    radius = 25
    #test = Image.open("test.jpeg").resize((512,512))
    add_corners(s3_im, radius)
    #testbg.paste(test, (0,0), test)
    #add_corners(s3_im, 100)
    sh = drop_shadow(s3_im, iterations=60, border=68, background=0x000000, shadow=(0,0,0,150), offset=(0,0))
    nimgw, nimgh = sh.size
    offset = (-62,-62)
    #base.paste(sh, (int(base.width / 2 - base.width/4), int(base.height / 2 - base.height /4)), sh)
    #base.paste(sh, offset, mask=sh)
    image_pos = (int(base.width / 2 - base.width/4), int(base.height / 2 - base.height /4))
    base.paste(sh, (image_pos[0]+offset[0],image_pos[1]+offset[1]), sh)
    base.paste(s3_im, image_pos, s3_im)
    #font = ImageFont.load_default(size=42)
    #pilmoji = Pilmoji(base)
    #pilmoji.text(
    #    (256, 210),
    #    f"I completed {data["achievement_name"]}! 😎",
    #    fill=(0xEE, 0xAC, 0xFF),
    #    font=font,
    #)
    base.show()
    #s.paste((255, 255, 255), (0, 0, s.width, s.height))
    #s.paste(base, (0, 0), base)
    #s.show()

# Credit: https://enzircle.hashnode.dev/image-beautifier-in-python
# Modified to make shadows work for rounded images
def drop_shadow(image, offset=(5,5), background=0xffffff, shadow=0x444444, 
                border=8, iterations=3):
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
    totalWidth = image.size[0] + abs(offset[0]) + 2*border
    totalHeight = image.size[1] + abs(offset[1]) + 2*border
    back = Image.new("RGBA", (totalWidth, totalHeight), background)
    # Place the shadow, taking into account the offset from the image
    shadowLeft = border + max(offset[0], 0)
    shadowTop = border + max(offset[1], 0)
    back.paste(shadow, [shadowLeft, shadowTop, shadowLeft + image.size[0], 
               shadowTop + image.size[1]] )
    # Apply the filter to blur the edges of the shadow.  Since a small kernel
    # is used, the filter must be applied repeatedly to get a decent blur.
    n = 0
    while n < iterations:
        back = back.filter(ImageFilter.BLUR)
        n += 1

    # modified to just return the shadow so we can have image and shadow as separate images
    return back


# https://stackoverflow.com/a/11291419
def add_corners(im, rad):
    circle = Image.new('L', (rad * 2, rad * 2), 0)
    draw = ImageDraw.Draw(circle)
    draw.ellipse((0, 0, rad * 2 - 1, rad * 2 - 1), fill=255)
    alpha = Image.new('L', im.size, 255)
    w, h = im.size
    alpha.paste(circle.crop((0, 0, rad, rad)), (0, 0))
    alpha.paste(circle.crop((0, rad, rad, rad * 2)), (0, h - rad))
    alpha.paste(circle.crop((rad, 0, rad * 2, rad)), (w - rad, 0))
    alpha.paste(circle.crop((rad, rad, rad * 2, rad * 2)), (w - rad, h - rad))
    im.putalpha(alpha)
    return im

def get_s3_image(image_id: str) -> Image:
    img_response = download(image_id)
    stream = io.BytesIO(img_response.content)
    return Image.open(stream).resize((512, 512))


def draw_gradient(im: Image, stops: list[SubGradient]):
    old = (stops[0].r, stops[0].g, stops[0].b)
    start = 0

    for g in stops:
        end = int((g.percentage / 100) * im.height)
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
# TODO: create new image for each subgradient to apply opacity
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

    increment_r = c1[0] < c2[0]
    increment_g = c1[1] < c2[1]
    increment_b = c1[2] < c2[2]

    # Draw a horizontal line on each x from 0 -> image height. Line incrementally approaches destination color.
    for x in range(start, end):
        stop_r = has_reached_end(fill[0], c2[0], increment_r)
        stop_g = has_reached_end(fill[0], c2[0], increment_g)
        stop_b = has_reached_end(fill[0], c2[0], increment_b)

        r = fill[0]
        g = fill[1]
        b = fill[2]

        if divides(x, c_freq_r) and not stop_r:
            r = new_color(r, increment_r, 0)
        if divides(x, c_freq_g) and not stop_g:
            g = new_color(g, increment_g, 0)
        if divides(x, c_freq_b) and not stop_b:
            b = new_color(b, increment_b, 0)

        fill = (r, g, b)

        draw.line([(0, x), (im.width, x)], fill=fill, width=0)


def divides(a: int, b: int):
    if a == 0:
        return False
    return a % b == 0


# Change frequency determines how many iterations between 0 and the images height it will take before an intensity of a color is changed
# It returns an int which means the value is going to be rounded, but it works well enough.
def change_freq(a: int, b: int, height: int) -> int:
    if a == b:
        return 11
    return int(height / abs(a - b))


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


generate_image(achievement_name="Testtitel", id=1234, image_id="171576751164")
