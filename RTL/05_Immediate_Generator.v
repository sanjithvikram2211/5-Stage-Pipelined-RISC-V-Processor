module Immediate_Generator(
    input [31:0] instruction,
    output reg [31:0] immediate
);
    always @(*) begin
        case (instruction[6:0])
            7'b0010011, 7'b0000011: // I-type: ADDI, LW
                immediate = {{20{instruction[31]}}, instruction[31:20]};

            7'b0100011: // S-type: SW
                immediate = {{20{instruction[31]}},
                              instruction[31:25], instruction[11:7]};

            7'b1100011: // B-type: BEQ, offset is even
                immediate = {{19{instruction[31]}},
                              instruction[31], instruction[7],
                              instruction[30:25], instruction[11:8], 1'b0};

            default:
                immediate = 32'd0;
        endcase
    end
endmodule
