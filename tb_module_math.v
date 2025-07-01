`timescale 1ns/1ps
`include "module_math.v"
module tb_module_math;
    parameter WIDTH = 32;

    reg  [WIDTH-1:0] a, b;
    reg  [4:0]       op;
    wire [WIDTH-1:0] result;
    wire             flag;

    module_math #(.WIDTH(WIDTH)) uut (
        .alu_a(a),
        .alu_b(b),
        .alu_op(op),
        .alu_result(result),
        .flag(flag)
    );

    initial begin
        $dumpfile("tb_module_math.vcd");
        $dumpvars(0,tb_module_math);
    end


    initial begin
        // Test ADD
        a = 32'd15; b = 32'd10; op = 5'b01101; #10;
        $display("ADD  : %0d + %0d = %0d, carry = %b", a, b, result, flag);

        // Test SUB
        a = 32'd20; b = 32'd5;  op = 5'b01110; #10;
        $display("SUB  : %0d - %0d = %0d, borrow = %b", a, b, result, flag);

        // Test MUL
        a = -6; b = 4; op = 5'b01111; #10;
        $display("MUL  : %0d * %0d = %0d", a, b, result);

        // Test MULH
        a = -6; b = 123456; op = 5'b10000; #10;
        $display("MULH : high(%0d * %0d) = %0d", a, b, result);

        // Test DIV
        a = -21; b = 4; op = 5'b10001; #10;
        $display("DIV  : %0d / %0d = %0d, div_zero = %b", a, b, result, flag);

        // Test REM
        a = -21; b = 4; op = 5'b10010; #10;
        $display("REM  : %0d %% %0d = %0d, div_zero = %b", a, b, result, flag);

        // Test chia cho 0
        a = 5; b = 0; op = 5'b10001; #10;
        $display("DIV 0: %0d / %0d = %0d, div_zero = %b", a, b, result, flag);

        $finish;
    end
endmodule
