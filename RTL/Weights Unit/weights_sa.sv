`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2024 12:24:20 PM
// Design Name: 
// Module Name: weights_sa
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

module weights_sa import cvxif_pkg::*;
#(
    parameter ADR_W = 16,
    parameter SRAM_W = 32
    )(
    // Clk, RST
	input  logic 				        i_clk,
	input  logic					    i_rstn,    
    input  convolution                  data,
    input  logic                        weights_start,         // Output data bus towards Accelerator
    input  logic  [6:0]                 current_ch,

    output logic [ADR_W-1:0]            o_sram_addr,        // Address from Accelerator
    output logic                        o_sram_rden,        // Read Enable from Accelerator
    input  logic [SRAM_W-1:0]           i_sram_data,         // Output data bus towards Accelerator    
    
    output logic                        ended,         // Output data bus towards Accelerator
    output logic signed       [7:0]     weights_0   [288-1:0]        // Output data bus towards sa
    );
    
logic                       started = '0 ;
logic                       weights_valid = '0 ;
logic       [8:0]           element = '0 ;
logic [ADR_W-1:0]           addr= '0 ;
logic [ADR_W-1:0]           first_addr;
logic [ADR_W-1:0]           last_addr;
logic  [6:0]                channel= '0 ;

assign first_addr =  ((current_ch-1)*9*data.W_kernels)/4;
assign last_addr  =  ((current_ch)*9*data.W_kernels)/4;



always_ff @(posedge i_clk)begin

    if (started) begin 
        if ((addr == last_addr )) begin 
            weights_0[element-4]    <= i_sram_data[7:0];
            weights_0[element-3]    <= i_sram_data[15:8];
            weights_0[element-2]    <= i_sram_data[23:16];
            weights_0[element-1]    <= i_sram_data[31:24];   
            element                 <= element + 4 ;            
            started                 <= 0 ;
            weights_valid           <= 1 ;
            o_sram_rden             <= 0 ;
            ended                   <= 1 ;
            
//            signals.weights_start   <= 0 ;
        end else begin
            weights_0[element-4]    <= i_sram_data[7:0];
            weights_0[element-3]    <= i_sram_data[15:8];
            weights_0[element-2]    <= i_sram_data[23:16];
            weights_0[element-1]    <= i_sram_data[31:24];
            addr                    <= addr + 1 ;
            weights_valid           <= 0 ;
            o_sram_rden             <= 1 ;            
            element                 <= element + 4 ;            
            ended                   <= 0 ;
        end
    end  
    else if ((weights_start) && (!started) && (((channel!= current_ch)||(current_ch == 0)) && (addr!=last_addr))) begin /*& !ended*/
        started                 <= '1 ;
        o_sram_rden             <= '1 ;
        addr                    <= first_addr ;
        weights_valid           <= '0 ;
        element                 <= '0 ;
        channel                 <= current_ch ;
        ended                   <= 0 ;
        
    end else if (ended) begin
        ended                   <= 0 ;
    end
end

assign o_sram_addr=addr;
endmodule
