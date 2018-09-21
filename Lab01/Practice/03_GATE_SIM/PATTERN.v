`define CLK_PERIOD  30.0

module PATTERN(
	in_n0,
    in_n1,
    opt,
	out_n
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
output reg [2:0]  in_n0,in_n1;
output reg [1:0]  opt;
input wire signed[6:0] out_n;

//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
integer i, j;
integer seed;
integer NUM_PATTERN;
 	
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION                             
//---------------------------------------------------------------------
reg signed[6:0] ans;

//---------------------------------------------------------------------
//CLK DECLARATION                             
//---------------------------------------------------------------------
reg CLK;
real CYCLE;
initial begin
	CLK=15;
	CYCLE=`CLK_PERIOD;
end
always #(CYCLE/2) CLK = ~CLK;
//---------------------------------------------------------------------
//   TEST PATTERN                                         
//---------------------------------------------------------------------
initial begin
	in_n0 =0;
	in_n1 =0;
	opt = 0;
        ans = 0;
 	
	seed = 256;
	NUM_PATTERN = 100;

	@(negedge CLK);
    
	for( i = 1 ; i <= NUM_PATTERN; i = i + 1)
	begin    
        //$display("PATTERN %d", i);
		in_n0 =$random(seed)%4'd8;		
		in_n1 =$random(seed)%4'd8;		
		opt =  $random(seed)%2'd3;						

		case(opt)		
			2'b00:
				ans = in_n0 + in_n1;
			2'b01:
				ans = in_n0 - in_n1;
		    2'b10:
				ans = in_n0 * in_n1;
                 
		default: ans = ans;		
		endcase		
				
				
		@(negedge CLK)			
		if(ans !== out_n)
		begin		
		  $display("\033[1;31m   ******---------******---------******---------******   \033[m");		
		  $display("opt=%d ",opt);		
		  $display("in_n0: %d  in_n1: %d",in_n0, in_n1);		
		  $display("your ANS: %d correct ANS: %d",out_n, ans);		
		  $finish;				
		end		
		else begin
			$display("PATTERN %d pass", i);
		end
	end        
	pass_print;
	$finish;
end

task pass_print ;
begin
    $display("\033[1;35m You have passed this pattern!!\033[m");	
	$display("\033[1;31m   ******---------******   \033[m");		
	$display("\033[1;33m   **                 **   \033[m");
	$display("\033[1;32m   ** congratulation! **   \033[m");
	$display("\033[1;33m   **                 **   \033[m");	
	$display("\033[1;31m   ******---------******   \033[m");
end	
endtask

endmodule


