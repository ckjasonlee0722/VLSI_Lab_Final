# MATRIX_MULT Design Project

## Project Overview
This project implements a 2x2 matrix multiplier circuit for the final VLSI lab assignment. The design computes the matrix operation:

D = A × B × C

where each matrix is 2×2 and the final output is produced as a 13-bit value per element to preserve precision and prevent overflow. The implementation follows the required RTL behavior, synthesis constraints, and gate-level verification flow.

## Design Objective
The circuit receives 4-bit input data and generates valid output results through the `out_valid` and `out_data` interface. The design must:

- handle asynchronous reset correctly
- ensure `out_valid` is asserted for exactly 4 consecutive cycles
- output results in row-major order
- avoid overlap between `in_valid` and `out_valid`
- use DesignWare IP blocks rather than standard arithmetic operators
- satisfy timing constraints after synthesis

## Implementation Summary
- Top module: `MATRIX_MULT`
- Clock period: 5.0 ns
- Input interface: `clk`, `rst_n`, `in_valid`, `in_data[3:0]`
- Output interface: `out_valid`, `out_data[12:0]`
- Design style: sequential FSM-based datapath with DesignWare multiplication/addition/subtraction blocks

The datapath performs the required intermediate computations and then streams the final 2×2 result in four sequential output cycles.

## Key Constraints and Compliance
The final implementation satisfies the assignment rules:

- no latch in synthesis result
- no overlap of input and output valid signals
- output data reset to zero when valid is low
- timing requirement is met
- DesignWare IPs are used in the RTL implementation
- synthesis and gate-level checks pass without reported errors

## Synthesis Result Summary
The final synthesis log reports the following key results:

- Clock period: 5.00 ns
- Total cell area: 10126.688450
- Gate count: 1015
- Dynamic power: 486.5067 uW
- Leakage power: 7.5632 uW
- Total power: 0.5011 mW
- Timing result: slack = 0.00, MET

## Verification Status
The design passed the required verification checks:

- RTL functional validation
- gate-level simulation validation
- synthesis check for latch-free implementation
- timing validation with no violation
- no error reported in final synthesis log

## Project Files
- `MATRIX_MULT.v` — RTL implementation
- `PATTERN.v` — testbench pattern generator
- `syn.tcl` — synthesis script
- `MATRIX_MULT_SYN.log` — final synthesis log
- `Lab_final_spec.pdf` — assignment specification
- `Lab_Power.pdf` — power-related reference material

## Performance Note
The grading policy uses a combined performance metric based on latency, clock period, area, and power. The implemented design is optimized for correctness and timing closure while keeping area and power within acceptable limits.

## Conclusion
This project demonstrates a complete RTL-to-synthesis workflow for a matrix-multiplication accelerator with verified functional behavior and timing closure. The final design meets the key constraints of the lab specification and is suitable for presentation to the instructor.
