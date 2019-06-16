`timescale 1ns / 1ps

module testbench;

	reg txclk;			// 16x baud rate clock
	reg reset;			// active-high reset

	reg we;				// active-high write enable
	reg [8:0] din;		// 9-bit data in (optional parity bit + 8 bits data)
	reg parity;			// active-high include parity bit

	reg break; 			// active-high send break signal
	wire sout;			// serial data out
	wire empty;			// active-high shift register empty

	// Instantiate Unit Under Test (UUT)
	uart_tx uut (
		.txclk(txclk),		// 16x baud rate clock
		.reset(reset),		// active-high reset
		.we(we),			// active-high write enable
		.din(din),			// 9-bit data in (optional parity bit + 8 bits data)
		.parity(parity),	// active-high include parity bit
		.break(break), 		// active-high send break signal
		.sout(sout),		// serial data out
		.empty(empty)		// active-high shift register empty
	);

	// 16x 115.2k BAUD clock
	always begin
		#271.27 txclk = 0;
		#271.27 txclk = 1;
	end

	initial begin
		// create files for waveform viewer
		$dumpfile("testbench.lxt");
		$dumpvars;

		// initialize inputs
		txclk = 1;
		reset = 1;
		we = 0;
		din = 9'hx;
		parity = 0;
		break = 0;

		// release reset
		#250 reset = 0;

		// send a character with no parity
		send(0, 8'h64);
		wait(empty);

		// enable parity and send a character with odd number of 1's
		parity = 1;
		send(1, 8'h64);
		wait(empty);

		// send a char with even number of 1's
		send(0, 8'hA5);
		wait(empty);

		// send 20us break
		#250 break = 1;
		#20000 break = 0;

		// Finished
		#5000 $display("finished");
		$finish;
	end

	// send data
	task send;
		input parity_bit;
		input [7:0] char;
		begin
			wait(!txclk);
			wait(txclk); #1 din = {parity_bit, char};
			// write to transmitter
			wait(!txclk);
			wait(txclk); #1 we = 1;
			wait(!txclk);
			wait(txclk); #1 we = 0;
			// release bus
			wait(!txclk);
			wait(txclk); #1 din = 9'hx;
		end
	endtask

endmodule
