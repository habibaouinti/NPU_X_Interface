`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2024 13:44:17
// Design Name: 
// Module Name: sa
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
// PE[0][0] --> PE[0][1] --> PE[0][2] .... --> PE[0][7]
//   |            |            |                  |           
//   v            v            v                  v           
// PE[1][0] --> PE[1][1] --> PE[1][2] .... --> PE[1][7]
//   |            |            |                  |           
//   v            v            v                  v           
// PE[2][0] --> PE[2][1] --> PE[2][2] .... --> PE[2][7]
//   |            |            |                  |           
//   v            v            v                  v            
// PE[3][0] --> PE[3][1] --> PE[3][2] .... --> PE[3][7]
//   |            |            |                  |            
//   .            .            .                  .          
//   .            .            .                  .           
//   v            v            v                  v           
// PE[8][0] --> PE[8][1] --> PE[8][2] .... --> PE[8][7]
(* DONT_TOUCH = "yes" *)

module sa import cvxif_pkg::*;
#(
	DATA_WIDTH = 8,
	PE_NUM = 16
	)(
	input logic clk,
	input logic rstn,
    input logic stop,
    input  convolution                  data,
    // accumulator enable
	input  logic started,
	// data input
    input logic signed  [7:0]            inputs_i_0 [ 8:0],  
	// data input
    input logic signed  [31:0]           bias_i_0   [32-1:0],  
	// weights
    input logic signed  [7:0]            weight_i [288-1:0],        // Output data bus towards sa
	// accumulator output
	output logic   [32-1:0]              sram_ready_o,
	output logic                         results_ready_o,
    output logic signed [31:0]           acc_o    [32-1:0]	
);

	// process element outputs
	logic signed [DATA_WIDTH-1:0] data_pe_0 [ 8:0][32-1:0];

    // intermediat accumulator result output
   	logic signed [31:0] acc_res_pe_0 [8:0][32-1:0];
	
	// constants
	logic zeros[8:0]='{default: 1'b0};
	logic ones [8:0]='{default: 1'b1};
	// acc element arrangment
//	logic signed [31:0] acc_res [ 4:0];	
	// weight enable element arrangment
	logic  [7 :0]sram = 0;
	logic  load_en = 0;
	logic  acc_en= '0;
	logic  results_ready = 0 ;
	logic  results_valid = 0 ;
	logic [20:0] i;
	logic start_load;
	logic end_load = 0;
	logic start = 0;
	// enable selection
always_ff @(posedge clk) begin
    if (start_load) begin
            i           = i + 1 ;
            if (i==1) begin
                load_en = '0;
                acc_en  = '1;
            end      
            if ((i[3:0] == 4'b0001)&&(data.W_width == 1)) begin
                results_valid = '1 ;
            end else
            if ((i[3:0] == 4'b0111)&&(data.W_width == 3))begin
                results_valid = '1 ;
            end 
            if (stop) begin
                start_load         = '1;
                end_load           = '1;
                acc_en             = '0;
                results_valid      = '0;
            end else 
            if (end_load) begin
                end_load           = '0;
                start_load         = '0;
            end
    end else    
    if (started & !end_load) begin
        load_en     = '1;
        start_load  = '1;
        i           = '0;
    end 
end
	// process element arrangment
genvar n,m;
generate
	for ( n=0; n<32; n=n+1 ) //columns
	begin
	   for ( m=0; m<9; m=m+1 )//rows
	   begin
           pe_ws pe_0 (
                        .clk(clk),
                        .rstn(rstn),
                        .acc_en(acc_en),
                        .load_en(load_en),
                        .data_i((n == 0)? inputs_i_0[m]: data_pe_0[m][n-1]),
                        .acc_i((m == 0)? bias_i_0[n]:acc_res_pe_0[m-1][n]),
                        .weight_i((data.W_width==1)? (m < 3)? weight_i[3*n+m]: 8'b0 :weight_i[9*n+m]),
                        .data_o(data_pe_0[m][n]),
                        .acc_o(acc_res_pe_0[m][n])
            ); 	   
	   end
	end
endgenerate

assign sram_ready_o     = sram;
assign results_ready_o  = results_valid;
assign acc_o            = (data.W_width == 1)? acc_res_pe_0[2]: acc_res_pe_0[8];
//assign acc_o            = (data.I_channels == 3)? acc_res_3:acc_res_2;
endmodule // systolic_array 