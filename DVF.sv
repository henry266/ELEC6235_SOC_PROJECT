//clock divider for sensor communication
module DVF(
  input clk,rst,
  output reg clkout
);
parameter divd=25;
reg[7:0] cnt;

always@(posedge clk)
	if(rst) begin
    cnt<=8'b0;
    clkout<=1'b0;
  end else if(cnt<divd)
		cnt<=cnt+8'b1;
	else begin
    cnt<=8'b0;
    clkout<=~clkout;
	end
endmodule 
