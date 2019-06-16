# uart_transmitter
Verilog HDL UART Transmitter

This is a simple UART transmitter shift register with an "empty" output status bit. Writing to the register when it is not empty will immediately begin a new transmission, and probably create a bad character with a framing error at the receiver.

This transmitter requires a 16x baud rate transmit clock. It supports only 8 bits data and only 1 stop bit. It supports sending an optional parity bit, and can generate a break signal.

The data-in bus is 9 bits wide. The low 8 bits is the character to send, the MSB is the optional parity bit.

Parity is not calculated by this module. It is the responsibility of the higher level module to calculate the appropriate parity and include it with the data. If parity is not sent, then the MSB is unused (not loaded into the shift register). This means the higher level module can always calculate parity (to keep things simple) and simply assert the "parity" input when parity should be sent.

Asserting the "break" input will immediately drive "sout" low. It is the responsibility of the higher level module to assure break is held low long enough that the receiver detects the break condition.

If you happen to be simulating with Icarus Verilog on Windows, then you may find make.bat and testbench.gtkw useful.
