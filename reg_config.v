//this module is modified based on 3rd party IP
module reg_config(
  input clk,rst,
  input i2c_sclk, //databus "sdin"
  inout i2c_sdin,//from module "i2c_com"
	input SW8,SW9,SW10
);

////////////////////////////////////////////////////////////////////////////
reg       clock_20k;
reg [15:0]clock_20k_cnt;
reg [1:0] config_step;
reg [3:0] reg_index;
reg [23:0]i2c_data;
reg [15:0]reg_data;
reg       start;
wire      ack,tr_end;
////////////////////////////////////////////////////////////////////////////
i2c_com u1(
		   .clock_i2c(clock_20k),//
		   .rst(rst),          // reset
		   .ack(ack),          // acknowledge
		   .i2c_data(i2c_data),// 24bit config data 
		   .start(start),      // start ctrl
		   .tr_end(tr_end),    // transmit over
		   .i2c_sclk(i2c_sclk),// output sclk
		   .i2c_sdin(i2c_sdin) // inout sdin
		   );
////////////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
     begin
        if(rst)
			begin
			   clock_20k<=0;
			   clock_20k_cnt<=0;
			end
        else if(clock_20k_cnt<2499)
               clock_20k_cnt<=clock_20k_cnt+1;
        else
			begin
			   clock_20k<=!clock_20k;
			   clock_20k_cnt<=0;
			end
     end
////////////////////////////////////////////////////////////////////////////         
always@(posedge clock_20k or posedge rst)
     begin
         if(rst)
            begin
				config_step<=0;
				start<=0;
				reg_index<=0;
            end
         else
            begin
				if(reg_index<10)//from 0 to 9 , almost 10 register
					begin
						 case(config_step)
						 
						 0:begin
							   i2c_data<={8'h34,reg_data};//0x34(device address + r/w bit 0)
							   start<=1;
							   config_step<=1;//next step
						   end
						 1:begin
							   if(tr_end)
								   begin
									 if(!ack)// data transmit right then next......
									 config_step<=2;
									 else
									 config_step<=0;//if wrong return step 0
									 start<=0;//over
								   end
						   end
						 2:begin
								 reg_index<=reg_index+1;//next register
								 config_step<=0;
						   end
						 endcase
					 end	else if(SW8) begin
					reg_index <= 0;
				end
           end
      end
/////////////////////////////////////////////////////////////////////////////////////////         
always@(reg_index or SW9 or SW10) //refer to "WM8731 datasheet"  
      begin
			case(reg_index)
				0: reg_data<={8'b00000000,!SW9,7'b00_11111};//0000000_0_0_0_0_10111
				1: reg_data<={8'b00000001,!SW9,7'b00_11111};//0000001_0_0_0_0_10111
				2: reg_data<=16'h047F;//0000010_0_0_1100000
				3: reg_data<=16'h067F;//0000011_0_0_1100000
				4: reg_data<={10'b0000100_0_00,SW10,5'b1_0_0_0_0};//0000100_0__00_1_1__0_0_0_0
				5: reg_data<=16'b0000101_0000_1_0_00_0;//0000101_0000_1_1_10_0
				6: reg_data<=16'h0c00;//0000110_0__00000000
				7: reg_data<=16'h0e01;//0000111_0__0_0_0_0_00_01
				8: reg_data<=16'h1000;//0001000_0__0_0_0000_0_1
				9: reg_data<=16'h1201;//0001001_00000000_1
				default:reg_data<=16'h0017;
		    endcase
      end
endmodule

