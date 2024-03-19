import os
from PIL import Image

# Define the path to original dataset
original_data_dir = "./FruitDiseaseData"

# Define the path to the target dataset where images will be combined and renamed
target_data_dir = "./Dataset"

# Function to copy and rename images to avoid conflicts
def copy_and_rename_images(src_dir, dest_dir, label):
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)
    
    for filename in os.listdir(src_dir):
        if filename.endswith(".jpg"):
            src_path = os.path.join(src_dir, filename)
            dest_path = os.path.join(dest_dir, filename)
            
            # If the destination file already exists, add a number to the filename
            num = 1
            while os.path.exists(dest_path):
                dest_filename, ext = os.path.splitext(filename)
                dest_filename = f"{dest_filename}_{num}{ext}"
                dest_path = os.path.join(dest_dir, dest_filename)
                num += 1
            
            # Copy and rename the image to avoid conflicts
            Image.open(src_path).save(dest_path)
            print(f"Saved image: {dest_path}")

# Loop through the original dataset to combine and rename images
for label in os.listdir(original_data_dir):
    label_dir = os.path.join(original_data_dir, label)
    target_label_dir = os.path.join(target_data_dir, label)
    
    if label.endswith("2"):
        # If it's a "2" label, combine and rename images
        base_label = label[:-1]  # Remove the "2" to get the base label
        base_label_dir = os.path.join(target_data_dir, base_label)
        copy_and_rename_images(label_dir, base_label_dir, base_label)
    else:
        # If it's not a "2" label, copy images directly
        if not os.path.exists(target_label_dir):
            os.makedirs(target_label_dir)
        for filename in os.listdir(label_dir):
            if filename.endswith(".jpg"):
                src_path = os.path.join(label_dir, filename)
                dest_path = os.path.join(target_label_dir, filename)
                Image.open(src_path).save(dest_path)
                print(f"Saved image: {dest_path}")


