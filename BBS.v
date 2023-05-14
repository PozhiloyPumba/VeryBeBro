`timescale 10ns/1ns

module mod_multiplier
#(
	parameter SIZE=16,
	parameter MOD=40633
)
(
	input [SIZE-1:0] x,
	input reset,
	input clk,
	output [SIZE-1:0] out
);

reg [SIZE:0] tmp1;
assign out = tmp1[SIZE-1:0];

integer i;

always @(posedge clk)
begin
	if (reset) tmp1 = {SIZE {1'b0}};
	else begin
		tmp1 = {SIZE {1'b0}};
		for (i = SIZE-1; i >= 0; i = i - 1) begin
			tmp1 = tmp1 << 1'b1;
			if (tmp1 >= MOD) tmp1 = tmp1 - MOD;
			if (x[i]) tmp1 = tmp1 + x;
			if (tmp1 >= MOD) tmp1 = tmp1 -  MOD;
    		end
	end
end
endmodule


module main
(
	input clk,
	input reset,
	output [15:0] result
);
reg [15:0] seed;

always @(posedge clk) if (reset) seed = 16'd0;
initial begin
	#10 seed = 16'd200;
	#10 seed = 16'd40600;
	#10 seed = 16'd13089;
	#10 seed = 16'd884;
end

mod_multiplier mod_multiplier
(
	.x(seed),
	.clk(clk),
	.reset(reset),
	.out(result)
);

endmodule

module test();

reg clk;
reg reset;
wire [15:0] result;

initial
begin
	#1 clk = 1'b0;
	#1 reset = 1'b0;
end

always #1 clk = ~clk;
initial #3 reset = 1'b1;
initial #5 reset = 1'b0;

main main
(
	.reset(reset),
	.clk(clk),
	.result(result)
);

initial
begin
	#15 $display("%d", result);
	#10 $display("%d", result);
	#10 $display("%d", result);
	#10 $display("%d", result);
	#100 $finish;
end

endmodule

module hex2digit_hex
#(
	parameter INVERT = 1
)
(
	input	wire	[3:0]	hex,
	output	wire	[6:0]	digit
);

	wire [6:0] temp;
	assign temp =  ({7{hex == 4'h0}} & 7'b1000000 |
					{7{hex == 4'h1}} & 7'b1111001 |
					{7{hex == 4'h2}} & 7'b0100100 |
					{7{hex == 4'h3}} & 7'b0110000 |
					{7{hex == 4'h4}} & 7'b0011001 |
					{7{hex == 4'h5}} & 7'b0010010 |
					{7{hex == 4'h6}} & 7'b0000010 |
					{7{hex == 4'h7}} & 7'b1111000 |
					{7{hex == 4'h8}} & 7'b0000000 |
					{7{hex == 4'h9}} & 7'b0010000 |
					{7{hex == 4'hA}} & 7'b0001000 |
					{7{hex == 4'hB}} & 7'b0000011 | 
					{7{hex == 4'hC}} & 7'b1000110 |
					{7{hex == 4'hD}} & 7'b0100001 | 
					{7{hex == 4'hE}} & 7'b0000110 |
					{7{hex == 4'hF}} & 7'b0001110);

	assign digit = (INVERT) ? temp : ~temp;
endmodule

module button_handler_down
#(
	parameter INVERT = 1
)
(
	input	[0:0]	clock,
	input	[0:0]	button_signal,
	output	[0:0]	button_flag
);

reg [0:0] temp_1;
reg [0:0] temp_2;

always @(posedge clock)
begin
	temp_1 <= button_signal ^ INVERT;
	temp_2 <= temp_1; 
end

	assign button_flag = (~temp_2) & temp_1;
endmodule
