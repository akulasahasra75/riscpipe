`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 22:12:47
// Design Name: 
// Module Name: control_unit
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


module control_unit(
input [6:0] opcode,
input [2:0] funct3,

output reg reg_write,
output reg mem_write,
output reg alu_src,
output reg mem_read,
output reg mem_to_reg,
output reg branch,
output reg [2:0] alu_op
);

always @(*) begin
    reg_write = 0;
    alu_src = 0;
    mem_write = 0;
    mem_read = 0;
    mem_to_reg = 0;
    branch = 0;
    alu_op = 3'b000;   // default

    case(opcode)

        // R-type
        7'b0110011: begin
            reg_write = 1;
            alu_op = 3'b000;
        end

        // S-type (SW)
        7'b0100011: begin
            alu_src = 1'b1;
            mem_write = 1'b1;
            alu_op = 3'b000;
        end

        // B-type (BEQ)
        7'b1100011: begin
            branch = 1;
            alu_op = 3'b001;
        end

        // I-type (ADDI/LW in your current design)
        7'b0010011: begin
            if(funct3 == 3'b000) begin
                reg_write = 1;
                alu_src = 1;
                alu_op = 3'b000;
            end
            else if(funct3 == 3'b010) begin
                reg_write = 1;
                alu_src = 1;
                mem_read = 1;
                mem_to_reg = 1;
                alu_op = 3'b000;
            end
        end

    endcase
end

endmodule
