clear,clc
addpath(genpath('..'));
load('../Test datasets/gravity')
load(['../matData/nochange_5000people_200to500steps_0to100go'])

gravity = gravity - min(min(gravity));
data_reshape = gravity;
row=128;col=128;
blocksize=32;
n=row*col;
img_n=row/blocksize;img_m=col/blocksize;
blockNum=img_n*img_m; %分块后块数
%% 低采样率
rate= 0.05;
theta_max = round(rate * blocksize * blocksize);      % 最大参与人数
% 分块
x=zeros(n,1);
for i=1:img_n
    for j=1:img_m
        No=(i-1)*img_m+j;%第 (g-1)*img_m+k 块
        %用reshape函数转换为列向量
        x((No-1) * 1024 + 1 : No * 1024 ,1)=reshape(data_reshape((i-1)*32+1 : i*32 ,(j-1)*32+1 : j*32),[1024,1]);
    end
end
%%
% 统计DR
sampNum = 0;
% 统计测量值数
MNum = 0;

block_ejue = zeros(img_n , img_m);
block_e = zeros(img_n , img_m);
for num=1:1
    clear final_psi;
    %% 行走轨迹分块
    %轨迹矩阵
    for i = 1 :  theta_max
        for g=1:img_n
            for k=1:img_m
                No=(g-1)*img_m+k;%第 (g-1)*img_m+k 块
                temp_block=walk((g-1)*32+1:g*32,(k-1)*32+1:k*32,i);
                %第 (g-1)*img_m+k 块
                final_psi((No-1) * theta_max + i,(No-1)*1024+1 : No*1024)=temp_block(:); %(m*16,1024*16)
            end
        end
    end

    %% 计算每块分配测量值数
    m_befor=1;
    setM = zeros(img_n,img_m); %记录最后给每一块分配了多少m
    for i=1:img_n
        for j=1:img_m  
            block = (i-1) * img_m+j;
            phi = [];
            phi = final_psi((block-1) * theta_max + 1 : block * theta_max , :);%验证大小 imagesc(final_psi)
            phi(all(phi==0,2),:)=[];

            m = size(phi,1);

            setM(i,j) = m;
            sampNum = sampNum + sum(sum(phi(1:m , :))); % DR
            tempM = randn(m ,n);    
            tempM = tempM .* phi(1:m , :);
            for listj = 1 : m
                tempM(listj,:) = tempM(listj,:) ./ sqrt(sum(abs(tempM(listj,:)).^2));
            end

            temp_pinv_M = tempM';
            M(m_befor : m_befor + m -1,1 : n) = zeros(m , n);
            M(m_befor : m_befor + m - 1,(block-1)*1024+1 : block*1024) = tempM(: , (block-1)*1024+1 : block*1024);
            pinv_M(1 : n, m_befor : m_befor + m - 1) = zeros(n , m);
            pinv_M((block-1)*1024+1 : block*1024, m_befor : m_befor+m-1)=temp_pinv_M((block-1)*1024+1 : block*1024 , :);
            m_befor = m_befor + m;
        end
    end
    MNum = MNum + sum(sum(setM));
    m = size(M,1);
    %分块压缩
    Y = M * x;
    z_t=Y;

    iters=80;
    denoiser='BM3D'; 
    denoi=@(noisy,sigma_hat) denoise_blockFull(noisy,sigma_hat,row,col,denoiser);

    % 记录运算时间
    t0 = clock;
    x_t=zeros(n,1);
    for it=1:iters
        pseudo_data=pinv_M*z_t+x_t;
        sigma_hat=sqrt(1/m*sum(abs(z_t).^2));
        x_t=denoi(pseudo_data,sigma_hat);
        eta=randn(1,n);
        epsilon=max(pseudo_data)/1000+eps;
        div=eta*((denoi(pseudo_data+epsilon*eta',sigma_hat)-x_t)/epsilon);
        z_t=Y-M*x_t+1/m.*z_t.*div;
        if mod(it,10) == 0
            fprintf('num = %d iters=%d\n',num,it);
        end
    end
    for k=1:img_n
        for g=1:img_m
            %第k行第g列
            i = (k - 1) * img_m + g;
            recon_data((k-1)*32+1:k*32,(g-1)*32+1:g*32)=reshape(x_t((i - 1) * 1024  + 1: i * 1024,1),[32,32]);
            block_data_reshape = data_reshape((k-1)*32+1:k*32,(g-1)*32+1:g*32);
            block_recon_data = recon_data((k-1)*32+1:k*32,(g-1)*32+1:g*32);
            block_ejue(k,g) = block_ejue(k,g) + norm(block_data_reshape(:) - block_recon_data(:),1) / 1024;
            block_e(k,g) = block_e(k,g) + norm(block_data_reshape(:) - block_recon_data(:),1) / norm(block_data_reshape(:),2);
        end
    end
end
beforGravity = recon_data;
clear fai Y p final_psi;

%% 获取显著性地图

SaliencyMap0=saliency(abs(beforGravity));
SaliencyMap1=saliency(abs(beforGravity + 80));
SaliencyMap2=saliency(abs(beforGravity - 200));
SaliencyMap3=saliency(abs(beforGravity - 80));
SaliencyMap=(SaliencyMap0 + SaliencyMap1 + SaliencyMap2 + SaliencyMap3)/4;
Im_saliency_avg=mean(mean(SaliencyMap));  %显著性总体均值
BlockPerSaliency = zeros(img_n,img_m); %记录每一块平均显著性

%% 分块
x=zeros(n,1);
for i=1:img_n
    for j=1:img_m
        No=(i-1)*img_m+j;%第 (g-1)*img_m+k 块
        %用reshape函数转换为列向量
        x((No-1) * 1024 + 1 : No * 1024 ,1)=reshape(data_reshape((i-1)*32+1 : i*32 ,(j-1)*32+1 : j*32),[1024,1]);
        Block_saliency = mean(mean(SaliencyMap((i-1)*blocksize+1:i*blocksize,(j-1)*blocksize+1:j*blocksize)));  %每块的平均显著性值
        BlockPerSaliency(i,j) = Block_saliency;
    end
end

rates = [0.2 0.3 0.4 0.5 0.6];
now = 1;
for rate = rates
    theta_max = round(rate * blocksize * blocksize);      % 最大参与人数0.3
    %%
    % 统计DR
    sampNum = 0;
    % 统计测量值数
    MNum = 0;

    block_ejue = zeros(img_n , img_m);
    block_e = zeros(img_n , img_m);
    for num=1:5
        clear final_psi;
        %% 行走轨迹分块
        % 1、获得轨迹矩阵
        for i = 1 : theta_max
            for g=1:img_n
                for k=1:img_m
                    No=(g-1)*img_m+k;%第 (g-1)*img_m+k 块
                    temp_block=walk((g-1)*32+1:g*32,(k-1)*32+1:k*32,i);
                    %第 (g-1)*img_m+k 块
                    final_psi((No-1) * theta_max + i,(No-1)*1024+1 : No*1024)=temp_block(:); %(m*16,1024*16)
                end
            end
%             plot(find(walk(:,:,i)==1,1),find(walk(:,:,i)==1,2),'r')
            imagesc(walk(:,:,i))
            hold on
        end

        % 2、计算每块分配测量值数
        t_max = theta_max;
        for i=1 : blockNum        % 更新最大测量值数
            phi = final_psi((i-1) * theta_max + 1 : i * theta_max , :);
            phi(all(phi==0,2),:) = [];
            tempm = size(phi,1);
            if tempm < t_max
                t_max = tempm;
            end
        end
        t_min = round(0.4 * t_max); % 最小测量值数

        m_befor=1;
        setM = zeros(img_n,img_m); %记录最后给每一块分配了多少m
        Sum = sum(sum(BlockPerSaliency));
        meanSaliency = Sum / blockNum;
        distance = max(max(BlockPerSaliency)) - min(min(BlockPerSaliency)); %最大的显著性到平均显著性距离

        % 3、分配测量矩阵
        for i=1:img_n
            for j=1:img_m  
                block = (i-1) * img_m+j;
                phi = [];
                phi = final_psi((block-1) * theta_max + 1 : block * theta_max , :);
                phi(all(phi==0,2),:)=[];

                m = size(phi,1);
                tempm = round( t_min + ( BlockPerSaliency(i,j) - min(min(BlockPerSaliency)))  / distance *(t_max - t_min));
                if tempm < t_min
                    m = t_min;
                elseif tempm < m
                    m = tempm;
                end
    %             m = round(rate * blocksize * blocksize);

                setM(i,j) = m;
                sampNum = sampNum + sum(sum(phi(1:m , :))); % DR
                tempM = randn(m ,n);    
                tempM = tempM .* phi(1:m , :);
                for listj = 1 : m
                    tempM(listj,:) = tempM(listj,:) ./ sqrt(sum(abs(tempM(listj,:)).^2));
                end

                temp_pinv_M = tempM';
                M(m_befor : m_befor + m -1,1 : n) = zeros(m , n);
                M(m_befor : m_befor + m - 1,(block-1)*1024+1 : block*1024) = tempM(: , (block-1)*1024+1 : block*1024);
                pinv_M(1 : n, m_befor : m_befor + m - 1) = zeros(n , m);
                pinv_M((block-1)*1024+1 : block*1024, m_befor : m_befor+m-1)=temp_pinv_M((block-1)*1024+1 : block*1024 , :);
                m_befor = m_befor + m;
            end
        end
        MNum = MNum + sum(sum(setM));
        m = size(M,1);
        % 4、分块压缩
        Y = M * x;
        z_t=Y;

        % 5、整体重构
        iters=80;
        denoiser='BM3D'; 
        denoi=@(noisy,sigma_hat) denoise_blockFull(noisy,sigma_hat,row,col,denoiser);

        % 记录运算时间
        t0 = clock;
        x_t=zeros(n,1);
        for it=1:iters
            pseudo_data=pinv_M*z_t+x_t;
            sigma_hat=sqrt(1/m*sum(abs(z_t).^2));
            x_t=denoi(pseudo_data,sigma_hat);
            eta=randn(1,n);
            epsilon=max(pseudo_data)/1000+eps;
            div=eta*((denoi(pseudo_data+epsilon*eta',sigma_hat)-x_t)/epsilon);
            z_t=Y-M*x_t+1/m.*z_t.*div;
            if mod(it,10) == 0
                fprintf('num = %d iters=%d\n',num,it);
            end
        end
        for k=1:img_n
            for g=1:img_m
                %第k行第g列
                i = (k - 1) * img_m + g;
                recon_data((k-1)*32+1:k*32,(g-1)*32+1:g*32)=reshape(x_t((i - 1) * 1024  + 1: i * 1024,1),[32,32]);
            end
        end
        ejue(num,now) = norm(data_reshape(:) - recon_data(:),1)/n;
        e(num,now) = norm(data_reshape(:) - recon_data(:),2)/norm(data_reshape(:),2);
        e(num,now)

    end
    TimeCost(now) = etime(clock,t0)/num
    % 记录运算时间
    TimeCost = etime(clock,t0)/num;
    % 统计DR
    CR = sampNum / (1024*MNum);
    % 统计采样率
    Trate = MNum / (blockNum * 1024 * num);
    % 采样率	实际采样率	CR	T-绝对误差	T-相对误差	时长	招募人数
    result(now,1) = rate;
    result(now,2) = Trate;
    result(now,3) = CR;
    result(now,4) = min(ejue(:,now));
    result(now,5) = min(e(:,now));
    result(now,6) = TimeCost;
    result(now,7) = rate * 1024;
    result(now,8) = mean(ejue(:,now));
    result(now,9) = mean(e(:,now));
    now = now + 1
end