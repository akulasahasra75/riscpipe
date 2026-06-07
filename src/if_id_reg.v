`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2026 10:28:10
// Design Name: 
// Module Name: if_id_reg
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


module if_id_reg( input clk,rst,flush,stall,
input [31:0] pc_plus4_in, inst_in,
output reg [31:0] pc_plus4_out,inst_out);

always @(posedge clk)begin
    if(rst | flush)begin
        pc_plus4_out <=0;
        inst_out <=0;
    end
    else if(!stall) begin
        pc_plus4_out <= pc_plus4_in;
        inst_out <= inst_in;
    end
end

endmodule
