


featype='SF_GABOR';
for corridor=4:6
% path=fullfile(pwd,['Cor',num2str(corridor)],featype);

files=dir(fullfile(path, '*_Descriptors.mat')); % change for HOG3D

for com=1%:5

selector=1:5;

Accum=[];

% selector(com)=[];

for i=1:5%was 4
    
load(fullfile(path,files(selector(i)).name))

ind1=randi([1 size(DescriptorStack,2)],[1 800]);

ind2=randi([1 size(DescriptorStack,1)],[1 200]);

Accum=[Accum ; reshape(shiftdim(DescriptorStack(ind2,:,ind1),2),[],size(DescriptorStack,2))];

end

% name = 1000*selector(1)+100*selector(2)+10*selector(3)+selector(4);
name = 10000*selector(1)+1000*selector(2)+100*selector(3)+10*selector(4)+selector(5);

disp(['PermSamples' num2str(name)])

Accum=Accum./repmat(sqrt(sum(Accum.^2,2))+eps,1,size(DescriptorStack,2));
VWords=yael_kmeans(single(Accum)',4000,'niter',20,'verbose',2,'seed',3);
save(fullfile(path,['VWords_Traj_' num2str(name) '.mat']),'VWords')

end


disp(['Corridor' num2str(corridor)])
end