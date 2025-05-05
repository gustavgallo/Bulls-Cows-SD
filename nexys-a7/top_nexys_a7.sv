// device: xc7a100tcsg324-1
module top_nexys_a7 (
    input clock, //clock
    input reset, // recomeça o jogo 
    input confirma, // botao pra confirmar
    input logic[15:0] SW,    // switches
    output logic[15:0] LED,  // leds dos resultado
    output logic [7:0] an, //aqui seleciona qual dos 8 displays q vai escreve
    output logic [6:0] digit // aqui é o numero q vai escreve, tipo 1100000, bagulho assim, o DP ignora
);




 
endmodule