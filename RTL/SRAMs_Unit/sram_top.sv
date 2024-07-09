`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2024 11:25:51 AM
// Design Name: 
// Module Name: sram_top
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

module sram_top import cvxif_pkg::*;
#(
    parameter IF_W = 32,
    parameter IF_ADR_W = 16,

    parameter ADR_W = 12,
    parameter ADR_I = 14,
    parameter ADR_P = 11,
    parameter SRAM_I = 64,
    parameter SRAM_W = 32,
    parameter SRAM_P = 32
)(
    // Clk, RST
	input  logic 				        i_clk,
	input  logic					    i_rstn,
    input  cntr                         controls,

    // Host-side Interface
    input  logic [IF_W-1:0]             i_data,             // Input data bus from Host
    input  logic [IF_ADR_W-1:0]         i_address,          // Address from Host 
    input  logic [2:0]                  i_wren,             // Wite enable from Host
    input  logic [64-1:0]               i_wmask,           // Write mask bus
    input  logic [5:0]                  out_nb,             // Read enable from Host 
    input  logic [64-1:0]               sram_ready_o,             // Read enable from Host 
	output logic [SRAM_P-1:0]           o_data_out,         // Output data bus towards Host
	input  logic                        out,         // Output data bus towards Host
 
    // Accelerator-side Interface WEIGHTS
    input  logic [SRAM_W-1:0]           w_sram_data_0,        // Input data bus from Accelerator
    input  logic [ADR_W-1:0]            w_sram_addr_0,        // Address from Accelerator
    input  logic                        w_sram_rden_0,        // Read Enable from Accelerator
    output logic [SRAM_W-1:0]           w_sram_data_o_0,         // Output data bus towards Accelerator
       
    // Accelerator-side Interface INPUTS
    input  logic [SRAM_I-1:0]           i_sram_data_0,        // Input data bus from Accelerator
    input  logic [ADR_I-1:0]            i_sram_addr_0,        // Address from Accelerator
    input  logic                        i_sram_rden_0,        // Read Enable from Accelerator
    output logic [SRAM_I-1:0]           i_sram_data_o_0,         // Output data bus towards Accelerator

    // Accelerator-side Interface PSUMS
    input  logic [SRAM_P-1:0]           p_sram_data   [32-1:0],        // Input data bus from Accelerator
    input  logic [ADR_P-1:0]            p_sram_addr           ,        // Address from Accelerator
    input  logic                        p_sram_rden           ,        // Read Enable from Accelerator
    output logic [SRAM_P-1:0]           p_sram_data_o [32-1:0]        // Output data bus towards Accelerator
);

localparam mask1 = 64'h00000000FFFFFFFF;
localparam mask2 = 64'hFFFFFFFF00000000;

    // Inputs
logic                        i_rdwen;
logic [ADR_I-1:0]            i_addr_0;
logic [ADR_I-1:0]            i_addr_1;
logic [ADR_I-1:0]            i_addr_2;
logic [SRAM_I-1:0]           i_indata_0;
logic [SRAM_I-1:0]           i_indata_1;
logic [SRAM_I-1:0]           i_indata_2;   
logic [SRAM_I-1:0]           input_data;    
    // weights
logic                        w_rdwen;
logic [ADR_W-1:0]            w_addr;
logic [SRAM_W-1:0]           w_indata;
logic [SRAM_W-1:0]           w_outdata;


    // Inputs
//assign i_rdwen          = (execute)? i_sram_rden : !i_wren[0];
assign i_addr_0           = (controls.loadi)? i_address : i_sram_addr_0;

assign i_indata_0         = (controls.loadi)? input_data    : i_sram_data_0;
//assign i_sram_data_o    = (i_sram_rden[2])? dataout3 : (i_sram_rden[1])? dataout2 : dataout1;

    // weights
//assign w_rdwen      = (execute)? w_sram_rden : !i_wren[3];
assign w_addr       = (controls.loadw)?  i_address: w_sram_addr_0;
assign w_indata     = (controls.loadw)? i_data        : w_sram_data_0  ;

always_comb begin
    if (i_wmask == mask1) begin
        input_data  = {32'h0 ,i_data };
    end else
    if (i_wmask == mask2) begin
        input_data  = {i_data, 32'h0 };
    end
end


assign o_data_out = p_sram_data_o[out_nb] ;
// SRAM Inputs 1
ram_inferred#(
    .ADR_W(ADR_I),
    .SRAM_W(64)
) sram_Inputs_0(
        .i_clk          (i_clk),
        .i_rstn         (i_rstn),
        .i_cen          ('0),
        .i_rdwen        ((controls.execute)? 1'b1 : !i_wren[0]),
        .i_addr         (i_addr_0),
        .i_indata       (i_indata_0),
        .i_wmask        (i_wmask),
        .o_outdata      (i_sram_data_o_0)
);

// SRAM Weights 1
ram_inferred#(
    .ADR_W(ADR_W),
    .SRAM_W(32)
) sram_Weights_0(
        .i_clk          (i_clk),
        .i_rstn         (i_rstn),
        .i_cen          ('0),
        .i_rdwen        ((controls.execute)? 1'b1 : !i_wren[1]),
        .i_addr         (w_addr),
        .i_indata       (w_indata),
        .i_wmask        (32'hFFFFFFFF),
        .o_outdata      (w_sram_data_o_0)
);

genvar n;
generate
	for ( n=0; n<32; n=n+1 ) 
	begin
        // SRAM Psum 
        ram_psum#(
            .ADR_W(ADR_P),
            .SRAM_W(SRAM_P)
        ) sram_Psum(
                .i_clk          (i_clk),
                .i_rstn         (i_rstn),
                .i_cen          ('0),
//                .i_rdwen        (p_sram_rden),
                .i_rdwen        ((out)? i_wren[2] :p_sram_rden),
//                .i_addr         (p_sram_addr),
                .i_addr         ((out)? i_address :p_sram_addr),
                .i_indata       (p_sram_data[n]),
                .i_wmask        (32'hFFFFFFFF),
                .o_outdata      (p_sram_data_o[n])
        );
	end
endgenerate


endmodule
