# UART Design and Simulation Using Verilog and Open-Source Tools

## 1. Project Overview

This project implements a Universal Asynchronous Receiver Transmitter (UART)
using Verilog HDL. It includes a transmitter (TX), receiver (RX), and
testbenches for independent and loopback verification.

## 2. Objectives

* Design a UART transmitter.
* Design a UART receiver.
* Simulate serial data transmission and reception.
* Verify TX and RX independently.
* Verify TX-to-RX loopback communication.
* Inspect waveforms using GTKWave.
* Synthesize the modules using Yosys.

## 3. UART Protocol

The implemented UART frame contains:

| Field | Description |
|---|---|
| Start bit | Logic 0 |
| Data bits | 8 bits, LSB first |
| Parity | Not implemented |
| Stop bit | Logic 1 |

## 4. Tools Used

* Verilog HDL
* Icarus Verilog
* VVP
* GTKWave
* Yosys
* Ubuntu on Windows Subsystem for Linux (WSL)

## 5. Project Structure

See the project README for the complete directory structure.

## 6. UART Transmitter

Source file: `rtl/uart_tx.v`

Inputs:
* `clk`: System clock.
* `rst`: Active-high asynchronous reset.
* `tx_start`: Starts transmission.
* `tx_data[7:0]`: Data to transmit.

Outputs:
* `tx`: Serial output.
* `tx_busy`: Indicates active transmission.

The transmitter uses a 10-bit shift register containing one start bit,
eight data bits and one stop bit. Data is sent least-significant bit first.

## 7. UART Receiver

Source file: `rtl/uart_rx.v`

Inputs:
* `clk`: System clock.
* `rst`: Active-high asynchronous reset.
* `rx`: Serial input.

Outputs:
* `rx_data[7:0]`: Received byte.
* `rx_done`: One-clock completion pulse.

The receiver uses four states: IDLE, START, DATA and STOP.
It detects the start bit, samples eight data bits and validates the stop bit.

## 8. Timing Configuration

The design uses the assignment's default parameter:

`CLKS_PER_BIT = 868`

The default timing test uses a 50 MHz clock with a 20 ns period.

**Timing clarification:** At 50 MHz, 868 clocks per bit corresponds to
approximately 57,604 baud, not 9600 baud. Approximately 5208 clocks per
bit are required for 9600 baud at 50 MHz.

The implementation preserves the assignment's specified default value
of 868. The project does not claim that this setting produces 9600 baud.

## 9. Simulation and Verification

The following seven verification runs completed successfully:

1. Original UART TX test.
2. Original UART RX test.
3. Fast TX/RX loopback test.
4. Default timing loopback test.
5. Synthesized TX test.
6. Synthesized RX test.
7. Synthesized TX/RX loopback test.

The test byte was `8'hA5`. The receiver correctly recovered `8'hA5`.

## 10. Waveform Verification

VCD files were generated and inspected using GTKWave.

Screenshot evidence:

`docs/screenshots/uart_default_waveform.png`

The default loopback waveform shows the received data as A5,
the completion signal asserted, and the transmitter no longer busy.

## 11. Yosys Synthesis

TX and RX were synthesized separately using Yosys.

| Module | Generic mapped cells | Structural problems |
|---|---:|---:|
| UART TX | 161 | 0 |
| UART RX | 335 | 0 |

Generated netlists:

* `simulation/uart_tx_synth.v`
* `simulation/uart_rx_synth.v`

Both synthesized netlists passed their verification tests.

These are generic logic-mapped netlists, not physical FPGA implementations.

## 12. Automated Verification

Run all seven verification tests using `./scripts/run_simulation.sh`.

The script stops if a compilation or simulation command fails.

## 13. FPGA Implementation

FPGA place-and-route, board programming and hardware testing were not performed. This project covers RTL design, simulation, waveform inspection, Yosys synthesis and synthesized-netlist simulation.

## 14. Conclusion

The UART transmitter and receiver were successfully implemented using Verilog HDL. All seven verification runs passed, and the receiver correctly recovered the transmitted test byte A5.

## 15. Evidence

- `docs/screenshots/uart_default_waveform.png`
- `waveforms/`
- `simulation/uart_tx_synthesis.log`
- `simulation/uart_rx_synthesis.log`
