function x_hat = DAMP(y,iters,height,width,denoiser,M_func,mp)
% function [x_hat,PSNR] = DAMP(y,iters,width,height,denoiser,M_func,Mt_func,PSNR_func)
% this function implements D-AMP based on any denoiser present in the
% denoise function
%
% Required Input:
%       y       : the measurements 
%       iters   : the number of iterations
%       width   : width of the sampled signal
%       height  : height of the sampeled signal. height=1 for 1D signals
%       denoiser: string that determines which denosier to use. e.g., 'BM3D'
%       M_func  : function handle that projects onto M. Or a matrix M.
%
% Optional Input:
%       Mt_func  : function handle that projects onto M'.
%       PSNR_func: function handle to evaluate PSNR
%
% Output:
%       x_hat   : the recovered signal.
%       PSNR    : the PSNR trajectory.

   %M_pinv=M_func'


denoi=@(noisy,sigma_hat) denoise(noisy,sigma_hat,height,width,denoiser);

n=width*height;
m=length(y);

z_t=y;
x_t=zeros(n,1);
%M_pinv=pinv(M_func);
for i=1:iters
    pseudo_data=mp*z_t+x_t;
     sigma_hat=sqrt(1/m*sum(abs(z_t).^2));
%     sigma_hat=max(z_t);
    x_t=denoi(pseudo_data,sigma_hat);
    eta=randn(1,n);
    epsilon=max(pseudo_data)/1000+eps;
    div=eta*((denoi(pseudo_data+epsilon*eta',sigma_hat)-x_t)/epsilon);
    z_t=y-M_func*x_t+1/m.*z_t.*div;
%     if mod(i,10)==0
%         fprintf('iters=%d',i);
%     end
end
%x_hat=reshape(x_t,[width height]);
x_hat=x_t;
end