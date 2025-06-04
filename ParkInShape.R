library(tidyverse)
library(cowplot)
library(retimes)
library(reshape2)
library(lme4)
library(dplyr)
library(tidyr)
library(ggsignif)
library(ggpubr)
library(ggsci)
library(gridExtra)

###---Data---###
################

Subject <- c('PS003', 'PS012', 'PS014', 'PS017', 'PS019', 'PS021', 'PS025', 'PS026', 'PS027', 'PS032', 'PS033', 'PS035', 'PS037', 'PS038', 'PS041', 'PS044', 'PS045', 'PS046', 'PS052', 'PS053', 'PS057',
                      'PS002', 'PS004', 'PS006', 'PS007', 'PS011', 'PS016', 'PS018', 'PS020', 'PS022', 'PS024', 'PS028', 'PS029', 'PS031', 'PS034', 'PS036', 'PS039', 'PS043', 'PS047', 'PS048', 'PS049', 'PS054', 'PS056', 'PS058', 'PS059', 'PS060')

Intervention <- c(rep('Exercise',21),rep('Control',25))

BasicInfo <- bind_cols(Subject=Subject, Intervention=Intervention)

Updrs_delta <- c(6.00,11.00,9.00,4.00,12.00,-3.00,-8.00,-6.00,2.00,-13.00,-3.00,-6.00,18.00,-3.00,-9.00,-6.00,-7.00,-19.00,-2.00,3.00,-6.00,
                 1.00,.00,3.00,15.00,-4.00,5.00,9.00,9.00,4.00,1.00,.00,-1.00,2.00,2.00,18.00,-7.00,-20.00,-3.00,1.00,-3.00,-1.00,23.00,-4.00,-4.00,-5.00)
Age <- c(51,66,70,61,37,58,64,55,62,58,51,61,64,72,70,62,57,58,46,72,59,
         74,43,58,60,66,63,71,69,70,72,53,53,63,50,64,45,66,66,53,57,68,73,47,66,56)
Dis_dur <- c(41.00,11.00,49.00,23.00,12.00,10.00,20.00,43.00,75.00,140.00,38.00,36.00,78.00,18.00,5.00,9.00,39.00,115.00,13.00,79.00,84.00,
             7.00,38.00,37.00,109.00,21.00,2.00,98.00,97.00,15.00,40.00,94.00,19.00,16.00,83.00,39.00,23.00,78.00,8.00,48.00,79.00,23.00,46.00,5.00,32.00,23.00)
Gender <- c(2,1,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,1,2,1,
            2,1,1,2,2,2,2,2,1,1,1,1,2,1,1,1,2,2,1,1,2,2,2,2,1)

YearsOfEducation <- c(24,0,17,15,11,16,11,11,17,13,15,11,18,12,22,12,14,16,13,18,18,
19,13,12,10,14,16,18,15,13,10,13,20,21,10,12,16,16,13,25,18,16,18,22,31,22)

##### Boxplots for AP and PP deltas per group #####

APsubPP.ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/BsubA_exercise_temp.txt', col_names = FALSE, delim = ' ')
APsubPP.st <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/BsubA_stretch_temp.txt', col_names = FALSE, delim = ' ')
APsubPP <- bind_rows(APsubPP.ex, APsubPP.st)
APsubPP <- bind_cols(BasicInfo, APsubPP)
APsubPP <- APsubPP %>%
        select(-X5) %>%
        mutate(APsubPP=(X1+X2+X3+X4)/4,
               APsubPP.S1=(X2)/1) %>%
        select(Subject,Intervention, APsubPP, APsubPP.S1)

AP.A.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/AP/A_exercise_temp.txt', col_names = FALSE, delim = ' ')
AP.A.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/AP/A_stretch_temp.txt', col_names = FALSE, delim = ' ')
AP.A <- bind_rows(AP.A.Ex, AP.A.St) %>%
        mutate(Timepoint='Baseline') %>%
        select(-X5)
AP.A <- bind_cols(BasicInfo,AP.A)

AP.B.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/AP/B_exercise_temp.txt', col_names = FALSE, delim = ' ')
AP.B.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/AP/B_stretch_temp.txt', col_names = FALSE, delim = ' ')
AP.B <- bind_rows(AP.B.Ex, AP.B.St) %>%
        mutate(Timepoint='FollowUp') %>%
        select(-X5)
AP.B <- bind_cols(BasicInfo,AP.B)

AP <- full_join(AP.A, AP.B) %>%
        mutate(AP=(X1+X2+X3+X4)/4,
               AP.S1=(X2)/1) %>%
        select(Subject,Timepoint,Intervention, AP.S1)
AP.delta <- bind_cols(BasicInfo, AP.S1=(subset(AP, Timepoint=='FollowUp')$AP.S1 - subset(AP, Timepoint=='Baseline')$AP.S1))

PP.A.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/PP/A_exercise_temp.txt', col_names = FALSE, delim = ' ')
PP.A.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/PP/A_stretch_temp.txt', col_names = FALSE, delim = ' ')
PP.A <- bind_rows(PP.A.Ex, PP.A.St) %>%
        mutate(Timepoint='Baseline') %>%
        select(-X5)
PP.A <- bind_cols(BasicInfo,PP.A)

PP.B.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/PP/B_exercise_temp.txt', col_names = FALSE, delim = ' ')
PP.B.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/PP/B_stretch_temp.txt', col_names = FALSE, delim = ' ')
PP.B <- bind_rows(PP.B.Ex, PP.B.St) %>%
        mutate(Timepoint='FollowUp') %>%
        select(-X5)
PP.B <- bind_cols(BasicInfo,PP.B)

PP <- full_join(PP.A, PP.B) %>%
        mutate(PP=(X1+X2+X3+X4)/4,
               PP.S1=(X2)/1) %>%
        select(Subject,Timepoint,Intervention, PP.S1)
PP.delta <- bind_cols(BasicInfo, PP.S1=(subset(PP, Timepoint=='FollowUp')$PP.S1 - subset(PP, Timepoint=='Baseline')$PP.S1))

df.wide <- left_join(AP, PP) %>%
        mutate(Timepoint = as.factor(Timepoint),
               Intervention = as.factor(Intervention))
df.long <- df.wide %>%
        pivot_longer(cols = c('PP.S1', 'AP.S1'),
                     names_to = 'Seed',
                     values_to = 'smn.rsfc') %>%
        mutate(Seed=as.factor(Seed))

df.wide.delta <- left_join(AP.delta,PP.delta)
df.long.delta <- df.wide.delta %>%
        pivot_longer(cols = c('AP.S1','PP.S1'),
                     names_to = 'Seed',
                     values_to = 'smn.rsfc.delta')

df.summary <- df.long.delta %>%
        group_by(Intervention,Seed) %>%
        summarise(n=n(),mean=mean(smn.rsfc.delta),sd=sd(smn.rsfc.delta),se=sd/sqrt(n),upper=mean+se*1.96,lower=mean-se*1.96)

Box_TxSxG <- ggplot(df.long.delta, aes(reorder(Seed, desc(Seed)), smn.rsfc.delta, fill = Intervention)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black') +
        scale_fill_manual('Intervention', labels = c('Stretching', 'Aerobic exercise'), values = c('Control' = 'springgreen4', 'Exercise' = 'violetred4'))
#Box_TxSxG <- Box_TxSxG + 
#        labs(x='Putamen seed-region', y='\u0394 Beta', title = 'Connectivity change between putamen and primary somatosensory cortex') +
#        scale_x_discrete(labels=c('Posterior', 'Anterior')) +
#        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
#              legend.key.size = unit(1,'cm'), legend.text = element_text(size = 20), legend.title = element_text(size = 20, face = 'bold'), legend.position = c(.175, 0.1),
#              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
#              panel.background = element_rect(color = 'white', fill = 'white')) +
#        geom_segment(aes(x=1,y=2,xend=2,yend=2),size=1.4) +
#        geom_segment(aes(x=1,y=2,xend=1,yend=1.5),size=1.4) + geom_segment(aes(x=2,y=2,xend=2,yend=1.5),size=1.4) +
#        geom_segment(aes(x=0.815,y=1.5,xend=1.185,yend=1.5),size=1.4) + geom_segment(aes(x=1.815,y=1.5,xend=2.185,yend=1.5),size=1.4) +
#        geom_segment(aes(x=0.815,y=1.5,xend=0.815,yend=1),size=1.4) + geom_segment(aes(x=1.185,y=1.5,xend=1.185,yend=1),size=1.4) +
#        geom_segment(aes(x=1.815,y=1.5,xend=1.815,yend=1),size=1.4) + geom_segment(aes(x=2.185,y=1.5,xend=2.185,yend=1),size=1.4) + 
#        geom_text(x = 1.5, y = 2.1, label = '*', size = 20) + geom_text(x = 1, y = 1.0, label = '*', size = 20) + geom_text(x = 0.815, y = 0.70, label = '+', size = 13) +
#        guides(fill = guide_legend(override.aes = list(shape = NA)))
Box_TxSxG <- Box_TxSxG + 
  labs(x='Putamen seed-region', y='\u0394 Beta') +
  scale_x_discrete(labels=c('Posterior', 'Anterior')) +
  ylim(-0.5,0.5) +
  theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
        legend.key.size = unit(1,'cm'), legend.text = element_text(size = 20), legend.title = element_text(size = 20, face = 'bold'), legend.position = c(.175, 0.1),
        axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
        panel.background = element_rect(color = 'white', fill = 'white')) +
  geom_segment(aes(x=1,y=.5,xend=2,yend=.5),size=1.4) +
  geom_segment(aes(x=1,y=.5,xend=1,yend=.46),size=1.4) + geom_segment(aes(x=2,y=.5,xend=2,yend=.46),size=1.4) +
  geom_segment(aes(x=0.815,y=.46,xend=1.185,yend=.46),size=1.4) + geom_segment(aes(x=1.815,y=.46,xend=2.185,yend=.46),size=1.4) +
  geom_segment(aes(x=0.815,y=.46,xend=0.815,yend=.42),size=1.4) + geom_segment(aes(x=1.185,y=.46,xend=1.185,yend=.42),size=1.4) +
  geom_segment(aes(x=1.815,y=.46,xend=1.815,yend=.42),size=1.4) + geom_segment(aes(x=2.185,y=.46,xend=2.185,yend=.42),size=1.4) + 
  geom_text(x = 1.5, y = .505, label = '*', size = 20) + geom_text(x = 1, y = .415, label = '*', size = 20) + geom_text(x = 0.815, y = .38, label = '*', size = 20) +
  guides(fill = guide_legend(override.aes = list(shape = NA)))

