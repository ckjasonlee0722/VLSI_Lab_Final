# MATRIX_MULT Design Project

## Project Overview
This project implements a 2x2 matrix multiplication datapath in RTL using an FSM-based control flow. The design receives 4-bit input data, accumulates intermediate products, and outputs the result through the `out_valid` and `out_data` interface.

## RTL Summary
- Top module: `MATRIX_MULT`
- Clock period target in synthesis: 5.00 ns
- Input interface: `clk`, `rst_n`, `in_valid`, `in_data[3:0]`
- Output interface: `out_valid`, `out_data[12:0]`
- Design style: sequential FSM with DesignWare arithmetic blocks (`DW02_mult`, `DW01_add`, `DW01_sub`)

## Synthesis Log Status
The synthesis log shows that the design elaborated successfully and completed optimization without a hard failure.

Relevant log evidence:
- `Elaborated 1 design.`
- `Presto compilation completed successfully. (MATRIX_MULT)`
- `Optimization Complete`
- `report_timing` shows `slack (MET) 0.00`
- Final wrapper check reported: `--> V 02_SYN Success !!`

## Warning Observed
The log contains one warning from the compiler:
- `DEFAULT branch of CASE statement cannot be reached. (ELAB-311)`

This is not a synthesis failure. It means that the `default` branch in the FSM `case` statement is logically unreachable, but the implemented state space still covers the required operating states.

## Verified Results from the Log
From the final synthesis report:
- Clock period: 5.00 ns
- Total cell area: 10126.688450
- Total dynamic power: 493.5680 uW
- Cell leakage power: 7.5632 uW
- Total power: 0.5011 mW
- Timing result: `slack (MET) 0.00`

## Verification Notes
The log records that the final check flow passed the basic design checks, including:
- no soft IP detected
- latch checked
- width mismatch checked
- no error in synthesis log
- timing met

## Important Interpretation
This project is successfully synthesized and timing-closed according to the recorded log. The design is not shown to be broken; the most notable issue is a non-fatal warning about an unreachable `default` case. The README should therefore describe the status as successful synthesis with one benign compiler warning, rather than as a completely warning-free implementation.

## Project Files
- `MATRIX_MULT.v` — RTL implementation
- `PATTERN.v` — testbench pattern generator
- `syn.tcl` — synthesis script
- `MATRIX_MULT_SYN.log` — final synthesis log
- `README.md` — project summary
