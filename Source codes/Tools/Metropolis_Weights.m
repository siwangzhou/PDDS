function W = Metropolis_Weights(x,y,type,size)
    NodeNum = getN(type);
    W=zeros(3,3);
    %记录W中可以存值的坐标NodeNum-1,2
    coord = get_coordinate(type);
    sum=0;
    for j=1:NodeNum
        temp_x=x+coord(j,2)-2;
        temp_y=y+coord(j,1)-2;
        temp_type = situation(temp_x,temp_y,size);
        W(coord(j,1), coord(j,2))=1./(max(NodeNum,getN(temp_type)));
        sum=sum+W(coord(j,1), coord(j,2));
    end
    W(2,2)=1-sum;
end
function N = getN(type)
    if type==5
        N=8;
    elseif type==1||type==3||type==7||type==9
        N=3;
    else
        N=5;
    end
end
function coord = get_coordinate(type)
    if type==5
        coord=[1,1;1,2;1,3;2,1;2,3;3,1;3,2;3,3];
    elseif type==1
        coord=[2,3;3,2;3,3];
    elseif type==2
        coord=[2,1;2,3;3,1;3,2;3,3];
    elseif type==3
        coord=[2,1;3,1;3,2];
    elseif type==4
        coord=[1,2;1,3;2,3;3,2;3,3];
    elseif type==6
        coord=[1,1;1,2;2,1;3,1;3,2];
    elseif type==7
        coord=[1,2;1,3;2,3];
    elseif type==8
        coord=[1,1;1,2;1,3;2,1;2,3];
    else
        coord=[1,1;1,2;2,1];
    end
end