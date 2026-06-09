`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2026 11:39:54
// Design Name: 
// Module Name: top
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


module top(input clk, rst);

wire [31:0] pc, pc_plus4, pc_next, pc_branch;
wire [31:0] inst;

wire [6:0] opcode;
wire [2:0] funct3;
wire [4:0] rs1, rs2, rd;

wire [31:0] imm_i, imm_s, imm_b, imm;
wire [31:0] rd1, rd2, wd;

wire reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch;
wire [2:0] alu_op;

wire [31:0] alu_result;
wire zero;
wire [31:0] mem_data;

wire [31:0] inst_id, pc_plus4_id;
wire stall, flush;

/* ID/EX wires */
wire [31:0] rd1_ex, rd2_ex, imm_ex, pc_plus4_ex;
wire [4:0] rd_ex;
wire [4:0] rs1_ex, rs2_ex;

wire reg_write_ex;
wire mem_write_ex;
wire mem_read_ex;
wire mem_to_reg_ex;
wire branch_ex;
wire alu_src_ex;

wire [31:0] alu_result_wb, mem_data_wb;
wire [4:0] rd_wb;
wire reg_write_wb, mem_to_reg_wb;

wire [2:0] alu_op_ex;

wire [31:0] alu_in_a, alu_in_b, alu_in_b_fwd;

wire [1:0] forward_a, forward_b;
wire flush_id_ex;

wire [31:0] alu_result_mem, rd2_mem, pc_branch_mem;
wire [4:0] rd_mem;
wire reg_write_mem, mem_write_mem, mem_read_mem, mem_to_reg_mem, branch_mem, zero_mem;

assign flush = flush_id_ex;

assign alu_in_a =
    (forward_a == 2'b10) ? alu_result_mem :
    (forward_a == 2'b01) ? wd :
                           rd1_ex;

assign alu_in_b_fwd =
    (forward_b == 2'b10) ? alu_result_mem :
    (forward_b == 2'b01) ? wd :
                           rd2_ex;

assign alu_in_b = (alu_src_ex) ? imm_ex : alu_in_b_fwd;


assign pc_plus4 = pc + 4;
assign pc_branch = pc_branch_mem;
assign pc_next = (branch_mem & zero_mem) ? pc_branch_mem : pc_plus4;

/* Decode from IF/ID register */
assign opcode = inst_id[6:0];
assign rd     = inst_id[11:7];
assign funct3 = inst_id[14:12];
assign rs1    = inst_id[19:15];
assign rs2    = inst_id[24:20];

assign imm_i = {{20{inst_id[31]}}, inst_id[31:20]};
assign imm_s = {{20{inst_id[31]}}, inst_id[31:25], inst_id[11:7]};
assign imm_b = {{19{inst_id[31]}}, inst_id[31], inst_id[7],
                inst_id[30:25], inst_id[11:8], 1'b0};

assign imm = (opcode == 7'b0100011) ? imm_s :
             (opcode == 7'b1100011) ? imm_b :
             imm_i;

assign wd = (mem_to_reg_wb) ? mem_data_wb : alu_result_wb;

pc_reg m1(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pc_next(pc_next),
    .pc(pc)
);

inst_mem m2(
    .clk(clk),
    .addr(pc),
    .inst(inst)
);

control_unit m3(
    .opcode(opcode),
    .funct3(funct3),
    .reg_write(reg_write),
    .mem_write(mem_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .alu_op(alu_op)
);

reg_file m4(
    .clk(clk),
    .rst(rst),
    .we(reg_write_wb),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd_wb),
    .wd(wd),
    .rd1(rd1),
    .rd2(rd2)
);

alu m5(
    .a(alu_in_a),
    .b(alu_in_b),
    .alu_op(alu_op_ex),
    .zero(zero),
    .result(alu_result)
);

data_mem m6(
    .clk(clk),
    .mem_write(mem_write_mem),
    .mem_read(mem_read_mem),
    .addr(alu_result_mem),
    .write_data(rd2_mem),
    .read_data(mem_data)
);

if_id_reg m7(
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .stall(stall),
    .pc_plus4_in(pc_plus4),
    .inst_in(inst),
    .pc_plus4_out(pc_plus4_id),
    .inst_out(inst_id)
);

id_ex_reg m8(
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .stall(stall),
    .rd1_in(rd1),
    .rd2_in(rd2),
    .imm_in(imm),
    .pc_plus4_in(pc_plus4_id),

    .rd_in(rd),
    .rs1_in(rs1),
    .rs2_in(rs2),

    .reg_write_in(reg_write),
    .mem_write_in(mem_write),
    .mem_read_in(mem_read),
    .mem_to_reg_in(mem_to_reg),
    .branch_in(branch),
    .alu_src_in(alu_src),
    .alu_op_in(alu_op),

    .rd1_out(rd1_ex),
    .rd2_out(rd2_ex),
    .imm_out(imm_ex),
    .pc_plus4_out(pc_plus4_ex),

    .rd_out(rd_ex),
    .rs1_out(rs1_ex),
    .rs2_out(rs2_ex),

    .reg_write_out(reg_write_ex),
    .mem_write_out(mem_write_ex),
    .mem_read_out(mem_read_ex),
    .mem_to_reg_out(mem_to_reg_ex),
    .branch_out(branch_ex),
    .alu_src_out(alu_src_ex),
    .alu_op_out(alu_op_ex)
);
          
                        
ex_mem_reg m9(.clk(clk),
              .rst(rst),
              .flush(flush), 
              .stall(stall),
              .alu_result_in(alu_result), 
              .rd2_in(rd2_ex), 
              .pc_branch_in(pc_branch),
              .rd_in(rd_ex),
              .reg_write_in(reg_write_ex), 
              .mem_write_in(mem_write_ex), 
              .mem_read_in(mem_read_ex), 
              .mem_to_reg_in(mem_to_reg_ex), 
              .branch_in(branch_ex), 
              .zero_in(zero),
              .alu_result_out(alu_result_mem), 
              .rd2_out(rd2_mem), 
              .pc_branch_out(pc_branch_mem),
              .rd_out(rd_mem),
              .reg_write_out(reg_write_mem), 
              .mem_write_out(mem_write_mem), 
              .mem_read_out(mem_read_mem), 
              .mem_to_reg_out(mem_to_reg_mem), 
              .branch_out(branch_mem), 
              .zero_out(zero_mem));   
              
mem_wb_reg m10(.clk(clk), 
               .rst(rst),
               .alu_result_in(alu_result_mem), 
               .mem_data_in(mem_data),
               .rd_in(rd_mem),
               .reg_write_in(reg_write_mem), 
               .mem_to_reg_in(mem_to_reg_mem),
               .alu_result_out(alu_result_wb), 
               .mem_data_out(mem_data_wb),
               .rd_out(rd_wb),
               .reg_write_out(reg_write_wb), 
               .mem_to_reg_out(mem_to_reg_wb));                                 

forwarding_unit m11(
    .rs1_ex(rs1_ex),
    .rs2_ex(rs2_ex),
    .rd_mem(rd_mem),
    .rd_wb(rd_wb),
    .reg_write_mem(reg_write_mem),
    .reg_write_wb(reg_write_wb),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

hazard_unit m12(
    .rs1_id(rs1),
    .rs2_id(rs2),
    .rd_ex(rd_ex),
    .mem_read_ex(mem_read_ex),
    .stall(stall),
    .flush_id_ex(flush_id_ex)
);

endmodule
