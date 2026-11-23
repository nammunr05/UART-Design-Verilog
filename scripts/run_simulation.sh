#!/bin/bash
set -e

cd "$(dirname "$0")/.."

mkdir -p simulation waveforms

echo "======================================"
echo " UART DESIGN - COMPLETE VERIFICATION"
echo "======================================"

echo
echo "1. ORIGINAL TX TEST"
iverilog -g2012 -s tb_uart_tx \
  -o simulation/uart_tx_run \
  rtl/uart_tx.v tb/tb_uart_tx.v
vvp simulation/uart_tx_run

echo
echo "2. ORIGINAL RX TEST"
iverilog -g2012 -s tb_uart_rx \
  -o simulation/uart_rx_run \
  rtl/uart_rx.v tb/tb_uart_rx.v
vvp simulation/uart_rx_run

echo
echo "3. ORIGINAL LOOPBACK TEST"
iverilog -g2012 -s tb_uart_loopback \
  -o simulation/uart_loopback_run \
  rtl/uart_tx.v rtl/uart_rx.v tb/tb_uart_loopback.v
vvp simulation/uart_loopback_run

echo
echo "4. DEFAULT TIMING LOOPBACK TEST"
iverilog -g2012 -s tb_uart_default \
  -o simulation/uart_default_run \
  rtl/uart_tx.v rtl/uart_rx.v tb/tb_uart_default.v
vvp simulation/uart_default_run

echo
echo "5. SYNTHESIZED TX TEST"
iverilog -g2012 -s tb_uart_tx_synth \
  -o simulation/uart_tx_synth_run \
  simulation/uart_tx_synth.v tb/tb_uart_tx_synth.v
vvp simulation/uart_tx_synth_run

echo
echo "6. SYNTHESIZED RX TEST"
iverilog -g2012 -s tb_uart_rx_synth \
  -o simulation/uart_rx_synth_run \
  simulation/uart_rx_synth.v tb/tb_uart_rx_synth.v
vvp simulation/uart_rx_synth_run

echo
echo "7. SYNTHESIZED DEFAULT LOOPBACK TEST"
iverilog -g2012 -s tb_uart_default \
  -o simulation/uart_default_synth_run \
  simulation/uart_tx_synth.v \
  simulation/uart_rx_synth.v \
  tb/tb_uart_default.v
vvp simulation/uart_default_synth_run

echo
echo "======================================"
echo " ALL VERIFICATION RUNS COMPLETED"
echo "======================================"
