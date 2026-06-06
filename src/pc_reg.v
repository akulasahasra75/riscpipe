`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 21:19:58
// Design Name: 
// Module Name: pc_reg
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


module pc_reg(input wire clk,rst,stall,
input wire [31:0] pc_next,
output reg [31:0] pc);

always @(posedge clk)begin
    if(rst) pc <= 32'b0;
    else if(!stall)
        pc <= pc_next; 
end
endmodule
