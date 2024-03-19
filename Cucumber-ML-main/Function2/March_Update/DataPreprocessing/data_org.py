import os
import random
import shutil

# Define paths
augmented_data_dir = "./Dataset/LeafDiseaseDataAug"
output_dir = "./Dataset/VegetableImagesCucumber"

# Define the number of images for each category
images_per_label_train = 500
images_per_label_test = 100
images_per_label_validation = 100

# Loop through subdirectories in the augmented data directory
for label in os.listdir(augmented_data_dir):
    label_dir = os.path.join(augmented_data_dir, label)

    if os.path.isdir(label_dir):
        # Shuffle the image paths to randomly select
        image_paths = [os.path.join(label_dir, filename) for filename in os.listdir(label_dir)
                        if filename.endswith((".jpg", ".jpeg", ".png", ".JPG"))]
        random.shuffle(image_paths)

        # Create output directories for train, test, and validation
        output_train_dir = os.path.join(output_dir, 'train', label)
        output_test_dir = os.path.join(output_dir, 'test', label)
        output_validation_dir = os.path.join(output_dir, 'validation', label)

        os.makedirs(output_train_dir, exist_ok=True)
        os.makedirs(output_test_dir, exist_ok=True)
        os.makedirs(output_validation_dir, exist_ok=True)

        # Copy images to train
        for image_path in image_paths[:images_per_label_train]:
            shutil.copy(image_path, output_train_dir)

        # Copy images to test
        for image_path in image_paths[images_per_label_train:images_per_label_train + images_per_label_test]:
            shutil.copy(image_path, output_test_dir)

        # Copy images to validation
        for image_path in image_paths[images_per_label_train + images_per_label_test:images_per_label_train + images_per_label_test + images_per_label_validation]:
            shutil.copy(image_path, output_validation_dir)

print("Data organization completed.")