Box_TxSxG

tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission/Visualizations/TxSxG.tiff", width = 10, height = 10, units = "in", res = 300, compression = "lzw")
Box_TxSxG
dev.off()

#####

##### Boxplots for RFPN deltas per group #####

rfpn.A.ex <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/A_exercise_temp.txt', col_names = FALSE, delim = ' ')
rfpn.A.st <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/A_stretch_temp.txt', col_names = FALSE, delim = ' ')
rfpn.A <- bind_rows(rfpn.A.ex, rfpn.A.st) %>%
        mutate(Timepoint='Baseline') %>%
        select(-X2)
rfpn.A <- bind_cols(BasicInfo,rfpn.A)

rfpn.B.ex <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/B_exercise_temp.txt', col_names = FALSE, delim = ' ')
rfpn.B.st <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/B_stretch_temp.txt', col_names = FALSE, delim = ' ')
rfpn.B <- bind_rows(rfpn.B.ex, rfpn.B.st) %>%
        mutate(Timepoint='FollowUp') %>%
        select(-X2)
rfpn.B <- bind_cols(BasicInfo,rfpn.B)

rfpn <- full_join(rfpn.A, rfpn.B) %>%
        rename(rfpn.rsfc = X1) %>%
        mutate(Timepoint = as.factor(Timepoint),
               Intervention = as.factor(Intervention))

rfpn.delta <- bind_cols(BasicInfo, rfpn.rsfc.delta=(subset(rfpn, Timepoint=='FollowUp')$rfpn.rsfc - subset(rfpn, Timepoint=='Baseline')$rfpn.rsfc))

Box_RFPN <- ggplot(rfpn.delta, aes(x = Intervention, y = rfpn.rsfc.delta)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_RFPN <- Box_RFPN +labs(x='Intervention', y='\u0394 Beta') +
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
              panel.background = element_rect(color = 'white', fill = 'white')) +
        scale_x_discrete(breaks=c("Control","Exercise"), labels=c("Stretching", "Aerobic exercise")) + 
        geom_segment(aes(x=1,y=19,xend=2,yend=19),size=1.4) + 
        geom_segment(aes(x=1,y=19,xend=1,yend=17),size=1.4) + geom_segment(aes(x=2,y=19,xend=2,yend=17),size=1.4) +
        geom_text(x = 1.5, y = 19.3, label = '*', size = 20) + geom_text(x = 2, y = 15.5, label = '*', size = 20)

Box_RFPN

tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission/Visualizations/RFPN.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
Box_RFPN
dev.off()

#####

##### Box plots for saccade performance and amplitude ######

Intervention_Sacc <- c(rep('Exercise',16),rep('Control',22))

AntiSaccErrRate <- c(-21.4205,-0.2397,-18.8796,-8.5562,-19.7678,-24.2967,-13.3681,2.1136,10.6838,-4.2452,3.363,-34.4357,-14.1629,1.1365,17.6035,-14.5831,
                     9.7559,-0.8955,13.5452,-5.34,-16.3738,-1.1183,16.6282,-10.9412,-1.1341,-6.6491,15.7333,7.7739,-0.1491,-4.1649,-13.9833,-11.9442,-6.5255,-2.148,9.8156,-4.6306,9.0862,-18.0782)

SaccAmplitude <- c(0.1372,0.1495,0.1186,-0.0667,1.2082,0.9448,-0.0526,-0.2544,-0.1586,1.0768,-0.2305,0.0752,0.3195,0.9707,-0.3602,0.5692,
-2.344,-0.2621,0.0563,0.2108,-0.1038,-0.4167,-5.9227,0.2685,-1.1776,-0.2674,0.0521,-0.0153,-0.679,-1.1794,0.8867,0.0117,-0.5843,-0.893,0.622,-0.151,-1.2774,-2.2113)

Data_Sacc <- data.frame(Intervention_Sacc, AntiSaccErrRate, SaccAmplitude)
Data_Sacc$Intervention_Sacc <- as.factor(Data_Sacc$Intervention_Sacc)
colnames(Data_Sacc) <- c('Intervention_Sacc','AntiSaccErrRate','SaccAmplitude')

Box_AntiSaccErrRate <- ggplot(Data_Sacc, aes(x = Intervention_Sacc, y = AntiSaccErrRate)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_AntiSaccErrRate <- Box_AntiSaccErrRate +labs(x='Intervention', y='\u0394 Errors (%)') + 
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
              panel.background = element_rect(color = 'white', fill = 'white')) +
        scale_x_discrete(breaks=c("Control","Exercise"), labels=c("Stretching", "Aerobic exercise")) + 
        geom_segment(aes(x=1,y=28,xend=2,yend=28),size=1.4) + 
        geom_segment(aes(x=1,y=28,xend=1,yend=24),size=1.4) + geom_segment(aes(x=2,y=28,xend=2,yend=24),size=1.4) + 
        geom_text(x = 1.5, y = 30, label = '+', size = 13) + geom_text(x = 2, y = 21.2, label = '*', size = 20)

Box_AntiSaccErrRate

Box_Amp <- ggplot(Data_Sacc, aes(x = Intervention_Sacc, y = SaccAmplitude)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_Amp <- Box_Amp +labs(x='Intervention', y='\u0394 Amplitude (degrees)') + 
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
              panel.background = element_rect(color = 'white', fill = 'white')) +
        scale_x_discrete(breaks=c("Control","Exercise"), labels=c("Stretching", "Aerobic exercise")) + 
        geom_segment(aes(x=1,y=2.8,xend=2,yend=2.8),size=1.4) + 
        geom_segment(aes(x=1,y=2.8,xend=1,yend=2.3),size=1.4) + geom_segment(aes(x=2,y=2.8,xend=2,yend=2.3),size=1.4) + 
        geom_text(x = 1.5, y = 2.88, label = '*', size = 20) + 
        geom_text(x = 1, y = 1.9, label = '*', size = 20) + geom_text(x = 2, y = 1.9, label = '*', size = 20)

Box_Amp

extrawidth<- 8.7/3

tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission/Visualizations/PercentageError.tiff", width = 8.7+extrawidth, height = 10, units = "in", res = 300, compression = "lzw")
Box_AntiSaccErrRate
dev.off()

tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission/Visualizations/Amplitude.tiff", width = 8.7+extrawidth, height = 10, units = "in", res = 300, compression = "lzw")
Box_Amp
dev.off()

#####

##### Correlation plots #####

df <- read_csv('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/GroupData.csv')
df <- read_csv('F:/Dokument/Donders/ParkInShape/data/Park-in-Shape_database_clinvar_ImagingCohortOnly.csv')
df <- df %>%
        mutate(Intervention = if_else(Treatment_Code == 1, 'Exercise', 'Control'),
               Intervention = as.factor(Intervention))

varlist <- c('APsubPP_AllC_delta', 'PP_AllC_delta', 'global_pbvc','rfpn_AllC_delta',
          'Delta_UPDRSIII_OFF_Total_redef', 'Delta_UPDRSIII_OFF_Appendicular_redef', 'Delta_UPDRSIII_OFF_axial', 'Delta_UPDRSIII_OFF_tremor_redef',
          'pc_Weighted_Anti_delta', 'TAP_prestatieindex_delta', 'MoCa_delta', 'Totale_ex_time_withinHRZ', 'VO2max_delta')

scatterplots <- function(df, ivdv, xlab, ylab, xtick, ytick){
        
        dat <- df %>%
                select(MRI_code, Intervention, contains(ivdv[1]), contains(ivdv[2])) %>%
                na.omit
        
        df_e <- dat %>%
                filter(Intervention=='Exercise')
        c1_e <- cor.test(df_e[[ivdv[1]]], df_e[[ivdv[2]]])
        r_e <- c1_e$estimate
        p_e <- c1_e$p.value
        df_s <- dat %>%
                filter(Intervention=='Control')
        c1_s <- cor.test(df_s[[ivdv[1]]], df_s[[ivdv[2]]])
        r_s <- c1_s$estimate
        p_s <- c1_s$p.value
        
        xran <- round(range(na.omit(dat[[ivdv[1]]])))
        yran <- round(range(na.omit(dat[[ivdv[2]]])))
        yran_maxtomin <- abs(yran[1]) + abs(yran[2])
        
        g1 <- ggplot(dat, aes_string(x=ivdv[1], y=ivdv[2], group='Intervention', fill='Intervention', color='Intervention')) +
                geom_point(size=6, alpha=.7) +
                geom_smooth(method = 'lm', se = FALSE, lwd = 2) +
                scale_fill_manual(values=c("springgreen4","violetred4"), labels = c("Stretching", "Aerobic")) +
                xlab(xlab) + ylab(ylab) +
                scale_color_manual(values=c("springgreen4","violetred4"), labels = c("Stretching", "Aerobic")) +
                scale_x_continuous(breaks = seq(xran[1], xran[2], by = xtick)) +
                scale_y_continuous(breaks = seq(yran[1], yran[2]+yran[2]*0.4, by = ytick)) +
                annotate(geom="text", x=xran[1], y=yran[2]+yran[2]*0.4,
                         label=paste('Aerobic (n = ', sum(dat$Intervention=='Exercise'), '): r = ', round(r_e, digits = 2), ', p = ', round(p_e, digits = 3), sep = ''),
                         color="black",
                         size = 8,
                         hjust=0) +
                theme_cowplot(font_size = 22) +
                annotate(geom="text",  x=xran[1], y=yran[2]+yran[2]*0.4-yran_maxtomin*0.1,
                         label=paste('Stretching (n = ', sum(dat$Intervention=='Control'), '): r = ', round(r_s, digits = 2), ', p = ', round(p_s, digits = 3), sep = ''),
                         color="black",
                         size = 8,
                         hjust=0) +
                theme_cowplot(font_size = 22)
        g1
        
}
scatterplots_onlyex <- function(df, ivdv, xlab, ylab, xtick, ytick, sig, as_treated=FALSE, cormethod='pearson'){
  
  dat <- df %>%
    select(MRI_code, Intervention, Intervention_completed, contains(ivdv[1]), contains(ivdv[2])) %>%
    filter(Intervention=='Exercise') %>%
    na.omit
  
  if(as_treated==TRUE){
    dat <- dat %>%
      filter(Intervention_completed == 1)
  }
  
  df_e <- dat %>%
    filter(Intervention=='Exercise')
  
  c1_e <- cor.test(df_e[[ivdv[1]]], df_e[[ivdv[2]]], method = cormethod, alternative = 'two.sided')
  r_e <- c1_e$estimate
  p_e <- c1_e$p.value
  
  xran <- round(range(na.omit(dat[[ivdv[1]]])))
  yran <- round(range(na.omit(dat[[ivdv[2]]])))
  yran_maxtomin <- abs(yran[1]) + abs(yran[2])
  
  if(sig==TRUE){
    lt <- 'solid'
  }else{
    lt <- 'dotted'
  }
  g1 <- ggplot(dat, aes_string(x=ivdv[1], y=ivdv[2])) +
    geom_point(size=10, alpha=.7) +
    geom_smooth(method = 'lm', se = FALSE, lwd = 3, color='black', linetype=lt) +
    xlab(xlab) + ylab(ylab) +
    scale_x_continuous(breaks = seq(xran[1], xran[2], by = xtick)) +
    scale_y_continuous(breaks = seq(yran[1], yran[2], by = ytick)) +
    theme(axis.text.x = element_text(size = 40), axis.text.y = element_text(size = 40), axis.title = element_text(size = 40, face = 'bold'), plot.title = element_text(size = 40, face = 'bold', hjust = 0),
          axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
          panel.background = element_rect(color = 'white', fill = 'white')) + 
    annotate(geom="text", x=xran[1], y=yran[2]+yran[2]*0.4,
             label=paste('rho = ', round(r_e, digits = 2), ', p = ', round(p_e, digits = 3), sep = ''),
             color="black",
             size = 15,
             hjust=0)
  g1
  
}

