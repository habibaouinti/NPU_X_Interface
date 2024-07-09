`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2024 10:19:18 AM
// Design Name: 
// Module Name: input_sa_np
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

module input_sa_np import cvxif_pkg::*;
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
    
logic       started         = 0 ;
logic       finished_load   = 0 ;
logic [5:0] out             = 0 ;
logic [14:0] loads   ;
logic [14:0] jump_count   ;
logic [14:0] jump   ;
logic [14:0] size   ;
logic [2:0] load_count     = 0 ;
logic       first_count     = 0 ;
logic last_count     = 0 ;
logic signed       [7:0] inputs_0   [13:0][8:0]= '{default: 8'b0};
logic signed       [7:0] constant   [7:0][8:0]= '{default: 8'b0};
logic signed       [7:0] zeros   [8:0]= '{default: 8'b0};
w_load              signals = '0;
logic [ADR_W-1:0]           first_addr;
logic [ADR_W-1:0]           last_addr;

assign first_addr =  ((current_ch-1)*data.I_height*data.I_width)/4;
assign last_addr  =  ((current_ch)*data.I_height*data.I_width)/4;
assign jump = data.I_width/8 ;
assign size = 3*(data.I_height-data.W_height+1)*jump ;
always_comb begin
    first_count  = (loads<3 || jump_count%jump ==1 )&&started ;
    last_count   = ((loads > (size-4)) || ((jump_count%jump ==0)&&(jump_count!=0))) && started ;
end
always_ff @(posedge i_clk)begin
    if (started) begin 
    started_o = 0 ;
        if (size == loads) begin 
            finished_load           = '1 ;
            o_sram_rden_0           = '0 ;
            o_sram_addr_0           = '0 ;
            if (out < 13)begin
                out                 = out + 1 ;
            end
            else begin
                finished_send       = '1 ;
                started             = '0 ;
                inputs_0            = '{default: 8'b0};
            end
        end 
        else begin
                if (load_count == 3'b001 ) begin
                    inputs_0[5:0]             = inputs_0[13:8];
                    inputs_0[13:6]            = constant;
                    o_sram_addr_0             = o_sram_addr_0 + jump  ;
                    loads                     = loads + 1  ;
                    out                       = 0 ;
                    o_sram_rden_0             = o_sram_rden_0  ;
                    load_count                = load_count + 1 ; 
                                       
                    inputs_0[0][0]        = i_sram_data_0[7:0] ;
                    inputs_0[0][1]        = (first_count)  ? 8'b0 :i_sram_data_0[7:0] ;
                    inputs_0[0][2]        = (first_count)  ? 8'b0 :i_sram_data_0[7:0] ;

                                            
                    inputs_0[1][0]        = i_sram_data_0[15: 8] ;
                    inputs_0[1][1]        = i_sram_data_0[15: 8] ;
                    inputs_0[1][2]        = (first_count)? 8'b0 :i_sram_data_0[15: 8] ; 

                                            
                    inputs_0[2][0]        = i_sram_data_0[23:16] ;            
                    inputs_0[2][1]        = i_sram_data_0[23:16] ;             
                    inputs_0[2][2]        = i_sram_data_0[23:16] ;            

                                            
                    inputs_0[3][0]        = i_sram_data_0[31:24] ;            
                    inputs_0[3][1]        = i_sram_data_0[31:24] ;                 
                    inputs_0[3][2]        = i_sram_data_0[31:24] ;            

                    inputs_0[4][0]        = i_sram_data_0[39:32] ;            
                    inputs_0[4][1]        = i_sram_data_0[39:32] ;                 
                    inputs_0[4][2]        = i_sram_data_0[39:32] ;            
        
                                            
                    inputs_0[5][0]        = i_sram_data_0[47:40] ;            
                    inputs_0[5][1]        = i_sram_data_0[47:40] ;                 
                    inputs_0[5][2]        = i_sram_data_0[47:40] ;            
          
                                            
                    inputs_0[6][0]        = (last_count)? 8'b0 :i_sram_data_0[55:48] ;            
                    inputs_0[6][1]        = i_sram_data_0[55:48] ;                 
                    inputs_0[6][2]        = i_sram_data_0[55:48] ;            
          
                                            
                    inputs_0[7][0]        = (last_count)? 8'b0 :i_sram_data_0[63:56] ;            
                    inputs_0[7][1]        = (last_count)? 8'b0 :i_sram_data_0[63:56] ;                   
                    inputs_0[7][2]        = i_sram_data_0[63:56] ;            
          
                end else        
                if (load_count == 3'b010 ) begin 
                    o_sram_addr_0             = o_sram_addr_0 -(2*jump)+1 ;
                    loads                   = loads + 1  ;
                    out                     = out + 1 ;
                    o_sram_rden_0             = o_sram_rden_0  ;
                    load_count              = load_count + 1 ;                
                    inputs_0[3][3]        = i_sram_data_0[7:0] ;
                    inputs_0[3][4]        = (first_count)? 8'b0 :i_sram_data_0[7:0] ;
                    inputs_0[3][5]        = (first_count)? 8'b0 :i_sram_data_0[7:0] ;

                                            
                    inputs_0[4][3]        = i_sram_data_0[15: 8] ;
                    inputs_0[4][4]        = i_sram_data_0[15: 8] ; 
                    inputs_0[4][5]        = (first_count)? 8'b0 :i_sram_data_0[15: 8] ;

                                            
                    inputs_0[5][3]        = i_sram_data_0[23:16] ;          
                    inputs_0[5][4]        = i_sram_data_0[23:16] ;             
                    inputs_0[5][5]        = i_sram_data_0[23:16] ;            

                                            
                    inputs_0[6][3]        = i_sram_data_0[31:24] ;           
                    inputs_0[6][4]        = i_sram_data_0[31:24] ;     
                    inputs_0[6][5]        = i_sram_data_0[31:24] ;            
 
                                            
                    inputs_0[7][3]        = i_sram_data_0[39:32] ;           
                    inputs_0[7][4]        = i_sram_data_0[39:32] ;     
                    inputs_0[7][5]        = i_sram_data_0[39:32] ;            
       
                                            
                    inputs_0[8][3]        = i_sram_data_0[47:40] ;           
                    inputs_0[8][4]        = i_sram_data_0[47:40] ;     
                    inputs_0[8][5]        = i_sram_data_0[47:40] ;            
           
                                            
                    inputs_0[9][3]        = (last_count)? 8'b0 :i_sram_data_0[55:48] ;            
                    inputs_0[9][4]        = i_sram_data_0[55:48] ;     
                    inputs_0[9][5]        = i_sram_data_0[55:48] ;            
         
                                            
                    inputs_0[10][3]        = (last_count)? 8'b0 :i_sram_data_0[63:56] ;          
                    inputs_0[10][4]        = (last_count)? 8'b0 :i_sram_data_0[63:56] ;      
                    inputs_0[10][5]        = i_sram_data_0[63:56] ;            
           
                end else        
                if (load_count == 3'b011) begin 
                    o_sram_addr_0         = o_sram_addr_0 ;
                    loads                 = loads + 1  ;
                    out                   = out + 1 ;
                    o_sram_rden_0         = o_sram_rden_0  ;
                    load_count            = load_count + 1 ;                 
                    inputs_0[6][6]        = i_sram_data_0[7:0] ;
                    inputs_0[6][7]        = (first_count)? 8'b0 :i_sram_data_0[7:0] ;
                    inputs_0[6][8]        = (first_count)? 8'b0 :i_sram_data_0[7:0] ;

                                            
                    inputs_0[7][6]        = i_sram_data_0[15: 8] ;
                    inputs_0[7][7]        = i_sram_data_0[15: 8] ; 
                    inputs_0[7][8]        = (first_count)? 8'b0 :i_sram_data_0[15: 8] ;

                                            
                    inputs_0[8][6]        = i_sram_data_0[23:16] ;          
                    inputs_0[8][7]        = i_sram_data_0[23:16] ;             
                    inputs_0[8][8]        = i_sram_data_0[23:16] ;            

                                            
                    inputs_0[9][6]        = i_sram_data_0[31:24] ;           
                    inputs_0[9][7]        = i_sram_data_0[31:24] ;     
                    inputs_0[9][8]        = i_sram_data_0[31:24] ;            
        
                                            
                    inputs_0[10][6]        = i_sram_data_0[39:32] ;           
                    inputs_0[10][7]        = i_sram_data_0[39:32] ;     
                    inputs_0[10][8]        = i_sram_data_0[39:32] ;                    
                                            
                    inputs_0[11][6]        = i_sram_data_0[47:40] ;           
                    inputs_0[11][7]        = i_sram_data_0[47:40] ;     
                    inputs_0[11][8]        = i_sram_data_0[47:40] ;                      
                                            
                    inputs_0[12][6]        = (last_count)? 8'b0 :i_sram_data_0[55:48] ;            
                    inputs_0[12][7]        = i_sram_data_0[55:48] ;     
                    inputs_0[12][8]        = i_sram_data_0[55:48] ;                       
                                            
                    inputs_0[13][6]        = (last_count)? 8'b0 :i_sram_data_0[63:56] ;          
                    inputs_0[13][7]        = (last_count)? 8'b0 :i_sram_data_0[63:56] ;      
                    inputs_0[13][8]        = i_sram_data_0[63:56] ;                                 
                end else 
                if ((load_count >= 3'b100)&&(load_count < 3'b111)) begin 
                    load_count              = load_count + 1 ;
                    o_sram_addr_0           = o_sram_addr_0  ;
                    loads                   = loads          ;
                    o_sram_rden_0           = o_sram_rden_0  ;
                    out                     = out + 1        ;                
                end else 
                if (load_count == 3'b111) begin 
                    load_count              = 3'b000         ;
                    o_sram_addr_0           = o_sram_addr_0  ;
                    loads                   = loads          ;
                    o_sram_rden_0           = o_sram_rden_0  ;
                    out                     = out + 1        ;                
                end else begin
                    load_count              = load_count + 1 ;
                    o_sram_addr_0           = o_sram_addr_0 + jump  ;
                    loads                   = loads          ;
                    o_sram_rden_0           = o_sram_rden_0  ;
                    out                     = out + 1        ;
                    jump_count              = jump_count + 1  ;
                end     
            end

//        end
        inputs_o_0  <= (finished_send)? zeros : inputs_0[out];
    end 
    else if ((inputs_start) && !(started)) begin 
        started                 = '1 ;
        started_o               = '1 ;
        o_sram_rden_0           = '1 ;
        o_sram_addr_0           = '0 ;
        out                     = '0 ;
        loads                   = '0 ;
        jump_count              = '0 ;
        finished_load           = '0 ;
        finished_send           = '0 ;
        load_count              = 3'b000 ;
    end 
end


endmodule
