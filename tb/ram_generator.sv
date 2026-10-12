//`include "ram_transaction.sv"

class generator;

    mailbox #(transaction) wr_mbx;
    mailbox #(transaction) rd_mbx;
    mailbox #(bit) writes_done_mbx;
    mailbox #(bit) reads_done_mbx;

    function new(
        mailbox #(transaction) wr_mbx,
        mailbox #(transaction) rd_mbx,
        mailbox #(bit) writes_done_mbx,
        mailbox #(bit) reads_done_mbx
    );
        this.wr_mbx = wr_mbx;
        this.rd_mbx = rd_mbx;
        this.writes_done_mbx = writes_done_mbx;
        this.reads_done_mbx = reads_done_mbx;

    endfunction

    task run();

        transaction tnx;
        logic [6:0] addr_order[];
        logic [7:0] pattern;
        bit done;

        addr_order = new[128];

        // Initialize all addresses
        for (int i = 0; i < 128; i++)
            addr_order[i] = i;


        // Eight complete write/read passes
for (int phase = 0; phase < 8; phase++) begin

            // Shuffle addresses for each pass
            for (int i = 0; i < 128; i++)
                addr_order[i] = i;

            addr_order.shuffle();

            $display("");
            $display("====================================");
            $display("GENERATOR PHASE %0d", phase);
            $display("====================================");

            // -------------------------------
            // WRITE PHASE
            // -------------------------------
            for (int i = 0; i < 128; i++) begin

                tnx = new();

                if (!tnx.randomize() with {
                    op == transaction::write;
                    addr == addr_order[i];
                }) begin

                    $fatal(1, "Write randomization failed");
                end

                // Directed patterns
                case (phase)

                    // Phase 0: All zeros
                    0: tnx.wdata = 8'h00;

                    // Phase 1: All ones
                    1: tnx.wdata = 8'hFF;

                    // Phase 2: Alternating bits
                    2: tnx.wdata = 8'hAA;

                    // Phase 3: Opposite alternating bits
                    3: tnx.wdata = 8'h55;

                    // Phase 4: Walking one
                    4: tnx.wdata = 8'h01 << (i % 8);

                    // Phase 5: Walking zero
                    5: tnx.wdata = ~(8'h01 << (i % 8));

                    // Phase 6: Address-derived pattern
                    6: tnx.wdata = addr_order[i] ^ 8'hA5;

                    // Phase 7: Random data from randomization
                    7: ; 

                endcase

                wr_mbx.put(tnx);

            end

            // Wait until scoreboard processes this write batch
            //given by scoreboard that it is completed ok 
		do begin
  		  writes_done_mbx.get(done);
		end while (done != 1);

            // -------------------------------
            // READ PHASE
            // -------------------------------
            for (int i = 0; i < 128; i++) begin

                tnx = new();

                if (!tnx.randomize() with {
                    op == transaction::read;
                }) begin
                    $fatal(1, "Read randomization failed");
                end

                // Read every address in this pass
                tnx.addr = addr_order[i];
                rd_mbx.put(tnx);

            end

            // Wait until scoreboard processes this read batch
		do begin
  		  reads_done_mbx.get(done);
		end while (done != 1);

            $display(
                "[%0t] Phase %0d completed",
                $time, phase
            );

        end


        // -------------------------------
        // REPEATED RANDOM READS
        // -------------------------------
        $display("Starting repeated random-read phase");

        for (int i = 0; i < 128; i++) begin

            tnx = new();

            if (!tnx.randomize() with {
                op == transaction::read;
            }) begin
                $fatal(1, "Repeated-read randomization failed");
            end

            tnx.addr = $urandom_range(0, 127);

            rd_mbx.put(tnx);

        end

        // Wait for this final batch of 128 reads
		do begin
  		  reads_done_mbx.get(done);
		end while (done != 1);


        $display("[%0t] Generator completed all tests", $time);

    endtask

endclass


