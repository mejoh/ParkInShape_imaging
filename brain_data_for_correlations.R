# Data frame for exercise group
subjects <- read_csv('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/subjects.txt', col_names = 'Subject')
intervention <- c(rep.int(1, 21), rep.int(0,25))
subjects <- bind_cols(subjects,Intervention=intervention)
subjects <- subjects %>%
        filter(Intervention == 1)

APsubPP_A_ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/A_exercise_temp.txt',
                           ' ', col_names = c('APsubPP_C1_BA', 'APsubPP_C2_BA', 'APsubPP_C3_BA', 'APsubPP_C4_BA'))
APsubPP_B_ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/B_exercise_temp.txt',
                           ' ', col_names = c('APsubPP_C1_FU', 'APsubPP_C2_FU', 'APsubPP_C3_FU', 'APsubPP_C4_FU'))
APsubPP_BsubA_ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/BsubA_exercise_temp.txt',
                               ' ', col_names = c('APsubPP_C1_delta', 'APsubPP_C2_delta', 'APsubPP_C3_delta', 'APsubPP_C4_delta'))

PP_A_ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/A_exercise_temp.txt',
                           ' ', col_names = c('PP_C1_BA', 'PP_C2_BA'))
PP_B_ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/B_exercise_temp.txt',
                           ' ', col_names = c('PP_C1_FU', 'PP_C2_FU'))
PP_BsubA_ex <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/A_exercise_temp.txt',
                               ' ', col_names = c('PP_C1_delta', 'PP_C2_delta'))

rfpn_A_ex <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/A_exercise_temp.txt',
                        ' ', col_names = c('rfpn_C1_BA'))
rfpn_B_ex <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/B_exercise_temp.txt',
                        ' ', col_names = c('rfpn_C1_FU'))
rfpn_BsubA_ex <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/BsubA_exercise_temp.txt',
                            ' ', col_names = c('rfpn_C1_delta'))

#vbm_A_ex <- read_delim('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/vbm/SigSmn/A_ex_temp.txt', ' ', col_names = c('vbm_C1_BA'))
#vbm_B_ex <- read_delim('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/vbm/SigSmn/B_ex_temp.txt', ' ', col_names = c('vbm_C1_FU'))
#vbm_BsubA_ex <- read_delim('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/vbm/SigSmn/BsubA_exercise_temp.txt', ' ', col_names = c('vbm_C1_delta'))

df_ex <- bind_cols(subjects, 
                        APsubPP_A_ex, APsubPP_B_ex, APsubPP_BsubA_ex,
                        PP_A_ex, PP_B_ex, PP_BsubA_ex,
                        rfpn_A_ex, rfpn_B_ex, rfpn_BsubA_ex)

# Data frame for stretching group
subjects <- read_csv('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/subjects.txt', col_names = 'Subject')
intervention <- c(rep.int(1, 21), rep.int(0,25))
subjects <- bind_cols(subjects,Intervention=intervention)
subjects <- subjects %>%
        filter(Intervention == 0)

APsubPP_A_st <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/A_stretch_temp.txt',
                           ' ', col_names = c('APsubPP_C1_BA', 'APsubPP_C2_BA', 'APsubPP_C3_BA', 'APsubPP_C4_BA'))
APsubPP_B_st <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/B_stretch_temp.txt',
                           ' ', col_names = c('APsubPP_C1_FU', 'APsubPP_C2_FU', 'APsubPP_C3_FU', 'APsubPP_C4_FU'))
APsubPP_BsubA_st <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/APsubPP/BsubA_stretch_temp.txt',
                               ' ', col_names = c('APsubPP_C1_delta', 'APsubPP_C2_delta', 'APsubPP_C3_delta', 'APsubPP_C4_delta'))

PP_A_st <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/A_stretch_temp.txt',
                      ' ', col_names = c('PP_C1_BA', 'PP_C2_BA'))
PP_B_st <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/B_stretch_temp.txt',
                      ' ', col_names = c('PP_C1_FU', 'PP_C2_FU'))
PP_BsubA_st <- read_delim('P:/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun5_1-7-2021_cope/SMN/results/PP/BsubA_stretch_temp.txt',
                          ' ', col_names = c('PP_C1_delta', 'PP_C2_delta'))

rfpn_A_st <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/A_stretch_temp.txt',
                        ' ', col_names = c('rfpn_C1_BA'))
