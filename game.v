// KEY[0] press to reset
// KEY[1] press to start game
// SW[1:0] choose song 
// SW[3:2] choose speed 

module game	
	(
		CLOCK_50,						//	On Board 50 MHz
      KEY,
      SW,
		HEX0,
		HEX1,
		HEX2,
		
		// audio controls
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		AUD_DACDAT,
			  
		// keyboard controls
		PS2_CLK,
		PS2_DAT,
		  
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	
	input			   CLOCK_50;				//	50 MHz
	input   [9:0]  SW;
	input   [3:0]  KEY;
	input				AUD_ADCDAT;
	
	// keyboard controller
	inout          PS2_CLK;
	inout          PS2_DAT;
	
	// audio controls
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;
	
	output			AUD_DACDAT;
	
	// VGA controls
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	// Scoreboard displays
	output   [6:0] HEX0;
	output   [6:0] HEX1;
	output   [6:0] HEX2;
	
	wire resetn, go;
	assign resetn = KEY[0];
	assign go = ~KEY[1];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire draw, plot;
	

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn), // system active low reset
			.clock(CLOCK_50), // system clock
			.colour(colour), // set colour
			.x(x), // set x coordinate
			.y(y), // set y coordinate
			.plot(plot), // allow to draw
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
	wire rstscreen, lsong, lnote, shiftdown, logicin;
	wire songdone;
	wire column0press, column1press, column2press, column3press;
	wire pressednote, longnote;
	wire [3:0] note;
	wire isnote;
	wire [31:0] sound;
	wire resetscore;
	
	// if we want to test using the switches
	assign column0press = SW[7];
	assign column1press = SW[6];
	assign column2press = SW[5];
	assign column3press = SW[4];
		
	control c0(
				 .clock(CLOCK_50),
				 .resetn(resetn),
				 .go(go),
				 .draw(draw),
				 .reset_screen(rstscreen),
				 .load_song(lsong),
				 .load_note(lnote),
				 .speed(SW[3:2]),
				 .songdone(songdone),
				 .shift(shiftdown),
				 .logic_in(logicin),
				 .reset_score(resetscore)
				 );
				 
	datapath d0(
				  .clock(CLOCK_50),
				  .shift(shiftdown),
				  .resetn(resetn),
				  .draw(draw),
				  .reset_screen(rstscreen),
				  .load_song(lsong),
				  .choose_song(SW[1:0]),
				  .load_note(lnote),
				  .logicin(logicin),
				  .resetscore(resetscore),
				  .col0press(column0press),
				  .col1press(column1press),
				  .col2press(column2press),
				  .col3press(column3press),
				  .X(x), 
				  .Y(y),
				  .Col(colour),
				  .Plot(plot),
				  .SongDone(songdone),
				  .Note(note),
				  .IsNote(isnote),
				  .PressedNote(pressednote),
				  .LongNote(longnote)
				  );
	
	scoreboard sb(
					 .increment(pressednote), 
					 .clk(CLOCK_50), 
					 .resetn(resetn), 
					 .islong(longnote),
					 .HEX0(HEX0[6:0]), 
					 .HEX1(HEX1[6:0]),
					 .HEX2(HEX2[6:0])
					 );
					 
	sound_controller sc(
							 .clock(CLOCK_50),
							 .resetn(resetn),
							 .make_sound(isnote),
							 .note(note),
							 .sound_out(sound)
							 );
	
	audio_codec ac(// inputs
					  .clk(CLOCK_50),
					  .reset(~resetn),
					  .read(isnote),
					  .write(isnote), // not sure about this
					  .writedata_left(sound),
					  .writedata_right(sound),
					  .AUD_ADCDAT(AUD_ADCDAT),
						// Bidirectionals
					  .AUD_BCLK(AUD_BCLK),
					  .AUD_ADCLRCK(AUD_ADCLRCK),
					  .AUD_DACLRCK(AUD_DACLRCK),
						// Outputs
					  .read_ready(), // really not sure about these
					  .write_ready(),
					  .readdata_left(), 
					  .readdata_right(),
					  .AUD_DACDAT(AUD_DACDAT)
						);
	
	/*
	keyboard_controller kc(
								 .clock(CLOCK_50),
								 .reset(resetn),
								 .PS2_CLK(PS2_CLK),
								 .PS2_DAT(PS2_DAT),
								 .w(),
								 .a(column0press),
								 .s(column1press),
								 .d(column2press),
								 .f(column3press),
								 .left(),
								 .right(),
								 .up(),
								 .down(),
								 .space(),
								 .enter()
								 );						 
	*/
		
endmodule 



