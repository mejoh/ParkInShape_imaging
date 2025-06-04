library('tidyverse')
library('reshape2')
library('ggpubr')
library('ggsci')
library('lme4')

### Import data
###############
datafile <- c("P:/3011154.01/MJ/DWI/FreeWater/FreewaterValues.txt")
data <- read_delim(datafile, delim = " ")
datafile <- c("P:/3011154.01/MJ/DWI/FreeWater/FreewaterValues2.txt")
data <- read_delim(datafile, delim = " ")
###############
### Calculate deltas
###############
d1 <- data[8] - data[2]
d2 <- data[9] - data[3]
d3 <- data[10] - data[4]
d4 <- data[11] - data[5]
d5 <- data[12] - data[6]
d6 <- data[13] - data[7]
deltas <- cbind(d1, d2, d3, d4, d5, d6)
colnames(deltas) <- c('dAnt', 'dPost', 'dRAnt', 'dLAnt', 'dRPost', 'dLPost')
###############
### Bind deltas to main data frame
###############
data <- bind_cols(data, deltas)
###############
### Create regressors
###############
intervention <- c(0,	1,	0,	0,	0,	0,	1,	1,	1,	0,	1,	0,	1,	0,	0,	1,	1,	1,	0,	0,	0,	1,	1,	0,	1,	0,	1,	1,	0,	0,	0,	1,	1,	1,	0,	0,	0,	1,	0,	0,	1,	0,	0,	0)
intervention <- as.factor(intervention)
age <- c(74,	51,	43,	58,	60,	66,	66,	70,	61,	71,	37,	69,	58,	70,	72,	64,	55,	62,	53,	53,	63, 58,	51,	50,	61,	64,	64,	72,	45,	65,	66,	62,	57,	58,	66,	53,	57,	46,	68,	73,	59,	47,	66,	56)
gender <- c(0,	0,	1,	1,	0,	0,	1,	0,	0,	0,	0,	0,	1,	1,	1,	0,	0,	0,	1,	1,	0,	0,	0,	1,	0,	1,	0,	0,	1,	0,	0,	0,	0,	0,	0,	1,	1,	1,	0,	0,	1,	0,	0,	1)
gender <- as.factor(gender)
disease_duration <- c(7, 41, 38, 37, 109, 21, 11, 49, 23, 98, 12, 97, 10, 15, 40, 20, 43, 75, 94, 19, 16, 140, 38, 83, 36, 39, 78, 18, 23, 24, 78, 9, 39, 115, 8, 48, 79, 13, 23, 46, 84, 5, 32, 23)
updrs_ba <-c(9,16,7,12,13,24,34,35,33,22,29,9,13,18,25,25,27,29,54,14,36,41,34,59,36,14,17,53,19,30,64,20,33,51,34,32,13,23,42,15,38,30,23,16)
updrs_fu <- c(10,22,7,15,28,20,45,44,37,31,41,18,10,22,26,17,21,31,54,13,38,28,31,61,30,32,35,50,12,42,44,14,26,32,31,33,10,21,41,38,32,26,19,11)
updrs_delta <- updrs_fu - updrs_ba
###############
### Bind regressors to main data frame
###############
data <- bind_cols(data,intervention=intervention,age=age,gender=gender,disease_duration=disease_duration,updrs_ba=updrs_ba,updrs_fu=updrs_fu,updrs_delta=updrs_delta)
###############
### Exclude participants from analysis
###############
exclude <- c('PS012', 'PS028', 'PS034')
exclude <- c()
data <- data[!(data$Subject %in% exclude),]
###############
### Create data frame for LME
###############
mask <- c('ant', 'post')
mask <- c(rep(mask[1],nrow(data)),rep(mask[2],nrow(data)))
data.lme <- data.frame(Subject = data$Subject, Intervention = data$intervention, Mask = mask, Sex = data$gender, Age = data$age, t1 = c(data$t1Ant,data$t1Post), t2 = c(data$t2Ant, data$t2Post), ba_fw = c(data$t1Post), disdur = c(data$disease_duration))
data.lme <- melt(data.lme, id.vars = c('Subject','Intervention', 'Mask', 'Sex', 'Age','ba_fw', 'disdur'))
colnames(data.lme) <- c('Subject', 'Intervention', 'Mask', 'Sex', 'Age', 'BaselineFW', 'DisDur', 'Time', 'FW')
###############

### Bar plot
###############
data.summary.dPost <- data %>%
  group_by(intervention) %>%
  dplyr::summarise(
    dPost=mean(dPost, na.rm = TRUE),
    SE=c(0)
  )
data.summary.dPost$SE <- c(sd(subset(data$dPost, data$intervention == '0')),sd(subset(data$dPost, data$intervention == '1'))) / c(sqrt(23),sqrt(18))

