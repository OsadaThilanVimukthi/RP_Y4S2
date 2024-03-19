import os
from PIL import Image, ImageOps

# Define the path to the original dataset (Dataset folder)
original_data_dir = "./NewImages"

# Define the path to the target dataset where augmented and original images will be saved
final_data_dir = "./FinalDatasetNewImages"

# Define the data augmentation functions
def rotate_image(image, angle):
    # Rotate the image by the specified angle (90, 180 degrees)
    return image.rotate(angle, expand=True)
    
def flip_image(image):
    # Create horizontally and vertically flipped versions
    flipped_images = []
    flipped_images.append(ImageOps.mirror(image))  # Horizontal flip
    flipped_images.append(ImageOps.flip(image))    # Vertical flip
    return flipped_images

# Define the fixed rotation angles
rotation_angles = [90, 180]

# Loop through the original dataset and perform data augmentation
for label in os.listdir(original_data_dir):
    label_dir = os.path.join(original_data_dir, label)
    final_label_dir = os.path.join(final_data_dir, label)
    
    if not os.path.exists(final_label_dir):
        os.makedirs(final_label_dir)
    
    print(f"Processing label: {label}")
    
    for filename in os.listdir(label_dir):
        if filename.endswith(".jpg"):
            img_path = os.path.join(label_dir, filename)
            original_image = Image.open(img_path)
            
            # Save the original image
            original_image.save(os.path.join(final_label_dir, filename))
            print(f"Saved original image: {filename}")
            
            # Apply data augmentation to create augmented versions
            for angle in rotation_angles:  # Apply fixed rotations
                augmented_image = original_image.copy()
                augmented_image = rotate_image(augmented_image, angle)
                flipped_images = flip_image(augmented_image)
                
                # Save rotated and flipped images
                for j, flipped_image in enumerate(flipped_images):
                    augmented_filename = f"aug_rot_{angle}_flip_{j}_{filename}"  # Add rotation angle and numbers
                    flipped_image.save(os.path.join(final_label_dir, augmented_filename))
                    print(f"Saved augmented image: {augmented_filename}")

