module snn_rgb #(
  parameter integer NUM_INPUTS_HIDDEN = 3,
  parameter integer NUM_INPUTS_OUT    = 7
)(
    input  clk,                                 // 74.25 MHz input clock (video 720p)
    input  reset_n,                             // active-low reset
    input  [2:0] enable_in,                     // three slide switches (enable signals)
    // video input
    input  vs_in,                               // vertical sync in
    input  hs_in,                               // horizontal sync in
    input  de_in,                               // data enable (high for valid pixel)
    input  [7:0] r_in,                          // red pixel component
    input  [7:0] g_in,                          // green pixel component
    input  [7:0] b_in,                          // blue pixel component
    // video output
    output reg vs_out,                          // vertical sync out (delayed)
    output reg hs_out,                          // horizontal sync out (delayed)
    output reg de_out,                          // data enable out (delayed)
    output reg [7:0] r_out,                     // red output (full intensity or 0)
    output reg [7:0] g_out,                     // green output
    output reg [7:0] b_out,                     // blue output
    // other outputs
    output clk_o,                               // output clock (mirrors input clock)
    output [2:0] led                            // LEDs (not used in this design)
);

    // Internal signals
    reg        reset;
    reg        vs_0, hs_0, de_0;
    reg        vs_q, de_q;
    reg [7:0]  r_0, g_0, b_0;
    wire       vs_1, hs_1, de_1;
    wire       res_ly_1, res_ly_2;
    wire       r_sp, g_sp, b_sp;
    wire       h_0, h_1, h_2, h_3, h_4, h_5, h_6;
    wire       out_0, out_1;
    reg        frame_reset    = 1'b1;
    reg        neuron_reset   = 1'b1;
    reg [8:0]  step           = 9'd1;      // step counter (1 to 256)
    reg [7:0]  num_out0_sp    = 8'd0;      // count of spikes from output neuron 0
    reg [7:0]  num_out1_sp    = 8'd0;      // count of spikes from output neuron 1
    reg        r_out_1, g_out_1, b_out_1;  // single-bit signals for output color
    
    wire [6:0] spikes_out_ly_1;
    wire [1:0] spikes_out_ly_2;

    // Constants (matching VHDL constants)
    localparam integer sp_steps        = 64;   // number of timesteps per pixel evaluation
    localparam integer v_th            = 256;  // neuron voltage threshold
    localparam integer n_sp_to_activate= 23;   // spike count to classify as active
    localparam integer ltc_delay       = 11;   // latency delay (pipeline depth)
    localparam integer total_delay     = sp_steps + ltc_delay;  // overall delay (75 cycles)

    // Instantiate control module (delay alignment for video signals and resets)
    control #(
        .delay       (total_delay),
        .layer_delay (5)
    ) control_inst (
        .clk         (clk),
        .reset       (reset),
        .neuron_reset(neuron_reset),
        .vs_in       (vs_0),
        .hs_in       (hs_0),
        .de_in       (de_0),
        .res_ly_1    (res_ly_1),
        .res_ly_2    (res_ly_2),
        .vs_out      (vs_1),
        .hs_out      (hs_1),
        .de_out      (de_1)
    );

    // Instantiate pseudo-random spike generator for input RGB values
    gen_input gen_input_inst (
        .clk   (clk),
        .reset (frame_reset),
        .r_st  ({24'd0, r_0}),  // convert 8-bit r_0 to 32-bit for module
        .g_st  ({24'd0, g_0}),
        .b_st  ({24'd0, b_0}),
        .r_sp  (r_sp),
        .g_sp  (g_sp),
        .b_sp  (b_sp)
    );
    
  layer1 #(
    .NUM_INPUTS_HIDDEN (NUM_INPUTS_HIDDEN),
    .NUM_OUTPUTS       (7)
  ) layer1_01 (
    .clk               (clk),
    .reset             (reset),
    
    .neuron_reset      (res_ly_1),
    .spikes_in         ({b_sp, g_sp, r_sp}),
    
    .spikes_out        (spikes_out_ly_1)
  );

  layer2 #(
    .NUM_INPUTS_HIDDEN (7),
    .NUM_OUTPUTS       (2)
  ) layer2_01 (
    .clk               (clk),
    .reset             (reset),
    
    .neuron_reset      (res_ly_2),
    .spikes_in         (spikes_out_ly_1),
    
    .spikes_out        (spikes_out_ly_2)
  ); 
  
  assign out_0 = spikes_out_ly_2[0];
  assign out_1 = spikes_out_ly_2[1];


    // Sequential logic for input processing and output generation
    always @(posedge clk) begin
        // Synchronize and register inputs
        reset   <= ~reset_n;
        vs_0    <= vs_in;
        hs_0    <= hs_in;
        de_0    <= de_in;
        vs_q    <= vs_0;
        de_q    <= de_0;
        r_0     <= r_in;
        g_0     <= g_in;
        b_0     <= b_in;

        // Generate a frame reset pulse at the start of each frame (vertical sync rising edge)
        if (vs_0 == 1'b1 && vs_q == 1'b0) 
            frame_reset <= 1'b1;
        else 
            frame_reset <= 1'b0;

        // Step counter and neuron reset logic for pixel evaluation cycles
        if ((de_q == 1'b1 && de_1 == 1'b0) || (de_0 == 1'b1 && step >= sp_steps)) begin
            step         <= 9'd1;
            neuron_reset <= 1'b1;
        end else if (de_0 == 1'b1) begin
            step         <= step + 1'd1;
            neuron_reset <= 1'b0;
        end else begin
            step         <= 9'd1;
            neuron_reset <= 1'b0;
        end

        // Count spikes from output neurons during evaluation
        if (out_0 == 1'b1) 
            num_out0_sp <= num_out0_sp + 8'd1;
        if (out_1 == 1'b1) 
            num_out1_sp <= num_out1_sp + 8'd1;

        // Determine output color once the second layer resets (end of pixel evaluation)
        if (res_ly_2 == 1'b1) begin
            if (num_out0_sp >= n_sp_to_activate) begin
                r_out_1 <= 1'b1;   // output blue (for crosswalk detected)
                g_out_1 <= 1'b0;
                b_out_1 <= 1'b0;
            end else if (num_out1_sp >= n_sp_to_activate) begin
                r_out_1 <= 1'b0;
                g_out_1 <= 1'b1;   // output green (for road detected)
                b_out_1 <= 1'b0;
            end else begin
                r_out_1 <= 1'b0;
                g_out_1 <= 1'b0;
                b_out_1 <= 1'b0;   // output black (no detection)
            end
            // Reset spike counters for next pixel
            num_out0_sp <= 8'd0;
            num_out1_sp <= 8'd0;
        end

        // Register outputs (one-cycle delayed output signals)
        vs_out <= vs_1;
        hs_out <= hs_1;
        de_out <= de_1;
        // Set output pixel color (replicate single-bit signals across 8-bit channels)
        r_out  <= {8{r_out_1}};
        g_out  <= {8{g_out_1}};
        b_out  <= {8{b_out_1}};
    end

    // Continuous outputs
    assign clk_o = clk;
    assign led   = 3'b000;

endmodule
