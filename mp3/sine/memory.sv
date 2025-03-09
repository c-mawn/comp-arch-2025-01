// Sample memory module

module memory #(
    parameter INIT_FILE = ""
)(
    input logic     clk,
    input logic     [6:0] read_address, //7 bits for 128 lines of sine.txt
    output logic    [9:0] read_data
);

    // Declare memory array for storing 512 10-bit samples of a sine function
    logic [9:0] sample_memory [0:127];

    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, sample_memory);
    end

    always_ff @(posedge clk) begin
        read_data <= sample_memory[read_address];
    end

endmodule
