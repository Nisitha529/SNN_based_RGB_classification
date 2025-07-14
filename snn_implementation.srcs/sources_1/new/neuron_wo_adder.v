module neuron
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

    // Grouped partial sums
    reg signed [31:0] partial_sum_0_3;
    reg signed [31:0] partial_sum_4_7;
    reg signed [31:0] total_input;
    
    // Membrane potential
    reg signed [31:0] voltage = 0;

    // First pipeline stage: Input grouping
    always @(posedge clk) begin
        partial_sum_0_3 <= (sp_0 ? w_0 : 0) + 
                           (sp_1 ? w_1 : 0) + 
                           (sp_2 ? w_2 : 0) + 
                           (sp_3 ? w_3 : 0);
                           
        partial_sum_4_7 <= (sp_4 ? w_4 : 0) + 
                           (sp_5 ? w_5 : 0) + 
                           (sp_6 ? w_6 : 0) + 
                           (sp_7 ? w_7 : 0);  // Fixed w_6 -> w_7
    end

    // Second pipeline stage: Sum computation and voltage update
    always @(posedge clk) begin
        // Compute total input
        total_input <= partial_sum_0_3 + partial_sum_4_7 + bias;
        
        // Reset handling
        if (reset || neuron_reset) begin
            voltage <= 0;
            spike_out <= 0;
        end 
        else begin
            // Voltage update
            voltage <= voltage + total_input;
            
            // Spike generation with threshold reset
            if (voltage + total_input >= v_th) begin
                voltage <= voltage + total_input - v_th;
                spike_out <= 1;
            end else begin
                spike_out <= 0;
            end
        end
    end

endmodule