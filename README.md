# RISC-V Single-Cycle Processor (RV32I)

A complete implementation of a single-cycle RISC-V processor supporting the RV32I base integer instruction set with memory-mapped I/O peripherals.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Key Components](#key-components)
- [Memory Organization](#memory-organization)
- [Verification](#verification)
- [Demo Application](#demo-application)
- [Synthesis Results](#synthesis-results)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [References](#references)

---

## 🎯 Overview

This project implements a **single-cycle RISC-V processor** based on the RV32I instruction set architecture. In a single-cycle design, each instruction completes execution within one clock cycle, making it an ideal platform for understanding fundamental processor architecture concepts before advancing to pipelined implementations.

**Project Highlights:**
- ✅ Complete RV32I instruction set support (excluding FENCE)
- ✅ Custom ALU design without built-in operators
- ✅ Memory-mapped I/O system for peripheral interfacing
- ✅ Hardwired control unit
- ✅ Verified with comprehensive ISA test suite
- ✅ Hardware implementation on Altera DE2 FPGA
- ✅ Practical demo application (HEX/DEC converter)

**Course Context:**  
*Computer Architecture (EE3203) - Milestone 2*  
*Ho Chi Minh City University of Technology (HCMUT)*

---

## 🏗️ Architecture

### Single-Cycle Execution Model

In this architecture, all five stages of instruction execution occur within a single clock cycle:

1. **Instruction Fetch (IF)**: Fetch instruction from instruction memory
2. **Instruction Decode (ID)**: Decode instruction and read from register file
3. **Execute (EX)**: Perform ALU operation or branch comparison
4. **Memory Access (MEM)**: Access data memory or I/O peripherals via LSU
5. **Write Back (WB)**: Write result back to register file

### Block Diagram

```
┌──────┐   ┌──────┐   ┌─────────┐   ┌─────┐   ┌────────┐
│  PC  │──▶│ IMEM │──▶│ Control │──▶│ ALU │──▶│  LSU   │
└──────┘   └──────┘   │  Unit   │   └─────┘   └────────┘
    ▲                 └─────────┘      │           │
    │                      │            │           │
    │                  ┌───────┐       │           │
    └──────────────────│  BRC  │◀──────┘           │
                       └───────┘                   │
                           │                       │
                       ┌────────┐                  │
                       │Regfile │◀─────────────────┘
                       └────────┘
```

*For detailed datapath diagrams, see [docs/datapath.md](docs/datapath.md)*

---

## 🔧 Key Components

### 1. Arithmetic Logic Unit (ALU)

Custom-designed ALU supporting all RV32I arithmetic and logical operations **without using built-in SystemVerilog operators** for subtraction, comparison, or shifting.

**Features:**
- Addition/Subtraction using custom adder
- Logical operations (AND, OR, XOR)
- Shift operations via barrel shifter
- Comparison operations (SLT, SLTU)

**Operations Supported:**
```
ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
```

### 2. Branch Comparison Unit (BRC)

Dedicated unit for evaluating branch conditions with support for both signed and unsigned comparisons.

**Supported Branches:**
```
BEQ, BNE, BLT, BLTU, BGE, BGEU
```

### 3. Load-Store Unit (LSU)

Manages all memory operations and peripheral I/O through memory-mapped addressing.

**Capabilities:**
- Load operations: `LW`, `LH`, `LHU`, `LB`, `LBU`
- Store operations: `SW`, `SH`, `SB`
- Misaligned address handling
- Peripheral register access

### 4. Control Unit

Hardwired control logic that decodes instructions and generates all datapath control signals.

**Control Signals:**
- `pc_sel`: Program counter source selection
- `rd_wren`: Register file write enable
- `br_un`: Branch comparison mode (signed/unsigned)
- `opa_sel`, `opb_sel`: ALU operand selection
- `alu_op`: ALU operation code
- `mem_wren`: Memory write enable
- `wb_sel`: Write-back data selection
- `insn_vld`: Instruction valid flag

### 5. Register File

32 general-purpose registers (x0-x31), with x0 hardwired to zero.

**Specifications:**
- 32 registers × 32 bits
- 2 asynchronous read ports
- 1 synchronous write port

---

## 💾 Memory Organization

### Memory Map

| Address Range | Region | Size | Description |
|--------------|---------|------|-------------|
| `0x0000_0000 - 0x0000_07FF` | Data Memory | 2 KiB | Main memory for data storage |
| `0x1000_0000 - 0x1000_0FFF` | Red LEDs | 4 KiB | 17 red LED control (required) |
| `0x1000_1000 - 0x1000_1FFF` | Green LEDs | 4 KiB | 8 green LED control (required) |
| `0x1000_2000 - 0x1000_2FFF` | 7-Segment 0-3 | 4 KiB | Seven-segment displays 0-3 |
| `0x1000_3000 - 0x1000_3FFF` | 7-Segment 4-7 | 4 KiB | Seven-segment displays 4-7 |
| `0x1000_4000 - 0x1000_4FFF` | LCD Control | 4 KiB | LCD display registers |
| `0x1001_0000 - 0x1001_0FFF` | Switches | 4 KiB | Switch input (required) |

### Instruction Memory

- **Size:** 8 KiB (2048 words)
- **Type:** Asynchronous read, read-only
- **Loading:** Initialized via `$readmemh()` from hex file

---

## ✅ Verification

### ISA Test Results

The processor was verified using a comprehensive test suite covering all RV32I instructions:

```
SINGLE CYCLE - ISA tests

Arithmetic:  add, addi, sub ........................ PASS
Logical:     and, andi, or, ori, xor, xori ......... PASS
Shift:       sll, slli, srl, srli, sra, srai ...... PASS
Compare:     slt, slti, sltu, sltiu ................ PASS
Load:        lw, lh, lhu, lb, lbu .................. PASS
Store:       sw, sh, sb ............................ PASS
Branch:      beq, bne, blt, bltu, bge, bgeu ........ PASS
Jump:        jal, jalr ............................. PASS
Upper Imm:   lui, auipc ............................ PASS

Result: ALL TESTS PASSED ✓
```

### Test Coverage

- ✅ All 40+ RV32I instructions
- ✅ Edge cases (sign extension, branch offsets)
- ✅ Load/store with different sizes
- ✅ Memory-mapped I/O operations
- ✅ Misaligned address handling

---

## 🎬 Demo Application

### HEX/DEC Converter

A practical application demonstrating the processor's I/O capabilities by converting switch input values between hexadecimal and decimal representations.

**Features:**
- **Input:** 12-bit value from switches (SW[11:0])
- **Output:** 
  - Decimal display on 7-segment LEDs (HEX0-3)
  - Hexadecimal display on 7-segment LEDs (HEX4-7)
- **Controls:**
  - SW[12]: Master enable/disable
  - SW[13]: Decimal display enable
  - SW[14]: Hexadecimal display enable

**Implementation:**
- Written in RISC-V assembly (200+ lines)
- Decimal conversion via repeated division by 10
- Hexadecimal conversion via nibble extraction
- 7-segment encoding lookup table

### Demo Videos/Images

*Add screenshots or GIFs here:*
- Switch input operation
- Decimal conversion display
- Hexadecimal conversion display
- Both displays active

---

## 📊 Synthesis Results

### FPGA Implementation (Altera DE2)

| Resource | Usage | Percentage |
|----------|-------|------------|
| Logic Elements | 11,909 | 36% |
| Registers | 7,649 | - |
| Memory Bits | - | - |
| Frequency | XX MHz | - |

**Synthesis Tool:** Intel Quartus Prime  
**Target Device:** Cyclone II EP2C35F672C6

**Notes:**
- Higher resource usage due to behavioral-level module descriptions
- Custom ALU and barrel shifter contribute to logic element count
- Optimization opportunities exist for resource reduction

---

## 🚀 Getting Started

### Prerequisites

- **Simulator:** ModelSim, Verilator, or Cadence Xcelium
- **Synthesis:** Intel Quartus Prime
- **Hardware:** Altera DE2 board (optional)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/riscv-single-cycle.git
   cd riscv-single-cycle
   ```

2. **Compile the design**
   ```bash
   cd 10_sim
   # Follow simulation instructions
   ```

3. **Run test program**
   ```bash
   # Load mem.dump into instruction memory
   # Run simulation
   ```

4. **Synthesize for FPGA**
   ```bash
   cd 20_syn/quartus/run
   make synthesize
   ```

### Directory Structure

```
riscv-single-cycle/
├── 00_src/              # RTL source files
│   ├── singlecycle.sv   # Top-level module
│   ├── alu.sv
│   ├── brc.sv
│   ├── regfile.sv
│   ├── lsu.sv
│   ├── control.sv
│   └── ...
├── 01_bench/            # Testbench files
├── 02_test/             # Test programs
│   ├── asm/            # Assembly code
│   └── dump/           # Hex dumps
├── 10_sim/              # Simulation files
├── 20_syn/              # Synthesis files
│   └── quartus/
└── 99_doc/              # Documentation
```

---

## 📚 Documentation

### Module Interface: `singlecycle.sv`

```systemverilog
module singlecycle (
    input  logic        i_clk,        // Global clock
    input  logic        i_reset,      // Active-low reset
    output logic [31:0] o_pc_debug,   // Program counter (debug)
    output logic        o_insn_vld,   // Instruction valid
    output logic [31:0] o_io_ledr,    // Red LEDs output
    output logic [31:0] o_io_ledg,    // Green LEDs output
    output logic [ 6:0] o_io_hex0,    // 7-segment displays
    output logic [ 6:0] o_io_hex1,
    output logic [ 6:0] o_io_hex2,
    output logic [ 6:0] o_io_hex3,
    output logic [ 6:0] o_io_hex4,
    output logic [ 6:0] o_io_hex5,
    output logic [ 6:0] o_io_hex6,
    output logic [ 6:0] o_io_hex7,
    output logic [31:0] o_io_lcd,     // LCD control
    input  logic [31:0] i_io_sw       // Switch input
);
```

### Additional Documentation

- [Detailed Datapath](docs/datapath.md)
- [ALU Design](docs/alu.md)
- [Control Unit Logic](docs/control.md)
- [LSU Implementation](docs/lsu.md)
- [Verification Guide](docs/verification.md)

---

## 📖 References

1. Patterson & Hennessy - *Computer Organization and Design: RISC-V Edition*
2. Harris & Harris - *Digital Design and Computer Architecture: RISC-V Edition*
3. [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
4. UC Berkeley CS61C - RISC-V Lectures

---

## 👥 Team

**Group L02 - Semester 251**

- **Student 1:** [Name] - ALU, LSU, Control Unit
- **Student 2:** [Name] - BRC, Regfile, IMEM, Application
- **Student 3:** [Name] - ImmGen, Control Unit, Application

---

## 👤 Author

**[Your Name]**  
IC Design Student @ HCMUT, VNU-HCM

📧 Email: [your.email@example.com](mailto:your.email@example.com)  
💼 LinkedIn: [Your Profile](your-linkedin-url)

---

## 🙏 Acknowledgments

- **Course:** EE3203 Computer Architecture
- **Supervisor:** Assoc. Prof., PhD. Tran Hoang Linh
- **Teaching Assistant:** Hai Cao
- **Institution:** HCMUT, VNU-HCM

---

## 📄 License

This project was developed as part of the Computer Architecture course at HCMUT.

---

*Last updated: November 2024*
