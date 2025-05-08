// device: xc7a100tcsg324-1
module top_nexys_a7 (
    input clock, //clock
    //input reset, // recomeça o jogo 
    input confirma, // botao pra confirmar
    //input logic[15:0] SW,    // switches
    output logic[15:0] LED,  // leds dos resultado
    output logic [7:0] an, //aqui seleciona qual dos 8 displays q vai escreve
    output logic [6:0] digit // aqui é o numero q vai escreve, tipo 1100000, bagulho assim, o DP ignora
);

logic [6:0] escrita [7:0];
assign escrita [0] = 7'1111110;
assign escrita [1] = 7'1111101;
assign escrita [2] = 7'1111011;
assign escrita [3] = 7'1110111;
assign escrita [4] = 7'1101111;
assign escrita [5] = 7'1011111;
assign escrita [6] = 7'0111111;
assign escrita [7] = 7'0000000;

logic [3:0] count;


always(posedge clock, posedge confirma)begin
if(confirma)
begin 
    count <= 0;
end
else begin
an[count] <= 0;
digit <= escrita[count];


end

LED[count] = 0;





end


 
endmodule