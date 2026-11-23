`timescale 1ns/1ps

module tb_uart_tx;

    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;

    integer i;
    integer errors;

    uart_tx #(
        .CLKS_PER_BIT(4)
    ) uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        clk = 0;
        rst = 1;
        tx_start = 0;
        tx_data = 8'hA5;
        errors = 0;

        repeat (2) @(negedge clk);
        rst = 0;

        @(negedge clk);
        tx_start = 1;

        @(negedge clk);
        tx_start = 0;

        wait (tx == 0);
        #1;

        if (tx !== 1'b0) begin
            $display("FAIL: Start bit");
            errors = errors + 1;
        end else begin
            $display("PASS: Start bit");
        end

        for (i = 0; i < 8; i = i + 1) begin
            repeat (4) @(posedge clk);
            #1;

            if (tx !== tx_data[i]) begin
                $display("FAIL: Data bit %0d", i);
                errors = errors + 1;
            end else begin
                $display("PASS: Data bit %0d = %b", i, tx);
            end
        end

        repeat (4) @(posedge clk);
        #1;

        if (tx !== 1'b1) begin
            $display("FAIL: Stop bit");
            errors = errors + 1;
        end else begin
            $display("PASS: Stop bit");
        end

        if (tx_busy !== 1'b0) begin
            $display("FAIL: Busy signal did not clear");
            errors = errors + 1;
        end else begin
            $display("PASS: Busy signal cleared");
        end

        if (errors == 0)
            $display("\nALL UART TX TESTS PASSED!");
        else
            $display("\nUART TX ERRORS: %0d", errors);

        $finish;
    end

endmodule
