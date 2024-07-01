`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2024 16:22:21
// Design Name: 
// Module Name: psum_manager
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

module psum_manager import cvxif_pkg::*;
#(
    parameter ADR_P = 11,
    parameter SRAM_P = 32
)
(
	input logic                clk,
	input logic                rstn,
	
    input convolution          data,
	input logic                results_ready,
	input logic                finish,
    input logic signed [31:0]  results_i  [32-1:0],
    input  logic  [6:0]                 current_ch,
    // Accelerator-side Interface PSUMS
    output  logic [SRAM_P-1:0]           p_sram_data   [32-1:0],        // Input data bus from Accelerator
    input   logic [SRAM_P-1:0]           p_sram_data_i [32-1:0],        // Input data bus from Accelerator
    output  logic [ADR_P-1:0]            p_sram_addr   ,        // Address from Accelerator
    output  logic                        p_sram_rden   ,        // Read Enable from Accelerator
    
    output logic               stop,
    output logic               done
    );
    
logic                   start                   = 0                 ;
logic                   rden                    = 1                 ;
logic                   finished                = 0                 ;
logic [16:0]            count                                       ;
logic [16:0]            size_x                                        ;
logic [16:0]            size_y                                        ;
logic [16:0]            nb_elements                                 ;
logic [2:0]             last                    = 0                 ;
logic                   results_valid           = '0 ;
logic [ADR_P-1:0]       addr   = '{default: '0};



assign size_x = ((data.I_height-data.W_height+2*data.padding)/(data.Stride+1))+1 ;
assign size_y = ((data.I_width-data.W_width+2*data.padding)/(data.Stride+1))+1 ;
assign nb_elements =(data.W_width == 3)? (size_y+2)*size_x : data.I_height;
always_ff @(posedge clk) begin
    if (start) begin
        if (results_valid) begin
            if (count == 31) begin
                finished = 1'b1 ;
                start    = 1'b1 ;
                rden     = '1       ;
                addr    = addr+1;
            end else    
            if (count == 32 ) begin
                finished = 1'b0 ;
                start    = 1'b0 ;
                addr     = '0;
            end else 
            begin
                addr    = addr+1;
            end
        end else
        if (finish) begin
            results_valid  = 1'b1 ;   
            count          = '0;   
            addr    = addr+1;
        end else
        if (count == 1)begin
            addr    = addr;
            rden    = '0        ;
        end else
        if ((count>1)&&(count < nb_elements+31)) begin
            addr    = addr+1;
            rden    = '0        ;
        end     
         
       count               = count +1;
    end else    
    if (results_ready & !start & !finished) begin
        start               = '1;
        count               = '0;
        stop                = '0;
        addr                = '0;
        results_valid       = '0;         
        rden                = '1       ;
    end
end	
assign done         = finished  ;
assign stop         = finished  ;

assign p_sram_data[0]     = (current_ch==1)? results_i[0]  : p_sram_data_i[0]  + results_i[0] ;
assign p_sram_data[1]     = (current_ch==1)? results_i[1]  : p_sram_data_i[1]  + results_i[1] ;
assign p_sram_data[2]     = (current_ch==1)? results_i[2]  : p_sram_data_i[2]  + results_i[2] ;
assign p_sram_data[3]     = (current_ch==1)? results_i[3]  : p_sram_data_i[3]  + results_i[3] ;
assign p_sram_data[4]     = (current_ch==1)? results_i[4]  : p_sram_data_i[4]  + results_i[4] ;
assign p_sram_data[5]     = (current_ch==1)? results_i[5]  : p_sram_data_i[5]  + results_i[5] ;
assign p_sram_data[6]     = (current_ch==1)? results_i[6]  : p_sram_data_i[6]  + results_i[6] ;
assign p_sram_data[7]     = (current_ch==1)? results_i[7]  : p_sram_data_i[7]  + results_i[7] ;
assign p_sram_data[8]     = (current_ch==1)? results_i[8]  : p_sram_data_i[8]  + results_i[8] ;
assign p_sram_data[9]     = (current_ch==1)? results_i[9]  : p_sram_data_i[9]  + results_i[9] ;
assign p_sram_data[10]    = (current_ch==1)? results_i[10] : p_sram_data_i[10] + results_i[10] ;
assign p_sram_data[11]    = (current_ch==1)? results_i[11] : p_sram_data_i[11] + results_i[11] ;
assign p_sram_data[12]    = (current_ch==1)? results_i[12] : p_sram_data_i[12] + results_i[12] ;
assign p_sram_data[13]    = (current_ch==1)? results_i[13] : p_sram_data_i[13] + results_i[13] ;
assign p_sram_data[14]    = (current_ch==1)? results_i[14] : p_sram_data_i[14] + results_i[14] ;
assign p_sram_data[15]    = (current_ch==1)? results_i[15] : p_sram_data_i[15] + results_i[15] ;
assign p_sram_data[16]    = (current_ch==1)? results_i[16] : p_sram_data_i[16] + results_i[16] ;
assign p_sram_data[17]    = (current_ch==1)? results_i[17] : p_sram_data_i[17] + results_i[17] ;
assign p_sram_data[18]    = (current_ch==1)? results_i[18] : p_sram_data_i[18] + results_i[18] ;
assign p_sram_data[19]    = (current_ch==1)? results_i[19] : p_sram_data_i[19] + results_i[19] ;
assign p_sram_data[20]    = (current_ch==1)? results_i[20] : p_sram_data_i[20] + results_i[20] ;
assign p_sram_data[21]    = (current_ch==1)? results_i[21] : p_sram_data_i[21] + results_i[21] ;
assign p_sram_data[22]    = (current_ch==1)? results_i[22] : p_sram_data_i[22] + results_i[22] ;
assign p_sram_data[23]    = (current_ch==1)? results_i[23] : p_sram_data_i[23] + results_i[23] ;
assign p_sram_data[24]    = (current_ch==1)? results_i[24] : p_sram_data_i[24] + results_i[24] ;
assign p_sram_data[25]    = (current_ch==1)? results_i[25] : p_sram_data_i[25] + results_i[25] ;
assign p_sram_data[26]    = (current_ch==1)? results_i[26] : p_sram_data_i[26] + results_i[26] ;
assign p_sram_data[27]    = (current_ch==1)? results_i[27] : p_sram_data_i[27] + results_i[27] ;
assign p_sram_data[28]    = (current_ch==1)? results_i[28] : p_sram_data_i[28] + results_i[28] ;
assign p_sram_data[29]    = (current_ch==1)? results_i[29] : p_sram_data_i[29] + results_i[29] ;
assign p_sram_data[30]    = (current_ch==1)? results_i[30] : p_sram_data_i[30] + results_i[30] ;
assign p_sram_data[31]    = (current_ch==1)? results_i[31] : p_sram_data_i[31] + results_i[31] ;

assign p_sram_addr     = addr      ;

assign p_sram_rden     = rden      ;
        
endmodule
