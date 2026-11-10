module IF_ID_Register(
    input clk, input reset, input stall, input flush,
    input [31:0] pc_in, input [31:0] pc_plus4_in,
    input [31:0] instruction_in,
    output reg [31:0] pc_out, output reg [31:0] pc_plus4_out,
    output reg [31:0] instruction_out
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out <= 32'd0;
            pc_plus4_out <= 32'd0;
            instruction_out <= 32'h00000013;
        end
        else if (!stall) begin
            pc_out <= pc_in;
            pc_plus4_out <= pc_plus4_in;
            instruction_out <= instruction_in;
        end
    end
endmodule
