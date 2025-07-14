module control 
    #(
        parameter delay       = 5,           // equivalent to VHDL generic "delay"
        parameter layer_delay = 75  // equivalent to VHDL generic "layer_delay"
    )
    (
        input  clk,
        input  reset,
        input  neuron_reset,
        input  vs_in,
        input  hs_in,
        input  de_in,
        output res_ly_1,
        output res_ly_2,
        output vs_out,
        output hs_out,
        output de_out
    );

    // Shift register arrays (delay lines) for video signals and layer resets
    reg [delay-1:0]       vs_delay;
    reg [delay-1:0]       hs_delay;
    reg [delay-1:0]       de_delay;
    reg [layer_delay-1:0] ly1_delay;
    reg [2*layer_delay-1:0] ly2_delay;

    integer i, j, k;
    always @(posedge clk) begin
        // Load current inputs into the first stage of delay lines
        vs_delay[0]    <= vs_in;
        hs_delay[0]    <= hs_in;
        de_delay[0]    <= de_in;
        ly1_delay[0]   <= neuron_reset;
        ly2_delay[0]   <= neuron_reset;

        // Delay video signals according to the generic "delay"
        for (i = 1; i < delay; i = i + 1) begin
            vs_delay[i] <= vs_delay[i-1];
            hs_delay[i] <= hs_delay[i-1];
            de_delay[i] <= de_delay[i-1];
        end

        // Delay reset signal for layer 1
        for (j = 1; j < layer_delay; j = j + 1) begin
            ly1_delay[j] <= ly1_delay[j-1];
        end

        // Delay reset signal for layer 2 (twice the length of layer 1 delay)
        for (k = 1; k < 2*layer_delay; k = k + 1) begin
            ly2_delay[k] <= ly2_delay[k-1];
        end
    end

    // The last values of the delay lines drive the outputs
    assign vs_out   = vs_delay[delay-1];
    assign hs_out   = hs_delay[delay-1];
    assign de_out   = de_delay[delay-1];
    assign res_ly_1 = ly1_delay[layer_delay-1];
    assign res_ly_2 = ly2_delay[2*layer_delay-1];

endmodule