# Motor progression
        # AP - PP
sc1 <- scatterplots_onlyex(df,
                           c('ApsubppDelta', 'UP3TotalDelta'),
                           '\u0394 AP - PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III total score',
                           1, 5, TRUE)
sc2 <- scatterplots_onlyex(df,
                           c('ApsubppDelta', 'UP3TotalNoTremorDelta'),
                           '\u0394 AP - PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III total score (no tremor)',
                           1, 5, TRUE)
sc3 <- scatterplots_onlyex(df,
                           c('ApsubppDelta', 'UP3AppendicularDelta'),
                           '\u0394 AP - PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III appendicular score',
                           1, 5, TRUE)
sc4 <- scatterplots_onlyex(df,
                           c('ApsubppDelta', 'UP3AxialDelta'),
                           '\u0394 AP - PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III axial score',
                           1, 1, TRUE)
sc5 <- scatterplots_onlyex(df,
                           c('ApsubppDelta', 'UP3TremorDelta'),
                           '\u0394 AP - PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III tremor score',
                           1, 2, TRUE)   # Note: Tremor has little to do with cortico-striatal connectivity
sc6 <- scatterplots_onlyex(df,
                           c('ApsubppDelta', 'VO2MaxDelta'),
                           '\u0394 AP - PP connectivity (Z)',
                           '\u0394 VO2Max',
                           1, 2, TRUE)
sc7 <- scatterplots_onlyex(df,
                           c('ApsubppDelta', 'TotalExerciseTimeWithinHRZ'),
                           '\u0394 AP - PP connectivity (Z)',
                           '\u0394 TotalExerciseTimeWithinHRZ',
                           1, 1000, TRUE)
grid.arrange(sc1,sc2, nrow = 2, ncol = 2)
# PP
sc1 <- scatterplots_onlyex(df,
                           c('PpDelta', 'UP3TotalDelta'),
                           '\u0394 PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III total score',
                           1, 5, TRUE)
sc2 <- scatterplots_onlyex(df,
                           c('PpDelta', 'UP3TotalNoTremorDelta'),
                           '\u0394 PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III total score (no tremor)',
                           1, 5, TRUE)
sc3 <- scatterplots_onlyex(df,
                           c('PpDelta', 'UP3AppendicularDelta'),
                           '\u0394 PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III appendicular score',
                           1, 5, TRUE)
sc4 <- scatterplots_onlyex(df,
                           c('PpDelta', 'UP3AxialDelta'),
                           '\u0394 PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III axial score',
                           1, 1, TRUE)
sc5 <- scatterplots_onlyex(df,
                           c('PpDelta', 'UP3TremorDelta'),
                           '\u0394 PP connectivity (Z)',
                           '\u0394 MDS-UPDRS III tremor score',
                           1, 2, TRUE)   # Note: Tremor has little to do with cortico-striatal connectivity
sc6 <- scatterplots_onlyex(df,
                           c('PpDelta', 'VO2MaxDelta'),
                           '\u0394 PP connectivity (Z)',
                           '\u0394 VO2Max',
                           1, 2, TRUE)
sc7 <- scatterplots_onlyex(df,
                           c('PpDelta', 'TotalExerciseTimeWithinHRZ'),
                           '\u0394 PP connectivity (Z)',
                           '\u0394 TotalExerciseTimeWithinHRZ',
                           1, 1000, TRUE)
# Global PBVC
sc1 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'UP3TotalDelta'),
                           'Percentage-based volume change',
                           '\u0394 MDS-UPDRS III total score',
                           1, 5, TRUE)
sc2 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'UP3TotalNoTremorDelta'),
                           'Percentage-based volume change',
                           '\u0394 MDS-UPDRS III total score (no tremor)',
                           1, 5, TRUE)
sc3 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'UP3AppendicularDelta'),
                           'Percentage-based volume change',
                           '\u0394 MDS-UPDRS III appendicular score',
                           1, 5, TRUE)
sc4 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'UP3AxialDelta'),
                           'Percentage-based volume change',
                           '\u0394 MDS-UPDRS III axial score',
                           1, 1, TRUE)
sc5 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'UP3TremorDelta'),
                           'Percentage-based volume change',
                           '\u0394 MDS-UPDRS III tremor score',
                           1, 2, TRUE)
sc6 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'AlternatingCondsDelta'),
                           'Percentage-based volume change',
                           '\u0394 TAP flexibility',
                           1, 2, TRUE)
sc7 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'MocaDelta'),
                           'Percentage-based volume change',
                           '\u0394 MOCA',
                           1, 2, TRUE)
sc8 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'VO2MaxDelta'),
                           'Percentage-based volume change',
                           '\u0394 VO2Max',
                           1, 2, TRUE)
sc9 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'TotalExerciseTimeWithinHRZ'),
                           'Percentage-based volume change',
                           '\u0394 TotalExerciseTimeWithinHRZ',
                           1, 1000, TRUE)
# Cognitive improvement
# RFPN
sc1 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'PerErrorDelta'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 Anti-saccade errors (%)',
                           5, 5, TRUE)
sc2 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'AlternatingCondsDelta'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 TAP flexibility',
                           5, 5, TRUE)
sc3 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'UP3AxialDelta'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 MDS-UPDRS III axial score',
                           5, 1, TRUE)
sc4 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'UP3TotalDelta'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 MDS-UPDRS III total score',
                           5, 5, TRUE)
sc5 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'UP3TotalNoTremorDelta'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 MDS-UPDRS III total score (no tremor)',
                           5, 5, TRUE)
sc6 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'UP3AppendicularDelta'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 MDS-UPDRS III appendicular score',
                           5, 5, TRUE)
sc7 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'MocaDelta'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 MOCA',
                           5, 5, TRUE)
sc8 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'VO2MaxDelta'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 VO2Max',
                           5, 5, TRUE)
sc9 <- scatterplots_onlyex(df,
                           c('RfpnDelta2', 'TotalExerciseTimeWithinHRZ'),
                           '\u0394 RFPN connectivity (Z)',
                           '\u0394 TotalExerciseTimeWithinHRZ',
                           5, 1000, TRUE)
# Anti-saccade errors
sc1 <- scatterplots_onlyex(df,
                           c('PerErrorDelta', 'AlternatingCondsDelta'),
                           '\u0394 Anti-saccade errors (%)',
                           '\u0394 TAP flexibility',
                           5, 5, TRUE)
sc2 <- scatterplots_onlyex(df,
                           c('PerErrorDelta', 'UP3AxialDelta'),
                           '\u0394 Anti-saccade errors (%)',
                           '\u0394 MDS-UPDRS III axial score',
                           5, 1, TRUE)
sc3 <- scatterplots_onlyex(df,
                           c('PerErrorDelta', 'UP3TotalDelta'),
                           '\u0394 Anti-saccade errors (%)',
                           '\u0394 MDS-UPDRS III total score',
                           5, 5, TRUE)
sc4 <- scatterplots_onlyex(df,
                           c('PerErrorDelta', 'UP3TotalNoTremorDelta'),
                           '\u0394 Anti-saccade errors (%)',
                           '\u0394 MDS-UPDRS III total score (no tremor)',
                           5, 5, TRUE)
sc5 <- scatterplots_onlyex(df,
                           c('PerErrorDelta', 'UP3AppendicularDelta'),
                           '\u0394 Anti-saccade errors (%)',
                           '\u0394 MDS-UPDRS III appendicular score',
                           5, 5, TRUE)
sc6 <- scatterplots_onlyex(df,
                           c('PerErrorDelta', 'MocaDelta'),
                           '\u0394 Anti-saccade errors (%)',
                           '\u0394 MOCA',
                           5, 5, TRUE)
sc7 <- scatterplots_onlyex(df,
                           c('PerErrorDelta', 'VO2MaxDelta'),
                           '\u0394 Anti-saccade errors (%)',
                           '\u0394 VO2Max',
                           5, 5, TRUE)
