module snn_neuron_8 
    #(
        parameter integer w_0  = 0,
        parameter integer w_1  = 0,
        parameter integer w_2  = 0,
        parameter integer w_3  = 0,
        parameter integer w_4  = 0,
        parameter integer w_5  = 0,
        parameter integer w_6  = 0,
        parameter integer w_7  = 0,
        parameter integer bias = 0,
        parameter integer v_th = 0
    )
    (
        input  clk,
        input  reset,
        input  sp_0,
        input  sp_1,
        input  sp_2,
        input  sp_3,
        input  sp_4,
        input  sp_5,
        input  sp_6,
        input  sp_7,
        input  neuron_reset,
        output reg spike_out
    );

    // Internal registers for partial sums (initialized to 0)
    reg signed [31:0] tmp_sum_0        = 0;
    reg signed [31:0] tmp_sum_1        = 0;
    reg signed [31:0] tmp_sum_2        = 0;
    reg signed [31:0] tmp_sum_3        = 0;
    reg signed [31:0] tmp_sum_4        = 0;
    reg signed [31:0] tmp_sum_5        = 0;
    reg signed [31:0] tmp_sum_6        = 0;
    reg signed [31:0] tmp_sum_7        = 0;
    
    reg signed [31:0] tmp_sum_0_b      = 0;
    reg signed [31:0] tmp_sum_01       = 0;
    reg signed [31:0] tmp_sum_23       = 0;
    reg signed [31:0] tmp_sum_45       = 0;
    reg signed [31:0] tmp_sum_67       = 0;
    reg signed [31:0] tmp_sum_0123     = 0;
    reg signed [31:0] tmp_sum_4567     = 0;
    reg signed [31:0] sum              = 0;
    
    reg signed [31:0] voltage          = 0;  // Membrane potential (accumulated sum)
    reg signed [31:0] v_temp           = 0;

    always @(posedge clk) begin
        // add corresponding weight if there is a spike 
        if (sp_0 == 1'b1)
            tmp_sum_0 <= w_0;
        else
            tmp_sum_0 <= 32'd0;

        if (sp_1 == 1'b1)
            tmp_sum_1 <= w_1;
        else
            tmp_sum_1 <= 32'd0;

        if (sp_2 == 1'b1)
            tmp_sum_2 <= w_2;
        else
            tmp_sum_2 <= 32'd0;

        if (sp_3 == 1'b1)
            tmp_sum_3 <= w_3;
        else
            tmp_sum_3 <= 32'd0;

        if (sp_4 == 1'b1)
            tmp_sum_4 <= w_4;
        else
            tmp_sum_4 <= 32'd0;

        if (sp_5 == 1'b1)
            tmp_sum_5 <= w_5;
        else
            tmp_sum_5 <= 32'd0;

        if (sp_6 == 1'b1)
            tmp_sum_6 <= w_6;
        else
            tmp_sum_6 <= 32'd0;
            
        if (sp_7 == 1'b1)
            tmp_sum_7 <= w_6;
        else
            tmp_sum_7 <= 32'd0;

        // adder tree: pairwise add the partial sums
        tmp_sum_0_b     <= bias      + tmp_sum_0;
        tmp_sum_01      <= tmp_sum_1 + tmp_sum_2;
        tmp_sum_23      <= tmp_sum_3 + tmp_sum_4;
        tmp_sum_45      <= tmp_sum_5 + tmp_sum_6;
        tmp_sum_67      <= tmp_sum_7;
        
        tmp_sum_0123    <= tmp_sum_0_b + tmp_sum_01;
        tmp_sum_4567    <= tmp_sum_23  + tmp_sum_45;
        
        sum             <= tmp_sum_0123 + tmp_sum_4567 + tmp_sum_67;

        // update membrane voltage and generate spikes
        v_temp = voltage + sum;
        
        // create spikes and reset voltage by subtraction when threshold is exceeded
        if (v_temp > v_th) begin
            v_temp    = v_temp - v_th;
            spike_out <= 1'b1;
        end else begin
            spike_out <= 1'b0;
        end
        
        // reset the accumulated voltage at frame boundaries
        if (neuron_reset == 1'b1) begin
            v_temp = 0;
        end
        voltage <= v_temp;
    end

endmodule
