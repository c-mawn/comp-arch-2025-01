module top(
    input logic     clk, 
    output logic    RGB_G,
    output logic    RGB_R,
    output logic    RGB_B
);

    // CLK frequency is 12MHz, so 2,000,000 cycles is ~0.167s
    parameter BLINK_INTERVAL = 2000000;
    
    // Define distinct color states
    parameter RED_STATE    = 3'b011;  // R on, G off, B off
    parameter GREEN_STATE  = 3'b101;  // R off, G on, B off
    parameter BLUE_STATE   = 3'b110;  // R off, G off, B on
    parameter MAGENTA_STATE = 3'b010; // R on, G off, B on
    parameter CYAN_STATE   = 3'b100;  // R off, G on, B on
    parameter YELLOW_STATE = 3'b001;  // R on, G on, B off

    logic [20:0] count = 0; // 21-bit counter for BLINK_INTERVAL
    logic [2:0] current_state = RED_STATE;
    
    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            case (current_state)
                RED_STATE: current_state <= YELLOW_STATE;
                YELLOW_STATE: current_state <= GREEN_STATE;
                GREEN_STATE: current_state <= CYAN_STATE;
                CYAN_STATE: current_state <= BLUE_STATE;
                BLUE_STATE: current_state <= MAGENTA_STATE;
                MAGENTA_STATE: current_state <= RED_STATE;
                default: current_state <= RED_STATE;
            endcase
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end
    
    // Assign RGB outputs
    assign {RGB_R, RGB_G, RGB_B} = current_state;

endmodule
