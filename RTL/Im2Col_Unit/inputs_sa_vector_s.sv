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

module inputs_sa_vector_s import cvxif_pkg::*;
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
    output logic signed       [7:0]     inputs_o_0   [8:0]
    );
    
logic       started         = 0 ;
logic       finished_load   = 0 ;
logic [5:0] out             = 0 ;
logic [14:0] loads   ;
logic [14:0] jump   ;
logic [14:0] size   ;
logic [2:0] load_count     = 0 ;
logic       first_count     = 0 ;
logic last_count     = 0 ;
logic signed       [7:0] inputs_0   [5:0][8:0]= '{default: 8'b0};

logic signed       [7:0] constant   [3:0][8:0]= '{default: 8'b0};
w_load              signals = '0;
logic [ADR_W-1:0]           first_addr;
logic [ADR_W-1:0]           last_addr;

assign first_addr =  ((current_ch-1)*data.I_height*data.I_width)/4;
assign last_addr  =  ((current_ch)*data.I_height*data.I_width)/4;
assign jump = data.I_width/8 ;
assign size = data.I_height*jump ;
always_comb begin
    first_count  = (loads<3) ;
    last_count   = (loads > (size-4)) ;
end
always_ff @(posedge i_clk)begin
//    signals.inputs_start = inputs_start;
    if (started) begin 
        
        if (size == loads) begin 
            finished_load           = '1 ;
            o_sram_rden_0           = '0 ;


            if (out < 5)begin
                out                 = out + 1 ;
            end
            else begin
                finished_send       = '1 ;
            end
        end 
        else begin
                if (load_count == 3'b001 ) begin
                    inputs_0[1:0]             = inputs_0[5:4];

                    inputs_0[5:2]             = constant;

                    o_sram_addr_0             = o_sram_addr_0 + jump  ;

                    loads                     = loads + 1  ;
                    out                       = 0 ;
                    o_sram_rden_0             = o_sram_rden_0  ;

                    load_count                = load_count + 1 ; 
                                       
                    inputs_0[0][0]        = i_sram_data_0[7:0] ;

                                            
                    inputs_0[1][0]        = i_sram_data_0[23:16] ;

                                            
                    inputs_0[2][0]        = i_sram_data_0[39:32] ;            
            
           
                    inputs_0[3][0]        = (last_count)? 8'b0 :i_sram_data_0[55:48] ;            
                      
                end else        
                if (load_count == 3'b010 ) begin 
                    o_sram_addr_0         = o_sram_addr_0 -(2*jump)+1 ;

                    loads                 = loads + 1  ;
                    out                   = out + 1 ;
                    o_sram_rden_0         = o_sram_rden_0  ;

                    load_count            = load_count + 1 ;                
                    inputs_0[1][1]        = i_sram_data_0[7:0] ;

                                            
                    inputs_0[2][1]        = i_sram_data_0[23:16] ;

                                            
                    inputs_0[3][1]        = i_sram_data_0[39:32] ;            
          
           
                    inputs_0[4][1]        = (last_count)? 8'b0 :i_sram_data_0[55:48] ;            
                     
                end else        
                if (load_count == 3'b011) begin 
                    o_sram_addr_0         = o_sram_addr_0 ;

                    loads                 = loads + 1  ;
                    out                   = out + 1 ;
                    o_sram_rden_0         = o_sram_rden_0  ;

                    load_count            = 3'b000;                 
                    inputs_0[2][2]        = i_sram_data_0[7:0] ;

                                            
                    inputs_0[3][2]        = i_sram_data_0[23:16] ;

                                            
                    inputs_0[4][2]        = i_sram_data_0[39:32] ;            
           
           
                    inputs_0[5][2]        = (last_count)? 8'b0 :i_sram_data_0[55:48] ;            
                       
                end else begin
                    load_count              = load_count + 1 ;
                    o_sram_addr_0           = o_sram_addr_0 + jump  ;

                    loads                   = loads          ;
                    o_sram_rden_0           = o_sram_rden_0  ;

                    out                     = out + 1        ;
                end     
        end
        inputs_o_0  <= inputs_0[out];

    end 
    else if (inputs_start & !started & !finished_load ) begin 
        started                   <= '1 ;
        o_sram_rden_0             <= '1 ;
        o_sram_addr_0             <= '0 ;

        out                     <= '0 ;
        loads                   <= '0 ;
        load_count              <= 3'b000 ;
    end 
    started_o <= started ;
end


endmodule
