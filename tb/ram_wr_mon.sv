//`include"ram_transaction.sv"

class wr_mon ;
	virtual ram_if.wr_mon vif ; 
	
	mailbox #(transaction) sb_wr_mon_mbx ;
	mailbox #(transaction) cov_wr_mbx;
	function new (	virtual ram_if.wr_mon vif , 
			
			mailbox #(transaction) sb_wr_mon_mbx,
			mailbox #(transaction) cov_wr_mbx  );

	this.vif = vif ;
	
	this.sb_wr_mon_mbx =sb_wr_mon_mbx ;
	this.cov_wr_mbx = cov_wr_mbx ;
endfunction

task run ();
	transaction tnx ;
	$display("write monitor started ") ;
	
forever begin 
	@(vif.wr_mon_cb);
	if(vif.wr_mon_cb.we == 1'b1) begin

	tnx = new();
	tnx.op = transaction :: write ;
	tnx.addr = vif.wr_mon_cb.addr ;
	tnx.wdata = vif.wr_mon_cb.wdata;

	tnx.display_w ("wr_monitor");  //$display("[%s], we=%0b, re=%0b, addr =%0d, wdata = %0h  ,rdata =%0h " ,name,we,re,addr,wdata,rdata);
	sb_wr_mon_mbx.put (tnx);  // sb = scoreboard 
      // rf = reference module 
	cov_wr_mbx.put(tnx) ;

	end

end
endtask

endclass 