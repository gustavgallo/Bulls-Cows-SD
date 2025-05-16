module BullsAndCows (

    input clock, //clock
    input reset, // recomeça o jogo 
    input confirma_rising, // botao pra confirmar
    input logic[15:0] SW,    // switches
    output logic[15:0] led,  // leds dos resultados, deixei comentado por enquanto
    output logic[6:0] d1, d2, d3, d4, d5, d6, d7, d8 // aqui seleciona oq vai escrever em cada display
);

localparam NULL = 4'b1111;
assign is_diff = (num1 != num2 && num1 != num3 && num1 != num4 && num2 != num3 && num2 != num4 && num3 != num4) ? 1 : 0;

typedef enum logic [2:0] { // tava 1:0, coloquei 2:0 pra caber os estados
    
    P1SETUP,

    P2SETUP,

    P1GUESS,

    P2GUESS,

    CHECK_IF_EQUAL,

    RESULT,

    PRINT_BC,

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

//logic [15:0] //P1GUESS_reg;

//logic [15:0] //P2GUESS_reg;


logic switchguess = 0; // se o guess é do player 1 ou do player 2

logic [2:0]verifica = 0;

logic [2:0] bulls = 0;

logic [2:0] cows = 0;

logic check_done = 0; // se já verificou se os numeros são diferentes ou não


//FSM pra definir qual estado ir depois

always @(posedge clock) begin  // botei em clock

   case(EA)
    
    P1SETUP: 
    begin
        if(confirma_rising) begin
            PE <= CHECK_IF_EQUAL; UE <= P1SETUP;
        end else begin
            PE <= P1SETUP; UE <= P1SETUP;
        end
    end

    P2SETUP: 
    begin 
        if(confirma_rising) begin
            PE <= CHECK_IF_EQUAL; UE <= P2SETUP;
        end else begin
            PE <= P2SETUP; UE <= P2SETUP;
        end
    end
   

    CHECK_IF_EQUAL: 
    begin
        if(is_diff) begin
                if(UE == P1SETUP) begin PE <= P2SETUP; end
        else    if(UE == P2SETUP) begin PE <= P1GUESS; end
        else    if(UE == P1GUESS) begin PE <= RESULT; end
        else    if(UE == P2GUESS) begin PE <= RESULT; end
        end else if(!is_diff)begin
            PE <= UE;
        end 
    end
    
    P1GUESS:
    begin 
        if(confirma_rising) 
        begin 
            switchguess <= 0;
            PE <= CHECK_IF_EQUAL; UE <= P1GUESS;
        end else begin
            PE <= P1GUESS; UE <= P1GUESS;
        end

    end
        P2GUESS:
    begin 
        if(confirma_rising) 
        begin 
            switchguess <= 1;
            PE <= CHECK_IF_EQUAL; UE <= P2GUESS;
        end else begin
            PE <= P2GUESS; UE <= P2GUESS;
        end
        
    end
    RESULT:
    begin 
        if( confirma_rising ) begin
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
        if(confirma_rising ) begin
            PE = P1SETUP; UE = P1SETUP;
        end else begin
            PE = WIN; UE = WIN;
        end
    end

endcase

end

logic [3:0] num1, num2, num3, num4;

// bloco principal

always @(posedge clock or posedge reset) begin

    if(reset)begin

        P1SECRET <= 0;

        P2SECRET <= 0;  

        //P1GUESS_reg <= 0;
        
        //P2GUESS_reg <= 0;

        bulls <= 0;

        cows <= 0;

        switchguess <= 0;

        verifica <= 0;

        check_done <=0;

    end    

    else begin // mudei, tava dentro do case por algum motivo

        case(EA)

            P1SETUP: 
            begin
                num1 <= SW[3:0];
                num2 <= SW[7:4];
                num3 <= SW[11:8];
                num4 <= SW[15:12];
                P1SECRET <= SW;

            end

            P2SETUP: 
            begin
                num1 <= SW[3:0];
                num2 <= SW[7:4];
                num3 <= SW[11:8];
                num4 <= SW[15:12];
                P2SECRET <= SW;

            end

            CHECK_IF_EQUAL:
            begin

                
            end



            P1GUESS: 

            begin
                num1 <= SW[3:0];
                num2 <= SW[7:4];
                num3 <= SW[11:8];
                num4 <= SW[15:12];
                //P1GUESS_reg <= SW;
                cows <= 0;;
                bulls <= 0;
                verifica <= 0;
            end

            P2GUESS: 

            begin
                num1 <= SW[3:0];
                num2 <= SW[7:4];
                num3 <= SW[11:8];
                num4 <= SW[15:12];
                //P2GUESS_reg <= SW;
                bulls <= 0;
                cows <=0;
                verifica <= 0;
            end

            RESULT: // num4 → posição 0

                     //vai verificar se há bulls e/ou cows, se houver vai colocar NULL no local que houve essa incidencia e não fazer mais nada no clock

                    // após isso vai voltar para cá e rever zerar o verifica e olhar de novo

                     // tem que zerar o verifica e fazer tudo em clocks separados para não ficar sempre cows <= cows + 1 (0 <= 0 + 1)

            begin
                case(verifica) // não testei na fpga, mudei pra ficar mais facil de ler, pode ter algum erro de sintaxe, logica acho dificil ter
                    0: begin
                        if (num4 == P1SECRET[15:12]) begin

                        bulls <= bulls + 1;

                        num4 <= NULL; //agora NULL é um localparam para 4'b1111, ou seja, num4 <= 4'b1111, oq não pode ocorrer nos outros

                        end else if (

                        (num4 == P1SECRET[11:8] || num4 == P1SECRET[7:4] || num4 == P1SECRET[3:0])) begin

                        cows <= cows + 1;
                        num4 <= NULL;
                        end
                        verifica <= verifica + 1;
                    end
                    1: begin
                        if (num3 == P1SECRET[11:8]) begin

                            bulls <= bulls + 1;
                            num3 <= NULL;

                        end else if (

                            (num3 == P1SECRET[15:12] || num3 == P1SECRET[7:4] || num3 == P1SECRET[3:0])) begin
                            cows <= cows + 1;
                            num3 <= NULL;
                        end
                        verifica <= verifica + 1;
                    end
                    2: begin
                        if (num2 == P1SECRET[7:4]) begin
                                bulls <= bulls + 1;
                                num2 <= NULL;

                            end else if (

                                (num2 == P1SECRET[15:12] || num2 == P1SECRET[11:8] || num2 == P1SECRET[3:0])) begin
                                cows <= cows + 1;
                                num2 <= NULL;
                            end
                            verifica <= verifica + 1;
                    end
                    3: begin
                         // num1 → posição 3
                            if (num1 == P1SECRET[3:0] && verifica == 3) begin
                                bulls <= bulls + 1;
                                num1 <= NULL;

                            end else if ((num1 == P1SECRET[15:12] || num1 == P1SECRET[11:8] || num1 == P1SECRET[7:4])) begin
                                cows <= cows + 1;
                                num1 <= NULL;
                            end
                            verifica <= verifica + 1;
                    end
                    4: begin //ideia, imprimir o resultado, x B y C aqui, dai não precisa de um outro estado só pra essa impressão
                        
                    end
                endcase       
            end // end do result
               
                
                WIN:
                begin
                    //ganhou!!! parabens
                end

        endcase

        end // end do else (reset)

    end // end do always

    // aqui é o display, é pra funcionar, pois vai atualizar tds digitos assim que mudar o estado e o clock bater, pensei em fazer posedge EA, mas nao sei se funfa
    always @(posedge clock) begin
        case (EA)

            CHECK_IF_EQUAL: begin
                d8 <= {1'b1, 5'h11, 1'b1};
                d7 <= {1'b1, 5'h11, 1'b1};
                d6 <= {1'b1, 5'h11, 1'b1};
                d5 <= {1'b1, 5'h11, 1'b1};
                d4 <= {1'b1, 5'h11, 1'b1};
                d3 <= {1'b1, 5'h11, 1'b1};
                d2 <= {1'b1, 5'h11, 1'b1};
                d1 <= {1'b1, 5'h11, 1'b1};
            end

            P1SETUP: begin
                d8 <= {1'b1, 5'h5, 1'b1};
                d7 <= {1'b1, 5'h1, 1'b1};
                d6 <= {1'b1, 5'h10, 1'b1};
                d5 <= {1'b1, 5'h6, 1'b1};
                d4 <= {1'b1, 5'h7, 1'b1};
                d3 <= {1'b1, 5'h8, 1'b1};
                d2 <= {1'b1, 5'h9, 1'b1};
                d1 <= {1'b1, 5'hA, 1'b1};
                
            end

            P2SETUP: begin
                d8 <= {1'b1, 5'h5, 1'b1};
                d7 <= {1'b1, 5'h2, 1'b1};
                d6 <= {1'b1, 5'h10, 1'b1};
                d5 <= {1'b1, 5'h6, 1'b1};
                d4 <= {1'b1, 5'h7, 1'b1};
                d3 <= {1'b1, 5'h8, 1'b1};
                d2 <= {1'b1, 5'h9, 1'b1};
                d1 <= {1'b1, 5'hA, 1'b1};
            end

            P1GUESS: begin
                d8 <= {1'b1, 5'h5, 1'b1};
                d7 <= {1'b1, 5'h1, 1'b1};
                d6 <= {1'b1, 5'h10, 1'b1};
                d5 <= {1'b1, 5'hF, 1'b1};
                d4 <= {1'b1, 5'h9, 1'b1};
                d3 <= {1'b1, 5'h7, 1'b1};
                d2 <= {1'b1, 5'h6, 1'b1};
                d1 <= {1'b1, 5'h6, 1'b1};
            end

            P2GUESS: begin
                d8 <= {1'b1, 5'h5, 1'b1};
                d7 <= {1'b1, 5'h2, 1'b1};
                d6 <= {1'b1, 5'h10, 1'b1};
                d5 <= {1'b1, 5'hF, 1'b1};
                d4 <= {1'b1, 5'h9, 1'b1};
                d3 <= {1'b1, 5'h7, 1'b1};
                d2 <= {1'b1, 5'h6, 1'b1};
                d1 <= {1'b1, 5'h6, 1'b1};
            end

            RESULT: begin
                d8 <= {1'b1, bulls, 1'b1}; // num_bulls
                d7 <= {1'b1, 5'h10, 1'b1}; // espaço
                d6 <= {1'b1, 5'hB, 1'b1}; // B
                d5 <= {1'b1, 5'h10, 1'b1}; // espaço 
                d4 <= {1'b1, 5'h10, 1'b1}; //espaço
                d3 <= {1'b1, cows, 1'b1}; // num_cows
                d2 <= {1'b1, 5'h10, 1'b1}; // espaço
                d1 <= {1'b1, 5'hC, 1'b1}; // C

            end

            PRINT_BC:begin
                d8 <= {1'b1, bulls, 1'b1}; // num_bulls
                d7 <= {1'b1, 5'h10, 1'b1}; // espaço
                d6 <= {1'b1, 5'hB, 1'b1}; // B
                d5 <= {1'b1, 5'h10, 1'b1}; // espaço 
                d4 <= {1'b1, 5'h10, 1'b1}; //espaço
                d3 <= {1'b1, cows, 1'b1}; // num_cows
                d2 <= {1'b1, 5'h10, 1'b1}; // espaço
                d1 <= {1'b1, 5'hC, 1'b1}; // C

            end

            WIN: begin
                d8 <= {1'b1, 5'hB, 1'b1};
                d7 <= {1'b1, 5'h9, 1'b1};
                d6 <= {1'b1, 5'hD, 1'b1};
                d5 <= {1'b1, 5'hD, 1'b1};
                d4 <= {1'b1, 5'h6, 1'b1};
                d3 <= {1'b1, 5'h7, 1'b1};
                d2 <= {1'b1, 5'hE, 1'b1};
                d1 <= {1'b1, 5'h7, 1'b1};
            end

            default: begin
                d8 <= {1 + 5'h10 + 1}; // espaço
                d7 <= {1 + 5'h10 + 1}; // espaço
                d6 <= {1 + 5'h10 + 1}; // espaço
                d5 <= {1 + 5'h10 + 1}; // espaço
                d4 <= {1 + 5'h10 + 1}; // espaço
                d3 <= {1 + 5'h10 + 1}; // espaço
                d2 <= {1 + 5'h10 + 1}; // espaço
                d1 <= {1 + 5'h10 + 1}; // espaço
            end
        endcase
    end

endmodule