clear

cd /project/3011154.01/MJ/teststuff/PS041A/rs/parcellation/kmeans

% Import ts from some seed
A = importdata('puta_whole.txt');
voxel = A(1:3,:)';
ts = A(4:size(A,1),:);

% Calculate correlation matrix
X = corr(ts);

% Kmeans the correlation matrix
opts = statset('Display','final');
[cidx, ctrs] = kmeans(X,4,'Distance','city','Replicates',5,'Options',opts);

% Separate voxels into centroid bins
a = voxel(cidx==1,:);
b = voxel(cidx==2,:);
c = voxel(cidx==3,:);
d = voxel(cidx==4,:);

% Write voxels in each bin to a text file
fid = fopen('centroid_a','w');
s = size(a,1);
for i = 1:s
    writestuff = fprintf(fid, '%5d %5d %5d\r\n', a(i,:));
end

fid = fopen('centroid_b','w');
s = size(b,1);
for i = 1:s
    writestuff = fprintf(fid, '%5d %5d %5d\r\n', b(i,:));
end

fid = fopen('centroid_c','w');
s = size(c,1);
for i = 1:s
    writestuff = fprintf(fid, '%5d %5d %5d\r\n', c(i,:));
end

fid = fopen('centroid_d','w');
s = size(d,1);
for i = 1:s
    writestuff = fprintf(fid, '%5d %5d %5d\r\n', d(i,:));
end