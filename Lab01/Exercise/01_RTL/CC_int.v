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

wire [1:0] max_idx, min_idx;
wire [3:0] temp_max[0:1], temp_min[0:1], mux_num_out_0[0:2], mux_num_out_1[0:1];
wire [1:0] temp_max_idx[0:1], temp_min_idx[0:1], mux_idx_out_0[0:2], mux_idx_out_1[0:1];


// Sorting module
max max_0(in_n0, in_n1, 2'b00, 2'b01, temp_max[0], temp_max_idx[0]);
max max_1(temp_max[0], in_n2, temp_max_idx[0], 2'b10, temp_max[1], temp_max_idx[1]);
max max_2(temp_max[1], in_n3, temp_max_idx[1], 2'b11, sort_n0, max_idx);

min min_0(in_n0, in_n1, 2'b00, 2'b01, temp_min[0], temp_min_idx[0]);
min min_1(temp_min[0], in_n2, temp_min_idx[0], 2'b10, temp_min[1], temp_min_idx[1]);
min min_2(temp_min[1], in_n3, temp_min_idx[1], 2'b11, sort_n3, min_idx);

mux_4_3 mux_4_3_0(
				{in_n0, in_n1, in_n2, in_n3}, 
				{2'b00, 2'b01, 2'b10, 2'b11},
				max_idx, 
				{mux_num_out_0[0], mux_num_out_0[1], mux_num_out_0[2]},
				{mux_idx_out_0[0], mux_idx_out_0[1], mux_idx_out_0[2]}
				); 

mux_3_2 mux_3_2_0(
				{mux_num_out_0[0], mux_num_out_0[1], mux_num_out_0[2]},
				{mux_idx_out_0[0], mux_idx_out_0[1], mux_idx_out_0[2]},
				min_idx, 
				{mux_num_out_1[0], mux_num_out_1[1]},
				{mux_idx_out_1[0], mux_idx_out_1[1]}
				);

compare compare_0(mux_num_out_1[0], mux_num_out_1[1], sort_n1, sort_n2);

endmodule



module mux_4_3 (
		num,
		idx,
		sel_idx,
		num_out,
		idx_out
	);

input wire [15:0] num;
input wire [7:0] idx;
input wire [1:0] sel_idx;

wire [3:0] temp_num [0:3];
wire [1:0] temp_idx [0:3];

output reg [11:0] num_out; // Packing 3 4-bit num into a 12-bit array, num[0:2]
output reg [5:0] idx_out; // Packing 3 2-bit idx into a 6-bit array, idx[0:2]

// Unpacking
assign {temp_num[0], temp_num[1], temp_num[2], temp_num[3]} = num;
assign {temp_idx[0], temp_idx[1], temp_idx[2], temp_idx[3]} = idx;

always @(*) begin
	if (sel_idx == temp_idx[0]) begin
		num_out <= {temp_num[1], temp_num[2], temp_num[3]};
		idx_out <= {temp_idx[1], temp_idx[2], temp_idx[3]};
	end else if (sel_idx == temp_idx[1]) begin
		num_out <= {temp_num[0], temp_num[2], temp_num[3]};
		idx_out <= {temp_idx[0], temp_idx[2], temp_idx[3]};
	end else if (sel_idx == temp_idx[2]) begin
		num_out <= {temp_num[0], temp_num[1], temp_num[3]};
		idx_out <= {temp_idx[0], temp_idx[1], temp_idx[3]};
	end else begin
		num_out <= {temp_num[0], temp_num[1], temp_num[2]};
		idx_out <= {temp_idx[0], temp_idx[1], temp_idx[2]};
	end	
end

endmodule

module mux_3_2 (
		num,
		idx,
		sel_idx,
		num_out,
		idx_out
	);

input wire [11:0] num;
input wire [5:0] idx;
input wire [1:0] sel_idx;

wire [3:0] temp_num [0:2];
wire [1:0] temp_idx [0:2];

output reg [7:0] num_out; // Packing 3 4-bit num into a 12-bit array, num[0:2]
output reg [3:0] idx_out; // Packing 3 2-bit idx into a 6-bit array, idx[0:2]

// Unpacking
assign {temp_num[0], temp_num[1], temp_num[2]} = num;
assign {temp_idx[0], temp_idx[1], temp_idx[2]} = idx;

always @(*) begin
	if (sel_idx == temp_idx[0]) begin
		num_out <= {temp_num[1], temp_num[2]};
		idx_out <= {temp_idx[1], temp_idx[2]};
	end else if (sel_idx == temp_idx[1]) begin
		num_out <= {temp_num[0], temp_num[2]};
		idx_out <= {temp_idx[0], temp_idx[2]};
	end else begin
		num_out <= {temp_num[0], temp_num[1]};
		idx_out <= {temp_idx[0], temp_idx[1]};
	end	
end


endmodule
	

module max (
	num_1,
	num_2,
	idx_1,
	idx_2,
	max_num,
	max_idx
	);

input signed [3:0] num_1, num_2;
input wire [1:0] idx_1, idx_2;
output reg signed [3:0] max_num;
output reg [1:0] max_idx;


always @(*) begin
	if (num_1 > num_2) begin
		max_num <= num_1;
		max_idx <= idx_1;
	end else begin
		max_num <= num_2;
		max_idx <= idx_2;	
	end
end

endmodule


module min (
	num_1,
	num_2,
	idx_1,
	idx_2,
	min_num,
	min_idx
	);

input signed [3:0] num_1, num_2;
input wire [1:0] idx_1, idx_2;
output reg signed [3:0] min_num;
output reg [1:0] min_idx;

always @(*) begin
	if (num_1 > num_2) begin
		min_num <= num_2;
		min_idx <= idx_2;
	end else begin
		min_num <= num_1;
		min_idx <= idx_1;	
	end
end


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

