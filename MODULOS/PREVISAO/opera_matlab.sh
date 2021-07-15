#!/bin/bash


rodada="00"
datap1=`date +'"multmodels_d_%Y%m%d'$rodada.csv'"'` 
datap2=`date +'"multmodels_h_%Y%m%d'$rodada.csv'"'` 
datas1=`date +'"multmodels_stat_%Y%m%d'$rodada.csv'"'` 
datao1=`date +'"chuva_observada_d_%Y%m%d'$rodada.csv'"'` 
datao2=`date +'"chuva_observada_h_%Y%m%d'$rodada.csv'"'` 

echo "clear" >opera.m 
echo "M=importdata("$datap1");" >>opera.m
echo "xlswrite('work.xlsx',M.textdata,'diario','a2')" >>opera.m
echo "xlswrite('work.xlsx',M.data,'diario','e2')"  >>opera.m
echo "clear" >>opera.m 
echo "M=importdata("$datap2");" >>opera.m
echo "xlswrite('work.xlsx',M.textdata,'horario','a2')" >>opera.m
echo "xlswrite('work.xlsx',M.data,'horario','e2')"  >>opera.m
echo "clear" >>opera.m 
# echo "%M=importdata("$datao1");" >>opera.m
# echo "%xlswrite('work.xlsx',M.textdata,'OBS_D','a2')" >>opera.m
# echo "%xlswrite('work.xlsx',M.data,'OBS_D','e2')"  >>opera.m
# echo "%clear" >>opera.m 
# echo "%M=importdata("$datao2");" >>opera.m
# echo "%xlswrite('work.xlsx',M.textdata,'OBS_H','a2')" >>opera.m
# echo "%xlswrite('work.xlsx',M.data,'OBS_H','e2')"  >>opera.m
# echo "clear" >>opera.m 
echo "M=importdata("$datas1");" >>opera.m
###% % H=importdata(".stat_headers.dat");
echo "xlswrite('work.xlsx',M.textdata,'fromstat','b1')"  >>opera.m
###% % % xlswrite('work.xlsx',H,'fromstat','a2') 
echo "xlswrite('work.xlsx',M.data,'fromstat','b2')"  >>opera.m 
/mnt/c/"Program Files/Polyspace/R2019a/bin/matlab.exe" -batch "run  opera.m"
mkdir -p HISTORICO
cp $datap1 $datap2 $datas1 $datao1 $datao2 ./HISTORICO
