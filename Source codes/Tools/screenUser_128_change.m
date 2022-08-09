clear,clc
row=200;
col=200;
addpath(genpath('..'));
load('../matData/nochange_500people_900to1200steps_0to100go.mat')
n=row*col;
people_num = 500; %招募 128*128 个参与者
change_people_num = 500;
min_walk=30000;
max_walk=40000;
Tmin_walk = 400;
Tmax_walk = 500;
fq = 0.6  ;%60%
%walk=zeros(row,col,people_num);
%% 筛选条件
%行走范围 10~40
a=40;b=40;size=128;
minstartTime = 0;
startTime = 100;
people_chosed = [people_num round(people_num/1.5) round(people_num/2) round(people_num/5) round(people_num/10) round(people_num/50) round(people_num/100)];
change_people_chosed = [change_people_num round(change_people_num/1.5) round(change_people_num/2) round(change_people_num/5) round(change_people_num/10) round(change_people_num/50) round(change_people_num/100)];

%% 交换
walk=zeros(size,size,people_num);
change_time=0;

for i=1:people_num
    if psi(i,1,1) ~= 0
        walk(psi(i,1,1),psi(i,1,2),i)=1;
    end
end
for time=2:length(psi(1,:,1))
    for i=1:change_people_num
        meet(i).info=i;
        flag=0;
        if psi(i,time,1)~=0
            walk(psi(i,time,1),psi(i,time,2),i)=1;
            for j=1:i-1
                if psi(j,time,1)==psi(i,time,1) && psi(j,time,2)==psi(i,time,2)  %相遇
                    change_time=change_time+1;
                    if rand < fq  %%%%%%%%
                        temp_walk=walk(:,:,i);
                        %更新walk;
                        for z=1:size
                            for x=1:size
                                if walk(z,x,j)
                                    temp_walk(z,x)=1;
                                end
                            end
                        end
                        
                        walk(:,:,i) = temp_walk;
                        walk(:,:,j) = temp_walk;
                        meet(j).info = [meet(j).info,[i]];
                        for no=2:length(meet(j).info)
                            walk(:,:,meet(j).info(no))=temp_walk;
                        end
                        break;
                    end
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
%覆盖率
for choice = 1 : length(people_chosed)
    walk_change = zeros(128,128);
    for people = 1:people_chosed(choice)
        walk_change = walk_change | walk(:,:,people);
    end
    result(2,choice)=sum(sum(walk_change))/16384;
end
sum(sum(sum(walk)))/(size*size*people_num);
% save(['../matData/change_',num2str(change_people_num),'People_',num2str(Tmin_walk),'to',num2str(Tmax_walk),'steps_',num2str(minstartTime),'to',num2str(startTime),'go_',num2str(100*fq),'%fq.mat'],'walk','psi', '-v7.3' );
