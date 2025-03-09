`include "memory.sv"

module top(
    input logic     clk, 
    output logic    _9b,    // D0
    output logic    _6a,    // D1
    output logic    _4a,    // D2
    output logic    _2a,    // D3
    output logic    _0a,    // D4
    output logic    _5a,    // D5
    output logic    _3b,    // D6
    output logic    _49a,   // D7
    output logic    _45a,   // D8
    output logic    _48b    // D9
);

    logic [1:0] current_state = 2'b00;
    logic [6:0] quarter_address = 7'd0;
    logic [6:0] read_address;
    logic [9:0] data;
    logic [9:0] output_data;
    
    // Debugging stuff
    logic        invert;
    logic [9:0] inverted_value;

    parameter MAX_VALUE = 10'd1023;

    memory #(
        .INIT_FILE      ("sine.txt")
    ) u1 (
        .clk            (clk), 
        .read_address   (read_address), 
        .read_data      (data)
    );

    // Determine if we should invert
    always_comb begin
        invert = (current_state == 2'b10) || (current_state == 2'b11);
    end

    // Compute the inverted value (if needed)
    always_comb begin
        inverted_value = MAX_VALUE - data;
    end

    // Compute the address to read from memory
    always_comb begin
        if (current_state == 2'b00 || current_state == 2'b10) begin
            // Forward
            read_address = quarter_address;
        end else begin
            // Reverse
            read_address = 7'd127 - quarter_address;
        end
    end

    // Select output data based on invert
    always_comb begin
        if (invert) begin
            output_data = inverted_value;
        end else begin
            output_data = data;
        end
    end

    // State machine and quarter address increment
    always_ff @(posedge clk) begin
        if (quarter_address == 7'd127) begin
            quarter_address <= 7'd0;
            current_state <= current_state + 1;
        end else begin
            quarter_address <= quarter_address + 1;
        end
    end

    // Output assignments
    assign {_48b, _45a, _49a, _3b, _5a, _0a, _2a, _4a, _6a, _9b} = output_data;

endmodule




