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
