% Function to classify the hand cards into 169 different categories based
% on "Pocket Pairs"(13), "Suited"(78) and "Unsuited"(78) types.

function type = hole_card_type(hole_cards)
    global suited_ap;
    global unsuited_ap;
    
    card_ranks = floor(hole_cards/4) + 1; % 1 - 13
    card_suits = mod(hole_cards, 4) + 1; % 1- 4
    
    if card_ranks(1) == card_ranks(2)
        type = card_ranks(1);
    elseif card_suits(1) ==  card_suits(2)
        type = 13+find(suited_ap == card_ranks(1)*13+card_ranks(2));
    else
        type = 13+78+find(unsuited_ap == card_ranks(1)*13+card_ranks(2));
    end 
end