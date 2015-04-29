%% Decision Making
%
% INPUT: a structure "info" containing the following field
%        stage, pot, cur_pos, cur_pot, first_pos, board card,
%        hole_card, active, paid, history, su_info, oppo_model
% OUTPUT: an integer from 1 to 3 indicating:
%         1: CALL or CHECK
%         2: BET or RAISE
%         3. FOLD

% We provide some auxiliary probability tables, see section 3.4 
% in the write-up. If you use BNT by Kevin Murphy, please check
% sample BNT code student_BNT.m in T-Square to see how to use it.
%
% Some zero entries do not really mean zero probability, instead
% they mean states we do not care about because they can not
% contribute to any effective hand category in the showdown

%% Table 1: Prior probability of final categories given 7 cards

%  Busted          0.1728
%  One Pair        0.438
%  Two Pair        0.2352
%  3 of a Kind     0.0483
%  Straight        0.048
%  Flush           0.0299
%  Full House      0.0255
%  4 of a Kind     0.0019
%  Straight Flush	0.0004

%% Table 2: Straight and Flush CPT from flop (given two draws)

%                  SF      Flush	Straight
%  J               0.0     0.0     0.0
%  SF              1.0     0.0     0.0
%	SFO4            0.0842	0.2784	0.2414
%	SFO3            0.0028	0.0389	0.0416
%	SFI4            0.0426	0.3145	0.1249
%  F               0.0     1.0     0.0
%	F4              0       0.3497	0
%	F3              0       0.0416	0
%  S               0       0       1.0
%	SO4             0       0       0.3145
%	SO3             0       0       0.0444
%	SI4             0       0       0.1647
%	SF03 & F4       0.0028	0.3469	0.0416
%	SF03 & SI4      0.0028	0.0389	0.1360
%	SF03 & SO4      0.0028	0.0389	0.2784
%	SI4 & F3        0       0.0416	0.1647
%	SI4 & F4        0       0.3497	0.1249
%	SO3 & F3        0    	0.0416	0.0416
%	SO3 & F4        0    	0.3497	0.0250
%	SO4 & F3        0    	0.0416	0.2756
%	SO4 & F4        0    	0.3497	0.2414

%% Table 3: N of a Kind CPT from flop (given two draws)

%          K4      K3K2	K3      K2K2	K2      Junk
%  K4      1.0     0.0     0.0     0.0     0.0     0.0
%	K3K2	0.0435	09565   0.0     0.0  	0.0     0.0
%	K3      0.0426	0.1249	0.8326  0.0     0.0     0.0
%	K2K2	0.0019	0.1619	0.0000	0.8362  0.0     0.0
%	K2      0.0009	0.0250	0.0666	0.3000	0.6075  0.0
%	Junk	0.0000	0.0000	0.0139	0.0832	0.4440  0.4589

%% Table 4: Straight and Flush CPT from turn (given one draw)

%          SF      Flush	Straight
%  SF      1.0     0.0     0.0
%	SFO4	0.0435	0.1522	0.1739
%	SFI4	0.0217	0.1739	0.0870
%  F       0.0     1.0     0.0
%	F4      0       0.1957	0
%  S       0       0       1.0
%	SO4     0       0       0.1739
%	SI4     0       0       0.0870

%% Table 5: N of a Kind CPT from turn (given one draw)

%          K4          K3K2	K3      K2K2	K2      Junk
%  K4      1.0         0.0     0.0     0.0     0.0     0.0
%	K3K2	0.0217      0.9783  0.0     0.0     0.0     0.0
%	K3      0.0217      0.196	0.7823  0.0     0.0     0.0
%	K2K2	0.0000      0.0870	0.0     0.9130  0.0     0.0
%	K2      0.0000      0.0     0.0435	0.2609	0.6956  0.0
%	Junk	0.0000      0.0     0.0     0.0     0.3910  0.609

% Default decision maker
% Start your project here

function decision = MakeDecision_Default(info)
    global init_called_ap;
    if init_called_ap ~= 100
        init;
    end
    
    if (info.stage == 0) 
        decision = MakeDecisionPreFlop(info);
    else
        decision = MakeDecisionPostFlop(info);
    end
end

function decision = MakeDecisionPreFlop(info)
    persistent decProb
    decProb = [0.1 0.9 0.0; 0.3 0.7 0.0; 0.5 0.5 0.0; 0.7 0.3 0.0; 0.2 0.0 0.8];
    
    % This is a simple pre flop decision making function
    pfcat = preflop_cardtype(info.hole_card(1), info.hole_card(2));
    decision = sample_discrete(decProb(pfcat,:), 1, 1);
end

function decision = MakeDecisionPostFlop(info)
    display('MakeDecisionPostFlop')
	%% fill in missing code here for Part I
    
    if size(info.history.board,1) > 100
        win_prob = PredictWin(info);
    else
        win_prob = PredictWin1(info);
    end
    
    %% fill in missing code here for Part II
    %{
    Computes the bet amount that needs to be paid while checking. It also
    computes the value of the threshold, T based on the position of the
    player in the game. Also computes the decision of whether the player
    should fold, check or raise based on the probability of win. This
    calculation is done using the formulas provided in the write-up. It
    calculates this using inequalities involving number of total players,
    number of active players, bet amount, threshold and the probability of
    win.
    %}
    SBU=10;
    mustpay = info.cur_pot - info.paid(info.cur_pos);
    Bt = mustpay/SBU;
    M = info.pot/SBU;
    Na = sum(info.active);
    N = size(info.active,2);
    Pos = info.cur_pos;
    T = 0;
    
    if Pos<(N/3)
        T = -0.3;
    else
        T = 0.1;
    end
    
    if (win_prob > ((Bt+1)/(M+Na+Bt+1))-T)
        decision = 2;
    elseif (win_prob>((Bt/(M+Bt))-T))
        decision = 1;
    else
        decision = 3;
    end
    
    %% The following is just a sample of randomly generating different
    %% decisions. Please comment them after you finish your part.
