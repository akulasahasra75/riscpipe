`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 10:17:33
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_top;

reg clk;
reg rst;

top uut (
    .clk(clk),
    .rst(rst)
);

// Clock generation: 10 ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Reset + program loading
initial begin
    rst = 1'b1;
    #20;
    rst = 1'b0;

    // Initialize instruction memory
    uut.m2.mem[0] = 32'h00500093; // ADDI x1, x0, 5
    uut.m2.mem[1] = 32'h00300113; // ADDI x2, x0, 3
    uut.m2.mem[2] = 32'h00208333; // ADD  x3, x1, x2
    uut.m2.mem[3] = 32'h00302023; // SW   x3, 0(x0)
    uut.m2.mem[4] = 32'h00002203; // LW   x4, 0(x0)

    #200;
    $finish;
end

// Monitor processor state
initial begin
$monitor(
    "T=%0t PC=%h INST=%h x1=%0d x2=%0d x3=%0d x4=%0d",
        $time,
        uut.pc,
        uut.inst,
        uut.m4.regs[1],
        uut.m4.regs[2],
        uut.m4.regs[3],
        uut.m4.regs[4]
    );
end

endmodule