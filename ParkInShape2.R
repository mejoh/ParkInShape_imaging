library(tidyverse)
library(cowplot)
Subject <- c('PS003', 'PS012', 'PS014', 'PS017', 'PS019', 'PS021', 'PS025', 'PS026', 'PS027', 'PS032', 'PS033', 'PS035', 'PS037', 'PS038', 'PS041', 'PS044', 'PS045', 'PS046', 'PS052', 'PS053', 'PS057',
             'PS002', 'PS004', 'PS006', 'PS007', 'PS011', 'PS016', 'PS018', 'PS020', 'PS022', 'PS024', 'PS028', 'PS029', 'PS031', 'PS034', 'PS036', 'PS039', 'PS043', 'PS047', 'PS048', 'PS049', 'PS054', 'PS056', 'PS058', 'PS059', 'PS060')
Subject <- c(Subject, Subject)
Intervention <- c(rep('Exercise',21), rep ('Stretching',25))
Intervention <- c(Intervention, Intervention)
Session <- c(rep('Baseline',21+25), rep('Follow-up',21+25))
BasicInfo <- tibble(Subject=Subject, Intervention=Intervention, Session=Session) %>%
        mutate(Subject=as.factor(Subject), Intervention=as.factor(Intervention), Session=as.factor(Session))

# APsubPP
APsubPP.A.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/A_exercise_temp.txt', col_names = FALSE, delim = ' ')
APsubPP.B.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/B_exercise_temp.txt', col_names = FALSE, delim = ' ')
APsubPP.A.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/A_stretch_temp.txt', col_names = FALSE, delim = ' ')
APsubPP.B.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/B_stretch_temp.txt', col_names = FALSE, delim = ' ')
APsubPP <- bind_rows(APsubPP.A.Ex, APsubPP.A.St, APsubPP.B.Ex, APsubPP.B.St)
APsubPP <- APsubPP[,-5]
APsubPP <- bind_cols(BasicInfo, APsubPP)
APsubPP <- APsubPP %>%
        mutate(APsubPP.Avg=(X1+X2+X3+X4)/4)

AP.A.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/AP/A_exercise_temp.txt', col_names = FALSE, delim = ' ')
AP.B.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/AP/B_exercise_temp.txt', col_names = FALSE, delim = ' ')
AP.A.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/AP/A_stretch_temp.txt', col_names = FALSE, delim = ' ')
AP.B.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/AP/B_stretch_temp.txt', col_names = FALSE, delim = ' ')
AP <- bind_cols(AP.A.Ex, AP.A.St, AP.B.Ex, AP.B.St)
AP <- AP[,-5]
AP <- bind_rows(BasicInfo, AP)
AP <- AP %>%
        mutate(AP.Avg=(X1+X2+X3+X4)/4)

PP.A.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/PP/A_exercise_temp.txt', col_names = FALSE, delim = ' ')
PP.B.Ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/PP/B_exercise_temp.txt', col_names = FALSE, delim = ' ')
PP.A.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/PP/A_stretch_temp.txt', col_names = FALSE, delim = ' ')
PP.B.St <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/PP/B_stretch_temp.txt', col_names = FALSE, delim = ' ')
PP <- bind_cols(PP.A.Ex, PP.A.St, PP.B.Ex, PP.B.St)
PP <- AP[,-5]
PP <- bind_rows(BasicInfo, PP)
PP <- PP %>%
        mutate(PP.Avg=(X1+X2+X3+X4)/4)

# VBM
#VBM.A.Ex <- read_delim('P:/3011154.01/MJ/FinalResults/VBM/SigSmn/A_ex_temp.txt', col_names = FALSE, delim = ' ')
#VBM.B.Ex <- read_delim('P:/3011154.01/MJ/FinalResults/VBM/SigSmn/B_ex_temp.txt', col_names = FALSE, delim = ' ')
#VBM.A.St <- read_delim('P:/3011154.01/MJ/FinalResults/VBM/SigSmn/A_st_temp.txt', col_names = FALSE, delim = ' ')
#VBM.B.St <- read_delim('P:/3011154.01/MJ/FinalResults/VBM/SigSmn/B_st_temp.txt', col_names = FALSE, delim = ' ')
#VBM <- bind_rows(VBM.A.Ex, VBM.A.St, VBM.B.Ex, VBM.B.St)
#VBM <- VBM[,-2]
#VBM <- bind_cols(BasicInfo, VBM)
#VBM <- VBM %>%
#        mutate(VBM.Avg=X1/1)
# rFPN
rFPN.A.Ex <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/rfpn_BsubA/A_exercise_temp.txt', col_names = FALSE, delim = ' ')
rFPN.B.Ex <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/rfpn_BsubA/B_exercise_temp.txt', col_names = FALSE, delim = ' ')
rFPN.A.St <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/rfpn_BsubA/A_stretch_temp.txt', col_names = FALSE, delim = ' ')
rFPN.B.St <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/rfpn_BsubA/B_stretch_temp.txt', col_names = FALSE, delim = ' ')
rFPN <- bind_rows(rFPN.A.Ex, rFPN.A.St, rFPN.B.Ex, rFPN.B.St)
rFPN <- rFPN[,-2]
rFPN <- bind_cols(BasicInfo, rFPN)
rFPN <- rFPN %>%
        mutate(rFPN.Avg=(X1)/1)
# Anti-saccade
Intervention2 <- c(rep('Exercise',16), rep('Stretching',22))
ErrorRate <- read_csv('P:/3011154.01/MJ/ErrorRate.csv')
ErrorRate <- bind_cols(Intervention = Intervention2, ErrorRate)
ErrorRate <- ErrorRate %>%
        pivot_longer(cols = 2:5, names_to = c('Session','Condition'), values_to = 'Error.percentage', names_sep = '_') %>%
        mutate(Session=if_else(Session == 'A','Baseline','Follow-up')) %>%
        mutate(Session=as.factor(Session),
               Condition=as.factor(Condition))
Amplitude <- read_csv('P:/3011154.01/MJ/Amp.csv')
Amplitude <- bind_cols(Intervention = Intervention2, Amplitude)
Amplitude <- Amplitude %>%
        pivot_longer(cols = 2:5, names_to = c('Session','Condition'), values_to = 'Amplitude', names_sep = '_') %>%
        mutate(Session=if_else(Session == 'A','Baseline','Follow-up')) %>%
        mutate(Session=as.factor(Session),
               Condition=as.factor(Condition))

# Create data frames
df_brain <- bind_cols(BasicInfo, APsubPP=APsubPP$APsubPP.Avg, rFPN=rFPN$rFPN.Avg)
df_behav <- bind_cols(ErrorRate, Amplitude=Amplitude$Amplitude)

# Plotting functions
plot_brain <- function(df,var){
        df <- df %>%
                select(Subject, Intervention, Session, one_of(var))
        colnames(df)[colnames(df) == var] <- 'y'
        g <- ggplot(df, aes(x=Session, y=y)) +
                geom_boxplot(aes(fill=Intervention))
        g + ylab(var) + theme_cowplot(font_size = 25)
}
for(i in c('APsubPP','rFPN')){
        g <- plot_brain(df_brain,i)
        print(g)
}


# Summary
df_brain %>% 
        group_by(Intervention, Session) %>%
        summarise(Mean=mean(APsubPP))

df_behav %>% 
        group_by(Intervention, Session) %>%
        summarise(Mean=mean(Error.percentage))







