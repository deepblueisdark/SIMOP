
clear all
%Chuva Prevista Bacia Montante Jaciparaná (mm)
%Chuva Prevista Bacia Incremental Jaciparana Vila (mm)
%Chuva Prevista Incremental Jirau - Barragem SAE (mm)
%Chuva Prevista Incremental Jusante do Rio Beni - Jirau (mm)
%Chuva Prevista Incremental até Jusante do Rio Beni (m


% SAE_GFS_1P0__Bacia_Inc_JPVila.prn
% SAE_GFS_1P0__Bacia_JPVila.prn
% SAE_GFS_1P0__Bacia_MontJP.prn
% SAE_GFS_1P0__JIRAU_SAE.prn
% SAE_GFS_1P0__JRB_JIRAU.prn
% SAE_GFS_1P0__INC_ATE_JRB.prn

bacias={'Bacia_Inc_JPVila','Bacia_JPVila','Bacia_MontJP','JIRAU_SAE','JRB_JIRAU','INC_ATE_JRB'} ;


D=dir('../../../HICON/BOLETIM/202*')


[numdir,~]=size(D);


linha=2;
dadosrun=zeros(1,16);

for k=1:6

for i=1:numdir
    path1=sprintf('../../../HICON/BOLETIM/%s/chuva_media/SAE_GFS_1P0__%s.prn',D(i).name,bacias{k})
    path2=sprintf('../../../HICON/BOLETIM/%s/chuva_media/SAE_GFS_0P50__%s.prn',D(i).name,bacias{k})
    
    
    if (exist(path2,'file'))  
        dadosrun1=zeros(1,16);
        A=importdata(path2);
        dados=A
        data={datestr(datenum(D(i).name,'yyyymmdd'),'yyyy/mm/dd')};
        [~, lk]=size(dados(:,3)'); 
        dadosrun1(1:lk)=dados(:,5)' ;
        indice=(datenum(data)-datenum(2017,1,1))+1;
    
       ; if (exist(path2,'file'))  
       ;     B=importdata(path2);
      ;      dados=B;
      ;      dadosrun2=dados(:,5)' ;
      ;  end
    
      ;  if (exist(path2,'file'))  
       ;     dadosrun(1,1:10)=dadosrun2(1:10);
      ;      dadosrun(1,11:16)=dadosrun1(11:16);
     ;   else
      ;  dadosrun=dadosrun1;
    
    ;    end     
    
    
    
        ii=int2str(indice+1);
        range1=strcat('A',ii);
        range2=strcat('B',ii);
    
        data
        xlswrite('../../../HICON/BOLETIM/PREVISOES_PASSADAS.xlsx',data,bacias{k},range1) 
        xlswrite('../../../HICON/BOLETIM/PREVISOES_PASSADAS.xlsx',dadosrun,bacias{k},range2) 
    end
   
    
end

end

