%cd ../../bnt/
%addpath(genpathKPM(pwd))
%cd ../PGM_PROJ/project_part2/

global init_called_ap;
init_called_ap = 100;

global suited_ap;
global unsuited_ap;
    suited_ap=[];
    for i=1:13
        for j=i+1:13
            suited_ap = [ suited_ap ; i*13+j];
        end
    end
    unsuited_ap=[];
    for i=1:13
        for j=1:13
            if i ~= j
                card = sort([ i ,  j]);
                unsuited_ap = [ unsuited_ap ; card(1)*13+card(2)];
                unsuited_ap=unique(unsuited_ap);
            end
        end
    end
global total_data_ap;
total_data_ap = cell(7,1);

global hole_card_default_ap;
cards = [0:51];
F=zeros(1,169);
for i=1:10000
	card_sample=datasample(cards,2,'Replace',false);
    card_sample = sort(card_sample);
	f=hole_card_type(card_sample);
	F(f) = F(f)+1;
end
hole_card_default_ap = F/10000;


global hole_card_lookup_ap;
global hole_card_lookup_flat_ap;
hole_card_lookup_ap=cell(1,169);
card_list = [];
count = 0;
for i=0:51
    for j=i+1:51
        hole_card = [i,j];
        card_found = 0;
        for k=1:length(card_list);
            if card_list(k,1) == i && card_list(k,2) == j
                card_found = 1;
                break;
            end
        end
        if card_found == 0
            count = count+1;
            type = hole_card_type(hole_card);
            prev_cards= hole_card_lookup_ap{1,type};
            hole_card_lookup_ap{1,type} = [prev_cards,hole_card'];
        end
    end
end

hole_card_lookup_flat_ap = [];
for i=1:169
    cards= hole_card_lookup_ap{1,i};
    hole_card_lookup_flat_ap=[hole_card_lookup_flat_ap, cards];
end