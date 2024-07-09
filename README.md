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
# PE Unit
![pe](https://github.com/habibaouinti/NPU_X_Interface/assets/123462058/5d0abf7a-c7fc-4b2d-8f8d-20a4676d4906)
