`timescale 1ns/1ns

module main(
	input clk, 
	input reset, 
	input btn_show,
	input btn_gen,
	output [7:0]  leds,
	output [13:0] digs
);

wire btn_flg_show;
wire btn_flg_gen;
wire [255:0] number;

button_handler_down btn_handler_down_show (
	.clock(clk),
	.button_signal(btn_show),
	.button_flag(btn_flg_show)
);
button_handler_down btn_handler_down_gen (
	.clock(clk),
	.button_signal(btn_gen),
	.button_flag(btn_flg_gen)
);
number_counter number_counter(
	.clk(clk),
	.reset(reset),
	.btn_flg(btn_flg_gen),
	.result(number)
);
show_number show_number (
	.clk(clk),
	.reset(reset),
	.number(number),
	.btn_flg_show(btn_flg_show),
	.leds(leds),
	.digs(digs)
);

endmodule
//==============================================================
module show_number (
	input clk, 
	input reset, 
	input [255:0] number,
	input btn_flg_show,
	output [7:0] leds,
	output [13:0] digs
);
reg [5:0]  state;
reg [7:0]  leds_cp;

assign leds = leds_cp[7:0];

always @(posedge clk) begin
	if (reset) begin
		state <= 6'b0;
		leds_cp <= 8'b0;
	end
	else if (btn_flg_show) begin
		if (state == 6'd32) state <= 6'b0;
		state <= state + 1'b1;
	end
end

genvar Gi;
generate 	
	for(Gi = 0; Gi < 32; Gi = Gi + 1) begin: gen_show_i
		always @(posedge btn_flg_show) begin
			if (Gi == state) begin
				leds_cp <= number[Gi*8+7:Gi*8];
			end
		end
	end
endgenerate

hex2digit_hex hex2digit_hex_l(
	.hex({3'b0, state[4:4]}),
	.digit(digs[13:7])
);
hex2digit_hex hex2digit_hex_r(
	.hex(state[3:0]),
	.digit(digs[6:0])
);

endmodule
//==============================================================
module mod_multiplier
#(
	parameter SIZE=16,
	parameter MOD=40633
)
(
	input [SIZE-1:0] x,
	input clk,
	output [SIZE-1:0] out
);

reg [SIZE:0] tmp;
assign out = tmp[SIZE-1:0];

integer i;

always @(posedge clk)
begin
	tmp = {SIZE {1'b0}};
	for (i = SIZE-1; i >= 0; i = i - 1) begin
		tmp = tmp << 1'b1;
		if (tmp >= MOD) tmp = tmp - MOD;
		if (x[i]) tmp = tmp	+ x;
		if (tmp >= MOD) tmp = tmp -  MOD;
	end
end
endmodule
//==============================================================
module number_counter
#(
	parameter SIZE=256
)
(
	input clk,
	input reset,
	input btn_flg,
	output [SIZE-1:0] result
);
reg [15:0] seed;
reg [SIZE-1:0] number;
reg [9:0] bcounter;
wire [15:0] temporary;
reg [0:0] flg;

integer j;

assign result = number;

always @(posedge clk) begin
	if (reset) begin
		bcounter = {9 {1'b0}};
		seed     = 16'd884;
		number   = {SIZE {1'b0}};
	end else begin
		if (btn_flg) flg <= 1'b1;
		seed <= temporary;
		if (flg) begin
			if (bcounter != SIZE<<1) begin
				bcounter <= bcounter + 1'b1;
				if (bcounter[0] == 1'b1)
					number <= (number << 1) | (seed[0]);
			end else begin
				bcounter <= 9'b0;
				flg <= 1'b0;
			end
		end
	end
end

mod_multiplier mod_multiplier (
	.x(seed),
	.clk(clk),	
	.out(temporary)
);

endmodule
//==============================================================
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
//==============================================================
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
//==============================================================
module test();

reg  clk;
reg  reset;
reg  btn_gen;
reg  btn_show;
reg  [7:0] led;
reg  [15:0] dig;

initial
begin
	#1 clk = 1'b0;
	#1 reset = 1'b0;
end

always #1 clk = ~clk;
initial #3 reset = 1'b1;
initial #4 reset = 1'b0;
initial #100 btn_gen = 1'b1;
initial #150 btn_gen = 1'b0;

initial #1500 btn_gen = 1'b1;
initial #1550 btn_gen = 1'b0;

initial begin 
	#1250 btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
	#50  btn_show = 1'b1;
	#50  btn_show = 1'b0;
end

main main
(
	.reset(reset),
	.clk(clk), 
	.btn_show(btn_show),
	.btn_gen(btn_gen),
	.leds(),
	.digs()
);

//initial #1500 $finish;

endmodule
