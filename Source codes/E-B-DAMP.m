clear,clc
addpath(genpath('..'));
load('../Test datasets/gravity')

beforGravity = gravity;
gravity = gravity - min(min(gravity));
data_reshape = gravity;
row=128;col=128;
blocksize=32;
n=row*col;
img_n=row/blocksize;img_m=col/blocksize;
blockNum=img_n*img_m; %分块后块数

rates = [0.05	0.1 0.3	0.488];
now = 1;
invite = 500;
load(['../matData/change_500people_200to500steps_0to100go'])
for rate = rates
    theta_max = round(rate * blocksize * blocksize);      % 最大参与人数
    %% 分块
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
    % 记录运算时间
    t0 = clock;

    block_ejue = zeros(img_n , img_m);
    block_e = zeros(img_n , img_m);
    for num=1:5
        ind=randperm(invite);
        clear final_psi;
        %% 行走轨迹分块
        %轨迹矩阵
        for i = 1 :  theta_max
            for g=1:img_n
                for k=1:img_m
                    No=(g-1)*img_m+k;%第 (g-1)*img_m+k 块
                    temp_block=walk((g-1)*32+1:g*32,(k-1)*32+1:k*32,ind(i));
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
        ejue(num,now) = norm(data_reshape(:) - recon_data(:),1)/n;
        e(num,now) = norm(data_reshape(:) - recon_data(:),2)/norm(data_reshape(:),2);
        e(num,now)

    end
    % 记录运算时间
    TimeCost(now) = etime(clock,t0)/num
    % 统计DR
    CR = sampNum / (MNum * 1024) %原来的DR sampNum/(0.14*1024*128*128*20)
    % 统计采样率
    Trate = MNum / (blockNum * 1024 * num)
    % 采样率	实际采样率	CR	T-绝对误差	T-相对误差	时长	招募人数
    result(now,1) = rate;
    result(now,2) = Trate;
    result(now,3) = CR;
    result(now,4) = min(ejue(:,now));
    result(now,5) = min(e(:,now));
    result(now,6) = mean(TimeCost);
    result(now,7) = rate * 1024;
    result(now,8) = mean(ejue(:,now));
    result(now,9) = mean(e(:,now));
    now = now + 1;
end