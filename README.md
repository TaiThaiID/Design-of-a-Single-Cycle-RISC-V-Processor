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
<img width="1406" height="738" alt="single cycle" src="https://github.com/user-attachments/assets/6e6da528-ded5-4547-ade8-c2be036422d9" />
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

| Base Address | Top Address | Mapping |
|--------------|-------------|---------|
| `0x0000_0000` | `0x0000_07FF` | Memory (2 KiB) *(required)* |
| `0x0000_0800` | `0x0FFF_FFFF` | (Reserved) |
| `0x1000_0000` | `0x1000_0FFF` | Red LEDs *(required)* |
| `0x1000_1000` | `0x1000_1FFF` | Green LEDs *(required)* |
| `0x1000_2000` | `0x1000_2FFF` | Seven-segment LEDs 3-0 |
| `0x1000_3000` | `0x1000_3FFF` | Seven-segment LEDs 7-4 |
| `0x1000_4000` | `0x1000_4FFF` | LCD Control Registers |
| `0x1000_5000` | `0x1000_FFFF` | (Reserved) |
| `0x1001_0000` | `0x1001_0FFF` | Switches *(required)* |
| `0x1001_1000` | `0xFFFF_FFFF` | (Reserved) |

### Control Unit
Hardwired control logic generating all datapath signals based on instruction opcode, funct3, and funct7 fields.

##  I/O System Conventions

### Red LEDs (`o_io_ledr`)
| Bits | Usage |
|------|-------|
| 31-17 | (Reserved) |
| 16-0 | 17-bit data connected to red LED array |

### Green LEDs (`o_io_ledg`)
| Bits | Usage |
|------|-------|
| 31-8 | (Reserved) |
| 7-0 | 8-bit data connected to green LED array |

### Seven-Segment Displays

**Address `0x1000_2000` (HEX0-3):**
| Bits | Usage |
|------|-------|
| 31 | (Reserved) |
| 30-24 | 7-bit data to HEX3 |
| 23 | (Reserved) |
| 22-16 | 7-bit data to HEX2 |
| 15 | (Reserved) |
| 14-8 | 7-bit data to HEX1 |
| 7 | (Reserved) |
| 6-0 | 7-bit data to HEX0 |

**Address `0x1000_3000` (HEX4-7):**
| Bits | Usage |
|------|-------|
| 31 | (Reserved) |
| 30-24 | 7-bit data to HEX7 |
| 23 | (Reserved) |
| 22-16 | 7-bit data to HEX6 |
| 15 | (Reserved) |
| 14-8 | 7-bit data to HEX5 |
| 7 | (Reserved) |
| 6-0 | 7-bit data to HEX4 |

### LCD Display (`o_io_lcd`)
| Bits | Usage |
|------|-------|
| 31 | ON |
| 30-11 | (Reserved) |
| 10 | EN |
| 9 | RS |
| 8 | R/W |
| 7-0 | Data |

### Switches (`i_io_sw`)
| Bits | Usage |
|------|-------|
| 31-18 | (Reserved) |
| 17 | Reset |
| 16-0 | 17-bit data from SW16 to SW0 |

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

<img width="1307" height="875" alt="Screenshot 2026-01-20 001130" src="https://github.com/user-attachments/assets/37cfef7f-8ca5-4499-b2c9-06fc6f8372c2" />


## Synthesis Results

**Target:** Altera Cyclone II (DE2 Board)

| Resource | Usage |
|----------|-------|
| Logic Elements | 11,909 (36%) |
| Registers | 7,649 |

---
## References

- D. A. Patterson and J. L. Hennessy, Computer Organization and Design: The Hardware/Software Interface, RISC-V Edition, Morgan Kaufmann, 2020.
- S. L. Harris and D. Harris, Digital Design  and Computer Architecture: RISC-V Edition,  Morgan Kaufmann, 2021.
- Dan Garcia, "RISC-V Instructions Formats I, II, III", Great Ideas in Computer Architecture (Machine Structures), University of California, Berkeley, 2020.
- Dan Garcia, "RISC-V Single-Cycle Datapath I, II, III", Great Ideas in Computer Architecture (Machine Structures), University of California, Berkeley, 2020.
- Dan Garcia, "RISC-V Single-Cycle Control", Great Ideas in Computer Architecture (Machine Structures), University of California, Berkeley, 2020.

---
