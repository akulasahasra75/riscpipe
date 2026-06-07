`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2026 10:54:31
// Design Name: 
// Module Name: id_ex_reg
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


module id_ex_reg(input clk,rst,flush,stall,
input [31:0] pc_plus4_in,rd1_in,rd2_in,imm_in,
input [4:0] rs1_in, rs2_in,rd_in,
input [2:0] alu_op_in,
input reg_write_in,alu_src_in, mem_read_in, mem_to_reg_in, branch_in,
output reg [31:0] pc_plus4_op,rd1_out,rd2_out, imm_out,
output reg [4:0] rs1_out, rs2_out, rd_out,
output reg [2:0] alu_op_out,
output reg reg_write_out, alu_src_out, mem_write_out, mem_read_out, mem_to_reg_out, branch_out);

always @(posedge clk)begin
    if(rst | flush)begin
        pc_plus4_op <=0;
        rd1_out <= 0;
        rd2_out <= 0;
        imm_out <= 0;
        rs1_out <= 0; 
        rs2_out <= 0; 
        rd_out <= 0; 
        alu_op_out <= 0;
        reg_write_out <= 0;
        alu_src_out <= 0;
        mem_write_out <= 0;
        mem_read_out <= 0;
        mem_to_reg_out <= 0;
        branch_out <= 0;
    end
    else if(!stall) begin
        pc_plus4_op <= pc_plus4_in;
        rd1_out <=  rd1_in;
        rd2_out <=  rd2_in;
        imm_out <=  imm_in;
        rs1_out <= rs1_in; 
        rs2_out <= rs2_in; 
        rd_out <= rd_in; 
        alu_op_out <= alu_op_in;
        reg_write_out <= reg_write_in;
        alu_src_out <= alu_src_in;
        mem_write_out <= reg_write_in;
        mem_read_out <= mem_read_in;
        mem_to_reg_out <= mem_to_reg_in;
        branch_out <= branch_in;
       
    end
end

endmodule
