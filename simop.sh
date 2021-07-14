#!/bin/bash

export PATH=$PATH:/opt/opengrads
export LANG=en_us_8859_1


cd /home/ubuntu/SIMOP/
source  ./config.omega
export OUTPUT=$OUTPUTDIR"/"`date +"%Y%m%d"`"/" 
mkdir -p $OUTPUT 




chmod 777 MODULOS/*.sh 
chmod 777 COMMON_STUFF/* 




#
# verifica se workdisk é padroao ou userdef
#
#if test -z $7 ;then 
export WORKDISK="WORKDISK/OMEGA_"`date +"%Y%m%d%H%M%S"` 
mkdir -p $WORKDISK
#else
#export WORKDISK="WORKDISK/"$8
#mkdir -p $WORKDISK 
#fi 




echo $WORKDISK 
cd $WORKDISK 
echo $1" "$2" "$3" "$4" "$5" "$6" "$7" -> "$8 >SIMOPID


case $1 in 
	addx) 
         pwd
		 ../../MODULOS/adquirev2_beta.sh  $2 $3 $4  $5 $6 $7 $8 $9 
		cd ..
		rm -rf $WORKDISK 
        ;;
	cpc)
		../../MODULOS/CPC/cpc.sh $2 $3 $4  $5 $6 $7 $8 $9 
		cd ../../
		rm -rf $WORKDISK 
		;;
	gpm)
		../../MODULOS/GPM/gpm.sh $2 $3 $4  $5 $6 $7 $8 $9 
		cd ../../
		rm -rf $WORKDISK
		;;
	gfs) 
		../../MODULOS/GFS/gfs.sh $2 $3 $4  $5 $6 $7 $8 $9 
		cd ../../
		rm -rf $WORKDISK
		;;
	cfs) 
		../../MODULOS/CFS/cfs.sh $2 $3 $4  $5 $6 $7 $8 $9 
		cd ../../
		#rm -rf $WORKDISK
		;;		
		
  esac  






