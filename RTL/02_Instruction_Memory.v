module Instruction_Memory(
    input [31:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013; // NOP = ADDI x0,x0,0

        // Demonstration program (word addresses 0 through 7)
        memory[0] = 32'h002081B3; // ADD  x3,x1,x2
        memory[1] = 32'h40118233; // SUB  x4,x3,x1
        memory[2] = 32'h0041F2B3; // AND  x5,x3,x4
        memory[3] = 32'h0041E333; // OR   x6,x3,x4
        memory[4] = 32'h00A08393; // ADDI x7,x1,10
        memory[5] = 32'h00702023; // SW   x7,0(x0)
        memory[6] = 32'h00002403; // LW   x8,0(x0)
        memory[7] = 32'h0083C4B3; // XOR  x9,x7,x8
    end

    always @(*) begin
        if ((pc[1:0] == 2'b00) && (pc < 32'd1024))
            instruction = memory[pc[9:2]];
        else
            instruction = 32'h00000013;
    end
endmodule
