import moviepy.editor as mp
from PIL import Image
import math
import tkinter as tk
from tkinter import filedialog
import json
import os

def video_to_sprite_sheet(video_path, output_image, frame_width, frame_height):
    # Load the video file
    video = mp.VideoFileClip(video_path)

    # Get the video frame rate and duration
    fps = video.fps
    duration = video.duration
    total_frames = int(fps * duration)

    # Get the dimensions of the final sprite sheet
    sheet_columns = math.ceil(math.sqrt(total_frames))  # Number of columns (square root)
    sheet_rows = math.ceil(total_frames / sheet_columns)  # Number of rows

    # Create a blank image for the sprite sheet
    sprite_sheet = Image.new("RGB", (frame_width * sheet_columns, frame_height * sheet_rows))

    # Create metadata for the frames' positions in the sprite sheet
    frames_info = {
        "total_seconds": duration,
        "total_frames": total_frames,
        "fps": fps,
        "columns": sheet_columns,
        "rows": sheet_rows,
        "frames": []
    }

    # Loop through each frame and paste it into the sprite sheet
    for frame_idx in range(total_frames):
        # Extract the frame as an image
        frame = video.get_frame(frame_idx / fps)
        frame_image = Image.fromarray(frame)

        # Calculate where to paste the frame in the sprite sheet
        x = (frame_idx % sheet_columns) * frame_width
        y = (frame_idx // sheet_columns) * frame_height

        # Paste the frame into the sprite sheet
        sprite_sheet.paste(frame_image, (x, y))

        # Add frame metadata to the list
        frames_info["frames"].append({
            "index": frame_idx,
            "x": x,
            "y": y
        })

    # Save the sprite sheet as a PNG image
    sprite_sheet.save(output_image, "PNG")
    print(f"Sprite sheet saved as {output_image}")

    # Save the frame metadata as a .txt file in JSON format
    metadata_file = output_image.replace(".png", "_metadata.txt")
    with open(metadata_file, "w") as f:
        json.dump(frames_info, f, indent=4)
    print(f"Metadata saved as {metadata_file}")

def load_file():
    # Open file dialog to select the video file
    root = tk.Tk()
    root.withdraw()  # Hide the root window
    video_file = filedialog.askopenfilename(
        title="Select Video File", 
        filetypes=[("QuickTime Video", "*.mov"), ("All Files", "*.*")]
    )
    return video_file

def save_file():
    # Open file dialog to save the sprite sheet
    root = tk.Tk()
    root.withdraw()  # Hide the root window
    save_file_path = filedialog.asksaveasfilename(
        defaultextension=".png",
        filetypes=[("PNG Image", "*.png")],
        title="Save Sprite Sheet As"
    )
    return save_file_path

if __name__ == "__main__":
    # Ask the user to load a video file
    video_path = load_file()
    if not video_path:
        print("No video file selected. Exiting.")
        exit()

    # Ask the user where to save the sprite sheet
    output_image = save_file()
    if not output_image:
        print("No save location selected. Exiting.")
        exit()

    # Define frame dimensions (can be customized)
    frame_width, frame_height = 160, 144  # Natural video resolution

    # Convert the video to sprite sheet and generate metadata
    video_to_sprite_sheet(video_path, output_image, frame_width, frame_height)
