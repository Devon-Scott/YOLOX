#!/bin/bash

# Define paths
model="s"
testFilePath="./datasets/VOCDevkit/Tests/ImageSets/Main/test.txt"
jpegImagesPath="./datasets/VOCDevkit/Tests/JPEGImages"
onnxModelPath="./yolox_${model}.onnx"
outputPath="./ONNX_Outputs/yolox_${model}"
inputShape="640,640"
scoreThreshold="0.3"

# Check for model-specific paths and input shapes
if [ "$model" == "nano" ]; then
    jpegImagesPath="../../datasets/VOCDevkit/Tests/JPEGImages_small"
    inputShape="416,416"
fi

# Change directory to YOLOX/demo/ONNXRuntime
cd demo/ONNXRuntime || exit

# Initialize variables for calculating average inference time
total_time=0
count=0

# Read the test file
while IFS= read -r line; do
    imageName="${line}.jpg"
    imagePath="${jpegImagesPath}/${imageName}"
    
    if [ -f "$imagePath" ]; then
        # Construct the command
        command="python onnx_inference.py -m $onnxModelPath -i $imagePath -o $outputPath -s $scoreThreshold --input_shape $inputShape"
        
        # Run the command and capture the output
        output=$(eval $command)
        
        # Extract the inference time from the output
        if [[ $output =~ Model\ inference\ time:\ ([0-9]+\.[0-9]+)\ ms ]]; then
            inference_time=${BASH_REMATCH[1]}
            total_time=$(echo "$total_time + $inference_time" | bc)
            count=$((count + 1))
        fi
    else
        echo "Image $imagePath does not exist."
    fi
done < "$testFilePath"

# Calculate and print the average inference time
if [ $count -gt 0 ]; then
    average_time=$(echo "scale=2; $total_time / $count" | bc)
    echo "Average inference time: $average_time ms"
else
    echo "No valid inference times captured."
fi

# Change back to the original directory
cd ../../