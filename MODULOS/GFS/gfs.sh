#!/bin/bash 

#-----------------------------------------------------------------------
#
#  INICIO 
#
#

  
source ../../config.omega
cp ../../COMMON_STUFF/get*.pl . 


cp ../../MODULOS/GFS/calcbaciaV4_opera.ncl .
cp ../../MODULOS/GFS/stat_calcbacia.ncl .

cp ../../MODULOS/GFS/calcbaciaV4_opera_unique.ncl .

case $1 in
	calcx) 
		echo "[ GFS/GEFS - CALCBACIA -X]" 
		ncl ./calcbaciaV4_opera_unique.ncl  $2  $3 $4 $5 $6  
		arquivo_saida="gfs_saida2_"`date +"%Y%m%d"`".csv"
		arquivo_log_erro="gfs_logerror_"`date +"%Y%m%d"`".csv"
		echo $arquivo_saida 
		if test -e $OUTPUT/$arquivo_saida  ;then
			echo "arquivo "$arquivo_saida" existe" 
			cat $arquivo_saida  >>  $OUTPUT/$arquivo_saida
				
		else
			echo "arquivo "$arquivo_saida" NAO existe" 
			cp $arquivo_saida   $OUTPUT
		fi 
		#
		# log do erro
		#
		if test -e log.error ;then 
			echo $arquivo_log_erro
			if test -e $OUTPUT/$arquivo_log_erro  ;then
				echo "arquivo "$arquivo_log_erro" existe" 
				cat log.error   >>  $OUTPUT/$arquivo_log_erro
				
			else
				echo "arquivo "$arquivo_log_erro" NAO existe" 
				cat log.error  > $OUTPUT/$arquivo_log_erro 
			fi
		fi 		
		;;		
	stat)
		ncl ./stat_calcbacia.ncl 
		echo "clear all" > toexel.m
		echo "M=importdata('e:/OPERACIONAL/OUTPUT/"`date +"%Y%m%d"`"/gfs_stat_"`date +"%Y%m%d"`".csv');" >>toexel.m
		echo "xlswrite('e:/OPERACIONAL/PREVISAO/opera.xlsx',M.data,'stat','b2')" >> toexel.m 
		/mnt/c/"Program Files/Polyspace/R2019a/bin/matlab.exe" -batch "run  toexel.m"
		;;
	toexel)
	
		echo "clear all" > toexel.m
		echo "M=importdata('e:/OPERACIONAL/OUTPUT/"`date +"%Y%m%d"`"/gfs_saida2_"`date +"%Y%m%d"`".csv');" >>toexel.m
		echo "[num_tempos,num_colunas]=size(M.data);" >> toexel.m
		echo "CHUVAO=strings(9999,num_colunas);" >> toexel.m
		echo "xlswrite('e:/OPERACIONAL/PREVISAO/opera.xlsx',CHUVAO,'calcbaciav4','a2')" >> toexel.m
		echo "xlswrite('e:/OPERACIONAL/PREVISAO/opera.xlsx',M.data,'calcbaciav4','f2')" >> toexel.m 
		echo "xlswrite('e:/OPERACIONAL/PREVISAO/opera.xlsx',M.textdata,'calcbaciav4','a2')" >> toexel.m 
		/mnt/c/"Program Files/Polyspace/R2019a/bin/matlab.exe" -batch "run  toexel.m"
		;;
		
esac 		
