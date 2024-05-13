import PIL.Image
import schemas
from PIL import ImageDraw, Image, ImageFont
from pilmoji import Pilmoji
from images import download
from pydantic import BaseModel
import io

# TODO: better name
class GradientStop():
    def __init__(self, p, h, o):
        self.percentage = p
        self.hex_clr = h
        self.opacity = o

    percentage: int
    hex_clr: str
    opacity: float

def generate_image(data: BaseModel):
    s = Image.new(mode="RGB", size=(1024,1024))
    base = Image.new(mode="RGB", size=(1024,1024))
#    draw_gradient(base, (int("AB", 16),int("AB", 16),int("FC", 16)), (int("FD", 16),int("FD", 16),int("FF", 16)))
    draw_gradient2(
        base,
        #{
        #    23: "ABABFC",
        #    43: "AA6CFC",
        #    63: "D278FC",
        #    75: "EEACFF",
        #    100: "FDFDFF",
        #},
        [
            GradientStop(23, "ABABFC", 0.9),
            GradientStop(43, "AA6CFC", 0.6),
            GradientStop(63, "D278FC", 0.3), 
            GradientStop(75, "EEACFF", 0.3),
            GradientStop(100, "FDFDFF", 1.0),
        ],
    )
    s3_im = get_s3_image(data.image_id)
    base.paste(s3_im, (int(base.width/2),int(base.height/2)))
    font = ImageFont.load_default(size=42)
    pilmoji = Pilmoji(base)
    pilmoji.text((512,512), f"I completed {data.achievement_name}! 😎", fill=(255,0,0), font=font)
    s.paste(base, (0,0), base)
    s.show()
    #im.show()

def get_s3_image(image_id: str) -> Image:
    img_response = download(image_id)
    stream = io.BytesIO(img_response["content"])
    return Image.open(stream).resize((512,512))

def draw_gradient2(im: Image, stops: list[GradientStop]):
    fill = rgb_tuple(stops[0].hex_clr)
    start = 0

    for g in stops:
        end = int((g.percentage/100) * im.height)
        fill = draw_subgradient(im=im, c1=fill, c2=rgb_tuple(g.hex_clr), start=start, end=end, opacity=g.opacity)
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

    c_freqR = change_freq(c1[0], c2[0], end-start)
    c_freqG = change_freq(c1[1], c2[1], end-start)
    c_freqB = change_freq(c1[2], c2[2], end-start)

    upR = c1[0] < c2[0]
    upG = c1[1] < c2[1]
    upB = c1[2] < c2[2]

    # Draw a horizontal line on each x from 0 -> image height. Line incrementally approaches destination color.
    for x in range(start, end):
        stopR = has_reached_end(fill[0], c2[0], upR)
        stopG = has_reached_end(fill[0], c2[0], upG)
        stopB = has_reached_end(fill[0], c2[0], upB)

        r = fill[0]
        g = fill[1]
        b = fill[2]

        if divides(x, c_freqR) and not stopR:
            r = new_color(r, upR, 0)
        if divides(x, c_freqG) and not stopG:
            g = new_color(g, upG, 0)
        if divides(x, c_freqB) and not stopB:
            b = new_color(b, upB, 0)

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

generate_image(schemas.Achievement(achievement_name="Testtitel", id = 1234, image_id="171576751164"))
