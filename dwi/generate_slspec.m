Subjects = {'PS002A' 'PS002B' 'PS003A' 'PS003B' 'PS004A' 'PS004B' 'PS006A' 'PS006B' 'PS007A' 'PS007B' 'PS011A' 'PS011B' 'PS012A' 'PS012B' 'PS014A' 'PS014B' 'PS017A' 'PS017B' 'PS018A' 'PS018B' 'PS019A' 'PS019B' 'PS020A' 'PS020B' 'PS021A' 'PS021B' 'PS022A' 'PS022B' 'PS024A' 'PS024B' 'PS025A' 'PS025B' 'PS026A' 'PS026B' 'PS027A' 'PS027B' 'PS028A' 'PS028B' 'PS029A' 'PS029B' 'PS031A' 'PS031B' 'PS032A' 'PS032B' 'PS033A' 'PS033B' 'PS034A' 'PS034B' 'PS035A' 'PS035B' 'PS036A' 'PS036B' 'PS037A' 'PS037B' 'PS038A' 'PS038B' 'PS039A' 'PS039B' 'PS042A' 'PS042B' 'PS043A' 'PS043B' 'PS044A' 'PS044B' 'PS045A' 'PS045B' 'PS046A' 'PS046B' 'PS047A''PS047B' 'PS048A' 'PS048B' 'PS049A' 'PS049B' 'PS052A' 'PS052B' 'PS054A' 'PS054B' 'PS056A' 'PS056B' 'PS057A' 'PS057B' 'PS058A' 'PS058B' 'PS059A' 'PS059B' 'PS060A' 'PS060B'};
%Subjects = {'PS002B'};
DWIDir = '/project/3011154.01/MJ/DWI';

for i = 1:numel(Subjects)
   
    JsonFile = dir(fullfile(DWIDir, 'raw', Subjects{i}, '0008', '0008_PT08D1_ep2d_diff_68dirs_2.2mm_p2_*_8.json'));
    JsonFile = fullfile(JsonFile.folder, JsonFile.name);
    SlspecFile = fullfile(DWIDir, 'processed', Subjects{i}, 'b0', 'slspec.txt');
    
    fp = fopen(JsonFile,'r');
    fcont = fread(fp);
    fclose(fp);
    cfcont = char(fcont');
    i1 = strfind(cfcont,'SliceTiming');
    i2 = strfind(cfcont(i1:end),'[');
    i3 = strfind(cfcont((i1+i2):end),']');
    cslicetimes = cfcont((i1+i2+1):(i1+i2+i3-2));
    slicetimes = textscan(cslicetimes,'%f','Delimiter',',');
    [sortedslicetimes,sindx] = sort(slicetimes{1});
    mb = length(sortedslicetimes)/(sum(diff(sortedslicetimes)~=0)+1);
    slspec = reshape(sindx,[mb length(sindx)/mb])'-1;
    dlmwrite(SlspecFile,slspec,'delimiter',' ','precision','%3d');
    
end