# Neural-Processing-Unit
This project's aim is the implement a neural processing tile that can be integrated into
a RISC- V based SoC architecture. The neural tile will be controlled by a RISC-V core
through custom instructions as a co-processor unit. It should also have access to memory
and SoC peripherals. The focus of the work will be around the implementation of a
programmable neural processing tile to support several convolution operations as well as
the interfacing with the RISC-V core and data management between the neural tile and
RISC-V SoC memory. The neural tile implementation has to be developed using RTL
targeting Xilinx FPGA devices.
# SoC Architecture
The NPU is a Co-processor extending the cv32e40x core through the eXtension Interface
![soc](https://github.com/habibaouinti/NPU_X_Interface/assets/123462058/da7bb03e-8357-4135-a8aa-49d4fc987624)
# NPU Architecture
![NPU](https://github.com/habibaouinti/NPU_X_Interface/assets/123462058/3e0f4898-6ead-4924-a1e3-622520aadf86)
# Integration
The coprocessors main module is named coprocessor and can be found in [coprocessor.sv](RTL/coprocessor.sv). 
### Integration Template
 

	);

## List of Modules

| Name                           | Description                                                                                                                                                                                       | SystemVerilog File                                                                                             |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `coprocessor`                       | Top level module and includes the Memory Fetch/Store Unit                                                                                                                                                                                  | [coprocessor.sv](RTL/coprocessor.sv)                                                                         |
| `Decoder Unit` | Decides when and if an offload attempt from the core is accepted or not and stores the register files  | [co_decoder.sv](RTL/co_decoder.sv)       |
| `Control Unit`            | Decides when and if an offload attempt from the core is accepted or not                                                                                                                           | [fpu_ss_predecoder.sv](src/fpu_ss_predecoder.sv "fpu_ss_predecoder.sv")                                        |
| `SRAM Top Unit`                  | Stream FIFO from [pulp-platform/common_cells](https://github.com/pulp-platform/common_cells) is used in the coprocessor to buffer incoming instructions and metadata of ongoing memory operations | [stream_fifo.sv](https://github.com/pulp-platform/common_cells/tree/master/src/stream_fifo.sv "stream_fifo.sv")|
| `Im2Col Unit`               | Decodes instructions                                                                                                                                                                              | [fpu_ss_decoder.sv](src/fpu_ss_decoder.sv "fpu_ss_decoder.sv")                                                 |
| `Weights Unit`               | Flip-flop based floating-point specific register file with three read ports and one write port                                                                                                    | [fpu_ss_regfile.sv](src/fpu_ss_regfile.sv "fpu_ss_regfile.sv")                                                 |
| `Systolic Array Unit`                    | Main porcessing unit                                                                                                                                                                              | [fpnew_top.sv](https://github.com/pulp-platform/fpnew/tree/develop/src/fpnew_top.sv "fpnew_top.sv")            |
| `Psum Manager Unit`                   | Contains the floating-point specific CSR registers and executes all floating-point specific CSR instructions                                                                                      | [fpu_ss_csr.sv](src/fpu_ss_csr.sv "fpu_ss_csr.sv")                                                             |
|       
# PE Unit
![pe](https://github.com/habibaouinti/NPU_X_Interface/assets/123462058/5d0abf7a-c7fc-4b2d-8f8d-20a4676d4906)
