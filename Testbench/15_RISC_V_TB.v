`timescale 1ns/1ps

module RISC_V_TB;
    reg clk;
    reg reset;

    RISC_V_Top DUT(
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        // Hold reset for two rising clock edges
        repeat (2) @(negedge clk);
        reset = 0;

        // Simulation-only preload of source registers:
        // x1 = 10, x2 = 5. The architectural register file
        // is otherwise reset to zero.
        @(negedge clk);
        DUT.RF.registers[1] = 32'd10;
        DUT.RF.registers[2] = 32'd5;

        // Allow the program to pass through the pipeline
        repeat (30) @(posedge clk);

        $display("x3 = %0d", DUT.RF.registers[3]);
        $display("x4 = %0d", DUT.RF.registers[4]);
        $display("x5 = %0d", DUT.RF.registers[5]);
        $display("x6 = %0d", DUT.RF.registers[6]);
        $display("x7 = %0d", DUT.RF.registers[7]);
        $display("x8 = %0d", DUT.RF.registers[8]);
        $display("x9 = %0d", DUT.RF.registers[9]);
        $display("Data_Memory[0] = %0d", DUT.DMEM.memory[0]);

        $finish;
    end
    initial begin
    // Wait for processor execution
    #320;

    $display("------ FINAL REGISTER VALUES ------");
    $display("x3 = %d", DUT.RF.registers[3]);
    $display("x4 = %d", DUT.RF.registers[4]);
    $display("x5 = %d", DUT.RF.registers[5]);
    $display("x6 = %d", DUT.RF.registers[6]);
    $display("x7 = %d", DUT.RF.registers[7]);
    $display("x8 = %d", DUT.RF.registers[8]);
    $display("x9 = %d", DUT.RF.registers[9]);

    $display("------ DATA MEMORY ------");
    $display("Memory[0] = %d", DUT.DMEM.memory[0]);

    $finish;
end

endmodule
