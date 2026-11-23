# UART Design and Simulation Using Verilog

A UART transmitter and receiver implemented in Verilog HDL.

## Features
- 8-bit UART transmission, LSB first
- UART receiver with start and stop-bit validation
- TX/RX loopback testing
- Icarus Verilog simulation
- GTKWave waveform inspection
- Yosys synthesis and synthesized-netlist verification

## Tools
- Verilog HDL
- Icarus Verilog
- GTKWave
- Yosys
- Ubuntu on WSL

## Run All Tests
```bash
./scripts/run_simulation.sh
```

Seven verification runs passed.

## Synthesis Results
| Module | Generic cells | Structural problems |
|---|---:|---:|
| UART TX | 161 | 0 |
| UART RX | 335 | 0 |

## Timing Note
The assignment default is CLKS_PER_BIT = 868 at 50 MHz, which is approximately 57,604 baud, not 9600 baud. Approximately 5208 clocks per bit are required for 9600 baud at 50 MHz.

## Evidence
Waveform screenshot: `docs/screenshots/uart_default_waveform.png`

Detailed report: [PROJECT_REPORT.md](docs/PROJECT_REPORT.md)

FPGA board programming and hardware testing were not performed.
