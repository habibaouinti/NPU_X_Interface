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

module inputs_sa import cvxif_pkg::*;
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
    output logic signed       [7:0]     inputs_o_0   [8:0]        // Output data bus towards sa
    );
    
  /////////////////////////////////////////////////////
logic        [ADR_W-1:0]    o_sram_addr_p;
logic                       o_sram_rden_p;
logic                       finished_send_p;
logic                       n_started_o;
logic signed       [7:0]    n_inputs_o_0   [8:0] ;
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
logic [ADR_W-1:0]           o_sram_addr_np;
logic                       o_sram_rden_np;
logic                       finished_send_np;
logic                       np_started_o;
logic signed       [7:0]    np_inputs_o_0   [8:0] ;
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  assign o_sram_addr_0 = (data.padding)? o_sram_addr_p   : o_sram_addr_np;
  assign o_sram_rden_0 = (data.padding)? o_sram_rden_p   : o_sram_rden_np;
  assign started_o     = (data.padding)? n_started_o     : np_started_o  ;
  assign inputs_o_0    = (data.padding)? n_inputs_o_0    : np_inputs_o_0 ;
  assign finished_send = (data.padding)? finished_send_p : finished_send_np ;
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
    input_sa_np inputs_sa_np(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	
    .data(data),
    .inputs_start(inputs_start && !data.padding),
    .finished_send(finished_send_np),
    .o_sram_addr_0(o_sram_addr_np),        // Address from Accelerator
    .o_sram_rden_0(o_sram_rden_np),        // Read Enable from Accelerator
    .i_sram_data_0(i_sram_data_0),   
	.current_ch(current_ch),
    .started_o(np_started_o),
    .inputs_o_0(np_inputs_o_0)
 );
  /////////////////////////////////////////////////
 /////////////////////////////////////////////////////
    input_sa_p inputs_sa_p(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
    .finished_send(finished_send_p),
    .data(data),
    .inputs_start(inputs_start && data.padding),
	.current_ch(current_ch),
    .o_sram_addr_0(o_sram_addr_p),        // Address from Accelerator
    .o_sram_rden_0(o_sram_rden_p),        // Read Enable from Accelerator
    .i_sram_data_0(i_sram_data_0),   
    

    .started_o(n_started_o),
    .inputs_o_0(n_inputs_o_0)
 );
  ///////////////////////////////////////////////// /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////


endmodule
