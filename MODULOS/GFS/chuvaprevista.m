
clear all

M=importdata('e:/OPERACIONAL/OUTPUT/20210623/gfs_saida2_20210623.csv'); 
[num_tempos,num_colunas]=size(M.data);
CHUVAO=zeros(9999,num_colunas);
hoje=datenum(M.data(1,1:3));
indice=hoje-datenum(2018,1,1)+1;
ii=int2str(indice+1);
range=strcat('A',ii);
xlswrite('c:/OPERACIONAL/PREVISAO/opera.xlsx',CHUVAO,'calcbaciav4','a2')
xlswrite('c:/OPERACIONAL/PREVISAO/opera.xlsx',M.data,'calcbaciav4','f2')
xlswrite('c:/OPERACIONAL/PREVISAO/opera.xlsx',M.textdata,'calcbaciav4','a2')



    
    
    