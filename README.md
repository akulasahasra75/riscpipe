# riscpipe — 5-Stage Pipelined RISC Processor

A fully functional 5-stage pipelined processor implemented in Verilog, designed and verified using Vivado behavioral simulation.

## Architecture

The processor implements a classic 5-stage pipeline:

**IF → ID → EX → MEM → WB**

- **IF** — Instruction Fetch: PC increments by 4 each cycle, fetches instruction from instruction memory
- **ID** — Instruction Decode: Register file reads, immediate sign extension, control signal generation
- **EX** — Execute: ALU operations, branch target computation, forwarding mux selection
- **MEM** — Memory Access: Load and store operations on data memory
- **WB** — Write Back: ALU result or memory data written back to register file

## Custom ISA

6-instruction ISA with RISC-V compatible encoding:

| Instruction | Format | Operation |
|---|---|---|
| ADD rd, rs1, rs2 | R-type | rd = rs1 + rs2 |
| SUB rd, rs1, rs2 | R-type | rd = rs1 - rs2 |
| ADDI rd, rs1, imm | I-type | rd = rs1 + imm |
| LW rd, imm(rs1) | I-type | rd = mem[rs1 + imm] |
| SW rs2, imm(rs1) | S-type | mem[rs1 + imm] = rs2 |
| BEQ rs1, rs2, imm | B-type | if rs1==rs2, PC = PC+imm |

## Hazard Handling

**Data hazards — forwarding:** The forwarding unit detects RAW hazards and routes results directly from EX/MEM and MEM/WB pipeline registers back to ALU inputs, eliminating stall cycles for most hazards.

**Load-use hazards — stall:** When a load instruction is immediately followed by a dependent instruction, the hazard detection unit inserts one stall cycle and a pipeline bubble.

**Control hazards — flush:** On a taken branch, the two incorrectly fetched instructions are flushed from the pipeline.

## Project Structure

```text
.
├── src
│   ├── top.v
│   ├── pc_reg.v
│   ├── inst_mem.v
│   ├── reg_file.v
│   ├── control_unit.v
│   ├── alu.v
│   ├── data_mem.v
│   ├── if_id_reg.v
│   ├── id_ex_reg.v
│   ├── ex_mem_reg.v
│   ├── mem_wb_reg.v
│   ├── forwarding_unit.v
│   └── hazard_unit.v
└── sim
    └── tb_top.v
```
## Simulation

Simulated in Vivado 2023.1 behavioral simulation. Test program:
ADDI x1, x0, 5      # x1 = 5
ADDI x2, x0, 3      # x2 = 3
ADD  x3, x1, x2     # x3 = 8  (forwarding from EX/MEM)
SW   x3, 0(x0)      # mem[0] = 8
LW   x4, 0(x0)      # x4 = 8  (load-use stall + MEM/WB forward)

Expected result: x1=5, x2=3, x3=8, x4=8

## Tools

- Verilog HDL
- Vivado 2023.1 (simulation only — Phase 1)
- Target device: Artix-7 (Phase 2 — FPGA deployment, planned)

## Repository

[github.com/akulasahasra75/riscpipe](https://github.com/akulasahasra75/riscpipe)
