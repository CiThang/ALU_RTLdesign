module module_logic #(
    parameter WIDTH     = 32
)(
    input [WIDTH - 1:0] alu_a,
    input [WIDTH - 1:0] alu_b,
    input [4:0]         alu_op,
    output[WIDTH - 1:0] alu_result
);

    reg [WIDTH - 1:0] result_r;

    // localparam : chính là hằng số (parameter) cục bộ
    localparam gAND             = 5'b00001;
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
 

    reg [31:16] shift_right_fill_r;
    reg [WIDTH-1:0] shift_right_1_r;
    reg [WIDTH-1:0] shift_right_2_r;
    reg [WIDTH-1:0] shift_right_4_r;
    reg [WIDTH-1:0] shift_right_8_r;

    reg [WIDTH-1:0] shift_left_1_r;
    reg [WIDTH-1:0] shift_left_2_r;
    reg [WIDTH-1:0] shift_left_4_r;
    reg [WIDTH-1:0] shift_left_8_r;

    // các cổng logic
    always @(alu_a or alu_b or alu_op) begin
        case(alu_op)
            gAND: 
                begin
                    result_r = alu_a & alu_b;
                end
            gOR:
                begin
                    result_r = alu_a | alu_b;
                end
            gNOT:
                begin
                    result_r = ~alu_a;
                end
            gNOR:
                begin
                    result_r = ~(alu_a | alu_b);
                end
            gNAND:
                begin
                    result_r = ~(alu_a & alu_b);
                end
            gXOR:
                begin
                    result_r = (~alu_a&alu_b) | (~alu_b&alu_a);
                end
            // dịch trái
            SHIFT_LEFT:
                begin
                    if(alu_b[0]==1'b1)
                        shift_left_1_r = {alu_a[30:0],1'b0};
                    else
                        shift_left_1_r = alu_a;

                    if(alu_b[1]==1'b1)
                        shift_left_2_r ={shift_left_1_r[29:0],2'b0};
                    else   
                        shift_left_2_r = shift_left_1_r;
                    
                    if(alu_b[2]==1'b1)
                        shift_left_4_r ={shift_left_2_r[27:0],4'b0000};
                    else    
                        shift_left_4_r = shift_left_2_r;

                    if(alu_b[3]==1'b1)
                        shift_left_8_r ={shift_left_8_r[23:0],8'b00000000};
                    else
                        shift_left_8_r =shift_left_4_r;

                    if(alu_b[4]==1'b1)
                        result_r = {shift_left_8_r[15:0],16'b0000000000000000};
                    else
                        result_r = shift_left_8_r;
                end

            SHIFT_RIGHT, SHIFT_RIGHT_ARITH:
                begin
                    if(alu_a[31] == 1'b1 && alu_op == SHIFT_RIGHT_ARITH)
                        shift_right_fill_r = 16'b1111111111111111;
                    else
                        shift_right_fill_r = 16'b0000000000000000;

                    if (alu_b[0] == 1'b1)
                        shift_right_1_r = {shift_right_fill_r[31],alu_a[31:1]};
                    else
                        shift_right_1_r = alu_a;
                    
                    if (alu_b[1] == 1'b1)
                        shift_right_2_r = {shift_right_fill_r[31:30],shift_right_1_r[31:2]};
                    else 
                        shift_right_2_r = shift_right_1_r;
                    
                    if (alu_b[2] == 1'b1)
                        shift_right_4_r = {shift_right_fill_r[31:28],shift_right_2_r[31:4]};
                    else
                        shift_right_4_r = shift_right_2_r;

                    if (alu_b[3] == 1'b1)
                        shift_right_8_r = {shift_right_fill_r[31:24],shift_right_4_r[31:8]};
                    else    
                        shift_right_8_r = shift_right_4_r;

                    if(alu_b [4] == 1'b1)
                        result_r = {shift_right_fill_r[31:16],shift_right_8_r[31:16]};
                    else
                        result_r = shift_right_8_r;


                end
            COMPARE :
                begin
                    result_r = (alu_a == alu_b) ? 32'b1 : 32'b0;
                end
            BIGGER :
                begin
                    result_r = (alu_a > alu_b) ? 32'b1 : 32'b0;
                end
            SMALLER :
                begin
                    result_r = (alu_a < alu_b) ? 32'b1 : 32'b0;
                end

        default:
            begin
                result_r <= 32'b0;
            end
        endcase
    end
    // so sánh
    assign alu_result = result_r;

endmodule

