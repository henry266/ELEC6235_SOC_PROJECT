module data_processor(
  input clk, rst,
  input empty_adc, full_dac,
  output rd_adc, wr_dac,
  input [31:0] adc_fifo_out,
  output [31:0] dac_fifo_in
);

reg [31:0] buffer0;
reg valid;
reg done;
reg first;


//wire [31:0] fx;
//assign fx = 32'd2 >> (32'd3*adc_fifo_out);

assign dac_fifo_in = buffer0;
assign rd_adc = !empty_adc &&(first || done);
//assign rd_adc = 0;
assign wr_dac = valid && !full_dac;

always@(posedge clk or posedge rst)
if(rst)
  first <= 1;
else if(!empty_adc)
  first <= 0;

always@(posedge clk or posedge rst)
if(rst)
  done <= 0;
else if(wr_dac)
  done <= 1;
else if(rd_adc)
  done <= 0;

always@(posedge clk or posedge rst)
if(rst)
  valid <= 0;
else if(rd_adc)
  valid <= 1;
else if(wr_dac)
  valid <= 0;

always@(posedge clk or posedge rst)
if(rst) begin
  buffer0 <= 32'b0;
//  buffer1 <= '0;
end else if(rd_adc)
  buffer0 <= adc_fifo_out;


endmodule
