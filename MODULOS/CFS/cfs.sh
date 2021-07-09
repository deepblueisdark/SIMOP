#!/bin/bash


cfs_mensal2()
{
#-------------------------------------------------------------------------------------
#
# WXWEATHER   - CONSULTORIA EM METEOROLOGIA E COMPUTAÇÃO DE ALTO DESEMPENHO  
#     
#-------------------------------------------------------------------------------------
# ADQUIRE MODEL -  Sistema para baixar e pré-processar dados de modelos de previsão
# numerica do tempo e climáticos
#
#  funcao cfs_mensal() 
#  baixa os dados do CFS mensal e cria um ensemble com n membros num unico arquivo. 
#  
#  
#
#
# -----------------------------------------------------------------------------------  
# 
#  Desenvolvido por: Reginaldo Ventura de Sa (regis@lamma.ufrj.br) 
#  Release 1 em :  27/03/2018     
#
#-----------------------------------------------------------------------------------
# Sintaxe:
# adquire_model.sh cfs 
#
#-----------------------------------------------------------------------------------------------
# CHANGE LOG
# 
#-----------------------------------------------------------------------------------------------
#
# INICIO
# Altero CDLOG por que  estou dentro do diretorio CFS do WORKDISK
# isso foi feito por que tenho que ter os ultimos 2 dias de arquivos armazenados
# e para evitar que se baixe de novo caso se rode no mesmo dia. 
#
echo "INICIO DO PROCESSO CFS: "`date +"%Y%m%d %H%M"`
tempo1=`date +"%s"`
DIA=`date +"%d"`
#
# vetor rodada com os horarios da rodad.
#
 rodada=( 00 18 12 06 00 )
#
# quantidade de dias dos meses  para transformar kg/s/m2 em mm 
#
diasnomes=(99 31 28  31  30  31  30  31  31  30  31  30   31)
#
# vetores com os tempos
#  tempo = vetor com a data de hoje , ontem e antes de ontem 
# previsoes =  YYYYMM  =>  vetor com as n previsoes 
# datagrads = data do grads para lead00 existir ou não.
#

 tempo=( `date +"%Y%m%d"`   `date +"%Y%m%d" -d"1 days ago"`  `date +"%Y%m%d" -d"2 days ago"`  `date +"%Y%m%d" -d"3 days ago"`  ) 
 
 
 previsoes=( `date +"%Y%m"`                `date +"%Y%m" -d"1 months "` `date +"%Y%m" -d"2 months "` 
              `date +"%Y%m" -d"3 months "` `date +"%Y%m" -d"4 months "` `date +"%Y%m" -d"5 months "`
			  `date +"%Y%m" -d"6 months "`  `date +"%Y%m" -d"7 months "` `date +"%Y%m" -d"8 months "` `date +"%Y%m" -d"9 months "` )
			  
			  
 mesprev=(   `date +"%-m"`  `date +"%-m" -d"1 months "`  `date +"%-m" -d"2 months "`  
              `date +"%-m" -d"3 months "`  `date +"%-m" -d"4 months "`  `date +"%-m" -d"5 months "` 
			  `date +"%-m" -d"6 months "`    `date +"%-m" -d"7 months "`  `date +"%-m" -d"8 months "`  `date +"%-m" -d"9 months "` )
 
 
datagrads=( `date +"00Z01%b%Y"` `date +"00Z01%b%Y" -d"1 months"`) 
 
#
# cria o nome do arquivo final 
# 
filenc="CFS_MENSAL_"${tempo[0]}${rodada[0]}".nc"  
LOCAL=$CFS"/MENSAL/" 
mkdir -p $LOCAL
if test -e $LOCAL$filenc ;then 
	echo "CFS MENSAL JA FOI PRODUZIDO" 
	return 
fi 
#
#
#
echo "BALANCETE DOS ENSEMBLES" > ensembles_novo 
membro=1
echo "MEMBRO = "$membro >> ensembles_novo 

if test "$DIA" -le "10" ;then 

	   REGLEAD=0 
	   echo " TEREMOS O LEAD0"
	   else
	   echo " NAO TEREMOS O LEAD 1"
	   REGLEAD=1
fi
n=0
for i in `seq 1 2`
do
	for j in `seq 1 4`
	do
		let membro=($membro+1) 
		echo "*"  >> ensembles_novo 
		echo "MEMBRO = "$membro >> ensembles_novo 
		echo "*" >> ensembles_novo 
		for k in `seq  $REGLEAD 7`
		do
			file[$n]="flxf.01."${tempo[$i]}${rodada[$j]}"."${previsoes[$k]}".avrg.grib.grb2"   
			if test ! -e ${file[$n]} ;then 
				link="https://nomads.ncep.noaa.gov/pub/data/nccf/com/cfs/prod/cfs/cfs."${tempo[$i]}"/"${rodada[$j]}"/monthly_grib_01/flxf.01."${tempo[$i]}${rodada[$j]}"."${previsoes[$k]}".avrg.grib.grb2"
				echo "PROCESSANDO: "${file[$n]}" FAZENDO DOWNLOAD"  
				wget --no-check-certificate -nc $link  
			else
				echo "PROCESSANDO: "${file[$n]}"  DOWNLOAD JA FEITO" 
			fi 
			if test -e  ${file[$n]} ;then 
				check[$n]="OK"
			else
				check[$n]="NAO BAIXADO"
			fi 
			let mesens[$n]=(${mesprev[$k]}) 
			let lead[$n]=(${mesprev[$k]}-${mesprev[0]}) 
			if test ${lead[$n]} -lt 0 ;then 
				let lead[$n]=(${lead[$n]}+12) 
			fi
			echo "["$n"]"${file[$n]}" LEAD "${lead[$n]}" CHECK "${check[$n]}  >> ensembles_novo 
			let n=(n+1) 
		done 
	done
done 

let n=(n-1)
rm CFSALL.BIN  
for k in `seq 0 $n`
do
	echo ${file[$k]}" "${lead[$k]}  
	perl ./g2ctl.pl  ${file[$k]}  >cfs.ctl 
	gribmap -i cfs.ctl   
	echo "'lats4d -i cfs.ctl -lon 280 330 -lat -35 10 -format stream -vars  pratesfc  -func @*"${diasnomes[${mesens[$k]}]}"*24*3600  -o arqout'"           >script.gs
	echo "'quit'" >>script.gs
	grads -lbc "script.gs" 
	cat arqout.bin >> CFSALL.BIN 
	rm arqout.bin 
done	
#
# se temos lead00  cria o arquivo com 7 variaveis , se não  com 6 varoaveis. 
#
if test "$REGLEAD" -eq  "0" 
then 
	echo " ======================= LEAD00 EXISTE ========================"  >>$CDLOG"/cfsmensal.prn" 2>&1
	echo "dset ./CFSALL.BIN" > cfsmensal.ctl 
	echo "title cfs mensal " >>cfsmensal.ctl
	echo "undef 9.999e+20" >>cfsmensal.ctl
	echo "xdef 55 linear 279.375 0.9375" >>cfsmensal.ctl
	echo "ydef 50 levels -35.433 -34.488 -33.543 -32.598 -31.653 -30.709 -29.764 -28.819" >>cfsmensal.ctl
	echo " -27.874 -26.929 -25.984 -25.039 -24.094 -23.15 -22.205 -21.26 -20.315 -19.37"  >>cfsmensal.ctl
	echo " -18.425 -17.48 -16.535 -15.59 -14.646 -13.701 -12.756 -11.811 -10.866 -9.921"  >>cfsmensal.ctl
	echo " -8.976 -8.031 -7.087 -6.142 -5.197 -4.252 -3.307 -2.362 -1.417 -0.472"         >>cfsmensal.ctl
	echo " 0.472 1.417 2.362 3.307 4.252 5.197 6.142 7.087 8.031 8.976"                   >>cfsmensal.ctl
	echo " 9.921 10.866"                                                                  >>cfsmensal.ctl
	echo "zdef 1 linear 0 1"                                                              >>cfsmensal.ctl  
	echo "tdef 6 linear  "${datagrads[0]}" 1mo"                                                >>cfsmensal.ctl
	echo "vars 8"                                                                         >>cfsmensal.ctl
	echo "lead00  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead01  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead02  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl  
	echo "lead03  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl 
	echo "lead04  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead05  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead06  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead07  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	#echo "lead08  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	#echo "lead09  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "endvars"                                                                        >>cfsmensal.ctl  

	echo "'lats4d -i cfsmensal.ctl  -o "$filenc" -q'"           >script.gs
	grads -lbc "script.gs"          
	if test -e $filenc ;then 
		mv $filenc $LOCAL
	fi 
else
	echo " ======================= LEAD00 NAO EXISTE   ========================"  >>$CDLOG"/cfsmensal.prn" 2>&1
	echo "dset ./CFSALL.BIN" > cfsmensal.ctl 
	echo "title cfs mensal porra" >>cfsmensal.ctl
	echo "undef 9.999e+20" >>cfsmensal.ctl
	echo "xdef 55 linear 279.375 0.9375" >>cfsmensal.ctl
	echo "ydef 50 levels -35.433 -34.488 -33.543 -32.598 -31.653 -30.709 -29.764 -28.819" >>cfsmensal.ctl
	echo " -27.874 -26.929 -25.984 -25.039 -24.094 -23.15 -22.205 -21.26 -20.315 -19.37"  >>cfsmensal.ctl
	echo " -18.425 -17.48 -16.535 -15.59 -14.646 -13.701 -12.756 -11.811 -10.866 -9.921"  >>cfsmensal.ctl
	echo " -8.976 -8.031 -7.087 -6.142 -5.197 -4.252 -3.307 -2.362 -1.417 -0.472"         >>cfsmensal.ctl
	echo " 0.472 1.417 2.362 3.307 4.252 5.197 6.142 7.087 8.031 8.976"                   >>cfsmensal.ctl
	echo " 9.921 10.866"                                                                  >>cfsmensal.ctl
	echo "zdef 1 linear 0 1"                                                              >>cfsmensal.ctl  
	echo "tdef 6 linear "${datagrads[1]}" 1mo"                                                >>cfsmensal.ctl
	echo "vars 7"                                                                         >>cfsmensal.ctl
	echo "lead01  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead02  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl  
	echo "lead03  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl 
	echo "lead04  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead05  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead06  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "lead07  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	#echo "lead08  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	#echo "lead09  0  t,y,x  ** surface Precipitation Rate [kg/m^2/s]"                     >>cfsmensal.ctl
	echo "endvars"                                                                        >>cfsmensal.ctl  
	echo "'lats4d -i cfsmensal.ctl  -o "$filenc" -q'"           >script.gs
	grads -lbc "script.gs"
	if test -e $filenc ;then 
		mv $filenc $LOCAL
	fi 
 fi

echo "FINAL DO PROCESSO CFS: "`date +"%Y%m%d %T"`
tempo2=`date +"%s"`
let "tempo=tempo2-tempo1"
echo "DURACAO DO PROCESSO:"$tempo" segundos" 









}





#-----------------------------------------------------------------------
#
#  INICIO 
#
#
source ../../config.omega
cp ../../COMMON_STUFF/*.pl .
export LANG=en_us_8859_1
cfs_mensal2 $2 

#
# FIM 
#
 
 echo " F I M    D  A      O P E R A Ç A  O"