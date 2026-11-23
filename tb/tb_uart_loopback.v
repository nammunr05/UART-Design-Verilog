`timescale 1ns/1ps

module tb_uart_loopback;

    localparam CPB = 4;

    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_done;

    integer i;
    integer errors;

    uart_tx #(
        .CLKS_PER_BIT(CPB)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    uart_rx #(
        .CLKS_PER_BIT(CPB)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);

        clk = 0;
        rst = 1;
        tx_start = 0;
        tx_data = 8'hA5;
        errors = 0;

        repeat (3) @(negedge clk);
        rst = 0;

        @(negedge clk);
        tx_start = 1;

        @(negedge clk);
        tx_start = 0;

        if (tx_busy !== 1'b1) begin
            $display("FAIL: TX did not become busy");
            errors = errors + 1;
        end else begin
            $display("PASS: TX started");
        end

        // Wait for receiver completion, with a timeout.
        for (i = 0; i < 60 && rx_done !== 1'b1; i = i + 1)
            @(negedge clk);

        #1;

        if (rx_done !== 1'b1) begin
            $display("FAIL: RX completion timeout");
            errors = errors + 1;
        end else begin
            $display("PASS: RX completed");
        end

        if (rx_data !== tx_data) begin
            $display("FAIL: Received %h, expected %h",
                     rx_data, tx_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Loopback data = %h", rx_data);
        end

        if (tx_busy !== 1'b0) begin
            $display("FAIL: TX busy did not clear");
            errors = errors + 1;
        end else begin
            $display("PASS: TX busy cleared");
        end

        if (errors == 0)
            $display("\nALL UART LOOPBACK TESTS PASSED!");
        else
            $display("\nUART LOOPBACK ERRORS: %0d", errors);

        $finish;
    end

endmodule
