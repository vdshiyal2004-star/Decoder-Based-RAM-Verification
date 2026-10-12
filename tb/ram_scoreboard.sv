//`include "ram_transaction.sv"
class scoreboard  ;

	mailbox#(transaction) sb_wr_mon_mbx;
	mailbox#(transaction) sb_rd_mon_mbx;
	mailbox #(bit) writes_done_mbx;
	mailbox#(bit) reads_done_mbx ;

	logic [7:0] expected_mem [0:127] ;

	int pass_count ;
	int fail_count ;
	int write_count;
	int read_count;


function new(   mailbox#(transaction) sb_wr_mon_mbx,
		mailbox#(transaction) sb_rd_mon_mbx ,
		mailbox #(bit) writes_done_mbx,
		mailbox#(bit) reads_done_mbx);

		this.sb_wr_mon_mbx = sb_wr_mon_mbx ;
		this.sb_rd_mon_mbx =sb_rd_mon_mbx ;
		this.writes_done_mbx = writes_done_mbx ;
		this.reads_done_mbx = reads_done_mbx ;

		pass_count = 0;
		fail_count = 0;
		write_count =0;
		read_count = 0;

	foreach(expected_mem[i]) begin expected_mem[i] = 8'h00 ; end

endfunction

task write_check ();

	transaction tnx ;
	forever begin 
	sb_wr_mon_mbx.get(tnx);
	expected_mem[tnx.addr] = tnx.wdata ;
	write_count++;

$display("[SCOREBOARD WRITE] addr =%0d wdata = %0h",tnx.addr,tnx.wdata);

if ((write_count % 128) == 0) begin
    bit done = 1'b1;
    writes_done_mbx.put(done);
    $display("[%0t] All 128 writes checked", $time);
end
else begin
    bit done = 1'b0;
    writes_done_mbx.put(done);

end

	end

endtask


task read_check ();

	transaction tnx ;

	logic [7:0] expected_data ;
	
	forever begin

	sb_rd_mon_mbx.get(tnx) ;
	expected_data  = expected_mem[tnx.addr] ;	

	if(expected_data == tnx.rdata ) begin 
	pass_count ++ ;
	read_count++; 
	$display("[SCOREBOARD PASS] addr = %0d expected=%0h actual=%0h ",tnx.addr ,expected_data ,tnx.rdata );
	end

	else begin
	fail_count ++;
	read_count++; 

	$error("[SCOREBOARD FAIL] addr = %0d expected=%0h actual=%0h",tnx.addr ,expected_data, tnx.rdata);
	
	end

	
if ((read_count % 128) == 0) begin
    bit done = 1'b1;
    reads_done_mbx.put(done);
end
else begin
    bit done = 1'b0;
    reads_done_mbx.put(done);

end

end

endtask

task run() ;
	fork
		write_check();
		read_check ();
	join_none
endtask


task reset_expected_memory();

    foreach (expected_mem[i])
        expected_mem[i] = 8'h00;

    $display("[%0t] SCOREBOARD: Reference memory cleared",
             $time);

endtask



function void report();
	$display("========================================================");
	$display("		SCOREBOARD REPORT 			  ");
	$display("========================================================");
	$display ("PASS COUNT = %0d",pass_count);
	$display ("FAIL COUNT = %0d",fail_count);
	$display("========================================================");
	if (fail_count == 0)
  	  $display("TEST RESULT = PASS");
	else
  	  $display("TEST RESULT = FAIL");

endfunction


endclass 










