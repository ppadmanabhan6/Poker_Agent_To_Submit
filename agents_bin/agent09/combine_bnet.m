%This function generates a combined BNT model for the opponents playing
%style, and the hole cards available in order to estimate the probabilities
%of the opponents hole cards based on the bet that he places. Based on the
%number of hole cards on the table, a different Bayes net is combined with
%the Bayes net denoting a players style.

function [combined_bnet,Bet] = combine_bnet(bnet1,bnet2)
    bnet1_cpt = CPT_from_bnet(bnet1);
    bnet2_cpt = CPT_from_bnet(bnet2);
    N1 = length(bnet1.node_sizes);
    N2 = length(bnet2.node_sizes);
    N = N1+N2-1; 
    dag = zeros(N,N);

    if N == 9
        Hole = 1; Turn = 2; River = 3; FH = 4; Bet = 5; Style_1 = 6; Style_2 = 7; Bluff = 8; Position = 9;
        node_names = {'Hole',  'Turn', 'River' , 'FH' };
        dag([Hole, River, Turn], FH) = 1;
    elseif N == 8
        Hole = 1;  River = 2; FH = 3; Bet = 4; Style_1 = 5; Style_2 = 6; Bluff = 7; Position = 8;
        node_names = {'Hole', 'River' , 'FH' , 'Bet', 'Style_1', 'Style_2', 'Bluff', 'Position'};
        dag([Hole, River], FH) = 1;
    elseif N == 7
        Hole = 1; FH = 2; Bet = 3; Style_1 = 4; Style_2 = 5; Bluff = 6; Position = 7;
        node_names = {'Hole', 'FH', 'Bet', 'Style_1', 'Style_2', 'Bluff', 'Position' };
        dag([Hole], FH) = 1;
    end
    dag([FH, Style_1, Style_2, Bluff, Position], Bet) = 1;
    dag([Style_1, Style_2, Position], Bluff) = 1;

    % create structure of each node
    node_sizes = [bnet1.node_sizes , bnet2.node_sizes(2:end)];
    discrete_nodes = 1:N;
    combined_bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes, 'names', node_names);

    for i=1:N1
        combined_bnet.CPD{i} = tabular_CPD(combined_bnet,i,bnet1_cpt{1,i}(:)');
    end
    
    for i=2:N2
        combined_bnet.CPD{i+N1-1} = tabular_CPD(combined_bnet,i+N1-1,bnet2_cpt{1,i}(:)');
    end
end