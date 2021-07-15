#!/bin/bash
# PATH=$PATH://usr/local/ncl//bin/:/usr/bin: 
# export NCARG_ROOT=/usr/lib/ncarg/
# export PATH=$PATH:/usr/local/ncl/bin
# cd /mnt/e/OPERACIONAL/SIMOP/MODULOS/PREVISAO
#
# executar previsao
#
source ../../config.omega
cp ../../MODULOS/PREVISAO/calcula_opera.ncl .
cp ../../MODULOS/PREVISAO/opera_matlab.sh .
cp ../../MODULOS/PREVISAO/work.xlsx .
export INC_MOD=0
export RESTART=False
export EXECUTE_MODELS=True ##rue ##True 
export EXECUTE_STAT=True #True
export EXECUTE_OBS=False
if test -z $1 ;then 
export DATARUN=`date +"%Y%m%d"`
export RODADA="00" 
export TIME_UNITS=`date +"days since  %Y-%m-%d 00:00:00"`
data=`date +"%Y-%m-%d"`
else
export DATARUN=`date +"%Y%m%d" -d"$1 days ago"`
export RODADA=$2
export TIME_UNITS="days since  "$data" "$RODADA":00:00"
fi 
ncl ./calcula_opera.ncl 
./opera_matlab.sh 
cp ./work.xlsx  $HISTORICO/previsao_multmodels_$data$rodada".xlsx"
cp ./work.xlsx  /mnt/e/OPERACIONAL/PREVISAO/ 





