`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2026 11:25:40
// Design Name: 
// Module Name: data_mem
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


module data_mem(
    input clk,
    input mem_write,
    input mem_read,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
);

reg [31:0] mem [0:63];
integer i;

initial begin
    for(i = 0; i < 64; i = i + 1)
        mem[i] = 32'b0;
end

always @(posedge clk) begin
    if(mem_write)
        mem[addr[5:0]] <= write_data;
end

assign read_data = (mem_read) ? mem[addr[5:0]] : 32'b0;

endmodule
