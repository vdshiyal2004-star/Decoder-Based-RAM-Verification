//`include"ram_transaction.sv"
class wr_drv ;
	virtual ram_if.wr_drv vif;

	mailbox #(transaction) wr_mbx ;
	
	function new(virtual ram_if.wr_drv vif ,mailbox #(transaction)wr_mbx );
		this.vif = vif;
		this.wr_mbx = wr_mbx ;
	endfunction
///////////////////////////////////////////////////////////////////////////

task reset (int cycles = 4 );
	$display("applying reset task");
	vif.wr_cb.rst_n <=0;
	vif.wr_cb.we <= 1'b0;
	vif.wr_cb.addr <= 0;
	vif.wr_cb.wdata <= 0;
	repeat (cycles)@(vif.wr_cb)
	vif.wr_cb.rst_n <= 1'b1;
	$display("reset desserted ") ;
endtask

///////////////////////////////////////////////////////////////////////////

task driver(transaction tnx) ;

	@(vif.wr_cb);
	vif.wr_cb.we <= 1'b1;
	vif.wr_cb.addr <= tnx.addr ;
	vif.wr_cb.wdata <=tnx.wdata ;

	@(vif.wr_cb);

	vif.wr_cb.we <= 1'b0 ;

	
endtask

///////////////////////////////////////////////////////////////////////////

task run();
	
	transaction tnx ;
	forever begin 
		wr_mbx.get(tnx) ;
		driver (tnx);
	end
endtask



endclass













