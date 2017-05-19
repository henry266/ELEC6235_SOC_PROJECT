//this module is modified based on example in the book:
//Embedded_SoPC_Design_with_Nios_II_Processor_and_Verilog_Examples
//Digital interface controller
module adc_dac(
  input wire clk,rst,  //50Mhz clk
  input wire [31:0] dac_data_in,   //data to be transformed to serial input of CODEC
  output wire [31:0] adc_data_out,  //transfromed from serial output of CODEC
  output wire m_clk, b_clk, dac_lr_clk, adc_lr_clk,
  output wire dacdat,  //serial data from FPGA to CODEC
  input wire adcdat,  //serial data from CODEC to FPGA
  output wire load_done_tick
);

localparam M_DVSR = 2;
localparam B_DVSR = 3;
localparam LR_DVSR = 5;

reg [M_DVSR-1 : 0] m_reg;
wire [M_DVSR-1 : 0] m_next;
reg [B_DVSR-1 : 0] b_reg;
wire [B_DVSR-1 : 0] b_next;
reg [LR_DVSR-1 : 0] lr_reg;
wire [LR_DVSR-1 : 0] lr_next;
reg [31:0] dac_buf_reg, adc_buf_reg;
wire [31:0] dac_buf_next, adc_buf_next;
reg lr_delayed_reg, b_delayed_reg;
wire m_12_5m_tick, load_tick, b_neg_tick, b_pos_tick;

always@(posedge clk, posedge rst)
if(rst)
  begin
    m_reg          <= 0;
    b_reg          <= 0;
    lr_reg         <= 0;
    dac_buf_reg    <= 0;
    adc_buf_reg    <= 0;
    b_delayed_reg  <= 0;
    lr_delayed_reg <= 0;
  end
else
  begin
    m_reg          <= m_next;
    b_reg          <= b_next;
    lr_reg         <= lr_next;
    dac_buf_reg    <= dac_buf_next;
    adc_buf_reg    <= adc_buf_next;
    b_delayed_reg  <= b_reg[B_DVSR-1];
    lr_delayed_reg <= lr_reg[LR_DVSR-1];
  end

assign m_next = m_reg + 1;
assign m_clk = m_reg[M_DVSR-1];
assign m_12_5m_tick = (m_reg == 0)? 1'b1 : 1'b0;
assign b_next = m_12_5m_tick ? b_reg + 1 : b_reg;
assign b_clk = b_reg[B_DVSR-1];
assign b_neg_tick = b_delayed_reg & ~b_reg[B_DVSR-1];
assign b_pos_tick = ~b_delayed_reg & b_reg[B_DVSR-1];
assign lr_next = b_neg_tick ? lr_reg + 1 : lr_reg;
assign dac_lr_clk = lr_reg[LR_DVSR-1];
assign adc_lr_clk = lr_reg[LR_DVSR-1];
assign load_tick = ~lr_delayed_reg & lr_reg[LR_DVSR-1];
assign load_done_tick = load_tick;
assign dac_buf_next = load_tick  ? dac_data_in :
                      b_neg_tick ? {dac_buf_reg[30:0], 1'b0} : dac_buf_reg;              
assign dacdat = dac_buf_reg[31];
assign adc_buf_next = b_pos_tick ? {adc_buf_reg[30:0], adcdat} : adc_buf_reg;
assign adc_data_out = adc_buf_reg;

endmodule
