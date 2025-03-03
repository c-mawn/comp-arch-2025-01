module pwm #(
    parameter PWM_INTERVAL = 1200
)(
    input logic clk,
    input logic [$clog2(PWM_INTERVAL)-1:0] pwm_value,
    output logic pwm_out
);
    logic [$clog2(PWM_INTERVAL)-1:0] pwm_count = 0;

    always @(posedge clk) begin
        pwm_count <= (pwm_count >= PWM_INTERVAL-1) ? 0 : pwm_count + 1;
    end

    assign pwm_out = (pwm_count < pwm_value) ? 1'b1 : 1'b0;
endmodule