
class ram_test;

    virtual ram_if vif;
    ram_env env;

    function new(virtual ram_if vif);
        this.vif = vif;
        env = new(vif);
    endfunction


    // Reset and verify all 128 memory addresses
    task reset_test();

        transaction tnx;

        $display("");
        $display("========================================");
        $display("       RESET VERIFICATION START");
        $display("========================================");

        // Assert reset after all previous transactions finish
        @(negedge vif.clk);
        vif.we = 1'b0;
        vif.re = 1'b0;
        vif.rst_n = 1'b0;

        // Allow reset to clear the DUT memory
        repeat (2) @(negedge vif.clk);

        // Synchronize the scoreboard reference memory
        env.sb.reset_expected_memory();

        // Release reset
        vif.rst_n = 1'b1;

        repeat (2) @(negedge vif.clk);

        $display("[%0t] Reset released", $time);

        // Read every address after reset
        for (int i = 0; i < 128; i++) begin

            tnx = new();

            tnx.op = transaction::read;
            tnx.we = 1'b0;
            tnx.re = 1'b1;
            tnx.addr = i;

            env.rd_mbx.put(tnx);

        end

        // Wait until all 128 post-reset reads are checked
        wait (env.sb.read_count == 1280);

        $display("[%0t] All 128 post-reset reads checked",
                 $time);

        $display("========================================");
        $display("       RESET VERIFICATION END");
        $display("========================================");

    endtask


    // Main test
    task run();

        $display("");
        $display("========================================");
        $display("       RAM VERIFICATION TEST");
        $display("========================================");

        // Initial reset
        vif.rst_n = 1'b0;
        vif.we = 1'b0;
        vif.re = 1'b0;
        vif.addr = 7'd0;
        vif.wdata = 8'd0;

        repeat (4) @(negedge vif.clk);

        vif.rst_n = 1'b1;

        $display("[%0t] Initial reset released", $time);

        // Start generator, drivers, monitors, scoreboard, coverage
        env.run();


$display("[%0t] Environment started", $time);

// Wait for all original generator transactions
wait (env.sb.write_count == 1024);
$display("[%0t] All 1024 writes completed", $time);

wait (env.sb.read_count == 1152);
$display("[%0t] All 1152 original reads completed", $time);

// Now perform reset verification.
// This task adds another 128 reads.
reset_test();

// Final reports
env.sb.report();
env.cov.report();

$display("[%0t] RAM verification completed", $time);
$finish;


    endtask

endclass
