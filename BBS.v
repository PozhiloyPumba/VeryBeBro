`timescale 10ns/100ps

module mod_multiplier
#(
	parameter SIZE=16,
	parameter MOD=40633
)
(
	input [SIZE-1:0] x,
	input reset,
	output [SIZE-1:0] out
)

reg [SIZE-1:0] tmp1;
reg [SIZE-1:0] tmp2;

integer i;

for (i = 0; i < SIZE; i = i + 1)
begin
	if (reset)
	begin 
		{tmp1, tmp2} = {2 * SIZE {1'b0}};
	end
	else
	begin
		tmp1 = {SIZE{1'b0}};

	end
end
endmodule


module main
(
	input clk,
	input reset,
	output [15:0] result
)
reg [15:0] seed;
seed = 16'b11

mod_multiplier mod_multiplier
(
	.x(seed),
	.reset(reset),
	.out(result)
);

endmodule

module test

wire clk;
wire reset;
wire [15:0] result;

initial
begin
	#0 clk = 1'b0;
	#0 reset = 1'b0;
end

always #1 clk = ~clk;
initial #3 reset = 1'b1;
initial #5 reset = 1'b1;

main main
(
	.reset(reset),
	.clk(clk),
	.result(result)
);

$display("%d", result);

endmodule
