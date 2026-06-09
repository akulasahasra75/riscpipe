`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 10:01:30
// Design Name: 
// Module Name: hazards
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

module hazard_unit(
    input  [4:0] rs1_id,
    input  [4:0] rs2_id,
    input  [4:0] rd_ex,
    input        mem_read_ex,
    output reg   stall,
    output reg   flush_id_ex
);

always @(*) begin
    stall       = 1'b0;
    flush_id_ex = 1'b0;

    if (mem_read_ex &&
        (rd_ex != 5'b00000) &&
        ((rd_ex == rs1_id) || (rd_ex == rs2_id)))
    begin
        stall       = 1'b1;
        flush_id_ex = 1'b1;
    end
end

endmodule