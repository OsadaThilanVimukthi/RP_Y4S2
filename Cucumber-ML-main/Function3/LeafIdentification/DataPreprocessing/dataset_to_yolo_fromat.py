import os
import random
from sklearn.model_selection import train_test_split

def create_yolo_dataset(root_folder, class_names, test_size=0.2, val_size=0.2, random_seed=42):
    # Create class folders
    for class_name in class_names:
        class_folder = os.path.join(root_folder, class_name)
        os.makedirs(class_folder, exist_ok=True)

    # Collect image files
    image_files = []
    for class_name in class_names:
        class_folder = os.path.join(root_folder, class_name)
        image_files.extend([(class_name, f) for f in os.listdir(class_folder) if f.lower().endswith(('.jpg', '.jpeg', '.png'))])

    # Split dataset into train, val, and test
    train_files, test_files = train_test_split(image_files, test_size=test_size, random_state=random_seed)
    train_files, val_files = train_test_split(train_files, test_size=val_size, random_state=random_seed)

    # Write data annotation files
    for split, files in [("train", train_files), ("val", val_files), ("test", test_files)]:
        with open(os.path.join(root_folder, f"{split}.txt"), "w") as annotation_file:
            for class_name, file_name in files:
                annotation_file.write(f"{class_names.index(class_name)} {file_name}\n")

    # Create YAML file for dataset configuration
    with open(os.path.join(root_folder, "data.yaml"), "w") as yaml_file:
        yaml_file.write(f"train: {root_folder}\n")
        yaml_file.write(f"val: {root_folder}\n")
        yaml_file.write(f"nc: {len(class_names)}\n")
        yaml_file.write("names: " + str(class_names))

if __name__ == "__main__":
    root_folder = "./LeavesDatasetAug"
    class_names = ["Cucumber Leaves", "Other Leaves"]

    # Call the function to create the dataset
    create_yolo_dataset(root_folder, class_names)
