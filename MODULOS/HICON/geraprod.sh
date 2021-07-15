#!/bin/bash 

pwd




source ../../config.omega
cp ../../COMMON_STUFF/get*.pl . 
cp ../../MODULOS/HICON/geraprod.sh .
cp ../../MODULOS/HICON/baixar_gfs.gs .
cp ../../MODULOS/HICON/calcbacia.gs .
cp ../../MODULOS/HICON/bacias.dat .
cp ../../MODULOS/HICON/gera_previsoes_passadas.m .



export CICC=/mnt/d/DADOS/CICC/OPENDAP/
export IMAGENSDODIA=/mnt/e/OPERACIONAL/HICON/BOLETIM/IMAGENS/
export IMAGENSDODIA=/mnt/e/OPERACIONAL/HICON/BOLETIM/IMAGENS/
mkdir -p $IMAGENSDODIA


export SAIDAS=/mnt/e/OPERACIONAL/HICON/BOLETIM/`date +"%Y%m%d"` 
export HICON=$SAIDAS"/chuva_media/"
mkdir -p $SAIDAS
mkdir -p $HICON 



# checa se chegou os dados
#
#
# data de hoje
#
if test -z $1 ;then 
	export datadehoje=`date +"%Y%m%d"`
	export ciclo="00"
	export datagrads=`date +"00Z%d%b%Y"`

else
	export datadehoje=$1
    export ciclo=$2
    export datagrads=$3
fi

file0p50=$datadehoje"_"$ciclo"z_0P50.bin"

echo "* script autogerado em "`date` >script.gs
if test -e "$CICC/0P50/$file0p50" ;then
	echo "0P50 ---> ja foi baixado"
else
	echo "pi=baixagfs($datadehoje,$ciclo,0p50)" >>   script.gs
fi 



cat ./baixar_gfs.gs >>script.gs
grads -lbc "script.gs"   #>>./LOG.prn 2>&1   
	mkdir  -p $CICC/0P50 
	mv  $file0p50 $CICC/0P50/   
	
	
if  test  "$(ls -l $CICC/0P50/$file0p50  | awk '{print $5}')" -ge "652864"  ; then 

         

	echo " CALCULANDO CALCBACIA GFS "



	echo "dset $CICC/0P50/"$file0p50 > gfs_0p50.ctl
	echo "title GFS 0.25 deg starting from 00Z08jul2015, downloaded Jul 08 04:44 UTC" >>gfs_0p50.ctl
	echo "undef 9.999e+20" >>gfs_0p50.ctl
	echo "xdef 101 linear -80 0.50" >>gfs_0p50.ctl
	echo "ydef 101 linear -40 0.50" >>gfs_0p50.ctl
	echo "zdef 1 levels 1000">>gfs_0p50.ctl
	echo "tdef 16 linear "$datagrads" 1dy" >>gfs_0p50.ctl 
	echo "vars 1">>gfs_0p50.ctl
	echo "chuva  0  t,y,x  ** chuva mm">>gfs_0p50.ctl
	echo "endvars">>gfs_0p50.ctl

	echo "calcabcia 0p50"
	echo "'open gfs_0p50.ctl'" > script0p50.gs 
	echo "pi=calcbacia(chuva,1,16,SAE_GFS_0P50_)" >>script0p50.gs
	cat ./calcbacia.gs >>script0p50.gs 
	grads -lbc "script0p50.gs" >/dev/null

	ano=`date +"%Y"`
	anomes=`date +"%Y%m"`
	anomesdia=`date +"%Y%m%d"`
	grads_data=`date +"00Z01%b%Y"`
	grads_data2=`date -d "90 days ago" +"00Z%d%b%Y"`
	dia=`date +"%d"`

	mv SAE_GFS* $HICON

	/mnt/c/"Program Files/Polyspace/R2019a/bin/matlab.exe" -batch "run  gera_previsoes_passadas.m" 

else

	echo "arquivo com problemas"
	rm $CICC/0P50/$file0p50

fi

