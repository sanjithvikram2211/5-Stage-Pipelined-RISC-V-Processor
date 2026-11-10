module Data_Memory(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'd0;
    end

    // Word-aligned, combinational read
    always @(*) begin
        if (mem_read && (address[1:0] == 2'b00) && (address < 32'd1024))
            read_data = memory[address[9:2]];
        else
            read_data = 32'd0;
    end

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write && (address[1:0] == 2'b00) && (address < 32'd1024))
            memory[address[9:2]] <= write_data;
    end
endmodule
