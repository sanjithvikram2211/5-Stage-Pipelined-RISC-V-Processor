module Forwarding_Unit(
    input [4:0] id_ex_rs1, input [4:0] id_ex_rs2,
    input [4:0] ex_mem_rd, input ex_mem_reg_write, input ex_mem_mem_read,
    input [4:0] mem_wb_rd, input mem_wb_reg_write,
    output reg [1:0] forward_a, output reg [1:0] forward_b
);
    // 00 = ID/EX value, 10 = EX/MEM value, 01 = MEM/WB value
    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        if (ex_mem_reg_write && !ex_mem_mem_read &&
            (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1))
            forward_a = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 0) &&
                 (mem_wb_rd == id_ex_rs1))
            forward_a = 2'b01;

        if (ex_mem_reg_write && !ex_mem_mem_read &&
            (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2))
            forward_b = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 0) &&
                 (mem_wb_rd == id_ex_rs2))
            forward_b = 2'b01;
    end
endmodule
