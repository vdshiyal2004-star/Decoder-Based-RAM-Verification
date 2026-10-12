module ram(     input we,
		input re,
		input [6:0] addr,
		input [7:0]wdata,
		input clk,
		input rst_n,
		output reg [7:0]rdata
	   );

wire [4:0] word_select ;

//////////////////////// memory blocks ////////////////////////////

reg [7:0] mem0 [0:31] ;
reg [7:0] mem1 [0:31] ;
reg [7:0] mem2 [0:31] ;
reg [7:0] mem3 [0:31] ;

///////////////////////// select word ///////////////////////////

assign word_select = addr[4:0] ;

////////////////////////// write block at posedge  ///////////////////////////

always_ff@(posedge clk or negedge rst_n) begin
	if( !rst_n ) begin
		for(int i=0; i<32 ;i++) begin
			mem0[i] <= 8'h00 ;
			mem1[i] <= 8'h00 ;
			mem2[i] <= 8'h00 ;
			mem3[i] <= 8'h00 ;
		end
	end
	else if(we) begin
		case(addr[6:5])
			2'b00 : mem0[word_select] <= wdata ;
			2'b01 : mem1[word_select] <= wdata ;
			2'b10 : mem2[word_select] <= wdata ;
			2'b11 : mem3[word_select] <= wdata ;
 
	
		endcase
	end
end

////////////////////////// read block at negedge  ///////////////////////////

always_ff@(negedge clk or negedge rst_n) begin
	if( !rst_n ) begin
		rdata <= 8'h00;
	end
	else if(re) begin
		case(addr[6:5])
			2'b00 : rdata <= mem0[word_select]   ;
			2'b01 : rdata <= mem1[word_select]   ;
			2'b10 : rdata <= mem2[word_select]   ;
			2'b11 : rdata <= mem3[word_select]   ;

		endcase
	end
end

endmodule










