
`timescale 1ns/1ps

module tb_bulls_and_cows;

  logic clk = 0;
  logic rst = 0;
  logic [3:0] sw;
  logic [3:0] btn;
  logic [6:0] seg;
  logic [3:0] an;
  logic dp;

  // Clock 100 MHz
  always #5 clk = ~clk;

  top_nexys_a7 dut (
    .clk(clk),
    .rst(rst),
    .sw(sw),
    .btn(btn),
    .seg(seg),
    .an(an),
    .dp(dp)
  );

  task press_btn(input [3:0] b);
    begin
      btn = b;
      #20;
      btn = 4'b0000;
    end
  endtask

  initial begin
    rst = 1;
    sw = 4'd0;
    btn = 4'd0;
    #50;

    rst = 0;

    // Digita o número 1234 (exemplo) com btn[0] como "enter"
    sw = 4'd1; press_btn(4'b0001); // digita 1
    sw = 4'd2; press_btn(4'b0001); // digita 2
    sw = 4'd3; press_btn(4'b0001); // digita 3
    sw = 4'd4; press_btn(4'b0001); // digita 4

    // Envia o palpite com btn[1]
    press_btn(4'b0010);

    // Aguarda atualização
    #200;

    // Reinicia jogo
    press_btn(4'b1000); // digamos que btn[3] seja reset do jogo

    #100;

    $finish;
  end

endmodule
