function type = situation(x,y,size)
    if x<size && x>1 &&y<size && y>1
        type = 5;
    elseif x==1
        if y==1
            type = 1;
        elseif y==size
            type = 7;
        else 
            type = 4;
        end
    elseif x==size
        if y==1
            type = 3;
        elseif y==size
            type = 9;
        else 
            type = 6;
        end
    else
        if y==1
            type = 2;
        else 
            type = 8;
        end
    end
end
