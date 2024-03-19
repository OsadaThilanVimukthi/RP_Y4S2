"""
    This code creates additional images with various augmentations for a specified label in
    a dataset. Don't Run this Again
    
    :param label_dir: The `label_dir` parameter is the directory path to the label that you want to
    augment. In this case, it is the directory path to the label "Belly Rot" in the FinalDataset
    :param num_images: The `num_images` parameter specifies the number of additional images to create
    for the specified label. In the given code, it is set to `300`, which means that 300 additional
    images will be created for the label specified in the `label_to_augment` variable
"""

import os
from PIL import Image, ImageEnhance
import random

# Define the path to the FinalDataset
# final_data_dir = "./FinalDataset"
final_data_dir = "" # Don't Run this Again

# Define the label to augment (e.g., "Belly Rot")
label_to_augment = "Belly Rot"

# Define the number of additional images to create (e.g., 300)
additional_images = 320

# Function to create additional images with various augmentations
def create_additional_images(label_dir, num_images):
    images = [img for img in os.listdir(label_dir) if img.endswith(".jpg")]
    for i in range(num_images):
        original_image = Image.open(os.path.join(label_dir, random.choice(images)))
        
        # Apply data augmentations
        augmented_image = original_image.copy()
        
        # Apply additional augmentations
        if i % 3 == 0:
            brightness = ImageEnhance.Brightness(augmented_image)
            augmented_image = brightness.enhance(1.2)  # Increase brightness
        elif i % 3 == 1:
            contrast = ImageEnhance.Contrast(augmented_image)
            augmented_image = contrast.enhance(1.2)  # Increase contrast
        else:
            # Add other augmentations here, if needed
            pass
        
        # Save the augmented image
        augmented_filename = f"aug_additional_{i + 1}.jpg"
        augmented_image.save(os.path.join(label_dir, augmented_filename))
        print(f"Saved additional image: {augmented_filename}")

# Check if the label to augment exists in the dataset
if label_to_augment not in os.listdir(final_data_dir):
    print(f"The label '{label_to_augment}' does not exist in the dataset.")
else:
    label_dir = os.path.join(final_data_dir, label_to_augment)
    
    # Check if the label directory contains images
    if not os.path.exists(label_dir):
        print(f"The label directory for '{label_to_augment}' does not exist in the dataset.")
    else:
        # Create the specified number of additional images
        create_additional_images(label_dir, additional_images)
        print(f"Created {additional_images} additional images for the '{label_to_augment}' label.")
