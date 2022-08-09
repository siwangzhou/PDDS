PDDS
Figures
Two .m files, using which the figures shown in Figs. 10-14 are plotted.

Source codes
“DDS-MCS.m” implements the most advanced dds-mcs scheme for comparison. "B-DAMP.m" is used to realize our block wise perceptual coding and decoding task. "E-B-DAMP.m" is used to realize the block wise perceptual coding and decoding task of our data exchange. "A-B-DAMP.m"is used to implement our block wise perceptual coding and decoding task with attention mechanism. "AE-B-DAMP.m "is used to realize our block wise perceptual coding and decoding task with attention mechanism and data exchange."Tools" and "matData" are used to generate and store track matrices. "D-AMP_toolbox-master" is used to obtain the support of dam technology.

Test datasets
"gravity.mat" and "period_gravity.mat" are Gravity anomaly datasets. The size of "gravity.mat" is 16384, and that of "period_gravity.mat" is 558424. 

Trajectory
“screenUser_128.m” is used to create trajectory matrixes of the participants, which can be used in "./Source codes/Tools/". “change_500people_200to500steps_0to100go.mat” means to recruit 500 participants, and each person walks 200-500 steps, respectively.