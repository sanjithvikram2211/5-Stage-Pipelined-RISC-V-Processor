module RISC_V_Top(
    input clk,
    input reset
);
    // IF stage
    wire [31:0] pc, pc_next, instruction;
    wire stall;
    wire branch_taken;
    wire [31:0] branch_target;

    Program_Counter PC(
        .clk(clk), .reset(reset), .stall(stall),
        .branch_taken(branch_taken), .branch_target(branch_target),
        .pc_out(pc)
    );

    assign pc_next = pc + 32'd4;

    Instruction_Memory IMEM(
        .pc(pc), .instruction(instruction)
    );

    // IF/ID pipeline register
    wire [31:0] ifid_pc, ifid_pc4, ifid_instruction;

    IF_ID_Register IF_ID(
        .clk(clk), .reset(reset), .stall(stall), .flush(branch_taken),
        .pc_in(pc), .pc_plus4_in(pc_next), .instruction_in(instruction),
        .pc_out(ifid_pc), .pc_plus4_out(ifid_pc4),
        .instruction_out(ifid_instruction)
    );

    // ID stage
    wire [4:0] rs1_id, rs2_id, rd_id;
    wire [31:0] read_data1_id, read_data2_id, immediate_id;
    wire reg_write_id, mem_read_id, mem_write_id, mem_to_reg_id;
    wire alu_src_id, branch_id;
    wire [3:0] alu_control_id;

    assign rs1_id = ifid_instruction[19:15];
    assign rs2_id = ifid_instruction[24:20];
    assign rd_id  = ifid_instruction[11:7];

    wire [31:0] writeback_data;
    wire [4:0] memwb_rd;
    wire memwb_reg_write, memwb_mem_to_reg;
    wire [31:0] memwb_mem_data, memwb_alu_result, memwb_pc4;
    wire [31:0] memwb_unused_pc4;

    assign writeback_data = memwb_mem_to_reg ? memwb_mem_data : memwb_alu_result;

wire [31:0] read_data1_rf;
wire [31:0] read_data2_rf;

Register_File RF(
    .clk(clk), .reset(reset),
    .reg_write(memwb_reg_write),
    .rs1(rs1_id), .rs2(rs2_id), .rd(memwb_rd),
    .write_data(writeback_data),
    .read_data1(read_data1_rf),
    .read_data2(read_data2_rf)
);

// WB-to-ID forwarding
assign read_data1_id =
    (memwb_reg_write && (memwb_rd != 0) &&
     (memwb_rd == rs1_id))
    ? writeback_data : read_data1_rf;

