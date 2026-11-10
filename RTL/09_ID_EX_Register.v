module ID_EX_Register(
    input clk, input reset, input flush,
    input [31:0] pc_in, input [31:0] pc_plus4_in,
    input [31:0] read_data1_in, input [31:0] read_data2_in,
    input [31:0] immediate_in,
    input [4:0] rs1_in, input [4:0] rs2_in, input [4:0] rd_in,
    input reg_write_in, input mem_read_in, input mem_write_in,
    input mem_to_reg_in, input alu_src_in, input branch_in,
    input [3:0] alu_control_in,

    output reg [31:0] pc_out, output reg [31:0] pc_plus4_out,
    output reg [31:0] read_data1_out, output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,
    output reg [4:0] rs1_out, output reg [4:0] rs2_out, output reg [4:0] rd_out,
    output reg reg_write_out, output reg mem_read_out, output reg mem_write_out,
    output reg mem_to_reg_out, output reg alu_src_out, output reg branch_out,
    output reg [3:0] alu_control_out
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out <= 0; pc_plus4_out <= 0;
            read_data1_out <= 0; read_data2_out <= 0; immediate_out <= 0;
            rs1_out <= 0; rs2_out <= 0; rd_out <= 0;
            reg_write_out <= 0; mem_read_out <= 0; mem_write_out <= 0;
            mem_to_reg_out <= 0; alu_src_out <= 0; branch_out <= 0;
            alu_control_out <= 0;
        end
        else begin
            pc_out <= pc_in; pc_plus4_out <= pc_plus4_in;
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;
            immediate_out <= immediate_in;
            rs1_out <= rs1_in; rs2_out <= rs2_in; rd_out <= rd_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_src_out <= alu_src_in;
            branch_out <= branch_in;
            alu_control_out <= alu_control_in;
        end
    end
endmodule
