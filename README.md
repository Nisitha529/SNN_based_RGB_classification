# SNN based RGB classification
This project implements a Spiking Neural Network (SNN) on an FPGA for RGB image processing. The system processes incoming images pixel-by-pixel, converting RGB values into spike trains that are classified by a two-layer neural network. The output is a color-coded video stream where detected patterns are highlighted in specific colors, making it suitable for applications such as road and crosswalk detection in automotive systems.

## Module Overview
### snn_rgb (Top Module)
The main top-level module integrates all system components and manages the video processing pipeline. It handles video signal synchronization, coordinates the neural network evaluation cycles, and generates the final color-coded output.

### neuron_1 (Neuron Model)
Implements a leaky integrate-and-fire (LIF) spiking neuron with configurable parameters. The neuron processes input spikes through a two-stage pipeline that calculates weighted sums and updates the membrane potential. When the voltage exceeds the threshold, a output spike is generated and the potential is reset by subtracting the threshold value.

### layer1 (First Neural Layer)
Contains seven neurons that process the three RGB input spikes into intermediate representations. Each neuron has predefined weights and biases optimized for feature extraction from the color input signals. This layer serves as the hidden layer in the network architecture.

### layer2 (Second Neural Layer)
Consists of two output neurons that receive spikes from the first layer and produce the final classification decisions. The weights and biases in this layer are tuned to distinguish between the target patterns.

### gen_input (Spike Generator)
Converts RGB pixel values into probabilistic spike trains using a pseudo-random number generator (LFSR). The probability of spike generation is proportional to the pixel intensity value, creating a rate-based encoding of the input video data.

### control (Control Unit)
Manages timing and synchronization across the system using configurable delay lines. This module ensures proper alignment of data signals with neural network processing and generates synchronized reset signals for both network layers.

### tb_snn_rgb (Testbench)
Provides verification capabilities for the complete system through file-based testing. The testbench reads input images in PPM format, applies appropriate video timing signals, and captures the output results to verify functionality against expected behavior.

## SNN Output
![SNN Output](.results_img_dir/snn-out.png)

