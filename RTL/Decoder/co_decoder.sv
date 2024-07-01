`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2024 11:20:45 AM
// Design Name: 
// Module Name: co_decoder
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

(* DONT_TOUCH = "yes" *)

module co_decoder import cvxif_pkg::*;
(
    input  logic             clk_i,
    input  logic             issue_valid_i,
    input  x_issue_req_t     issue_req_i,
    output x_issue_resp_t    issue_resp_o,
    output cntr              controls,
    output convolution       data
    );
    
    
    parameter Custom_OPCODE    = 7'b0001011 ;
    parameter ADDR             = 3'b000     ;
    parameter LDI              = 3'b001     ;
    parameter LDW              = 3'b010     ;
    parameter RADDR            = 3'b011     ;

always_comb 
begin
    unique case (issue_req_i.instr[6:0])
      Custom_OPCODE: begin // Custom opcode
      if (issue_valid_i) begin
            issue_resp_o.accept     = '1;
            issue_resp_o.writeback  = '0;
            issue_resp_o.dualwrite  = '0;
            issue_resp_o.dualread   = '0;
//            issue_resp_o.loadstore  = '0;
            issue_resp_o.loadstore  = issue_req_i.instr[13] || issue_req_i.instr[12];
            issue_resp_o.ecswrite   = '0;
            issue_resp_o.exc        = '0;
            unique case (issue_req_i.instr[14:12])   
                ADDR:   begin
                    data.W_addr             = issue_req_i.rs[0];
                    data.I_addr             = issue_req_i.rs[1];
                    controls.loadw          = '0                        ; 
                    controls.loadi          = '0                        ;                     
                    controls.execute        = '0                         ; 
                end
                LDI:    begin
                    data.I_height           = issue_req_i.rs[0][15:0]          ; //register operand 1
                    data.I_width            = issue_req_i.rs[0][31:16]        ; //register operand 2
                    data.I_kernels          = issue_req_i.rs[1][15:0]         ; //register operand 1
                    data.I_channels         = issue_req_i.rs[1][31:16]   ; 
                    controls.loadw          = '0                         ; 
                    controls.loadi          = '1                         ; 
                    controls.execute        = '0                         ; 
                end
                LDW:    begin
                    data.W_height           = issue_req_i.rs[0][15:0]          ; //register operand 1
                    data.W_width            = issue_req_i.rs[0][31:16]        ; //register operand 2
                    data.W_kernels          = issue_req_i.rs[1][15:0]         ; //register operand 1
                    data.W_channels         = issue_req_i.rs[1][31:16]   ;  
                    data.padding            = issue_req_i.instr[26] ;
                    data.Stride             = issue_req_i.instr[25] ;                                     
                    controls.loadw          = '1                        ; 
                    controls.loadi          = '0                        ; 
                    controls.execute        = '0                         ; 
                end
                RADDR:  begin
                    data.R_addr             = issue_req_i.rs[0]         ;
                    controls.loadw          = '0                        ; 
                    controls.loadi          = '0                        ;                     
                    controls.execute        = '1                         ; 
                end
                default: begin
                    data.I_height           = data.I_height          ; //register operand 1
                    data.I_width            = data.I_width          ; //register operand 2
                    data.I_channels         = data.I_channels    ;
                    data.W_height           = data.W_height          ; //register operand 1
                    data.W_width            = data.W_width          ; //register operand 2
                    data.W_channels         = data.W_channels    ;
                    data.Stride             = data.Stride   ;
                    data.padding            = data.padding   ;
                    controls.loadw          = '0                        ; 
                    controls.loadi          = '0                        ;                     
                    controls.execute        = '0                         ; 
                end
            endcase
      end
      end
      default: begin
    // Default assignments
        issue_resp_o.accept    = '0;
        issue_resp_o.writeback = '0;
        issue_resp_o.dualwrite = '0;
        issue_resp_o.dualread  = '0;
        issue_resp_o.loadstore = '0;
        issue_resp_o.ecswrite  = '0;
        issue_resp_o.exc       = '0;
        controls               = '0 ;
      end
  endcase
  end
endmodule