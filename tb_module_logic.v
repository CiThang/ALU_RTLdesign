`timescale 1ns / 1ps
`include "module_logic.v"
module tb_module_logic;

    // Define the WIDTH parameter for the testbench and the DUT
    parameter WIDTH = 32;

    // Inputs to the DUT (Device Under Test)
    reg [WIDTH - 1:0] alu_a;
    reg [WIDTH - 1:0] alu_b;
    reg [4:0]         alu_op; // Keeping 5 bits for alu_op as in your original module

    // Output from the DUT
    wire [WIDTH - 1:0] alu_result;

    // Localparams for operations (matching your original values, adjusted for 5-bit alu_op if needed, otherwise this is fine)
    // IMPORTANT: Make sure these match the ones inside your module_logic
    localparam gAND             = 5'b00001; // Changed to 5-bit to match alu_op width
    localparam gOR              = 5'b00010;
    localparam gNOT             = 5'b00011;
    localparam gXOR             = 5'b00100;
    localparam gNAND            = 5'b00101;
    localparam gNOR             = 5'b00110;

    localparam SHIFT_RIGHT      = 5'b00111;
    localparam SHIFT_RIGHT_ARITH= 5'b01000;
    localparam SHIFT_LEFT       = 5'b01001;

    localparam COMPARE          = 5'b01010;
    localparam BIGGER           = 5'b01011;
    localparam SMALLER          = 5'b01100;

    // Instantiate the Device Under Test (DUT)
    module_logic #(
        .WIDTH(WIDTH)
    ) dut (
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_op(alu_op),
        .alu_result(alu_result)
    );

    initial begin
        $dumpfile("tb_module_logic.vcd");
        $dumpvars(0, tb_module_logic);
    end


    // Initial block for test scenarios
    initial begin
        // Initialize inputs
        alu_a = 0;
        alu_b = 0;
        alu_op = 0;

        $display("--------------------------------------");
        $display("Starting module_logic Testbench");
        $display("Time | alu_a      | alu_b      | alu_op | alu_result");
        $display("--------------------------------------");

        // Test AND operation
        alu_a = 32'hAAAA_AAAA; // 1010...1010
        alu_b = 32'hFFFF_0000; // 1111...0000
        alu_op = gAND;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: alu_a & alu_b = 32'hAAAA_0000

        // Test OR operation
        alu_a = 32'hAAAA_AAAA;
        alu_b = 32'hFFFF_0000;
        alu_op = gOR;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: alu_a | alu_b = 32'hFFFF_AAAA

        // Test NOT operation
        alu_a = 32'hF0F0_F0F0;
        alu_b = 0; // Not used
        alu_op = gNOT;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: ~alu_a = 32'h0F0F_0F0F

        // Test XOR operation
        alu_a = 32'h1234_5678;
        alu_b = 32'h8765_4321;
        alu_op = gXOR;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: alu_a ^ alu_b = 32'h9551_1559

        // Test SHIFT_LEFT (logical)
        alu_a = 32'h0000_000F; // ...0000_1111
        alu_b = 5'd4; // Shift by 4
        alu_op = SHIFT_LEFT;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'h0000_00F0

        // Test SHIFT_RIGHT (logical)
        alu_a = 32'hF000_0000; // 1111_0000...
        alu_b = 5'd4; // Shift by 4
        alu_op = SHIFT_RIGHT;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'h0F00_0000

        // Test SHIFT_RIGHT_ARITH (positive number)
        alu_a = 32'h7000_0000; // Positive (MSB is 0)
        alu_b = 5'd4;
        alu_op = SHIFT_RIGHT_ARITH;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'h0700_0000 (same as logical for positive)

        // Test SHIFT_RIGHT_ARITH (negative number)
        alu_a = 32'hFFFF_FF00; // Negative (MSB is 1)
        alu_b = 5'd4;
        alu_op = SHIFT_RIGHT_ARITH;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'hFFFF_FFF0 (sign extension with 1s)

        // Test COMPARE (Equal)
        alu_a = 32'd100;
        alu_b = 32'd100;
        alu_op = COMPARE;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'h0000_0001 (or 32'hFFFF_FFFF if you prefer all 1s for true)

        // Test COMPARE (Not Equal)
        alu_a = 32'd100;
        alu_b = 32'd99;
        alu_op = COMPARE;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'h0000_0000

        // Test BIGGER
        alu_a = 32'd200;
        alu_b = 32'd150;
        alu_op = BIGGER;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'h0000_0001

        // Test SMALLER
        alu_a = 32'd50;
        alu_b = 32'd100;
        alu_op = SMALLER;
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'h0000_0001

        // Default case
        alu_a = 0;
        alu_b = 0;
        alu_op = 5'b11111; // Undefined opcode
        #10 $display("%0t | %h | %h | %b | %h", $time, alu_a, alu_b, alu_op, alu_result);
        // Expected: 32'h0000_0000

        $display("--------------------------------------");
        $display("Testbench finished.");
        $finish; // End simulation
    end

endmodule