sc8 <- scatterplots_onlyex(df,
                           c('PerErrorDelta', 'TotalExerciseTimeWithinHRZ'),
                           '\u0394 Anti-saccade errors (%)',
                           '\u0394 TotalExerciseTimeWithinHRZ',
                           5, 1000, TRUE)
# Global PBVC and primary outcomes
sc1 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'ApsubppDelta'),
                           'Percentage-based volume change',
                           '\u0394 AP-PP connectivity',
                           1, 1, TRUE)
sc2 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'PpDelta'),
                           'Percentage-based volume change',
                           '\u0394 PP connectivity',
                           1, 5, TRUE)
sc3 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'RfpnDelta'),
                           'Percentage-based volume change',
                           '\u0394 RFPN connectivity',
                           1, 1, TRUE)
sc4 <- scatterplots_onlyex(df,
                           c('GlobalPBVC', 'PerErrorDelta'),
                           'Percentage-based volume change',
                           '\u0394 Anti-saccade errors',
                           1, 5, TRUE)
# For plotting
p1 <- scatterplots_onlyex(df,
                          c('pc_Weighted_Anti_delta', 'Delta_UPDRSIII_OFF_axial'),
                          '\u0394 Anti-saccade errors (%)',
                          '\u0394 MDS-UPDRS III axial score',
                          10, 1, TRUE, as_treated = FALSE, cormethod = 'spearman')
p2 <- scatterplots_onlyex(df,
                          c('rfpn_AllC_delta', 'VO2max_delta'),
                          '\u0394 DLPFC - RFPN connectivity',
                          '\u0394 VO2 max',
                          2, 2, TRUE, as_treated = FALSE, cormethod = 'spearman')
p3 <- scatterplots_onlyex(df,
                          c('pc_Weighted_Anti_delta', 'VO2max_delta'),
                          '\u0394 Anti-saccade errors (%)',
                          '\u0394 VO2 max',
                          10, 1, TRUE, as_treated = FALSE, cormethod = 'spearman')
p <- grid.arrange(p3, p2, nrow = 1, ncol = 2)

tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission2/Visualizations/Scatter_PerError-Axial.tiff", width = 10.2, height = 10, units = "in", res = 300, compression = "lzw")
p1
dev.off()


tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission2/Visualizations/Scatter_Rfpn-VO2max.tiff", width = 22, height = 10, units = "in", res = 300, compression = "lzw")
p2
dev.off()

tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission2/Visualizations/Scatter_PerError-VO2max.tiff", width = 10.2, height = 10, units = "in", res = 300, compression = "lzw")
p3
dev.off()

# tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission2/Visualizations/Scatter_ClinCorrs.tiff", units = "in", res = 300, compression = "lzw")
# p
# dev.off()

#####

##### Effect sizes #####

library(effectsize)

