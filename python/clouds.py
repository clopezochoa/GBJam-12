from PIL import Image, ImageDraw
import random

# Set the size of the initial image (small for pixel art effect)
img_size = (160, 40)  # Width x Height
img = Image.new('RGB', img_size, 'skyblue')  # Create a sky blue background image
draw = ImageDraw.Draw(img)

number_of_clouds = 20  # Number of cloud formations to generate

min_radius = 3
max_radius = 15

for _ in range(number_of_clouds):
    # Cloud center x and y, ensuring circles will not touch top or sides
    x_center = random.randint(max_radius + 1, img_size[0] - max_radius - 1)
    y_center = random.randint(max_radius + 1, img_size[1] - max_radius - 1)

    num_circles = random.randint(5, 10)
    for _ in range(num_circles):
        # Random radius for each circle
        radius = random.randint(min_radius, max_radius)

        # Random offset from center, ensuring circles stay within bounds
        dx = random.randint(-radius, radius)
        dy = random.randint(-radius, radius)

        x = x_center + dx
        y = y_center + dy

        # Adjust x and y to ensure constraints

        # Left edge: x - radius > 0 (cannot touch left side)
        if x - radius <= 0:
            x = radius + 1

        # Right edge: x + radius < img_size[0] (cannot touch right side)
        if x + radius >= img_size[0]:
            x = img_size[0] - radius - 1

        # Top edge: y - radius > 0 (cannot touch top)
        if y - radius <= 0:
            y = radius + 1

        # Bottom Edge: y + radius <= img_size[1] (can touch bottom)
        if y + radius > img_size[1]:
            y = img_size[1] - radius

        # Now draw the circle
        left = x - radius
        upper = y - radius
        right = x + radius
        lower = y + radius

        # Decide color for shading (30% chance for shadow)
        if random.random() < 0.3:
            color = 'lightgrey'
        else:
            color = 'white'

        draw.ellipse([left, upper, right, lower], fill=color)

# Resize the image to a larger size for pixelated effect
final_size = (img_size[0]*4, img_size[1]*4)
img = img.resize(final_size, Image.NEAREST)

# Save the image as a PNG file
img.save('pixelart_clouds.png')