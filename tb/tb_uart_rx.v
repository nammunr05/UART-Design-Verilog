`timescale 1ns/1ps

module tb_uart_rx;

    localparam CPB = 4;

    reg clk;
    reg rst;
    reg rx;

    wire [7:0] rx_data;
    wire rx_done;

    integer i;
    integer errors;

    uart_rx #(
        .CLKS_PER_BIT(CPB)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    always #5 clk = ~clk;

    task send_frame;
        input [7:0] data;
        begin
            // Start bit
            rx = 1'b0;
            repeat (CPB) @(negedge clk);

            // Eight data bits, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                repeat (CPB) @(negedge clk);
            end

            // Stop bit
            rx = 1'b1;
            repeat (CPB-1) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("waveforms/uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        clk = 0;
        rst = 1;
        rx = 1;
        errors = 0;

        repeat (2) @(negedge clk);
        rst = 0;

        @(negedge clk);
        send_frame(8'hA5);

        #1;

        if (rx_done !== 1'b1) begin
            $display("FAIL: RX done signal");
            errors = errors + 1;
        end else begin
            $display("PASS: RX done signal");
        end

        if (rx_data !== 8'hA5) begin
            $display("FAIL: Received data = %h, expected A5", rx_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Received data = %h", rx_data);
        end

        if (errors == 0)
            $display("\nALL UART RX TESTS PASSED!");
        else
            $display("\nUART RX ERRORS: %0d", errors);

        $finish;
    end

endmodule
