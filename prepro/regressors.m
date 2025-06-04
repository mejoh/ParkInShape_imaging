%% Head motion regressors
clear

%subject_list = ['PS002'; 'PS003'; 'PS004'; 'PS006'; 'PS007'; 'PS009'; 'PS010'; 'PS011'; 'PS012'; 'PS013'; 'PS014'; 'PS016'; 'PS017'; 'PS018'; 'PS019'; 'PS020'; 'PS021'; 'PS022'; 'PS023'; 'PS024'; 'PS025'; 'PS026'; 'PS027'; 'PS028'; 'PS029'; 'PS030'; 'PS031'; 'PS032'; 'PS033'; 'PS034'; 'PS035'; 'PS036'; 'PS037'; 'PS038'; 'PS039'; 'PS040'; 'PS041'; 'PS042'; 'PS043'; 'PS044'; 'PS045'; 'PS046'; 'PS047'; 'PS048'; 'PS049'; 'PS051'; 'PS052'; 'PS053'; 'PS054'; 'PS055'; 'PS056'; 'PS057'; 'PS058'; 'PS059'; 'PS060'];
%subject_list = ['PS002'; 'PS003'; 'PS004'; 'PS006'; 'PS007'; 'PS011'; 'PS012'; 'PS014'; 'PS016'; 'PS017'; 'PS018'; 'PS019'; 'PS020'; 'PS021'; 'PS022'; 'PS024'; 'PS025'; 'PS026'; 'PS027'; 'PS028'; 'PS029'; 'PS031'; 'PS032'; 'PS033'; 'PS034'; 'PS035'; 'PS036'; 'PS037'; 'PS038'; 'PS039'; 'PS041'; 'PS042'; 'PS043'; 'PS044'; 'PS045'; 'PS046'; 'PS047'; 'PS048'; 'PS049'; 'PS052'; 'PS053'; 'PS054'; 'PS056'; 'PS057'; 'PS058'; 'PS060'];
subject_list = ['PS059']

for j=1:1
    
    for ses=2:2
        
        if ses==1
            D = strcat('/project/3011154.01/MJ/FC/',sprintf(subject_list(j,:)),'A/rs/prepro.feat/mc');
            P = strcat('/project/3011154.01/MJ/FC/',sprintf(subject_list(j,:)),'A/rs/prepro.feat/mc/prefiltered_func_data_mcf.par');
        else
            D = strcat('/project/3011154.01/MJ/FC/',sprintf(subject_list(j,:)),'B/rs/prepro.feat/mc');
            P = strcat('/project/3011154.01/MJ/FC/',sprintf(subject_list(j,:)),'B/rs/prepro.feat/mc/prefiltered_func_data_mcf.par');
        end
        
        for i=1:size(P,1)
            
            m=load(deblank(P(i,:))); % load the motion parameters
            mh=[zeros(1,6); m(1:end-1,:)]; % create the motion history regressors
            volt_mov=[m mh m.^2 mh.^2]; % construct the volterra expansion
            [D,F,E]=fileparts(deblank(P(i,:))); %get the name of the original file
            save([D '/' F '_VX24' E],'-ascii','volt_mov'); %save new matrix
        end
    
    end

end
