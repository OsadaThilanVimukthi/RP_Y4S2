"""
    This code is a script that removes a specified number of random images from a specific
    label directory in a dataset. Don't Run this Again
    
    :param label_dir: The `label_dir` variable represents the directory path where the images of a
    specific label are stored. It is obtained by joining the `final_data_dir` (the path to the
    FinalDataset) with the `label_to_balance` (the label to balance)
    :param num_images: The `num_images` parameter is the number of images you want to remove from the
    specified label directory. In the given code, it is set to 800
"""

import os
import random

# Define the path to the FinalDataset
# final_data_dir = "./FinalDataset"
final_data_dir = "" # Don't Run this Again

# Define the label to balance (e.g., "Pythium Fruit Rot")
label_to_balance = "Pythium Fruit Rot"

# Define the number of images to remove (e.g., 800)
images_to_remove = 800

# Function to remove random images from a label directory
def remove_images(label_dir, num_images):
    images = [img for img in os.listdir(label_dir) if img.endswith(".jpg")]
    images_to_remove = random.sample(images, num_images)
    for img in images_to_remove:
        img_path = os.path.join(label_dir, img)
        os.remove(img_path)

# Check if the label to balance exists in the dataset
if label_to_balance not in os.listdir(final_data_dir):
    print(f"The label '{label_to_balance}' does not exist in the dataset.")
else:
    label_dir = os.path.join(final_data_dir, label_to_balance)
    
    # Check if the label directory contains augmented images
    if not os.path.exists(label_dir):
        print(f"The label directory for '{label_to_balance}' does not exist in the dataset.")
    else:
        # Remove the specified number of random images from the label
        remove_images(label_dir, images_to_remove)
        print(f"Removed {images_to_remove} images from the '{label_to_balance}' label.")
