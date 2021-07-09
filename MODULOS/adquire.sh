#!/bin/bash 

#
#██████╗ ██████╗ ███████╗ ██████╗██╗██████╗ ██╗████████╗ █████╗  ██████╗ █████╗  ██████╗ 
#██╔══██╗██╔══██╗██╔════╝██╔════╝██║██╔══██╗██║╚══██╔══╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗
#██████╔╝██████╔╝█████╗  ██║     ██║██████╔╝██║   ██║   ███████║██║     ███████║██║   ██║
#██╔═══╝ ██╔══██╗██╔══╝  ██║     ██║██╔═══╝ ██║   ██║   ██╔══██║██║     ██╔══██║██║   ██║
#██║     ██║  ██║███████╗╚██████╗██║██║     ██║   ██║   ██║  ██║╚██████╗██║  ██║╚██████╔╝
#╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝#
#
#   _____   _____     _____       __   ___    _____    _____    ___  
#  / ____| |  __ \   / ____|     / /  / _ \  |  __ \  | ____|  / _ \ 
# | |      | |__) | | |         / /  | | | | | |__) | | |__   | | | |
# | |      |  ___/  | |        / /   | | | | |  ___/  |___ \  | | | |
# | |____  | |      | |____   / /    | |_| | | |       ___) | | |_| |
#  \_____| |_|       \_____| /_/      \___/  |_|      |____/   \___/ 
#                                                                                                                                   
#                                                                   
baixa_cpc_0p50()
{
## 
# verifca quantos dias para trás vão ser baixados
#
if test -z $1 ;then 
LIMITE=15 
else
LIMITE=$1
fi

DATABASE=$OBS   
ORIGINAIS=$DATABASE"/CHUVAOBS/CPC_GAUGE_0P50/BIN/"
mkdir -p $ORIGINAIS     > /dev/null 2>&1
echo "[ CPC ] BAIXANDO CPC_GAUGE_0P50 INICIO:"`date +"%Y%m%d %H:%M"`
#
# atualiza banco de dados
#
#
# baixa as 63 ultimas chuvas. se jรก baixou passa adiante. 
#
cd $ORIGINAIS 
pwd 
for n in `seq --format=%02g 1 $LIMITE`
do
    download_data=`date -d "$n days ago" +"%Y%m%d"`
    ano=`date -d "$n days ago" +"%Y"`
	
    file="PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx."$download_data".RT"
    #filenc="CHUVACPC_0P50_"$download_data".nc" 
	#filencpath="$RECORTE/$filenc"
	if test  -e $file  
    then 
    echo "[ CPC ] ja existe:"$file 
    else 
	echo "[ CPC ] BAIXANDO CPC_GAUGE_0P50 :"$file
	wget -nc ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/RT/$ano/$file  > /dev/null 2>&1
    fi
done
echo "[ CPC ] BAIXANDO CPC_GAUGE_0P50  FINAL:"`date +"%Y%m%d %H:%M"`

}



