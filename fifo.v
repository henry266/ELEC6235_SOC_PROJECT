//synchronus FIFO
`define FIFO_WIDTH 3
`define FIFO_SIZE (1<<`FIFO_WIDTH)

module fifo(
  input clk, rst, wr, rd,
  input [31:0] w_data,
  output reg [31:0] r_data,
//  output reg [`FIFO_WIDTH : 0] fifo_counter,
  output empty, full
);

reg [`FIFO_WIDTH : 0] fifo_counter;
reg [`FIFO_WIDTH-1 : 0] rd_ptr, wr_ptr;
reg [31:0] fifo_mem [`FIFO_SIZE-1 : 0];

assign empty = fifo_counter == 0;
assign full = fifo_counter == `FIFO_SIZE;

always@(posedge clk or posedge rst)
if(rst)
  fifo_counter <= 0;
else if(!full && wr && !rd)
  fifo_counter <= fifo_counter + 1;
else if(!empty && rd && ! wr)
  fifo_counter <= fifo_counter - 1;

always@(posedge clk)
if(wr && !full)
  fifo_mem[wr_ptr] <= w_data;

always@(posedge clk or posedge rst)
if(rst)
  r_data <= 32'd0;
else if(rd && !empty)
  r_data <= fifo_mem[rd_ptr];

always@(posedge clk or posedge rst)
if(rst)
begin
  wr_ptr <= 0;
  rd_ptr <= 0;
end
else begin
  if(!full && wr)
    wr_ptr <= wr_ptr + 1;
  if(!empty && rd)
    rd_ptr <= rd_ptr + 1;
end

endmodule
