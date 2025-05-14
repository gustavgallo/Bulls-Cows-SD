module BullsAndCows (

    input clock, //clock

    input reset, // recomeça o jogo 

    input confirma, // botao pra confirmar

    input logic[15:0] SW,    // switches

    output logic[15:0] led,  // leds dos resultados

    output logic[6:0] d1, d2, d3, d4, d5, d6, d7, d8; // aqui seleciona oq vai escrever em cada display
    

);

localparam NULL = 4'b1111;

typedef enum logic [2:0] { // tava 1:0, coloquei 2:0 pra caber os estados
    
    P1SETUP,

    P2SETUP,

    P1GUESS,

    P2GUESS,

    CHECK_IF_EQUAL,

    RESULT,

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

logic enable_guess_for_check = 0;

logic switchguess; // se o guess é do player 1 ou do player 2

logic verifica;

logic [2:0] bulls;

logic [2:0] cows;


//FSM pra definir qual estado ir depois

always_comb begin  // <= em comb?

   case(EA)
    
    P1SETUP: 
    begin
       
    end

    P2SETUP: 
    begin 
      
    end
   


    CHECK_IF_EQUAL: 
    begin
        if(is_diff) begin
            if(UE == P1SETUP) begin PE <= P2SETUP end
            if(UE == P2SETUP) begin PE <= P1GUESS end
            if(UE == P1GUESS) begin PE <= RESULT end
            if(UE == P2GUESS) begin PE <= RESULT end
        end else begin
            PE <= UE;
        end
    end
    
    P1GUESS:
    begin 
        if(enable_guess_for_check) 
        begin 
            switchguess <= 0;
            PE <= CHECK_IF_EQUAL; UE <= P1GUESS;
        end else begin
            PE <= P1GUESS; UE <= P1GUESS;
        end

    end
        P2GUESS:
    begin 
        if(enable_guess_for_check) 
        begin 
            switchguess <= 1;
            PE <= CHECK_IF_EQUAL; UE <= P2GUESS;
        end else begin
            PE <= P2GUESS; UE <= P2GUESS;
        end
        
    end
    RESULT:
    begin 
        if( posedge confirma) begin
        if(bulls == 4) begin
            PE <= WIN; UE <= RESULT;
        end else if (switchguess && verifica == 4) begin
            PE <= PRINT_BC; UE <= P1GUESS;
        end else if (!switchguess && verifica == 4) begin
            PE <= P1GUESS; UE <= P2GUESS;
        end
        end else PE <= RESULT;
    end

    PRINT_BC:
    begin
        
    end
    
    WIN:
    begin 
        if(posedge confirma) begin
            PE = P1SETUP; UE = P1SETUP;
        end else begin
            PE = WIN; UE = WIN;
        end
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

        bulls <= 0;

        cows <= 0;

        switchguess <= 0;

    end    

    else begin // mudei, tava dentro do case por algum motivo

        case(EA)

            P1SETUP: 
            begin
       
                P1SECRET <= SW;

            end

            P2SETUP: 
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



            P1GUESS: 

            begin
                P1GUESS_reg <= SW;
                cows <= 0;;
                bulls <= 0;
                verifica <= 0;
            end

            P2GUESS: 

            begin
                P2GUESS_reg <= SW;
                bulls <= 0;
                cows <=0;
                verifica <= 0;
            end

            RESULT:

            begin


                     // num4 → posição 0

                     //vai verificar se há bulls e/ou cows, se houver vai colocar NULL no local que houve essa incidencia e não fazer mais nada no clock

                    // após isso vai voltar para cá e rever zerar o verifica e olhar de novo

                     // tem que zerar o verifica e fazer tudo em clocks separados para não ficar sempre cows <= cows + 1 (0 <= 0 + 1)

                    if (num4 == P1SECRET[15:12] && verifica == 0) begin

                        bulls <= bulls + 1;

                        num4 <= NULL; //agora NULL é um localparam para 4'b1111, ou seja, num4 <= 4'b1111, oq não pode ocorrer nos outros


                    end else if (

                        (num4 == P1SECRET[11:8] || num4 == P1SECRET[7:4] || num4 == P1SECRET[3:0]) && verifica == 0) begin

                        cows <= cows + 1;

                        num4 <= NULL;

                    end

                    // num3 → posição 1

                    if (num3 == P1SECRET[11:8] && verifica == 1) begin

                        bulls <= bulls + 1;

                        num3 <= NULL;


                    end else if (

                        (num3 == P1SECRET[15:12] || num3 == P1SECRET[7:4] || num3 == P1SECRET[3:0]) && verifica == 1) begin

                        cows <= cows + 1;

                        num3 <= NULL;

                    end

                           // num2 → posição 2
                            if (num2 == P1SECRET[7:4] && verifica == 2) begin

                                bulls <= bulls + 1;

                                num2 <= NULL;


                            end else if (

                                (num2 == P1SECRET[15:12] || num2 == P1SECRET[11:8] || num2 == P1SECRET[3:0]) && verifica == 2) begin

                                cows <= cows + 1;

                                num2 <= NULL;


                            end



                            // num1 → posição 3

                            if (num1 == P1SECRET[3:0] && verifica == 3) begin

                                bulls <= bulls + 1;

                                num1 <= NULL;


                            end else if ((num1 == P1SECRET[15:12] || num1 == P1SECRET[11:8] || num1 == P1SECRET[7:4]) && verifica == 3 ) begin

                                cows <= cows + 1;

                                num1 <= NULL;

                            end

                                verifica <= verifica + 1;
                                
            end // end do result
               
                
                WIN:
                begin

                end

        endcase

        end // end do else (reset)

    end // end do always

    // aqui é o display, é pra funcionar, pois vai atualizar tds digitos assim que mudar o estado e o clock bater
    always @(posedge clock) begin
        case (EA)
            P1SETUP: begin
                d1 <= {1 + 4'h5 + 1};    // 'J'
                d2 <= {1 + 4'h1 + 1};    // '1'
                d3 <= {1 + 4'h10 + 1};   // espaço
                d4 <= {1 + 4'h6 + 1};    // 'S'
                d5 <= {1 + 4'h7 + 1};    // 'E'
                d6 <= {1 + 4'h8 + 1};    // 'T'
                d7 <= {1 + 4'h9 + 1};    // 'U'
                d8 <= {1 + 4'hA + 1};    // 'P'
            end

            P2SETUP: begin
                d1 <= {1 + 4'h5 + 1};    // 'J'
                d2 <= {1 + 4'h2 + 1};    // '2'
                d3 <= {1 + 4'h10 + 1};   // espaço
                d4 <= {1 + 4'h6 + 1};    // 'S'
                d5 <= {1 + 4'h7 + 1};    // 'E'
                d6 <= {1 + 4'h8 + 1};    // 'T'
                d7 <= {1 + 4'h9 + 1};    // 'U'
                d8 <= {1 + 4'hA + 1};    // 'P'
            end

            P1GUESS: begin
                d1 <= {1 + 4'h5 + 1};    // 'J'
                d2 <= {1 + 4'h1 + 1};    // '1'
                d3 <= {1 + 4'h10 + 1};   // espaço
                d4 <= {1 + 4'hF + 1};    // 'G'
                d5 <= {1 + 4'h9 + 1};    // 'U'
                d6 <= {1 + 4'h7 + 1};    // 'E'
                d7 <= {1 + 4'h6 + 1};    // 'S'
                d8 <= {1 + 4'h6 + 1};    // 'S'
            end

            P2GUESS: begin
                d1 <= {1 + 4'h5 + 1};    // 'J'
                d2 <= {1 + 4'h2 + 1};    // '2'
                d3 <= {1 + 4'h10 + 1};   // espaço
                d4 <= {1 + 4'hF + 1};    // 'G'
                d5 <= {1 + 4'h9 + 1};    // 'U'
                d6 <= {1 + 4'h7 + 1};    // 'E'
                d7 <= {1 + 4'h6 + 1};    // 'S'
                d8 <= {1 + 4'h6 + 1};    // 'S'
            end

            RESULT: begin
                d1 <= {1 + num_cows + 1};   // número de vacas (C)
                d2 <= {1 + 4'h10 + 1};      // espaço
                d3 <= {1 + 4'hC + 1};       // 'C'
                d4 <= {1 + 4'h10 + 1};      // espaço
                d5 <= {1 + num_bulls + 1};  // número de touros (B)
                d6 <= {1 + 4'hB + 1};       // 'B'
                d7 <= {1 + 4'h10 + 1};      // espaço
                d8 <= {1 + 4'h10 + 1};      // espaço
            end

            WIN: begin
                d1 <= {1 + 4'hB + 1};   // 'B'
                d2 <= {1 + 4'h9 + 1};   // 'U'
                d3 <= {1 + 4'hD + 1};   // 'L'
                d4 <= {1 + 4'hD + 1};   // 'L'
                d5 <= {1 + 4'h6 + 1};   // 'S'
                d6 <= {1 + 4'h7 + 1};   // 'E'
                d7 <= {1 + 4'hE + 1};   // 'Y'
                d8 <= {1 + 4'h7 + 1};   // 'E'
            end

            default: begin
                d1 <= {1 + 4'h10 + 1}; // espaço
                d2 <= {1 + 4'h10 + 1}; // espaço
                d3 <= {1 + 4'h10 + 1}; // espaço
                d4 <= {1 + 4'h10 + 1}; // espaço
                d5 <= {1 + 4'h10 + 1}; // espaço
                d6 <= {1 + 4'h10 + 1}; // espaço
                d7 <= {1 + 4'h10 + 1}; // espaço
                d8 <= {1 + 4'h10 + 1}; // espaço
            end
        endcase
    end

endmodule