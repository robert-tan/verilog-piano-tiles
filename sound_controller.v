// adapted from github https://github.com/alexdrouillard/Piano/blob/master/DJ.v

module sound_controller(clock, resetn, note, make_sound, sound_out);
	input clock, resetn, make_sound;
	input [3:0] note;
	output [31:0] sound_out;
	
	reg [19:0] delay;

	localparam 				C_MIDDLE = 20'd95554, // C4 261.63Hz	DONT FORGET DIVIDE BY 2
								D_MIDDLE = 20'd85132, // D4 293.66Hz
								E_MIDDLE = 20'd75843, // E4 329.63Hz
								F_MIDDLE = 20'd71586, // F4 349.23Hz
								G_MIDDLE = 20'd63776, // G4 392.00Hz
								A_MIDDLE = 20'd56818, // A4 440Hz
								B_MIDDLE = 20'd50620, // B4 493.88Hz
								C_HIGH = 20'd47778, // C5 523.25Hz
								Eb_MIDDLE = 20'd80352, // Eb4 311.13Hz
								Bb_MIDDLE = 20'd53630, // Bb4 466.16Hz
								D_HIGH = 20'd42565, // D5 587.33Hz
								E_HIGH = 20'd37922, // E5 659.25Hz
								F_HIGH = 20'd35793, // F5 698.46Hz
								G_HIGH = 20'd31888, // G5 783.99Hz
								Eb_HIGH = 20'd40177, // Eb5 622.25Hz
								GS_MIDDLE = 20'd60197; // G#4 415.30Hz
								
	always @(*)
		begin
			case ( note )
				4'b0000: delay = C_MIDDLE;
				4'b0001: delay = D_MIDDLE;
				4'b0010: delay = E_MIDDLE;
				4'b0011: delay = F_MIDDLE;
				4'b0100: delay = G_MIDDLE;
				4'b0101: delay = A_MIDDLE;
				4'b0110: delay = B_MIDDLE;
				4'b0111: delay = C_HIGH;
				4'b1000: delay = Eb_MIDDLE;
				4'b1001: delay = Bb_MIDDLE;
				4'b1010: delay = D_HIGH;
				4'b1011: delay = E_HIGH;
				4'b1100: delay = F_HIGH;
				4'b1101: delay = G_HIGH;
				4'b1110: delay = Eb_HIGH;
				4'b1111: delay = GS_MIDDLE;
				default: delay = C_MIDDLE;
			endcase
		end

   oscillator oc( 
					  .clock(clock),
					  .resetn(resetn),
					  .makesound(make_sound),
					  .delay(delay),
					  .amplitude_out(sound_out)
					  );

endmodule


module oscillator (clock, resetn, makesound, delay, amplitude_out);
	input clock, resetn, makesound;
	input [19:0] delay;
	output [31:0] amplitude_out;

	wire flip;
	wire [31:0] amplitude;

	delay_flipper count (
		.clock(clock),
		.resetn(resetn),
		.delay(delay),
		.flip(flip)
	);
	
	assign amplitude = flip ? 32'd100000000 : -32'd100000000; //volume level
	assign amplitude_out = makesound ? amplitude : 32'b0;

endmodule


module delay_flipper(clock, resetn, delay, flip);
	input clock, resetn;
	input [19:0] delay;
	output reg flip;

	reg [19:0] count;

	always@(posedge clock) 
		begin
			if (resetn == 1'b0) 
				begin
					flip <= 1'd0;
					count <= 20'd0;
				end
			else if (count == delay) 
				begin //DELAY IS == TO 50MHz / DESIRED FREQUENCY
					flip <= !flip;
					count <= 20'd0;
				end
			else
				count <= count + 1;
		end

endmodule
