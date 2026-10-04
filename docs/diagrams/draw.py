"""A small drawing toolkit for the architecture diagrams.

Follows the conventions AWS describes for architecture diagrams: boxes for
components, arrows for relationships, labels for context, and a legend that
explains the icons. Everything renders to PNG so the diagrams display in a
GitHub README without any viewer plugin.
"""
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.abspath(__file__))
LOGOS = os.path.join(ROOT, 'logos')
FONTS = os.path.abspath(os.path.join(
    ROOT, '..', '..', 'Lafaek AI Farm', 'mobile-app', 'assets', 'fonts'))

SCALE = 2  # render at 2x then downsample, for crisp text

# Palette — the app's own colours, so the docs and the product match.
GREEN = (22, 138, 74)
GREEN_DARK = (7, 59, 32)
GREEN_LIGHT = (232, 245, 236)
MINT = (209, 237, 219)
INK = (20, 33, 43)
GREY = (108, 122, 132)
BORDER = (214, 221, 226)
PAPER = (250, 252, 248)
WHITE = (255, 255, 255)
BLUE = (49, 85, 217)
BLUE_LIGHT = (231, 238, 252)
AMBER = (240, 160, 30)
AMBER_LIGHT = (255, 244, 214)
RED = (209, 74, 58)
RED_LIGHT = (253, 235, 232)
LAVENDER = (124, 92, 214)
LAVENDER_LIGHT = (240, 236, 252)


def font(size, weight='Regular'):
    path = os.path.join(FONTS, f'Inter-{weight}.ttf')
    if os.path.exists(path):
        return ImageFont.truetype(path, size * SCALE)
    return ImageFont.load_default(size * SCALE)


class Canvas:
    def __init__(self, width, height, bg=PAPER):
        self.w, self.h = width, height
        self.im = Image.new('RGB', (width * SCALE, height * SCALE), bg)
        self.d = ImageDraw.Draw(self.im)
        self._logos = {}

    # ---- primitives -----------------------------------------------------

    def _s(self, *v):
        return tuple(int(x * SCALE) for x in v)

    def box(self, x, y, w, h, fill=WHITE, outline=BORDER, radius=14, width=2,
            dash=False):
        xy = self._s(x, y, x + w, y + h)
        if dash:
            self._dashed_rect(xy, outline, width)
            if fill is not None:
                self.d.rounded_rectangle(xy, radius=radius * SCALE, fill=fill,
                                         outline=None)
                self._dashed_rect(xy, outline, width)
        else:
            self.d.rounded_rectangle(xy, radius=radius * SCALE, fill=fill,
                                     outline=outline, width=width * SCALE)

    def _dashed_rect(self, xy, colour, width, dash=10, gap=7):
        x0, y0, x1, y1 = xy
        step = (dash + gap) * SCALE
        on = dash * SCALE
        w = width * SCALE
        for x in range(x0, x1, step):
            self.d.line([x, y0, min(x + on, x1), y0], fill=colour, width=w)
            self.d.line([x, y1, min(x + on, x1), y1], fill=colour, width=w)
        for y in range(y0, y1, step):
            self.d.line([x0, y, x0, min(y + on, y1)], fill=colour, width=w)
            self.d.line([x1, y, x1, min(y + on, y1)], fill=colour, width=w)

    def text(self, x, y, s, size=13, weight='Regular', fill=INK,
             anchor='la', max_width=None, line_height=1.35):
        f = font(size, weight)
        if max_width is None:
            self.d.text(self._s(x, y), s, font=f, fill=fill, anchor=anchor)
            return y + size * line_height
        for line in self._wrap(s, f, max_width):
            self.d.text(self._s(x, y), line, font=f, fill=fill, anchor=anchor)
            y += size * line_height
        return y

    def _wrap(self, s, f, max_width):
        out, line = [], ''
        for word in s.split():
            trial = f'{line} {word}'.strip()
            if self.d.textlength(trial, font=f) <= max_width * SCALE or not line:
                line = trial
            else:
                out.append(line)
                line = word
        if line:
            out.append(line)
        return out

    def logo(self, name, x, y, size=34):
        path = os.path.join(LOGOS, f'{name}.png')
        if not os.path.exists(path):
            return
        key = (name, size)
        if key not in self._logos:
            im = Image.open(path).convert('RGBA')
            im.thumbnail((size * SCALE, size * SCALE), Image.LANCZOS)
            self._logos[key] = im
        im = self._logos[key]
        self.im.paste(im, self._s(x, y)[:2], im)

    def arrow(self, x0, y0, x1, y1, colour=GREEN, width=2.5, head=9,
              dashed=False, label=None, label_size=11, label_offset=-16):
        if dashed:
            self._dashed_line(x0, y0, x1, y1, colour, width)
        else:
            self.d.line(self._s(x0, y0, x1, y1), fill=colour,
                        width=int(width * SCALE))
        # arrowhead
        import math
        ang = math.atan2(y1 - y0, x1 - x0)
        for s in (2.6, -2.6):
            self.d.line(
                self._s(x1, y1,
                        x1 - head * math.cos(ang + s / 3),
                        y1 - head * math.sin(ang + s / 3)),
                fill=colour, width=int(width * SCALE))
        self.d.polygon([
            self._s(x1, y1)[:2],
            self._s(x1 - head * math.cos(ang - 0.42),
                    y1 - head * math.sin(ang - 0.42))[:2],
            self._s(x1 - head * math.cos(ang + 0.42),
                    y1 - head * math.sin(ang + 0.42))[:2],
        ], fill=colour)
        if label:
            mx, my = (x0 + x1) / 2, (y0 + y1) / 2
            f = font(label_size, 'Medium')
            tw = self.d.textlength(label, font=f) / SCALE
            self.d.rectangle(
                self._s(mx - tw / 2 - 5, my + label_offset - 3,
                        mx + tw / 2 + 5, my + label_offset + label_size + 3),
                fill=PAPER)
            self.d.text(self._s(mx, my + label_offset), label, font=f,
                        fill=colour, anchor='ma')

    def _dashed_line(self, x0, y0, x1, y1, colour, width, dash=9, gap=6):
        import math
        dist = math.hypot(x1 - x0, y1 - y0)
        if dist == 0:
            return
        ux, uy = (x1 - x0) / dist, (y1 - y0) / dist
        pos = 0
        while pos < dist:
            end = min(pos + dash, dist)
            self.d.line(self._s(x0 + ux * pos, y0 + uy * pos,
                                x0 + ux * end, y0 + uy * end),
                        fill=colour, width=int(width * SCALE))
            pos = end + gap

    def chip(self, x, y, label, fill=GREEN_LIGHT, colour=GREEN_DARK, size=11,
             pad=8, h=22):
        f = font(size, 'SemiBold')
        w = self.d.textlength(label, font=f) / SCALE + pad * 2
        self.d.rounded_rectangle(self._s(x, y, x + w, y + h),
                                 radius=int(h / 2 * SCALE), fill=fill)
        self.d.text(self._s(x + w / 2, y + h / 2), label, font=f, fill=colour,
                    anchor='mm')
        return w

    def save(self, name):
        out = os.path.join(ROOT, name)
        self.im.resize((self.w, self.h), Image.LANCZOS).save(out, optimize=True)
        print(f'  {name}  {self.w}x{self.h}  '
              f'{os.path.getsize(out) / 1024:.0f} KB')


def titled(canvas, title, subtitle=None):
    """Standard diagram header."""
    canvas.text(40, 34, title, size=26, weight='Bold')
    if subtitle:
        canvas.text(40, 70, subtitle, size=13, fill=GREY)
