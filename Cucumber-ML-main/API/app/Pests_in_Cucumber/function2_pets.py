from fastapi import APIRouter, File, UploadFile, HTTPException, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import os
import shutil
import subprocess
import uuid  # Added import for generating unique filenames

router = APIRouter()

# Get the directory of the current script
current_dir = os.path.dirname(os.path.abspath(__file__))

# Load the trained model
model_path = os.path.join(current_dir, 'weights', 'best_yolov7_weights.pt')

# Function 2 - YOLOv7
class YOLOv7Input(BaseModel):
    image: UploadFile

@router.post("/cucumber_with_pests", tags=['Function 2 - Cucumber with Pests - YOLOv7'])
async def cucumber_with_pests(
    image: UploadFile = File(...),
    confidence: float = Form(0.1),
):
    try:
        # Use a fixed filename for the uploaded image
        fixed_filename = "uploaded_image" + os.path.splitext(image.filename)[1]  # Keep the extension
        uploaded_images_path = os.path.join(current_dir, "uploaded_images")
        os.makedirs(uploaded_images_path, exist_ok=True)
        image_path = os.path.join(uploaded_images_path, fixed_filename)
        
        # Save the uploaded image with the fixed filename
        with open(image_path, "wb") as image_file:
            shutil.copyfileobj(image.file, image_file)

        detect_script_path = os.path.join(current_dir, 'detect.py')
        absolute_model_path = os.path.abspath(model_path)
        absolute_image_path = os.path.abspath(image_path)

        process = subprocess.run([
            "python", detect_script_path,
            "--weights", absolute_model_path,
            "--img-size", "640",
            "--conf", str(confidence),
            "--source", absolute_image_path,
            "--device", "cpu"
        ], capture_output=True, text=True, cwd=current_dir)

        # Check if the command failed
        if process.returncode != 0:
            raise HTTPException(status_code=500, detail=f"Error processing the file: {process.stderr}")

        # Parse the output results
        results = []
        for line in process.stdout.split('\n'):
            if line.startswith("Predicted class:"):
                parts = line.split(", Confidence: ")
                if len(parts) == 2:
                    predicted_class = parts[0].replace("Predicted class: ", "").strip()
                    confidence = float(parts[1])
                    results.append({"predicted_class": predicted_class, "confidence": confidence})

        # Provide the organized output results and image path
        output = {
            "results": results,
            "image_path": image_path,
            "message": "Objects detected!" if results else "Unable to detect pests!"
        }

        return output

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing the file: {str(e)}")
