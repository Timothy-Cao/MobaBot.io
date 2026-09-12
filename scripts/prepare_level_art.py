"""Rebuild reversible level-selector pixelation from the retained PNG masters."""
from pathlib import Path
from PIL import Image, ImageEnhance

folder = Path(__file__).resolve().parents[1] / "assets" / "levels"
for name in ("yard", "assembly", "cooling"):
    image = Image.open(folder / f"{name}-source.png").convert("RGB")
    image = image.resize((256, 384), Image.Resampling.LANCZOS)
    image = ImageEnhance.Color(image).enhance(0.85)
    image = ImageEnhance.Brightness(image).enhance(0.97)
    image.save(folder / f"{name}.png")
