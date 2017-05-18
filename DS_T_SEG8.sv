module DHT_SEG8(
input clk,rst,
input[39:0] data,   // 40-bit humidity & temperature data
output reg [7:0] SEG0,SEG1,SEG2,SEG3,
output reg [7:0] humidity //current humidity value
);

reg [1:0]   SCAN_R;
reg [3:0]   SEG_DR0,SEG_DR1,SEG_DR2,SEG_DR3;
reg [7:0]   DIG;


always @(posedge clk or posedge rst)
begin

if(rst)
begin
//data<=0;
humidity<=8'd0;
DIG = 8'hFF; 
end

else
begin
   SCAN_R = SCAN_R + 1'b1;
   case(SCAN_R)
      3'h0 :
	begin 
       DIG = 8'h80; 
       SEG_DR0 = data[39:32]/10;  //first digit of integer part of humidity
		 humidity <= data[39:32];
       case(SEG_DR0)
      4'h0 : SEG0 <= 8'hC0;
      4'h1 : SEG0 <= 8'hF9;
      4'h2 : SEG0 <= 8'hA4;
      4'h3 : SEG0 <= 8'hB0;
      4'h4 : SEG0 <= 8'h99;
      4'h5 : SEG0 <= 8'h92;
      4'h6 : SEG0 <= 8'h82;
      4'h7 : SEG0 <= 8'hF8;
      4'h8 : SEG0 <= 8'h80;
      4'h9 : SEG0 <= 8'h90;
      default : SEG0 <= 8'hFF;
      endcase
       
       end
      3'h1 :
       begin DIG = 8'hBF;
       SEG_DR1 = data[39:32]%10; //second digit of integer part of humidity
//		 humidity <= data[39:32];
       case(SEG_DR1)
      4'h0 : SEG1 <= 8'hC0;
      4'h1 : SEG1 <= 8'hF9;
      4'h2 : SEG1 <= 8'hA4;
      4'h3 : SEG1 <= 8'hB0;
      4'h4 : SEG1 <= 8'h99;
      4'h5 : SEG1 <= 8'h92;
      4'h6 : SEG1 <= 8'h82;
      4'h7 : SEG1 <= 8'hF8;
      4'h8 : SEG1 <= 8'h80;
      4'h9 : SEG1 <= 8'h90;
      default : SEG1 <= 8'hFF;
      endcase
      end 
	  3'h2 :
	   begin 
	   DIG = 8'hF7; 
	   SEG_DR2 = data[23:16]/10;  //first digit of integer part of temperature
       case(SEG_DR2)
      4'h0 : SEG2 <= 8'hC0;
      4'h1 : SEG2 <= 8'hF9;
      4'h2 : SEG2 <= 8'hA4;
      4'h3 : SEG2 <= 8'hB0;
      4'h4 : SEG2 <= 8'h99;
      4'h5 : SEG2 <= 8'h92;
      4'h6 : SEG2 <= 8'h82;
      4'h7 : SEG2 <= 8'hF8;
      4'h8 : SEG2 <= 8'h80;
      4'h9 : SEG2 <= 8'h90;
      default : SEG2 <= 8'hFF;
      endcase
	   end
      3'h3 :
       begin 
       DIG = 8'hFB; 
       SEG_DR3 = data[23:16]%10;   //second digit of integer part of temperature
       case(SEG_DR3)
      4'h0 : SEG3 <= 8'hC0;
      4'h1 : SEG3 <= 8'hF9;
      4'h2 : SEG3 <= 8'hA4;
      4'h3 : SEG3 <= 8'hB0;
      4'h4 : SEG3 <= 8'h99;
      4'h5 : SEG3 <= 8'h92;
      4'h6 : SEG3 <= 8'h82;
      4'h7 : SEG3 <= 8'hF8;
      4'h8 : SEG3 <= 8'h80;
      4'h9 : SEG3 <= 8'h90;
      default : SEG3 <= 8'hFF;
      endcase
      end
 
   endcase
end
end
endmodule 
