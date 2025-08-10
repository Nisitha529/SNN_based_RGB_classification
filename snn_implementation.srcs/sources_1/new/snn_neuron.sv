module neuron_1 
    #(
        parameter NUM_INPUTS = 8,            
        parameter signed [31:0] WEIGHTS [8] = '{8{0}}, 
        parameter signed [31:0] BIAS = 0,    
        parameter signed [31:0] V_TH = 0     
    )
    (
        input  clk,
        input  reset,
        input  [NUM_INPUTS - 1 :0] spikes_i,
        input  neuron_reset,
        output reg spike_out
    );
    
    // Internal registers
    reg signed [31:0] voltage = 0;
    reg signed [31:0] weighted_sum[1:0];
    reg signed [31:0] total_input;
    reg signed [31:0] new_voltage;
    
    // Pipeline stage 1: Input weighting
    always @(posedge clk) begin
        // First group (inputs 0-3)
        weighted_sum[0] <= 
            (0 < NUM_INPUTS && spikes_i[0] ? WEIGHTS[0] : 32'd0) +
            (1 < NUM_INPUTS && spikes_i[1] ? WEIGHTS[1] : 32'd0) +
            (2 < NUM_INPUTS && spikes_i[2] ? WEIGHTS[2] : 32'd0) +
            (3 < NUM_INPUTS && spikes_i[3] ? WEIGHTS[3] : 32'd0);
        
        // Second group (inputs 4-7)
        weighted_sum[1] <= 
            (4 < NUM_INPUTS && spikes_i[4] ? WEIGHTS[4] : 32'd0) +
            (5 < NUM_INPUTS && spikes_i[5] ? WEIGHTS[5] : 32'd0) +
            (6 < NUM_INPUTS && spikes_i[6] ? WEIGHTS[6] : 32'd0) +
            (7 < NUM_INPUTS && spikes_i[7] ? WEIGHTS[7] : 32'd0);
    end

    // Pipeline stage 2: Summation and voltage update
    always @(posedge clk) begin
        if (reset || neuron_reset) begin
            voltage      <= 0;
            spike_out    <= 0;
        end else begin
            // Calculate total input (sum of groups + bias)
            total_input   = weighted_sum[0] + weighted_sum[1] + BIAS;
            new_voltage   = voltage + total_input;
            
            // Threshold check and spike generation
            if (new_voltage >= V_TH) begin
                voltage   <= new_voltage - V_TH;
                spike_out <= 1'b1;
            end else begin
                voltage   <= new_voltage;
                spike_out <= 1'b0;
            end
        end
    end
endmodule