summarystats <- c('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/BsubA_exercise_temp.txt',
                 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/BsubA_stretch_temp.txt')
APsubPP.BsubA.Ex <- read_delim(summarystats[1], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=1)
APsubPP.BsubA.St <- read_delim(summarystats[2], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=0)
APsubPP.BsubA <- full_join(APsubPP.BsubA.Ex, APsubPP.BsubA.St) %>%
        mutate(Intervention = as.factor(Intervention))
APsubPP.BsubA %>%
        group_by(Intervention) %>%
        summarise(m1=mean(X1),s1=sd(X1),m2=mean(X2),s2=sd(X2),m3=mean(X3),s3=sd(X3),m4=mean(X4),s4=sd(X4))
hedges_g(X4 ~ Intervention, data = APsubPP.BsubA)
hedges_g(X3 ~ Intervention, data = APsubPP.BsubA)
hedges_g(X2 ~ Intervention, data = APsubPP.BsubA)
hedges_g(X1 ~ Intervention, data = APsubPP.BsubA)

summarystats <- c('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/followup/results/APsubPP/B_exercise_temp.txt',
                  'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/followup/results/APsubPP/B_stretch_temp.txt')
APsubPP.T2.Ex <- read_delim(summarystats[1], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=0)
APsubPP.T2.St <- read_delim(summarystats[2], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=1)
APsubPP.T2 <- full_join(APsubPP.T2.Ex, APsubPP.T2.St) %>%
        mutate(Intervention = as.factor(Intervention))
APsubPP.T2 %>%
        group_by(Intervention) %>%
        summarise(m1=mean(X1),s1=sd(X1),m2=mean(X2),s2=sd(X2),m3=mean(X3),s3=sd(X3))
hedges_g(X3 ~ Intervention, data = APsubPP.T2)
hedges_g(X2 ~ Intervention, data = APsubPP.T2)
hedges_g(X1 ~ Intervention, data = APsubPP.T2)

summarystats <- c('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/stretch_AgtB/BsubA_stretch_temp.txt')
APsubPP.BsubA.StOnly <- read_delim(summarystats, delim=' ', col_names = FALSE)
APsubPP.BsubA.StOnly %>%
  summarise(m1=mean(X1),s1=sd(X1),m2=mean(X2),s2=sd(X2))
hedges_g('X2', data = APsubPP.BsubA.StOnly)
hedges_g('X1', data = APsubPP.BsubA.StOnly)

summarystats <- c('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/BsubA_exercise_temp.txt',
                  'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/BsubA_stretch_temp.txt')
PP.BsubA.Ex <- read_delim(summarystats[1], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=1)
PP.BsubA.St <- read_delim(summarystats[2], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=0)
PP.BsubA <- full_join(PP.BsubA.Ex, PP.BsubA.St) %>%
        mutate(Intervention = as.factor(Intervention))
PP.BsubA %>%
        group_by(Intervention) %>%
        summarise(m1=mean(X1),s1=sd(X1),m2=mean(X2),s2=sd(X2))
hedges_g(X2 ~ Intervention, data = PP.BsubA)
hedges_g(X1 ~ Intervention, data = PP.BsubA)

summarystats <- c('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/followup/results/PP/B_exercise_temp.txt',
                  'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/followup/results/PP/B_stretch_temp.txt')
PP.T2.Ex <- read_delim(summarystats[1], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=1)
PP.T2.St <- read_delim(summarystats[2], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=0)
PP.T2 <- full_join(PP.T2.Ex, PP.T2.St) %>%
        mutate(Intervention = as.factor(Intervention))
PP.T2 %>%
        group_by(Intervention) %>%
        summarise(m1=mean(X1),s1=sd(X1),m2=mean(X2),s2=sd(X2))
hedges_g(X2 ~ Intervention, data = PP.T2)
hedges_g(X1 ~ Intervention, data = PP.T2)

summarystats <- c('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/stretch_BgtA/BsubA_stretch_temp.txt')
PP.BsubA.StOnly <- read_delim(summarystats, delim=' ', col_names = FALSE)
PP.BsubA.StOnly %>%
        summarise(m1=mean(X1),s1=sd(X1),m2=mean(X2),s2=sd(X2))
hedges_g('X2', data = PP.BsubA.StOnly)
hedges_g('X1', data = PP.BsubA.StOnly)

summarystats <- c('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/BsubA_exercise_temp.txt',
                  'P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/BsubA_stretch_temp.txt')
RFPN.BsubA.Ex <- read_delim(summarystats[1], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=0)
RFPN.BsubA.St <- read_delim(summarystats[2], delim=' ', col_names = FALSE) %>%
        mutate(Intervention=1)
RFPN.BsubA <- full_join(RFPN.BsubA.Ex, RFPN.BsubA.St) %>%
        mutate(Intervention = as.factor(Intervention))
RFPN.BsubA %>%
        group_by(Intervention) %>%
        summarise(m1=mean(X1),s1=sd(X1))
hedges_g(X1 ~ Intervention, data = RFPN.BsubA)

summarystats <- c('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/aerobic_BgtA/BsubA_exercise_temp.txt')
RFPN.BsubA.ExOnly <- read_delim(summarystats[1], delim=' ', col_names = FALSE)
RFPN.BsubA.ExOnly %>%
        summarise(m1=mean(X1),s1=sd(X1),m2=mean(X2),s2=sd(X2))
hedges_g('X2', data = RFPN.BsubA.ExOnly)
hedges_g('X1', data = RFPN.BsubA.ExOnly)

#####

### ------------ DEPRECATED -------------- ###

#APsubPP_SMN_Cluster1 <- c(3.447771,1.415602,3.346409,0.802264,4.690768,0.295512,-0.002721,0.005206,3.386957,-3.408761,0.681277,5.915114,0.618903,0.567495,1.318524,3.554383,0.624205,0.689049,1.582343,0.978534,2.448056,
#-1.012505,-2.426723,-2.482623,-6.488969,-2.506401,2.990111,-5.022625,-2.571496,-1.451685,-1.938170,-5.773273,-0.480890,-2.973196,2.589964,2.238116,-3.904871,-1.662712,0.117552,-2.422592,1.952380,-0.226551,-0.348038,-2.482181,-2.961648,0.263432)
#APsubPP_SMN_Cluster2 <- c(3.321181,2.471924,2.755434,0.938590,3.596571,1.081256,3.835186,-0.550708,2.721269,0.456821,1.553459,-0.268525,-0.746478,-2.350933,1.984193,5.313546,1.046883,-0.095939,0.156686,-1.317278,0.006654,
#-3.749610,-3.950405,-0.057946,-4.420793,-1.529207,0.580108,-0.826893,-6.317052,1.025597,0.304934,2.231487,-3.099509,0.326296,-2.515443,1.453248,-1.243136,-0.357764,-3.037359,-0.926622,1.236209,0.655353,-1.725135,-3.887347,-3.131775,-3.104770)
#APsubPP_SMN <- (APsubPP_SMN_Cluster1 + APsubPP_SMN_Cluster2) / 2

PP_SMN_Cluster1 <- c(-0.752189,0.112495,0.383390,1.142299,-1.606283,-1.529385,-0.621961,-1.606942,-0.343723,0.259906,-1.986027,-0.044157,1.035062,0.888876,-0.758319,-2.679902,0.684817,0.991093,-2.152250,1.296580,0.084274,
2.454186,1.855178,-0.197572,3.200014,1.317163,3.279744,2.355900,2.683088,0.983785,-0.782303,-0.733905,1.636053,0.546147,2.919385,-1.278960,-2.780740,0.623869,1.832198,-0.042259,0.984566,-0.455868,0.517528,1.940291,1.213843,1.029316)
PP_SMN_Cluster2 <- c(0.078414,1.073237,-0.701858,-0.410935,-4.961335,-0.813036,-0.547634,-1.303701,1.233623,1.263135,-2.202057,-1.160897,-0.342365,-2.694716,-0.135992,-3.393622,-1.204124,-0.106772,-5.382552,-0.355843,0.557165,
1.932885,5.142215,-0.411865,4.825442,0.876461,0.584023,1.236906,1.565655,1.221779,-0.066302,3.757782,1.094841,-0.045329,2.454599,0.280973,-0.033189,1.352943,1.601472,2.126159,-2.436826,-1.531092,-0.834736,2.745080,1.238386,-0.335097)
PP_SMN <- (PP_SMN_Cluster1 + PP_SMN_Cluster2) / 2     # This data is taken from the post hoc test for PP

AP_SMN_Cluster1 <- c(4.747059,2.259222,2.299450,-0.202237,1.675786,0.525792,-0.012358,-1.186552,3.376703,-2.498480,-1.654878,3.240499,0.781198,-0.388007,2.412366,0.368605,-0.700979,0.326586,-2.979510,0.241987,1.511111,
1.371823,0.144185,-2.808967,-1.205148,-0.573050,1.651934,-4.310653,-1.228919,1.578787,-0.735396,-4.315010,1.529530,-3.760999,2.761226,0.649350,-4.869190,-0.363551,2.015147,-0.885444,2.144995,-2.136325,-0.120161,-0.030944,-1.908677,-0.587267)
AP_SMN_Cluster2 <- c(2.618097,2.463524,3.304487,1.644189,2.430453,0.360707,2.604972,-1.949615,1.900335,0.328588,-0.553462,-0.391643,-0.008168,-1.996503,1.225228,2.562551,2.052780,0.221042,-2.053027,0.295504,-0.272722,
-1.724356,-1.643186,-0.403177,-1.391865,0.007033,3.728038,1.728091,-4.327205,2.053120,-0.416397,1.973882,-1.221598,0.827562,0.344444,0.222292,-4.002574,-0.750216,-1.022415,-1.063297,2.174819,-0.316465,-1.779882,-2.139414,-2.016657,-1.973285)
AP_SMN <- (AP_SMN_Cluster1 + AP_SMN_Cluster2) / 2     # This data is taken from the the APsubPP test, note difference with PP_SMN

VBM_SMN <- c(0.021447,-0.002824,0.012849,0.002731,-0.011298,-0.005936,-0.005482,-0.001132,-0.021548,-0.031733,-0.001623,0.005928,-0.032495,-0.003236,0.008222,-0.005382,0.006123,-0.024720,0.029625,-0.032556,-0.004254,
-0.041700,-0.013155,-0.021312,-0.038800,0.000140,-0.004119,-0.042583,-0.024924,-0.005997,0.031078,0.007584,0.003167,-0.051346,-0.010133,0.012693,0.012892,-0.032966,-0.042303,-0.017257,-0.005505,-0.007968,-0.035715,-0.009147,-0.021758,-0.031655)

RFPN_Cluster1 <- c(-3.696170,4.567544,2.042282,7.915059,-2.588662,-1.839521,2.479584,-1.983542,9.207403,2.258575,1.305280,3.331700,2.219812,6.028119,2.644463,0.383331,2.488215,3.155146,5.159703,4.662817,-2.327176,
8.253058,-1.345592,0.458303,-13.322061,-2.845172,-6.525143,-3.594682,-8.230032,4.343353,-1.221952,1.724409,-1.652735,2.074127,-0.396632,1.958618,-3.656619,-4.194560,-0.947370,-17.361244,0.183505,-3.263255,-0.295136,-4.106146,-13.680952,-2.933446)
RFPN_Cluster2 <- c(5.982694,10.514097,9.845662,11.594073,7.466626,1.972779,9.145643,1.120560,-2.946462,-0.766805,-4.864542,5.105434,6.094304,4.138912,8.458503,6.753234,0.369612,-9.078521,12.425019,18.500631,3.060282,
1.700837,2.629428,-5.212659,-16.465374,-3.090759,8.661646,-9.236493,-7.404951,-3.296015,2.630277,2.754254,12.497836,2.367301,0.611527,8.285959,-4.323031,-4.647555,0.811016,-4.627601,-2.598360,-3.146438,0.427342,-2.730709,-18.844887,-5.985189)
RFPN_Cluster3 <- c(3.843947,8.923572,15.860322,6.847818,3.496977,2.233487,4.176726,-0.803730,-2.691334,2.622458,1.644216,18.673138,7.280929,1.332288,4.478042,-3.163726,1.096862,4.454806,17.832470,2.380427,3.206897,
5.013810,1.407470,3.985469,-1.465024,-1.161830,5.933641,-10.924913,-7.128805,-0.468349,-4.462635,-1.056814,9.505643,-8.174335,-2.833606,3.128396,4.066674,-1.858587,0.612877,2.449648,-7.867718,-4.308507,-1.167458,-4.043759,-12.525864,-6.346723)
RFPN_Cluster4 <- c(6.870051,5.796588,11.710742,2.405822,1.487784,2.332157,1.061923,1.174267,3.686598,-2.494060,5.562808,8.406304,-0.373301,7.070974,5.511943,1.843355,3.965636,1.471124,11.726097,6.494297,0.883265,
1.356140,1.002260,1.375195,-10.425858,-1.262751,6.210872,-4.851394,-2.003754,-0.511533,-0.491087,1.345838,1.433451,1.188029,0.553016,-0.622311,-5.907016,-6.345919,3.250826,-5.485410,0.361917,-4.197572,0.086934,-4.201794,-2.916258,-5.946467)
RFPN <- (RFPN_Cluster1 + RFPN_Cluster2 + RFPN_Cluster3 + RFPN_Cluster4) / 4

Data <- data.frame(Subject, Intervention, APsubPP_SMN, PP_SMN, AP_SMN, VBM_SMN, RFPN)
Data$Intervention <- as.factor(Data$Intervention)
colnames(Data) <- c('Subject','Intervention','APsubPP_SMN', 'PP_SMN', 'AP_SMN','VBM_SMN','RFPN')

putamen_smn.melt <- melt(Data[c(1,2,4,5)], id.vars = c('Subject','Intervention'))
colnames(putamen_smn.melt) <- c('Subject','Intervention','Seed','FC')
levels(putamen_smn.melt$Seed) <- c('Posterior putamen','Anterior putamen')

# Baseline: IPC
AP_IPC <- read.csv('P:/3011154.01/MJ/FC/higher_level/baseline/AP/A_All_temp.txt', header = FALSE, sep=' ')
AP_IPC <- AP_IPC[,1:2]
colnames(AP_IPC) <- c('AP.Right','AP.Left')
PP_IPC <- read.csv('P:/3011154.01/MJ/FC/higher_level/baseline/PP/A_All_temp.txt', header = FALSE, sep=' ')
PP_IPC <- PP_IPC[,1:2]
colnames(PP_IPC) <- c('PP.Right','PP.Left')
IPC <- bind_cols(id=Subject, AP_IPC,PP_IPC,Intervention=Intervention) %>% tibble
IPC.long <- IPC %>%
        pivot_longer(cols = -c(id, Intervention),
                     names_to = c('Seed','Side'),
                     names_pattern = '(.)P.(.*)',
                     values_to = 'FC') %>%
        mutate(Intervention=as.factor(Intervention),
               Seed=as.factor(Seed),
               Side=as.factor(Side),
               Intervention=if_else(Intervention=='Control','Stretching','Aerobic exercise'))
IPC.long$Intervention <- factor(IPC.long$Intervention, levels=c('Aerobic exercise','Stretching'))
IPC.summary <- IPC.long %>%
        group_by(Intervention, Seed, Side) %>%
        summarise(N=n(), Mean=mean(FC), SD=sd(FC), SE=SD/sqrt(N), Lower95CI=Mean-1.96*SE, Upper95CI=Mean+1.96*SE)

IPC.summary.r <- IPC.summary %>%
        filter(Side=='Right')
ggplot(IPC.summary.r, aes(x=Seed, y=Mean, fill=Intervention)) +
        geom_bar(aes(x=Seed, y=Mean, fill=Intervention), stat='identity', position=position_dodge(), size=1, colour='black', data=IPC.summary.r) +
        scale_fill_manual('Intervention', values=c('Stretching' = 'white', 'Aerobic exercise' = 'darkgrey')) +
        geom_errorbar(aes(ymin=Mean-SE, ymax=Mean+SE), stat='identity', position=position_dodge(0.9), width=0.3, size=1, data=IPC.summary.r) +
        theme_cowplot(font_size = 25, line_size = 0.8) +
        labs(title = 'Functional connectivity of the right IPC at baseline') +
        xlab('Putamen seed-region') +
        ylab('Functional connectivity (Z)') +
        scale_x_discrete(labels=c('AP','PP')) +
        coord_trans(x='reverse') +
        guides(fill = guide_legend(reverse = TRUE)) +
        ylim(-0.2,1.7) +
        geom_text(x=1.5,y=1.7,label='*',size=10) +
        geom_text(x=0.77,y=1.55,label='*',size=10) +
        geom_text(x=1.23,y=1.55,label='*',size=10) +
        geom_segment(aes(x=1,xend=2,y=1.68,yend=1.68), size=1) +
        geom_text(x=1,y=1.65,label='ns', size=10) +
        geom_segment(aes(x=0.75,xend=1.25,y=1.6,yend=1.6), size=1) +
        geom_text(x=2,y=1.65,label='ns', size=10) +
        geom_segment(aes(x=1.75,xend=2.25,y=1.6,yend=1.6), size=1)

IPC.summary.l <- IPC.summary %>%
        filter(Side=='Left')
ggplot(IPC.summary.r, aes(x=Seed, y=Mean, fill=Intervention)) +
        geom_bar(aes(x=Seed, y=Mean, fill=Intervention), stat='identity', position=position_dodge(), size=1, colour='black', data=IPC.summary.l) +
        scale_fill_manual('Intervention', values=c('Stretching' = 'white', 'Aerobic exercise' = 'darkgrey')) +
        geom_errorbar(aes(ymin=Mean-SE, ymax=Mean+SE), stat='identity', position=position_dodge(0.9), width=0.3, size=1, data=IPC.summary.l) +
        theme_cowplot(font_size = 25, line_size = 0.8) +
        labs(title = 'Functional connectivity of the left IPC at baseline') +
        xlab('Putamen seed-region') +
        ylab('Functional connectivity (Z)') +
        scale_x_discrete(labels=c('AP','PP')) +
        coord_trans(x='reverse') +
        guides(fill = guide_legend(reverse = TRUE)) +
        ylim(-0.3,1.8) +
        geom_text(x=1.5,y=1.8,label='*',size=10) +
        geom_text(x=0.77,y=1.64,label='*',size=10) +
        geom_text(x=1.23,y=1.64,label='*',size=10) +
        geom_segment(aes(x=1,xend=2,y=1.78,yend=1.78), size=1) +
        geom_text(x=1,y=1.75,label='ns', size=10) +
        geom_segment(aes(x=0.75,xend=1.25,y=1.69,yend=1.69), size=1)+
        geom_text(x=2,y=1.75,label='ns', size=10) +
        geom_segment(aes(x=1.75,xend=2.25,y=1.69,yend=1.69), size=1)

# Baseline / Follow-up, separately


# APsubPP_SMN
Data.summary.APsubPP_SMN <- Data %>%
  group_by(Intervention) %>%
  dplyr::summarise(
    APsubPP_SMN=mean(APsubPP_SMN, na.rm = TRUE),
    SE=c(0)
    )
Data.summary.APsubPP_SMN$SE <- c(sd(subset(Data$APsubPP_SMN, Data$Intervention == 'Control')),sd(subset(Data$APsubPP_SMN, Data$Intervention == 'Exercise'))) / c(sqrt(25),sqrt(21))

# PP_SMN
Data.summary.PP_SMN <- Data %>%
  group_by(Intervention) %>%
  dplyr::summarise(
    PP_SMN=mean(PP_SMN, na.rm = TRUE),
    SE=c(0)
  )
Data.summary.PP_SMN$SE <- c(sd(subset(Data$PP_SMN, Data$Intervention == 'Control')),sd(subset(Data$PP_SMN, Data$Intervention == 'Exercise'))) / c(sqrt(25),sqrt(21))

# AP_SMN
Data.summary.AP_SMN <- Data %>%
  group_by(Intervention) %>%
  dplyr::summarise(
    AP_SMN=mean(AP_SMN, na.rm = TRUE),
    SE=c(0)
  )
Data.summary.AP_SMN$SE <- c(sd(subset(Data$AP_SMN, Data$Intervention == 'Control')),sd(subset(Data$AP_SMN, Data$Intervention == 'Exercise'))) / c(sqrt(25),sqrt(21))

# Combine AP and PP
Data.summary.Combined <- data.frame(1:4,1,1,1)
colnames(Data.summary.Combined) <- c('Seed', 'Intervention', 'FC', 'SE')
Data.summary.Combined[1:4,1] <- c('Anterior putamen','Anterior putamen','Posterior putamen','Posterior putamen')
Data.summary.Combined[1:4,2] <- c('Control','Exercise','Control','Exercise')
Data.summary.Combined$Seed <- factor(Data.summary.Combined$Seed)
Data.summary.Combined$Intervention <- factor(Data.summary.Combined$Intervention)
Data.summary.Combined[1,3] <- Data.summary.AP_SMN[1,2]
Data.summary.Combined[2,3] <- Data.summary.AP_SMN[2,2]
Data.summary.Combined[3,3] <- Data.summary.PP_SMN[1,2]
Data.summary.Combined[4,3] <- Data.summary.PP_SMN[2,2]
Data.summary.Combined[1,4] <- Data.summary.AP_SMN[1,3]
Data.summary.Combined[2,4] <- Data.summary.AP_SMN[2,3]
Data.summary.Combined[3,4] <- Data.summary.PP_SMN[1,3]
Data.summary.Combined[4,4] <- Data.summary.PP_SMN[2,3]

# VBM_SMN
Data.summary.VBM_SMN <- Data %>%
  group_by(Intervention) %>%
  dplyr::summarise(
    VBM_SMN=mean(VBM_SMN, na.rm = TRUE),
    SE=c(0)
  )
Data.summary.VBM_SMN$SE <- c(sd(subset(Data$VBM_SMN, Data$Intervention == 'Control')),sd(subset(Data$VBM_SMN, Data$Intervention == 'Exercise'))) / c(sqrt(25),sqrt(21))

# RFPN
Data.summary.RFPN <- Data %>%
  group_by(Intervention) %>%
  dplyr::summarise(
    RFPN=mean(RFPN, na.rm = TRUE),
    SE=c(0)
  )
Data.summary.RFPN$SE <- c(sd(subset(Data$RFPN, Data$Intervention == 'Control')),sd(subset(Data$RFPN, Data$Intervention == 'Exercise'))) / c(sqrt(25),sqrt(21))

# Saccade
Intervention_Sacc <- c(rep('Exercise',16),rep('Control',22))

#AntiSaccErrRate <- c(-21.4205,-0.2397,-18.8796,-8.5562,-19.7678,-24.2967,-13.3681,2.1136,10.6838,-4.2452,3.363,-34.4357,-14.1629,1.1365,17.6035,-14.5831,
#                     9.7559,-0.8955,13.5452,-5.34,-16.3738,-1.1183,16.6282,-10.9412,-1.1341,-6.6491,15.7333,7.7739,-0.1491,-4.1649,-13.9833,-11.9442,-6.5255,-2.148,9.8156,-4.6306,9.0862,-18.0782)
AntiSaccErrRate <- c(25.26, .15, 20.12, 9.77, 22.51, 23.50, 17.59, -2.19, -9.75, 5.69, -1.67, 36.79, 11.47, -.03, -18.59, 11.56,
                     -5.81, .78, -17.57, 6.65, 19.41, 1.02, -17.03, 11.07, 2.72, 7.04, -15.33, -10.58, -1.02, 6.93, 13.01, 9.89, 5.75, 3.74, -7.06, 4.33, -7.11, 13.37)

#SaccAmplitude <- c(0.1372,0.1495,0.1186,-0.0667,1.2082,0.9448,-0.0526,-0.2544,-0.1586,1.0768,-0.2305,0.0752,0.3195,0.9707,-0.3602,0.5692,
#-2.344,-0.2621,0.0563,0.2108,-0.1038,-0.4167,-5.9227,0.2685,-1.1776,-0.2674,0.0521,-0.0153,-0.679,-1.1794,0.8867,0.0117,-0.5843,-0.893,0.622,-0.151,-1.2774,-2.2113)
SaccAmplitude <- c(-.01, .51, .06, -.04, .94, 1.01, -.12, -.18, -.23, .90, -.52, .27, .20, .54, -.41, .57,
                   -2.00, -.13, .10, .07, -.56, -.18, -4.65, -.03, -.68, -.31, -.30, .00, -.82, -1.48, .65, -.26, -.70, -1.17, .34, .39, -1.37, -1.10)

Data_Sacc <- data.frame(Intervention_Sacc, AntiSaccErrRate, SaccAmplitude)
Data_Sacc$Intervention_Sacc <- as.factor(Data_Sacc$Intervention_Sacc)
colnames(Data_Sacc) <- c('Intervention_Sacc','AntiSaccErrRate','SaccAmplitude')

# Anti-Saccade Error Rate
Data.summary.SaccErr <- Data_Sacc %>%
  group_by(Intervention_Sacc) %>%
  dplyr::summarise(
    AntiSaccErrRate=mean(AntiSaccErrRate, na.rm = TRUE),
    SE=c(0)
  )
Data.summary.SaccErr$SE <- c(sd(subset(Data_Sacc$AntiSaccErrRate, Data_Sacc$Intervention_Sacc == 'Control')),sd(subset(Data_Sacc$AntiSaccErrRate, Data_Sacc$Intervention_Sacc == 'Exercise'))) / c(sqrt(16),sqrt(22))

# Saccade Amplitude
Data.summary.SaccAmp <- Data_Sacc %>%
  group_by(Intervention_Sacc) %>%
  dplyr::summarise(
    SaccAmplitude=mean(SaccAmplitude, na.rm = TRUE),
    SE=c(0)
  )
Data.summary.SaccAmp$SE <- c(sd(subset(Data_Sacc$SaccAmplitude, Data_Sacc$Intervention_Sacc == 'Control')),sd(subset(Data_Sacc$SaccAmplitude, Data_Sacc$Intervention_Sacc == 'Exercise'))) / c(sqrt(16),sqrt(22))

################

###---Bar plot---###
####################

# Time x Seed x Group bar plot
bargraph1 <- ggplot(putamen_smn.melt, aes(x = Seed, y = FC, fill=Intervention)) +
  geom_bar(aes(x = Seed, y = FC, fill=Intervention), stat='identity', position=position_dodge(0.9), data = Data.summary.Combined, width = 0.9, size = 1.4, colour = 'black') +
  scale_fill_manual('Intervention', values = c('Control' = 'springgreen4', 'Exercise' = 'violetred4')) +
  geom_errorbar(position = position_dodge(width = 0.9), aes(ymin = FC - SE, ymax = FC + SE), data = Data.summary.Combined, width = 0.25, size = 1.4) +
  geom_jitter(position = position_dodge(0.9), color = "black", size = 2.5, alpha = 1/2) +
  ylim(-4.5,6)
bargraph1 <- bargraph1 + labs(x='Seed-region', y='Beta (follow-up - baseline, Z)', title = 'Sensorimotor network connectivity') +
  theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
        legend.key.size = unit(1,'cm'), legend.text = element_text(size = 30), legend.title = element_text(size = 30, face = 'bold'), legend.position = c(0.5, 0.1),
        axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
        panel.background = element_rect(color = 'white', fill = 'white')) +
  geom_segment(aes(x=1,y=6,xend=2,yend=6),size=1.4) +
  geom_segment(aes(x=1,y=6,xend=1,yend=5.5),size=1.4) + geom_segment(aes(x=2,y=6,xend=2,yend=5.5),size=1.4) +
  geom_segment(aes(x=0.78,y=5.5,xend=1.22,yend=5.5),size=1.4) + geom_segment(aes(x=1.78,y=5.5,xend=2.22,yend=5.5),size=1.4) +
  geom_segment(aes(x=0.78,y=5.5,xend=0.78,yend=5),size=1.4) + geom_segment(aes(x=1.22,y=5.5,xend=1.22,yend=5),size=1.4) +
  geom_segment(aes(x=1.78,y=5.5,xend=1.78,yend=5),size=1.4) + geom_segment(aes(x=2.22,y=5.5,xend=2.22,yend=5),size=1.4) + 
  geom_text(x = 1.5, y = 6.1, label = '*', size = 20) + geom_text(x = 2, y = 5.0, label = '*', size = 20) + geom_text(x = 1.75, y = 4.55, label = '**', size = 20) +
  guides(fill = guide_legend(override.aes = list(shape = NA)))

