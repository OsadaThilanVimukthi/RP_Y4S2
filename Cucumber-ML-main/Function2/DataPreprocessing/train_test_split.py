import os
import random
import shutil

# Define the path to the FinalDataset
final_data_dir = "./FinalDataset"

# Define the path to the directory where the train and test sets will be created
output_dir = "./FinalDataset"

# Define the train-test split ratio (e.g., 70% train and 30% test)
train_ratio = 0.7

# Create train and test directories
train_dir = os.path.join(output_dir, "train")
test_dir = os.path.join(output_dir, "test")
os.makedirs(train_dir, exist_ok=True)
os.makedirs(test_dir, exist_ok=True)

# Loop through the subdirectories (labels) in the FinalDataset
for label in os.listdir(final_data_dir):
    label_dir = os.path.join(final_data_dir, label)
    
    # Create train and test subdirectories for each label
    train_label_dir = os.path.join(train_dir, label)
    test_label_dir = os.path.join(test_dir, label)
    os.makedirs(train_label_dir, exist_ok=True)
    os.makedirs(test_label_dir, exist_ok=True)
    
    # Get a list of image files in the label directory
    image_files = [img for img in os.listdir(label_dir) if img.endswith(".jpg")]
    
    # Calculate the number of images for the train set based on the specified ratio
    num_train_images = int(len(image_files) * train_ratio)
    
    # Shuffle the list of image files for random splitting
    random.shuffle(image_files)
    
    # Split the images into train and test sets
    train_images = image_files[:num_train_images]
    test_images = image_files[num_train_images:]
    
    # Move the images to the appropriate train and test directories
    for img in train_images:
        src_path = os.path.join(label_dir, img)
        dst_path = os.path.join(train_label_dir, img)
        shutil.move(src_path, dst_path)
    
    for img in test_images:
        src_path = os.path.join(label_dir, img)
        dst_path = os.path.join(test_label_dir, img)
        shutil.move(src_path, dst_path)

print("Dataset has been split into train and test sets.")
