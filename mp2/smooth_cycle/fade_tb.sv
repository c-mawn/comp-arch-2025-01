`timescale 10ns/10ns

module fade_tb;
    logic clk = 0;
    logic RGB_R, RGB_G, RGB_B;
    
    top dut (
        .clk(clk),
        .RGB_R(RGB_R),
        .RGB_G(RGB_G),
        .RGB_B(RGB_B)
    );

    initial begin
        $dumpfile("fade.vcd");
        $dumpvars(0, fade_tb);
        #2000000000;  // Simulate for 2 seconds
        $finish;
    end

    // 12MHz clock (83.33ns period)
    always #41.666667 clk = ~clk;
endmodule