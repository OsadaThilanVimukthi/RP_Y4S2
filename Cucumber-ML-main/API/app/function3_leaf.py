from fastapi import FastAPI, File, UploadFile, APIRouter
from fastapi.responses import JSONResponse
import numpy as np
from tensorflow import keras
from keras.applications.vgg16 import preprocess_input
from keras.preprocessing import image
import os

router = APIRouter()

# Get the directory of the current script
current_dir = os.path.dirname(os.path.abspath(__file__))

# Load the trained model for Function 2
leaf_model_path = os.path.join(current_dir, "./src/fun3/best_model_epoch4.h5")
leaf_model = keras.models.load_model(leaf_model_path)

# Load the trained model for Disease detection (Function 3)
disease_model_path = os.path.join(current_dir, "./src/fun3/best_model_v2.0.h5")
disease_model = keras.models.load_model(disease_model_path)

# Define the class labels
leaf_class_labels = [
    'Cucumber Leaves',
    'Other Leaves'
]

disease_class_labels = [
    'Healthy leaves',
    'downy mildew stage 1',
    'downy mildew stage 2',
    'powdery mildew stage 1',
    'powdery mildew stage 2'
]

# Load and preprocess the input image for leaf identification
def preprocess_leaf_image(image_path, target_size):
    img = image.load_img(image_path, target_size=target_size)
    img_array = image.img_to_array(img)
    img_array = preprocess_input(img_array)
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

# Load and preprocess the input image for disease detection
def preprocess_disease_image(image_path, target_size):
    img = image.load_img(image_path, target_size=target_size)
    img_array = image.img_to_array(img)
    img_array = preprocess_input(img_array)
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

# Define a function to make predictions for leaf identification
def predict_leaf_class(image_path):
    img_array = preprocess_leaf_image(image_path, target_size=(224, 224))
    predictions = leaf_model.predict(img_array)
    class_index = np.argmax(predictions)
    class_label = leaf_class_labels[class_index]
    return class_label

# Define a function to make predictions for disease detection
def predict_disease_class(image_path):
    img_array = preprocess_disease_image(image_path, target_size=(224, 224))
    predictions = disease_model.predict(img_array)
    class_index = np.argmax(predictions)
    class_label = disease_class_labels[class_index]
    return class_label

# Define a function to post-process the prediction for leaf identification
def post_process_leaf(class_label):
    return class_label == "Cucumber Leaves"

# Define a function to post-process the prediction for disease detection
def post_process_disease(class_label):
    if class_label == "Healthy leaves":
        return "Leaves are healthy."
    else:
        return f"Leaves have a disease."

@router.post("/cucumber_leaf", tags=['Function 3 - Leaf Identification & Disease'])
async def cucumber_leaf(file: UploadFile = File(...)):
    # Save the uploaded file
    uploaded_images_path = os.path.join(current_dir, "uploaded_images")
    filename = os.path.join(uploaded_images_path, file.filename)
    
    with open(filename, "wb") as buffer:
        buffer.write(file.file.read())

    # Get the class label for leaf identification
    leaf_class_label = predict_leaf_class(filename)

    # Initialize disease_class_label
    disease_class_label = None

    # Check if it's Cucumber Leaves
    if post_process_leaf(leaf_class_label):
        # If it is, run disease detection
        disease_class_label = predict_disease_class(filename)
        result = post_process_disease(disease_class_label)
    else:
        # If it's not, return a message
        result = "This is not Cucumber Leaves."
    
    # Delete the uploaded image
    os.remove(filename)

    # Return the result as JSON
    return JSONResponse(content={"result": result, "class_leaf": leaf_class_label, "class_disease": disease_class_label})
