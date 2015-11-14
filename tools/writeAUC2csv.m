function [] = writeAUC2csv(Auc,csvFile2write)

fid = fopen(csvFile2write,'at+');

fprintf(fid,'Method,mean AUC,min AUC,max AUC\n');

for i = 1:length(Auc)
    fprintf(fid,'%s,%.2f,%.2f,%.2f\n',Auc(i).method,...
        Auc(i).mean_AUC,Auc(i).min_AUC,Auc(i).max_AUC);
end
fclose(fid);
end