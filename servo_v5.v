`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Dual-Axis Servo Controller with UART (Single RX, Fully Isolated X/Y Channels)
// Updated pin mapping:
//  - servo_x  → D5  (X-axis single fin)
//  - servo_y1 → C5  (Y-axis fin 1)
//  - servo_y2 → A4  (Y-axis fin 2, same as y1 signal)
//////////////////////////////////////////////////////////////////////////////////
module dual_axis_servo_uart_v5(
    input clk50mhz,
    input uart_rx,
    output reg servo_x,     // Formerly servo_x1
    output reg servo_y1,    // Formerly servo_y
    output reg servo_y2     // Formerly servo_x2
);

    // === Parameters ===
    parameter CLK_FREQ   = 50000000;
    parameter BAUD_RATE  = 9600;
    parameter BAUD_TICK  = CLK_FREQ / BAUD_RATE;

    // === UART Logic ===
    reg [12:0] baud_cnt = 0;
    reg [3:0] bit_cnt = 0;
    reg [9:0] rx_shift = 10'b1111111111;
    reg receiving = 0;
    reg [7:0] rx_data = 0;
    reg data_ready = 0;

    // === Control Registers ===
    reg [7:0] x_target = 8'd192;
    reg [7:0] y_target = 8'd192;
    reg [7:0] x_position = 8'd192;
    reg [7:0] y_position = 8'd192;

    reg [7:0] x_prev = 8'd192;
    reg [7:0] y_prev = 8'd192;

    reg [15:0] smooth_cnt = 0;
    reg [19:0] pwm_cnt = 0;

    reg state_waiting = 0;  // 0: Expecting X, 1: Expecting Y

    // === UART Receiver FSM ===
    always @(posedge clk50mhz) begin
        data_ready <= 0;
        if (!receiving) begin
            if (uart_rx == 0) begin
                receiving <= 1;
                baud_cnt <= BAUD_TICK / 2;
                bit_cnt <= 0;
            end
        end else begin
            if (baud_cnt == 0) begin
                baud_cnt <= BAUD_TICK - 1;
                rx_shift <= {uart_rx, rx_shift[9:1]};
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt == 9) begin
                    receiving <= 0;
                    rx_data <= rx_shift[8:1];
                    data_ready <= 1;
                end
            end else begin
                baud_cnt <= baud_cnt - 1;
            end
        end
    end

    // === X/Y Assignment with Isolation ===
    always @(posedge clk50mhz) begin
        if (data_ready) begin
            if (state_waiting == 0) begin
                if (rx_data != x_prev) begin
                    x_target <= rx_data;
                    x_prev <= rx_data;
                end
            end else begin
                if (rx_data != y_prev) begin
                    y_target <= rx_data;
                    y_prev <= rx_data;
                end
            end
            state_waiting <= ~state_waiting;
        end
    end

    // === Smooth Transition ===
    always @(posedge clk50mhz) begin
        if (smooth_cnt >= 16'd25000) begin
            smooth_cnt <= 0;

            if (x_position < x_target) x_position <= x_position + 1;
            else if (x_position > x_target) x_position <= x_position - 1;

            if (y_position < y_target) y_position <= y_position + 1;
            else if (y_position > y_target) y_position <= y_position - 1;
        end else begin
            smooth_cnt <= smooth_cnt + 1;
        end
    end

    // === PWM Counter ===
    always @(posedge clk50mhz) begin
        if (pwm_cnt >= 20'd999_999)
            pwm_cnt <= 0;
        else
            pwm_cnt <= pwm_cnt + 1;
    end

    // === Pulse Width ===
    wire [19:0] pulse_width_x = 20'd50000 + x_position * 20'd196;
    wire [19:0] pulse_width_y = 20'd50000 + y_position * 20'd196;

    // === PWM Outputs (updated names only) ===
    always @(posedge clk50mhz) begin
        servo_x  <= (pwm_cnt < pulse_width_x); // → D5
        servo_y1 <= (pwm_cnt < pulse_width_y); // → C5
        servo_y2 <= (pwm_cnt < pulse_width_y); // → A4
    end

endmodule