%     num = floor(rand(1)*100);
%     if (num <= 60)
%         decision = 1;
%     elseif (num <= 90)
%         decision = 2;
%     else
%         decision = 3;
%     end    

end



%{
The PredictWin function basically computes the probability of our winning a
particular game. Given the hold cards as well as the cards present on the
table;we sample the remaining cards on the table(2 or 1 or none depending 
on the stage of the game.) We also sample the cards for the opponents that
are still playing the game. We perform a similar procedure 10,000 times and
for every set of samples, we find the final type of hand we get as well as
the opponents get and then predict whether we will win the particular game,
lose or tie. In our implementation, we assume a tie to also be a win since
the earnings are split between all the current players in the case of a
win, which might still be beneficial. In this method, we are calculating
the probability of us winning a particular game at every stage of the game.
%}

% Compute probability of winning vs N opponents
function win_prob = PredictWin(info)
    
    global hole_card_lookup_flat_ap;
    win_prob = 0.0;
    Num_trials = 10000;
    
    hole_card = info.hole_card;
    board_card = info.board_card;
    win_count = 0;
    opponent_dist_all = [];
 
    hole_cards_array = cell(1,info.num_oppo);
    card_sample = hole_card_lookup_flat_ap;
    oppo_card = []    ;
    for num=1:1:info.num_oppo   
        opponent_dist = convert_to_hole(info.su_info(num,:),[board_card]);

        hole_cards_array{1,num} = datasample(card_sample',Num_trials,'Weights',opponent_dist);              
    end
   
    for i=1:Num_trials
        cards = [0:51];
        cards = setdiff(cards,[hole_card,board_card]);

        board_card_rest = zeros(1,sum(board_card == -1));
        board_card = board_card(board_card ~= -1);
        opponent_cards = zeros(1,info.num_oppo*2); 
        k = size(opponent_cards,2)+size(board_card_rest,2);
        for num=1:info.num_oppo
            opponent_cards(1,num*2 -1:num*2) = hole_cards_array{1,num}(i); 
        end

        cards = setdiff(cards,opponent_cards);
        board_card_rest = datasample(cards,size(board_card_rest,2),'Replace',false);

        [my_type,my_highcard] = final_type([hole_card, board_card, board_card_rest]);
        my_highcard = max(my_highcard);
        loss = 0;
        for j=1:info.num_oppo
            if info.active(j+1) == 1
                [op_type,op_highcard] = final_type([opponent_cards(2*j-1:2*j),board_card,board_card_rest]);
                op_highcard = max(op_highcard);
                if( (op_type > my_type )|| (op_type == my_type && op_highcard > my_highcard))
                    loss=1;
                    break;
                end
            end
        end
        if loss ~= 1
            win_count = win_count + 1;
        end

        
    end
    win_prob = (win_count/Num_trials)
end

function win_prob = PredictWin1(info)
   
    win_prob = 0.0;
    Num_trials = 10000;
    hole_card = info.hole_card;
    board_card = info.board_card;
    cards = [0:51];
    cards = setdiff(cards,[hole_card,board_card]);
    opponent_cards = zeros(1,info.num_oppo*2);
    board_card_rest = zeros(1,sum(board_card == -1));
    board_card = board_card(board_card ~= -1);
    k = size(opponent_cards,2)+size(board_card_rest,2);
    win_count = 0;
    
    for i=1:Num_trials
        sample_card = datasample(cards,k,'Replace',false);
        opponent_cards = sample_card(1:info.num_oppo*2);
        board_card_rest = sample_card(info.num_oppo*2+1:end);
        [my_type,my_highcard] = final_type([hole_card,board_card,board_card_rest]);
        my_highcard = max(my_highcard);
        loss = 0;
        for j=1:info.num_oppo
            if info.active(j+1) == 1
                [op_type,op_highcard] = final_type([opponent_cards(2*j-1:2*j),board_card,board_card_rest]);
                op_highcard = max(op_highcard);
                if( (op_type > my_type )|| (op_type == my_type && op_highcard > my_highcard))
                    loss=1;
                    break;
                end
            end
        end
        if loss ~= 1
            win_count = win_count + 1;
        end
        
    end
    win_prob = (win_count/Num_trials) 
end


%The function computes the final category of our hand as well as our high card 
%and returns it, by using the sftype and cardtype functions provided in the
%code. Currently this function is not being used as we are using the
%final_type function provided in the code instead.

function [type,highcard] = final_card_type(v)
    [cf,high_cf] = cardtype(v);
    [sf,high_sf] = sftype(v);
    type = 0;
    highcard = max(high_cf,high_sf);
    if sf== 1
        type = 8;
        highcard = max(high_sf);
    elseif sf == 5
        type = 5;
        highcard = max(high_sf);
    elseif sf == 8
        type = 4;
        highcard = max(high_sf);
    elseif cf == 5
        type = 7;
        highcard = max(high_cf);
    elseif cf == 4
        type = 6;
        highcard = max(high_cf);
    elseif cf == 3
        type = 3;
        highcard = max(high_cf);
    elseif cf == 2
        type = 2;
        highcard = max(high_cf);
    elseif cf == 1
        type = 1;
        highcard = max(high_cf);
    end
end
