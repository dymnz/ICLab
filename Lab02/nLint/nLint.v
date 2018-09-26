//#######################################################################################
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  (C) Copyright Laboratory Optimum Application-Specific Integrated System
//  All Right Reserved.
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//  2018 Fall ICLAB Course
//  Lab02     : nLint Tool Demo Case
//  Author    : Shiang-Yu Hung
//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//  File Name       : nLint.v
//  Module Name     : nLint
//  Release version : V1.1 (Release Date:2009-03)
//
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//#######################################################################################

module nLint(
   //Input Port
    CLK,RESET,IN_VALID,IN,
    //Output Port
    OUT_VALID, OUT
	);

input           CLK,RESET,IN_VALID;
input   [ 3:0]  IN;
output          OUT_VALID;
output  [ 3:0]  OUT;

reg          OUT_VALID;
reg  [ 3:0]  OUT;

reg  [ 2:0]  FLAG,COUNT;
reg  [ 4:0]  TEMP_T,TEMP;

//------------------------------------------------------------------
//      FLAG  is assigned by blocking and non-blocking assignment 
//------------------------------------------------------------------
always@(posedge CLK)begin
   if(RESET)              FLAG  <= 3'd0;
   else if(IN_VALID)      FLAG   =  FLAG+1'd1;  //  <---
   else                   FLAG  <=  FLAG;
end


//------------------------------------------------------------------
//     COUNT is driven by mutiple always block 
//------------------------------------------------------------------
always@(posedge CLK)begin
   if(RESET)            COUNT  <= 3'd0;
   else if(IN == FLAG)  COUNT  <= COUNT+1'd1;   
   else                 COUNT  <= COUNT;   
end
always@(posedge CLK)begin               
   if(IN_VALID)         COUNT  <= COUNT+1'd1;
   else                 COUNT  <= COUNT;   
end




always@(posedge CLK)begin
   if(RESET)            TEMP <= 5'd0;
   else                 TEMP <= TEMP_T; 
end

always@(COUNT or IN  )begin                        //  <--- incomplete sensitivity list
   if(COUNT == 3'd1)            TEMP_T = IN+FLAG;  //  <--- size mismatch
   else if(COUNT == 3'd2)       TEMP_T = TEMP_T;   //  <--- combinationl loop
                                                   //  <--- no "else" statement 
end



always@(posedge CLK)begin               
   if(RESET)            OUT_VALID  <= 1'b0;
   else if(COUNT>=3'd3) OUT_VALID  <= 1'b1;
   else                 OUT_VALID  <= 1'b0;   
end

always@(posedge CLK)begin               
   if(RESET)            OUT  <= 4'd0;
   else if(COUNT==3'd2) OUT  <= TEMP;   //<--- size mismatch
   else                 OUT  <= OUT;   
end



endmodule
