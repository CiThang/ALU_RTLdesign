`include "module_logic.v"
`include "module_math.v"

module alu_top #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] alu_a,
    input  [WIDTH-1:0] alu_b,
    input  [4:0]       alu_op,
    input              alu_sel,          // 0: toán học, 1: logic
    output [WIDTH-1:0] alu_result,
    output             flag
);

    //===============================================
    // Function: Chuyển unsigned -> signed (giữ bit)
    //===============================================
    function signed [WIDTH-1:0] unsigned_to_signed;
        input [WIDTH-1:0] u_in;
        begin
            unsigned_to_signed = u_in;
        end
    endfunction

    //===============================================
    // Chuyển alu_a, alu_b thành dạng có dấu
    //===============================================
    wire signed [WIDTH-1:0] a_signed = unsigned_to_signed(alu_a);
    wire signed [WIDTH-1:0] b_signed = unsigned_to_signed(alu_b);

    //===============================================
    // Module toán học
    //===============================================
    wire [WIDTH-1:0] math_result;
    wire             math_flag;

    module_math #(.WIDTH(WIDTH)) u_math (
        .alu_a(alu_a),              // hoặc: a_signed nếu cần signed
        .alu_b(alu_b),              // hoặc: b_signed nếu cần signed
        .alu_op(alu_op),
        .alu_result(math_result),
        .flag(math_flag)
    );

    //===============================================
    // Module logic
    //===============================================
    wire [WIDTH-1:0] logic_result;

    module_logic #(.WIDTH(WIDTH)) u_logic (
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_op(alu_op),
        .alu_result(logic_result)
    );

    //===============================================
    // Chọn đầu ra: toán học hay logic
    //===============================================
    assign alu_result = (alu_sel == 1'b0) ? math_result : logic_result;
    assign flag       = (alu_sel == 1'b0) ? math_flag   : 1'b0;

endmodule
