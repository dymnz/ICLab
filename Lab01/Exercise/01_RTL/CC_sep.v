`include "Sort.v"
`include "Reduce_mean.v"

module CC(
	in_n0,
	in_n1, 
	in_n2, 
	in_n3, 
	opt,
	out_n
);

input wire signed [3:0] in_n0, in_n1, in_n2, in_n3;
input wire [2:0] opt;
output reg signed [8:0] out_n;

reg signed [5:0] n0, n1, n2, n3;				// Input for RM stage, using 6-bit to avoid over flow
reg signed [8:0] ar_n0, ar_n1, ar_n2, ar_n3;	// Input for AR stage, using 8-bit to avoid over flow 		

wire signed [3:0] sort_n0, sort_n1, sort_n2, sort_n3; // Result after Sort Stage, n0>>>n3
wire signed [5:0] rm_n0, rm_n1, rm_n2, rm_n3;	// Result after RM stage, using 6-bit to avoid over flowm


Sort sort_0(
	in_n0, in_n1, in_n2, in_n3, 
	sort_n0, sort_n1, sort_n2,sort_n3	
);

Reduce_mean rm_0(
	n0, n1, n2, n3,
	rm_n0, rm_n1, rm_n2, rm_n3
);


// Select sorting output
always @(*) begin
	case (opt[0])
		1'b0: begin
			n0 <= in_n0;
			n1 <= in_n1;
			n2 <= in_n2;
			n3 <= in_n3;
		end
		1'b1: begin
			n0 <= sort_n0;
			n1 <= sort_n1;
			n2 <= sort_n2;
			n3 <= sort_n3;			
		end
	endcase
end

// Select reduce mean
always @(*) begin
	case (opt[1])
		1'b0: begin
			ar_n0 <= n0;
			ar_n1 <= n1;
			ar_n2 <= n2;
			ar_n3 <= n3;	
		end
		1'b1: begin
			ar_n0 <= rm_n0;
			ar_n1 <= rm_n1;
			ar_n2 <= rm_n2;
			ar_n3 <= rm_n3;				
		end
	endcase
end

// Select arithmatic op
always @(*) begin
	case (opt[2])
		1'b0: begin
			out_n = (ar_n3 + ar_n2) * ar_n1;
		end
		1'b1: begin
			out_n = (2 * ar_n1 * ar_n0) + ar_n3;
		end
	endcase
end


endmodule
