module scoreboard(input increment, input clk, input resetn, input islong,
		  output [6:0] HEX0, output [6:0] HEX1, output [6:0] HEX2);
   
   reg [7:0] score;
	wire [11:0] decscore;
   
   always @(posedge clk)
		begin
			if (!resetn)
				score <= 8'b0;
			else if (increment == 1'b1)
				begin
					if (islong == 1'b1)
						score <= score + 2'b11;
					else
						score <= score + 1'b1;
				end
		end
		
	BCD bcd(
			 .binary(score),
			 .Hundreds(decscore[11:8]),
			 .Tens(decscore[7:4]),
			 .Ones(decscore[3:0])
			 );

   hex_decoder H0(
		  .hex_digit(decscore[3:0]),
		  .segments(HEX0)
		  );

   hex_decoder H1(
		  .hex_digit(decscore[7:4]),
		  .segments(HEX1)
		  );
		  
	hex_decoder H2(
		  .hex_digit(decscore[11:8]),
		  .segments(HEX2)
		  );
   
endmodule // scoreboard

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

// taken from https://pubweb.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html
module BCD(
	input [7:0] binary,
	output reg [3:0] Hundreds,
	output reg [3:0] Tens,
	output reg [3:0] Ones
	);
	
	integer i;
	always @(binary)
		begin
			Hundreds = 4'd0;
			Tens = 4'd0;
			Ones = 4'd0;
			
			for (i = 7; i >= 0; i = i - 1)
				begin
					if (Hundreds >= 5)
						Hundreds = Hundreds + 3;
					if (Tens >= 5)
						Tens = Tens + 3;
					if (Ones >= 5)
						Ones = Ones + 3;
					
					Hundreds = Hundreds << 1;
					Hundreds[0] = Tens[3];
					Tens = Tens << 1;
					Tens[0] = Ones[3];
					Ones = Ones << 1;
					Ones[0] = binary[i];
				end
		end
endmodule
	