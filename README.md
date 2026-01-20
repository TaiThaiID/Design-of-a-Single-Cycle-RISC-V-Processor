# RISC-V Single-Cycle Processor

A complete single-cycle RISC-V processor implementation with custom ALU design and memory-mapped I/O peripherals.

## Overview

This processor executes the full RV32I instruction set in a single clock cycle per instruction. It features a custom-designed ALU built without using standard arithmetic operators, making it suitable for understanding fundamental processor architecture.

**Key Features:**
- Complete RV32I ISA support (40+ instructions)
- Custom ALU with barrel shifter (no built-in operators)
- Memory-mapped I/O system
- Verified with comprehensive ISA test suite
- FPGA implementation on Altera DE2

## Architecture

```
PC → IMEM → Decoder → Regfile → ALU → LSU → I/O
              ↓         ↓        ↓     ↓
         Control    Operands   BRC   Memory
```

**Execution Flow:**
1. Fetch instruction from IMEM
2. Decode and read registers
3. Execute operation (ALU/BRC)
4. Access memory/peripherals (LSU)
5. Write back to register

All stages complete in one clock cycle.

## Implementation Highlights

### Custom ALU
- Arithmetic: Addition/subtraction using custom adder
- Logic: AND, OR, XOR operations
- Shift: Barrel shifter for SLL, SRL, SRA
- Compare: Custom comparator for SLT/SLTU

### Load-Store Unit
Handles all memory operations and I/O access through memory mapping:

| Address | Peripheral | 
|---------|-----------|
| `0x0000_0000` | Data Memory (2 KiB) |
| `0x1000_0000` | Red LEDs |
| `0x1000_1000` | Green LEDs |
| `0x1000_2000` | 7-Segment Displays 0-3 |
| `0x1000_3000` | 7-Segment Displays 4-7 |
| `0x1001_0000` | Switches |

### Control Unit
Hardwired control logic generating all datapath signals based on instruction opcode, funct3, and funct7 fields.

## Verification

Passed all RV32I instruction tests including:
- Arithmetic & Logic operations
- Shift operations (SLL, SRL, SRA)
- Load/Store (LW, LH, LB, SW, SH, SB)
- Branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
- Jumps (JAL, JALR)
- Upper immediates (LUI, AUIPC)

**Result:** All tests passed ✓

## Demo Application

**HEX/DEC Converter** - Real-time conversion between hexadecimal and decimal

- Input via switches (12-bit value)
- Display on 7-segment LEDs
- Switch controls for display modes
- ~200 lines of RISC-V assembly

*[Add demo images/GIF here]*

## Synthesis Results

**Target:** Altera Cyclone II (DE2 Board)

| Resource | Usage |
|----------|-------|
| Logic Elements | 11,909 (36%) |
| Registers | 7,649 |

## Quick Start

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/riscv-single-cycle.git

# Run simulation
cd 10_sim
# [Add simulation commands]

# Synthesize
cd 20_syn/quartus
# [Add synthesis commands]
```

## Project Structure

```
riscv-single-cycle/
├── 00_src/         # RTL sources (singlecycle.sv, alu.sv, etc.)
├── 01_bench/       # Testbenches
├── 02_test/        # Test programs
├── 10_sim/         # Simulation scripts
└── 20_syn/         # Synthesis files
```

## Documentation

- Full block diagram and datapath in [docs/](docs/)
- Module specifications in source files
- Test results in [verification report](docs/verification.md)

## Author

**[Your Name]**  
IC Design Student @ HCMUT, VNU-HCM  
📧 [your.email@example.com](mailto:your.email@example.com) | 💼 [LinkedIn](your-linkedin)

---

*Computer Architecture Course (EE3203) - Milestone 2*
