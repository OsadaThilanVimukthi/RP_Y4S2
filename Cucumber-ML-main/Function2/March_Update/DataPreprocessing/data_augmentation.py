import os
from PIL import Image
from PIL import ImageOps
from PIL import ImageEnhance
import random
import shutil

# Define the data augmentation functions
def rotate_image(image, angle):
    return image.rotate(angle)

# Define the data directory paths
original_data_dir = "./Dataset/LeafDiseaseData"
augmented_data_dir = "./Dataset/LeafDiseaseDataAug"

# Set the target number of images per label
target_images_per_class = 1800

# Loop through the subdirectories in the original data directory
for label in os.listdir(original_data_dir):
    label_dir = os.path.join(original_data_dir, label)
    augmented_label_dir = os.path.join(augmented_data_dir, label)

    if os.path.isdir(label_dir):
        image_paths = [os.path.join(label_dir, filename) for filename in os.listdir(label_dir)
                        if filename.endswith((".jpg", ".jpeg", ".png", ".JPG"))]

        # If the class already has 1600 images, copy randomly selected images without augmentation
        if len(image_paths) >= target_images_per_class:
            selected_images = random.sample(image_paths, target_images_per_class)
            os.makedirs(augmented_label_dir, exist_ok=True)
            for original_image_path in selected_images:
                original_image_name = os.path.basename(original_image_path)
                augmented_image_path = os.path.join(augmented_label_dir, original_image_name)
                shutil.copyfile(original_image_path, augmented_image_path)
                print(f"Copied: {augmented_image_path}")
        else:
            # Copy original images to the augmented directory
            os.makedirs(augmented_label_dir, exist_ok=True)
            for original_image_path in image_paths:
                original_image_name = os.path.basename(original_image_path)
                augmented_image_path = os.path.join(augmented_label_dir, original_image_name)
                shutil.copyfile(original_image_path, augmented_image_path)
                print(f"Saved original image: {augmented_image_path}")

            # Create the augmented images
            label_count = len(image_paths)
            while label_count < target_images_per_class:
                random_image_path = random.choice(image_paths)
                img = Image.open(random_image_path)

                # Apply data augmentation
                augmentation_choice = random.choice([1, 2, 3])  # Exclude rotation augmentation
                augmented_image = img

                if augmentation_choice == 1:
                    angle = random.choice([30, 90, 120, 180])  # Rotation augmentation
                    augmented_image = rotate_image(img, angle)
                    prefix = f"rotate_{angle}"
                elif augmentation_choice == 2:
                    brightness = ImageEnhance.Brightness(img)
                    augmented_image = brightness.enhance(random.uniform(0.5, 1.5))  # Random brightness adjustment
                    prefix = "bright"
                elif augmentation_choice == 3:
                    contrast = ImageEnhance.Contrast(img)
                    augmented_image = contrast.enhance(random.uniform(0.5, 1.5))  # Random contrast adjustment
                    prefix = "contrast"

                # Save the augmented image with prefix and count
                augmented_count = len(os.listdir(augmented_label_dir))
                augmented_image_path = os.path.join(augmented_label_dir, f"aug_{prefix}_{label_count + augmented_count}.jpg")
                augmented_image.save(augmented_image_path)
                print(f"Saved: {augmented_image_path}")
                label_count = len(os.listdir(augmented_label_dir))

print("Data augmentation completed.")
