import os
import subprocess

# Define paths
test_file_path = './datasets/VOCDevkit/VOC2007/ImageSets/Main/test.txt'
jpeg_images_path = './datasets/VOCDevkit/VOC2007/JPEGImages'
onnx_model_path = '../../yolox_s.onnx'
output_path = '../../ONNX_Outputs/yolox_s'
input_shape = '640,640'
score_threshold = '0.3'

# Read the test file
with open(test_file_path, 'r') as file:
    lines = file.readlines()

# Process each line
for line in lines:
    image_name = line.strip() + '.jpg'
    image_path = os.path.join(jpeg_images_path, image_name)
    
    if os.path.exists(image_path):
        # Construct the command
        command = [
            'python', 'onnx_inference.py',
            '-m', onnx_model_path,
            '-i', image_path,
            '-o', output_path,
            '-s', score_threshold,
            '--input_shape', input_shape
        ]
        
        # Run the command
        subprocess.run(command)
    else:
        print(f"Image {image_path} does not exist.")