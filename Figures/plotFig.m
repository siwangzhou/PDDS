clear,clc
load('data.mat')
figureName = [{'coverage1'},{'recruitNum1'},{'time'},{'MSE1'},{'probability'},{'coverage2'},{'recruitNum2'},{'MSE2'},{'coverage3'},{'recruitNum3'},{'recruitNum4'},{'MSE3'}];

% %% fig14(b) fig2
% plot(fig2(1,:),100 * fig2(2,:),'b--*', 'linewidth', 0.75)
% hold on
% plot(fig2(1,:),100 * fig2(3,:),'r--o', 'linewidth', 0.75)
% legend('DDS-MCS ','Our proposed')
% xlabel("Number of the participants")
% ylabel("Coverage(%)")
% xlim([0 350])
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(1))],'-dpdf')
% 
% %% fig14(a) fig3
% figure;
% plot(fig3(1,1:9),fig3(2,1:9),'b--*', 'linewidth', 0.75)
% hold on
% plot(fig3(3,:),fig3(4,:),'r--o', 'linewidth', 0.75)
% legend('DDS-MCS ','Our proposed')
% xlabel("Decoding error")
% ylabel("Number of the participants")
% xlim([0 0.2])
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(2))],'-dpdf')

% fig14(c) fig4
figure;
plot(fig4(1,:),fig4(2,:),'b--*', 'linewidth', 0.75)
hold on
plot(fig4(3,1:14),fig4(4,1:14),'r--o', 'linewidth', 0.75)
legend('DDS-MCS ','Our proposed')
xlabel("Decoding rate")
ylabel("Decoding time(s)")
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
% xlim([0 0.13])
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,['./pdf/',char(figureName(3))],'-dpdf')

% fig14(d) fig5
figure;
plot(fig5(2,1:13),fig5(1,1:13),'b--*', 'linewidth', 0.75)
hold on
plot(fig5(4,:),fig5(3,:),'r--o', 'linewidth', 0.75)
legend('DDS-MCS ','Our proposed')
xlabel("Decoding rate")
ylabel("Decoding error")
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
xlim([0 0.13])
ylim([0 0.2])
%0.05Îª¼ä¸ô
set(gca, 'xTick', [0 : 0.05:0.15]);
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,['./pdf/',char(figureName(4))],'-dpdf')

