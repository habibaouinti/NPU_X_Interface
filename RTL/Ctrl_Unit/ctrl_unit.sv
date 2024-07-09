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

module ctrl_unit import cvxif_pkg::*;
(
    // Clk, RST
	input  logic 				        i_clk,
	input  logic					    i_rstn,    
    input  logic                        start,
    input  logic                        w_ended,
    input  logic                        results_ready,
    input  logic                        finished,
    input  convolution                  data,
    
    output  logic  [6:0]                current_ch,
    output  logic                       start_w_load,
    output  logic                       load,
	output  logic					    out    
    );
logic       started = '0;
logic       ended   = '0;
logic       hold1   = '0;
logic       hold2   = '0;
logic       hold3   = '0;
logic [6:0] count   = '0;

always_ff @(posedge i_clk) begin
    if (w_ended) begin
        start_w_load    = '0        ;
    end
    if (started) begin
        if (finished) begin
            count   = count + 1;
            if (count-1 == data.I_channels) begin 
                ended           = '1 ;
                start_w_load    = '0 ;
                started         = '0 ;
            end else
            begin 
                ended          = '0 ;
                start_w_load   = '1 ;
            end                        
        end else begin
            count           = count         ;
            start_w_load    = start_w_load  ;
            ended           = ended  ;
            started         = started  ;
        end 
        
    end else
    if ( start && !started && !ended )begin
        started         = '1        ;
        start_w_load    = '1        ;
        ended           = '0        ;
        load            = '0        ;
        count           = 7'b0000001;
    end else
    begin
        start_w_load    = '0        ;
        count           = '0        ;
        started         = '0        ;    
    end
    if (hold3) begin
        load   = '1 ;
    end else
    if (hold2) begin
        hold3  = '1 ;
    end else
    if (hold1) begin
        hold2  = '1 ;
    end else
    if (ended) begin
        hold1  = '1 ;
    end

end


assign out          = ended ;
assign current_ch   = count ;
endmodule
