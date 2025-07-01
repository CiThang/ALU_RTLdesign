`timescale 1ns/1ps
`include "alu_top.v"
module tb_alu_top;

    parameter WIDTH = 32;

    reg  [WIDTH-1:0] alu_a;
    reg  [WIDTH-1:0] alu_b;
    reg  [4:0]       alu_op;
    reg              alu_sel;

    wire [WIDTH-1:0] alu_result;
    wire             flag;

    // Instantiate DUT (Device Under Test)
    alu_top #(.WIDTH(WIDTH)) dut (
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_op(alu_op),
        .alu_sel(alu_sel),
        .alu_result(alu_result),
        .flag(flag)
    );

    // Task: Display result with name
    task display_result;
        input [255:0] op_name;
        begin
            #5; // delay for result
            $display("%s => Result: %0d (0x%h), Flag: %b", op_name, alu_result, alu_result, flag);
        end
    endtask

    initial begin
        $dumpfile("tb_alu_top.vcd");
        $dumpvars(0,tb_alu_top);
    end


    initial begin
        $display("=== ALU TOP TEST ===");

        // --------- Test toán học ----------
        alu_sel = 0;

        // ADD: 15 + 10 = 25
        alu_a = 15;
        alu_b = 10;
        alu_op = 5'b01101; // ADD
        display_result("ADD");

        // SUB: 20 - 5 = 15
        alu_a = 20;
        alu_b = 5;
        alu_op = 5'b01110; // SUB
        display_result("SUB");

        // MUL: 4294967290 * 4
        alu_a = 32'hFFFFFFFA; // 4294967290 (signed = -6)
        alu_b = 4;
        alu_op = 5'b01111; // MUL
        display_result("MUL");

        // MULH: high of 4294967290 * 123456
        alu_a = 32'hFFFFFFFA; // -6
        alu_b = 32'd123456;
        alu_op = 5'b10000; // MULH
        display_result("MULH");

        // DIV: 4294967275 / 4
        alu_a = 32'hFFFFFFEB; // -21
        alu_b = 4;
        alu_op = 5'b10001; // DIV
        display_result("DIV");

        // REM: 4294967275 % 4
        alu_a = 32'hFFFFFFEB; // -21
        alu_b = 4;
        alu_op = 5'b10010; // REM
        display_result("REM");

        // DIV 0: 5 / 0
        alu_a = 5;
        alu_b = 0;
        alu_op = 5'b10001; // DIV
        display_result("DIV by 0");

        // --------- Test logic ----------
        alu_sel = 1;

        // AND: 0xF0F0 & 0x0FF0
        alu_a = 32'h0000F0F0;
        alu_b = 32'h00000FF0;
        alu_op = 5'b00001; // AND
        display_result("AND");

        // OR
        alu_op = 5'b00010;
        display_result("OR");

        // NOT (on alu_a only)
        alu_op = 5'b00011;
        display_result("NOT");

        // XOR
        alu_op = 5'b00100;
        display_result("XOR");

        // NAND
        alu_op = 5'b00101;
        display_result("NAND");

        // NOR
        alu_op = 5'b00110;
        display_result("NOR");

        // SHIFT LEFT
        alu_a = 32'h0000000F;
        alu_b = 5;
        alu_op = 5'b01001;
        display_result("SHIFT LEFT");

        // SHIFT RIGHT
        alu_op = 5'b00111;
        display_result("SHIFT RIGHT");

        // SHIFT RIGHT ARITHMETIC
        alu_op = 5'b01000;
        alu_a = 32'hF0000000; // signed negative
        display_result("ARITH SHIFT RIGHT");

        // COMPARE: a == b
        alu_a = 1234;
        alu_b = 1234;
        alu_op = 5'b01010;
        display_result("COMPARE");

        // BIGGER
        alu_a = 99;
        alu_b = 100;
        alu_op = 5'b01011;
        display_result("BIGGER");

        // SMALLER
        alu_op = 5'b01100;
        display_result("SMALLER");

        $display("=== Test Done ===");
        $finish;
    end

endmodule
