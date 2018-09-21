module CORE (
    in_n0,
    in_n1,
    opt,
    out_n
);
//--------------------------------------------------------------
//Input, Output Declaration
//--------------------------------------------------------------
input wire[2:0] in_n0, in_n1;
input wire[1:0] opt;
output reg signed[6:0] out_n;








endmodule 
//--------------------------------------------------------------
//Module Half Adder & Full Adder provided by TA
//--------------------------------------------------------------
module HA(
		a, 
		b, 
		sum, 
		c_out
);
  input wire a, b;
  output wire sum, c_out;
  xor (sum, a, b);
  and (c_out, a, b);
endmodule


module FA(
		a, 
		b, 
		c_in, 
		sum, 
		c_out
);
  input   a, b, c_in;
  output  sum, c_out;
  wire   w1, w2, w3;
  HA M1(.a(a), .b(b), .sum(w1), .c_out(w2));
  HA M2(.a(w1), .b(c_in), .sum(sum), .c_out(w3));
  or (c_out, w2, w3);
endmodule