assign read_data2_id =
    (memwb_reg_write && (memwb_rd != 0) &&
     (memwb_rd == rs2_id))
    ? writeback_data : read_data2_rf;
   
    Control_Unit CU(
        .opcode(ifid_instruction[6:0]),
        .funct3(ifid_instruction[14:12]),
        .funct7(ifid_instruction[31:25]),
        .reg_write(reg_write_id), .mem_read(mem_read_id),
        .mem_write(mem_write_id), .mem_to_reg(mem_to_reg_id),
        .alu_src(alu_src_id), .branch(branch_id),
        .alu_control(alu_control_id)
    );

    Immediate_Generator IG(
        .instruction(ifid_instruction), .immediate(immediate_id)
    );

    // Hazard detection: load-use dependency
    wire [31:0] idex_pc, idex_pc4, idex_data1, idex_data2, idex_imm;
    wire [4:0] idex_rs1, idex_rs2, idex_rd;
    wire idex_reg_write, idex_mem_read, idex_mem_write;
    wire idex_mem_to_reg, idex_alu_src, idex_branch;
    wire [3:0] idex_alu_control;

    Hazard_Detection_Unit HDU(
        .id_ex_mem_read(idex_mem_read), .id_ex_rd(idex_rd),
        .if_id_rs1(rs1_id), .if_id_rs2(rs2_id), .stall(stall)
    );

    // ID/EX register receives a bubble on stall or taken branch
    ID_EX_Register ID_EX(
        .clk(clk), .reset(reset), .flush(stall || branch_taken),
        .pc_in(ifid_pc), .pc_plus4_in(ifid_pc4),
        .read_data1_in(read_data1_id), .read_data2_in(read_data2_id),
        .immediate_in(immediate_id),
        .rs1_in(rs1_id), .rs2_in(rs2_id), .rd_in(rd_id),
        .reg_write_in(reg_write_id), .mem_read_in(mem_read_id),
        .mem_write_in(mem_write_id), .mem_to_reg_in(mem_to_reg_id),
        .alu_src_in(alu_src_id), .branch_in(branch_id),
        .alu_control_in(alu_control_id),
        .pc_out(idex_pc), .pc_plus4_out(idex_pc4),
        .read_data1_out(idex_data1), .read_data2_out(idex_data2),
        .immediate_out(idex_imm),
        .rs1_out(idex_rs1), .rs2_out(idex_rs2), .rd_out(idex_rd),
        .reg_write_out(idex_reg_write), .mem_read_out(idex_mem_read),
        .mem_write_out(idex_mem_write), .mem_to_reg_out(idex_mem_to_reg),
        .alu_src_out(idex_alu_src), .branch_out(idex_branch),
        .alu_control_out(idex_alu_control)
    );

    // EX stage and forwarding
    wire [1:0] forward_a, forward_b;
    wire [31:0] exmem_alu_result, exmem_store_data, exmem_pc4;
    wire [4:0] exmem_rd;
    wire exmem_reg_write, exmem_mem_read, exmem_mem_write, exmem_mem_to_reg;

    Forwarding_Unit FU(
        .id_ex_rs1(idex_rs1), .id_ex_rs2(idex_rs2),
        .ex_mem_rd(exmem_rd), .ex_mem_reg_write(exmem_reg_write),
        .ex_mem_mem_read(exmem_mem_read),
        .mem_wb_rd(memwb_rd), .mem_wb_reg_write(memwb_reg_write),
        .forward_a(forward_a), .forward_b(forward_b)
    );

    reg [31:0] forward_data_a, forward_data_b;
    always @(*) begin
        case (forward_a)
            2'b10: forward_data_a = exmem_alu_result;
            2'b01: forward_data_a = writeback_data;
            default: forward_data_a = idex_data1;
        endcase

        case (forward_b)
            2'b10: forward_data_b = exmem_alu_result;
            2'b01: forward_data_b = writeback_data;
            default: forward_data_b = idex_data2;
        endcase
    end

    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire alu_zero;

    assign alu_operand_b = idex_alu_src ? idex_imm : forward_data_b;

    ALU ALU_UNIT(
        .operand_a(forward_data_a), .operand_b(alu_operand_b),
        .alu_control(idex_alu_control),
        .result(alu_result), .zero(alu_zero)
    );

    assign branch_taken = idex_branch && (forward_data_a == forward_data_b);
    assign branch_target = idex_pc + idex_imm;

    // EX/MEM pipeline register
    EX_MEM_Register EX_MEM(
        .clk(clk), .reset(reset),
        .alu_result_in(alu_result), .store_data_in(forward_data_b),
        .pc_plus4_in(idex_pc4), .rd_in(idex_rd),
        .reg_write_in(idex_reg_write), .mem_read_in(idex_mem_read),
        .mem_write_in(idex_mem_write), .mem_to_reg_in(idex_mem_to_reg),
        .alu_result_out(exmem_alu_result),
        .store_data_out(exmem_store_data), .pc_plus4_out(exmem_pc4),
        .rd_out(exmem_rd), .reg_write_out(exmem_reg_write),
        .mem_read_out(exmem_mem_read), .mem_write_out(exmem_mem_write),
        .mem_to_reg_out(exmem_mem_to_reg)
    );

    // MEM stage
    wire [31:0] memory_read_data;

    Data_Memory DMEM(
        .clk(clk), .mem_read(exmem_mem_read), .mem_write(exmem_mem_write),
        .address(exmem_alu_result), .write_data(exmem_store_data),
        .read_data(memory_read_data)
    );

    // MEM/WB pipeline register
    MEM_WB_Register MEM_WB(
        .clk(clk), .reset(reset),
        .memory_data_in(memory_read_data), .alu_result_in(exmem_alu_result),
        .pc_plus4_in(exmem_pc4), .rd_in(exmem_rd),
        .reg_write_in(exmem_reg_write), .mem_to_reg_in(exmem_mem_to_reg),
        .memory_data_out(memwb_mem_data), .alu_result_out(memwb_alu_result),
        .pc_plus4_out(memwb_pc4), .rd_out(memwb_rd),
        .reg_write_out(memwb_reg_write), .mem_to_reg_out(memwb_mem_to_reg)
    );

endmodule