% %% fig11(a) 6
% figure;
% % plot(fig6(2,:),fig6(1,:),'b--*', 'linewidth', 0.75)
% % hold on
% plot(fig6(4,:),fig6(3,:),'r--o', 'linewidth', 0.75)
% hold on
% plot(fig6(6,:),fig6(5,:),'g--s', 'linewidth', 0.75)
% hold on
% plot(fig6(8,1:7),fig6(7,1:7),'c--p', 'linewidth', 0.75)
% hold on
% plot(fig6(10,:),fig6(9,:),'k--^', 'linewidth', 0.75)
% % 'DDS-MCS steps:200~500',
% legend('steps:200~500','steps:500~700','steps:700~900','steps:900~1200')
% xlabel("Decoding rate")
% ylabel("The proportion of successful data recovery (%)")
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(5))],'-dpdf')
% 
% %% fig11(c) fig7
% figure;
% % plot(fig7(1,:),100 * fig7(2,:),'b--*', 'linewidth', 0.75)
% % hold on
% plot(fig7(1,:),100 * fig7(3,:),'r--o', 'linewidth', 0.75)
% hold on
% plot(fig7(1,:),100 * fig7(4,:),'m--+', 'linewidth', 0.75)
% hold on
% plot(fig7(1,:),100 * fig7(5,:),'g--s', 'linewidth', 0.75)
% hold on
% plot(fig7(1,:),100 * fig7(6,:),'c--p', 'linewidth', 0.75)
% hold on
% plot(fig7(1,:),100 * fig7(7,:),'k--^', 'linewidth', 0.75)
% legend('steps:200~500','steps:400~500','steps:500~700','steps:700~900','steps:900~1200')
% % legend('non-shared ','shared steps:200~500','shared steps:400~500','shared steps:500~700','shared steps:700~900','shared steps:900~1200')
% xlabel("Number of the participants")
% ylabel("Coverage(%)")
% xlim([0 350])
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(6))],'-dpdf')
% 
% %% fig11(c) fig8
% figure;
% plot(fig8(1,1:11),fig8(2,1:11),'r--o', 'linewidth', 0.75)
% hold on
% plot(fig8(3,1:9),fig8(4,1:9),'m--+', 'linewidth', 0.75)
% hold on
% plot(fig8(5,1:12),fig8(6,1:12),'g--s', 'linewidth', 0.75)
% hold on
% plot(fig8(7,1:12),fig8(8,1:12),'c--p', 'linewidth', 0.75)
% hold on
% plot(fig8(9,:),fig8(10,:),'k--^', 'linewidth', 0.75)
% xlim([0 0.2])
% legend('steps:200~500','steps:400~500','steps:500~700','steps:700~900','steps:900~1200')
% xlabel("Decoding error")
% ylabel("Number of the participants")
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(7))],'-dpdf')
% 
% %% fig11(b) fig9
% figure;
% plot(fig9(1,:),fig9(2,:),'r--o', 'linewidth', 0.75)
% hold on
% plot(fig9(3,1:9),fig9(4,1:9),'m--+', 'linewidth', 0.75)
% hold on
% plot(fig9(5,1:12),fig9(6,1:12),'g--s', 'linewidth', 0.75)
% hold on
% plot(fig9(7,1:12),fig9(8,1:12),'c--p', 'linewidth', 0.75)
% hold on
% plot(fig9(9,1:13),fig9(10,1:13),'k--^', 'linewidth', 0.75)
% xlim([0 0.15])
% ylim([0 0.18])
% legend('steps:200~500','steps:400~500','steps:500~700','steps:700~900','steps:900~1200')
% xlabel("Decoding rate")
% ylabel("Decoding error")
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(8))],'-dpdf')
% 
% %% fig12(a) fig10
% figure;
% % plot(fig10(1,:),fig10(2,:) * 100,'b--*', 'linewidth', 0.75)
% % hold on
% plot(fig10(1,:),fig10(3,:) * 100,'b-.h', 'linewidth', 0.75)
% hold on
% plot(fig10(1,:),fig10(4,:) * 100,'r--o', 'linewidth', 0.75)
% hold on
% plot(fig10(1,:),fig10(5,:) * 100,'m-.*', 'linewidth', 0.75)
% hold on
% plot(fig10(1,:),fig10(6,:) * 100,'k-.s', 'linewidth', 0.75)
% legend('Exchange:100%','Exchange:50%','Exchange:20%','Exchange:10%')
% xlabel("Number of the participants")
% ylabel("Coverage(%)")
% xlim([0 350])
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(9))],'-dpdf')
% 
% % fig12(b) fig11
% figure;
% plot(fig11(1,:),fig11(2,:),'b-.h', 'linewidth', 0.75)
% hold on
% plot(fig11(3,:),fig11(4,:),'r--o', 'linewidth', 0.75)
% hold on
% plot(fig11(5,1:7),fig11(6,1:7),'m-.*', 'linewidth', 0.75)
% hold on
% plot(fig11(7,1:6),fig11(8,1:6),'k-.s', 'linewidth', 0.75)
% legend('Exchange:100%','Exchange:50%','Exchange:20%','Exchange:10%')
% xlim([0 0.2])
% xlabel("Decoding error")
% ylabel("Number of the participants")
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(10))],'-dpdf')
% 
% % fig13(a) fig12
% figure;
% plot(fig12(1,1:7),fig12(2,1:7),'k--h', 'linewidth', 0.75)
% hold on
% plot(fig12(3,1:5),fig12(4,1:5),'k--*', 'linewidth', 0.75)
% hold on
% plot(fig12(5,1:9),fig12(6,1:9),'r--s', 'linewidth', 0.75)
% hold on
% plot(fig12(7,:),fig12(8,:),'r--o', 'linewidth', 0.75)
% xlim([0 0.2])
% ylim([0 500])
% legend('B-DAMP','A-B-DAMP','E-B-DAMP','AE-B-DAMP')
% xlabel("Decoding error")
% ylabel("Number of the participants")
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(11))],'-dpdf')
% 
% % fig13(b) fig13
% figure;
% plot(fig13(2,1:8),fig13(1,1:8),'k--h', 'linewidth', 0.75)
% hold on
% plot(fig13(4,1:10),fig13(3,1:10),'k--*', 'linewidth', 0.75)
% hold on
% plot(fig13(6,1:8),fig13(5,1:8),'r--s', 'linewidth', 0.75)
% hold on
% plot(fig13(8,:),fig13(7,:),'r--o', 'linewidth', 0.75)
% xlim([0.015 0.11])
% ylim([0 0.2])
% legend('B-DAMP','A-B-DAMP','E-B-DAMP','AE-B-DAMP')
% xlabel("Decoding rate")
% ylabel("Decoding error")
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(gcf,['./pdf/',char(figureName(12))],'-dpdf')