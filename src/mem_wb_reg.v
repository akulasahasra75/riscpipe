`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2026 11:20:16
// Design Name: 
// Module Name: mem_wb_reg
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


module mem_wb_reg(
input clk, rst,
input [31:0] alu_result_in, mem_data_in,
input [4:0] rd_in,
input reg_write_in, mem_to_reg_in,
output reg [31:0] alu_result_out, mem_data_out,
output reg [4:0] rd_out,
output reg reg_write_out, mem_to_reg_out);


always @(posedge clk)begin
    if(rst)begin
        alu_result_out <=0;
        mem_data_out <= 0;
        rd_out <= 0;
        reg_write_out <= 0;
        mem_to_reg_out <= 0;
    end
    else begin
        alu_result_out <= alu_result_in;
        rd_out <= rd_in; 
        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        mem_data_out <= mem_data_in;
    end
end

endmodule
