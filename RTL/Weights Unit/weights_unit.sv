`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2024 01:47:41 PM
// Design Name: 
// Module Name: weights_unit
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


module weights_unit import cvxif_pkg::*;
#(
    parameter ADR_W = 16,
    parameter SRAM_W = 32
    )(
    // Clk, RST
	input  logic 				        i_clk,
	input  logic					    i_rstn,    
	input  logic                        w_square,       
    input  logic                        w_vector,
    input  convolution                  data,
    input  logic                        weights_start,         // Output data bus towards Accelerator
    input  logic  [6:0]                 current_ch,
    
    output logic                        ended,         // Output data bus towards Accelerator
    output logic [ADR_W-1:0]            o_sram_addr,        // Address from Accelerator
    output logic                        o_sram_rden,        // Read Enable from Accelerator
    input  logic [SRAM_W-1:0]           i_sram_data,         // Output data bus towards Accelerator    
    
    
    output logic signed       [7:0]     weights_0   [288-1:0]        // Output data bus towards sa
    );


logic [ADR_W-1:0]            square_addr;
logic [ADR_W-1:0]            vector_addr;
logic                        square_rden;
logic                        vector_rden;
logic                        square_ended;
logic                        vector_ended;
logic                        square_start;
logic                        vector_start;
wire signed       [7:0]     weights_square   [288-1:0];
wire signed       [7:0]     weights_vector   [288-1:0];

assign o_sram_addr = (w_square)? square_addr    : vector_addr ;
assign o_sram_rden = (w_square)? square_rden    : vector_rden ;
assign weights_0   = (w_square)? weights_square : weights_vector ;
assign ended       = (w_square)? square_ended   : vector_ended ;


  weights_sa weights_sa(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
		
    .data(data),
    .weights_start(weights_start && w_square),  
    .ended(square_ended),  
	.current_ch(current_ch),
     
    .o_sram_addr(square_addr),        // Address from Accelerator
    .o_sram_rden(square_rden),        // Read Enable from Accelerator
    .i_sram_data(i_sram_data),   

    .weights_0(weights_square)
 );

  weights_sa_vector weights_sa_vector(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
		
    .data(data),
    .weights_start(weights_start && w_vector),  
    .ended(vector_ended),  
	.current_ch(current_ch),
     
    .o_sram_addr(vector_addr),        // Address from Accelerator
    .o_sram_rden(vector_rden),        // Read Enable from Accelerator
    .i_sram_data(i_sram_data),   

    .weights_0(weights_vector)
 );

endmodule
