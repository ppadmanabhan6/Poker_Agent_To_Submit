%% Update Opponent Model
%%
%% INPUT: a matrix recording K round history info containing
%%        the following field
%%        showdown: K by 1 binary vector, recording if a game finally went
%%                  to a showdown stage.
%%        board:    k by 5 matrix, recording all the board cards
%%        hole:     k by N*2 matrix, recording hole cards for all players.
%%                  If a player folds, his cards are hidden (-1)
%%        bet:      k*4 by N, betting history of each player in four
%%                  rounds.
%%
%% OUTPUT: a matrix recording opponent model parameters

function oppo = UpdateOpponent(history,i)
    oppo = [];
    %% ----- FILL IN THE MISSING CODE ----- %%
    global total_data_ap;
    
    for val=1:1:10
        if (val==i)
            continue;
        else
            current_player = val;
        end
        % Create Bayes graph structure
        N = 6; 
        dag = zeros(N,N);
        FH = 1;Bet = 2; Style_1 = 3; Style_2 = 4; Bluff = 5; Position = 6;
        node_names = {'FH', 'Bet', 'Style_1', 'Style_2', 'Bluff', 'Position' };
        dag([FH, Style_1, Style_2, Bluff, Position], Bet) = 1;
        dag([Style_1, Style_2, Position], Bluff) = 1;

        % Create structure of each node
        discrete_nodes = 1:N;
        node_sizes = [9 3 2 2 2 2];
        bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes, 'names', node_names);

        % Define parameters
        card_type_prob = [0.1728, 0.438, 0.2352,0.0483, 0.048, 0.0299, 0.0255, 0.0019, 0.0004];
        bet_prob = (1/432).*ones(1, 432);
        bluff_prob = (1/16).*ones(1, 16);

        bnet.CPD{FH} = tabular_CPD(bnet, FH, card_type_prob);
        bnet.CPD{Bet} = tabular_CPD(bnet, Bet, bet_prob);
        bnet.CPD{Style_1} = tabular_CPD(bnet, Style_1, [0.5 0.5]);
        bnet.CPD{Style_2} = tabular_CPD(bnet, Style_2, [0.5 0.5]);
        bnet.CPD{Bluff} = tabular_CPD(bnet, Bluff, bluff_prob);
        bnet.CPD{Position} = tabular_CPD(bnet, Position, [0.5 0.5]);

        % Draw graph
        %G = bnet.dag;
        %draw_graph(G);

        %Create the data for learning
        game_number = size(history.showdown,1);
        number_players = size(history.money,2);

        %Style1 (If the player folded during the game then this variable is             2, else it is 1
        %Basically a value of 2 is a tight player and a value of 1 is a loose player)
        style1_value = 1;
        for i=1:1:4
            if(history.bet(history.stage_starts(i), current_player) == 3)
                style1_value = 2;
            end
        end

        %Style2 (If the ratio of raises to calls is greater than 1 then this is 2, else it is 1.
        %Basically a value of 1 is a passive player and a value of 2 is an aggressive player)
        type_bet = [0,0];
        for i=1:1:4
            if(history.bet(history.stage_starts(i), current_player) == 1)
                type_bet(1) = type_bet(1) + 1;
            elseif(history.bet(history.stage_starts(i), current_player) == 2)
                type_bet(2) = type_bet(2) + 1;
            end
        end
        if(type_bet(1) > type_bet(2))
            style2_value = 2;
        else
            style2_value = 1;
        end

        %Position (A value of 2 is a late position while a value of 1 is an early position)
        if(history.pos(game_number)>(number_players/3))
            position_value = 2;
        else
            position_value = 1;
        end

        %Bet (The bet places during every round of the game until the player folded)
        bet_values = [];
        for i=1:1:4
            if(history.bet(history.stage_starts(i), current_player) ~= 0)
                bet_values = [bet_values history.bet(history.stage_starts(i), current_player)];
            end
        end

        %FH (If game goes to showdown and the players cards are known, its final type is found and stored)
        card_values = [history.hole(game_number, 2*current_player),history.hole(game_number, 2*current_player -1)];
        if(card_values(1,1) ~= -1)
            FH_value = {final_type([card_values history.board(game_number,:)]) + 1};
        else
            FH_value = {[]};
        end
         
        %Bluff (At showdown, if player had a poor final hand type then bluff is 2 else bluff is 1)
        bluff_value = 1;
        if(card_values(1,1) ~= -1)
            if(cell2mat(FH_value) < 4)
                bluff_value = 2;
            end  
        end

        %New training data after this game
        for i=1:1:size(bet_values,2)
            new_data = [FH_value; bet_values(i); style1_value; style2_value; bluff_value; position_value;current_player];
            if(isequal(total_data_ap(7,1),{[]}))
                total_data_ap(:,1) = new_data;
            else
                total_data_ap = [total_data_ap, new_data];
            end
        end
        
        %Obtaining current player data
        current_data = cell(6,1);
        for i=1:1:size(total_data_ap,2)
            if(isequal(total_data_ap(7,i), {current_player}))
                current_data = [current_data,total_data_ap(1:6,i)];
            end
        end
        
        %Training the Bayes Network
        engine = jtree_inf_engine(bnet);
        max_iter = 10;
        [bnet_trained, LLtrace] = learn_params_em(engine, current_data, max_iter);
        oppo = [oppo;bnet_trained];
        CPT_values = CPT_from_bnet(bnet_trained);
        FH_CPT = CPT_values{1,1};
        
    end
end
