function C = generate_table(table_name)

    C = banana_code({[1 4 7], ...
                    [4.4:2.2:13.2],...
                    [-2,0], ...
                    [-2,0], ...
                    [-2,0], ...
                    [-2,0], ...
                    [-2,0], ...
                    [-2,0], ...
                    [-2,0], ...
                    -99});
                
    banana_test(C);
    
    %---------------------- CHANGE THIS PART!!! ---------------------------
    VN{1}  = 'rx_ch';
    VN{2}  = 'lp';
    VN{3}  = 'ch1'; 
    VN{4}  = 'ch2';   
    VN{5}  = 'ch3'; 
    VN{6}  = 'ch4';             
    VN{7}  = 'ch5'; 
    VN{8}  = 'ch6'; 
    VN{9}  = 'ch7';           
    VN{10} = 'ch8';
    %---------------------- CHANGE THIS PART!!! ---------------------------
    
    T = array2table(C, 'VariableNames', VN);
    save2 = sprintf('data/tables/%s.csv',table_name);
    if exist(save2, 'file')
        error(sprintf('%s already exists, you should manually delete first\n', save2));
    end
    writetable(T, save2);
end

function C = banana_code(M)
    C = M{end}(:);
    zoh = @(x,y) reshape(repmat(x(:),1,y).',[],1);

    for i = length(M)-1:-1:1
        tmp = C;
        for j = 1:length(M{i})-1
            C = [C; flipud(tmp)];
            tmp = flipud(tmp);
        end

        C = [zoh(M{i}, size(C,1)/length(M{i})), C];
    end
end

function banana_test(C)
    D = C(2:end,:) - C(1:end-1,:);
    M = containers.Map;
    
    for i = 1:size(D,1)
        if length(find(D(i,:)~=0)) ~= 1
            error('banana test failed: continuous 2-line diff is not a one-hot vector');
        end
    end
    
    for i = 1:size(C,1)
        id = strjoin(strsplit(num2str(C(i,:))), ',');
        if M.isKey(id)
            error(sprintf('banana test failed: duplicated lines (L%d, L%d)', i+1, M(id)+1));
        else
            M(id) = i;
        end
    end
end
