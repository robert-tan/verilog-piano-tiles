// main datapath module
module datapath(clock, shift, resetn, reset_screen, draw, resetscore, load_song, choose_song, load_note, logicin, col0press, col1press, col2press, col3press, X, Y, Col, Plot, SongDone, Note, IsNote, PressedNote, LongNote);
	input clock, resetn, draw, shift, load_song, reset_screen, load_note, logicin, resetscore;
	input col0press, col1press, col2press, col3press;
	input [1:0] choose_song;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg [2:0] Col;
	
	output reg Plot;
	output SongDone;
	output PressedNote, LongNote;
	output reg [3:0] Note;
	output IsNote;
	
	wire [7:0] noteaddress;
	wire [19:0] noteinfo;
	wire nextnote;
	
	wire [2:0] newcolour;
	wire [3:0] newnote;
	wire newpos;
	wire [1:0] loadcolumn;
	
	reg load1, load2, load3, load0;
	
	wire [6:0] xpos;
	wire [6:0] yvalue;
	wire [1:0] currcolumn;
	reg access; 
	wire incrementcolumn;
	reg [6:0] xstart;
	wire [6:0] column0x, column1x, column2x, column3x;
	wire [2:0] colour0, colour1, colour2, colour3;
	reg [2:0] currcolour;
	wire [3:0] note0, note1, note2, note3;
	
	wire [2:0] clearcolour;
	wire [7:0] clearx;
	wire [6:0] cleary;
	
	wire resetplot;
	wire islong;
	
	reg count;
	wire finishedcolumn, finisheddraw;
	
	wire presscol0, presscol1, presscol2, presscol3;
	wire col0isnote, col1isnote, col2isnote, col3isnote;
	wire col0succpress, col1succpress, col2succpress, col3succpress;
	wire col0longpress, col1longpress, col2longpress, col3longpress;
	wire [3:0] choosenote;
	
	// store current note until it's done
	noteregister noter(
							.noteinfo(noteinfo),
							.load(nextnote),
							.resetn(resetn),
							.shift(shift),
							.clock(clock),
							.Colour(newcolour),
							.Note(newnote),
							.Position(newpos),
							.Column(loadcolumn),
							.Next(nextnote),
							.IsLong(islong),
							.SongDone(SongDone)
							);
	
	// store current note's address
	noteaddressreg nar(
							.clock(clock),
							.resetn(resetn),
							.next(nextnote),
							.address(noteaddress)
							);
	
	
	// output song info
	managesongs msongs(
							.song(choose_song), 
							.load(load_song),
							.resetn(resetn),
							.clock(clock),
							.address(noteaddress),
							.noteinfo(noteinfo)
							);
	
	// reset draw
	draw_black resetd(.resetn(resetn), 
						   .enable(reset_screen), 
						   .clk(clock), 
						   .plot(resetplot), 
						   .col(clearcolour), 
						   .x(clearx), 
						   .y(cleary)
							);
							
	
	// choose which column to load new note into
	always @(*)
		begin
			case ( loadcolumn )
				2'b00:
					begin
						load0 = 1'b1;
						load1 = 1'b0;
						load2 = 1'b0;
						load3 = 1'b0;
					end
				2'b01:
					begin
						load0 = 1'b0;
						load1 = 1'b1;
						load2 = 1'b0;
						load3 = 1'b0;
					end
				2'b10:
					begin
						load0 = 1'b0;
						load1 = 1'b0;
						load2 = 1'b1;
						load3 = 1'b0;
					end
				2'b11:
					begin
						load0 = 1'b0;
						load1 = 1'b0;
						load2 = 1'b0;
						load3 = 1'b1;
					end
				default: 
					begin
						load0 = 1'b0;
						load1 = 1'b0;
						load2 = 1'b0;
						load3 = 1'b0;
					end
			endcase
		end
	
	// column press logic
	assign presscol0 = logicin && col0press;
	assign presscol1 = logicin && col1press;
	assign presscol2 = logicin && col2press;
	assign presscol3 = logicin && col3press;

	// columns of game
	column c1(
				.shift(shift),
				.load(load0),
				.colour(newcolour),
				.column(2'b00),
				.note(newnote),
				.pos(newpos),
				.long(islong),
				.clock(clock),
				.resetn(resetn),
				.access(draw),
				.y(yvalue),
				.press(presscol0),
				.pressphase(logicin),
				.resetscore(resetscore),
				.X(column0x),
				.Colour(colour0),
				.Note(note0),
				.IsNote(col0isnote),
				.SuccPress(col0succpress),
				.LongPress(col0longpress)
				);
				
	column c2(
				.shift(shift),
				.load(load1),
				.colour(newcolour),
				.column(2'b01),
				.note(newnote),
				.pos(newpos),
				.long(islong),
				.clock(clock),
				.resetn(resetn),
				.access(draw),
				.y(yvalue),
				.press(presscol1),
				.pressphase(logicin),
				.resetscore(resetscore),
				.X(column1x),
				.Colour(colour1),
				.Note(note1),
				.IsNote(col1isnote),
				.SuccPress(col1succpress),
				.LongPress(col1longpress)
				);
				
	column c3(
				.shift(shift),
				.load(load2),
				.colour(newcolour),
				.column(2'b10),
				.note(newnote),
				.pos(newpos),
				.long(islong),
				.clock(clock),
				.resetn(resetn),
				.access(draw),
				.y(yvalue),
				.press(presscol2),
				.pressphase(logicin),
				.resetscore(resetscore),
				.X(column2x),
				.Colour(colour2),
				.Note(note2),
				.IsNote(col2isnote),
				.SuccPress(col2succpress),
				.LongPress(col2longpress)
				);
				
	column c4(
				.shift(shift),
				.load(load3),
				.colour(newcolour),
				.column(2'b11),
				.note(newnote),
				.pos(newpos),
				.long(islong),
				.clock(clock),
				.resetn(resetn),
				.access(draw),
				.y(yvalue),
				.press(presscol3),
				.pressphase(logicin),
				.resetscore(resetscore),
				.X(column3x),
				.Colour(colour3),
				.Note(note3),
				.IsNote(col3isnote),
				.SuccPress(col3succpress),
				.LongPress(col3longpress)
				);
				
	// output note
	assign IsNote = col0isnote | col1isnote | col2isnote | col3isnote;
	assign choosenote = {col3isnote, col2isnote, col1isnote, col0isnote};
	
	always @(*)
		begin
			case ( choosenote )
				4'b0001: Note = note0;
				4'b0010: Note = note1;
				4'b0100: Note = note2;
				4'b1000: Note = note3;
				default: Note = 0;
			endcase
		end
	
				
	// scoreboard logic
	assign PressedNote = col0succpress | col1succpress | col2succpress | col3succpress;
	assign LongNote = col0longpress | col1longpress | col2longpress | col3longpress;
						  
	row_counter rc(
					  .enable(count),
					  .clock(clock),
					  .resetn(resetn),
					  .q(xpos)
					  );
					  
					  
	assign incrementcolumn = (xpos == 3'b111) ? 1 : 0;
					  
	column_counter cc(
						  .enable(incrementcolumn),
						  .clock(clock),
						  .resetn(resetn),
						  .q(yvalue)
						  );
						  
	assign finishedcolumn = (xpos == 0 && yvalue == 0) ? 1 : 0;
						  
	current_column currc(
							  .enable(finishedcolumn),
							  .clock(clock),
							  .resetn(resetn),
							  .q(currcolumn)
							  );
							  
	assign finisheddraw = (currcolumn == 2'b11 && xpos == 3'b111 && yvalue == 7'b1110011) ? 1 : 0;
	
	always @(*)
		begin
			case ( currcolumn )
				2'b00:   xstart = column0x;
				2'b01:   xstart = column1x;
				2'b10:   xstart = column2x;
				2'b11:   xstart = column3x;         
				default: xstart = 0;       
			endcase
		end
		
	always @(*)
		begin
			case ( currcolumn )
				2'b00:   currcolour = colour0;
				2'b01:   currcolour = colour1;
				2'b10:   currcolour = colour2;
				2'b11:   currcolour = colour3;         
				default: currcolour = 3'b000;       
			endcase
		end
	
				
	// draw logic
	always @(posedge clock)
		begin
			if (resetn == 1'b0)
				begin
					Plot <= 1'b0;

				end				
			else if (draw == 1'b1)
				begin
					count <= 1'b1;
					access <= 1'b1;
					X <= {1'b0, xstart + xpos};
					if (xpos == 3'b000)
						begin
							Y <= yvalue - 1;
							if (yvalue == 7'b1100101) // white line
								Col <= 3'b111;
							else if (yvalue == 7'b1110100) // very bottom
								Col <= 3'b000;
							else
								Col <= currcolour;
						end
					else
						begin
							Y <= yvalue;
							if (yvalue == 7'b1100100) // white line
								Col <= 3'b111;
							else if (yvalue == 7'b1110011) // very bottom
								Col <= 3'b000;
							else
								Col <= currcolour;
						end
					Plot <= 1'b1;
					
				end
			else if (reset_screen == 1'b1)
				begin 
					Plot <= resetplot;
					X <= clearx;
					Y <= cleary;
					Col <= clearcolour;
				end
		end

endmodule


module noteregister(noteinfo, load, resetn, shift, clock, Colour, Note, Position, Column, Next, IsLong, SongDone);
	input [19:0] noteinfo;
	input load, resetn, shift, clock;
	output reg [2:0] Colour;
	output reg [3:0] Note;
	output reg Position;
	output reg [1:0] Column;
	output reg Next, IsLong;
	output reg SongDone;
	reg [4:0] notelen, notesoutputted;
	reg [6:0] waittime, untilnext;
	
	always @(posedge clock)
		begin
			if (resetn == 0)
				begin
					Colour <= 3'b000;
					Note <= 4'b0000;
					Position <= 1'b0;
					Column <= 2'b00;
					Next <= 1'b0;
					IsLong <= 1'b0;
					SongDone <= 1'b0;
					notesoutputted <= 4'b0000;
					untilnext <= 7'b0000000;
					notelen <= 4'b0000;
					waittime <= 7'b00000000;
				end
			else if (load == 1'b1)
				begin
					Column <= noteinfo[19:18];
					Colour <= noteinfo[17:15];
					Note <= noteinfo[14:11];
					notelen <= noteinfo[10:7];
					waittime <= noteinfo[6:0];
					notesoutputted <= 4'b0000;
					untilnext <= 7'b0000000;
					Position <= 1'b1;
					Next <= 1'b0;
					if (noteinfo[10:7] == 4'b1100)
						IsLong <= 1'b1;
					else
						IsLong <= 1'b0;
				end
			else if (shift == 1'b1)
				begin
					if (untilnext == waittime)
						begin
							if (waittime == 7'b1110111)
								SongDone <= 1'b1;
							Next <= 1'b1;
							IsLong <= 1'b0;
						end
					if (notesoutputted == notelen)
						begin
							Colour <= 3'b000;
							Position <= 1'b0;
							Note <= 4'b0000;
							Column <= 2'b00;
							// IsLong <= 1'b0;
						end
					notesoutputted <= notesoutputted + 1;
					untilnext <= untilnext + 1;
				end
		end

endmodule


// manage the current note address
module noteaddressreg(clock, resetn, next, address);
	input next, clock, resetn;
	output reg [7:0] address;
	
	always @(posedge clock) 
		begin
			if (resetn == 1'b0) 
				address <= 8'b00000000;
			else if (next == 1'b1)
				address <= address + 1'b1;
		end

endmodule


// manage the current note output for the song
module managesongs(song, load, clock, resetn, address, noteinfo);
	input [1:0] song;
	input load, clock, resetn;
	input [7:0] address;
	output reg [19:0] noteinfo;
	reg [1:0] currsong;
	
	wire [19:0] mhall, furelise, unravel;
	
	
	always @(posedge clock) 
		begin
			if (resetn == 0)
				currsong <= 2'b00;
			else if (load == 1'b1)
				currsong <= song;
		end
		
	mhallsong mhallnote(
							 .address(address),
							 .data(0),
							 .wren(0),
							 .clock(clock),
							 .q(mhall)
							 );
							 
	furelisesong furelisenote(
									 .address(address),
									 .data(0),
									 .wren(0),
									 .clock(clock),
									 .q(furelise)
									 );
									 
	unravelsong unravelnote(
								  .address(address),
								  .data(0),
								  .wren(0),
								  .clock(clock),
								  .q(unravel)
								  );
		
	always @(*)
		begin
			case ( currsong )
				2'b00:   noteinfo = mhall;
				2'b01:   noteinfo = furelise;
				2'b10:   noteinfo = unravel; // if we ever do this
				2'b11:   noteinfo = 0;         
				default: noteinfo = 0;       
			endcase
		end
	
endmodule


// count which column we are currently drawing
module current_column(enable, clock, resetn, q);
	input enable, clock, resetn;
	output [1:0] q;
	reg [1:0] q;
	
	always @(posedge clock)
		begin
			if (resetn == 1'b0) 
				q <= 2'b00;
			else if (enable == 1'b1)
				begin
					if (q == 2'b11)
						q <= 2'b00;
					else
						q <= q + 1'b1;
				end
		end

endmodule


// column model
module column(shift, load, colour, column, note, pos, long, clock, resetn, access, y, press, pressphase, resetscore, X, Colour, Note, IsNote, SuccPress, LongPress);
	// will need to add even more inputs and logic for button presses
	input shift, load, pos, clock, resetn, access, press, long, pressphase, resetscore;
	input [2:0] colour;
	input [3:0] note;
	input [1:0] column;
	input [6:0] y;
	
	output reg [6:0] X;
	output reg [2:0] Colour;
	output reg [3:0] Note;
	output reg       IsNote;
	output reg       SuccPress;
	output reg       LongPress;
	
	localparam WHITE_LINE = 7'b1100100;

	// screen view
	// position: 1 wherever a box exists
	// change all 115s to 8s for testing purposes
	reg [115:0] position;
	reg [115:0] col0;
	reg [115:0] col1;
	reg [115:0] col2;
	reg [115:0] note0;
	reg [115:0] note1;
	reg [115:0] note2;
	reg [115:0] note3;
	reg [115:0] islong;
	
	reg [6:0] counter;
   reg [6:0] temp_y;
   reg 		 temp_islong;
	
	always @(posedge clock)
		begin
			if (resetn == 1'b0)
				begin
					position <= 0;
					col0 <= 0;
					col1 <= 0;
					col2 <= 0;
					note0 <= 0;
					note1 <= 0;
					note2 <= 0;
					note3 <= 0;
					islong <= 0;
					IsNote <= 0;
					Note <= 0;
					SuccPress <= 0;
					LongPress <= 0;
				end
			else if (resetscore == 1'b1)
				begin
					SuccPress <= 0;
					LongPress <= 0;
				end
			else if (shift == 1'b1) // shift down logic
				begin
					if (load == 1'b1) // load note in
						begin
						// 114 changed to 7 for testing purposes
							position <= {position[114:0], pos};
							col0 <= {col0[114:0], colour[0]};
							col1 <= {col1[114:0], colour[1]};
							col2 <= {col2[114:0], colour[2]};
							note0 <= {note0[114:0], note[0]};
							note1 <= {note1[114:0], note[1]};
							note2 <= {note2[114:0], note[2]};
							note3 <= {note3[114:0], note[3]};
							islong <= {islong[114:0], long};
						end
					else
						begin
							position <= {position[114:0], 1'b0};
							col0 <= {col0[114:0], 1'b0};
							col1 <= {col1[114:0], 1'b0};
							col2 <= {col2[114:0], 1'b0};
							note0 <= {note0[114:0], 1'b0};
							note1 <= {note1[114:0], 1'b0};
							note2 <= {note2[114:0], 1'b0};
							note3 <= {note3[114:0], 1'b0};
							islong <= {islong[114:0], 1'b0};
						end
				end
			else if (access == 1'b1) // access value at location for VGA
				begin
					if (column == 2'b00)
						X <= 7'b0111010; // 58
					else if (column == 2'b01)
						X <= 7'b1000100; // 68
					else if (column == 2'b10)
						X <= 7'b1001110; // 78
					else if (column == 2'b11)
						X <= 7'b1011000; // 88
					Colour <= {col2[y], col1[y], col0[y]};
				end
			else if (pressphase == 1'b1)
				begin 
					if (press == 1'b1) // check around box 
						begin
							if (position[WHITE_LINE] == 1'b1) 
								begin
									IsNote <= 1'b1;
									Note <= {note3[WHITE_LINE], note2[WHITE_LINE], note1[WHITE_LINE], note0[WHITE_LINE]};
								end
							else 
								begin
									IsNote <= 1'b0;
								end
							if (col0[WHITE_LINE] == 1'b0 && col1[WHITE_LINE] == 1'b0 && col2[WHITE_LINE] == 1'b0) 
								begin // no note here
									SuccPress <= 0;
									LongPress <= 0;
								end						 
							else  // note is here
								begin
									if (islong[WHITE_LINE] == 1'b0)
										begin // short box, 1 press
											SuccPress <= 1;
											LongPress <= 0;
											if (position[WHITE_LINE - 2'b11] == 1'b1) 
												begin
													col0[WHITE_LINE - 2'b11] = 1'b0;
													col1[WHITE_LINE - 2'b11] = 1'b0;
													col2[WHITE_LINE - 2'b11] = 1'b0;
													col0[WHITE_LINE - 3'b100] = 1'b0;
													col1[WHITE_LINE - 3'b100] = 1'b0;
													col2[WHITE_LINE - 3'b100] = 1'b0;
												end
											if (position[WHITE_LINE - 2'b10] == 1'b1) 
												begin
													col0[WHITE_LINE - 2'b10] = 1'b0;
													col1[WHITE_LINE - 2'b10] = 1'b0;
													col2[WHITE_LINE - 2'b10] = 1'b0;
												end
											if (position[WHITE_LINE - 1'b1] == 1'b1) 
												begin
													col0[WHITE_LINE - 1'b1] = 1'b0;
													col1[WHITE_LINE - 1'b1] = 1'b0;
													col2[WHITE_LINE - 1'b1] = 1'b0;
												end
											if (position[WHITE_LINE] == 1'b1) 
												begin
													col0[WHITE_LINE] = 1'b0;
													col1[WHITE_LINE] = 1'b0;
													col2[WHITE_LINE] = 1'b0;
												end
											if (position[WHITE_LINE + 1'b1] == 1'b1)
												begin
													col0[WHITE_LINE + 1'b1] = 1'b0;
													col1[WHITE_LINE + 1'b1] = 1'b0;
													col2[WHITE_LINE + 1'b1] = 1'b0;
												end
											if (position[WHITE_LINE + 2'b10] == 1'b1)
												begin
													col0[WHITE_LINE + 2'b10] = 1'b0;
													col1[WHITE_LINE + 2'b10] = 1'b0;
													col2[WHITE_LINE + 2'b10] = 1'b0;
												end
											if (position[WHITE_LINE + 2'b11] == 1'b1)
												begin
													col0[WHITE_LINE + 2'b11] = 1'b0;
													col1[WHITE_LINE + 2'b11] = 1'b0;
													col2[WHITE_LINE + 2'b11] = 1'b0;
												end
										end
									
									else // pressed long note, need to hold
										begin
										// if there are 8 consecutive 0s and next is not black
											islong[WHITE_LINE] = 1'b0;
											if (islong[WHITE_LINE + 4'b0111: WHITE_LINE] == 8'b00000000 && 
												~(col0[WHITE_LINE + 1'b1] == 1'b0 && col1[WHITE_LINE + 1'b1] == 1'b0 && col2[WHITE_LINE + 1'b1] == 1'b0) &&
												~(col0[WHITE_LINE + 2'b11] == 1'b0 && col1[WHITE_LINE + 2'b11] == 1'b0 && col2[WHITE_LINE + 2'b11] == 1'b0) &&
												~(col0[WHITE_LINE + 3'b101] == 1'b0 && col1[WHITE_LINE + 3'b101] == 1'b0 && col2[WHITE_LINE + 3'b101] == 1'b0) &&
												~(col0[WHITE_LINE + 3'b111] == 1'b0 && col1[WHITE_LINE + 3'b111] == 1'b0 && col2[WHITE_LINE + 3'b111] == 1'b0)
												)
												begin
													SuccPress <= 1;
													LongPress <= 1;
													if (position[WHITE_LINE - 2'b11] == 1'b1) 
														begin
															col0[WHITE_LINE - 2'b11] = 1'b0;
															col1[WHITE_LINE - 2'b11] = 1'b0;
															col2[WHITE_LINE - 2'b11] = 1'b0;
															col0[WHITE_LINE - 3'b100] = 1'b0;
															col1[WHITE_LINE - 3'b100] = 1'b0;
															col2[WHITE_LINE - 3'b100] = 1'b0;
															col0[WHITE_LINE - 3'b101] = 1'b0;
															col1[WHITE_LINE - 3'b101] = 1'b0;
															col2[WHITE_LINE - 3'b101] = 1'b0;
														end
													if (position[WHITE_LINE - 2'b10] == 1'b1) 
														begin
															col0[WHITE_LINE - 2'b10] = 1'b0;
															col1[WHITE_LINE - 2'b10] = 1'b0;
															col2[WHITE_LINE - 2'b10] = 1'b0;
														end
													if (position[WHITE_LINE - 1'b1] == 1'b1) 
														begin
															col0[WHITE_LINE - 1'b1] = 1'b0;
															col1[WHITE_LINE - 1'b1] = 1'b0;
															col2[WHITE_LINE - 1'b1] = 1'b0;
														end
													if (position[WHITE_LINE] == 1'b1) 
														begin
															col0[WHITE_LINE] = 1'b0;
															col1[WHITE_LINE] = 1'b0;
															col2[WHITE_LINE] = 1'b0;
														end
													if (position[WHITE_LINE + 1'b1] == 1'b1)
														begin
															col0[WHITE_LINE + 1'b1] = 1'b0;
															col1[WHITE_LINE + 1'b1] = 1'b0;
															col2[WHITE_LINE + 1'b1] = 1'b0;
														end
													if (position[WHITE_LINE + 2'b10] == 1'b1)
														begin
															col0[WHITE_LINE + 2'b10] = 1'b0;
															col1[WHITE_LINE + 2'b10] = 1'b0;
															col2[WHITE_LINE + 2'b10] = 1'b0;
														end
													if (position[WHITE_LINE + 2'b11] == 1'b1)
														begin
															col0[WHITE_LINE + 2'b11] = 1'b0;
															col1[WHITE_LINE + 2'b11] = 1'b0;
															col2[WHITE_LINE + 2'b11] = 1'b0;
														end
													if (position[WHITE_LINE + 3'b100] == 1'b1)
														begin
															col0[WHITE_LINE + 3'b100] = 1'b0;
															col1[WHITE_LINE + 3'b100] = 1'b0;
															col2[WHITE_LINE + 3'b100] = 1'b0;
														end
													if (position[WHITE_LINE + 3'b101] == 1'b1)
														begin
															col0[WHITE_LINE + 3'b101] = 1'b0;
															col1[WHITE_LINE + 3'b101] = 1'b0;
															col2[WHITE_LINE + 3'b101] = 1'b0;
														end
													if (position[WHITE_LINE + 3'b110] == 1'b1)
														begin
															col0[WHITE_LINE + 3'b110] = 1'b0;
															col1[WHITE_LINE + 3'b110] = 1'b0;
															col2[WHITE_LINE + 3'b110] = 1'b0;
														end
													if (position[WHITE_LINE + 3'b111] == 1'b1)
														begin
															col0[WHITE_LINE + 3'b111] = 1'b0;
															col1[WHITE_LINE + 3'b111] = 1'b0;
															col2[WHITE_LINE + 3'b111] = 1'b0;
															col0[WHITE_LINE + 4'b1000] = 1'b0;
															col1[WHITE_LINE + 4'b1000] = 1'b0;
															col2[WHITE_LINE + 4'b1000] = 1'b0;
															col0[WHITE_LINE + 4'b1001] = 1'b0;
															col1[WHITE_LINE + 4'b1001] = 1'b0;
															col2[WHITE_LINE + 4'b1001] = 1'b0;
															col0[WHITE_LINE + 4'b1010] = 1'b0;
															col1[WHITE_LINE + 4'b1010] = 1'b0;
															col2[WHITE_LINE + 4'b1010] = 1'b0;
															col0[WHITE_LINE + 4'b1011] = 1'b0;
															col1[WHITE_LINE + 4'b1011] = 1'b0;
															col2[WHITE_LINE + 4'b1011] = 1'b0;
															col0[WHITE_LINE + 4'b1100] = 1'b0;
															col1[WHITE_LINE + 4'b1100] = 1'b0;
															col2[WHITE_LINE + 4'b1100] = 1'b0;
														end // this position
												end // longpress logic
										end // check longpress
								end // handle press
				      end // if press == 1
					else 
						IsNote <= 0;
				end // press phase
		end // handle phases

endmodule


// count from 0 to 115 to draw column
module column_counter(enable, clock, resetn, q);
	input enable, clock, resetn;
	output [7:0] q;
	reg [7:0] q;
	
	always @(posedge clock)
		begin
			if (resetn == 1'b0)
				q <= 7'b0000000;
			else if (enable == 1'b1)
				begin
					if (q == 7'b1110011)
						q <= 7'b0000000;
					else
						q <= q + 1'b1;
				end
		end
endmodule


// count from 0 to 7 to draw row
module row_counter(enable, clock, resetn, q);
	input enable, clock, resetn;
	output [2:0] q;
	reg [2:0] q;
	
	always @(posedge clock)
		begin
			if (resetn == 1'b0)
				q <= 3'b000;
			else if (enable == 1'b1)
				begin
					if (q == 3'b111)
						q <= 3'b000;
					else
						q <= q + 1'b1;
				end
		end
endmodule


// redraw the black screen
module draw_black(input resetn, 
						input enable, 
						input clk, 
						output reg plot, 
						output reg [2:0] col, 
						output reg [7:0] x, 
						output reg [6:0] y
						);

   localparam S_WAIT = 1'b0,
     S_DRAW = 1'b1;

   localparam WHITE_LINE = 7'b1100100,
     X_MAX = 8'b10101000,
     Y_MAX = 7'b1111111;

   reg curr_state, next_state;
   reg [7:0] counter_x, next_counter_x;
   reg [6:0] counter_y, next_counter_y;   

   always @(*)
		begin
			case(curr_state)
			  S_WAIT: next_state = enable ? S_DRAW : S_WAIT;
			  S_DRAW: 
					begin
						if (counter_x == X_MAX && counter_y == Y_MAX) 
							begin
								next_state = S_WAIT;
								next_counter_x = 8'b0;
								next_counter_y = 7'b0;	
							end
						else if (counter_x == X_MAX) 
							begin
								next_state = S_DRAW;
								next_counter_x = 8'b0;
								next_counter_y = counter_y + 1'b1;		
							end
				  else 
						begin
							next_state = S_DRAW;
							next_counter_x = counter_x + 1'b1;
							next_counter_y = counter_y;
						end
					end
				default: 
					begin
					  next_state = S_WAIT;
					  next_counter_x = 8'b0;
					  next_counter_y = 7'b0;	     
					end
			  	  
			endcase // case (curr_state)	
     end // always @ (*)
	     
   always @(*)
     begin
		plot = 1'b0;
		col = 3'b0;
		x = 8'b0;
		y = 7'b0;
		case (curr_state)
		  S_DRAW: 
				begin
					  plot = 1'b1;
					  if (counter_y == WHITE_LINE)
						 col = 3'b111;
					  else
						 col = 3'b000;
					  x = counter_x;
					  y = counter_y;
				end
		endcase // case (curr_state)	
     end // always @ (*)
		 
   always @(posedge clk)
     begin
			if (!resetn) 
				begin
					counter_x <= 8'b0;
					counter_y <= 7'b0;
					curr_state <= S_WAIT;
				end
			else 
				begin
					counter_x <= next_counter_x;
					counter_y <= next_counter_y;
					curr_state <= next_state;
				end
     end // always @ (posedge clk)
endmodule // draw_black

   


