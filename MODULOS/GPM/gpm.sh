#!/bin/bash 

#-----------------------------------------------------------------------
#
#  INICIO 
#
#
  
source ../../config.omega



case $1 in
	cria_imagens)
			ncl ../../MODULOS/GPM/ncl_plotar_mapa_chuva_gpm_operacional.ncl
			mv *.png $OUTPUT
			;;
		
esac 		
