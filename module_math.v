module module_math#(
    parameter WIDTH = 32 
)(
    input  [WIDTH-1:0] alu_a,
    input  [WIDTH-1:0] alu_b,
    input  [4:0]       alu_op,
    output [WIDTH-1:0] alu_result,
    output             flag       // c_out hoặc div_zero tùy lệnh
);
    // Các mã lệnh
    localparam ADD   = 5'b01101;
    localparam SUB   = 5'b01110;
    localparam MUL   = 5'b01111;
    localparam MULH  = 5'b10000;
    localparam DIV   = 5'b10001;
    localparam REM   = 5'b10010;

    // ADD
    wire [WIDTH-1:0] add_result;
    wire add_flag;

    ripple_carry_adder_32bit #(.WIDTH(WIDTH)) adder_inst (
        .a(alu_a),
        .b(alu_b),
        .c_in_initial(1'b0),
        .s(add_result),
        .c_out_final(add_flag)
    );

    // SUB
    wire [WIDTH-1:0] sub_result;
    wire raw_c_out;
    wire sub_flag;

    subtractor_32bit #(.WIDTH(WIDTH)) subtractor_inst (
        .a(alu_a),
        .b(alu_b),
        .s(sub_result),
        .c_out(raw_c_out)
    );
    assign sub_flag = ~raw_c_out;  // Vì trong phép trừ bù 2, borrow = ~carry

    // MUL / MULH
    wire [WIDTH-1:0] mul_result;
    multiplier_32bit #(.WIDTH(WIDTH)) multiplier_inst (
        .a(alu_a),
        .b(alu_b),
        .mulh_sel(alu_op == MULH),
        .result(mul_result)
    );

    // DIV / REM
    wire [WIDTH-1:0] divrem_result;
    wire div_zero_flag;
    div_rem_signed #(.WIDTH(WIDTH)) divrem_inst (
        .a(alu_a),
        .b(alu_b),
        .rem_sel(alu_op == REM),
        .result(divrem_result),
        .div_zero(div_zero_flag)
    );

    // Chọn đầu ra
    assign alu_result =
        (alu_op == ADD)  ? add_result     :
        (alu_op == SUB)  ? sub_result     :
        (alu_op == MUL ||
         alu_op == MULH) ? mul_result     :
        (alu_op == DIV ||
         alu_op == REM ) ? divrem_result  :
        {WIDTH{1'b0}};

    assign flag =
        (alu_op == ADD)  ? add_flag       :
        (alu_op == SUB)  ? sub_flag       :
        (alu_op == DIV ||
         alu_op == REM ) ? div_zero_flag  :
        1'b0;
endmodule


module ripple_carry_adder_32bit #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input             c_in_initial,
    output [WIDTH-1:0] s,
    output            c_out_final
);
    wire [WIDTH:0] c;
    assign c[0] = c_in_initial;

    genvar i;
    generate
        for(i = 0; i < WIDTH; i = i + 1) begin : fa_instances
            full_adder fa_inst (
                .a(a[i]),
                .b(b[i]),
                .c_in(c[i]),
                .r(s[i]),
                .c_out(c[i+1])
            );
        end
    endgenerate

    assign c_out_final = c[WIDTH];
endmodule


module subtractor_32bit #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] s,
    output             c_out   // Đây là carry, cần đảo lại khi dùng làm borrow
);
    wire [WIDTH-1:0] b_inverted;
    assign b_inverted = ~b;

    ripple_carry_adder_32bit #(.WIDTH(WIDTH)) sub_adder_inst (
        .a(a),
        .b(b_inverted),
        .c_in_initial(1'b1),
        .s(s),
        .c_out_final(c_out)
    );
endmodule


module full_adder(
    input  a,
    input  b,
    input  c_in,
    output r,  
    output c_out 
);
    assign r = a ^ b ^ c_in;
    assign c_out = (a & b) | (a & c_in) | (b & c_in);
endmodule


module multiplier_32bit #(
    parameter WIDTH = 32
)(  
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input              mulh_sel,
    output [WIDTH-1:0] result
);
    wire signed [WIDTH-1:0] a_signed = a;
    wire signed [WIDTH-1:0] b_signed = b;

    wire signed [2*WIDTH-1:0] mult_result = a_signed * b_signed;

    assign result = mulh_sel ? mult_result[63:32] : mult_result[31:0];
endmodule


module div_rem_signed #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input              rem_sel,
    output [WIDTH-1:0] result,
    output             div_zero
);
    wire signed [WIDTH-1:0] a_signed = a;
    wire signed [WIDTH-1:0] b_signed = b;

    assign div_zero = (b_signed == 0);

    wire signed [WIDTH-1:0] quotient  = div_zero ? 0 : (a_signed / b_signed);
    wire signed [WIDTH-1:0] remainder = div_zero ? 0 : (a_signed % b_signed);

    assign result = rem_sel ? remainder : quotient;
endmodule
