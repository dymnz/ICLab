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

always @(*) begin
	// Select sorting output
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

	// Select reduce mean
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

	// Select arithmatic op
	case (opt[2])
		1'b0: begin
			out_n <= (ar_n3 + ar_n2) * ar_n1;
		end
		1'b1: begin
			out_n <= (2 * ar_n1 * ar_n0) + ar_n3;
		end
	endcase	
end


endmodule


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

module Sort (
	in_n0, in_n1, in_n2, in_n3, 
	sort_n0, sort_n1, sort_n2, sort_n3	
);

input signed [3:0] in_n0, in_n1, in_n2, in_n3;
output signed [3:0] sort_n0, sort_n1, sort_n2, sort_n3;


wire signed [3:0] horz_0[0:1], vert_0[0:2], horz_1[0:0], vert_1[0:1];

compare comp_0_0(in_n0, in_n1, horz_0[0], vert_0[0]);
compare comp_0_1(horz_0[0], in_n2, horz_0[1], vert_0[1]);
compare comp_0_2(horz_0[1], in_n3, sort_n0, vert_0[2]);

compare comp_1_1(vert_0[0], vert_0[1], horz_1[0], vert_1[0]);
compare comp_1_2(horz_1[0], vert_0[2], sort_n1, vert_1[1]);

compare comp_2_2(vert_1[0], vert_1[1], sort_n2, sort_n3);

endmodule
	
module compare (
		num_1,
		num_2,
		max_num,
		min_num
	);

input wire signed [3:0] num_1, num_2;
output reg signed [3:0] max_num, min_num;


always @(*) begin
	if (num_1 > num_2) begin
		max_num <= num_1;
		min_num <= num_2;
	end else begin
		max_num <= num_2;
		min_num <= num_1;
	end
end
endmodule

