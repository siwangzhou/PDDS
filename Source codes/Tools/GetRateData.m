clear,clc
row=128;
col=128;
addpath(genpath('..'));
T=50;  %����
n=row*col;
rates=[0.02 , 0.03 , 0.04 , 0.06 , 0.08 , 0.09];
for rate = rates
    load(['./matData/matrix_space_300_90000_',num2str(T),'steps'])
    walk_2=walk;
    people_num=round(rate*n);     %%%% �� %%%%
    max_walk=400;  %psi�ʱ��  %%%% �� %%%%
    %% ��ȡ����ǰ����
    temp=randperm(90000);
    walk_befor_per=walk_2(:,:,temp(1:people_num));
    walk=walk_befor_per;
    save(['./matData/',num2str(T),'/matrix_space_nochange_',num2str(row),'_00',num2str(100*rate),'.mat'],'walk');
    disp(['����ǰ�����ʣ�',num2str(sum(sum(sum(walk)))/(row*col*people_num))])
    %% �������ݽ���
    walk_befor_per=[];
    walk_2=[];
    walk=zeros(row,col,people_num);
    change_time=0;
    
    for i=1:people_num
        if psi(i,1,1)~=0
            walk(psi(i,1,1),psi(i,1,2),i)=1;
        end
    end
    for time=2:max_walk
        %     meet=zeros(people_num);
        for i=1:people_num
            meet(i).info=i;
            flag=0;
            if psi(i,time,1)~=0
                walk(psi(i,time,1),psi(i,time,2),i)=1;
                for j=1:i-1
                    if psi(j,time,1)==psi(i,time,1) && psi(j,time,2)==psi(i,time,2)  %����
                        change_time=change_time+1;
                        temp_walk=walk(:,:,i);
                        %����walk;
                        for z=1:row
                            for x=1:col
                                if walk(z,x,j)
                                    temp_walk(z,x)=1;
                                end
                            end
                        end
                        walk(:,:,i)=temp_walk;
                        walk(:,:,j)=temp_walk;
                        meet(j).info=[meet(j).info,[i]];
                        for no=2:length(meet(j).info)
                            walk(:,:,meet(j).info(no))=temp_walk;
                        end
                        break;
                    end
                end
                flag=1;
            elseif flag
                break;
            else
                continue;
            end
        end
        if mod(time,50)==0
            disp(['����������������������',num2str(time),'�롪������������������'])
        end
    end
    num=sum(sum(sum(walk)));
    disp(['�����󸲸��ʣ�',num2str(num/(row*col*people_num))])
    save(['./matData/',num2str(T),'/matrix_space_change_',num2str(row),'_00',num2str(100*rate),'.mat'],'walk');
end











