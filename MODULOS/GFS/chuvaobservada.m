clear all
M=importdata('testechuva.csv',' '); 

[num_tempos,num_colunas]=size(M.data);

CHUVAO=zeros(num_tempos,num_colunas);
    hoje=datenum(M.data(1,1:3));
    indice=hoje-datenum(2018,1,1)+1;
    ii=int2str(indice+1);
    range=strcat('A',ii);
for i=1:num_tempos

    madeira=mean(M.data(i,7:13));
CHUVAO(i,1)=M.data(i,1);
CHUVAO(i,2)=M.data(i,2);
CHUVAO(i,3)=M.data(i,3);

CHUVAO(i,4)=M.data(i,6);%cahoeira esperança  
CHUVAO(i,5)=M.data(i,9);%mamore
CHUVAO(i,6)=M.data(i,15); %bacia mont_jpvila
CHUVAO(i,7)=M.data(i,12); %JRB_JIRAU
CHUVAO(i,8)=M.data(i,13); %jirau->sae 
CHUVAO(i,9)=M.data(i,11); %inc_JRB 
CHUVAO(i,10)=M.data(i,8); %Beni conf madre  
CHUVAO(i,11)=M.data(i,10); %Guapore
CHUVAO(i,12)=M.data(i,14); %jrb_sae 
CHUVAO(i,13)=M.data(i,5); %JRB 
CHUVAO(i,14)=M.data(i,7); %madredios
CHUVAO(i,15)=madeira;  %rio MADEIRA
CHUVAO(i,16)=M.data(i,17); %bacia_inc JPVila
CHUVAO(i,17)=M.data(i,16); %bcia_JPVILA
end 


xlswrite('CHUVA_OBSERVADA.xlsx',CHUVAO,"54km",range)