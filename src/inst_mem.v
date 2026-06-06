`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 21:28:19
// Design Name: 
// Module Name: inst_mem
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


module inst_mem(input wire clk,
input wire [31:0] addr,
output reg [31:0] inst);

reg [31:0] mem[0:63];
integer i;

initial begin
    for(i =0; i<64; i = i+1)
        mem[i] = 32'h00000000;
end

always @ (posedge clk)begin

    inst<= mem[addr[5:0]];
end
endmodule
