`include "pwm.sv"
`include "smooth_cycle.sv" // I had to comment out the include statements to make the iverilog work

module top(
    input clk,
    output RGB_R,
    output RGB_G,
    output RGB_B
);
    localparam PWM_INTERVAL = 1200;
    localparam HOLD_OFF_STEPS = 800;      
    localparam RAMP_STEPS = 400;          
    localparam HOLD_ON_STEPS = 800;       
    localparam PHASE_SHIFT = 800;         

    wire [10:0] r_val, g_val, b_val;
    wire r_pwm, g_pwm, b_pwm;

    // Red (0° phase)
    smooth_cycle #(
        .INIT_PHASE_OFFSET(0),
        .HOLD_OFF_STEPS(HOLD_OFF_STEPS),
        .RAMP_STEPS(RAMP_STEPS),
        .HOLD_ON_STEPS(HOLD_ON_STEPS)
    ) red (
        .clk(clk),
        .pwm_value(r_val)
    );

    // Green (120° phase shift)
    smooth_cycle #(
        .INIT_PHASE_OFFSET(PHASE_SHIFT),
        .HOLD_OFF_STEPS(HOLD_OFF_STEPS),
        .RAMP_STEPS(RAMP_STEPS),
        .HOLD_ON_STEPS(HOLD_ON_STEPS)
    ) green (
        .clk(clk),
        .pwm_value(g_val)
    );

    // Blue (240° phase shift)
    smooth_cycle #(
        .INIT_PHASE_OFFSET(2*PHASE_SHIFT),
        .HOLD_OFF_STEPS(HOLD_OFF_STEPS),
        .RAMP_STEPS(RAMP_STEPS),
        .HOLD_ON_STEPS(HOLD_ON_STEPS)
    ) blue (
        .clk(clk),
        .pwm_value(b_val)
    );

    // PWM Modules
    pwm red_pwm (.clk(clk), .pwm_value(r_val), .pwm_out(r_pwm));
    pwm green_pwm (.clk(clk), .pwm_value(g_val), .pwm_out(g_pwm));
    pwm blue_pwm (.clk(clk), .pwm_value(b_val), .pwm_out(b_pwm));

    // Active-low outputs
    assign RGB_R = ~r_pwm;
    assign RGB_G = ~g_pwm;
    assign RGB_B = ~b_pwm;
endmodule