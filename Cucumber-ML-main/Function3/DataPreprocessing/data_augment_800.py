import os
from PIL import Image
from PIL import ImageOps
from PIL import ImageEnhance
from PIL import ImageFilter
import random
import shutil

# Define the data augmentation functions
def rotate_image(image, angle):
    return image.rotate(angle, expand=True)

def flip_image(image):
    flipped_images = []
    flipped_images.append(ImageOps.mirror(image))  # Horizontal flip
    flipped_images.append(ImageOps.flip(image))    # Vertical flip
    return flipped_images

# Define the fixed rotation angles
rotation_angles = [90, 180]

# Define the data directory paths
original_data_dir = "./LeafDiseaseData"
augmented_data_dir = "./FinalDataset_800"

# Loop through the subdirectories in the original data directory
for label in os.listdir(original_data_dir):
    label_dir = os.path.join(original_data_dir, label)
    augmented_label_dir = os.path.join(augmented_data_dir, label)

    if os.path.isdir(label_dir):
        image_paths = [os.path.join(label_dir, filename) for filename in os.listdir(label_dir) if filename.endswith(".JPG")]

        # Copy original images to the augmented directory
        os.makedirs(augmented_label_dir, exist_ok=True)
        for original_image_path in image_paths:
            original_image_name = os.path.basename(original_image_path)
            augmented_image_path = os.path.join(augmented_label_dir, original_image_name)

            shutil.copyfile(original_image_path, augmented_image_path)
            print(f"Saved original image: {augmented_image_path}")

        # Create the augmented images
        label_count = len(image_paths)
        while label_count < 800:  # Increase the target number of images per label
            random_image_path = random.choice(image_paths)
            img = Image.open(random_image_path)

            # Apply data augmentation
            if label_count < 800:
                augmentation_choice = random.choice([0, 1, 2, 3, 4, 5])  # Increase the number of choices
                augmented_image = img
                
                if augmentation_choice == 0:
                    rotated_images = [rotate_image(img, angle) for angle in rotation_angles]
                    augmented_image = random.choice(rotated_images)
                    prefix = "rotate"
                elif augmentation_choice == 1:
                    flipped_images = flip_image(img)
                    augmented_image = random.choice(flipped_images)
                    prefix = "flip"
                elif augmentation_choice == 2:
                    brightness = ImageEnhance.Brightness(img)
                    augmented_image = brightness.enhance(random.uniform(0.8, 1.2))  # Random brightness adjustment
                    prefix = "bright"
                elif augmentation_choice == 3:
                    contrast = ImageEnhance.Contrast(img)
                    augmented_image = contrast.enhance(random.uniform(0.8, 1.2))  # Random contrast adjustment
                    prefix = "contrast"
                elif augmentation_choice == 4:
                    zoomed_image = img.crop((50, 50, img.width - 50, img.height - 50))  # Simulate zoom
                    prefix = "zoom"
                elif augmentation_choice == 5:
                    blurred_image = img.filter(ImageFilter.GaussianBlur(random.uniform(0, 2)))  # Random Gaussian blur
                    prefix = "blur"

                # Save the augmented image with prefix and count
                augmented_count = len(os.listdir(augmented_label_dir))
                augmented_image_path = os.path.join(augmented_label_dir, f"aug_{prefix}_{label_count + augmented_count}.JPG")
                augmented_image.save(augmented_image_path)
                print(f"Saved: {augmented_image_path}")
                label_count = len(os.listdir(augmented_label_dir))

print("Data augmentation completed.")
