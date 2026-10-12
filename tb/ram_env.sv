
class ram_env;

    // Virtual interface
    virtual ram_if vif;

    // Generator mailboxes
    mailbox #(transaction) wr_mbx;
    mailbox #(transaction) rd_mbx;
	
    mailbox #(bit) writes_done_mbx;
    mailbox #(bit) reads_done_mbx;

    // Write monitor mailboxes
    mailbox #(transaction) sb_wr_mon_mbx;
    mailbox #(transaction) cov_wr_mbx;

    // Read monitor mailboxes
    mailbox #(transaction) sb_rd_mon_mbx;
    mailbox #(transaction) cov_rd_mbx;

    // Component handles
    generator gen;
    wr_drv wdrv;
    rd_drv rdrv;
    wr_mon wmon;
    rd_mon rmon;
    scoreboard sb;
    coverage cov;

    // Constructor
    function new(virtual ram_if vif);

        this.vif = vif;

        // Create mailboxes
        wr_mbx = new();
        rd_mbx = new();

	writes_done_mbx = new();
	reads_done_mbx  = new();

        sb_wr_mon_mbx = new();
        cov_wr_mbx = new();

        sb_rd_mon_mbx = new();
        cov_rd_mbx = new();

        // Create generator
	gen = new(wr_mbx, rd_mbx, writes_done_mbx,reads_done_mbx);

        // Create drivers
        wdrv = new(vif, wr_mbx);
        rdrv = new(vif, rd_mbx);

	//create coverage mailbox
	cov_wr_mbx = new();
	cov_rd_mbx = new();

        // Create monitors
        wmon = new(vif,sb_wr_mon_mbx, cov_wr_mbx);
        rmon = new(vif,sb_rd_mon_mbx, cov_rd_mbx);

        // Create scoreboard
        sb = new(sb_wr_mon_mbx, sb_rd_mon_mbx, writes_done_mbx , reads_done_mbx);
	
        // Create coverage
        cov = new(cov_wr_mbx, cov_rd_mbx, vif);

    endfunction


    // Start all components
    task run();

        fork
            gen.run();
            wdrv.run();
            rdrv.run();
            wmon.run();
            rmon.run();
            sb.run();
            cov.run();
        join_none

    endtask

endclass
