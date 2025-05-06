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

    READSECRET1,

    READSECRET2,

    GUESS,

    RESULT,

    PRINT,

    WIN

} state_t;



state_t EA, PE;



//definidor dos estados

always_ff @(posedge clock or posedge reset) begin

    if(reset)begin

    EA <= READSECRET1;

    end else

    EA <= PE;

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





//FSM pra definir qual estado ir depois

always_comb begin

   case(EA)



endcase

end



task automatic getSwitches(   // taskizinha para pegar os switches, pega o SW, coloca no registrador que tu mandar e separa nos Vx,     define se são iguais tambem, depois tem que ver como vamos fazer o enable (melhor trocar o nome pra ficar mais explicito o contexto)

    input logic [15:0] SW,

    output logic [15:0] VAR_REG,

    output logic [3:0] v1, v2, v3, v4,

    output logic enable

);

    VAR_REG = SW;

    v4 = SW[15:12];

    v3 = SW[11:8];

    v2 = SW[7:4];

    v1 = SW[3:0];

    enable = (v4!=v3 && v4!=v2 && v4 != v1 && v3!= v1 && v3!=v2 && v2!= v1) ? 1 : 0;

endtask



// bloco principal

always @(posedge clock or posedge reset) begin

    if(reset)begin

        P1SECRET <= 0;

        P2SECRET <= 0;  

        GUESS <= 0;

        enable <= 0;

        bulls <= 0;

        cows <= 0;

        switchguess <= 0;

    end    

    else begin

        case(EA)

            enable <= 0; // não sei se rola deixar aqui, por enquanto não vou mudar



            READSECRET1: // precisa dos v1, v2... ? seria só para o if do enable? se for talvez seja melhor usar SW como matriz mesmo

            begin

                getSwitches(SW, P1SECRET, v1, v2, v3, v4, enable);

            end

            

            READSECRET2: // precisa dos v1, v2... ? seria só para o if do enable? se for talvez seja melhor usar SW como matriz mesmo

            begin

                getSwitches(SW, P1SECRET, v1, v2, v3, v4, enable);

            end

        

            GUESS: // aqui seria preciso os v, mas podemos mudar caso seja necessario

            begin

                if(switchguess == 0) // falta o else, não sei se é uma boa fazer assim
                begin // guess do player 1

                    enable <= 0; // não sei pq ta aqui, decidi não mudar por enquanto

                   getSwitches(SW, GUESS, v1, v2, v3, v4, enable);

                end
            end

            RESULT:

            begin

                if(enable)

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

                        end

                        else begin 

                            switchguess <= ~switchguess;

                            enable <= 0; 

                        end

            end // end do result

        endcase

        end // end do else (reset)

    end // end do always

endmodule