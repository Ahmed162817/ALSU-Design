module ALSU_tb ();

parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER = "ON";

reg clk, rst, cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, direction;
reg [2:0] A, B, opcode;

wire [15:0] leds;
wire [5:0] out;
reg MSB, LSB; // To Store the LSB or MSB of the previous output to test it in the Rotation Operations

ALSU #(.INPUT_PRIORITY(INPUT_PRIORITY),.FULL_ADDER(FULL_ADDER)) DUT (.clk(clk),.rst(rst),.A(A),.B(B),.cin(cin),.serial_in(serial_in),.red_op_A(red_op_A),.red_op_B(red_op_B),.opcode(opcode),.bypass_A(bypass_A),.bypass_B(bypass_B),.direction(direction),.leds(leds),.out(out));

initial begin
    clk = 0;
    forever begin
        #10 clk = ~clk;
    end
end

initial begin
    rst = 1;                // Test Reset operation
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        red_op_A = $random;
        red_op_B =  $random;
        bypass_A = $random;
        bypass_B = $random;
        direction = $random;
        A = $random;
        B = $random;
        opcode = $random;
        @(negedge clk);
        if((leds != 0) || (out != 0)) begin
            $display("Error in rst operation");
            $stop;
        end
    end
    rst = 0; 
    bypass_A = 1; bypass_B = 1;        // Test Bypass operations
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        red_op_A = $random;
        red_op_B =  $random;
        direction = $random;
        A = $random;
        B = $random;
        opcode = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) && (out != A) ) begin
            $display("Error when both bypass_A & bypass_B are High");
            $stop;
        end
    end
    bypass_A = 1; bypass_B = 0;
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        red_op_A = $random;
        red_op_B =  $random;
        direction = $random;
        A = $random;
        B = $random;
        opcode = $random;
        repeat(2) @(negedge clk);
        if((leds != 0) && (out != A)) begin
            $display("Error when bypass_A is High");
            $stop;
        end
    end
    bypass_A = 0; bypass_B = 1;
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        red_op_A = $random;
        red_op_B =  $random;
        direction = $random;
        A = $random;
        B = $random;
        opcode = $random;
        repeat(2) @(negedge clk);
        if((leds != 0) && (out != B)) begin
            $display("Error when bypass_B is High");
            $stop;
        end
    end
    bypass_A = 0; bypass_B = 0;   opcode = 0;         // AND Operations
    red_op_A = 1; red_op_B = 1; 
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) || (out != (&A) ) ) begin
            $display("Error when both red_op_A & red_op_B are High in AND operation");
            $stop;
        end
    end
    red_op_A = 1; red_op_B = 0;
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) || (out != (&A) ) ) begin
            $display("Error when red_op_A is High in AND operation");
            $stop;
        end
    end
    red_op_A = 0; red_op_B = 1;
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) || (out != (&B) ) ) begin
            $display("Error when red_op_B is High in AND operation");
            $stop;
        end
    end
    red_op_A = 0; red_op_B = 0;
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) || (out != (A&B) ) ) begin
            $display("Error when both red_op_A & red_op_B are low (bitwise AND operation) ");
            $stop;
        end
    end
    opcode = 1;              // XOR operations
    red_op_A = 1; red_op_B = 1;     
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) || (out != (^A) ) ) begin
            $display("Error when red_op_A & red_op_B both are High in XOR operation");
            $stop;
        end
    end
    red_op_A = 1; red_op_B = 0;
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) || (out != (^A) ) ) begin
            $display("Error when red_op_A is High in XOR operation");
            $stop;
        end
    end
    red_op_A = 0; red_op_B = 1;
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) || (out != (^B) ) ) begin
            $display("Error when red_op_B is High in XOR operation");
            $stop;
        end
    end
    red_op_A = 0; red_op_B = 0;
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) || (out != (A^B) ) ) begin
            $display("Error when both red_op_A & red_op_B are low (bitwise XOR operation)");
            $stop;
        end
    end
    opcode = 2;                 // Addition operation 
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if(FULL_ADDER == "ON") begin
        	if( (leds != 0) && (out != (A+B+cin) ) ) begin
            	$display("Error in Addition operation (Full Adder) ");
            	$stop;
        	end
        end
        else begin
        	if( (leds != 0) && (out != (A+B) ) ) begin
            	$display("Error in Addition operation (Half Adder)");
            	$stop;
        	end
        end
    end
    opcode = 3;                // Multiplication operation 
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        direction = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) && (out != (A*B) ) ) begin
            $display("Error in Multiplication Operation");
            $stop;
        end
    end
    opcode = 4;   direction = 1;             // Shift left operation          
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) && (out[0] != serial_in) ) begin
            $display("Error in Shift Left Operation");
            $stop;
        end
    end
    direction = 0;            // Shift Right operation
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        A = $random;
        B = $random;
        repeat(2) @(negedge clk);
        if( (leds != 0) && (out[5] != serial_in) ) begin
            $display("Error in Shift Right Operation");
            $stop;
        end
    end
    opcode = 5;      direction = 1;       // Rotate left operation          
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        A = $random;
        B = $random;
        @(negedge clk);
        MSB = out[5];
        @(negedge clk);
        if( (leds != 0) && (out[0] != MSB) ) begin
            $display("Error in Rotate Left Operation");
            $stop;
        end
    end
    direction = 0;            // Rotate Right operation
    repeat(5) begin
        cin = $random;
        serial_in = $random;
        A = $random;
        B = $random;
        @(negedge clk);
        LSB = out[0];
        @(negedge clk);
        if( (leds != 0) && (out[5] != LSB) ) begin
            $display("Error in Rotate Right Operation");
            $stop;
        end
    end
    repeat(20) begin
        cin = $random;
        serial_in = $random;
        red_op_A = $random;
        red_op_B =  $random;
        direction = $random;
        A = $random;
        B = $random;
        opcode = $random;
        repeat(2) @(negedge clk);
        if( (opcode == 6 || opcode == 7) && (out != 0) ) begin
        	$display("During invalid cases, output is incorrect !!");
        	$stop;
        end
        if( (opcode == 2 || opcode == 3 || opcode == 4 || opcode == 5) && (red_op_A == 1 || red_op_B == 1) && (out != 0) ) begin
        	$display("During invalid cases, output is incorrect !!");
        	$stop;
        end
    end
    $display("Correct ALSU design");
    $stop;
end

endmodule