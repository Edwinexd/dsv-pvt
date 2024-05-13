import PIL.Image
import schemas
from pydantic import BaseModel
from PIL import ImageDraw, Image, ImageFont
from pilmoji import Pilmoji
from images import download
import io

def generate_image(data: BaseModel):
    base = Image.new(mode="RGB", size=(1024,1024))
    draw_gradient(base, (int("AB", 16),int("AB", 16),int("FC", 16)), (int("FD", 16),int("FD", 16),int("FF", 16)))
    s3_im = get_s3_image(data.image_id)
    base.paste(s3_im, (int(base.width/2),int(base.height/2)))
    font = ImageFont.load_default(size=42)
    pilmoji = Pilmoji(base)
    pilmoji.text((512,512), f"I completed {data.achievement_name}! 😎", fill=(255,0,0), font=font)
    base.show()
    #im.show()

def get_s3_image(image_id: str) -> Image:
    img_response = download(image_id)
    stream = io.BytesIO(img_response["content"])
    return Image.open(stream).resize((512,512))

# Draws background gradient from color 1 -> color 2
def draw_gradient(im: Image, c1: tuple[int, int, int], c2: tuple[int, int, int]):
    draw = ImageDraw.Draw(im)
    fill = c1

    c_freqR = change_freq(c1[0], c2[0], im.height)
    c_freqG = change_freq(c1[1], c2[1], im.height)
    c_freqB = change_freq(c1[2], c2[2], im.height)

    upR = c1[0] < c2[0]
    upG = c1[1] < c2[1]
    upB = c1[2] < c2[2]

    for x in range(1, 1024):
        stopR = has_reached_end(fill[0], c2[0], upR)
        stopG = has_reached_end(fill[0], c2[0], upG)
        stopB = has_reached_end(fill[0], c2[0], upB)

        r = fill[0]
        g = fill[1]
        b = fill[2]

        if (x % c_freqR == 0) and not stopR:
            r = new_color(r, upR, 0)
        if (x % c_freqG == 0) and not stopG:
            g = new_color(g, upG, 0)
        if (x % c_freqB == 0) and not stopB:
            b = new_color(b, upB, 0)

        fill = (r,g,b)
        
        draw.line([(0,x), (im.width, x)], fill=fill, width=0)

def change_freq(a: int, b: int, height: int) -> int:
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

#generate_image(schemas.Achievement(achievement_name="Testtitel", id = 1234, image_id="171576751164"))