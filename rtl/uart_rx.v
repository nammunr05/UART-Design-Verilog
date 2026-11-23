`timescale 1ns/1ps

module uart_rx #(
    parameter CLKS_PER_BIT = 868
)(
    input wire clk,
    input wire rst,
    input wire rx,
    output reg [7:0] rx_data,
    output reg rx_done
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;
    reg [15:0] clk_count;
    reg [3:0] bit_index;
    reg [7:0] rx_shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            rx_shift_reg <= 0;
            rx_data <= 0;
            rx_done <= 0;
        end else begin
            rx_done <= 0;

            case (state)

                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;

                    if (rx == 1'b0)
                        state <= START;
                end

                START: begin
                    if (clk_count < (CLKS_PER_BIT/2)-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;

                        if (rx == 1'b0)
                            state <= DATA;
                        else
                            state <= IDLE;
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_shift_reg[bit_index] <= rx;

                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else
                            state <= STOP;
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= IDLE;

                        if (rx == 1'b1) begin
                            rx_data <= rx_shift_reg;
                            rx_done <= 1'b1;
                        end
                    end
                end

                default: begin
                    state <= IDLE;
                    clk_count <= 0;
                end

            endcase
        end
    end

endmodule
