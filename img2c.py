import sys
from PIL import Image


template = '''void load_pixels() {{
{lines}
}};
'''

im = Image.open(sys.argv[-2]).convert('RGB')

with open(sys.argv[-1], 'w') as f:
    pixels = []
    lines = []
    count = 0

    for y in range(im.size[1]):
        for x in range(0, im.size[0], 2):
            r, g, b = im.getpixel((x, y))
            rgb565 = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
            pixels.append(rgb565 >> 8)
            pixels.append(rgb565 & 0xff)

            r, g, b = im.getpixel((x+1, y))
            rgb565 = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
            pixels.append(rgb565 >> 8)
            pixels.append(rgb565 & 0xff)

            u32 = (pixels[0] << 24) + (pixels[1] << 16) + (pixels[2] << 8) + pixels[3]
            lines.append(f'\t*(unsigned int *)(0x62000000 + {count:7d}) = {u32:#08x};')
            pixels = []
            count += 4;
    f.write(template.format(lines='\n'.join(lines)))

