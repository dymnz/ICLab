module CC(
	in_n0,
	in_n1, 
	in_n2, 
	in_n3, 
	opt,
	out_n
);

input wire [3:0] in_n0, in_n1, in_n2, in_n3;
input wire [2:0] opt;
output wire [8:0] out_n;

reg [3:0] n0, n1, n2, n3;
wire [3:0] sort_n0, sort_n1, sort_n2, sort_n3; // n0>>>n3
wire [1:0] max_idx, min_idx;

wire [3:0] temp_max[0:1], temp_min[0:1], mux_num_out_0[0:2], mux_num_out_1[0:1];
wire [1:0] temp_max_idx[0:1], temp_min_idx[0:1], mux_idx_out_0[0:2], mux_idx_out_1[0:1];

always @(*) begin
	case (opt[0])
		1'b0: begin
			{n0, n1, n2, n3} = {in_n0, in_n1, in_n2, in_n3};
		end
		1'b1: begin
			{n0, n1, n2, n3} = {sort_n0, sort_n1, sort_n2, sort_n3};			
		end
	endcase
	case (opt[1])
		1'b0: begin
			
		end
		1'b1: begin
			
		end
	endcase
end

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
		num_out = {temp_num[1], temp_num[2], temp_num[3]};
		idx_out = {temp_idx[1], temp_idx[2], temp_idx[3]};
	end else if (sel_idx == temp_idx[1]) begin
		num_out = {temp_num[0], temp_num[2], temp_num[3]};
		idx_out = {temp_idx[0], temp_idx[2], temp_idx[3]};
	end else if (sel_idx == temp_idx[2]) begin
		num_out = {temp_num[0], temp_num[1], temp_num[3]};
		idx_out = {temp_idx[0], temp_idx[1], temp_idx[3]};
	end else begin
		num_out = {temp_num[0], temp_num[1], temp_num[2]};
		idx_out = {temp_idx[0], temp_idx[1], temp_idx[2]};
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
		num_out = {temp_num[1], temp_num[2]};
		idx_out = {temp_idx[1], temp_idx[2]};
	end else if (sel_idx == temp_idx[1]) begin
		num_out = {temp_num[0], temp_num[2]};
		idx_out = {temp_idx[0], temp_idx[2]};
	end else begin
		num_out = {temp_num[0], temp_num[1]};
		idx_out = {temp_idx[0], temp_idx[1]};
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

input wire [3:0] num_1, num_2;
input wire [1:0] idx_1, idx_2;
output reg [3:0] max_num;
output reg [1:0] max_idx;


always @(*) begin
	if (num_1 > num_2) begin
		max_num = num_1;
		max_idx = idx_1;
	end else begin
		max_num = num_2;
		max_idx = idx_2;	
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

input wire [3:0] num_1, num_2;
input wire [1:0] idx_1, idx_2;
output reg [3:0] min_num;
output reg [1:0] min_idx;

always @(*) begin
	if (num_1 > num_2) begin
		min_num = num_2;
		min_idx = idx_2;
	end else begin
		min_num = num_1;
		min_idx = idx_1;	
	end
end


endmodule

module compare (
		num_1,
		num_2,
		max_num,
		min_num
	);

input wire [3:0] num_1, num_2;
output reg [3:0] max_num, min_num;


always @(*) begin
	if (num_1 > num_2) begin
		max_num = num_1;
		min_num = num_2;
	end else begin
		max_num = num_2;
		min_num = num_1;
	end
end
endmodule