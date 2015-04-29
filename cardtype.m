%% Compute N of a Kind Hand Categories,
% Student does not need to understand this.

% See Table 2 in the write-up
%   0 -- No Pair
%   1 -- One Pair
%   2 -- Two pair
%   3 -- Three of a Kind
%   4 -- Full House
%   5 -- Four of a Kind
%
% Note: Input card_codes should be combination of board and hole cards. Any card types with value -1 will 
% be stripped out automatically, so you can always pass in the full board_card array
% The meaning of the highcard output depends upon what category it is.
% HighCard is single card value for 0, 1, 3, 5 and two card values for cases 2 and 4.

function [ct, highcard] = cardtype(card_codes)
    card_codes = card_codes(card_codes ~= -1); % Remove any -1 codes from undealt board cards
    len = size(card_codes,2);
    card_codes = sort(card_codes);
    card_ranks = floor(card_codes/4) + 1; % 1 - 13  
    %ct = 0;
    
    % genrate array of size 13 which counts the number of occurunces of
    % each kind (rank)
    rank_count = zeros(1, 13);
    for idx = 1:len
        rank = card_ranks(idx); % 1 - 13
        rank_count(rank) = rank_count(rank) + 1;
    end
%     % One line version of the above but is quite slow
%     rank_count = accumarray(card_ranks', 1, [13 1]); 
     
    temp = find(rank_count >= 4, 1);
    if(~isempty(temp))
        ct = 5;  % four of a kind
        highcard = temp(1) + 1;
        return;
    end

    k3_ranks = find(rank_count == 3, 2);
    if (numel(k3_ranks) == 2)
        ct = 4;  % Full House
        highcard = [(k3_ranks(2) + 1 ) (k3_ranks(1) + 1)];
        return;
    elseif (numel(k3_ranks) == 1)
        highcard = k3_ranks(1) + 1;
        k2_ranks = find(rank_count == 2, 2);
        if(~isempty(k2_ranks))
            ct = 4;  % Full House
            highcard = [highcard (k2_ranks(end) +1)];
        else
            ct = 3;  % three of a kind
        end
        return;
    end
  
    k2_ranks = find(rank_count >= 2, 3);
    num_of_k2 = numel(k2_ranks);
    switch num_of_k2
        case 0
            ct = 0;  % No Pair
            highcard = card_ranks(len) + 1;
        case 1
            ct = 1;  % one pair
            highcard = [(k2_ranks + 1) (card_ranks(len) + 1)];
        otherwise
            ct = 2;  % two of a kind
            highcard = [(k2_ranks(num_of_k2) + 1) (k2_ranks(num_of_k2-1) +1)];   % reorder the high cards
    end
end


    
    

