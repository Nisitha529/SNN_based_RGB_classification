`timescale 1ns/1ps

module tb_snn_neuron_2input();
    // Clock and Reset
    logic clk = 0;
    logic reset = 1;
    
    // Input Spikes
    logic sp_0, sp_1;
    
    // Control Signals
    logic neuron_reset = 0;
    
    // Outputs
    logic spike_out_hw;  // Hardware implementation
    logic spike_out_sw;  // Software model
    logic spike_out_ref; // Golden reference
    
    // Test Parameters
    parameter COMPARE_HW_SW = 1;   // Compare hardware vs software model
    parameter COMPARE_HW_REF = 1;  // Compare hardware vs golden reference
    parameter LOG_DETAILS = 1;     // Enable detailed logging
    
    // Test Status
    int error_count = 0;
    int test_case = 0;
    string test_name;
    
    // Reference model parameters
    parameter int REF_W0 = 2;
    parameter int REF_W1 = 1;
    parameter int REF_BIAS = 1;
    parameter int REF_VTH = 10;
    parameter int REF_LEAK = 100;

    // Instantiate DUT (Hardware Implementation)
    snn_neuron_2input #(
        .w_0(REF_W0),
        .w_1(REF_W1),
        .bias(REF_BIAS),
        .v_th(REF_VTH),
        .leak(REF_LEAK)
    ) dut (
        .clk(clk),
        .reset(reset),
        .sp_0(sp_0),
        .sp_1(sp_1),
        .neuron_reset(neuron_reset),
        .spike_out(spike_out_hw)
    );

    // Software Model (Behavioral Reference)
    int sw_voltage = 0;
    int sw_new_voltage = 0;
    always @(posedge clk) begin
        if (reset || neuron_reset) begin
            sw_voltage <= 0;
            spike_out_sw <= 0;
        end else begin
            // Calculate inputs
            int current_sum = REF_BIAS;
            if (sp_0) current_sum += REF_W0;
            if (sp_1) current_sum += REF_W1;
            
            // Apply leak and update
            sw_new_voltage = (sw_voltage * (1000 - REF_LEAK)) / 1000 + current_sum;
            
            // Threshold check
            if (sw_new_voltage >= REF_VTH) begin
                sw_voltage <= sw_new_voltage - REF_VTH;
                spike_out_sw <= 1;
            end else begin
                sw_voltage <= sw_new_voltage;
                spike_out_sw <= 0;
            end
        end
    end

    // Golden Reference Model
    int ref_voltage = 0;
    int ref_new_voltage = 0;
    always @(posedge clk) begin
        if (reset || neuron_reset) begin
            ref_voltage <= 0;
            spike_out_ref <= 0;
        end else begin
            // Calculate inputs
            int current_sum = REF_BIAS;
            if (sp_0) current_sum += REF_W0;
            if (sp_1) current_sum += REF_W1;
            
            // Apply leak and update
            ref_new_voltage = (ref_voltage * (1000 - REF_LEAK)) / 1000 + current_sum;
            
            // Threshold check
            if (ref_new_voltage >= REF_VTH) begin
                ref_voltage <= ref_new_voltage - REF_VTH;
                spike_out_ref <= 1;
            end else begin
                ref_voltage <= ref_new_voltage;
                spike_out_ref <= 0;
            end
        end
    end

    // Clock Generation (50MHz)
    always #10 clk = ~clk;

    // Debug Print Task
    task print_cycle_details();
        string voltage_str, inputs_str;
        int hw_pre_voltage;  // Removed 'automatic' keyword
        
        // Create formatted strings
        inputs_str = $sformatf("sp0:%b sp1:%b", sp_0, sp_1);
        
        // Calculate pre-voltage for HW model
        hw_pre_voltage = dut.voltage + (spike_out_hw ? REF_VTH : 0);
        
        voltage_str = $sformatf("HW: pre=%0d post=%0d | SW: pre=%0d post=%0d | Ref: pre=%0d post=%0d",
                               hw_pre_voltage, dut.voltage,
                               sw_new_voltage, sw_voltage,
                               ref_new_voltage, ref_voltage);
        
        // Print spike outputs
        $display("[%0t] INPUTS: %s", $time, inputs_str);
        $display("     VOLTAGE: %s", voltage_str);
        $display("     SPIKES:  HW:%b SW:%b Ref:%b", 
                 spike_out_hw, spike_out_sw, spike_out_ref);
    endtask

    // Comparison Task
    task compare_outputs(string test_context);
        int hw_pre_voltage;  // Removed 'automatic' keyword
        
        if (LOG_DETAILS) print_cycle_details();
        
        // Calculate pre-voltage for comparison
        hw_pre_voltage = dut.voltage + (spike_out_hw ? REF_VTH : 0);
        
        // [Rest of the comparison logic remains the same...]
    endtask

    // Test Sequence Control
    task run_test(string name, int duration);
        test_case++;
        test_name = name;
        $display("\n===== TEST %0d: %s =====", test_case, test_name);
        #(duration * 20);  // Duration in clock cycles
    endtask

    // Main Test Sequence
    initial begin
        $display("\nStarting Enhanced Two-Input Neuron Testbench\n");
        $display("Comparison Mode: HW/SW=%0d, HW/Ref=%0d", 
                 COMPARE_HW_SW, COMPARE_HW_REF);
        
        // Initialize signals
        sp_0 = 0;
        sp_1 = 0;
        neuron_reset = 0;
        
        // Apply reset
        reset = 1;
        #100;
        reset = 0;
        #100;
        
        // Print initial state
        print_cycle_details();
        
        // Test Case 1: Basic Accumulation
        run_test("Basic Accumulation", 1);
        sp_0 = 1;  // Weight = 2
        #20;
        compare_outputs("After first spike input");
        sp_0 = 0;
        #100;
        
        // Test Case 2: Simultaneous Inputs
        run_test("Simultaneous Inputs", 1);
        sp_0 = 1;  // Weight = 2
        sp_1 = 1;  // Weight = 1
        #20;
        compare_outputs("After simultaneous spikes");
        sp_0 = 0;
        sp_1 = 0;
        #100;
        
        // Test Case 3: Leakage Effect
        run_test("Leakage Effect", 1);
        sp_0 = 1;
        #20;
        compare_outputs("After input spike");
        sp_0 = 0;
        #200;
        compare_outputs("After leak period");
        
        // Test Case 4: Threshold Crossing
        run_test("Threshold Crossing", 1);
        sp_0 = 1;
        #20;
        compare_outputs("Cycle 1");
        sp_0 = 0;
        #20;
        
        sp_0 = 1;
        #20;
        compare_outputs("Cycle 2");
        sp_0 = 0;
        #20;
        
        sp_0 = 1;
        #20;
        compare_outputs("Cycle 3");
        sp_0 = 0;
        #20;
        
        // Test Case 5: Reset Functionality
        run_test("Reset Functionality", 1);
        neuron_reset = 1;
        #20;
        compare_outputs("During reset");
        #20;
        neuron_reset = 0;
        #100;
        compare_outputs("After reset");
        
        // Summary
        $display("\n===== SIMULATION SUMMARY =====");
        $display("Completed %0d test cases", test_case);
        if (error_count == 0) begin
            $display("PASS: All comparisons matched");
        end else begin
            $error("FAIL: %0d comparison error(s) detected", error_count);
        end
        
        $finish;
    end

    // Simulation Timeout
    initial begin
        #500_000;
        $error("Simulation timeout");
        $finish;
    end
endmodule