import numpy as np
from PIL import Image, ImageDraw

# Constants
WIDTH, HEIGHT = 160, 144

# Bayer matrix for dithering (4x4)
bayer_matrix = np.array([
    [0, 8, 2, 10],
    [12, 4, 14, 6],
    [3, 11, 1, 9],
    [15, 7, 13, 5]
])

# Convert HEX color to RGB
def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))

# Function to apply dithering using Bayer matrix
def dither(x, y, threshold):
    matrix_value = bayer_matrix[y % 4, x % 4]
    return matrix_value < threshold * 16

def generate_clouds(cloud_light_color, cloud_dark_color):
    cloud_img = Image.new('RGB', (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(cloud_img)

    # Create noise for cloud generation (you could use Perlin noise here)
    for y in range(HEIGHT):
        for x in range(WIDTH):
            # Simple random noise for demonstration purposes
            if np.random.rand() < 0.3:  # 30% chance to draw a cloud pixel
                color = cloud_light_color if np.random.rand() < 0.5 else cloud_dark_color
                draw.point((x, y), fill=color)

    return cloud_img

# Function to create a curved horizon with dithered fade
def generate_background(curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color):
    img = Image.new('RGB', (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(img)

    # Horizon line curve
    horizon_curve = lambda x: int((curve_intensity - 0.5) * 20 * np.sin(0.5 * np.pi * (2 * x / WIDTH)))

    # Generate sky and ground with dithering
    for y in range(HEIGHT):
        for x in range(WIDTH):
            horizon_y = int(horizon_height * HEIGHT) + horizon_curve(x)

            if y < horizon_y:  # Sky
                draw.point((x, y), fill=sky_color)
            else:  # Ground with dithering
                fade_start = horizon_y
                fade_end = horizon_y + int(fade_depth * HEIGHT)

                if y <= fade_end:
                    dither_factor = (y - fade_start) / (fade_end - fade_start)
                    threshold = max(0, min(1, dither_factor))  # Clamp between 0 and 1

                    if dither(x, y, threshold):
                        draw.point((x, y), fill=ground_color)
                    else:
                        draw.point((x, y), fill=sky_color)
                else:
                    draw.point((x, y), fill=ground_color)
    # clouds = generate_clouds(cloud_light_color, cloud_dark_color)
    # img = Image.alpha_composite(img.convert('RGBA'), clouds.convert('RGBA'))

    return img

# Create an animated sprite with continuous interpolation
def create_animation(curve_intensity, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color, leveling_factor):
    original_curve_intensity = curve_intensity

    images = []
    num_frames = 64  # Total number of frames for smoother animation

    for i in range(num_frames):
        # Calculate the t value for interpolation
        t = (i % (num_frames // 2)) / (num_frames // 2)  # Range from 0 to 1
        if i >= num_frames // 2:
            t = 1 - t  # Reverse direction for the second half

        # Interpolate the curve intensity
        curve_variation = original_curve_intensity * (1 - leveling_factor * t)
        images.append(generate_background(curve_variation, fade_depth, horizon_height, ground_color, sky_color, cloud_light_color, cloud_dark_color))

    return images

