// device: xc7a100tcsg324-1
module top_nexys_a7 (
    input clock, //clock
    //input reset, // recomeça o jogo 
    input confirma, // botao pra confirmar
    //input logic[15:0] SW,    // switches
    output logic[15:0] LED,  // leds dos resultado
    output logic [7:0] AN, //aqui seleciona qual dos 8 displays q vai escreve
    output logic [7:0] DIGIT // aqui é o numero q vai escreve, tipo 1100000, bagulho assim, o DP ignora
);
logic[6:0] d1, d2, d3, d4, d5, d6, d7, d8;
dspl_drv_NexysA7 display(
    .clock(clock),
    .reset(reset),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .d4(d4),
    .d5(d5),
    .d6(d6),
    .d7(d7),
    .d8(d8),
    .an(AN),
    .dec_ddp(DIGIT)
);
// instancia o jogo bulls and cows
BullsAndCows game(
    .clock(clock),
    .reset(reset),
    .confirma(confirma),
    .led(LED),
    .SW(SW),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .d4(d4),
    .d5(d5),
    .d6(d6),
    .d7(d7),
    .d8(d8)
);


 
endmodule