`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 21:41:35
// Design Name: 
// Module Name: reg_file
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


module reg_file(
    input clk,
    input rst,
    input we,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);

    reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'h00000000;
    end

    assign rd1 = (rs1 == 5'd0) ? 32'h00000000 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'h00000000 : regs[rs2];

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'h00000000;
        end
        else if (we && (rd != 5'd0)) begin
            regs[rd] <= wd;
        end

       // regs[0] <= 32'h00000000;
    end

endmodule