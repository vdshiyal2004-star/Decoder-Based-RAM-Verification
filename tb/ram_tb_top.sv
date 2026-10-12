

module ram_tb_top;

    import ram_pkg::*;
    `include "ram_test.sv"
    // Clock
    bit clk = 1'b0;

    always #5 clk = ~clk;


    // Interface
    ram_if vif(clk);


    // DUT
    ram dut (
        .we    (vif.we),
        .re    (vif.re),
        .addr  (vif.addr),
        .wdata (vif.wdata),
        .clk   (clk),
        .rst_n (vif.rst_n),
        .rdata (vif.rdata)
    );


    // Test handle
   // ram_test test;

	ram_test test;

    // Start test
    initial begin

        $display("========================================");
        $display("       RAM TESTBENCH STARTED");
        $display("========================================");

        test = new(vif);

        test.run();

    end

endmodule
