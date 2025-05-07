module Bulls&Cows (

    input clock, //clock

    input reset, // recomeça o jogo 

    input confirma, // botao pra confirmar

    input logic[15:0] SW,    // switches

    output logic[15:0] LED,  // leds dos resultados

    output logic [7:0] an, //aqui seleciona qual dos 8 displays q vai escreve

    output logic [6:0] digit // aqui é o numero q vai escreve, tipo 1100000, bagulho assim, o DP ignora

);

localparam NULL = 4'b1111;

typedef enum logic [2:0] { // tava 1:0, coloquei 2:0 pra caber os estados

    P1SETUP,

    P2SETUP,

    P1GUESS,

    P2GUESS,

    CHECK_IF_EQUAL,

    RESULT,

    PRINT,

    WIN

} state_t;


state_t EA, PE, UE;



//definidor dos estados

always_ff @(posedge clock or posedge reset) begin

    if(reset)begin

    EA <= P1SETUP;

    end else

    EA <= PE;

end



logic [15:0] P1SECRET;

logic [15:0] P2SECRET;

logic [15:0] P1GUESS_reg;

logic [15:0] P2GUESS_reg;

logic is_diff = 0;

logic enable_switch_players; // eu amo enable

logic enable_guess_for_check; // eu amo enable

logic switchguess; // se o guess é do player 1 ou do player 2

logic verifica;

logic [2:0] bulls;

logic [2:0] cows;





//FSM pra definir qual estado ir depois

always_comb begin

   case(EA)
    
    P1SETUP: 
    begin
        UE = P1SETUP;
        PE = CHECK_IF_EQUAL;
    end

    P2SETUP: 
    begin 
        UE = P2SETUP;
        PE = CHECK_IF_EQUAL;
    end
    P1GUESS:
    begin
        UE = P1GUESS;
        PE = CHECK_IF_EQUAL;
    end
    P2GUESS:
    begin
        UE = P2GUESS;
        PE = CHECK_IF_EQUAL;
    end


    CHECK_IF_EQUAL: 
    begin
        if(is_diff) begin
            if(UE == P1SETUP) begin PE = P2SETUP end
            if(UE == P2SETUP) begin PE = P1GUESS end
            if(UE == P1GUESS) begin PE = P2GUESS end
            if(UE == P2GUESS) begin PE = P1GUESS end
        end else begin
            PE = UE;
        end
    end
    READSECRET2:
    begin 
        if(enable_switch_players) begin PE = GUESS end
        else begin 
            enable_switch_players = 0;
            PE = READSECRET2; 
        end
    end
    GUESS:
    begin 
        if(enable_guess_for_check) 
        begin 
            PE = RESULT;
        end else begin
            PE = GUESS;
        end
    end
    RESULT:
    begin 

    end
    PRINT:
    begin 

    end
    WIN:
    begin 

    end

endcase

end

always_comb begin
        num1 < (SW[0], SW[1], SW[2], SW[3]);
        num2 < (SW[4], SW[5], SW[6], SW[7]);
        num3 < (SW[8], SW[9], SW[10], SW[11]);
        num4 < (SW[12], SW[13], SW[14], SW[15]);
end

// bloco principal

always @(posedge clock or posedge reset) begin

    if(reset)begin

        P1SECRET <= 0;

        P2SECRET <= 0;  

        GUESS <= 0;

        enable_guess_for_check <= 0;

        enable_switch_players <= 0;

        bulls <= 0;

        cows <= 0;

        switchguess <= 0;

    end    

    else begin // mudei, tava dentro do case por algum motivo

        case(EA)

            P1SETUP: // precisa dos v1, v2... ? seria só para o if do enable? se for talvez seja melhor usar SW como matriz mesmo

            begin

                P1SECRET <= SW;

            end

            P2SETUP: // precisa dos v1, v2... ? seria só para o if do enable? se for talvez seja melhor usar SW como matriz mesmo

            begin

                P2SECRET <= SW;

            end

            CHECK_IF_EQUAL:
            begin

                if( num4 != num3 && num4 != num2 && num4 != num1 && num3 != num2 && num3 != num1 && num2 != num1 ) begin
                    is_diff <= 1;
                end else begin
                    is_diff <= 0;
                end

            end



            P1GUESS: // aqui seria preciso os v, mas podemos mudar caso seja necessario

            begin
                P1GUESS_reg <= SW;
            end

            P2GUESS: // aqui seria preciso os v, mas podemos mudar caso seja necessario

            begin
                P2GUESS_reg <= SW;
            end

            RESULT:

            begin

                    verifica <= 0;

                     // v4 → posição 0

                     //vai verificar se há bulls e/ou cows, se houver vai colocar NULL no local que houve essa incidencia e não fazer mais nada no clock

                    // após isso vai voltar para cá e rever zerar o verifica e olhar de novo

                     // tem que zerar o verifica e fazer tudo em clocks separados para não ficar sempre cows <= cows + 1 (0 <= 0 + 1)

                    if (v4 == P1SECRET[15:12] && verifica == 0) begin

                        bulls <= bulls + 1;

                        v4 <= NULL; //agora NULL é um localparam para 4'b1111, ou seja, v4 <= 4'b1111, oq não pode ocorrer nos outros

                        verifica <= 1;

                    end else if (

                        (v4 == P1SECRET[11:8] || v4 == P1SECRET[7:4] || v4 == P1SECRET[3:0]) && verifica == 0) begin

                        cows <= cows + 1;

                        v4 <= NULL;

                        verifica <= 1;

                    end

                    // v3 → posição 1

                    if (v3 == P1SECRET[11:8] && verifica == 0) begin

                        bulls <= bulls + 1;

                        v3 <= NULL;

                        verifica <= 1;

                    end else if (

                        (v3 == P1SECRET[15:12] || v3 == P1SECRET[7:4] || v3 == P1SECRET[3:0]) && verifica == 0) begin

                        cows <= cows + 1;

                        v3 <= NULL;

                        verifica <= 1;

                    end



                            // v2 → posição 2

                            if (v2 == P1SECRET[7:4] && verifica == 0) begin

                                bulls <= bulls + 1;

                                v2 <= NULL;

                                verifica <= 1;

                            end else if (

                                (v2 == P1SECRET[15:12] || v2 == P1SECRET[11:8] || v2 == P1SECRET[3:0]) && verifica == 0) begin

                                cows <= cows + 1;

                                v2 <= NULL;

                                verifica <= 1;

                            end



                            // v1 → posição 3

                            if (v1 == P1SECRET[3:0] && verifica == 0) begin

                                bulls <= bulls + 1;

                                v1 <= NULL;

                                verifica <= 1;

                            end else if ((v1 == P1SECRET[15:12] || v1 == P1SECRET[11:8] || v1 == P1SECRET[7:4]) && verifica == 0 ) begin

                                cows <= cows + 1;

                                v1 <= NULL;

                                verifica <= 1;

                            end

                        switchguess <= ~switchguess;

                        enable_guess_for_check <= 0; 

            end // end do result
                PRINT:
                begin

                end
                WIN:
                begin

                end

        endcase

        end // end do else (reset)

    end // end do always

endmodule