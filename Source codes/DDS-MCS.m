clear,clc
addpath(genpath('..'));

load('../Test datasets/gravity')
beforGravity = gravity;
gravity = gravity - min(min(gravity));
data=gravity;

data_reshape = data(:);
row=128;col=128;
n=row*col;
invite = 500;
A=[];
rates = [0.08	0.17	0.2	0.3	0.4];
now = 1;
load(['../matData/nochange_5000people_200to500steps_0to100go'])
for rate = rates
    m=round(rate*n);
    denoiser='BM3D'; 
    % 目标：
    % 统计DR
    sampNum = 0;
    for num=1:1
        clear fai Y psi;

        %轨迹矩阵
        ind=randperm(invite);
        psi=zeros(m,row*col);
        for i=1:m
            temp = walk(:,:,i);
            psi(i,:)=temp(:)';
        end
        sampNum = sampNum + sum(sum(psi)); % DR
        Y=zeros(m,1);

        %测量矩阵
        fai=randn(m,n);
        fai=fai.*psi;
        for j = 1:m
            fai(j,:) = fai(j,:) ./ sqrt(sum(abs(fai(j,:)).^2));
        end
        A=fai;
        M_pinv=A';

        %% 压缩 %%
        Y = A * data_reshape;

        %% 重构 %%
        z_t=Y;
        x_t=zeros(n,1);
        denoi=@(noisy,sigma_hat) denoise_CS(noisy,sigma_hat,row,col,denoiser);
        iters=80;

        % 记录运算时间
        t0=clock;
        for i=1:iters
            pseudo_data=M_pinv*z_t+x_t;
            sigma_hat=sqrt(1/m*sum(abs(z_t).^2));
            x_t=denoi(pseudo_data,sigma_hat);
            eta=randn(1,n);
            epsilon=max(pseudo_data)/1000+eps;
            div=eta*((denoi(pseudo_data+epsilon*eta',sigma_hat)-x_t)/epsilon);
            z_t=Y-A*x_t+1/m.*z_t.*div;
            if mod(i,10)==0
                fprintf('iters=%d\n',i);
            end
        end
        ejue(num,now)=norm(data(:)-x_t(:),1)/n;
        e(num,now)=norm(data(:)-x_t(:),2)/norm(data(:),2);
        fprintf('nums=%d\n',num);
        fprintf('--------> 相对误差 = %d <---------\n',e(num,1));
        % 记录运算时间
        TimeCost(now) = etime(clock,t0)/num
    end
    % 统计DR
    CR = sampNum / (m * n * num)
    % 采样率	实际采样率	CR	T-绝对误差	T-相对误差	时长	招募人数
    result(now,1) = rate;
    result(now,2) = rate;
    result(now,3) = CR;
    result(now,4) = min(ejue(:,now));
    result(now,5) = min(e(:,now));
    result(now,6) = mean(TimeCost);
    result(now,7) = rate * n;
    result(now,8) = mean(ejue(:,now));
    result(now,9) = mean(e(:,now));
    now = now + 1;
end