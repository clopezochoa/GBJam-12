import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageTk
from graphics import generate_background, create_animation, hex_to_rgb
import math

# Constants
WIDTH, HEIGHT = 160, 144

# Default color palette
default_colors = {
    "Darkest": "#190000",
    "Dark Red": "#560909",
    "Light Red": "#ad2020",
    "Brightest": "#f2e6e6"
}

# Generic handler for updating sliders and entries
def slider_entry_sync(slider, entry, callback=None):
    """Synchronize slider and entry, updating preview or other actions."""
    def update_entry_from_slider(_):
        entry.delete(0, tk.END)
        entry.insert(0, slider.get())
        if callback:
            callback()

    def update_slider_from_entry(_):
        try:
            value = int(entry.get())
            slider.set(value)
            if callback:
                callback()
        except ValueError:
            pass  # Ignore if the entry is not a valid integer
    
    slider.config(command=update_entry_from_slider)
    entry.bind("<Return>", update_slider_from_entry)

# Generic function to get input values and generate background
def generate_image_data():
    curve_intensity = curve_slider.get() / 100.0
    fade_depth = fade_slider.get() / 100.0
    horizon_height = height_slider.get() / 100.0
    ground_color = hex_to_rgb(ground_color_entry.get())
    sky_color = hex_to_rgb(sky_color_entry.get())
    cloud_light_color = hex_to_rgb(cloud_light_color_entry.get())
    cloud_dark_color = hex_to_rgb(cloud_dark_color_entry.get())
    
    return curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color

# Unified function for generating and updating preview
def update_preview():
    curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color = generate_image_data()
    bg_img = generate_background(curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color)
    
    # Update the preview image in the UI
    preview_img = ImageTk.PhotoImage(bg_img.resize((WIDTH * 2, HEIGHT * 2)))  # Scale up for better view
    preview_label.config(image=preview_img)
    preview_label.image = preview_img

# Save image function using unified image generation
def save_image():
    curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color = generate_image_data()
    bg_img = generate_background(curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color)
    
    filepath = filedialog.asksaveasfilename(defaultextension=".png", filetypes=[("PNG files", "*.png")])
    if filepath:
        bg_img.save(filepath)
        print(f"Image saved to {filepath}")

# Create animation using unified image generation
def create_animation_handler():
    curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color = generate_image_data()
    leveling_factor = leveling_slider.get() / 100.0
    images = create_animation(curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color, leveling_factor)
    
    filepath = filedialog.asksaveasfilename(defaultextension=".gif", filetypes=[("GIF files", "*.gif")])
    if filepath:
        images[0].save(filepath, save_all=True, append_images=images[1:], duration=100, loop=0)
        print(f"Animation saved to {filepath}")

# Save animation as a sprite sheet with all frames in a single PNG
def save_sprite_sheet():
    curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color = generate_image_data()
    curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color = generate_image_data()
    leveling_factor = leveling_slider.get() / 100.0
    images = create_animation(curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color, leveling_factor)
    
    # Calculate the number of frames
    total_frames = len(images)
    
    # Determine the grid size
    sheet_columns = math.ceil(math.sqrt(total_frames))  # Number of columns (square root)
    sheet_rows = math.ceil(total_frames / sheet_columns)  # Number of rows

    # Create a blank image for the sprite sheet
    sprite_sheet = Image.new("RGB", (WIDTH * sheet_columns, HEIGHT * sheet_rows))

    # Paste each frame into the sprite sheet
    for frame_idx, img in enumerate(images):
        x = (frame_idx % sheet_columns) * WIDTH
        y = (frame_idx // sheet_columns) * HEIGHT
        sprite_sheet.paste(img, (x, y))

    # Save the sprite sheet as a PNG image
    output_image = filedialog.asksaveasfilename(defaultextension=".png", filetypes=[("PNG Image", "*.png")])
    if output_image:
        sprite_sheet.save(output_image)
        print(f"Sprite sheet saved as {output_image}")

# Create the Tkinter window
window = tk.Tk()
window.title("Pixel Art Landscape Generator")

# Preview label to display the generated background
preview_label = tk.Label(window)
preview_label.grid(row=0, column=0, columnspan=4)

# Sliders and entries creation with synchronization
def create_slider_entry(row, label_text, default_value, callback=None):
    slider = tk.Scale(window, from_=0, to=100, orient='horizontal', label=label_text)
    slider.set(default_value)
    slider.grid(row=row, column=0, columnspan=3)

    entry = tk.Entry(window, width=5)
    entry.insert(0, str(default_value))
    entry.grid(row=row, column=3)

    slider_entry_sync(slider, entry, callback)
    return slider

# Create sliders and entries
curve_slider = create_slider_entry(1, 'Horizon Curve Intensity', 35, update_preview)
fade_slider = create_slider_entry(2, 'Fade Depth', 15, update_preview)
height_slider = create_slider_entry(3, 'Horizon Height', 20, update_preview)
leveling_slider = create_slider_entry(4, 'Curve Leveling (0% to 100%)', 100)

# Color selection entries
tk.Label(window, text="Ground Color (HEX)").grid(row=5, column=0, columnspan=2)
ground_color_entry = tk.Entry(window)
ground_color_entry.insert(0, default_colors["Darkest"])
ground_color_entry.grid(row=5, column=2, columnspan=2)

tk.Label(window, text="Sky Color (HEX)").grid(row=6, column=0, columnspan=2)
sky_color_entry = tk.Entry(window)
sky_color_entry.insert(0, default_colors["Brightest"])
sky_color_entry.grid(row=6, column=2, columnspan=2)

tk.Label(window, text="Cloud Light Color (HEX)").grid(row=7, column=0, columnspan=2)
cloud_light_color_entry = tk.Entry(window)
cloud_light_color_entry.insert(0, default_colors["Dark Red"])
cloud_light_color_entry.grid(row=7, column=2, columnspan=2)

tk.Label(window, text="Cloud Dark Color (HEX)").grid(row=8, column=0, columnspan=2)
cloud_dark_color_entry = tk.Entry(window)
cloud_dark_color_entry.insert(0, default_colors["Light Red"])
cloud_dark_color_entry.grid(row=8, column=2, columnspan=2)

# Buttons for saving image, creating animation, and saving sprite sheet
save_button = tk.Button(window, text="Save Image", command=save_image)
save_button.grid(row=11, column=0)

animation_button = tk.Button(window, text="Create Animation", command=create_animation_handler)
animation_button.grid(row=11, column=1)

sprite_sheet_button = tk.Button(window, text="Save as Sprite Sheet", command=save_sprite_sheet)
sprite_sheet_button.grid(row=11, column=2)

update_preview()
window.mainloop()
