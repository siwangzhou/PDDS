clear,clc
row=200;
col=200;
addpath(genpath('..'));

n=row*col;
people_num = 500; %招募 128*128 个参与者
change_people_num = 500;
min_walk=30000;
max_walk=40000;
Tmin_walk = 400;
Tmax_walk = 500;
fq = 0.2;%60%
%walk=zeros(row,col,people_num);
%% 筛选条件
%行走范围 10~40
a=40;b=40;size=128;
minstartTime = 0;
startTime = 100;
people_chosed = [people_num round(people_num/1.5) round(people_num/2) round(people_num/5) round(people_num/10) round(people_num/50) round(people_num/100)];
change_people_chosed = [change_people_num round(change_people_num/1.5) round(change_people_num/2) round(change_people_num/5) round(change_people_num/10) round(change_people_num/50) round(change_people_num/100)];

%%
chosed=0;
while chosed<people_num
    %步长
    step = Tmin_walk + randperm(Tmax_walk - Tmin_walk,1);
    %随机生成起点 让x成为向前的变量，只增或者只减
    x=round(1 + (col-1) * rand);
    y=round(1 + (row-1) * rand);
    tempx=x;
    %确定方向
    if x>round(col/2)%往左
        direction=1;
    else             %往右
        direction=0;
    end
    
    %开始t次random walk
    k=1;
    start_time = minstartTime + randperm(startTime - minstartTime,1);%给随机步数制定下限 %%%%%%%%
    t=min_walk+randperm(max_walk-min_walk,1);%给随机步数制定下限
    temp=rand;
    tempPhi=[];
    walk=zeros(size,size);
    tempJ=[1:start_time]';%记录要删除的行号 （不在范围内的点）
    for j=start_time:start_time+t
        %确定坐标类型 0~4、6~9表示边角
        type = situation(tempx,y,row);
        %得到起点周围点的概率,3*3大小的矩阵
        W = Metropolis_Weights(tempx,y,type,row);
        %根据W确定下一步走哪里
        if mod(j,10)==0
            if rand>0.5
                direction=1;
            else
                direction=0;
            end
        end
        if x==col %往左
            direction=1;
        elseif x==1%往右
            direction=0;
        end
        [tempx,y] = get_xy(tempx,y,W);
        if direction==0
            x=x+1;
        else
            x=x-1;
        end
        if x<=0||y<=0
            disp('error');
            break;
        end
        %更新路径记录
        if temp>0.5        %让用户行走方向更随机
            tempPhi(j,1)=x;
            tempPhi(j,2)=y;
        else
            tempPhi(j,1)=y;
            tempPhi(j,2)=x;
        end
        if tempPhi(j,1)>a && tempPhi(j,1)<a+size+1 && tempPhi(j,2)>b && tempPhi(j,2)<b+size+1
            walk(tempPhi(j,1)-a,tempPhi(j,2)-b)=1;
            if sum(sum(walk))==step %选中了当前用户
                chosed=chosed+1;
                walk_befor_per(:,:,chosed)=walk;
                %删除不要的点
                tempPhi(tempJ,:)=a;
                psi(chosed,1:j,1)=tempPhi(1:j,1)-a;%存在<=0的数
                psi(chosed,1:j,2)=tempPhi(1:j,2)-b;
                
                if mod(chosed,50)==0
                    disp(['当前是第',num2str(chosed),'个人'])
                end
                break;
            end
        else
            tempJ=[tempJ;j];
        end
    end
    %%根据步长和范围，确定是否保留该用户
end
walk=walk_befor_per;

%覆盖率
for choice = 1 : length(people_chosed)
    walk_nochange = zeros(128,128);
    for people = 1:people_chosed(choice)
        walk_nochange = walk_nochange | walk_befor_per(:,:,people);
    end
    result(1,choice)=sum(sum(walk_nochange))/16384;
end
walk = walk_befor_per;
% save(['../matData/nochange_',num2str(people_num),'people_',num2str(Tmin_walk),'to',num2str(Tmax_walk),'steps_',num2str(minstartTime),'to',num2str(startTime),'go_',num2str(fq),'fq.mat'],'walk','psi', '-v7.3' );

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
                    if mod(change_time,fq) == 0 %%%%%%%%
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
% save(['../matData/change_',num2str(change_people_num),'People_',num2str(Tmin_walk),'to',num2str(Tmax_walk),'steps_',num2str(minstartTime),'to',num2str(startTime),'go_',num2str(fq),'fq.mat'],'walk','psi', '-v7.3' );
