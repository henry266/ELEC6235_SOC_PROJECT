//this module is modified based on 3rd party IP
module i2c_com(clock_i2c,//i2c clock 10khz
               rst,      //reset     
               ack,      
               i2c_data, //24-bit
               start,    //
               tr_end,   //transmition end
               cyc_count,//sclk count   
               i2c_sclk, //
               i2c_sdin);//
/////////////////////////////////////////////////////////////////////////               
input [23:0]i2c_data;
input rst,clock_i2c,start;
output [5:0]cyc_count;
output ack;
output tr_end;
output i2c_sclk;//sclk
inout  i2c_sdin;//sdin
/////////////////////////////////////////////////////////////////////////
reg [5:0] cyc_count;
reg reg_sdat;
reg sclk;
reg ack1,ack2,ack3;
reg tr_end;
wire i2c_sclk;
wire i2c_sdin;
wire ack;
/////////////////////////////////////////////////////////////////////////
assign ack=ack1|ack2|ack3;//only one ack high indicate that data be wrong---(0+0+0)=0
assign i2c_sclk=sclk|(((cyc_count>=4)&(cyc_count<=30))?~clock_i2c:0);
//4-30 data on "sdin" databus ready, then sclk negedge shift into device
assign i2c_sdin=reg_sdat?1'bz:0;//when input sdin z, when output z=high(outside pullup) 0=low
/////////////////////////////////////////////////////////////////////////
always@(posedge clock_i2c or  posedge rst)//count number of clock_i2c when "start"
begin
   if(rst)  
	   begin
			cyc_count<=6'b111111;
	   end
   else 
	   begin
		   if(start==0) 
			   begin  
					cyc_count<=0;
			   end
		   else if(cyc_count<6'b111111)	
			   begin	
					cyc_count<=cyc_count+1;//
			   end
	   end
end
/////////////////////////////////////////////////////////////////////////
always@(posedge clock_i2c or posedge rst)
begin
   if(rst)
	   begin
		  tr_end<=0;
		  ack1<=1; ack2<=1;ack3<=1;
		  sclk<=1;
		  reg_sdat<=1;
	   end
   else
	   begin	
			case(cyc_count)
					0:begin 
						ack1<=1;ack2<=1;ack3<=1;tr_end<=0;sclk<=1;reg_sdat<=1;//sdin  z_status
					  end
					1:reg_sdat<=0;//start(sclk=1&&negedge of sdin)
					2:sclk<=0;    //
					3:reg_sdat<=i2c_data[23];
					4:reg_sdat<=i2c_data[22];
					5:reg_sdat<=i2c_data[21];
					6:reg_sdat<=i2c_data[20];
					7:reg_sdat<=i2c_data[19];
					8:reg_sdat<=i2c_data[18];
					9:reg_sdat<=i2c_data[17];
					10:reg_sdat<=i2c_data[16];//7 bit device address + R/W bit = 0x34
					11:reg_sdat<=1;//ack, master pull up the sdin
					///////////////////////////////////////////////////////////////   
					12:begin 
						reg_sdat<=i2c_data[15];ack1<=i2c_sdin;//get ack1 from sdin
					   end
					13:reg_sdat<=i2c_data[14];
					14:reg_sdat<=i2c_data[13];
					15:reg_sdat<=i2c_data[12];
					16:reg_sdat<=i2c_data[11];
					17:reg_sdat<=i2c_data[10];
					18:reg_sdat<=i2c_data[9];
					19:reg_sdat<=i2c_data[8];
					20:reg_sdat<=1;
					///////////////////////////////////////////////////////////////
					21:begin 
						reg_sdat<=i2c_data[7];ack2<=i2c_sdin;
					   end
					22:reg_sdat<=i2c_data[6];
					23:reg_sdat<=i2c_data[5];
					24:reg_sdat<=i2c_data[4];
					25:reg_sdat<=i2c_data[3];
					26:reg_sdat<=i2c_data[2];
					27:reg_sdat<=i2c_data[1];
					28:reg_sdat<=i2c_data[0];
					29:reg_sdat<=1;
					///////////////////////////////////////////////////////////////
					30:begin 
						ack3<=i2c_sdin;sclk<=0;reg_sdat<=0;
					   end
					31:sclk<=1;
					32:begin 
					    reg_sdat<=1;//posedge of sdin when sclk = 1
						tr_end<=1;  //write over
					   end
					default:;
			endcase
	   end
end

endmodule

