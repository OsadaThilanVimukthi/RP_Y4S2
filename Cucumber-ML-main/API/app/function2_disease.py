from fastapi import FastAPI, File, UploadFile, APIRouter
from fastapi.responses import JSONResponse
import numpy as np
from tensorflow import keras
from keras.applications.vgg16 import preprocess_input
from keras.preprocessing import image
import os
from PIL import Image
import torch
from torchvision import transforms
import torch.nn as nn

router = APIRouter()

# Get the directory of the current script
current_dir = os.path.dirname(os.path.abspath(__file__))

# Class labels for the second model
class_labels_fun2 = ["Belly Rot", "Fresh Cucumber"]

# Define the class names for the first model
class_names_fun1 = ['Bean', 'Bitter_Gourd', 'Bottle_Gourd', 'Brinjal', 'Broccoli', 'Cabbage', 'Capsicum', 
                    'Carrot', 'Cauliflower', 'Cucumber', 'Papaya', 'Potato', 'Pumpkin', 'Radish', 'Tomato']

VGG_types = {
    "VGG16": [
        64,
        64,
        "M",
        128,
        128,
        "M",
        256,
        256,
        256,
        "M",
        512,
        512,
        512,
        "M",
        512,
        512,
        512,
        "M",
    ],
}

class VGG_net(nn.Module):
    def __init__(self, input_channels, num_classes=2):
        super(VGG_net, self).__init__()
        self.in_channels = input_channels
        self.conv_layers = self.create_conv_layers(VGG_types['VGG16'])  # create our conv layers
        self.fcs = nn.Sequential(
            nn.Linear(512 * 7 * 7, 4096),
            nn.ReLU(),
            nn.Dropout(p=0.5),
            nn.Linear(4096, 4096),
            nn.ReLU(),
            nn.Dropout(p=0.5),
            nn.Linear(4096, num_classes)  # sizeInputImage = 224, divided by num Maxpool : 224 / 2⁷ = 7
        )

    def forward(self, x):
        x = self.conv_layers(x)
        x = x.reshape(x.shape[0], -1)  # flatten our convlayers
        x = self.fcs(x)
        return x

    def create_conv_layers(self, architecture):
        layers = []
        in_channels = self.in_channels
        for layer in architecture:
            if type(layer) is int:
                out_channels = layer
                layers += [nn.Conv2d(in_channels=in_channels, out_channels=out_channels,
                                    kernel_size=(3, 3), stride=(1, 1), padding=(1, 1)),
                            nn.BatchNorm2d(layer),
                            nn.ReLU()]
                in_channels = layer  # for the next iteration
            elif layer == 'M':
                layers += [nn.MaxPool2d(kernel_size=(2, 2), stride=(2, 2))]
        return nn.Sequential(*layers,)

# Load the first model (Function 1)
model_path_fun1 = os.path.join(current_dir, './src/fun2/VGG16_torch_model_46.pt')
model_fun1 = VGG_net(input_channels=3, num_classes=len(class_names_fun1))
model_fun1.load_state_dict(torch.load(model_path_fun1, map_location=torch.device('cpu')))
model_fun1.eval()

# Load the second model (Function 2)
disease_model_path = os.path.join(current_dir, "./src/fun2/best_model_v3.h5")
model_fun2 = keras.models.load_model(disease_model_path)

# Load and preprocess the input image
def preprocess_image(image_path, target_size):
    img = image.load_img(image_path, target_size=target_size)
    img_array = image.img_to_array(img)
    img_array = preprocess_input(img_array)
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

# Define a function to make predictions
def predict_class(image_path):
    img_array = preprocess_image(image_path, target_size=(224, 224))
    predictions = model_fun2.predict(img_array)
    class_index = np.argmax(predictions)
    class_label = class_labels_fun2[class_index]
    return class_label


# Define the transformation for input images for the first model
data_transform_fun1 = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
])

# Function to predict using the first model
def predict_image_fun1(image_path):
    try:
        image = Image.open(image_path)
        image_tensor = data_transform_fun1(image).unsqueeze(0)

        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        image_tensor = image_tensor.to(device)

        with torch.no_grad():
            model_fun1.eval()
            output = model_fun1(image_tensor)

        _, predicted_class = torch.max(output, 1)
        raw_predictions = output.squeeze().tolist()

        if raw_predictions[class_names_fun1.index('Cucumber')] > 0.7:
            return {
                'predicted_class': 'Cucumber',
            }
        else:
            return {
                'predicted_class': class_names_fun1[predicted_class.item()],
            }

    except Exception as e:
        return {
            'error': str(e)
        }

# Function to post-process the prediction from the first model
def post_process_fun1(prediction_result):
    if prediction_result['predicted_class'] == 'Cucumber':
        return "This is Cucumber"
    else:
        return "This is not Cucumber."

# Function to post-process the prediction from the second model
def post_process_fun2(class_label):
    if class_label == "Fresh Cucumber":
        return "The cucumber is healthy."
    else:
        return "The cucumber has a disease."

@router.post("/cucumber_disease", tags=['Function 2 - Cucumber Disease'])
async def cucumber_disease(file: UploadFile = File(...)):
    # Save the uploaded file
    uploaded_images_path = os.path.join(current_dir, "uploaded_images")
    filename = os.path.join(uploaded_images_path, file.filename)
    
    with open(filename, "wb") as buffer:
        buffer.write(file.file.read())

    # Get the prediction from the first model
    prediction_result_fun1 = predict_image_fun1(filename)

    # Check if the first model predicts Cucumber
    if prediction_result_fun1['predicted_class'] == 'Cucumber':
        # Use the existing prediction logic (Function 2)
        class_label_fun2 = predict_class(filename)

        # Check if it is "Belly Rot" or "Fresh Cucumber"
        if class_label_fun2 == "Fresh Cucumber":
            result = "The cucumber is healthy."
        else:
            result = "The cucumber has a disease."
    else:
        # Use the prediction from the first model
        result = "This is not Cucumber."
        # Set class to 'Other' when the image is not detected as 'Cucumber'
        class_label_fun2 = "Other"

    # Delete the uploaded image
    os.remove(filename)

    # Return the result as JSON
    return JSONResponse(content={"result": result, "class": class_label_fun2})
