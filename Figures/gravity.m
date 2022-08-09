clear,clc
load('gravity.mat')
load('period_gravity.mat')
imagesc([301 428],[537 664],gravity)
colormap(jet)
colorbar;
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3)-0.7, pos(4)-0.5])
print(gcf,"experiment",'-dpdf')

gra = gra';
figure;
imagesc(gra)
colormap(jet)
colorbar;
test  = gra(537:664,301:428);
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,"gravity",'-dpdf')

figure;
imagesc(test)
colormap(jet)
colorbar;
axis([301:428,537:664])