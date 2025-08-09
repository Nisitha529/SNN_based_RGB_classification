`timescale 1ns / 1ps

module layer1 #(
  parameter NUM_INPUTS_HIDDEN = 3,
  parameter NUM_OUTPUTS       = 7
)(
  input                             clk,
  input                             reset,
  
  input                             neuron_reset,
  input  [NUM_INPUTS_HIDDEN - 1:0]  spikes_in,
  
  output [NUM_OUTPUTS - 1:0]        spikes_out
);

  localparam integer v_th            = 256;

  neuron_1 #(
    .NUM_INPUTS   (NUM_INPUTS_HIDDEN),
    .WEIGHTS      ({-1,  10, 103,8'd0, 8'd0, 8'd0, 8'd0, 8'd0}),
    .BIAS         (-79),
    .V_TH         (v_th)
  ) hidden0_inst(
    .clk          (clk), 
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[0])
  );
  
  neuron_1 #(
    .NUM_INPUTS   (NUM_INPUTS_HIDDEN),
    .WEIGHTS      ({-74, -75, -131,8'd0, 8'd0, 8'd0, 8'd0, 8'd0}),
    .BIAS         (27),
    .V_TH         (v_th)
  ) hidden1_inst(
    .clk          (clk), 
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[1])
  );
  
  neuron_1 #(
    .NUM_INPUTS   (NUM_INPUTS_HIDDEN),
    .WEIGHTS      ({-113, -184, -208,8'd0, 8'd0, 8'd0, 8'd0, 8'd0}),
    .BIAS         (210),
    .V_TH         (v_th)
  ) hidden2_inst(
    .clk          (clk), 
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[2])
  );
  
  neuron_1 #(
    .NUM_INPUTS   (NUM_INPUTS_HIDDEN),
    .WEIGHTS      ({83, 47, -79,8'd0, 8'd0, 8'd0, 8'd0, 8'd0}),
    .BIAS         (-43),
    .V_TH         (v_th)
  ) hidden3_inst(
    .clk          (clk), 
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[3])
  );
  
  neuron_1 #(
    .NUM_INPUTS   (NUM_INPUTS_HIDDEN),
    .WEIGHTS      ({11, 74, -61,8'd0, 8'd0, 8'd0, 8'd0, 8'd0}),
    .BIAS         (-42),
    .V_TH         (v_th)
  ) hidden4_inst(
    .clk          (clk), 
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[4])
  );
  
  neuron_1 #(
    .NUM_INPUTS   (NUM_INPUTS_HIDDEN),
    .WEIGHTS      ({46, -13, 61,8'd0, 8'd0, 8'd0, 8'd0, 8'd0}),
    .BIAS         (-78),
    .V_TH         (v_th)
  ) hidden5_inst(
    .clk          (clk), 
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[5])
  );
  
  neuron_1 #(
    .NUM_INPUTS   (NUM_INPUTS_HIDDEN),
    .WEIGHTS      ({125, 179, 168,8'd0, 8'd0, 8'd0, 8'd0, 8'd0}),
    .BIAS         (-216),
    .V_TH         (v_th)
  ) hidden6_inst(
    .clk          (clk), 
    .reset        (reset),
    
    .spikes_i     (spikes_in),
    .neuron_reset (neuron_reset),
    
    .spike_out    (spikes_out[6])
  );
  
endmodule
