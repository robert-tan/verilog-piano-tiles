// main control module
module control(clock, resetn, go, speed, songdone, draw, reset_screen, load_song, load_note, shift, logic_in, reset_score);
	input clock, resetn, go, songdone;
	input [1:0] speed;
	output reg draw, reset_screen, load_song, load_note, shift, logic_in, reset_score;
	
	reg [2:0] current_state, next_state;
	reg load_speed, count;
	wire [19:0] seconds;
	wire [3:0] framecount;
	wire [11:0] pixelsdrawn;
	wire [14:0] screendrawn;
	wire frameenable, shiftdown;
	wire redraw_done, draw_done, finishedcolumn, finisheddraw;
	
	localparam DRAW_RESET      = 3'd0,
				  LOAD            = 3'd1,
				  WAIT            = 3'd2,
				  LOAD_NOTE       = 3'd3,
				  SHIFT_DOWN_WAIT = 3'd4,
				  SHIFT_DOWN      = 3'd5,
				  DRAW            = 3'd6,
				  PLAYER_LOGIC    = 3'd7;
	
						 
	delay_counter dc(
						 .enable(count),
						 .clock(clock),
						 .resetn(resetn),
						 .q(seconds)
						 );
						 
	assign frameenable = (seconds == 0) ? 1 : 0;
	
	frame_counter fc(
						 .enable(frameenable),
						 .clock(clock),
						 .resetn(resetn),
						 .load(load_speed),
						 .speed(speed),
						 .q(framecount)
						 );
						 
	assign shiftdown = (framecount == 4'b0000 & seconds == 0) ? 1 : 0;
	
	draw_counter drawc(
						 .enable(draw),
						 .clock(clock),
						 .resetn(resetn),
						 .q(pixelsdrawn)
						 );
						 
	redraw_counter rdc(
						 .enable(reset_screen),
						 .clock(clock),
						 .resetn(resetn),
						 .q(screendrawn)
						 );
	
	assign redraw_done = (screendrawn == 0) ? 1 : 0;
	
	assign draw_done = (pixelsdrawn == 0) ? 1 : 0;
	
	always @(*)
		begin: state_table
			case (current_state)
				DRAW_RESET: next_state = redraw_done ? LOAD : DRAW_RESET; 
				LOAD: next_state = go ? WAIT : LOAD;
				WAIT: next_state = go ? WAIT : LOAD_NOTE;
				LOAD_NOTE: next_state = songdone ? DRAW_RESET : SHIFT_DOWN_WAIT; 
				SHIFT_DOWN_WAIT : next_state = shiftdown ? SHIFT_DOWN : SHIFT_DOWN_WAIT;
				SHIFT_DOWN: next_state = DRAW; 
				DRAW: next_state = draw_done ? PLAYER_LOGIC : DRAW; 
				PLAYER_LOGIC: next_state = LOAD_NOTE;
				default: next_state = DRAW_RESET;
			endcase
		end
		
	always @(*)
		begin: enable_signals
			reset_screen = 1'b0;
			load_song = 1'b0;
			load_speed = 1'b0;
			load_note = 1'b0;
			shift = 1'b0;
			draw = 1'b0;
			count = 1'b0;
			logic_in = 1'b0;
			reset_score = 1'b0;
			
			case (current_state)
				DRAW_RESET:
					begin
						reset_screen = 1'b1;
					end
				LOAD:
					begin
						load_song = 1'b1;
						load_speed = 1'b1;
					end
				LOAD_NOTE:
					begin
						load_note = 1'b1;
						reset_score = 1'b1;
					end
				SHIFT_DOWN_WAIT:
					begin
						count = 1'b1;
					end
				SHIFT_DOWN:
					begin 
						shift = 1'b1;
					end
				DRAW:
					begin
						draw = 1'b1;
					end
				PLAYER_LOGIC:
					begin
						logic_in = 1'b1;
					end
			endcase
		end
		
	always @(posedge clock)
		begin: state_FFs
			if (resetn == 1'b0) 
				current_state <= DRAW_RESET;
			else
				current_state <= next_state;
		end

endmodule


// count down from 1/60th of a second
module delay_counter(enable, clock, resetn, q);
	input enable, clock, resetn;
	output [19:0] q;
	reg [19:0] q;
	
	always @(posedge clock)
		begin
			if (resetn == 1'b0)
				q <= 20'b11001011011100110111;
			else if (enable == 1'b1)
				begin
					if (q == 0)
						q <= 20'b11001011011100110111; // around 1/60th a second of 50Mhz
					else
						q <= q - 1'b1;
				end
		end
endmodule


// count down the frames. Can control the speed with load.
// 7 frames per second
// 15 frames per second
// 30 frames per second
// 60 frames per second
module frame_counter(enable, clock, resetn, load, speed, q);
	input enable, clock, resetn, load;
	input [1:0] speed;
	reg [3:0] currspeed;
	output [3:0] q;
	reg [3:0] q;
	
	always @(posedge clock)
		begin
			if (resetn == 1'b0)
				begin
					q <= 4'b0000;
					currspeed <= 4'b0100;
				end
			else if (load == 1'b1)
				begin
					if (speed == 2'b00)
						currspeed <= 4'b0100;
					else if (speed == 2'b01)
						currspeed <= 4'b0010;
					else if (speed == 2'b10)
						currspeed <= 4'b0001;
					else if (speed == 2'b11)
						currspeed <= 4'b0000;
				end
			else if (enable == 1'b1)
				begin
					if (q == 4'b0000)
						q <= currspeed;
					else
						q <= q - 1'b1;
				end
		end
endmodule


// make sure we have enough clock cycles to draw everything
module draw_counter(enable, clock, resetn, q);
	input enable, clock, resetn;
	output [11:0] q;
	reg [11:0] q;
	
	always @(posedge clock)
		begin
			if (resetn == 1'b0)
				q <= 12'b111010000000; // 32 * 116
			else if (enable == 1'b1)
				begin
					if (q == 12'b000000000000)
						q <= 12'b111010000000;
					else
						q <= q - 1'b1;
				end
		end
endmodule


// make sure we have enough clock cycles to redraw everything
module redraw_counter(enable, clock, resetn, q);
	input enable, clock, resetn;
	output [14:0] q;
	reg [14:0] q;
	
	always @(posedge clock)
		begin
			if (resetn == 1'b0)
				q <= 15'b100011111100000; // 154 * 116
			else if (enable == 1'b1)
				begin
					if (q == 15'b000000000000000)
						q <= 15'b100010111001000;
					else
						q <= q - 1'b1;
				end
		end

endmodule
