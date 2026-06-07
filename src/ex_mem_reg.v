`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2026 11:11:42
// Design Name: 
// Module Name: ex_mem_reg
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


module ex_mem_reg(
input clk, rst, flush, stall,
input [31:0] alu_result_in, rd2_in, pc_branch_in,
input [4:0] rd_in,
input reg_write_in, mem_write_in, mem_read_in, mem_to_reg_in, branch_in, zero_in,
output reg [31:0] alu_result_out, rd2_out, pc_branch_out,
output reg [4:0] rd_out,
output reg reg_write_out, mem_write_out, mem_read_out, mem_to_reg_out, branch_out, zero_out);

always @(posedge clk)begin
    if(rst | flush)begin
        alu_result_out <=0;
        rd2_out <= 0;
        rd_out <= 0; 
        pc_branch_out <= 0;
        reg_write_out <= 0;
        zero_out <= 0;
        mem_write_out <= 0;
        mem_read_out <= 0;
        mem_to_reg_out <= 0;
        branch_out <= 0;
    end
    else if(!stall) begin
        alu_result_out <= alu_result_in;
        rd2_out <=  rd2_in;
        rd_out <= rd_in; 
        pc_branch_out <= pc_branch_in;
        reg_write_out <= reg_write_in;
        zero_out <= zero_in;
        mem_write_out <= mem_write_in;
        mem_read_out <= mem_read_in;
        mem_to_reg_out <= mem_to_reg_in;
        branch_out <= branch_in;
       
    end
end
endmodule
