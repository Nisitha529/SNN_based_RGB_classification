`timescale 1ns / 1ps

module layer2 #(
  parameter NUM_INPUTS  = 7,
  parameter NUM_OUTPUTS = 2
)(
  input                      clk,
  input                      reset,
  
  input                      neuron_reset,
  input  [NUM_INPUTS - 1:0]  spikes_in,
  
  output [NUM_OUTPUTS - 1:0] spikes_out
);

  localparam integer v_th            = 256;

  neuron_1 #(
    .NUM_INPUTS   (7),
    .WEIGHTS      ({42, -222, 13, 2, 60, -101, 316, 8'd0}),
    .BIAS         (-59),
    .V_TH         (v_th)
  ) output0_inst (
    .clk          (clk),
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[0])
  );  
  
  neuron_1 #(
    .NUM_INPUTS   (7),
    .WEIGHTS      ({-88, 8, -423, 82, -59, 16, -346, 8'd0}),
    .BIAS         (155),
    .V_TH         (v_th)
  ) output1_inst (
    .clk          (clk),
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[1])
  );  


endmodule