# ███╗   ███╗███████╗██████╗  ██████╗ ███████╗        ██╗     ██████╗██████╗ ████████╗███████╗ ██████╗        ██╗     ██████╗ ██████╗ ███╗   ███╗ ██████╗ ██████╗  ██╗ ██╗        ██╗    ██╗  ██╗ ██████╗ ██████╗  █████╗ ██████╗ ██╗ ██████╗ 
# ████╗ ████║██╔════╝██╔══██╗██╔════╝ ██╔════╝       ██╔╝    ██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔════╝       ██╔╝    ██╔════╝ ██╔══██╗████╗ ████║██╔═████╗██╔══██╗███║███║       ██╔╝    ██║  ██║██╔═══██╗██╔══██╗██╔══██╗██╔══██╗██║██╔═══██╗
# ██╔████╔██║█████╗  ██████╔╝██║  ███╗█████╗        ██╔╝     ██║     ██████╔╝   ██║   █████╗  ██║           ██╔╝     ██║  ███╗██████╔╝██╔████╔██║██║██╔██║██████╔╝╚██║╚██║      ██╔╝     ███████║██║   ██║██████╔╝███████║██████╔╝██║██║   ██║
# ██║╚██╔╝██║██╔══╝  ██╔══██╗██║   ██║██╔══╝       ██╔╝      ██║     ██╔═══╝    ██║   ██╔══╝  ██║          ██╔╝      ██║   ██║██╔═══╝ ██║╚██╔╝██║████╔╝██║██╔═══╝  ██║ ██║     ██╔╝      ██╔══██║██║   ██║██╔══██╗██╔══██║██╔══██╗██║██║   ██║
# ██║ ╚═╝ ██║███████╗██║  ██║╚██████╔╝███████╗    ██╔╝       ╚██████╗██║        ██║   ███████╗╚██████╗    ██╔╝       ╚██████╔╝██║     ██║ ╚═╝ ██║╚██████╔╝██║      ██║ ██║    ██╔╝       ██║  ██║╚██████╔╝██║  ██║██║  ██║██║  ██║██║╚██████╔╝
# ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚═╝         ╚═════╝╚═╝        ╚═╝   ╚══════╝ ╚═════╝    ╚═╝         ╚═════╝ ╚═╝     ╚═╝     ╚═╝ ╚═════╝ ╚═╝      ╚═╝ ╚═╝    ╚═╝        ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝ 
                                                                                                                                                                                                                                            
baixa_merge_gpm_cptec_11km_early_horario()
{
DATABASE=$OBS  
ORIGINAIS=$DATABASE"/CHUVAOBS/MERGE_CPTEC_HORARIO_GPM_11KM/GRIB/"
mkdir -p $ORIGINAIS    > /dev/null 2>&1
echo "[ MERGE GPM CPTEC EARLY  HORARIO ] BAIXANDO  INICIO:"`date +"%Y%m%d %H:%M"`
cd $ORIGINAIS
if test -z $2 ;then 
hora=`date +"%H"` 
else
hora=$2 
fi 
if test -z $1 ;then 
numdias=3
else
numdias=$1
fi

echo "[ MERGE GPM CPTEC EARLY  HORARIO ] BAIXANDO ATE A HORA:"

for ndias in `seq $numdias -1 0`
do
for horas in `seq --format="%02g" 0 23`
do
anomesdiahora=`date +"%Y%m%d$horas" -d "$ndias days ago"`
ano=`date +"%Y" -d "$ndias days ago"`
mes=`date +"%m" -d "$ndias days ago"`
dia=`date +"%d" -d "$ndias days ago"`

download_data=`date +"%Y%m%d" -d "$ndias days ago"`

	
filegrib="MERGE_CPTEC_"$anomesdiahora".grib2"
filectl="MERGE_CPTEC_"$anomesdiahora".ctl"  
fileidx="MERGE_CPTEC_"$anomesdiahora".idx"
	
	
	

	
site="ftp.cptec.inpe.br/modelos/tempo/MERGE/GPM/HOURLY/"$ano"/"$mes"/"$dia"/"


ftppath=$site"/"$filegrib
if test -e $filegrib
then
	echo "[ MERGE GPM CPTEC EARLY  HORARIO ] "$filegrib " ja existe"
	#	echo "'lats4d  -i MERGE_GPM_early_$download_data$horas.ctl  -o  $filenc -q'" > gpm.gs
    #grads -lbc "gpm.gs" 
	#mv $filenc ../NETCDF/
else
	echo "[ MERGE GPM CPTEC  EARLY  HORARIO ] "$filegrib " sendo baixado"
    ftppath=$site"/"$filegrib
    wget -nc $ftppath      > /dev/null 2>&1
	ftppath=$site"/"$filectl
	wget -nc $ftppath      > /dev/null 2>&1
	ftppath=$site"/"$fileidx
	wget -nc $ftppath      > /dev/null 2>&1

    # if test -e $filegrib ;then 

	# echo "'lats4d  -i MERGE_GPM_early_$download_data$horas.ctl  -o  $filenc -q'" > gpm.gs
    # grads -lbc "gpm.gs" 
	# mv $filenc ../NETCDF/
	# fi 
fi
done
done 
echo "          FINAL:"`date +"%Y%m%d %H:%M"`
#cd $WORK
echo "[ MERGE GPM CPTEC EARLY  HORARIO ]  BAIXANDO  CMORPH25KM   FINAL:"`date +"%Y%m%d %H:%M"`
}







