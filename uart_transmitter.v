`timescale 1ns / 1ps

/*
** UART Transmitter
** Supports only 16x baud rate clock
** Supports only 8 data bits and only 1 stop bit
** Supports sending parity bit
** Supports sending break signal
**
** Audi McAvoy
** May 2019
*/

module uart_tx (

	input txclk,			// 16x baud rate clock
	input reset,			// active-high reset

	input we,				// active-high write enable
	input [8:0] din,		// 9-bit data in (optional parity bit + 8 bits data)
	input parity,			// active-high send parity bit

	input break,			// active-high send break signal
	output sout,			// serial data out
	output empty			// active-high shift register empty
);

	// 16x bit counter
	reg [7:0] counter = 8'd0;
	assign empty = (counter == 8'd0);
	always @(posedge txclk) begin
		if (reset) counter <= 8'd0;
		else if (we) counter <= parity ? 8'hAF : 8'h9F; // 11 or 10 bits * 16 clocks per bit (think zero-based)
		else if (!empty) counter <= counter - 1'd1;
	end

	// shift register
	reg [9:0] sout_buf = 10'h3ff;
	wire sout_shift = (counter[3:0] == 4'd0);
	always @(posedge txclk) begin
		if (reset) sout_buf <= 10'h3ff;
		else if (we) sout_buf <= parity ? {din, 1'b0} : {1'b1, din[7:0], 1'b0}; // LSB is start bit, bit-9 is stop bit if parity is not sent
		else if (sout_shift) sout_buf <= {1'b1, sout_buf[9:1]}; // right-shift
	end
	assign sout = break ? 1'b0 : sout_buf[0];

endmodule
