#!/usr/bin/env python3
"""
Generate PNG icons for Pokemon types.
This script creates simple PNG icons for each Pokemon type with the appropriate colors.
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFont

# Pokemon type colors (same as in the Flutter app)
TYPE_COLORS = {
    'normal': (168, 168, 120),
    'fire': (240, 128, 48),
    'water': (104, 144, 240),
    'electric': (248, 208, 48),
    'grass': (120, 200, 80),
    'ice': (152, 216, 216),
    'fighting': (192, 48, 40),
    'poison': (160, 64, 160),
    'ground': (224, 192, 104),
    'flying': (168, 144, 240),
    'psychic': (248, 88, 136),
    'bug': (168, 184, 32),
    'rock': (184, 160, 56),
    'ghost': (112, 88, 152),
    'dragon': (112, 56, 248),
    'dark': (112, 88, 72),
    'steel': (184, 184, 208),
    'fairy': (238, 153, 172),
}

def generate_png_icon(type_name, output_dir, size=48):
    """Generate a PNG icon for the given Pokemon type."""
    # Get color for the type
    color = TYPE_COLORS.get(type_name, (204, 204, 204))
    
    print(f"Generating icon for {type_name} type...")
    
    # Create a new image with a transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw a circle with the type color
    draw.ellipse([(0, 0), (size, size)], fill=color)
    
    # Add the first letter of the type name
    letter = type_name[0].upper()
    
    # Try to load a font, use default if not available
    try:
        # Try to use Arial or a similar font
        font = ImageFont.truetype("arial.ttf", size // 2)
        print(f"Using Arial font for {type_name}")
    except IOError:
        # Use default font if Arial is not available
        font = ImageFont.load_default()
        print(f"Using default font for {type_name}")
    
    # Calculate text position to center it
    try:
        text_width = draw.textlength(letter, font=font)
        text_height = size // 2  # Approximate height
        text_position = ((size - text_width) // 2, (size - text_height) // 2)
    except AttributeError:
        # For older versions of PIL
        text_width, text_height = draw.textsize(letter, font=font)
        text_position = ((size - text_width) // 2, (size - text_height) // 2)
        print(f"Using older PIL text sizing method for {type_name}")
    
    # Draw the letter in white
    draw.text(text_position, letter, fill=(255, 255, 255), font=font)
    
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    print(f"Output directory: {os.path.abspath(output_dir)}")
    
    # Save the image
    output_path = os.path.join(output_dir, f"{type_name}.png")
    try:
        img.save(output_path)
        print(f"Successfully saved icon to {os.path.abspath(output_path)}")
    except Exception as e:
        print(f"Error saving icon for {type_name}: {e}")
    
    return os.path.abspath(output_path)

def main():
    # Default output directory
    output_dir = os.path.join('assets', 'images')
    
    print(f"Starting icon generation...")
    print(f"Current working directory: {os.getcwd()}")
    print(f"Target output directory: {os.path.abspath(output_dir)}")
    
    # Create PNG icons for all Pokemon types
    generated_files = []
    for type_name in TYPE_COLORS.keys():
        try:
            file_path = generate_png_icon(type_name, output_dir)
            generated_files.append(file_path)
        except Exception as e:
            print(f"Error generating icon for {type_name}: {e}")
    
    print("\nIcon generation complete!")
    print(f"PNG icons saved to: {os.path.abspath(output_dir)}")
    print(f"Generated {len(generated_files)} icons")
    print("\nMake sure to add this directory to your pubspec.yaml assets section.")

if __name__ == "__main__":
    main() 