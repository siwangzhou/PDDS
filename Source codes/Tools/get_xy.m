function [x,y] = get_xy(x_old,y_old,W,type)
    choice=rand;
    sum=0;
    flag=0;
    for i=1:3
        for j=1:3
           sum=sum + W(i,j);
           if choice<sum || sum==1
                x=x_old+(j-2);
                y=y_old+(i-2);
                flag=1;
                break;
           end
        end
        if flag==1
            break;
        end
    end
end