%This function generates a model specific to the baord cards available on
%the table. It generates a Bayes net that tried to estimate the
%probabilities of the final hands based on the board cards using a
%sampling technique.

function bnet_trained = generate_model_from_board(board_card)

    if length(board_card) == 3
        % Create Bayes graph structure
        N = 4; 
        dag = zeros(N,N);
        Hole = 1; Turn = 2; River = 3; FH = 4;
        node_names = {'Hole',  'Turn', 'River' , 'FH' };
        dag([Hole, River, Turn], FH) = 1;

        % Create structure of each node
        node_sizes = [169 52 52 9 ];
        cards_to_sample = 4;
        
    elseif length(board_card) == 4
        % Create Bayes graph structure
        N = 3; 
        dag = zeros(N,N);
        Hole = 1;  River = 2; FH = 3;
        node_names = {'Hole',  'River' , 'FH'};
        dag([Hole, River], FH) = 1;

        % Create structure of each node
        node_sizes = [169 52 9 ];    
        cards_to_sample = 3;
    else
        % Create Bayes graph structure
        N = 2; 
        dag = zeros(N,N);
        Hole =1 ; FH = 2;
        node_names = {'Hole',  'FH' };
        dag(Hole, FH) = 1;

        % Create structure of each node
        node_sizes = [169 9 ];
        cards_to_sample = 2;
    end
    
    discrete_nodes = 1:N;
    bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes, 'names', node_names);
    seed = 0;
    rand('state',seed);
    
    % Define parameters
    bnet.CPD{Hole} = tabular_CPD(bnet, Hole);
    if cards_to_sample >= 3
        bnet.CPD{River} = tabular_CPD(bnet, River);
    end
    if cards_to_sample == 4
        bnet.CPD{Turn} = tabular_CPD(bnet, Turn);
    end

    bnet.CPD{FH} = tabular_CPD(bnet, FH);
    
    % Generate_samples 
    %N
    nsamples = 10000;
    samples = cell(N, nsamples);
    cards = setdiff([0:51],board_card);
    for i=1:nsamples
        card_sample = datasample(cards,cards_to_sample,'Replace',false)+1;
        hole_cards = sort(card_sample(1:2));

        samples(Hole,i)={[hole_card_type(hole_cards-1)]};

        samples(FH,i) = {[final_type([card_sample-1,board_card])+1]};
        if cards_to_sample == 4
            samples(Turn,i) = {[card_sample(3)]};
            samples(River,i) = {[card_sample(4)]};
        elseif cards_to_sample == 3
            samples(River,i) = {[card_sample(3)]};
        end
    end
        
    % Training the model
    bnet_trained = learn_params(bnet, samples);    
end