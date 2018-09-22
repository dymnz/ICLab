module Reduce_mean (
	n0, n1, n2, n3,
	rm_n0, rm_n1, rm_n2, rm_n3
);

input wire signed [5:0] n0, n1, n2, n3;	// Using 6-bit to avoid over flow
output reg signed [5:0] rm_n0, rm_n1, rm_n2, rm_n3;

reg signed [5:0] mean;

always @(*) begin
	mean = (n0 + n1 + n2 + n3);

	if (mean >= 0) begin
		mean = mean >>> 2;
	end else begin
		mean = -mean;
		mean = mean >>> 2;
		mean = -mean;
	end

	rm_n0 <= n0 - mean;
	rm_n1 <= n1 - mean;
	rm_n2 <= n2 - mean;
	rm_n3 <= n3 - mean;
end

endmodule

/*
module RM_tb();

reg [5:0] n0, n1, n2, n3;
wire signed [5:0] rm_n0, rm_n1, rm_n2, rm_n3;

Reduce_mean rm_0(
	n0, n1, n2, n3,
	rm_n0, rm_n1, rm_n2, rm_n3
);

initial begin		
	#10 
	n0 = 0; n1 = 1; n2 = -1; n3 = -5;
	#10
	$display("%4d %4d %4d %4d\n", rm_n0, rm_n1, rm_n2, rm_n3);
	#10 
	n0 = -1; n1 = -2; n2 = -3; n3 = -4;
	#10
	$display("%4d %4d %4d %4d\n", rm_n0, rm_n1, rm_n2, rm_n3);			
end
endmodule	
*/