bargraph1

Box_TxSxG <- ggplot(putamen_smn.melt, aes(Seed, FC, fill = Intervention)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black') +
        scale_fill_manual('Intervention', labels = c('Stretching', 'Aerobic exercise'), values = c('Control' = 'springgreen4', 'Exercise' = 'violetred4'))
Box_TxSxG <- Box_TxSxG + 
        labs(x='Seed-region', y='Beta (follow-up - baseline, Z)', title = 'Sensorimotor network connectivity') +
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              legend.key.size = unit(1,'cm'), legend.text = element_text(size = 20), legend.title = element_text(size = 20, face = 'bold'), legend.position = c(.85, 0.1),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
              panel.background = element_rect(color = 'white', fill = 'white')) +
        geom_segment(aes(x=1,y=6,xend=2,yend=6),size=1.4) +
        geom_segment(aes(x=1,y=6,xend=1,yend=5.5),size=1.4) + geom_segment(aes(x=2,y=6,xend=2,yend=5.5),size=1.4) +
        geom_segment(aes(x=0.815,y=5.5,xend=1.185,yend=5.5),size=1.4) + geom_segment(aes(x=1.815,y=5.5,xend=2.185,yend=5.5),size=1.4) +
        geom_segment(aes(x=0.815,y=5.5,xend=0.815,yend=5),size=1.4) + geom_segment(aes(x=1.185,y=5.5,xend=1.185,yend=5),size=1.4) +
        geom_segment(aes(x=1.815,y=5.5,xend=1.815,yend=5),size=1.4) + geom_segment(aes(x=2.185,y=5.5,xend=2.185,yend=5),size=1.4) + 
        geom_text(x = 1.5, y = 6.1, label = '*', size = 20) + geom_text(x = 1, y = 5.0, label = '*', size = 20) + geom_text(x = 0.815, y = 4.55, label = '**', size = 20) +
        guides(fill = guide_legend(override.aes = list(shape = NA)))

