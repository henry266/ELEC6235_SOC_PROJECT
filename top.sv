module top(
  input clk,
  input rst,
  inout i2c_sdin,  //i2c data wire to audio codec
  output i2c_sclk, //i2c control wire to audio codec
  
  input SW16,SW15,SW14,			//16-delay,15-dist,14-echo: 0-disable, 1-enable
  input SW13,						//effect selection: 0-automatic, 1-manual
  output[7:0] SEG0,SEG1,SEG2,SEG3, // 7-seg disp, {SEG0,SEG1}:humidity, {SEG2,SEG3}:temp
  inout Data,		//data wire to the sensor
  input SW8,		//reconfigure enbale: 1-enbale changes on SW9&SW10. 
  input SW9,		//line-in mute: 0-enable mute, 1-disable mute
  input SW10,		//mic-mute: 0-enable mute, 1-disable mute
  
  output m_clk, b_clk, dac_lr_clk, adc_lr_clk, //control wires for the digital interface 
  output dacdat,  //data input to DAC
  input adcdat,  //data output from ADC
  
  output LED14,LED15,LED16
  
);

wire [31:0] dac_data_in;
wire [31:0] adc_data_out;
wire load_done_tick;

wire [7:0] humidity;
wire effect_delay,effect_dist,effect_iir;

assign effect_delay = SW13 ? SW16 : (humidity > 8'd70);
assign effect_dist = SW13 ? SW15  : (humidity < 8'd40);
assign effect_iir = SW13 ? SW14   : (humidity <= 8'd70 && humidity >=8'd40);

wire wr_dac, rd_dac, wr_adc, rd_adc;
wire empty_dac, empty_adc, full_dac, full_adc;
wire [31:0] w_data_adc, w_data_dac, r_data_adc, r_data_dac;
//wire [3:0] fifo_counter_dac,fifo_counter_adc;

assign wr_adc = load_done_tick;
assign rd_dac = load_done_tick;

sensor_ctrl sensor(
             .clk(clk),
             .SEG0(SEG0),
             .SEG1(SEG1),
             .SEG2(SEG2),
             .SEG3(SEG3),
             .Data(Data),
             .rst(rst),
             .humidity(humidity)
            );

fifo dac_fifo(
  .clk     (clk         ) ,
  .rst     (rst         ) ,
  .wr      (wr_dac      ) ,
  .rd      (rd_dac      ) ,
  .w_data  (w_data_dac  ) ,
  .r_data  (r_data_dac  ) ,
  .empty   (empty_dac   ) ,
  .full    (full_dac    ) 
);

fifo adc_fifo(
  .clk     (clk         ) ,
  .rst     (rst         ) ,
  .wr      (wr_adc      ) ,
  .rd      (rd_adc      ) ,
  .w_data  (w_data_adc  ) ,
  .r_data  (r_data_adc  ) ,
  .empty   (empty_adc   ) ,
  .full    (full_adc    ) 
);

data_processor data_processor_inst(
  .clk  (clk),
  .rst  (rst),
  .empty_adc  (empty_adc),
  .full_dac   (full_dac),
  .effect_dist (effect_dist),
  .effect_delay (effect_delay),
  .effect_iir (effect_iir),
  .rd_adc  (rd_adc),
  .wr_dac  (wr_dac),
  .adc_fifo_out (r_data_adc),
  .dac_fifo_in  (w_data_dac)
);

reg_config reg_config_inst(.*);

adc_dac adc_dac_inst(.*);

assign dac_data_in = r_data_dac;
assign w_data_adc = adc_data_out;

assign LED14 =  (humidity > 8'd70);
assign LED15 =  (humidity < 8'd40);
assign LED16 =  (humidity <= 8'd70 && humidity >=8'd40);

endmodule
