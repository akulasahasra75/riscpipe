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
output reg reg_write,mem_write,alu_src,mem_read,mem_to_reg,branch);

always @(*) begin
    reg_write = 0;
    alu_src = 0;
    mem_write = 0;
    mem_read = 0;
    mem_to_reg = 0;
    branch = 0;
    case(opcode)
        7'b0110011: reg_write = 1;
        7'b0100011:begin
                      alu_src = 1'b1;
                      mem_write = 1'b1;
                   end
        7'b1100011: branch = 1;
        7'b0010011:begin
                    if(funct3 == 3'b000)begin
                        reg_write = 1;
                        alu_src = 1;
                    end
                    else if(funct3 == 3'b010) begin
                        reg_write = 1;
                        alu_src = 1;
                        mem_read = 1;
                        mem_to_reg = 1;
                    end
                  end
          //default: begin
            //        reg_write = 0;
              //      alu_src = 0;
                //    mem_write = 0;
                  //  mem_read = 0;
               //     mem_to_reg = 0;
                 //   branch = 0;
                  // end
    endcase
end

endmodule
