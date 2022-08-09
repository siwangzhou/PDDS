clear,clc
row=128;
col=128;
addpath(genpath('..'));
T=50;  %步长
n=row*col;
rates=[0.02 , 0.03 , 0.04 , 0.06 , 0.08 , 0.09];
for rate = rates
    load(['./matData/matrix_space_300_90000_',num2str(T),'steps'])
    walk_2=walk;
    people_num=round(rate*n);     %%%% 改 %%%%
    max_walk=400;  %psi最长时间  %%%% 改 %%%%
    %% 截取交换前数据
    temp=randperm(90000);
    walk_befor_per=walk_2(:,:,temp(1:people_num));
    walk=walk_befor_per;
    save(['./matData/',num2str(T),'/matrix_space_nochange_',num2str(row),'_00',num2str(100*rate),'.mat'],'walk');
    disp(['交换前覆盖率：',num2str(sum(sum(sum(walk)))/(row*col*people_num))])
    %% 进行数据交换
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
                    if psi(j,time,1)==psi(i,time,1) && psi(j,time,2)==psi(i,time,2)  %相遇
                        change_time=change_time+1;
                        temp_walk=walk(:,:,i);
                        %更新walk;
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
            disp(['——————————第',num2str(time),'秒——————————'])
        end
    end
    num=sum(sum(sum(walk)));
    disp(['交换后覆盖率：',num2str(num/(row*col*people_num))])
    save(['./matData/',num2str(T),'/matrix_space_change_',num2str(row),'_00',num2str(100*rate),'.mat'],'walk');
end











