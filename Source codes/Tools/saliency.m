%��������ͼ����
function smap=saliency(X)
%  OMP�ĺ���
[a,b]=size(X);
%% 
%�ó�������ͼ
P=fft2(X); 
myLogAmplitude = log(abs(P));
myPhase = angle(P);
mySpectralResidual = myLogAmplitude - imfilter(myLogAmplitude, fspecial('average', 3), 'replicate'); 
smap = abs(ifft2(exp(mySpectralResidual + i*myPhase))).^2;
smap = mat2gray(imfilter(smap, fspecial('gaussian', [10, 10], 3)));


% %% Spectral Residual
% myFFT = fft2(X);
% myLogAmplitude = log(abs(myFFT));
% myPhase = angle(myFFT);
% mySpectralResidual = myLogAmplitude - imfilter(myLogAmplitude, fspecial('average', 3), 'replicate');
% saliencyMap = abs(ifft2(exp(mySpectralResidual + i*myPhase))).^2;
% 
% %% After Effect
% saliencyMap = mat2gray(imfilter(saliencyMap, fspecial('gaussian', [10, 10], 2.5)));
% imagesc(saliencyMap);