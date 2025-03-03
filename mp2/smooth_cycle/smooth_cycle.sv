module smooth_cycle #(
    parameter PWM_INTERVAL = 1200,        // 100µs PWM period
    parameter INC_DEC_INTERVAL = 5000,    // 416.67µs per step (12MHz clock)
    parameter HOLD_OFF_STEPS = 800,       // 800 steps × 416.67µs = 0.33333s (1/3 sec)
    parameter RAMP_STEPS = 400,           // 400 steps × 416.67µs = 0.16666667s (1/6 sec)
    parameter HOLD_ON_STEPS = 800,        // 800 steps × 416.67µs = 0.33333s (1/3 sec)
    parameter INIT_PHASE_OFFSET = 0       // Phase offset in steps
)(
    input clk,
    output reg [10:0] pwm_value           // 11 bits for 1200 steps
);
    // State encoding
    localparam HOLD_OFF = 2'b00;
    localparam RAMP_UP = 2'b01;
    localparam HOLD_ON = 2'b10;
    localparam RAMP_DOWN = 2'b11;

    reg [1:0] state = HOLD_OFF;           // Current state
    reg [31:0] counter = 0;               // Step counter
    reg [31:0] phase_counter;             // Phase counter (no initialization here)
    reg [10:0] step_value = 3;            // PWM step value (1200 / 400 = 3)

    // Initialization
    initial begin
        pwm_value = 0;
        state = HOLD_OFF;
        phase_counter = INIT_PHASE_OFFSET;  // Initialize phase_counter here
    end

    always @(posedge clk) begin
        if (counter >= INC_DEC_INTERVAL - 1) begin
            counter <= 0;

            // Update phase counter
            if (phase_counter >= (HOLD_OFF_STEPS + RAMP_STEPS + HOLD_ON_STEPS + RAMP_STEPS) - 1) begin
                phase_counter <= 0;
            end else begin
                phase_counter <= phase_counter + 1;
            end

            // State machine
            case (state)
                HOLD_OFF: begin
                    if (phase_counter >= HOLD_OFF_STEPS) begin
                        state <= RAMP_UP;
                    end
                end
                RAMP_UP: begin
                    if (pwm_value < PWM_INTERVAL - step_value) begin
                        pwm_value <= pwm_value + step_value;
                    end else begin
                        pwm_value <= PWM_INTERVAL;  // Clamp to max
                        state <= HOLD_ON;
                    end
                end
                HOLD_ON: begin
                    if (phase_counter >= HOLD_OFF_STEPS + RAMP_STEPS + HOLD_ON_STEPS) begin
                        state <= RAMP_DOWN;
                    end
                end
                RAMP_DOWN: begin
                    if (pwm_value > step_value) begin
                        pwm_value <= pwm_value - step_value;
                    end else begin
                        pwm_value <= 0;  // Clamp to min
                        state <= HOLD_OFF;
                    end
                end
            endcase
        end else begin
            counter <= counter + 1;
        end
    end
endmodule