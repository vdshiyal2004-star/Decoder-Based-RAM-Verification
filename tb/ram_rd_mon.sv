//`include"ram_transaction.sv"

class rd_mon;

	virtual ram_if.rd_mon vif;
	
	mailbox #(transaction) sb_rd_mon_mbx ; // scoreboard 
	mailbox #(transaction) cov_rd_mbx;

function new (  virtual ram_if.rd_mon vif,
		
		mailbox #(transaction) sb_rd_mon_mbx,     
		mailbox #(transaction) cov_rd_mbx );

	this.vif = vif ;
	this.sb_rd_mon_mbx = sb_rd_mon_mbx ;
	this.cov_rd_mbx = cov_rd_mbx ;
endfunction 

task run();

transaction tnx;
	$display("read monitor started ") ;

forever begin

	@(vif.rd_mon_cb);
	if(vif.rd_mon_cb.re == 1'b1) begin

	tnx = new();
	tnx.op = transaction :: read ;
	tnx.addr = vif.rd_mon_cb.addr ;
	tnx.rdata = vif.rd_mon_cb.rdata ;


	tnx.display_r ("read monitor ");  //$display("[%s], we=%0b, re=%0b, addr =%0d, wdata = %0h  ,rdata =%0h " ,name,we,re,addr,wdata,rdata);

	sb_rd_mon_mbx.put(tnx);
	cov_rd_mbx.put(tnx);
	end

end
endtask

endclass

