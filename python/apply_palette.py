from tkinter import Tk, filedialog, messagebox
from PIL import Image
import numpy as np
import os

# Define the color palette
palette = [
    (0x19, 0x00, 0x00),  # #190000
    (0x56, 0x09, 0x09),  # #560909
    (0xad, 0x20, 0x20),  # #ad2020
    (0xf2, 0xe6, 0xe6),  # #f2e6e6
]

def closest_color(rgb):
    """Find the closest color from the palette using Euclidean distance."""
    r, g, b = rgb[:3]
    distances = [np.sqrt((r - pr)**2 + (g - pg)**2 + (b - pb)**2) for pr, pg, pb in palette]
    return palette[np.argmin(distances)]

def resample_image(image_path, output_path):
    # Open the image and convert it to RGBA format
    img = Image.open(image_path).convert("RGBA")
    width, height = img.size
    pixels = np.array(img)

    # Iterate through every pixel in the image
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[y, x]
            # If the pixel is fully transparent, keep it as transparent
            if a == 0:
                continue
            # If the pixel is visible, make the color the closest from the palette
            # and set alpha to fully opaque (255)
            pixels[y, x][:3] = closest_color((r, g, b))
            pixels[y, x][3] = 255  # Make the pixel fully opaque

    # Create a new image from the modified pixel array
    new_img = Image.fromarray(pixels, "RGBA")
    new_img.save(output_path)
    print(f"Processed and saved: {output_path}")

def batch_process_images():
    # Create the Tkinter window
    root = Tk()
    root.withdraw()  # Hide the root window

    # Prompt the user to select multiple image files
    input_image_paths = filedialog.askopenfilenames(
        title="Select Images for Batch Processing",
        filetypes=[("PNG files", "*.png"), ("All files", "*.*")]
    )

    if not input_image_paths:
        print("No files selected.")
        return

    # Ask if the user wants to choose a folder for batch saving or save each file manually
    save_option = messagebox.askyesno(
        title="Save Option",
        message="Do you want to save all processed images in a single folder?"
    )

    if save_option:
        # Ask the user to choose a folder to save all processed images
        output_folder = filedialog.askdirectory(title="Select Folder to Save Processed Images")
        if not output_folder:
            print("No folder selected.")
            return

    # Process each selected image
    for image_path in input_image_paths:
        file_name = os.path.basename(image_path)

        if save_option:
            # Save all files to the selected output folder, preserving the original names
            output_path = os.path.join(output_folder, file_name)
        else:
            # Ask user to select save location for each image
            output_path = filedialog.asksaveasfilename(
                title=f"Save Processed Image As ({file_name})",
                initialfile=file_name,
                defaultextension=".png",
                filetypes=[("PNG files", "*.png"), ("All files", "*.*")]
            )

            if not output_path:
                print(f"Skipping file: {file_name}")
                continue

        # Process and save the image
        resample_image(image_path, output_path)

if __name__ == "__main__":
    batch_process_images()
