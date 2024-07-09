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
| `Decoder Unit` | Decides when and if an offload attempt from the core is accepted or not and stores the register files | [co_decoder.sv](RTL/co_decoder.sv)       |
| `Control Unit`          | Control Unit serves as the manager and coordinater the operations of all other components.  | [ctrl_unit.sv](RTL/Ctrl Unit/ctrl_unit.sv) |
| `SRAM Top Unit`         | The internal memory of the NPU, comprising three distinct SRAMs: Inputs SRAM, Weights SRAM and Psums SRAMs. | [sram_top.sv](RTL/SRAMs Unit/sram_top.sv)|
| `Im2Col Unit`           | Custom Image to Column Unit | [inputs_unit.sv](RTL/Im2Col Unit/inputs_unit.sv)      |
| `Weights Unit`          | Custom Weights to Columns Unit | [weights_unit.sv](RTL/Weights Unit/weights_unit.sv)                                                 |
| `Systolic Array Unit`   | Main porcessing unit | [sa.sv](RTL/Systolic Array/sa.sv)            |
| `Psum Manager Unit`     | Partial sums manager from Systolic Array to SRAMs | [psum_manager.sv](RTL/Psum Manager/psum_manager.sv)                                                             |

# PE Unit
![pe](https://github.com/habibaouinti/NPU_X_Interface/assets/123462058/5d0abf7a-c7fc-4b2d-8f8d-20a4676d4906)
