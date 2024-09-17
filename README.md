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
![SoC](https://github.com/user-attachments/assets/bc3e9c3d-7808-4f43-b18b-357d6055ad87)
# NPU Architecture
![npu](https://github.com/user-attachments/assets/1e5984c7-5ef7-4ee3-b91f-b1e220b42086)
# Integration
The coprocessors main module is named coprocessor and can be found in [coprocessor.sv](RTL/coprocessor.sv). 
### Integration Template
      coprocessor copro0 (
        .clk_i          (  ),
        .rst_ni         (  ),
        .xif_compressed (  ),
        .xif_issue      (  ),
        .xif_commit     (  ),
        .xif_mem        (  ),
        .xif_mem_result (  ),
        .xif_result     (  )
    );

## List of Modules

| Name                           | Description                                                                                                                                                                                       | SystemVerilog File                                                                                             |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `coprocessor`                       | Top level module and includes the Memory Fetch/Store Unit                                                                                                                                                                                  | [coprocessor.sv](RTL/coprocessor.sv)                                                                         |
| `Decoder Unit` | Decides when and if an offload attempt from the core is accepted or not and stores the register files | [co_decoder.sv](RTL/co_decoder.sv)       |
| `Control Unit`          | Control Unit serves as the manager and coordinater the operations of all other components.  | [ctrl_unit.sv](RTL/Ctrl_Unit/ctrl_unit.sv) |
| `SRAM Top Unit`         | The internal memory of the NPU, comprising three distinct SRAMs: Inputs SRAM, Weights SRAM and Psums SRAMs. | [sram_top.sv](RTL/SRAMs_Unit/sram_top.sv)|
| `Im2Col Unit`           | Custom Image to Column Unit | [inputs_unit.sv](RTL/Im2Col_Unit/inputs_unit.sv)      |
| `Weights Unit`          | Custom Weights to Columns Unit | [weights_unit.sv](RTL/Weights_Unit/weights_unit.sv)                                                 |
| `Systolic Array Unit`   | Main porcessing unit | [sa.sv](RTL/Systolic_Array/sa.sv)            |
| `Psum Manager Unit`     | Partial sums manager from Systolic Array to SRAMs | [psum_manager.sv](RTL/Psum_Manager/psum_manager.sv)                                                             |

# PE Unit
![pe](https://github.com/habibaouinti/NPU_X_Interface/assets/123462058/5d0abf7a-c7fc-4b2d-8f8d-20a4676d4906)
