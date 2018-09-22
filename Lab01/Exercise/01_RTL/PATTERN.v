`define CYCLE_TIME 20.0

module PATTERN(
// Output signals
  in_n0,
  in_n1,
  in_n2,
  in_n3,
  opt,
  // Input signals
  out_n
);
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg signed[3:0] in_n0, in_n1, in_n2, in_n3;
output reg[2:0] opt;

input signed[8:0] out_n;
//================================================================
// parameters & integer
//================================================================
reg clk;
real	CYCLE = `CYCLE_TIME;
integer PATNUM = 1000;
integer seed;
integer total_latency;
integer patcount;
integer file_in, file_out, cnt_in, cnt_out;
integer lat;
//================================================================
// wire & registers 
//================================================================
reg	signed[3:0]  sort_n0, sort_n1, sort_n2, sort_n3;
reg	signed[4:0]  rm_n0, rm_n1, rm_n2, rm_n3;
integer avg;
reg	signed[8:0]  ANS;
//================================================================
// clock
//================================================================
always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;
//================================================================
// initial
//================================================================
initial begin
    file_in =  $fopen("../00_TESTBED/inputs.txt", "r");
	file_out = $fopen("../00_TESTBED/outputs.txt", "r");
    if (file_in == 0 || file_out == 0)begin
		$display ("Error in opening the files");
		$finish;
	end

    in_n0 = 4'dx;
	in_n1 = 4'dx;
	in_n2 = 4'dx;
	in_n3 = 4'dx;
	opt = 3'dx;
	force clk = 0;
	release clk;
	total_latency = 0;
	seed = 32;

	for(patcount = 0; patcount < PATNUM; patcount = patcount + 1)
	begin		
		input_task;
		@(negedge clk);
		check_ans;
	end
	
	YOU_PASS_task;
	$fclose(file_in);
	$fclose(file_out);
end

//================================================================
// task
//================================================================
task input_task; begin
	//generate operation and inputs 
	cnt_in = $fscanf(file_in, "%d %d %d %d %d\n", in_n0, in_n1, in_n2, in_n3, opt);
	cnt_out = $fscanf(file_out,"%d\n", ANS);

end endtask

task check_ans; begin
	if( ANS !== out_n ) begin
		$display("**************************************************************");
		$display("*                            PATTERN NO.%4d 	                ",patcount);
		$display("*                 Ans : %d,  Your output : %d  at %8t         ",ANS,out_n,$time);
		$display("**************************************************************");
		$finish;
	end
	else begin
		$display("*                            PATTERN NO.%4d  passed	                ",patcount);
	end
end endtask

task YOU_PASS_task;begin
	  $display ("-------------------------------------------------------------------");
	  $display ("                         Congratulations!                          ");
	  $display ("                  You have passed all patterns!                    ");
	  $display ("                 Your execution cycles = %5d cycles                ", total_latency);
	  $display ("                    Your clock period = %.1f ns                    ", CYCLE);
	  $display ("                    Your total latency = %.1f ns                   ", total_latency*CYCLE);
	  $display ("-------------------------------------------------------------------");    
	  $finish;
end endtask
endmodule
