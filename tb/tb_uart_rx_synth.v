`timescale 1ns/1ps

module tb_uart_rx_synth;

    reg clk = 0;
    reg rst = 1;
    reg rx = 1;

    wire [7:0] rx_data;
    wire rx_done;

    reg [7:0] test_data = 8'hA5;
    integer i;
    integer timeout;
    integer errors = 0;

    uart_rx uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    always #10 clk = ~clk;

    task send_bit(input reg bit_value);
        begin
            rx = bit_value;
            repeat (868) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("waveforms/uart_rx_synth.vcd");
        $dumpvars(0, tb_uart_rx_synth);

        repeat (5) @(negedge clk);
        rst = 0;

        repeat (3) @(negedge clk);

        // Start bit
        send_bit(1'b0);

        // Eight data bits, LSB first
        for (i = 0; i < 8; i = i + 1)
            send_bit(test_data[i]);

        // Stop bit: monitor rx_done throughout this interval.
        rx = 1'b1;

        timeout = 0;
        while (rx_done !== 1'b1 && timeout < 900) begin
            @(negedge clk);
            timeout = timeout + 1;
        end

        #1;

        if (rx_done !== 1'b1) begin
            $display("FAIL: RX completion");
            errors = errors + 1;
        end else begin
            $display("PASS: Synthesized RX completed");
        end

        if (rx_data !== test_data) begin
            $display("FAIL: Received %h, expected %h",
                     rx_data, test_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Received data = %h", rx_data);
        end

        if (errors == 0)
            $display("\nALL SYNTHESIZED RX TESTS PASSED!");
        else
            $display("\nSYNTHESIZED RX ERRORS: %0d", errors);

        $finish;
    end

endmodule
