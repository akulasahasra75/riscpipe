`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 09:53:55
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit(
input [4:0]rs1_ex, rs2_ex, rd_mem, rd_wb,
input reg_write_mem, reg_write_wb,
output reg [1:0] forward_a, forward_b);

    always @(*) begin
    forward_a = 2'b00;
    forward_b = 2'b00;

    if (reg_write_mem &&
        (rd_mem != 5'b00000) &&
        (rd_mem == rs1_ex))
    begin
        forward_a = 2'b10;   
    end
    else if (reg_write_wb &&
             (rd_wb != 5'b00000) &&
             (rd_wb == rs1_ex))
    begin
        forward_a = 2'b01;   
    end

    if (reg_write_mem &&
        (rd_mem != 5'b00000) &&
        (rd_mem == rs2_ex))
    begin
        forward_b = 2'b10;   
    end
    else if (reg_write_wb &&
             (rd_wb != 5'b00000) &&
             (rd_wb == rs2_ex))
    begin
        forward_b = 2'b01;  
    end
end
endmodule