Box_TxSxG

# VBM_SMN
#bargraph2 <- ggplot(Data, aes(x = Intervention, y = VBM_SMN)) +
#  geom_bar(stat = "identity", position = "dodge", data = Data.summary.VBM_SMN, fill = c("springgreen4","violetred4"), width = 1, size = 1.4, colour = 'black') +
#  geom_jitter(position = position_jitter(0), color = "black", size = 2.5, alpha = 1/2) +
#  geom_errorbar(aes(ymin = VBM_SMN - SE, ymax = VBM_SMN + SE), data = Data.summary.VBM_SMN, width = 0.25, size = 1.4) +
#  ylim(-0.06,0.06)
#bargraph2 <- bargraph2 +labs(x='Intervention', y='Grey matter volume (follow-up - baseline, Z)', title = 'Primary motor cortex grey matter volume') + 
#  theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
#        axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
#        panel.background = element_rect(color = 'white', fill = 'white')) +
#  geom_segment(aes(x=1,y=0.06,xend=2,yend=0.06),size=1.4) + 
#  geom_segment(aes(x=1,y=0.06,xend=1,yend=0.0535),size=1.4) + geom_segment(aes(x=2,y=0.06,xend=2,yend=0.0535),size=1.4) + 
#  geom_text(x = 1.5, y = 0.061, label = '*', size = 20) + geom_text(x = 1, y = 0.0485, label = '***', size = 20)

#bargraph2

Box_VBM <- ggplot(Data, aes(x = Intervention, y = VBM_SMN)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_VBM <- Box_VBM +labs(x='Intervention', y='Grey matter volume (follow-up - baseline)', title = 'Primary motor cortex grey matter volume') + 
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
              panel.background = element_rect(color = 'white', fill = 'white')) +
        scale_x_discrete(breaks=c("Control","Exercise"), labels=c("Stretching", "Aerobic exercise")) +
        geom_segment(aes(x=1,y=0.06,xend=2,yend=0.06),size=1.4) + 
        geom_segment(aes(x=1,y=0.06,xend=1,yend=0.0535),size=1.4) + geom_segment(aes(x=2,y=0.06,xend=2,yend=0.0535),size=1.4) + 
        geom_text(x = 1.5, y = 0.061, label = '*', size = 20) + geom_text(x = 1, y = 0.0485, label = '***', size = 20)

Box_VBM

# RFPN
#bargraph3 <- ggplot(Data, aes(x = Intervention, y = RFPN)) +
#  geom_bar(stat = "identity", position = "dodge", data = Data.summary.RFPN, fill = c("springgreen4","violetred4"), width = 1, size = 1.4, colour = 'black') +
#  geom_jitter(position = position_jitter(0), color = "black", size = 2.5, alpha = 1/2) +
#  geom_errorbar(aes(ymin = RFPN - SE, ymax = RFPN + SE), data = Data.summary.RFPN, width = 0.25, size = 1.4) +
#  ylim(-15,20)
#bargraph3 <- bargraph3 +labs(x='Intervention', y='Beta (follow-up - baseline, Z)', title = 'Frontoparietal network connectivity') +
#  theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
#        axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
#        panel.background = element_rect(color = 'white', fill = 'white')) + 
#  geom_segment(aes(x=1,y=19,xend=2,yend=19),size=1.4) + 
#  geom_segment(aes(x=1,y=19,xend=1,yend=17),size=1.4) + geom_segment(aes(x=2,y=19,xend=2,yend=17),size=1.4) +
#  geom_text(x = 1.5, y = 19.3, label = '**', size = 20) + geom_text(x = 2, y = 15.5, label = '*', size = 20)

#bargraph3

Box_RFPN <- ggplot(Data, aes(x = Intervention, y = RFPN)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_RFPN <- Box_RFPN +labs(x='Intervention', y='Beta (follow-up - baseline, Z)', title = 'Frontoparietal network connectivity') +
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
              panel.background = element_rect(color = 'white', fill = 'white')) +
        scale_x_discrete(breaks=c("Control","Exercise"), labels=c("Stretching", "Aerobic exercise")) + 
        geom_segment(aes(x=1,y=19,xend=2,yend=19),size=1.4) + 
        geom_segment(aes(x=1,y=19,xend=1,yend=17),size=1.4) + geom_segment(aes(x=2,y=19,xend=2,yend=17),size=1.4) +
        geom_text(x = 1.5, y = 19.3, label = '**', size = 20) + geom_text(x = 2, y = 15.5, label = '*', size = 20)

Box_RFPN

# AntiSaccade Error Rate
#bargraph4 <- ggplot(Data_Sacc, aes(x = Intervention_Sacc, y = AntiSaccErrRate)) +
#  geom_bar(stat = "identity", position = "dodge", data = Data.summary.SaccErr, fill = c("springgreen4","violetred4"), width = 1, size = 1.4, colour = 'black') +
#  geom_jitter(position = position_jitter(0), color = "black", size = 2.5, alpha = 1/2) +
#  geom_errorbar(aes(ymin = AntiSaccErrRate - SE, ymax = AntiSaccErrRate + SE), data = Data.summary.SaccErr, width = 0.25, size = 1.4) +
#  ylim(-35,30)
#bargraph4 <- bargraph4 +labs(x='Intervention', y='Error rate (follow-up - baseline, %)', title = 'Anti-saccade error rate') + 
#  theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
#        axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
#        panel.background = element_rect(color = 'white', fill = 'white')) + 
#  geom_segment(aes(x=1,y=28,xend=2,yend=28),size=1.4) + 
#  geom_segment(aes(x=1,y=28,xend=1,yend=24),size=1.4) + geom_segment(aes(x=2,y=28,xend=2,yend=24),size=1.4) + 
#  geom_text(x = 1.5, y = 28.5, label = '*', size = 20) + geom_text(x = 2, y = 21.2, label = '*', size = 20)

#bargraph4

Box_AntiSaccErrRate <- ggplot(Data_Sacc, aes(x = Intervention_Sacc, y = AntiSaccErrRate)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_AntiSaccErrRate <- Box_AntiSaccErrRate +labs(x='Intervention', y='Error rate (follow-up - baseline, %)', title = 'Anti-saccade error rate') + 
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
              panel.background = element_rect(color = 'white', fill = 'white')) +
        scale_x_discrete(breaks=c("Control","Exercise"), labels=c("Stretching", "Aerobic exercise")) + 
        geom_segment(aes(x=1,y=28,xend=2,yend=28),size=1.4) + 
        geom_segment(aes(x=1,y=28,xend=1,yend=24),size=1.4) + geom_segment(aes(x=2,y=28,xend=2,yend=24),size=1.4) + 
        geom_text(x = 1.5, y = 28.5, label = '*', size = 20) + geom_text(x = 2, y = 21.2, label = '*', size = 20)

Box_AntiSaccErrRate

