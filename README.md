# ALU
Fully parameterized Arithmetic Logic Unit (ALU)
Here’s a professional and concise GitHub description for your ALU project:

---

### 🔧 Parameterized ALU in SystemVerilog

This project implements a fully parameterized **Arithmetic Logic Unit (ALU)** in **SystemVerilog**, supporting a wide range of arithmetic, logical, shift, and comparison operations. It is designed for flexibility, allowing customization of operand width and includes support for overflow detection, carry-out, and status flags.

#### ✅ Features:

* **Configurable operand width** via parameters
* Supports:

  * Arithmetic: `ADD`, `SUB`, `INC`, `DEC`, `ADD with carry`, `SUB with borrow`
  * Logical: `AND`, `OR`, `XOR`, `NOT`
  * Shifts: `Logical left`, `Logical right`, `Arithmetic right`
  * Comparison: `Greater`, `Less`, `Equal`
  * Custom operations: Extended multiplication techniques
* **Flag outputs**:

  * Carry Out (`COUT`)
  * Overflow (`OFLOW`)
  * Error Detection
  * Comparison flags (`G`, `L`, `E`)
* **Synthesis-ready** and **testbench included**

#### 📁 Structure:

* `alu.sv`: Main ALU module
* `alu_tb.sv`: Testbench for verification
* `README.md`: Project overview and usage instructions

#### 💡 Use Cases:

* Digital design practice
* RTL-level simulation projects
* FPGA implementation and SoC integration

