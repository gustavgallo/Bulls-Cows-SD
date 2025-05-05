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
logic verifica;
logic [2:0] bulls;
logic [2:0] cows;


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
                if(enable)begin
                    verifica <= 0;
                    // v4 → posição 0
                    //vai verificar se há bulls e/ou cows, se houver vai colocar null no local que houve essa incidencia e não fazer mais nada no clock
                    // após isso vai voltar para cá e rever zerar o verifica e olhar de novo
                    // tem que zerar o verifica e fazer tudo em clocks separados para não ficar sempre cows <= cows + 1 (0 <= 0 + 1)
                if (v4 == P1SECRET[15:12] && verifica == 0) begin
                    bulls <= bulls + 1;
                    v4 <= null;
                    verifica <= 1;
                end else if (
                    (v4 == P1SECRET[11:8] || v4 == P1SECRET[7:4] || v4 == P1SECRET[3:0]) && verifica == 0) begin
                    cows <= cows + 1;
                    v4 <= null;
                    verifica <= 1;
                end
                // v3 → posição 1
                if (v3 == P1SECRET[11:8] && verifica == 0) begin
                    bulls <= bulls + 1;
                    v3 <= null;
                    verifica <= 1;
                end else if (
                    (v3 == P1SECRET[15:12] || v3 == P1SECRET[7:4] || v3 == P1SECRET[3:0]) && verifica == 0) begin
                    cows <= cows + 1;
                    v3 <= null;
                    verifica <= 1;
                end

                // v2 → posição 2
                if (v2 == P1SECRET[7:4] && verifica == 0) begin
                    bulls <= bulls + 1;
                    v2 <= null;
                    verifica <= 1;
                end else if (
                    (v2 == P1SECRET[15:12] || v2 == P1SECRET[11:8] || v2 == P1SECRET[3:0]) && verifica == 0) begin
                    cows <= cows + 1;
                    v2 <= null;
                    verifica <= 1;
                end

                // v1 → posição 3
                if (v1 == P1SECRET[3:0] && verifica == 0) begin
                    bulls <= bulls + 1;
                    v1 <= null;
                    verifica <= 1;
                end else if (
                    (v1 == P1SECRET[15:12] || v1 == P1SECRET[11:8] || v1 == P1SECRET[7:4]) && verifica == 0) begin
                    cows <= cows + 1;
                    v1 <= null;
                    verifica <= 1;
                end


        end
        end


        endcase
        end
        
       
    end
                
    end

    always_comb begin
    logic [3:0] g1, g2, g3, g4;
    logic [3:0] s1, s2, s3, s4;

    bulls = 0;
    cows = 0;

    g4 = GUESS[15:12];
    g3 = GUESS[11:8];
    g2 = GUESS[7:4];
    g1 = GUESS[3:0];

    if (switchguess == 0) begin
        s4 = P2SECRET[15:12];
        s3 = P2SECRET[11:8];
        s2 = P2SECRET[7:4];
        s1 = P2SECRET[3:0];
    end else begin
        s4 = P1SECRET[15:12];
        s3 = P1SECRET[11:8];
        s2 = P1SECRET[7:4];
        s1 = P1SECRET[3:0];
    end

    // BULLS
    if (g1 == s1) bulls = bulls + 1;
    if (g2 == s2) bulls = bulls + 1;
    if (g3 == s3) bulls = bulls + 1;
    if (g4 == s4) bulls = bulls + 1;

    // COWS
    if (g1 == s2 || g1 == s3 || g1 == s4) cows = cows + 1;
    if (g2 == s1 || g2 == s3 || g2 == s4) cows = cows + 1;
    if (g3 == s1 || g3 == s2 || g3 == s4) cows = cows + 1;
    if (g4 == s1 || g4 == s2 || g4 == s3) cows = cows + 1;
end









endmodule