# Data preparation
exercise <-   c('PS003', 'PS012', 'PS014', 'PS017', 'PS019', 'PS021', 'PS025', 'PS026', 'PS027', 'PS032',
                'PS033', 'PS035', 'PS037', 'PS038', 'PS041', 'PS044', 'PS045', 'PS046', 'PS052', 'PS053', 'PS057')
age_ex <- c(51,66,70,61,37,58,64,55,62,58,51,61,64,72,70,62,57,58,46,72,59)
gender_ex <- c(2,1,2,2,2,1,2,2,2,2,2,2,2,2,1,2,2,2,1,2,1)
baseline_severity_ex <- c(16,34,35,33,29,13,25,27,29,41,34,36,17,53,37,20,33,51,23,38,38)

stretching <- c('PS002', 'PS004', 'PS006', 'PS007', 'PS011', 'PS016', 'PS018', 'PS020', 'PS022', 'PS024',
                'PS028', 'PS029', 'PS031', 'PS034', 'PS036', 'PS039', 'PS043', 'PS047', 'PS048', 'PS049', 'PS054', 'PS056', 'PS058', 'PS059', 'PS060')
age_st <- c(74,43,58,60,66,63,71,69,70,72,53,53,63,50,64,45,66,66,53,57,68,73,47,66,56)
gender_st <- c(2,1,1,2,2,2,2,2,1,1,1,1,2,1,1,1,2,2,1,1,2,2,2,2,1)
baseline_severity_st <- c(9,7,12,13,24,15,22,9,18,25,54,14,36,59,14,19,64,34,32,13,42,15,30,16,23)

subject <- c(exercise, stretching)
age <- c(age_ex, age_st)
gender <- c(gender_ex, gender_st)
updrs3_ba <- c(baseline_severity_ex, baseline_severity_st)
intervention <- c(rep('ex',21), rep('con',25))
pbvc <- rep(NA, length(subject))
df <- bind_cols(subject=subject, age=age, gender=gender, updrs3_ba=updrs3_ba, intervention=as.factor(intervention), pbvc=pbvc) %>%
        mutate(gender = if_else(gender==1,'F','M'),
               gender = as.factor(gender))

for(n in 1:length(df$subject)){
        file <- paste('P:/3024006.02/ParkInShape_siena/', df$subject[n], 'A_ana2_to_', df$subject[n], 'B_ana2_siena/report.siena', sep='')
        content <- read_lines(file)
        pbvc_val <- content[length(content)]
        pbvc_val <- str_remove(pbvc_val, 'finalPBVC ')
        pbvc_val <- str_remove(pbvc_val, ' %')
        pbvc_val <- as.numeric(pbvc_val)
        df$pbvc[n] <- pbvc_val
}

discontinued_intervention <- c('PS032','PS037','PS045','PS057',
                               'PS007', 'PS022', 'PS058')
df2 <- df %>%
        mutate(discon.int = if_else(subject %in% discontinued_intervention,'Y','N'))
df2 <- df2 %>%
        filter(discon.int != 'Y')

# Descriptives
df %>%
        group_by(intervention) %>%
        summarise(n=n(), mean=mean(pbvc), sd=sd(pbvc), se=sd/sqrt(n), lower=mean-1.96*se, upper=mean+1.96*se)
ggplot(df, aes(x=intervention,y=pbvc)) + geom_boxplot()
ggplot(df, aes(x=pbvc, color=intervention)) + geom_density()

Box_PBVC <- ggplot(df, aes(x = intervention, y = pbvc)) +
        geom_boxplot(outlier.size = 3, size = 1.4, color = 'black', fill = c("springgreen4","violetred4"))
Box_PBVC <- Box_PBVC +labs(x='Intervention', y='\u0394  Percentage-based volume', title = 'Global brain atrophy') +
        theme(axis.text.x = element_text(size = 30), axis.text.y = element_text(size = 30), axis.title = element_text(size = 30, face = 'bold'), plot.title = element_text(size = 30, face = 'bold', hjust = 0),
              axis.ticks = element_line(size = 1), axis.ticks.length = unit(.3, "cm"), axis.line.x = element_line(size = 1, colour = "black"), axis.line.y = element_line(size = 1, colour = "black"), 
              panel.background = element_rect(color = 'white', fill = 'white')) +
        scale_x_discrete(breaks=c("con","ex"), labels=c("Stretching", "Aerobic exercise")) + 
        geom_segment(aes(x=1,y=2,xend=2,yend=2),size=1.4) + 
        geom_segment(aes(x=1,y=2,xend=1,yend=1.8),size=1.4) + geom_segment(aes(x=2,y=2,xend=2,yend=1.8),size=1.4) +
        geom_text(x = 1.5, y = 2.03, label = '*', size = 20) + geom_text(x = 1, y = 1.61, label = '***', size = 20)

Box_PBVC

tiff("F:/Dokument/Donders/ParkInShape/Manuscripts/AnnalsOfNeurology/Re-submission/Visualizations/GlobalPBVC.tiff", width = 8.7, height = 10, units = "in", res = 300, compression = "lzw")
Box_PBVC
dev.off()

# Inferences
m1 <- lm(pbvc ~ 1 + intervention + scale(updrs3_ba, center = TRUE, scale = FALSE), data = df)
summary(m1)
anova(m1)
plot(m1)

# Post hoc
t1 <- t.test(subset(df, intervention=='ex')$pbvc)
t2 <- t.test(subset(df, intervention=='con')$pbvc)

# With age and gender as covars
m1 <- lm(pbvc ~ 1 + intervention + updrs3_ba + age + gender, data = df)
summary(m1)
anova(m1)
plot(m1)

# Sensitivity to outliers
df <- df %>%
        mutate(outlier = 0)
#df$outlier[c(2,20,26, 32)] <- 1
m <- mean(df$pbvc)
s <- sd(df$pbvc)
df <- df %>%
        mutate(outlier = if_else((pbvc > m + s * 2) | (pbvc < m - s * 2), 1, 0))
df_nooutliers <- df %>%
        filter(outlier == 0)

df_nooutliers %>%
        group_by(intervention) %>%
        summarise(n=n(), mean=mean(pbvc), sd=sd(pbvc), se=sd/sqrt(n), lower=mean-1.96*se, upper=mean+1.96*se)
ggplot(df_nooutliers, aes(x=intervention,y=pbvc)) + geom_boxplot()
ggplot(df_nooutliers, aes(x=pbvc, color=intervention)) + geom_density()

m1 <- lm(pbvc ~ 1 + intervention + updrs3_ba, data = df_nooutliers)
summary(m1)
anova(m1)
plot(m1)
