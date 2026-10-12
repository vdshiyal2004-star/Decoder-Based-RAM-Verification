
class coverage;

    mailbox #(transaction) wr_cov_mbx;
    mailbox #(transaction) rd_cov_mbx;

    virtual ram_if vif;

    transaction wr_tnx;
    transaction rd_tnx;

    int wr_sample_count = 0;
    int rd_sample_count = 0;

    bit reset_seen = 0;
    bit reset_release_seen = 0;
    bit post_reset_read_seen = 0;

    // ------------------------------------------
    // WRITE FUNCTIONAL COVERAGE
    // ------------------------------------------
    covergroup wr_cg;

        cp_addr: coverpoint wr_tnx.addr {
            bins block0 = {[0:31]};
            bins block1 = {[32:63]};
            bins block2 = {[64:95]};
            bins block3 = {[96:127]};
        }

        cp_data: coverpoint wr_tnx.wdata {
            bins zero = {8'h00};
            bins ones = {8'hFF};
            bins aa = {8'hAA};
            bins data_55 = {8'h55};
            bins walking_one[] = {
                8'h01, 8'h02, 8'h04, 8'h08,
                8'h10, 8'h20, 8'h40, 8'h80
            };
            bins walking_zero[] = {
                8'hFE, 8'hFD, 8'hFB, 8'hF7,
                8'hEF, 8'hDF, 8'hBF, 8'h7F
            };
            bins other = default;
        }

        // Verify that every memory block sees
        // the important data patterns.
        cp_block_data: cross cp_addr, cp_data;

    endgroup


    // ------------------------------------------
    // READ FUNCTIONAL COVERAGE
    // ------------------------------------------
    covergroup rd_cg;

        cp_addr: coverpoint rd_tnx.addr {
            bins block0 = {[0:31]};
            bins block1 = {[32:63]};
            bins block2 = {[64:95]};
            bins block3 = {[96:127]};
        }

        cp_read_data: coverpoint rd_tnx.rdata {
            bins zero = {8'h00};
            bins ones = {8'hFF};
            bins aa = {8'hAA};
            bins data_55 = {8'h55};
            bins other = default;
        }

        cp_block_data: cross cp_addr, cp_read_data;

    endgroup


    // ------------------------------------------
    // CONSTRUCTOR
    // ------------------------------------------
    function new(
        mailbox #(transaction) wr_cov_mbx,
        mailbox #(transaction) rd_cov_mbx,
        virtual ram_if vif
    );

        this.wr_cov_mbx = wr_cov_mbx;
        this.rd_cov_mbx = rd_cov_mbx;
        this.vif = vif;

        wr_cg = new();
        rd_cg = new();

    endfunction


    // ------------------------------------------
    // COVERAGE SAMPLING
    // ------------------------------------------
    task run();

        fork

            begin
                forever begin
                    wr_cov_mbx.get(wr_tnx);
                    wr_cg.sample();
                    wr_sample_count++;
                end
            end

            begin
                forever begin
                    rd_cov_mbx.get(rd_tnx);
                    rd_cg.sample();
                    rd_sample_count++;

                    if (vif.rst_n)
                        post_reset_read_seen = 1;
                end
            end

            begin
                forever begin
                    @(negedge vif.rst_n);
                    reset_seen = 1;
                end
            end

            begin
                forever begin
                    @(posedge vif.rst_n);
                    reset_release_seen = 1;
                end
            end

        join_none

    endtask


    // ------------------------------------------
    // COVERAGE REPORT
    // ------------------------------------------
    function void report();

        $display("");
        $display("================================================");
        $display("            FUNCTIONAL COVERAGE REPORT");
        $display("================================================");

        $display("Write samples       = %0d", wr_sample_count);
        $display("Read samples        = %0d", rd_sample_count);

        $display("Write coverage      = %0.2f%%",
                 wr_cg.get_coverage());

        $display("Read coverage       = %0.2f%%",
                 rd_cg.get_coverage());

        $display("Reset asserted      = %0b", reset_seen);
        $display("Reset released      = %0b", reset_release_seen);
        $display("Post-reset read seen= %0b",
                 post_reset_read_seen);

        $display("================================================");

    endfunction

endclass