##
#
#███████╗███████╗██████╗ ██████╗  █████╗ ███╗   ███╗███████╗███╗   ██╗████████╗ █████╗ ███████╗
#██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔════╝████╗  ██║╚══██╔══╝██╔══██╗██╔════╝
#█████╗  █████╗  ██████╔╝██████╔╝███████║██╔████╔██║█████╗  ██╔██╗ ██║   ██║   ███████║███████╗
#██╔══╝  ██╔══╝  ██╔══██╗██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   ██╔══██║╚════██║
#██║     ███████╗██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   ██║  ██║███████║
#╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
#      








merge_gpm_11km_early_horario_netcdf()
{
DATABASE=$OBS  
ORIGINAIS=$DATABASE"/CHUVAOBS/MERGE_CPTEC_HORARIO_GPM_11KM/GRIB/"
NETCDF=$DATABASE"/CHUVAOBS/MERGE_CPTEC_HORARIO_GPM_11KM/NETCDF/"
mkdir -p $NETCDF
mkdir -p $ORIGINAIS    > /dev/null 2>&1
echo "[ MERGE GPM CPTEC EARLY  HORARIO ] TRANSFORMANDO  INICIO:"`date +"%Y%m%d %H:%M"`
cd $ORIGINAIS
mkdir -p $ORIGINAIS    > /dev/null 2>&1
echo "[ MERGE GPM CPTEC EARLY  HORARIO ] BAIXANDO  INICIO:"`date +"%Y%m%d %H:%M"`
cd $ORIGINAIS
if test -z $2 ;then 
hora=`date +"%H"` 
else
hora=$2 
fi 


if test -z $1 ;then 
numdias=3
else
numdias=$1
fi

echo "[ MERGE GPM CPTEC EARLY  HORARIO ] NUM DE DIAS A SEREM PROCESSADOS "$numdias
for ndias in `seq $numdias -1 0`
do
for horas in `seq --format="%02g" 0 23`
do
	anomesdiahora=`date +"%Y%m%d$horas" -d "$ndias days ago"`
	ano=`date +"%Y" -d "$ndias days ago"`
	mes=`date +"%m" -d "$ndias days ago"`
	download_data=`date +"%Y%m%d" -d "$ndias days ago"`

	
	filegrib="MERGE_CPTEC_"$anomesdiahora".grib2"  
	datagrads=`date +"00Z%d%b%Y" -d"$n days ago"`
    filenc="MERGE_CPTEC_"$download_data$horas".nc" 
	
	




if [ -f $NETCDF$filenc ]
then
	echo "[ MERGE GPM EARLY  HORARIO ] "$filenc "  Já existe"
else
    if test -e $filegrib ;then 
		echo "[ MERGE GPM EARLY  HORARIO ] "$filenc "  criando netcdf"
		echo "'lats4d -vars prec  -i MERGE_CPTEC_$download_data$horas.ctl  -o  $filenc -q'" > gpm.gs
		grads -lbc "gpm.gs" >/dev/null 
		mv $filenc ../NETCDF/
	else
		echo "[ MERGE GPM EARLY  HORARIO ] "$filegrib "  NAO EXISTE"
	fi  

fi
done
done 
echo "          FINAL:"`date +"%Y%m%d %H:%M"`
#cd $WORK
echo "[ MERGE GPM EARLY  HORARIO ]     FINAL:"`date +"%Y%m%d %H:%M"`
}




