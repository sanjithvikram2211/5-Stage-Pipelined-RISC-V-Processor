module Control_Unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,
    output reg branch,
    output reg [3:0] alu_control
);
    // ALU control: 0000 ADD, 0001 SUB, 0010 AND, 0011 OR, 0100 XOR
    always @(*) begin
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        branch     = 1'b0;
        alu_control = 4'b0000;

        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_control = (funct7[5]) ? 4'b0001 : 4'b0000;
                    3'b111: alu_control = 4'b0010;
                    3'b110: alu_control = 4'b0011;
                    3'b100: alu_control = 4'b0100;
                    default: alu_control = 4'b0000;
                endcase
            end

            7'b0010011: begin // ADDI subset
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_control = 4'b0000;
            end

            7'b0000011: begin // LW
                reg_write = 1'b1;
                mem_read = 1'b1;
                mem_to_reg = 1'b1;
                alu_src = 1'b1;
                alu_control = 4'b0000;
            end

            7'b0100011: begin // SW
                mem_write = 1'b1;
                alu_src = 1'b1;
                alu_control = 4'b0000;
            end

            7'b1100011: begin // BEQ
                branch = 1'b1;
                alu_control = 4'b0001;
            end

            default: begin
                // Unsupported instruction behaves as NOP
            end
        endcase
    end
endmodule
