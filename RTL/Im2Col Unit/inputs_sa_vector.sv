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

module inputs_sa_vector import cvxif_pkg::*;
#(
    parameter ADR_W = 16,
    parameter SRAM_W = 64
    )(
    // Clk, RST
	input   logic 				        i_clk,
	input   logic					    i_rstn,    
	
    input   convolution                 data,
    input   logic                       inputs_start,         // Output data bus towards Accelerator
    output  logic                       finished_send,       
    output  logic [ADR_W-1:0]           o_sram_addr_0,        // Address from Accelerator
    output  logic                       o_sram_rden_0,        // Read Enable from Accelerator
    input   logic [SRAM_W-1:0]          i_sram_data_0,         // Output data bus towards Accelerator
    input   logic  [6:0]                current_ch,

    
    output  logic                       started_o,        // Read Enable from Accelerator
    output logic signed       [7:0]     inputs_o_0   [8:0]       // Output data bus towards sa
    );
    
    logic                       p_finished_send;
    logic [ADR_W-1:0]           p_o_sram_addr_0;        // Address from Accelerator
    logic                       p_o_sram_rden_0;
    logic                       p_started_o;      // Read Enable from Accelerator
    logic signed       [7:0]    p_inputs_o_0 [8:0] ;
  ///////////////////////////////////////////////// 
    logic                       np_finished_send;
    logic [ADR_W-1:0]           np_o_sram_addr_0;        // Address from Accelerator
    logic                       np_o_sram_rden_0;
    logic                       np_started_o;      // Read Enable from Accelerator
    logic signed       [7:0]    np_inputs_o_0 [8:0];
 
  /////////////////////////////////////////////////////
  assign finished_send = (data.padding)? p_finished_send : np_finished_send ;
  assign o_sram_addr_0 = (data.padding)? p_o_sram_addr_0 : np_o_sram_addr_0 ;
  assign o_sram_rden_0 = (data.padding)? p_o_sram_rden_0 : np_o_sram_rden_0 ;
  assign started_o     = (data.padding)? p_started_o     : np_started_o     ;
  assign inputs_o_0    = (data.padding)? p_inputs_o_0    : np_inputs_o_0    ;
  /////////////////////////////////////////////////////
    inputs_sa_vector_p inputs_sa_vector_p(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
    .data(data),
    .inputs_start(inputs_start && data.padding),
    .finished_send(p_finished_send),
    .o_sram_addr_0(p_o_sram_addr_0),        // Address from Accelerator
    .o_sram_rden_0(p_o_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data_0(i_sram_data_0),   
	.current_ch(current_ch),
    .started_o(p_started_o),
    .inputs_o_0(p_inputs_o_0)
 );
  /////////////////////////////////////////////////  ///////////////////////////////////////////////// /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
    inputs_sa_vector_np inputs_sa_vector_np(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
    .data(data),
    .inputs_start(inputs_start && !data.padding),
    .finished_send(np_finished_send),
    .o_sram_addr_0(np_o_sram_addr_0),        // Address from Accelerator
    .o_sram_rden_0(np_o_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data_0(i_sram_data_0),   
	.current_ch(current_ch),
    .started_o(np_started_o),
    .inputs_o_0(np_inputs_o_0)
 );
  /////////////////////////////////////////////////

endmodule