merge_gpm_11km_early_cria_diaria()
{
DATABASE=$OBS  


ORIGINAIS=$DATABASE"/CHUVAOBS/MERGE_CPTEC_HORARIO_GPM_11KM/NETCDF/"

NETCDF=$DATABASE"/CHUVAOBS/MERGE_CPTEC_DIARIO_GPM_11KM/NETCDF/"


mkdir -p $NETCDF
mkdir -p $ORIGINAIS    > /dev/null 2>&1







cd $ORIGINAIS


if test -z $2 ;then 
hora=`date +"%H"` 
else
hora=$2 
fi 


if test -z $1 ;then 
numdias=3
else
numdias=$1
fi

echo "[ MERGE GPM CPTEC EARLY  DIARIO ] NUM DE DIAS A SEREM PROCESSADOS "$numdias






for ndias in `seq $numdias -1 1`
do
	ano=`date +"%Y" -d "$ndias days ago"`
	mes=`date +"%m" -d "$ndias days ago"`
	dia=`date +"%d" -d "$ndias days ago"`
	
	
	files="MERGE_CPTEC_"$ano$mes$dia"*.nc"
	
	filencd="MERGE_CPTEC_DIARIO_"$ano$mes$dia".nc"
	if test -e $NETCDF/$filencd ;then 
		echo "[ MERGE GPM CPTEC EARLY  DIARIO ] Arquivo "$filencd" JA EXISTE"
	else
		ncra -h -y ttl  $files $filencd   > /dev/null 
		mv $filencd $NETCDF 
	fi 
done
echo "          FINAL:"`date +"%Y%m%d %H:%M"`
echo "[ MERGE GPM EARLY  HORARIO ]     FINAL:"`date +"%Y%m%d %H:%M"`
}















# https://podaac-opendap.jpl.nasa.gov/opendap/hyrax/allData/ghrsst/data/L4/GLOB/UKMO/OSTIA/2006/091/20060401-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc.bz2.html

# https://podaac-opendap.jpl.nasa.gov/opendap/hyrax/allData/ghrsst/data/L4/GLOB/UKMO/OSTIA/2006/091/20060401-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc.bz2.html


# https://podaac-opendap.jpl.nasa.gov/opendap/hyrax/allData/ghrsst/data/L4/GLOB/UKMO/OSTIA/2006/091/20060401-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc.bz2.nc?lat%5B0:1:3599%5D,lon%5B0:1:7199%5D,analysed_sst%5B0:1:0%5D%5B0:1:3599%5D%5B0:1:7199%5D,analysis_error%5B0:1:0%5D%5B0:1:3599%5D%5B0:1:7199%5D,sea_ice_fraction%5B0:1:0%5D%5B0:1:3599%5D%5B0:1:7199%5D,mask%5B0:1:0%5D%5B0:1:3599%5D%5B0:1:7199%5D

# https://podaac-opendap.jpl.nasa.gov/opendap/hyrax/allData/ghrsst/data/L4/GLOB/UKMO/OSTIA/2014/091/20140401-UKMO-L4HRfnd-GLOB-v01-fv02-OSTIA.nc.bz2.nc?lat%5B0:1:3599%5D,lon%5B0:1:7199%5D,analysed_sst%5B0:1:0%5D%5B0:1:3599%5D%5B0:1:7199%5D
# #------------------------------------------------------------------------------------------
#  __  __          _____ _   _ 
# |  \/  |   /\   |_   _| \ | |
# | \  / |  /  \    | | |  \| |
# | |\/| | / /\ \   | | | . ` |
# | |  | |/ ____ \ _| |_| |\  |
# |_|  |_/_/    \_\_____|_| \_|
#

source ../../config.omega

case $1 in
	obs) 
		case $2 in
			all) 
				baixa_cpc_0p50  $3 $4
				baixa_merge_gpm_cptec_11km_early_horario $3 $4
				merge_gpm_11km_early_horario_netcdf $3 $4
				merge_gpm_11km_early_cria_diaria $3 $4
				;;
			gpm)
				baixa_merge_gpm_cptec_11km_early_horario $3 $4
				merge_gpm_11km_early_horario_netcdf $3 $4
				merge_gpm_11km_early_cria_diaria $3 $4
				;;
			cpc)			
				baixa_cpc_0p50 $3 $4 $5 
				;;
		esac
		;;	
	esac 