# AntiSaccade Amplitude
#bargraph5 <- ggplot(Data_Sacc, aes(x = Intervention_Sacc, y = SaccAmplitude)) +
#  geom_bar(stat = "identity", position = "dodge", data = Data.summary.SaccAmp, fill = c("springgreen4","violetred4"), width = 1, size = 1.4, colour = 'black') +
#  geom_jitter(position = position_jitter(0), color = "black", size = 2.5, alpha = 1/2) +
#  geom_errorbar(aes(ymin = SaccAmplitude - SE, ymax = SaccAmplitude + SE), data = Data.summary.SaccAmp, width = 0.25, size = 1) +
#  ylim(-6,3)
#bargraph5 <- bargraph5 +labs(x='Intervention', y='Amplitude (follow-up - baseline, degrees)', title = 'Pro-saccade amplitude') + 
#  theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
#        axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
#        panel.background = element_rect(color = 'white', fill = 'white')) + 
#  geom_segment(aes(x=1,y=2.8,xend=2,yend=2.8),size=1.4) + 
#  geom_segment(aes(x=1,y=2.8,xend=1,yend=2.3),size=1.4) + geom_segment(aes(x=2,y=2.8,xend=2,yend=2.3),size=1.4) + 
#  geom_text(x = 1.5, y = 2.88, label = '*', size = 20) + geom_text(x = 1, y = 1.9, label = '*', size = 20)

#bargraph5

Box_Amp <- ggplot(Data_Sacc, aes(x = Intervention_Sacc, y = SaccAmplitude)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_Amp <- Box_Amp +labs(x='Intervention', y='Amplitude (follow-up - baseline, degrees)', title = 'Pro-saccade amplitude') + 
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
              panel.background = element_rect(color = 'white', fill = 'white')) +
        scale_x_discrete(breaks=c("Control","Exercise"), labels=c("Stretching", "Aerobic exercise")) + 
        geom_segment(aes(x=1,y=2.8,xend=2,yend=2.8),size=1.4) + 
        geom_segment(aes(x=1,y=2.8,xend=1,yend=2.3),size=1.4) + geom_segment(aes(x=2,y=2.8,xend=2,yend=2.3),size=1.4) + 
        geom_text(x = 1.5, y = 2.88, label = '*', size = 20) + 
        geom_text(x = 1, y = 1.9, label = '*', size = 20) + geom_text(x = 2, y = 1.9, label = '*', size = 20)

Box_Amp

#tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/1_APsubPP.tiff", width = 10, height = 10, units = "in", res = 300, compression = "lzw")
#bargraph1
#dev.off()

tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/1_APsubPP.tiff", width = 10, height = 10, units = "in", res = 300, compression = "lzw")
Box_TxSxG
dev.off()

#tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/2_GM.tiff", width = 10, height = 10, units = "in", res = 300, compression = "lzw")
#bargraph2
#dev.off()

tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/2_GM.tiff", width = 10, height = 10, units = "in", res = 300, compression = "lzw")
Box_VBM
dev.off()

#tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/3_RFPN.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
#bargraph3
#dev.off()

tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/3_RFPN.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
Box_RFPN
dev.off()

#tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/4_ERROR.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
#bargraph4
#dev.off()

tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/4_ERROR.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
Box_AntiSaccErrRate
dev.off()

#tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/5_AMP.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
#bargraph5
#dev.off()

tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/5_AMP.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
Box_Amp
dev.off()

####################

###---Between-group differences and CIs---###
####################

# Formula for calculating CIs for difference scores #
# (X1 - X2) +/- t* sqrt(SD1^2/n1 + SD^2/n2)
# (X1 - X2) is the difference between two means
# t* is the critical t value, in our case t44 = 2.015
# sqrt(SD1^2/n1 + SD^2/n2) is the squared sum of standard errors

Diff <- Data.summary.APsubPP_SMN[2,2] - Data.summary.APsubPP_SMN[1,2]
SSE <- sqrt(Data.summary.APsubPP_SMN[2,3] + Data.summary.APsubPP_SMN[1,3])

Diff <- Data.summary.VBM_SMN[2,2] - Data.summary.VBM_SMN[1,2]
SSE <- sqrt(Data.summary.VBM_SMN[2,3] + Data.summary.VBM_SMN[1,3])

Diff <- Data.summary.RFPN[2,2] - Data.summary.RFPN[1,2]
SSE <- sqrt(Data.summary.RFPN[2,3] + Data.summary.RFPN[1,3])

Diff <- Data.summary.SaccErr[2,2] - Data.summary.SaccErr[1,2]
SSE <- sqrt(Data.summary.SaccErr[2,3] + Data.summary.SaccErr[1,3])

Diff <- Data.summary.SaccAmp[2,2] - Data.summary.SaccAmp[1,2]
SSE <- sqrt(Data.summary.SaccAmp[2,3] + Data.summary.SaccAmp[1,3])


df <- (25-1) + (21-1)
t44 <- 2.015
CIpos <- Diff + t44 * SSE
CIneg <- Diff - t44 * SSE
print(c(Diff, CIpos, CIneg))





####################





library(tidyverse)

##### Files #####
fAP.A.ex <- 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun/results/APsubPP/AP/A_exercise_temp.txt'
fAP.A.st <- 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun/results/APsubPP/AP/A_stretch_temp.txt'
fAP.B.ex <- 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun/results/APsubPP/AP/B_exercise_temp.txt'
fAP.B.st <- 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun/results/APsubPP/AP/B_stretch_temp.txt'
fPP.A.ex <- 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun/results/APsubPP/PP/A_exercise_temp.txt'
fPP.A.st <- 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun/results/APsubPP/PP/A_stretch_temp.txt'
fPP.B.ex <- 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun/results/APsubPP/PP/B_exercise_temp.txt'
fPP.B.st <- 'P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun/results/APsubPP/PP/B_stretch_temp.txt'
#####

##### Data import #####
dAP.A.ex <- read.csv(fAP.A.ex, sep = ' ', header=FALSE, col.names = c('C1','C2','drop'))
dAP.A.st <- read.csv(fAP.A.st, sep = ' ', header=FALSE, col.names = c('C1','C2','drop'))
dAP.B.ex <- read.csv(fAP.B.ex, sep = ' ', header=FALSE, col.names = c('C1','C2','drop'))
dAP.B.st <- read.csv(fAP.B.st, sep = ' ', header=FALSE, col.names = c('C1','C2','drop'))
dPP.A.ex <- read.csv(fPP.A.ex, sep = ' ', header=FALSE, col.names = c('C1','C2','drop'))
dPP.A.st <- read.csv(fPP.A.st, sep = ' ', header=FALSE, col.names = c('C1','C2','drop'))
dPP.B.ex <- read.csv(fPP.B.ex, sep = ' ', header=FALSE, col.names = c('C1','C2','drop'))
dPP.B.st <- read.csv(fPP.B.st, sep = ' ', header=FALSE, col.names = c('C1','C2','drop'))
#####

##### Drop column with NAs #####
dAP.A.ex <- dAP.A.ex %>% select(-drop)
dAP.A.st <- dAP.A.st %>% select(-drop)
dAP.B.ex <- dAP.B.ex %>% select(-drop)
dAP.B.st <- dAP.B.st %>% select(-drop)
dPP.A.ex <- dPP.A.ex %>% select(-drop)
dPP.A.st <- dPP.A.st %>% select(-drop)
dPP.B.ex <- dPP.B.ex %>% select(-drop)
dPP.B.st <- dPP.B.st %>% select(-drop)
#####

##### Average remanining columns #####
dAP.A.ex <- dAP.A.ex %>% mutate(Avg = (C1+C2)/2)
dAP.A.st <- dAP.A.st %>% mutate(Avg = (C1+C2)/2)
dAP.B.ex <- dAP.B.ex %>% mutate(Avg = (C1+C2)/2)
dAP.B.st <- dAP.B.st %>% mutate(Avg = (C1+C2)/2)
dPP.A.ex <- dPP.A.ex %>% mutate(Avg = (C1+C2)/2)
dPP.A.st <- dPP.A.st %>% mutate(Avg = (C1+C2)/2)
dPP.B.ex <- dPP.B.ex %>% mutate(Avg = (C1+C2)/2)
dPP.B.st <- dPP.B.st %>% mutate(Avg = (C1+C2)/2)
#####

##### Assemble dataframe #####
intervention <- as.factor(c(rep('Exercise',21),rep('Stretching',25)))
df <- data.frame(AP.A=c(dAP.A.ex[,'Avg'], dAP.A.st[,'Avg']),
                 AP.B=c(dAP.B.ex[,'Avg'], dAP.B.st[,'Avg']),
                 PP.A=c(dPP.A.ex[,'Avg'], dPP.A.st[,'Avg']),
                 PP.B=c(dPP.B.ex[,'Avg'], dPP.B.st[,'Avg']))
df2 <- df %>% 
        tibble %>%
        bind_cols(intervention=intervention) %>% 
        pivot_longer(cols=1:4, names_to= c('Seed','Session'), values_to='FC', names_pattern='([A-Z][A-Z]).([A-Z])') %>%
        mutate(Seed=as.factor(Seed),
               Session=if_else(Session=='A','Baseline','Follow-up'),
               Session=as.factor(Session))
#####

##### Summarize data #####
df2.summary <- df2 %>%
        group_by(intervention, Seed, Session) %>%
        summarise(N=n(), Mean=mean(FC), SD=sd(FC), SE=SD/sqrt(N), lower=Mean-1.96*SE, upper=Mean+1.96*SE)
#####

##### Plot #####
ggplot(df2.summary, aes(x=Seed, y=Mean, fill=Session)) +
        geom_bar(data=df2.summary, aes(x=Seed,y=Mean, fill=Session), stat='identity', position=position_dodge(0.9), color='black', size=1) +
        geom_errorbar(data=df2.summary, aes(ymin=lower, ymax=upper), stat='identity', position=position_dodge(0.9), width=0.3, size=1) +
        scale_fill_manual('Session', values = c('Baseline' = 'white', 'Follow-up' = 'darkgrey')) +
        facet_grid(. ~ intervention) +
        theme_cowplot(font_size = 25) +
        xlab('Putamen seed-region') +
        ylab('Functional connectivity (Z)') +
        labs(title = 'Functional connectivity of the sensorimotor network')
#####