rfpn_B_st <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/B_stretch_temp.txt',
                        ' ', col_names = c('rfpn_C1_FU'))
rfpn_BsubA_st <- read_delim('P:/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/BsubA_stretch_temp.txt',
                            ' ', col_names = c('rfpn_C1_delta'))
#vbm_A_st <- read_delim('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/vbm/SigSmn/A_st_temp.txt', ' ', col_names = c('vbm_C1_BA'))
#vbm_B_st <- read_delim('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/vbm/SigSmn/B_st_temp.txt', ' ', col_names = c('vbm_C1_FU'))
#vbm_BsubA_st <- read_delim('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/vbm/SigSmn/BsubA_stretch_temp.txt', ' ', col_names = c('vbm_C1_delta'))

# Bind exercise and stretching groups together
df_st <- bind_cols(subjects, 
                   APsubPP_A_st, APsubPP_B_st, APsubPP_BsubA_st,
                   PP_A_st, PP_B_st, PP_BsubA_st,
                   rfpn_A_st, rfpn_B_st, rfpn_BsubA_st)
df <- full_join(df_ex, df_st)
#df <- df_ex

# Import percentage-based volume change from SIENA
pbvc <- rep(NA, length(df$Subject))
for(n in 1:length(df$Subject)){
        file <- paste('P:/3024006.02/ParkInShape_siena/', df$Subject[n], 'A_ana2_to_', df$Subject[n], 'B_ana2_siena/report.siena', sep='')
        content <- read_lines(file)
        pbvc_val <- content[length(content)]
        pbvc_val <- str_remove(pbvc_val, 'finalPBVC ')
        pbvc_val <- str_remove(pbvc_val, ' %')
        pbvc_val <- as.numeric(pbvc_val)
        pbvc[n] <- pbvc_val
}

df <- bind_cols(df, global_pbvc = pbvc)

# Data frame for FW and MD
#fw_col_names <- c('Subject', 'FW_Ant_BA', 'FW_Post_BA', 'FW_RAnt_BA', 'FW_LAnt_BA', 'FW_RPost_BA', 'FW_LPost_BA',
#                  'FW_Ant_FU', 'FW_Post_FU', 'FW_RAnt_FU', 'FW_LAnt_FU', 'FW_RPost_FU', 'FW_LPost_FU')
#md_col_names <- c('Subject', 'MD_Ant_BA', 'MD_Post_BA', 'MD_RAnt_BA', 'MD_LAnt_BA', 'MD_RPost_BA', 'MD_LPost_BA',
#                  'MD_Ant_FU', 'MD_Post_FU', 'MD_RAnt_FU', 'MD_LAnt_FU', 'MD_RPost_FU', 'MD_LPost_FU')
#fw <- read_delim('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fw/FreewaterValues.txt', ' ', col_names = fw_col_names, skip = 1)
#md <- read_delim('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fw/MeanDiffValues.txt', ' ', col_names = md_col_names, skip = 1)

# Merge FW and MD into main data frame
#df <- left_join(df, fw)
#df <- left_join(df, md)

# Make new vars
df <- df %>%
        mutate(APsubPP_AllC_BA = (APsubPP_C1_BA + APsubPP_C2_BA + APsubPP_C3_BA + APsubPP_C4_BA)/4,
               APsubPP_AllC_FU = (APsubPP_C1_FU + APsubPP_C2_FU + APsubPP_C3_FU + APsubPP_C4_FU)/4,
               APsubPP_AllC_delta = (APsubPP_C1_delta + APsubPP_C2_delta + APsubPP_C3_delta + APsubPP_C4_delta)/4,
               PP_AllC_BA = (PP_C1_BA + PP_C2_BA)/2,
               PP_AllC_FU = (PP_C1_FU + PP_C2_FU)/2,
               PP_AllC_delta = (PP_C1_delta + PP_C2_delta)/2,
               rfpn_AllC_BA = (rfpn_C1_BA)/1,
               rfpn_AllC_FU = (rfpn_C1_FU)/1,
               rfpn_AllC_delta = (rfpn_C1_delta)/1)

# Write data frame to file
outputname <- paste('P:/3011154.01/MJ/AnnalsOfNeu_behav-corrs/ParkInShape_brain_data_', today(), '.csv', sep='')
write_csv(df, outputname)












