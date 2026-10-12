class transaction ;

typedef enum {write , read} op_t ;

	rand bit we;
	rand bit re;
	rand op_t op ;
	randc bit [6:0] addr ;
	rand bit [7:0] wdata;
	bit [7:0] rdata;
		

function void display_w(string name ="transaction") ;
	$display("[%s], we=1, re=0, addr =%0d, wdata = %0h  " ,name,addr,wdata);
endfunction


function void display_r(string name ="transaction") ;
	$display("[%s], we=0, re=1, addr =%0d, rdata = %0h  " ,name,addr,rdata);
endfunction


constraint operation_c{
	if(op == write){we == 1; re == 0;}
	else if(op == read) {we == 0 ; re == 1 ;}
}

constraint address { addr inside {[0:127]} ;}
endclass


	





