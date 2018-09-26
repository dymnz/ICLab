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
//   File Name   : IMC.v
//   Module Name : IMC
//   Release version : V1.0 (Release Date: 2018-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


// : s_HOLD
// 		Wait until IN_VALID in high
// 		
//	 /* Read num state */
// : s_RN_0 s_RN_1 s_RN_2 s_RN_3
// 		drop OUT_VALID	
//   	s_RN_3: goto s_CALC
//   	
// : s_CALC
//		Calculate determinent
//		IF det == 0
//			goto s_DET_INVALID
//	   ELSE 
//			calculate inv
//		   	goto s_ON_0
//		   	
// : s_DET_INVALID
// 		goto s_RN_0		
// 		
// 	 /* Output num state */		
// : s_ON_0	s_ON_1 s_ON_2 s_ON_3
// 		raise OUT_VALID
// 		s_ON_3: goto s_RN_0

module IMC(
    //Input Port
    clk,
    rst_n,
    IN_VALID,
    IN,

    //Output Port
    OUT_VALID,
    OUT
    );

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input           clk, rst_n, IN_VALID;
input [ 3:0]  IN;
output  reg OUT_VALID;
output  reg [13:0]  OUT;

//---------------------------------------------------------------------
//   PARAMETER DECLARATION
//---------------------------------------------------------------------

parameter 
	s_HOLD = 4'b1111,
	s_RN_0 = 4'b0000,
	s_RN_1 = 4'b0001,
	s_RN_2 = 4'b0010,
	s_RN_3 = 4'b0011,

	s_CALC = 4'b0100,
	s_DET_INVALID = 4'b0101,

	s_ON_0 = 4'b0110,
	s_ON_1 = 4'b0111,
	s_ON_2 = 4'b1000,
	s_ON_3 = 4'b1001;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------

reg [3:0] current_state, next_state;
reg [15:0] a, b, c, d; 
wire [31:0] det;
wire [31:0] e, f, g, h;

//---------------------------------------------------------------------
//   RTL CODE
//---------------------------------------------------------------------
assign det = (a*d - b*c);
assign e = d / det;
assign f = -b / det;
assign g = -c / det;
assign h = a / det;

/* State change */
always @(posedge clk) begin
	if(~rst_n) begin
		current_state <= s_RN_0;			
	end else begin
		current_state <= next_state;
	end
end


/* State Evaluate */
always @(current_state or rst_n or IN_VALID) begin
	if(~rst_n) begin
		next_state <= s_RN_0;
	end else begin
		case (current_state)
			s_RN_0:				
				if (IN_VALID) begin
					next_state <= s_RN_1;			
				end else begin
					next_state <= s_RN_0;
				end
			s_RN_1:
				next_state <= s_RN_2;
			s_RN_2:
				next_state <= s_RN_3;				
			s_RN_3:
				next_state <= s_CALC;

			s_CALC:				
				if (det == 0) begin
					next_state <= s_DET_INVALID;	
				end else begin
					next_state <= s_ON_0;
				end

			s_DET_INVALID:
				next_state <= s_RN_0;

			s_ON_0:
				next_state <= s_ON_1;
			s_ON_1:
				next_state <= s_ON_2;
			s_ON_2:
				next_state <= s_ON_3;	
			s_ON_3:
				next_state <= s_RN_0;	

			default : /* default */;
		endcase
	end
end

/* Output */
always @(posedge clk) begin
	OUT_VALID <= 1'b0;
	OUT <= 14'b0;
	case (current_state)
		s_RN_0:			
			a <= {2'b0, IN, 10'b0};
		s_RN_1:
			b <= {2'b0, IN, 10'b0};
		s_RN_2:
			c <= {2'b0, IN, 10'b0};			
		s_RN_3:
			d <= {2'b0, IN, 10'b0};

		s_CALC: begin				
		end
		s_DET_INVALID: begin
		end

		s_ON_0: begin
			OUT_VALID <= 1'b1;
			OUT <= e[13:0];
		end
		s_ON_1: begin
			OUT_VALID <= 1'b1;
			OUT <= f[13:0];				
		end				
		s_ON_2: begin
			OUT_VALID <= 1'b1;				
			OUT <= g[13:0];
		end				
		s_ON_3: begin
			OUT_VALID <= 1'b1;	
			OUT <= h[13:0];
		end
		default: begin /* default */
			OUT_VALID <= 1'b0;
			OUT <= 0;
		end
	endcase
end

endmodule
