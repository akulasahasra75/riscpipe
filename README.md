# 🔧 riscpipe — 5-Stage Pipelined RISC Processor

**Fully Pipelined RISC Processor with Hazard Handling, Implemented in Verilog**

![Board](https://img.shields.io/badge/Target-Artix--7-blue)
![HDL](https://img.shields.io/badge/HDL-Verilog-orange)
![Tools](https://img.shields.io/badge/Tools-Vivado%202023.1-green)
![License](https://img.shields.io/badge/License-MIT-lightgrey)
![Simulation](https://img.shields.io/badge/Simulation-Behavioral-brightgreen)

> A complete, fully functional 5-stage pipelined RISC processor — from custom ISA design through hazard handling to behavioral simulation and planned FPGA deployment.

| 🚀 5-Stage Pipeline | ⚡ Forwarding Unit | 🛡 Hazard Detection | 🎯 Custom 6-Instr ISA |
|---|---|---|---|

---

## 🧠 Problem Statement

Classical single-cycle processors execute one instruction per clock cycle at the cost of long cycle times — every instruction, regardless of complexity, must wait for the slowest operation. This project solves that by:

- **Pipelining execution** across 5 concurrent stages, increasing instruction throughput
- **Eliminating most stalls** via a forwarding unit that routes results directly between pipeline stages
- **Handling all three hazard classes** — data, load-use, and control — cleanly and correctly
- **Targeting Artix-7 FPGA** deployment as Phase 2

---

## 📑 Table of Contents

- [Problem Statement](#-problem-statement)
- [System Architecture](#-system-architecture)
- [How It Works](#-how-it-works)
- [Custom ISA](#-custom-isa)
- [Hazard Handling](#-hazard-handling)
- [Project Structure](#-project-structure)
- [Simulation & Testing](#-simulation--testing)
- [Tech Stack](#-tech-stack)
- [How to Run](#-how-to-run)
- [Known Issues & Notes](#-known-issues--notes)
- [Future Improvements](#-future-improvements)
- [References](#-references)
- [License](#-license)
- [Authors & Credits](#-authors--credits)

---

## 🏗 System Architecture

### High-Level Pipeline Block Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        riscpipe — 5-Stage Pipeline                       │
│                                                                         │
│  ┌──────────┐  IF/ID  ┌──────────┐  ID/EX  ┌──────────┐  EX/MEM        │
│  │    IF    │────────►│    ID    │────────►│    EX    │────────────►   │
│  │          │  reg    │          │  reg    │          │  reg            │
│  │ PC + 4   │         │ Reg Read │         │   ALU    │                 │
│  │ Inst Mem │         │ Ctrl Gen │         │ Fwd Mux  │                 │
│  └──────────┘         │ Imm Ext  │         │ Br Comp  │                 │
│       ▲               └──────────┘         └──────────┘                 │
│       │                    │                    │                       │
│  ┌────┴──────────────────── HAZARD UNIT ─────────────────────┐          │
│  │  • Load-use stall (1 cycle)                               │          │
│  │  • Branch flush (2 instructions)                          │          │
│  └───────────────────────────────────────────────────────────┘          │
│                                                                         │
│           EX/MEM             MEM/WB                                     │
│   ────────────────►┌──────────┐────────►┌──────────┐                   │
│         reg        │   MEM    │  reg    │    WB    │                   │
│                    │          │         │          │                   │
│                    │ Data Mem │         │ Writeback│                   │
│                    │ LD / ST  │         │ to RegF  │                   │
│                    └──────────┘         └──────────┘                   │
│                         │                    │                          │
│  ┌──────────────────── FORWARDING UNIT ───────────────────────┐         │
│  │  • EX/MEM → EX  (forward ALU result one stage back)       │         │
│  │  • MEM/WB → EX  (forward ALU or load result two stages)   │         │
│  └───────────────────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Module Hierarchy

```
top.v
├── pc_reg.v            — Program counter register (stall-aware)
├── inst_mem.v          — Instruction memory (ROM)
├── if_id_reg.v         — IF/ID pipeline register (flush-aware)
├── reg_file.v          — 32-entry × 32-bit register file
├── control_unit.v      — Main control signal decoder
├── id_ex_reg.v         — ID/EX pipeline register (stall/flush-aware)
├── alu.v               — ALU (ADD, SUB, pass-through for branches)
├── forwarding_unit.v   — RAW hazard forwarding logic
├── hazard_unit.v       — Load-use stall + branch flush detection
├── ex_mem_reg.v        — EX/MEM pipeline register
├── data_mem.v          — Data memory (byte-addressed, word-aligned)
└── mem_wb_reg.v        — MEM/WB pipeline register
```

---

## ⚙️ How It Works

### End-to-End Execution Flow

```
Verilog Source ──► Vivado Sim ──► Waveform ──► Phase 2: FPGA
     │                 │               │
     │                 │               └─► Verify register values,
     │                 │                   memory contents, PC trace
     │                 │
     │                 └─► tb_top.v drives clock, loads
     │                     test program into inst_mem
     │
     └─► All modules instantiated in top.v,
         connected via pipeline registers
```

### Cycle-by-Cycle Pipeline Trace (Test Program)

```
Cycle:   1    2    3    4    5    6    7    8    9   10
        ─────────────────────────────────────────────────
ADDI1:  IF   ID   EX  MEM   WB
ADDI2:       IF   ID   EX  MEM   WB
ADD  :            IF   ID   EX  MEM   WB       ← EX/MEM forward for rs1, rs2
SW   :                 IF   ID   EX  MEM   WB
LW   :                      IF   ID  ---   EX  MEM   WB   ← stall (load-use)
                                       ↑
                                  bubble inserted
```

---

## 📐 Custom ISA

6-instruction ISA with RISC-V compatible encoding:

| Instruction | Format | Encoding | Operation |
|---|---|---|---|
| `ADD rd, rs1, rs2` | R-type | funct3=000, funct7=0000000 | `rd = rs1 + rs2` |
| `SUB rd, rs1, rs2` | R-type | funct3=000, funct7=0100000 | `rd = rs1 - rs2` |
| `ADDI rd, rs1, imm` | I-type | funct3=000 | `rd = rs1 + imm` |
| `LW rd, imm(rs1)` | I-type | funct3=010 | `rd = mem[rs1 + imm]` |
| `SW rs2, imm(rs1)` | S-type | funct3=010 | `mem[rs1 + imm] = rs2` |
| `BEQ rs1, rs2, imm` | B-type | funct3=000 | `if rs1==rs2, PC = PC+imm` |

### Instruction Encoding Fields

```
R-type:  [31:25] funct7 | [24:20] rs2 | [19:15] rs1 | [14:12] funct3 | [11:7] rd  | [6:0] opcode
I-type:  [31:20] imm[11:0]             | [19:15] rs1 | [14:12] funct3 | [11:7] rd  | [6:0] opcode
S-type:  [31:25] imm[11:5] | [24:20] rs2| [19:15] rs1 | [14:12] funct3 | [11:7] imm[4:0] | [6:0] opcode
B-type:  [31:25] imm[12|10:5]| [24:20] rs2|[19:15] rs1 |[14:12] funct3 |[11:7] imm[4:1|11]|[6:0] opcode
```

---

## 🛡 Hazard Handling

### Data Hazards — Forwarding

The forwarding unit resolves Read-After-Write (RAW) hazards by routing results from later pipeline stages back to the EX stage ALU inputs, eliminating stall cycles for most arithmetic dependencies.

```
Forwarding conditions:
  EX/MEM forward:  EX/MEM.RegWrite  AND  EX/MEM.Rd  == ID/EX.Rs1 (or Rs2)
                   AND  EX/MEM.Rd  != 0
  MEM/WB forward:  MEM/WB.RegWrite  AND  MEM/WB.Rd  == ID/EX.Rs1 (or Rs2)
                   AND  MEM/WB.Rd  != 0
                   AND  NOT (EX/MEM forward already active)
```

### Load-Use Hazards — Stall

When a `LW` is immediately followed by an instruction that reads the loaded register, one stall cycle is inserted:

```
Stall condition:   ID/EX.MemRead  AND
                   (ID/EX.Rd == IF/ID.Rs1  OR  ID/EX.Rd == IF/ID.Rs2)

Action:  PC ← hold  |  IF/ID ← hold  |  ID/EX ← bubble (NOP)
```

### Control Hazards — Flush

On a taken branch, the two instructions already fetched (in IF and ID stages) are flushed:

```
Flush condition:   Branch resolved as taken in EX stage
Action:            IF/ID ← NOP  |  ID/EX ← NOP  |  PC ← branch target
```

| Hazard Type | Detection | Resolution | Cycles Lost |
|---|---|---|---|
| RAW (non-load) | Forwarding unit | Forward from EX/MEM or MEM/WB | 0 |
| Load-use | Hazard unit | Stall + bubble | 1 |
| Taken branch | Hazard unit | Flush 2 instructions | 2 |

---

## 📁 Project Structure

```
riscpipe/
│
├── src/
│   ├── top.v                — Top-level module, pipeline wiring
│   ├── pc_reg.v             — Program counter (stall-aware)
│   ├── inst_mem.v           — Instruction memory (ROM)
│   ├── reg_file.v           — 32×32 register file
│   ├── control_unit.v       — Opcode → control signals
│   ├── alu.v                — Arithmetic/logic unit
│   ├── data_mem.v           — Data memory (load/store)
│   ├── if_id_reg.v          — IF/ID pipeline register
│   ├── id_ex_reg.v          — ID/EX pipeline register
│   ├── ex_mem_reg.v         — EX/MEM pipeline register
│   ├── mem_wb_reg.v         — MEM/WB pipeline register
│   ├── forwarding_unit.v    — RAW hazard forwarding
│   └── hazard_unit.v        — Load-use stall, branch flush
│
└── sim/
    └── tb_top.v             — Testbench: clock gen, test program, assertions
```

---

## 🧪 Simulation & Testing

### Validation Status

| Stage | Status | Details |
|---|---|---|
| RTL Compilation | ✅ Pass | All modules compile clean in Vivado |
| Behavioral Simulation | ✅ Pass | Waveform matches expected register values |
| Forwarding Paths | ✅ Pass | EX/MEM and MEM/WB forwarding verified |
| Load-Use Stall | ✅ Pass | One bubble inserted, correct result in x4 |
| Branch Flush | ✅ Pass | Two NOPs inserted on taken BEQ |
| FPGA Synthesis | 🔜 Planned | Phase 2 — Artix-7 deployment |

### Test Program

```asm
ADDI x1, x0, 5     # x1 = 5
ADDI x2, x0, 3     # x2 = 3
ADD  x3, x1, x2    # x3 = 8  ← forwarded from EX/MEM (x1) and EX/MEM (x2)
SW   x3, 0(x0)     # mem[0] = 8
LW   x4, 0(x0)     # x4 = 8  ← load-use stall, then MEM/WB forward
```

### Expected Results

| Register / Memory | Expected Value | Verified? |
|---|---|---|
| x1 | 5 | ✅ |
| x2 | 3 | ✅ |
| x3 | 8 | ✅ |
| mem[0] | 8 | ✅ |
| x4 | 8 | ✅ |

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| HDL | Verilog (IEEE 1364-2001) | All RTL design and pipeline modules |
| Simulation | Vivado 2023.1 Behavioral Sim | Functional verification, waveform analysis |
| Testbench | Verilog `tb_top.v` | Clock generation, program loading, assertions |
| Target Board | Digilent Nexys 4 DDR (Artix-7) | Phase 2 FPGA deployment |

### Target Platform (Phase 2)

| Parameter | Value |
|---|---|
| Board | Digilent Nexys 4 DDR |
| FPGA | Xilinx Artix-7 (xc7a100t) |
| Clock target | 100 MHz |
| Tools | Vivado 2023.1 |
| ISA width | 32-bit |
| Register file | 32 × 32-bit |

---

## 🚀 How to Run

### Prerequisites

| Tool | Version | Purpose | Required? |
|---|---|---|---|
| Vivado | 2023.1 | Simulation and (Phase 2) synthesis | Yes |
| Git | Any | Clone the repo | Yes |

### Simulation (Vivado GUI)

```tcl
# 1. Clone repository
git clone https://github.com/akulasahasra75/riscpipe.git
cd riscpipe

# 2. Open Vivado, create a new project targeting xc7a100t
# 3. Add all files under src/ as design sources
# 4. Add sim/tb_top.v as simulation source
# 5. Run Behavioral Simulation
```

### Simulation (Vivado Batch Mode)

```tcl
# From Vivado Tcl console:
create_project riscpipe ./riscpipe_proj -part xc7a100tcsg324-1
add_files -norecurse [glob src/*.v]
add_files -fileset sim_1 -norecurse sim/tb_top.v
set_property top tb_top [get_filesets sim_1]
launch_simulation
run all
```

### What to Check in the Waveform

```
Signal                    Expected Behaviour
─────────────────────────────────────────────────────
clk                       Regular clock, 10 ns period
pc                        Increments by 4 each cycle (stalls on load-use)
if_id_inst                Instruction register — holds or flushes on hazard
forward_a, forward_b      2'b10 or 2'b01 on ADD, showing forwarding active
stall                     1'b1 for one cycle after LW before dependent instr
flush                     1'b1 when branch is taken
reg_file[1]               Settles to 32'h5 after ADDI completes WB
reg_file[3]               Settles to 32'h8 after ADD completes WB
data_mem[0]               32'h8 after SW completes MEM
reg_file[4]               Settles to 32'h8 after LW completes WB
```

---

## ⚠️ Known Issues & Notes

| Item | Note |
|---|---|
| Branch resolution | Branch is resolved in EX stage — always flushes 2 instructions on taken branch (no branch prediction) |
| Memory model | Instruction and data memories are separate (Harvard architecture), initialized via `$readmemh` or hardcoded in testbench |
| FPGA deployment | Synthesis and timing closure not yet validated; clock constraints pending |
| Register x0 | Hardwired to zero; write attempts are silently ignored in `reg_file.v` |
| Immediate sign extension | All immediates are sign-extended to 32 bits in the ID stage |

---

## 🔮 Future Improvements

- [ ] FPGA deployment on Nexys 4 DDR (Phase 2)
- [ ] Timing constraint file (`.xdc`) for 100 MHz target
- [ ] Expand ISA — add `OR`, `AND`, `SLT`, `JAL`
- [ ] Branch predictor (static not-taken, then dynamic 2-bit)
- [ ] Cache model (direct-mapped instruction cache)
- [ ] Larger test suite with automated pass/fail assertions in testbench
- [ ] UART output for register dump post-execution (on-FPGA debugging)

---

## 📖 References

1. D. Patterson and J. Hennessy, *Computer Organization and Design: ARM Edition*, 2016.
2. Xilinx, *Vivado Design Suite User Guide: Logic Simulation (UG900)*, v2023.1.
3. RISC-V International, *The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA*, 2019.
4. Digilent, *Nexys 4 DDR Reference Manual*.

---

## 📄 License

This project is licensed under the MIT License.

`MIT License — Copyright (c) 2026 akulasahasra75`

---

## 👥 Authors & Credits

| Name | GitHub |
|---|---|
| Akula Sahasra | [@akulasahasra75](https://github.com/akulasahasra75) |

*Digital Systems / Computer Architecture — 5-Stage Pipelined RISC Processor in Verilog*

---

⭐ *If this project helped you understand pipelining or hazard handling, consider giving it a star!*

*Built with Verilog, Vivado, and a lot of pipeline diagrams.*
