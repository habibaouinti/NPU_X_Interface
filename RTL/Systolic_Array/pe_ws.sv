/* PROCESS ELEMENT 
 * Parameters:
 * DATA_WIDTH - length of an n x n matrix
 * ACC_WIDTH  - accumulator size, depends on matrix size and how many iterations
 *		  	  - general rule should be n * datawidth * 2	
 */
 (* DONT_TOUCH = "yes" *)

module pe_ws #(
	parameter DATA_WIDTH = 8,
	parameter ACC_WIDTH = 32
	) (    
	input logic clk,
    input logic rstn,
	// enable
	input logic acc_en,
    input logic load_en, 
	// data a and b inputs
    input logic signed  [DATA_WIDTH - 1:0] data_i,
    input logic signed  [ACC_WIDTH - 1:0] acc_i,
	input logic signed  [DATA_WIDTH - 1:0] weight_i,
	// data a and b outputs
	output logic signed [DATA_WIDTH - 1:0] data_o,
	// output accumulator
	output logic signed 		[ACC_WIDTH  - 1:0] acc_o
    );
	
	logic signed [ACC_WIDTH  - 1:0] acc_r;
	logic signed [DATA_WIDTH - 1:0] data_r;
    logic signed [DATA_WIDTH - 1:0] weight_r;

	always_ff @(posedge clk, negedge rstn) begin
		if(!rstn) begin
			acc_r    <= '0;
			data_r   <= '0;
            weight_r <= '0;
		end else begin
			if (load_en) begin
                weight_r = weight_i;
            end
            if (acc_en) begin
                if ((data_i == 0) && (weight_r == 0)) begin
                    acc_r  = acc_i ;
                    data_r = data_i;
				end else begin
                    acc_r  = acc_i + (data_i * weight_r);
                    data_r = data_i;				
                end
			end
		end
	end
	
	assign acc_o    = acc_r;
	assign data_o   = data_r;

endmodule
