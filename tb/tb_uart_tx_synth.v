`timescale 1ns/1ps

module tb_uart_tx_synth;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 8'hA5;

    wire tx;
    wire tx_busy;

    integer errors = 0;

    uart_tx uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("waveforms/uart_tx_synth.vcd");
        $dumpvars(0, tb_uart_tx_synth);

        repeat (5) @(negedge clk);
        rst = 0;

        @(negedge clk);
        tx_start = 1;

        @(negedge clk);
        tx_start = 0;

        if (tx_busy !== 1'b1) begin
            $display("FAIL: TX did not start");
            errors = errors + 1;
        end else begin
            $display("PASS: Synthesized TX started");
        end

        // Check start bit.
        repeat (868) @(negedge clk);

        if (tx !== 1'b0) begin
            $display("FAIL: Start bit");
            errors = errors + 1;
        end else begin
            $display("PASS: Start bit");
        end

        // Check eight data bits, LSB first.
        for (integer i = 0; i < 8; i = i + 1) begin
            repeat (868) @(negedge clk);

            if (tx !== tx_data[i]) begin
                $display("FAIL: Data bit %0d", i);
                errors = errors + 1;
            end
        end

        // Check stop bit.
        repeat (868) @(negedge clk);

        if (tx !== 1'b1) begin
            $display("FAIL: Stop bit");
            errors = errors + 1;
        end else begin
            $display("PASS: Stop bit");
        end

        repeat (2) @(negedge clk);

        if (tx_busy !== 1'b0) begin
            $display("FAIL: TX busy did not clear");
            errors = errors + 1;
        end else begin
            $display("PASS: TX busy cleared");
        end

        if (errors == 0)
            $display("\nALL SYNTHESIZED TX TESTS PASSED!");
        else
            $display("\nSYNTHESIZED TX ERRORS: %0d", errors);

        $finish;
    end

endmodule
