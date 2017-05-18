module data_processor(
  input clk, rst,
  input empty_adc, full_dac,
  input effect_dist,effect_delay,effect_iir, // enable signal of the effects
  output rd_adc,  // 1-enable read from adc-fifo
  output wr_dac,  // 1-enable write to dac-fifo
  input  [31:0] adc_fifo_out,   //input from adc-fifo
  output [31:0] dac_fifo_in     //output to dac-fifo
);

//-----state parameters-------
parameter IDLE = 4'd0;
parameter FIRST = 4'd1;
parameter PROC = 4'd2;

//-----size definition for delay mem---------
parameter MEM_DEPTH = 13;     //delay time = 2^13/ 48k
parameter MEM_SIZE = 1 << MEM_DEPTH;

reg [31:0] delay_mem  [MEM_SIZE-1 :0];
reg [31:0] delay_mem1 [MEM_SIZE-1 :0];
reg [31:0] delay_mem2 [MEM_SIZE-1 :0];
reg [31:0] delay_mem3 [MEM_SIZE-1 :0];
reg [MEM_DEPTH-1 : 0] addr;

reg [9:0] counter;

reg [3:0] state;
reg [3:0] next_state;

reg [31:0] buffer0,buffer1,buffer2,buffer3,buffer4;
reg valid;
reg done;

wire signed [15:0] left_0,right_0;
wire signed [15:0] left_1,right_1;
wire signed [15:0] left_2,right_2;
wire signed [15:0] left_3,right_3;
wire signed [15:0] left_4,right_4;

assign left_0  = buffer0[31:16];
assign right_0 = buffer0[15:0];
assign left_1  = buffer1[31:16];
assign right_1 = buffer1[15:0];
assign left_2  = buffer2[31:16];
assign right_2 = buffer2[15:0];
assign left_3  = buffer3[31:16];
assign right_3 = buffer3[15:0];
assign left_4  = buffer4[31:16];
assign right_4 = buffer4[15:0];


wire signed [15:0] left_dist, right_dist;
wire signed [15:0] left_dist_amp, right_dist_amp;

//-----sound clipping (distortion)-----
assign left_dist = ~left_0[15]?(left_0 > 32 ? 32 : left_0) : (left_0 < -32 ? -32 : left_0);      //threshold = 32
assign right_dist = ~right_0[15]?(right_0 > 32 ? 32 : right_0) : (right_0 < -32 ? -32 : right_0); 

//-----sound amplify-----
assign left_dist_amp = left_dist << 1;
assign right_dist_amp = right_dist << 1;

//-----delay & echo--------
wire signed [15:0] left_delay, right_delay;
wire signed [15:0] left_echo, right_echo;
assign left_echo   = left_0/2 + left_1/2 + left_2/4 + left_3/8 + left_4/16;
assign right_echo  = right_0/2 + right_1/2 + right_2/4 + right_3/8 + right_4/16;
assign left_delay  = left_0/2 + left_4/2;
assign right_delay = right_0/2 + right_4/2;

assign dac_fifo_in = effect_delay ? {left_delay,right_delay}:
                     effect_dist  ? {left_dist_amp,right_dist_amp}:
                     effect_iir   ? {left_echo,right_echo} : buffer0;

assign rd_adc = !empty_adc &&(state == IDLE || done);
assign wr_dac = valid && !full_dac;


always@(posedge clk or posedge rst)
if(rst)
  state <= 4'd0;
else
  state <= next_state;

always@(*)
begin
  next_state = state;
  case(state)
    IDLE    : if(!empty_adc) next_state = FIRST;
    FIRST   : next_state = PROC;
    PROC    : next_state = PROC;
  endcase

end

reg flag0;

//wire signed [15:0] left_in,right_in;
//assign left_in = adc_fifo_out[31:16];
//assign right_in = adc_fifo_out[15:0];

always@(posedge clk or posedge rst)
if(rst) begin
  buffer0 <= 32'b0;
  flag0 <= 0;
end else if(state == IDLE && !empty_adc) begin        //loading first sample
  buffer0 <= adc_fifo_out;
  flag0 <= 1;
end else if(state != IDLE && !empty_adc && done) begin //loading following samples
  buffer0 <= adc_fifo_out;
  flag0 <= 1;
end else
  flag0 <= 0;

always@(posedge clk or posedge rst)
if(rst)
  valid <= 0;
else
  valid <= flag0;

always@(posedge clk or posedge rst)
if(rst)
  done <= 0;
else if(state == PROC && !full_dac && valid)
  done <= 1;
else if(wr_dac)
  done <= 0;

always@(posedge clk or posedge rst)
if(rst)
  buffer1 <= 32'b0;
else
  buffer1 <= delay_mem[addr+1];

always@(posedge clk or posedge rst)
if(rst)
  buffer2 <= 32'b0;
else
  buffer2 <= delay_mem1[addr+1];
  
always@(posedge clk or posedge rst)
if(rst)
  buffer3 <= 32'b0;
else
  buffer3 <= delay_mem2[addr+1];
  
always@(posedge clk or posedge rst)
if(rst)
  buffer4 <= 32'b0;
else
  buffer4 <= delay_mem3[addr+1];
  
always@(posedge clk)
if(rst)
counter <= 0;
else
counter <= counter + 1;

always@(posedge clk)
if(rst)
addr <= 0;
else if(&counter)
addr <= addr + 1;

always@(posedge clk)
delay_mem[addr] <= buffer0;

always@(posedge clk)
delay_mem1[addr] <= buffer1;

always@(posedge clk)
delay_mem2[addr] <= buffer2;

always@(posedge clk)
delay_mem3[addr] <= buffer3;

endmodule
