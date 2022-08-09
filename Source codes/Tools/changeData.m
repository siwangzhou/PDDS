function [walk,psi]=changeData(walk,psi,A,B,T,row,col)
%%函数说明：用于交换参与者i和meet在第j步之前的数据
% walk ——所有人各自去的地方
% A    ——当前行走的参与者
% B    ——遇到的参与者
% T    ——第T步遇上的
    for i=1:row
        for j=1:col
            if length(walk(i,j,A).info)==0 && length(walk(i,j,B).info)==0
                break;
            end
            if length(walk(i,j,B).info)==0        %A去过，B没去过 说明 length(walk(i,j,A).info)==1
                if walk(i,j,A).info(1)==1
                    psi(B,T).road=[psi(B,T).road,[i;j]];
                    walk(i,j,B).info(1)=1;
                    walk(i,j,B).info(2)=T;
                end
            elseif length(walk(i,j,A).info)==0     %B去过，A没去过 说明 length(walk(i,j,B).info)==1
                if walk(i,j,B).info(2)<=T && walk(i,j,B).info(1)==1
                    psi(A,T).road=[psi(A,T).road,[i;j]];
                    walk(i,j,A).info(1)=1;
                    walk(i,j,A).info(2)=T;
                end
            end
        end
    end
end