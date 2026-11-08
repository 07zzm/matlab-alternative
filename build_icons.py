# -*- coding: utf-8 -*-
"""生成科研环境的图标：Jupyter（渐变色+J标识）、Octave（科技蓝+O标识）、面板（多按钮）"""
import os, struct, zlib
from PIL import Image, ImageDraw, ImageFilter

out = r"D:\GitHub_Project\craft-anything\research\assets\icons"
os.makedirs(out, exist_ok=True)

# ---------- 渐变背景 ----------
def gradient(size, c1, c2, horizontal=True):
    img = Image.new("RGBA", size, (0,0,0,0))
    px = img.load()
    w, h = size
    for x in range(w):
        for y in range(h):
            t = x/(w-1) if horizontal else y/(h-1)
            r = int(c1[0]*(1-t) + c2[0]*t)
            g = int(c1[1]*(1-t) + c2[1]*t)
            b = int(c1[2]*(1-t) + c2[2]*t)
            px[x,y] = (r, g, b, 255)
    return img

def radial_gradient(size, center, c1, c2):
    img = Image.new("RGBA", size, (0,0,0,0))
    px = img.load()
    w, h = size
    cx, cy = center
    for x in range(w):
        for y in range(h):
            d = ((x-cx)**2+(y-cy)**2)**0.5
            t = min(d/((w**2+h**2)**0.5), 1.0)
            r = int(c1[0]*(1-t) + c2[0]*t)
            g = int(c1[1]*(1-t) + c2[1]*t)
            b = int(c1[2]*(1-t) + c2[2]*t)
            px[x,y] = (r, g, b, 255)
    return img

def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0,0,size[0],size[1]], radius=radius, fill=255)
    return mask

def save_ico(img, path):
    # 多尺寸 .ico
    sizes = [16, 32, 48, 64, 128, 256]
    imgs = [img.resize((s,s), Image.LANCZOS) for s in sizes]
    imgs[0].save(path, format="ICO", sizes=[(s,s) for s in sizes], append_images=imgs[1:])

def save_png(img, path):
    img.save(path, "PNG")

# ---------- 图标 1: Jupyter (紫蓝渐变, J + 环 图案) ----------
def make_jupyter(size=512):
    img = radial_gradient((size,size), (size//2,size//2),
                          (99, 102, 241),   # indigo
                          (236, 72, 153))   # pink
    d = ImageDraw.Draw(img)
    w, h = size, size
    cx, cy = w//2, h//2
    # 外发光圆环
    r = int(size*0.32)
    for i, a in enumerate([220, 180, 140]):
        rr = r + i*6
        d.ellipse([cx-rr, cy-rr, cx+rr, cy+rr],
                  outline=(255,255,255,a), width=2)
    # 中心 J 字母（白色）
    font_size = int(size*0.55)
    try:
        from PIL import ImageFont
        font = ImageFont.truetype(r"C:\Windows\Fonts\msyhbd.ttc", font_size)
    except:
        font = ImageFont.load_default()
    text_w, text_h = d.textbbox((0,0), "J", font=font)[2:]
    d.text(((cx - text_w//2)-text_w*0.02, (cy - text_h//2)+text_h*0.03),
           "J", fill=(255,255,255,255), font=font)
    return img

# ---------- 图标 2: Octave (青蓝渐变, O + 波浪) ----------
def make_octave(size=512):
    img = radial_gradient((size,size), (size//2,size//2),
                          (16, 185, 129),   # emerald
                          (59, 130, 246))   # blue
    d = ImageDraw.Draw(img)
    w, h = size, size
    cx, cy = w//2, h//2
    # 中心 O 字母
    font_size = int(size*0.55)
    try:
        from PIL import ImageFont
        font = ImageFont.truetype(r"C:\Windows\Fonts\msyhbd.ttc", font_size)
    except:
        font = ImageFont.load_default()
    text_w, text_h = d.textbbox((0,0), "O", font=font)[2:]
    d.text(((cx - text_w//2)-text_w*0.02, (cy - text_h//2)+text_h*0.03),
           "O", fill=(255,255,255,255), font=font)
    return img

# ---------- 图标 3: 面板启动器 (多色三按钮) ----------
def make_panel(size=512):
    img = Image.new("RGBA", (size,size), (0,0,0,0))
    d = ImageDraw.Draw(img)
    w, h = size, size
    r = int(size*0.12)
    gap = int(size*0.05)
    bh = int(size*0.22)
    bw = int(size*0.62)
    cy_top = int(h*0.18) + bh//2
    colors = [
        (99, 102, 241),    # indigo
        (16, 185, 129),    # emerald
        (245, 158, 11),    # amber
    ]
    labels = [
        ("Jupyter", "蓝"),
        ("Octave GUI", "绿"),
        ("Octave CLI", "橙"),
    ]
    try:
        from PIL import ImageFont
        font = ImageFont.truetype(r"C:\Windows\Fonts\msyhbd.ttc", int(bh*0.55))
    except:
        font = ImageFont.load_default()

    for i, (c, (lbl, _)) in enumerate(zip(colors, labels)):
        y = cy_top + i*(bh+gap)
        x = (w - bw)//2
        # 按钮渐变：用纯色块加圆角
        btn = Image.new("RGBA", (bw, bh), (0,0,0,0))
        bd = ImageDraw.Draw(btn)
        bd.rounded_rectangle([0,0,bw-1,bh-1], radius=bh//2,
                             fill=c + (255,))
        img.paste(btn, (x, y), btn)
        tw = bd.textbbox((0,0), lbl, font=font)[2]
        bd.text(((bw-tw)//2, (bh - bd.textbbox((0,0), lbl, font=font)[3])//2),
                lbl, fill=(255,255,255,255), font=font)
    return img

# ---------- 圆角裁切 & 保存 ----------
for name, maker in [("jupyter", make_jupyter), ("octave", make_octave), ("panel", make_panel)]:
    img = maker(512)
    # 圆角方形蒙版（iOS 风格圆角）
    mask = rounded_mask((512,512), 88)
    img.putalpha(mask)
    save_ico(img, os.path.join(out, f"{name}.ico"))
    save_png(img, os.path.join(out, f"{name}.png"))
    print(f"saved {name}: {os.path.getsize(os.path.join(out, f'{name}.ico'))} bytes")
