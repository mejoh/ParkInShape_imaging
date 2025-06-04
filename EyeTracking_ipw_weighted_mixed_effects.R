# Weighted analysis of eye-tracking
library(lme4)
library(lmerTest)
f <- 'F:/Dokument/Donders/ParkInShape/data/Eye-tracking/FromIan/Performance_SPSS_withYOE_ForImputation_long.csv'
df <- read_csv(f) %>%
    mutate(GroupNumber = factor(GroupNumber, labels = c('Aerobic', 'Stretching')),
        Time = factor(Time, labels = c('Baseline', 'FollowUp')), 
        Task = factor(Task, labels = c('Pro','Anti')),
        Switch = factor(Switch, labels = c('None','-200','-100','0','100')),
        Name = str_sub(Name,2,6)) %>%
    relocate(Name, GroupNumber, Time, Task, Switch, PercentageCorrect, ipw)
#df <- df %>%       # Just a reminder of how IPW is calculated
#  mutate(ipw = (MissingBA/Propensity) + ((1-MissingBA) / (1-Propensity)))
m1_unweighted <- lmer(PercentageCorrect ~ 1 + GroupNumber*Time*Task*Switch + (1|Name), data = df)
anova(m1_unweighted)
m1_weighted <- lmer(PercentageCorrect ~ 1 + GroupNumber*Time*Task*Switch + (1|Name), data = df, weights = ipw)
anova(m1_weighted)