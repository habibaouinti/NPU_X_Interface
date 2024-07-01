`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2024 10:23:11 AM
// Design Name: 
// Module Name: coprocessor
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
module coprocessor import cvxif_pkg::*;
(
        input logic              clk_i,
        input logic              rst_ni,

        cv32e40x_if_xif.coproc_compressed xif_compressed,
        cv32e40x_if_xif.coproc_issue      xif_issue,
        cv32e40x_if_xif.coproc_commit     xif_commit,
        cv32e40x_if_xif.coproc_mem        xif_mem,
        cv32e40x_if_xif.coproc_mem_result xif_mem_result,
        cv32e40x_if_xif.coproc_result     xif_result
    );
    //Declarations

    wire   [4:0] rd,id;
    //Decoder outputs
    convolution         data ;
    cntr                controls;
    logic               mem_valid;
    logic [31:0]        last_addr ;
    logic [31:0]        caddr = '0 ;
/////////////////////////////////////////////////////
//Control Unit
/////////////////////////////////////////////////////
logic                        start;
logic                        finished;
logic                        finish;
    
logic  [6:0]                current_ch;
logic                       start_w_load;
logic                       start_i_load;
logic                       wb_load;
logic					    out;
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////    
    logic [5:0]         out_nb;
    logic [15:0]        out_count;
    logic [15:0]        out_width;
    logic [31:0]        out_size;
    logic [31:0]        out_image;
    logic [15:0]        out_height;
    logic [31:0]        kernel_size;
    logic [31:0]        kernel_size_channel;
    logic [31:0]        input_size;
    logic [31:0]        input_size_channel;
    //ISSUE INTERFACE
    x_issue_req_t       issue_req_i;
    x_issue_resp_t      issue_resp_o;
    logic               issue_valid_i;
    logic               issue_ready_o;
    // SRAM LOGIC
    logic [32-1:0]      mem_results;             // Input data bus from Host
    logic [64-1:0]      i_wmask   = '0;             // Input data bus from Host
    logic [15:0]        i_address = '0;         // Address from Host 
    logic [15:0]        zero_skip = '0;         // Address from Host 
    logic               addr_nb;          // Address from Host 
    logic [32-1:0]      srama_data,sramb_data;         // Output data bus towards Host
    logic [2:0]         sram_wren;
    logic [2:0]         we;
  //Result interface
  logic                 load_start;
  logic                 load_finish = 0;
  logic                 load_done;
  logic                 wload_finish;
  logic                 iload_finish;
  logic                 result_valid;
  logic                 mem_result_valid;
  logic                 mem_ready;
  logic                 mem_we;
/////////////////////////////////////////////////////
// weight UNIT 
/////////////////////////////////////////////////////	
logic [15:0]            w_sram_addr_0;        // Address from Accelerator
logic                   w_sram_rden_0;        // Read Enable from Accelerator
logic [31:0]            w_sram_data_0;         // Output data bus towards Accelerator   
logic [31:0]            w_sram_data_o_0;         // Output data bus towards Accelerator   
logic signed  [7:0]     weights_0  [288-1:0]   ;         // Output data bus towards sa
logic                   weights_valid ;        // Output data bus towards sa  
logic                   w_square ;        // Output data bus towards sa  
logic                   w_vector ;        // Output data bus towards sa  
logic                   w_ended ;        // Output data bus towards sa  
/////////////////////////////////////////////////////
  // input UNIT 
/////////////////////////////////////////////////////	
logic [14-1:0]          i_sram_addr_0;        // Address from Accelerator
logic                   i_sram_rden_0;        // Read Enable from Accelerator
logic [63:0]            i_sram_data_0;         // Output data bus towards Accelerator   
logic [63:0]            i_sram_data_o_0;         // Output data bus towards Accelerator   
logic signed       [7:0]     inputs_o_0   [8:0] ;         // Output data bus towards sa
logic signed       [7:0]     inputs_vector_0   [8:0] ;         // Output data bus towards sa
logic                   inputs_valid ;        // Output data bus towards sa  
logic  [1:0]          sram ;        // Output data bus towards sa  
/////////////////////////////////////////////////////	
/////////////////////////////////////////////////////
  // Partial SUMS UNIT 
/////////////////////////////////////////////////////	
logic [32-1:0]           wdata;        // Input data bus from Accelerator
logic [32-1:0]           o_data_out;        // Input data bus from Accelerator
logic [32-1:0]           p_sram_data  [32-1:0];        // Input data bus from Accelerator
logic [11-1:0]           p_sram_addr  ;        // Address from Accelerator
logic                    p_sram_rden  ;        // Read Enable from Accelerator
logic [32-1:0]           p_sram_data_o[32-1:0];         // Output data bus towards Accelerator

logic               done;
/////////////////////////////////////////////////////	
  // sa UNIT 
logic                   started_o;
logic                   stop;
logic signed  [31:0]    bias_i_0   [32-1:0]= '{default: 31'b0};
logic signed  [31:0]    acc_o      [32-1:0];
logic results_ready;
logic [7:0] sram_ready_o;
/////////////////////////////////////////////////////
  // Constants
/////////////////////////////////////////////////////	
/////////////////////////////////////////////////////	
/////////////////////////////////////////////////////	

    //the x interface
   
    //COMPRESSED INTERFACE - NOT USED
    assign xif_compressed.compressed_ready = '0;
    assign xif_compressed.compressed_resp  = '0;

    //ISSUE INTERFACE
    assign issue_req_i           = xif_issue.issue_req;
    assign xif_issue.issue_resp  = issue_resp_o;
    assign issue_valid_i         = xif_issue.issue_valid;
    assign rd                    = issue_req_i.instr[11:7];
    assign xif_issue.issue_ready = '1;

//    assign xif_issue.issue_ready = apu_gnt; 
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
//decoder
/////////////////////////////////////////////////////

co_decoder decoder (
      .clk_i           (clk_i),
      .issue_valid_i   (issue_valid_i),
      .issue_req_i     (issue_req_i),
      .issue_resp_o    (issue_resp_o),
      .controls        (controls),
      .data            (data)
);
/////////////////////////////////////////////////////
//Control Unit
/////////////////////////////////////////////////////
ctrl_unit control(
      .i_clk(clk_i),
	  .i_rstn(rst_ni),
	  .start(controls.execute),
	  .w_ended(w_ended),
	  .results_ready(results_ready),
	  .finished(done),
	  .data(data),
	  
	  .current_ch(current_ch),
	  .start_w_load(start_w_load),
	  .load(wb_load),
	  .out(out)
);
/////////////////////////////////////////////////////
assign kernel_size          = (data.W_width==3)? data.W_height*data.W_width*data.W_kernels*data.W_channels:(data.W_height+1)*data.W_kernels*data.W_channels;
assign input_size           = data.I_height*data.I_width*data.I_kernels*data.I_channels;
assign out_size             = (data.W_width==3)? 4*data.W_kernels*(((data.I_width-3+2*data.padding)/(data.Stride+1))+1)*(((data.I_height-3+2*data.padding)/(data.Stride+1))+1) :4*data.W_kernels*data.I_height ;
assign out_image            = (data.W_width==3)? (((data.I_width-3+2*data.padding)/(data.Stride+1))+2-data.Stride)*(((data.I_height-3+2*data.padding)/(data.Stride+1))+1)-2+data.Stride*2: data.I_height-2+2*data.padding-1 ;
assign kernel_size_channel  = data.W_height*data.W_width*data.W_kernels;
assign input_size_channel   = data.I_height*data.I_width*data.I_kernels;
/////////////////////////////////////////////////////
assign mem_ready = xif_mem.mem_ready;
assign mem_result_valid = xif_mem_result.mem_result_valid;
assign last_addr        = (controls.loadw)? data.W_addr + kernel_size  : (controls.loadi)? data.I_addr + input_size : data.R_addr + out_size ;

always_comb
begin
        if ((controls.loadw || controls.loadi || controls.execute) && !load_done)  // IF Loading 
        begin
            mem_valid           = '1 ;
            result_valid        = '0 ; 
            if (caddr >= last_addr)// Loading Finished
            begin
                mem_valid           = '0 ;
                result_valid        = '1 ;   
                caddr               = '0 ;
                load_done           = '1 ;             
                load_start          = '0 ;        
                i_address           = '1 ; 
                we                  = '0 ;
                i_wmask             = '0 ; 
            end 
            else // Loading Not Finished
            begin
                if (load_start) // Loading Started
                begin
                    we          = we ;
                    caddr       = caddr  ;
                    i_address   = i_address  ;
                    if (mem_result_valid) // Loading Next Address
                    begin
                        if (controls.loadi) begin
                            caddr           = caddr + 4 ;
                            addr_nb         = addr_nb + 1 ;
                            if (addr_nb) begin
                                i_wmask     = 64'h00000000FFFFFFFF;
                                i_address   = i_address + 1  ;    
                            end else
                            if (!addr_nb) begin
                                i_wmask     = 64'hFFFFFFFF00000000;
                                i_address       = i_address ;    
                            end
                            we              = we ;
                        end else
                        if (controls.loadw) begin
                                caddr           = caddr + 4 ;
                                we              = we ;
                                i_address       = i_address + 1 ;      
                        end else 
                        if (controls.execute) begin
                            if (wb_load) begin
                                we              = we ;
                                mem_we          = '1;
                                zero_skip       = zero_skip+1;
                                if (i_address == out_image +out_nb) begin
                                    out_nb = out_nb +1 ;
                                    i_address = {11'b0,out_nb} ;
                                    zero_skip       = '0 ;
                                end else
                                if ((zero_skip==data.I_width)&&(data.I_width>1)&&(!data.Stride)) begin
                                    if (data.padding) begin
                                        i_address       = i_address + 2 ;
                                    end else
                                    begin
                                        i_address       = i_address + 1 ;
                                    end
                                    zero_skip       = '0 ;
                                end else 
                                begin
                                    i_address       = i_address + 1 ;
                                end
                                caddr           = caddr + 4 ;
  
                            end else
                            begin
                                caddr           = caddr ;
                                i_address       = i_address ;
                                wdata           = wdata ;
                                we              = we ;
                                mem_we          = '1 ;                            
                            end 
                        end
                    end
//                    if (mem_ready) begin
//                        mem_we          = '1 ;
//                    end
                end
                else  // Loading Not Started
                begin
                    load_start          = '1    ;
                    i_address           = '0 ;
                    zero_skip           = '0 ;
                    addr_nb             = '0 ;
                    mem_we              = '0 ;  
                    if (controls.loadw) begin
                        we           = 3'b010 ;
                        caddr        = data.W_addr  ;
                    end 
                    else if (controls.loadi) begin
                        we           = 3'b001 ;
                        caddr        = data.I_addr  ;
                    end 
                    else if (controls.execute) begin
                        we           = 3'b100 ;
                        mem_we       = '1 ;  
                        caddr        = data.R_addr  ;
                    end
                end
            end 
        end else begin
            mem_valid           = '0 ;
            result_valid        = '1 ;        
            load_done           = '0 ;        
            out_nb              = '0 ;  
            mem_we              = '0 ;  
        end
end


assign w_square = (data.W_width == 3)? 1'b1:1'b0; 
assign w_vector = (data.W_width == 1)? 1'b1:1'b0; 

 // input UNIT 
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
    inputs_unit inputs_unit(
	.i_clk(clk_i),
	.i_rstn(rst_ni),
	
    .data(data),
    .w_square( w_square ),       
    .w_vector( w_vector ),
    .start(w_ended),  
    .stride(data.Stride),
    .finish(finish),
	.current_ch(current_ch),
        
    .o_sram_addr_0(i_sram_addr_0),        // Address from Accelerator
    .o_sram_rden_0(i_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data_0(i_sram_data_o_0),   
    
    .started_o(started_o),
    .inputs_o_0(inputs_o_0)
 );
  ///////////////////////////////////////////////// /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////
//   Weight UNIT 

  ///////////////////////////////////////////////////
  weights_unit weights_unitt(
	.i_clk(clk_i),
	.i_rstn(rst_ni),
	
		
    .w_square(w_square),        // Address from Accelerator
    .w_vector(w_vector),        // Address from Accelerator
    .data(data),
    .weights_start(start_w_load),  
//    .weights_start((controls.loadi)? 1'b1 : start_w_load),  
    .ended(w_ended),  
	.current_ch(current_ch),
     
    .o_sram_addr(w_sram_addr_0),        // Address from Accelerator
    .o_sram_rden(w_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data(w_sram_data_o_0),   

    .weights_0(weights_0)
 );
  /////////////////////////////////////////////////////
    //Memory INTERFACE
//always_comb begin
//    xif_mem.mem_valid       = mem_valid             ;
//    xif_mem.mem_req.id      = issue_req_i.id        ;    // Identification of the offloaded instruction
//    xif_mem.mem_req.addr    = (controls.loadw)? data.R_addr+i_address : caddr  ;  // Virtual address of the memory transaction
//    xif_mem.mem_req.mode    = '0                    ;  // Privilege level
//    xif_mem.mem_req.we      = controls.loadw                ;    // Write enable of the memory transaction
//    xif_mem.mem_req.size    = 3'b010                    ;  // Size of the memory transaction
//    xif_mem.mem_req.be      = '0                    ;    // Byte enables for memory transaction
//    xif_mem.mem_req.attr    = '0                    ;  // Memory transaction attributes
//    xif_mem.mem_req.wdata   = 10            ; // Write data of a store memory transaction
//    xif_mem.mem_req.last    = '0                    ;  // Is this the last memory transaction for the offloaded instruction?
//    xif_mem.mem_req.spec    = '0                    ;
//end
always_comb begin
    xif_mem.mem_valid       = mem_valid             ;
    xif_mem.mem_req.id      = issue_req_i.id        ;    // Identification of the offloaded instruction
    xif_mem.mem_req.addr    = caddr  ;  // Virtual address of the memory transaction
    xif_mem.mem_req.mode    = '0                    ;  // Privilege level
    xif_mem.mem_req.we      = mem_we                ;    // Write enable of the memory transaction
    xif_mem.mem_req.size    = 3'b010                    ;  // Size of the memory transaction
    xif_mem.mem_req.be      = (controls.execute)? 4'b1111 : '0                     ;    // Byte enables for memory transaction
    xif_mem.mem_req.attr    = '0                    ;  // Memory transaction attributes
    xif_mem.mem_req.wdata   = o_data_out            ; // Write data of a store memory transaction
    xif_mem.mem_req.last    = '0                    ;  // Is this the last memory transaction for the offloaded instruction?
    xif_mem.mem_req.spec    = '0                    ;
end
    //memory results phase 
  /////////////////////////////////////////////////////
  assign mem_results = xif_mem_result.mem_result.rdata ;
  
  assign sram_wren = (mem_result_valid && mem_valid && load_start)? we : 3'b100 ;
  // SRAM TOP
sram_top sram_top (
//     Clk, RST
	.i_clk(clk_i),
	.i_rstn(rst_ni),
    .controls(controls),

    // Host-side Interface
    .i_data(mem_results),             // Input data bus from Host
    .i_address((controls.execute)?i_address:i_address-1),          // Address from Host 
    .i_wren(sram_wren),             // Write enable from Host
    .i_wmask(i_wmask),           // Write mask bus
    .sram_ready_o(sram_ready_o),    	
    .out_nb(out_nb),    	
	.o_data_out(o_data_out),         // Output data bus towards Host
	.out(out),


	.w_sram_data_0(w_sram_data_0),        // Input data bus from Accelerator
    .w_sram_addr_0(w_sram_addr_0),        // Address from Accelerator
    .w_sram_rden_0(w_sram_rden_0),        // Read Enable from Accelerator
    .w_sram_data_o_0(w_sram_data_o_0),         // Output data bus towards Accelerator
    	
	.i_sram_data_0(i_sram_data_0),        // Input data bus from Accelerator
    .i_sram_addr_0(i_sram_addr_0),        // Address from Accelerator
    .i_sram_rden_0(i_sram_rden_0),        // Read Enable from Accelerator
    .i_sram_data_o_0(i_sram_data_o_0),         // Output data bus towards Accelerator
    
    .p_sram_data(p_sram_data),        // Input data bus from Accelerator
    .p_sram_data_o(p_sram_data_o),        // Input data bus from Accelerator
    .p_sram_addr(p_sram_addr),        // Address from Accelerator
    .p_sram_rden(p_sram_rden)        // Read Enable from Accelerator

); 
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////

sa sa(
	.clk(clk_i),
	.rstn(rst_ni),
    .stop(stop),
    .data(data),
//	 start enable
	.started(started_o),
//	 data input
    .inputs_i_0(inputs_o_0),  
//	 data input
    .bias_i_0(bias_i_0),  
//	 weights
    .weight_i(weights_0),        // Output data bus towards sa
//	 accumulator output
    .sram_ready_o(sram_ready_o),    	
    .results_ready_o(results_ready),    	
    .acc_o(acc_o)    	
); 
  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
psum_manager psums(
	.clk(clk_i),
	.rstn(rst_ni),
	.data(data),
	.results_ready(results_ready),
    .finish(finish),
	.current_ch(current_ch),
   	.results_i(acc_o),
    .p_sram_data(p_sram_data),        // Input data bus from Accelerator
    .p_sram_addr(p_sram_addr),        // Address from Accelerator
    .p_sram_rden(p_sram_rden),        // Read Enable from Accelerator
    .p_sram_data_i(p_sram_data_o),        // Read Enable from Accelerator


   	.stop(stop),
   	.done(done)
); 

  /////////////////////////////////////////////////////
  /////////////////////////////////////////////////////
    //RESULT INTERFACE
   always_comb begin
   
//    result_valid_o   = 1;
    xif_result.result_valid   = result_valid  ;
//    xif_result.result_valid   = (controls.Iload || controls.Wload) ? result_valid : '1  ;
    xif_result.result.id      = issue_req_i.id                          ;
    xif_result.result.data    = 10                               ;
    xif_result.result.rd      = rd                                      ;
    xif_result.result.we      = '0;                     
    xif_result.result.exc     = '0                                      ;
    xif_result.result.exccode = '0                                      ;
  end
endmodule