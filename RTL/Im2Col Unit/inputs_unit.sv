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

module inputs_unit import cvxif_pkg::*;
#(
    parameter ADR_W = 14,
    parameter SRAM_W = 64
    )(
    // Clk, RST
	input   logic 				        i_clk,
	input   logic					    i_rstn,    
	
    input   convolution                 data,
	input   logic                       w_square,       
    input   logic                       w_vector,    
    input   logic                       start,   
    input   logic                       stride,   
    output   logic                      finish,   
    input   logic  [6:0]                current_ch,
    
    output  logic [ADR_W-1:0]           o_sram_addr_0,        // Address from Accelerator
    output  logic                       o_sram_rden_0,        // Read Enable from Accelerator
    input   logic [SRAM_W-1:0]          i_sram_data_0,         // Output data bus towards Accelerator

    
    output  logic                       started_o,        // Read Enable from Accelerator
    output  logic signed       [7:0]    inputs_o_0   [8:0]        // Output data bus towards sa
    
    );
    
 /////////////////////////////////////////////////////
 /////////////////////////////////////////////////////
 logic [ADR_W-1:0]           vector_o_sram_addr_0;
 logic                       vector_o_sram_rden_0;        // Read Enable from Accelerator
 logic [SRAM_W-1:0]          vector_i_sram_data_0;         // Output data bus towards Accelerator
 logic                       vector_finish;
 logic signed       [7:0]    vector_inputs_o_0   [8:0];        // Output data bus towards sa
 /////////////////////////////////////////////////////
 /////////////////////////////////////////////////////
logic [ADR_W-1:0]   square_i_sram_addr_0;  
logic               square_i_sram_rden_0;      
logic [SRAM_W-1:0]  square_i_sram_data_o_0;  
logic                       square_finish;
logic              square_started_o;
logic signed       [7:0]    square_inputs_o_0   [8:0];
  ///////////////////////////////////////////////// /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
logic [ADR_W-1:0]   vector_i_sram_addr_0;  
logic               vector_i_sram_rden_0;      
logic [SRAM_W-1:0]  vector_i_sram_data_o_0;  
    
logic              vector_started_o;
logic signed       [7:0]    vector_inputs_o_0   [8:0];
  /////////////////////////////////////////////////
 /////////////////////////////////////////////////////
logic [ADR_W-1:0]   square_s_i_sram_addr_0;  
logic               square_s_i_sram_rden_0;      
logic [SRAM_W-1:0]  square_s_i_sram_data_o_0;  
logic                       square_s_finish;
logic              square_s_started_o;
logic signed       [7:0]    square_s_inputs_o_0   [8:0];
  ///////////////////////////////////////////////// /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
logic [ADR_W-1:0]   vector_s_i_sram_addr_0;  
logic               vector_s_i_sram_rden_0;      
logic [SRAM_W-1:0]  vector_s_i_sram_data_o_0;  
logic                       vector_s_finish;
logic              vector_s_started_o;
logic signed       [7:0]    vector_s_inputs_o_0   [8:0];

 /////////////////////////////////////////////////////
 /////////////////////////////////////////////////////
 assign o_sram_addr_0 = (w_square)? (stride)? square_s_i_sram_addr_0 : square_i_sram_addr_0 : (stride)? vector_s_i_sram_addr_0 : vector_i_sram_addr_0 ;
 assign o_sram_rden_0 = (w_square)? (stride)? square_s_i_sram_rden_0 : square_i_sram_rden_0 : (stride)? vector_s_i_sram_rden_0 : vector_i_sram_rden_0 ;
 assign finish        = (w_square)? (stride)? square_s_finish : square_finish : (stride)? vector_s_finish : vector_finish ;
 
 assign square_s_i_sram_data_o_0 = (w_square &&  stride)? i_sram_data_0 : 0;
 assign vector_s_i_sram_data_o_0 = (w_vector &&  stride)? i_sram_data_0 : 0;
 assign vector_i_sram_data_o_0   = (w_vector && !stride)? i_sram_data_0 : 0;
 assign square_i_sram_data_o_0   = (w_square && !stride)? i_sram_data_0 : 0;

 assign inputs_o_0    = (w_square)? (stride)? square_s_inputs_o_0 : square_inputs_o_0 : (stride)? vector_s_inputs_o_0 : vector_inputs_o_0 ;
 assign started_o     = (w_square)? (stride)? square_s_started_o : square_started_o : (stride)? vector_s_started_o : vector_started_o ;
 /////////////////////////////////////////////////////
 /////////////////////////////////////////////////////
    inputs_sa inputs_sa(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
    .data(data),
    .inputs_start(start && w_square && !stride),
    .finished_send(square_finish),
    .o_sram_addr_0(square_i_sram_addr_0),        // Address from Accelerator
    .o_sram_rden_0(square_i_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data_0(square_i_sram_data_o_0),   
	.current_ch(current_ch),
    
    .started_o(square_started_o),
    .inputs_o_0(square_inputs_o_0)
 );
  ///////////////////////////////////////////////// /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
    inputs_sa_vector inputs_sa_vector(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
    .data(data),
    .inputs_start(start && w_vector && !stride),
    .finished_send(vector_finish),
    .o_sram_addr_0(vector_i_sram_addr_0),        // Address from Accelerator
    .o_sram_rden_0(vector_i_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data_0(vector_i_sram_data_o_0),   
	.current_ch(current_ch),
    .started_o(vector_started_o),
    .inputs_o_0(vector_inputs_o_0)
 );
  /////////////////////////////////////////////////
 /////////////////////////////////////////////////////
    inputs_sa_s inputs_sa_s(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
    .data(data),
    .inputs_start(start && w_square && stride),
    .finished_send(square_s_finish),
    .o_sram_addr_0(square_s_i_sram_addr_0),        // Address from Accelerator
    .o_sram_rden_0(square_s_i_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data_0(square_s_i_sram_data_o_0),   
	.current_ch(current_ch),

    .started_o(square_s_started_o),
    .inputs_o_0(square_s_inputs_o_0)
 );
  ///////////////////////////////////////////////// /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
    inputs_sa_vector_s inputs_sa_vector_s(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
    .data(data),
    .inputs_start(start && w_vector && stride),
    .finished_send(vector_s_finish),
    .o_sram_addr_0(vector_s_i_sram_addr_0),        // Address from Accelerator
    .o_sram_rden_0(vector_s_i_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data_0(vector_s_i_sram_data_o_0),     
	.current_ch(current_ch),
    .started_o(vector_s_started_o),
    .inputs_o_0(vector_s_inputs_o_0)
 );
  /////////////////////////////////////////////////
    
endmodule
