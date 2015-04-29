%{
This function computes the prior probabilities, straight and flush
probabilities from 2 draws and 1 draw, N of a kind probabilities from 2
draws and 1 draw. These were calculated in order to evaluate the functioning
of our sampling method with the probabilities mentioned in the CPT table in
MakeDecision_Default. We have computed these probabilities by randomly
picking 5 cards(or 6 cards) that make up our hold cards and the cards on
the table, and then sampling 20,000 times the remaining 2 cards(or 1 card)
and computing the percentage of the different final hand that we obtain. 
We have performed this procedure for the various Straight and Flush types
as well as the N of a kind types of cards.
%}

%{
%Prior Probability
function counter = CheckProb()
    counter = zeros(1,9);
    cards = [0:51];
    Num_trials = 10000;
    for j=1:1:Num_trials
        cards_known = datasample(cards,7,'Replace',false);
        my_type = final_type(cards_known);
        counter(my_type + 1) = counter(my_type + 1) + 1; 
    end 
    counter = counter/10000;
end

%SF Type Probability (2 draws)
function counter = CheckProb()
    counter = zeros(21,3);
    for i=0:1:20
        disp(i);
        cards = [0:51];
        initial_type=100;
        while(initial_type~=i)
            cards_known = datasample(cards,5,'Replace',false);
            initial_type = sftype(cards_known);
        end
        Num_trials = 20000;
        cards = setdiff(cards,cards_known);
        for j=1:1:Num_trials
            board_card_rest = datasample(cards,2,'Replace',false);
            my_type = final_type([cards_known,board_card_rest]);
            if my_type==8
                counter(initial_type + 1,1) = counter(initial_type + 1,1) + 1; 
            elseif my_type == 5
                    counter(initial_type + 1,2) = counter(initial_type + 1,2) + 1; 
            elseif my_type == 4
                counter(initial_type + 1,3) = counter(initial_type + 1,3) + 1; 
            end
        end 
    end
    for k=1:1:21
        counter(k,:) = counter(k,:)/20000;
    end
end

%CardType Probability(2 draws)
function counter = CheckProb()
    counter = zeros(6,6);
    for i=0:1:5
        disp(i);
        cards = [0:51];
        initial_type=100;
        while(initial_type~=i)
            cards_known = datasample(cards,5,'Replace',false);
            initial_type = cardtype(cards_known);
        end
        Num_trials = 20000;
        cards = setdiff(cards,cards_known);
        for j=1:1:Num_trials
            board_card_rest = datasample(cards,2,'Replace',false);
            my_type = cardtype([cards_known,board_card_rest]);
            counter(initial_type + 1,my_type + 1) = counter(initial_type + 1,my_type + 1) + 1; 
        end 
    end
    for k=1:1:6
        counter(k,:) = counter(k,:)/20000;
    end
end

%SF Type Probability (2 draws)
function counter = CheckProb()
    counter = zeros(21,3);
    for i=0:1:20
        disp(i);
        cards = [0:51];
        initial_type=100;
        while(initial_type~=i)
            cards_known = datasample(cards,6,'Replace',false);
            initial_type = sftype(cards_known);
        end
        Num_trials = 20000;
        cards = setdiff(cards,cards_known);
        for j=1:1:Num_trials
            board_card_rest = datasample(cards,1,'Replace',false);
            my_type = final_type([cards_known,board_card_rest]);
            if my_type==8
                counter(initial_type + 1,1) = counter(initial_type + 1,1) + 1; 
            elseif my_type == 5
                    counter(initial_type + 1,2) = counter(initial_type + 1,2) + 1; 
            elseif my_type == 4
                counter(initial_type + 1,3) = counter(initial_type + 1,3) + 1; 
            end
        end 
    end
    for k=1:1:21
        counter(k,:) = counter(k,:)/20000;
    end
end
%}

%CardType Probability(1 draw)
function counter = CheckProb()
    counter = zeros(6,6);
    for i=0:1:5
        cards = [0:51];
        initial_type=100;
        while(initial_type~=i)
            cards_known = datasample(cards,6,'Replace',false);
            initial_type = cardtype(cards_known);
        end
        Num_trials = 20000;
        cards = setdiff(cards,cards_known);
        for j=1:1:Num_trials
            board_card_rest = datasample(cards,1,'Replace',false);
            my_type = cardtype([cards_known,board_card_rest]);
            counter(initial_type + 1,my_type + 1) = counter(initial_type + 1,my_type + 1) + 1; 
        end 
    end
    for k=1:1:6
        counter(k,:) = counter(k,:)/20000;
    end
end