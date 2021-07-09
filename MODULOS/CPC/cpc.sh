#!/bin/bash 

#-----------------------------------------------------------------------
#
#  INICIO 
#
#
  
source ../../config.omega
cp ../../COMMON_STUFF/get*.pl . 


case $1 in
	cria_cpc)
			ncl ../../MODULOS/CPC/CRIA_NETCDF/ncl_cria_netcdf_cpc.ncl
			;;
	calc_anomalia)	
			ncl ../../MODULOS/CPC/CRIA_NETCDF/ncl_cria_netcdf_cpc.ncl	
			ncl ../../MODULOS/CPC/CALCULA_ANOMALIA/le_cpc_cria_imagem_clima_anomalia.ncl $2 $3 
			mv *.png $OUTPUT
			;;			
	calc_chuva)
			ncl ../../MODULOS/CPC/CRIA_NETCDF/ncl_cria_netcdf_cpc.ncl
			ncl ../../MODULOS/CPC/CALCULA_CHUVA_MEDIA/calcbaciaV4_cpc.ncl $2 $3 
			cp ../../MODULOS/CPC/TOEXCEL/chuvaobservada.m .
			cp ../../MODULOS/CPC/TOEXCEL/CHUVA_OBSERVADA.xlsx .
			/mnt/c/"Program Files/Polyspace/R2019a/bin/matlab.exe" -batch "run  chuvaobservada.m"
			echo $OUTPUT
			cp CHUVA_OBSERVADA.xlsx $OUTPUT 
			;;
	
esac 		



###$OUTPUT"/cpc_"`date +"%Y%m%d"`"_CMB.csv"

