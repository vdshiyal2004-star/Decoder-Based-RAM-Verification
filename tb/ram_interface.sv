interface ram_if(input logic clk) ;

logic we;
logic re;
logic [7:0] rdata ;
logic [7:0] wdata ;
logic [6:0]addr ;
logic rst_n ;

clocking wr_cb @(posedge clk);
	default input #1 output #1 ;
	input rdata;
	output we;
	output addr;
	output wdata ;
	output rst_n ;

endclocking


clocking rd_cb @(posedge clk) ;
	default input #1 output #1 ;
	input rdata;
	output re;
	output addr;
endclocking

clocking wr_mon_cb @(posedge clk);
	default input #1 ;
	input we;
	input wdata;
	input addr;
	
endclocking

clocking rd_mon_cb @(posedge clk);
	default input #1;
	input re;
	input rdata;
	input addr;
endclocking

modport wr_drv (clocking wr_cb , input clk );
modport rd_drv (clocking rd_cb , input clk );
modport wr_mon (clocking wr_mon_cb , input clk );
modport rd_mon (clocking rd_mon_cb , input clk );

endinterface