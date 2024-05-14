import PIL.Image
import schemas
from PIL import ImageDraw, Image, ImageFont
from pilmoji import Pilmoji
from images import download
from pydantic import BaseModel
import io

# TODO: better name
class GradientStop():
    def __init__(self, p: int, r: int, g: int, b: int, o: float):
        self.percentage = p
        self.r = r
        self.g = g
        self.b = b
        self.opacity = o

    percentage: int
    r: int = 0xFF
    g: int = 0xFF
    b: int = 0xFF
    opacity: float

def generate_image(**data):
    # TODO: assert some sort of standard for kwargs e.g.
    # {title: "foo", user: "bar", image_id: "sna"...}

    s = Image.new(mode="RGB", size=(1024,1024))
    base = Image.new(mode="RGB", size=(1024,1024))
    draw_gradient(
        base,
        [
            GradientStop(23, r=0xAB, g=0xAB, b=0xFC, o=0.9),
            GradientStop(43, r=0xAA, g=0x6C, b=0xFC, o=0.6),
            GradientStop(63, r=0xD2, g=0x78, b=0xFC, o=0.3), 
            GradientStop(75, r=0xEE, g=0xAC, b=0xFF, o=0.3),
            GradientStop(100, r=0xFD, g=0xFD, b=0xFF,o=1.0),
        ],
    )
    s3_im = get_s3_image(data["image_id"])
    base.paste(s3_im, (int(base.width/2),int(base.height/2)))
    font = ImageFont.load_default(size=42)
    pilmoji = Pilmoji(base)
    pilmoji.text((512,512), f"I completed {data["achievement_name"]}! 😎", fill=(255,0,0), font=font)
    base.show()
    #s.paste(base, (0,0), base)
    #s.show()
    #im.show()

def get_s3_image(image_id: str) -> Image:
    img_response = download(image_id)
    stream = io.BytesIO(img_response["content"])
    return Image.open(stream).resize((512,512))

def draw_gradient(im: Image, stops: list[GradientStop]):
    fill = (stops[0].r, stops[0].g, stops[0].b)
    start = 0

    for g in stops:
        end = int((g.percentage/100) * im.height)
        fill = draw_subgradient(im=im, c1=fill, c2=(g.r, g.g, g.b), start=start, end=end, opacity=g.opacity)
        start = end

def rgb_tuple(hex_string: str) -> tuple[int, int, int]:
    r = int(hex_string[0:2], 16)
    g = int(hex_string[2:4], 16)
    b = int(hex_string[4:6], 16)
    return (r,g,b)

# Draws background gradient from color 1 -> color 2
# TODO: create new image for each subgradient to apply opacity
def draw_subgradient(im: Image, c1: tuple[int, int, int], c2: tuple[int, int, int], start : int, end: int, opacity: float):
    draw = ImageDraw.Draw(im)
    fill = c1

    c_freq_r = change_freq(c1[0], c2[0], end-start)
    c_freq_g = change_freq(c1[1], c2[1], end-start)
    c_freq_b = change_freq(c1[2], c2[2], end-start)

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

        fill = (r,g,b)
        
        draw.line([(0,x), (im.width, x)], fill=fill, width=0)
    return fill

def divides(a: int, b: int):
    if a == 0:
        return False
    return a % b == 0

# Change frequency determines how many iterations between 0 and the images height it will take before an intensity of a color is changed
# It returns an int which means the value is going to be rounded, but it works well enough.
def change_freq(a: int, b: int, height: int) -> int:
    if a == b:
        return 11
    return int(height/abs(a-b))

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

generate_image(achievement_name="Testtitel", id = 1234, image_id="171576751164")