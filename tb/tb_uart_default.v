`timescale 1ns/1ps

module tb_uart_default;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 8'hA5;

    wire tx;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_done;

    integer timeout;
    integer errors = 0;

    uart_tx transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    uart_rx receiver (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // 50 MHz clock: 20 ns period
    always #10 clk = ~clk;

    initial begin
        $dumpfile("waveforms/uart_default.vcd");
        $dumpvars(0, tb_uart_default);

        repeat (5) @(negedge clk);
        rst = 0;

        @(negedge clk);
        tx_start = 1;

        @(negedge clk);
        tx_start = 0;

        timeout = 0;

        while (rx_done !== 1'b1 && timeout < 12000) begin
            @(negedge clk);
            timeout = timeout + 1;
        end

        #1;

        if (rx_done !== 1'b1) begin
            $display("FAIL: Reception timeout");
            errors = errors + 1;
        end else begin
            $display("PASS: Receiver completed");
        end

        if (rx_data !== 8'hA5) begin
            $display("FAIL: Received %h, expected A5", rx_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Received A5 at CLKS_PER_BIT=868");
        end

        if (errors == 0)
            $display("\nDEFAULT TIMING TEST PASSED!");
        else
            $display("\nDEFAULT TIMING TEST FAILED!");

        $finish;
    end

endmodule
