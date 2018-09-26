//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2018 Fall
//   Lab02 Exercise		: Inverse Matrix Calculater
//   Author     		: Ping-Yuan Tsai (bubblegame@si2lab.org)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//   Release version : V1.0 (Release Date: 2018-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`define CYCLE_TIME     10.0
`define SEED_NUMBER     123
`define PATTERN_NUMBER 1000

module PATTERN(
    //Output Port
    clk,
    rst_n,
    IN_VALID,
    IN,

    //Input Port
    OUT_VALID,
    OUT
    );

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output          clk, rst_n, IN_VALID;
output  [ 3:0]  IN;
input           OUT_VALID;
input   [13:0]  OUT;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
integer SEED = `SEED_NUMBER;
real    CYCLE = `CYCLE_TIME;
integer i, p, x, lat;

//---------------------------------------------------------------------
//   WIRE & REGISTER DECLARATION
//---------------------------------------------------------------------
reg          clk, rst_n, IN_VALID;
reg  [ 3:0]  IN;

reg [1:0] t;
reg signed  [3:0] a, b, c, d;
reg signed  [8:0] det;
reg signed [13:0] temp;
reg signed [13:0] e, f, g, h;

reg signed [13:0] Y_OUT, C_OUT, your_e, your_f, your_g, your_h;

//---------------------------------------------------------------------
//   CLOCK
//---------------------------------------------------------------------
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//   TEST PATTERN                                         
//---------------------------------------------------------------------
initial
begin
    rst_n=1'b1;
    clk=0;
    IN_VALID = 1'b0;
    IN = 4'hX;

    reset_signal_task;
	
    for (p=0; p<`PATTERN_NUMBER; p=p+1)
    begin
        input_task;
        wait_OUT_VALID;
        check_ans;
    end
    YOU_PASS_task;
end

task reset_signal_task; begin 
    @(negedge clk); rst_n = 0; 
    @(negedge clk); rst_n = 1;
    if(OUT_VALID!==1'b0) begin
        $display("*****************************************************");
        $display("*     OUT_VALID should be 0 after initial RESET     *");
        $display("*****************************************************");
	repeat(2) @(negedge clk);
	$finish;
    end
end endtask

task input_task; begin

    // random delay between patterns
    t=$random(SEED)%2'd3+1; // 1~3 cycles
    repeat(t)
        @(negedge clk);

    // generating input
    a=$random(SEED);
    b=$random(SEED);
    c=$random(SEED);
    d=$random(SEED);
    det = a*d-b*c;
    
  if(det!=0) begin
    // calculate correct answer
    temp = {d, 10'b0};
    e = temp / det;
    temp = {b, 10'b0};
    f = - (temp / det);
    temp = {c, 10'b0};
    g = - (temp / det);
    temp = {a, 10'b0};
    h = temp / det;
  end
    // sending out input
    IN_VALID = 1'b1;
    IN = a;
    @(negedge clk);
    IN = b; 
    @(negedge clk);
    IN = c; 
    @(negedge clk);
    IN = d;
    @(negedge clk);
    IN_VALID = 1'b0;
    IN = 4'hX;
  
end endtask

task check_ans; begin
  if(det!=0) begin
    x=1;
    while(OUT_VALID===1'b1) begin
        if(x==1) begin
            C_OUT = e; Y_OUT = OUT; your_e = OUT;
        end
        else if(x==2) begin
            C_OUT = f; Y_OUT = OUT; your_f = OUT;
        end
        if(x==3) begin
            C_OUT = g; Y_OUT = OUT; your_g = OUT;
        end
        else if(x==4) begin
            C_OUT = h; Y_OUT = OUT; your_h = OUT;
        end
        else if(x>=5) begin
            $display ("---------------------------------------------------");
            $display ("          Outvalid is more than 4 cycles.          ");
            $display ("---------------------------------------------------");
            repeat(2) @(negedge clk);
            $finish;
        end
        @(negedge clk);	
        x=x+1;
    end

    if(x<5) begin
        $display ("---------------------------------------------------");
        $display ("          Outvalid is less than 4 cycles.          ");
        $display ("---------------------------------------------------");
        repeat(2) @(negedge clk);
        $finish;
    end
    else if(your_e!==e || your_f!==f || your_g!==g || your_h!==h) begin
        $display ("---------------------------------------------------");
        $display ("                  Output Error.                    ");
        $display ("             input matrix: %3d %3d                 ",a,b);
        $display ("                           %3d %3d                 ",c,d);
        $display ("    Correct inverse matrix: %6.3f %6.3f          ",e/1024.0,f/1024.0);
        $display ("                            %6.3f %6.3f          ",g/1024.0,h/1024.0);
        $display ("     Your   inverse matrix: %6.3f %6.3f          ",your_e/1024.0,your_f/1024.0);
        $display ("                            %6.3f %6.3f          ",your_g/1024.0,your_h/1024.0);
        $display ("---------------------------------------------------");
        repeat(2) @(negedge clk);
        $finish;    
    end
  end
  else begin
   x=1;
    while(OUT_VALID===1'b1) begin
        if(x==1) begin
            C_OUT = 0; Y_OUT = OUT; your_e = OUT;
        end
        else if(x>=2) begin
            $display ("--------------------------------------------------------");
            $display ("                    Output Error.                       ");
            $display ("               input matrix: %3d %3d                    ",a,b);
            $display ("                             %3d %3d                    ",c,d);
            $display ("Outvalid should be raised for only 1 cycle when det == 0");
            $display ("--------------------------------------------------------");
            repeat(2) @(negedge clk);
            $finish;
        end
        @(negedge clk);	
        x=x+1;
    end

    if(your_e!==0) begin
        $display ("---------------------------------------------------");
        $display ("                  Output Error.                    ");
        $display ("             input matrix: %3d %3d                 ",a,b);
        $display ("                           %3d %3d                 ",c,d);
        $display ("        Ouput should be zero when det == 0         ");
        $display ("---------------------------------------------------");
        repeat(2) @(negedge clk);
        $finish;    
    end  
  end
    $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Latency: %3d\033[m",p ,lat);
end endtask

task wait_OUT_VALID; begin
    lat=-1;
    while(OUT_VALID!==1) begin
	lat=lat+1;
	if(lat==1001)begin
            $display ("---------------------------------------------------");
            $display ("    The execution latency are over 1000 cycles.    ");
            $display ("---------------------------------------------------");
	    repeat(2)@(negedge clk);
	    $finish;
	end
	@(negedge clk);
    end
end endtask

task YOU_PASS_task; begin
    $display ("--------------------------------------------------------------------");
    $display ("                         Congratulations!                           ");
    $display ("                  You have passed all patterns!                     ");
    $display ("--------------------------------------------------------------------");        
    repeat(2)@(negedge clk);
    $finish;
end endtask

endmodule


