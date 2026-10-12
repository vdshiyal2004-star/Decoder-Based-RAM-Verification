//`include"ram_transaction.sv"

class rd_drv ;

	virtual ram_if.rd_drv vif ;
	mailbox #(transaction) rd_mbx ;
	

function new(virtual ram_if.rd_drv vif , mailbox #(transaction) rd_mbx) ;
		this.vif = vif ;
		this.rd_mbx  = rd_mbx ; 
endfunction

task driver (transaction tnx);
	@(vif.rd_cb);

	vif.rd_cb.addr <= tnx.addr ;
	vif.rd_cb.re <= 1'b1;

	@(vif.rd_cb);

	vif.rd_cb.re <= 1'b0 ;

endtask 
task run() ;

	transaction tnx ;
	forever begin
	rd_mbx.get(tnx);
	driver(tnx) ;
	end
 
endtask
	


endclass





