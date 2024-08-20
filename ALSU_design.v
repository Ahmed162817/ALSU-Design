module ALSU (A,B,opcode,cin,serial_in,direction,red_op_A,red_op_B,bypass_A,bypass_B,clk,rst,out,leds);

// parameter Declaration
parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER = "ON";

// input & output Declaration
input [2:0] A,B,opcode;
input cin,serial_in,direction,red_op_A,red_op_B,bypass_A,bypass_B,clk,rst;
output reg [5:0] out;
output reg [15:0] leds;

// internal signals
reg [2:0] A_ff,B_ff,opcode_ff;
reg cin_ff,serial_in_ff,direction_ff,red_op_A_ff,red_op_B_ff,bypass_A_ff,bypass_B_ff;
reg [5:0] out_ff;
reg error;          // This error signal activated when the invalid cases occur

// always block for sampling all inputs at positive edge of clock
always @(posedge clk or posedge rst) begin
	if(rst) begin
		A_ff <= 0;         B_ff <= 0;            opcode_ff <= 0;
		cin_ff <= 0;       serial_in_ff <= 0;    direction_ff <= 0;
		red_op_A_ff <= 0;  red_op_B_ff <= 0;     bypass_A_ff <= 0;   bypass_B_ff <= 0;
	end
	else begin
		A_ff <= A;     B_ff <= B;    opcode_ff <= opcode;        cin_ff <= cin; 
		serial_in_ff <= serial_in;   direction_ff <= direction;  red_op_A_ff <= red_op_A; 
		red_op_B_ff <= red_op_B;     bypass_A_ff <= bypass_A;    bypass_B_ff <= bypass_B;
	end
end

// always block related to output port (out)
always @ (*) begin
	if(bypass_A_ff == 1 && bypass_B_ff == 0)
		out_ff = A_ff;
	else if(bypass_A_ff == 0 && bypass_B_ff == 1)
		out_ff = B_ff;
	else if(bypass_A_ff == 1 && bypass_B_ff == 1) begin
			case(INPUT_PRIORITY)
				"A" : out_ff = A_ff;
				"B" : out_ff = B_ff;
			endcase
		end
	else begin
		case(opcode_ff)
			3'b000 : begin
				case({red_op_A_ff,red_op_B_ff})
					2'b00 : out_ff = A_ff & B_ff;
					2'b01 : out_ff = & B_ff;
					2'b10 : out_ff = & A_ff;
					2'b11 : begin
						case(INPUT_PRIORITY)
							"A" : out_ff = & A_ff;
							"B" : out_ff = & B_ff;
						endcase
					end
				endcase
			end

			3'b001 : begin
				case({red_op_A_ff,red_op_B_ff})
					2'b00 : out_ff = A_ff ^ B_ff;
					2'b01 : out_ff = ^ B_ff;
					2'b10 : out_ff = ^ A_ff;
					2'b11 : begin
						case(INPUT_PRIORITY)
							"A" : out_ff = ^ A_ff;
							"B" : out_ff = ^ B_ff;
						endcase
					end
				endcase
			end

			3'b010 : begin
					case (FULL_ADDER)
						"ON"  : out_ff = A_ff + B_ff + cin_ff;
						"OFF" : out_ff = A_ff + B_ff;
					endcase
			end

			3'b011 : out_ff = A_ff * B_ff;

			3'b100 : begin
				case(direction_ff)
					1'b0 : out_ff = {serial_in_ff , out_ff[5:1]};           // shift right operation
					1'b1 : out_ff = {out_ff[4:0] , serial_in_ff};           // shift left operation
				endcase                
			end

			3'b101 : begin
				case(direction_ff)
					1'b0 : out_ff = {out_ff[0] , out_ff[5:1]};           // rotate right operation
					1'b1 : out_ff = {out_ff[4:0] , out_ff[5]};           // rotate left operation
				endcase                
			end

			default : out_ff = 0;

		endcase
	end
end

// always block to detect invalid cases
always @ (*) begin
	case({bypass_A_ff,bypass_B_ff})
		2'b10 , 2'b01 , 2'b11 : error = 0;
		2'b00 : begin
			case(opcode_ff)
				3'b000 , 3'b001 : error = 0;
				3'b010 , 3'b011 , 3'b100 , 3'b101 : begin
					if(red_op_A_ff == 1 || red_op_B_ff == 1)
						error = 1;
					else 
						error = 0;
				end
				3'b110 , 3'b111 : error = 1;
			endcase
		end
	endcase
end

// always block for assigning the output leds
always @(posedge clk or posedge rst) begin
	if(rst)
		leds <= 0;
	else if(error) 
		leds <= ~leds;
	else 
		leds <= 0;
end

// always block for assigning the output signal (out)
always @(posedge clk or posedge rst) begin
	if(rst)
		out <= 0;
	else if(error) 
		out <= 0;
	else 
		out <= out_ff;
end

endmodule