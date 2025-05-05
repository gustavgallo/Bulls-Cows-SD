module Bulls&Cows (
    input clock, //clock
    input reset, // recomeça o jogo 
    input confirma, // botao pra confirmar
    input logic[15:0] SW,    // switches
    output logic[15:0] LED,  // leds dos resultados
    output logic [7:0] an, //aqui seleciona qual dos 8 displays q vai escreve
    output logic [6:0] digit // aqui é o numero q vai escreve, tipo 1100000, bagulho assim, o DP ignora

);

typedef enum logic [1:0] {
    READSECRET1,
    READSECRET2,
    GUESS,
    PRINT,
    RESULT
} state_t;

state_t EA, PE;

//definidor dos estados
always_ff @(posedge clock or posedge reset) begin
    if(reset)begin
    EA <= READSECRET1;
    end else
    EA<= PE;
end


//FSM pra definir qual estado ir depois
always_comb begin
   case(EA)

endcase
end

logic [15:0] P1SECRET;
logic [15:0] P2SECRET;
logic [15:0] GUESS;
//verificadores
logic [3:0] v1,v2,v3,v4;
logic enable; // eu amo enable
logic switchguess; // se o guess é do player 1 ou do player 2

// bloco principal
always @(posedge clock or posedge reset) begin
    if(reset)begin
        P1SECRET <= 0;
        P2SECRET <= 0;  
        GUESS <= 0;
        enable <= 0;

    else begin
        case(EA)
        READSECRET1:begin

        enable <= 0;
        P1SECRET <= SW;
        v4 <= SW[15:12];
        v3 <= SW[11:8];
        v2 <= SW[7:4];
        v1 <= SW[3:0];
        //todos digitos tem que ser singulares, se forem iguais ele fica até receber diferentes
        if(v4!=v3 && v4!=v2 && v4 != v1 && v3!= v1 && v3!=v2 && v2!= v1)enable <= 1;
        
        end
        READSECRET2: begin
        enable <= 0;
        P2SECRET <= SW;
        v4 <= SW[15:12];
        v3 <= SW[11:8];
        v2 <= SW[7:4];
        v1 <= SW[3:0];
        //todos digitos tem que ser singulares, se forem iguais ele fica até receber diferentes
        if(v4!=v3 && v4!=v2 && v4 != v1 && v3!= v1 && v3!=v2 && v2!= v1)enable <= 1;
        end
        
        GUESS: begin
            if(switchguess == 0) begin // guess do player 1
                enable <= 0;
                GUESS <= SW;
                v4 <= SW[15:12];
                v3 <= SW[11:8];
                v2 <= SW[7:4];
                v1 <= SW[3:0];
                if(v4!=v3 && v4!=v2 && v4 != v1 && v3!= v1 && v3!=v2 && v2!= v1)enable <= 1;
                if(enable == 1) 
                    


        end
        end


        endcase
        end
        
       
    end
                
    end



end







endmodule