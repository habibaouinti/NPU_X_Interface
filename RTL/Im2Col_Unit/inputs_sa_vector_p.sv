`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2024 02:33:09 PM
// Design Name: 
// Module Name: inputs_sa_vector_p
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


module inputs_sa_vector_p import cvxif_pkg::*;
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
    
logic       started         = 0 ;
logic       finished_load   = 0 ;
logic [5:0] out             = 0 ;
logic [14:0] loads   ;
logic [14:0] size   ;
logic [3:0] load_count     = 0 ;
logic       first_count     = 0 ;
logic last_count     = 0 ;
logic signed       [7:0] inputs_0   [9:0][8:0] = '{default: 8'b0};
logic signed       [7:0] constant   [9:0][8:0] = '{default: 8'b0};
logic signed       [7:0] zeros      [ 8:0]      = '{default: 8'b0};
w_load              signals = '0;
assign size = data.I_height/8 ;
logic [ADR_W-1:0]           first_addr;
logic [ADR_W-1:0]           last_addr;

assign first_addr =  ((current_ch-1)*data.I_height*data.I_width)/4;
assign last_addr  =  ((current_ch)*data.I_height*data.I_width)/4;
always_comb begin
    first_count  = (loads <1) ;
    last_count   = (loads >=  size-1) ;
end
always_ff @(posedge i_clk)begin
//    signals.inputs_start = inputs_start;
    if (started) begin 
    started_o = 0 ;
        if (size == loads) begin 
            finished_load           = '1 ;
            o_sram_rden_0           = '0 ;
            o_sram_addr_0           = '0 ;
            if (out < 9)begin
                out                 = out + 1 ;
            end
            else begin
                finished_send       = '1 ;
                inputs_0            = '{default: 8'b0};       
                started             = '0 ;
            end
        end 
        else begin
                if (load_count == 4'b0001 ) begin
                    inputs_0              = constant;
                    o_sram_addr_0         = o_sram_addr_0 + 1   ;
                    loads                 = loads +1  ;
                    out                   = 0 ;
                    o_sram_rden_0         = o_sram_rden_0  ;
                    load_count            = load_count + 1 ;    
                    if (first_count) begin
                        inputs_0[0][0]        = 8'b0 ;
                        
                        inputs_0[1][0]        = i_sram_data_0[7:0] ;
                        inputs_0[1][1]        = i_sram_data_0[7:0] ;
    
                                                
                        inputs_0[2][0]        = i_sram_data_0[15: 8] ;
                        inputs_0[2][1]        = i_sram_data_0[15: 8] ;
                        inputs_0[2][2]        = i_sram_data_0[15: 8] ; 
    
                                                
                        inputs_0[3][0]        = i_sram_data_0[23:16] ;            
                        inputs_0[3][1]        = i_sram_data_0[23:16] ;             
                        inputs_0[3][2]        = i_sram_data_0[23:16] ;            
    
                                                
                        inputs_0[4][0]        = i_sram_data_0[31:24] ;            
                        inputs_0[4][1]        = i_sram_data_0[31:24] ;                 
                        inputs_0[4][2]        = i_sram_data_0[31:24] ;            
    
                        inputs_0[5][0]        = i_sram_data_0[39:32] ;            
                        inputs_0[5][1]        = i_sram_data_0[39:32] ;                 
                        inputs_0[5][2]        = i_sram_data_0[39:32] ;            
            
                                                
                        inputs_0[6][0]        = i_sram_data_0[47:40] ;            
                        inputs_0[6][1]        = i_sram_data_0[47:40] ;                 
                        inputs_0[6][2]        = i_sram_data_0[47:40] ;            
              
                                                
                        inputs_0[7][0]        = i_sram_data_0[55:48] ;            
                        inputs_0[7][1]        = i_sram_data_0[55:48] ;                 
                        inputs_0[7][2]        = i_sram_data_0[55:48] ;            
              
                                                
                        inputs_0[8][0]        = i_sram_data_0[63:56] ;            
                        inputs_0[8][1]        = i_sram_data_0[63:56] ;                   
                        inputs_0[8][2]        = i_sram_data_0[63:56] ;            
                    end else
                    begin
                        inputs_0[0][0]        = i_sram_data_0[7:0] ;
                        inputs_0[0][1]        = i_sram_data_0[7:0] ;
                        inputs_0[0][2]        = i_sram_data_0[7:0] ;
    
                                                
                        inputs_0[1][0]        = i_sram_data_0[15: 8] ;
                        inputs_0[1][1]        = i_sram_data_0[15: 8] ;
                        inputs_0[1][2]        = i_sram_data_0[15: 8] ; 
    
                                                
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
              
                                                
                        inputs_0[6][0]        = i_sram_data_0[55:48] ;            
                        inputs_0[6][1]        = i_sram_data_0[55:48] ;                 
                        inputs_0[6][2]        = i_sram_data_0[55:48] ;            
              
                                                
                        inputs_0[7][0]        = (last_count)? 8'b0 :i_sram_data_0[63:56] ;            
                        inputs_0[7][1]        = i_sram_data_0[63:56] ;                   
                        inputs_0[7][2]        = i_sram_data_0[63:56] ;     
                               
                        inputs_0[8][2]        = 8'b0 ;            
                     end                
                 end else        
                if ((load_count >= 4'b0010)&&(load_count < 4'b0111)) begin 
                    load_count              = load_count + 1 ;
                    o_sram_addr_0           = o_sram_addr_0  ;
                    loads                   = loads          ;
                    o_sram_rden_0           = o_sram_rden_0  ;
                    out                     = out + 1        ;                
                end else 
                if (load_count == 4'b0111) begin 
                    load_count              = (loads==1)? load_count+1 :4'b0000 ;  
                    o_sram_addr_0           = o_sram_addr_0  ;
                    loads                   = loads          ;
                    o_sram_rden_0           = o_sram_rden_0  ;
                    out                     = out + 1        ;                
                end else
                if (load_count == 4'b1000) begin 
                    load_count              = 4'b0000 ;  
                    o_sram_addr_0           = o_sram_addr_0  ;
                    loads                   = loads          ;
                    o_sram_rden_0           = o_sram_rden_0  ;
                    out                     = out + 1        ;                
                end else begin
                    load_count              = load_count +1 ;
                    o_sram_addr_0           = o_sram_addr_0  ;
                    loads                   = loads    ;
                    o_sram_rden_0           = o_sram_rden_0 ;
                    out                     = out + 1 ;
                    
                end     
            end

//        end
        inputs_o_0  <= (finished_send)? zeros : inputs_0[out];
    end 
    else if (inputs_start & !started) begin 
        started                 = '1 ;
        started_o               = '1 ;
        o_sram_rden_0           = '1 ;
        o_sram_addr_0           = '0 ;
        out                     = '0 ;
        loads                   = '0 ;
        finished_send           = '0 ;
        finished_load           = '0 ;
        load_count              = 4'b0000 ;
    end 
end


endmodule
