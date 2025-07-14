module gen_input (
    input        clk,
    input        reset,
    input  [31:0] r_st,   // 8-bit value (0–255 range) treated as 32-bit integer
    input  [31:0] g_st,   // 8-bit value (0–255 range) treated as 32-bit integer
    input  [31:0] b_st,   // 8-bit value (0–255 range) treated as 32-bit integer
    output reg   r_sp,
    output reg   g_sp,
    output reg   b_sp
);

    // Pseudo-random number generator (8-bit LFSR)
    reg [7:0] random = 8'b00000001;

    always @(posedge clk) begin
        // Initialization after reset
        if (reset == 1'b1) begin
            random <= 8'b00000001;
        end 
        else begin
            // LFSR of 8th order: generate next pseudo-random value
            random[0]     <= random[7] ^ random[5] ^ random[4] ^ random[3];
            random[7:1]   <= random[6:0];
        end

        // Initiate spikes for R, G, and B based on thresholds
        if (random < r_st[7:0])   // compare 8-bit random to r_st (0–255)
            r_sp <= 1'b1;
        else
            r_sp <= 1'b0;

        if (random < g_st[7:0])
            g_sp <= 1'b1;
        else
            g_sp <= 1'b0;

        if (random < b_st[7:0])
            b_sp <= 1'b1;
        else
            b_sp <= 1'b0;
    end

endmodule
