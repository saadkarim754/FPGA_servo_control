`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Modified for Spartan-3E FPGA
//////////////////////////////////////////////////////////////////////////////////
module top_v2(
    input mclk,         // 50 MHz onboard clock
    input sw0,          // SW<0> = Increase
    input sw1,          // SW<1> = Decrease
    output Led,   // Direction indicator
    output servo        // PWM to servo
);

// ========= Constants ============
parameter MIN_PULSE = 16'd0;        // 1 ms pulse → 50,000 offset
parameter MAX_PULSE = 16'd50000;    // 2 ms pulse → 100,000 total
parameter MID_PULSE = 16'd25000;

// ========= Registers ============
reg [19:0] pwm_counter = 0;
reg servo_reg = 0;
reg [15:0] control = 0;       // Controls width of pulse: 0-50000

reg [25:0] hz_counter = 0;    // Enough to count to 50 million
reg clk_1hz = 0;
reg clk_1hz_prev = 0;         // For rising edge detect

reg toggle = 1;               // Used for LED direction feedback

// ========= 1ms Hz Clock Generator ============
always @(posedge mclk) begin
    if (hz_counter >= 26'd24_999) begin
        hz_counter <= 0;
        clk_1hz <= ~clk_1hz;
    end else begin
        hz_counter <= hz_counter + 1;
    end
end


// ========= Control Logic (sampled every 1 sec) ============
always @(posedge mclk) begin
    clk_1hz_prev <= clk_1hz;

    // Rising edge detection of 1 Hz clock
    if (clk_1hz_prev == 0 && clk_1hz == 1) begin
        if (sw0 && control < MAX_PULSE)
            control <= control + 1000;
        else if (sw1 && control > MIN_PULSE)
            control <= control - 1000;

        // Update toggle direction for LED
        if (sw0) toggle <= 1;
        else if (sw1) toggle <= 0;
    end
end

// ========= PWM Generation ============
always @(posedge mclk) begin
    if (pwm_counter == 20'd999_999)
        pwm_counter <= 0;
    else
        pwm_counter <= pwm_counter + 1;

    if (pwm_counter < (20'd50000 + control))
        servo_reg <= 1;
    else
        servo_reg <= 0;
end

// ========= Outputs ============
assign Led= toggle;
assign servo  = servo_reg;

endmodule