#bargraph <- ggplot(data, aes(x = intervention, y = dPost)) +
#  geom_bar(stat = "identity", position = "dodge", data = data.summary.dPost, fill = c("springgreen4","violetred4"), width = 1, size = 1.4, colour = 'black') +
#  geom_jitter(position = position_jitter(0), color = "black", size = 2.5, alpha = 1/2) +
#  geom_errorbar(aes(ymin = dPost - SE, ymax = dPost + SE), data = data.summary.dPost, width = 0.25, size = 1.4) +
#  ylim(-0.05,0.05)
#bargraph = bargraph +labs(x='Intervention', y='Free water (follow-up - baseline, fv)', title = 'Change in posterior substantia nigra free water') + 
#  theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
#        axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
#        panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(), panel.background = element_blank()) +
#  scale_x_discrete(breaks=c("0","1"), labels=c("Control", "Exercise"))

#bargraph

Box_FW <- ggplot(data, aes(x = intervention, y = dPost)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_FW <- Box_FW +labs(x='Intervention', y='\u0394 Free water (fv)', title = 'Posterior substantia nigra free water') + 
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"),
              panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(), panel.background = element_blank()) +
        scale_x_discrete(breaks=c("0","1"), labels=c("Stretching", "Aerobic exercise"))

Box_FW

#tiff("F:/Dokument/Donders/ParkInShape/visualizations/Graphs/6_FW.tiff", width = 10, height = 10, units = "in", res = 300, compression = "lzw")
#bargraph
#dev.off()

tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission/Visualizations/FW.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
Box_FW
dev.off()

###############
### Interaction plot
###############
data.interaction <- data.lme[data.lme$Mask == 'post',]  # Specify data here
interaction.plot(x.factor = data.interaction$Time, trace.factor = data.interaction$Intervention, response = data.interaction$FW, fun = mean, type = c("l"), col = c("red","blue"), legend = TRUE, trace.label = c('Intervention'), xlab = c('Time'), ylab = c('Free-water'))
###############

### One-way ANCOVA
###############
my.ancova <- aov(dPost ~ 1 + scale(t1Post, center=TRUE, scale=FALSE) + intervention + scale(age, center = TRUE, scale = FALSE) + gender + scale(updrs_ba, center = TRUE, scale = FALSE), data = data)
summary(my.ancova)
plot(my.ancova, 1)
pairwise.t.test(data$dPost, data$intervention, p.adj = 'none')
###############
### Linear mixed effects
###############
# Linear model of the effect of intervention
estimation <- lm(dPost ~ intervention + age + gender, data = data)
#coef(estimation)
summary(estimation)

estimation.null <- lmer(FW ~ Intervention + Time + Age + Sex + (1 + Time|Subject), data.lme[data.lme$Mask == 'post',], REML = FALSE)
estimation.model <- lmer(FW ~ Intervention + Time + Intervention * Time + Age + Sex + (1 + Time|Subject), data.lme[data.lme$Mask == 'post',], REML = FALSE)
coef(estimation.model)
anova(estimation.null, estimation.model)


m1 <- lmer(FW ~ 1 + Time * Intervention + (1|Subject), data=data.lme[data.lme$Mask == 'post',], REML = TRUE)
summary(m1)
anova(m1)

data.lme[data.lme$Mask == 'post',] %>%
        ggplot(aes(x=Intervention,y=FW, color=Time)) +
        geom_boxplot()

data.lme[data.lme$Mask == 'post',] %>%
        group_by(Intervention, Time) %>%
        summarise(n=n())

###############
### Kruskal-Wallis rank sum test
###############

###############
### Test normality
###############
ggdensity(data$t1Post, main = "t1Post density plot")
ggqqplot(data$t1Post)
shapiro.test(data$t1Post)
ggdensity(data$t2Post, main = "t2Post density plot")
ggqqplot(data$t2Post)
shapiro.test(data$t2Post)
###############

### Correlations
###############
group = c('1')
data.corr <- data[data$intervention == group,]
estimation.corr <- lm(data.corr$t1Post ~ data.corr$updrs_ba)                # Association between baseline FW and UPDRS
summary(estimation.corr)
estimation.corr <- lm(data.corr$t2Post ~ data.corr$updrs_fu)                # Association between follow-up FW and UPDRS
summary(estimation.corr)
estimation.corr <- lm(data.corr$dPost ~ data.corr$updrs_delta)              # Association between change in FW and UPDRS
summary(estimation.corr)
estimation.corr <- lm(data.corr$t1Post ~ data.corr$disease_duration)        # Association between baseline FW and disease duration
summary(estimation.corr)
estimation.corr <- lm(data.corr$dPost ~ data.corr$disease_duration)         # Association between change in FW and disease duration
summary(estimation.corr)
estimation.corr <- lm(data.corr$updrs_ba ~ data.corr$disease_duration)      # Association between baseline UPDRS and disease duration
summary(estimation.corr)
estimation.corr <- lm(data.corr$updrs_delta ~ data.corr$disease_duration)   # Association between change in UPDRS and disease duration
summary(estimation.corr)
###############