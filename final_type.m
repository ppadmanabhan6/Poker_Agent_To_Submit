function [type, highcard] = final_type(card_codes)
% FINAL_TYPE Compute the hand category in the showdown
%
% [type, highcard] = final_type(card_codes)
% [type, ~] = final_type(card_codes)
%
% card_codes  - an array of card codes e.g. [0 4 5 32 27 -1 15 12] (-1s are ignored)
% type        - best hand category (0-8). See descrip[tion below
% highcard    - an array of high card values (rank) to disambiguate same hand categories
%
%   0 -- Junk (High card)
%   1 -- One Pair
%   2 -- Two Pair
%   3 -- Three of a Kind
%   4 -- Straight
%   5 -- Flush
%   6 -- Full House
%   7 -- Four of a Kind
%   8 -- Straight Flush
%
% the output highcard can be used to resolve ties bewteen same hand
% categories. The highcard output depends on resulting best hand category (type).
% For example when you have a Straight Flush with highest card as an Ace, the value 
% highcard will be 14. Whereas best hand is a full-house (Say Jd, Jh, Jc, 3h, 3s) highcard will be a
% array of [ 11 3] denoting [J 3].

    card_codes = card_codes(card_codes ~= -1); % Remove any -1 codes from undealt board cards
    len = size(card_codes,2);
    card_codes = sort(card_codes);
    card_ranks = floor(card_codes/4) + 1; % 1 - 13
    card_suits = mod(card_codes, 4) + 1; % 1- 4
    
    % genrate array which counts the number of occurunces of each kind (rank)
    rank_count = zeros(1, 13);
    for idx = 1:len
        rank = card_ranks(idx); % 1 - 13
        rank_count(rank) = rank_count(rank) + 1;
    end
    
    % detect staright
    staright_rank = 0;
    for i=9:-1:1
        found_zero = 0;
        for j=0:4
            if(~rank_count(i+j))
                found_zero = 1;
                break;
            end
        end
        if(~found_zero)
            staright_rank = i + 4;
            break;
        end
    end
    
    
    % check for Straight Flush
    if(staright_rank)
        % now check for straight flush
        straight_index = find(card_ranks == staright_rank,1,'first');
        straight_suit = card_suits(straight_index-4);
        if(all(card_suits((straight_index-4):straight_index) == straight_suit))
            type = 8;  % Straight Flush
            highcard = staright_rank + 1;
            return;
        end;
    end
    
     
    % check for four of a kind
    temp = find(rank_count == 4, 1);
    if(~isempty(temp))
        type = 7;  % four of a kind
        highcard = temp(1) + 1;
        return;
    end
    
    k3_ranks = find(rank_count == 3, 2);
    k2_ranks = find(rank_count == 2, 3);
    
    % check for Full House
    if(~isempty(k3_ranks) && ~isempty(k2_ranks))
        type = 6;  % Full House
        highcard = [(k3_ranks(1) + 1) (k2_ranks(end) + 1)];
        return;
    elseif(numel(k3_ranks) == 2)
        type = 6;  % Full House
        highcard = [(k3_ranks(2) + 1 ) (k3_ranks(1) + 1)];
        return;
    end
    
    % detect flush
    % genrate array which counts the number of occurunces of each suit
    suit_count = zeros(1, 4);
    for idx = 1:len
        suit = card_suits(idx); % 1- 4
        suit_count(suit) = suit_count(suit) + 1;
    end
    
    
    
    flush_suit = find(suit_count >= 5, 1);
    % check for Flush
    if(~isempty(flush_suit))
        type = 5;  % Flush
        highcard = card_ranks(find(card_suits == flush_suit,1,'last')) + 1;
        return;
    end
    
    % check for Straight
    if(staright_rank)
        type = 4;  % Straight
        highcard = staright_rank + 1;
        return;
    end
    
    % check for three of a kind
    if(~isempty(k3_ranks))
        type = 3;  % three of a kind
        highcard = (k3_ranks(1) + 1);
        return;
    end
    
    % check for high card, one pair or two pair
    num_of_k2 = numel(k2_ranks);
    switch num_of_k2
        case 0
            type = 0;  % No Pair
            highcard = card_ranks(len) + 1;
        case 1
            type = 1;  % one pair
            highcard = [(k2_ranks + 1) (card_ranks(len) + 1)];
        otherwise
            type = 2;  % two of a kind
            highcard = [(k2_ranks(num_of_k2) + 1) (k2_ranks(num_of_k2-1) +1)];   % reorder the high cards
    end
    
end
