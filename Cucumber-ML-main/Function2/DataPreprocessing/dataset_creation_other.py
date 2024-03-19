import os
import shutil
import random

def rename_and_copy_images(input_directory, output_directory, target_count):
    # Create output directory if it doesn't exist
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    # List all subdirectories in the input directory
    subdirectories = [d for d in os.listdir(input_directory) if os.path.isdir(os.path.join(input_directory, d))]

    # Initialize variables
    total_images_copied = 0

    # Loop through subdirectories
    for folder_name in subdirectories:
        folder_path = os.path.join(input_directory, folder_name)

        # List all files in the current subdirectory
        images = [f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f))]

        # Calculate the number of images to copy from this folder
        images_to_copy = min(target_count - total_images_copied, len(images), 200)

        if images_to_copy > 0:
            # Shuffle the list of images for randomness
            random.shuffle(images)

            print(f"Copying {images_to_copy} images from '{folder_name}'...")

            # Copy images to the output directory with renamed filenames
            for image_name in images[:images_to_copy]:
                new_name = f"{folder_name}_{image_name}"
                source_path = os.path.join(folder_path, image_name)
                destination_path = os.path.join(output_directory, new_name)
                shutil.copyfile(source_path, destination_path)

                total_images_copied += 1
                print(f"  - Copied: {new_name}")

    print(f"\nTotal images copied: {total_images_copied}")

if __name__ == "__main__":
    input_directory = './VegetableImages'
    output_directory = './FinalDatasetv3.0/Other'
    target_count = 8090

    rename_and_copy_images(input_directory, output_directory, target_count)
