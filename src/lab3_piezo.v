`timescale 1ns/1ps

module lab3_piezo #(
  parameter integer CLK_HZ = 50_000_000,
  parameter integer TONE_HZ = 294
)(
  input wire clk_50mhz,
  input wire rst_p,
  output reg piezo
);

  localparam integer HALF_PERIOD = CLK_HZ / (2 * TONE_HZ);
  localparam integer COUNT_WIDTH = (HALF_PERIOD < 2) ? 1 : $clog2(HALF_PERIOD);

  reg [COUNT_WIDTH-1:0] count;

  // 50 MHz 클록 분주를 통한 50% 듀티 사각파 생성
  always @(posedge clk_50mhz or posedge rst_p) begin
    if (rst_p) begin
      count <= {COUNT_WIDTH{1'b0}};
      piezo <= 1'b0;
    end else if (count == HALF_PERIOD - 1) begin
      count <= {COUNT_WIDTH{1'b0}};
      piezo <= ~piezo;
    end else begin
      count <= count + 1'b1;
    end
  end

endmodule