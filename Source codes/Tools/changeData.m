function [walk,psi]=changeData(walk,psi,A,B,T,row,col)
%%����˵�������ڽ���������i��meet�ڵ�j��֮ǰ������
% walk ���������˸���ȥ�ĵط�
% A    ������ǰ���ߵĲ�����
% B    ���������Ĳ�����
% T    ������T�����ϵ�
    for i=1:row
        for j=1:col
            if length(walk(i,j,A).info)==0 && length(walk(i,j,B).info)==0
                break;
            end
            if length(walk(i,j,B).info)==0        %Aȥ����Bûȥ�� ˵�� length(walk(i,j,A).info)==1
                if walk(i,j,A).info(1)==1
                    psi(B,T).road=[psi(B,T).road,[i;j]];
                    walk(i,j,B).info(1)=1;
                    walk(i,j,B).info(2)=T;
                end
            elseif length(walk(i,j,A).info)==0     %Bȥ����Aûȥ�� ˵�� length(walk(i,j,B).info)==1
                if walk(i,j,B).info(2)<=T && walk(i,j,B).info(1)==1
                    psi(A,T).road=[psi(A,T).road,[i;j]];
                    walk(i,j,A).info(1)=1;
                    walk(i,j,A).info(2)=T;
                end
            end
        end
    end
end