module sensor_ctrl(
input clk,rst,
inout Data,
output[7:0] SEG0,SEG1,SEG2,SEG3,
output[7:0] humidity
);

wire[39:0] data;
wire clkout;

DVF dvf(.*);
temp Temp(.*);
DHT_SEG8 T_Show(.*);



endmodule
