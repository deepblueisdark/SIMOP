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








adquire_V4()
{

## 1 hora inicial 
## 2 incremento 
## 3 hora final 
## 4 modelo workflow exemplo: GEFS0P25 
## 5 membro ensemble ou operacional   exemplo: gep01 ensemble gfs operacional 
## 6 rodada  exemplo: (0,6,12,18) 
## 7 fonte 
## 8 dia_da_previsao ( vazio data atual) 
## 9 resolução do modelo 
#
#  verifica o dia 
#
	if test -z $8 ;then 
		datarun=`date +"%Y%m%d" `
	else
		datarun=`date +"%Y%m%d" -d "$8 day ago"`
	fi 
#
#    baixa produto GFS
#	
	if test $5 = "gfs" ;then 
		for hora in `seq --format=%03g $1 $2 $3`
		do
		
			file_grib=$4"_"$5"_"$6"_"$datarun"_"$hora".grib2"
			site_inv=$7$datarun"/"$6"/atmos/"$5".t"$6"z.pgrb2."$9".f"$hora".idx"
			site_grib=$7$datarun"/"$6"/atmos/"$5".t"$6"z.pgrb2."$9".f"$hora
			./get_inv.pl $site_inv | grep ":PRATE:" | ./get_grib.pl $site_grib $file_grib  > lixo
		done
	else 
#
#
#	baixa produto GEFS 
#	
		for hora in `seq --format=%03g $1 $2 $3`
		do
			if test $9 = "0p25" ;then
				file_grib=$4"_"$5"_"$6"_"$datarun"_"$hora".grib2"
				site_inv=$7$datarun"/"$6"/atmos/pgrb2sp25/"$5".t"$6"z.pgrb2s.0p25.f"$hora".idx"
				site_grib=$7$datarun"/"$6"/atmos/pgrb2sp25/"$5".t"$6"z.pgrb2s.0p25.f"$hora
				echo $site_grib 
				./get_inv.pl $site_inv | grep ":APCP:" | ./get_grib.pl $site_grib $file_grib  > lixo
			else
				file_grib=$4"_"$5"_"$6"_"$datarun"_"$hora".grib2"
				site_inv=$7$datarun"/"$6"/atmos/pgrb2bp5/"$5".t"$6"z.pgrb2b.0p50.f"$hora".idx"
				site_grib=$7$datarun"/"$6"/atmos/pgrb2bp5/"$5".t"$6"z.pgrb2b.0p50.f"$hora
				echo $site_grib 
				./get_inv.pl $site_inv | grep ":PRATE:" | ./get_grib.pl $site_grib $file_grib  > lixo
			fi
		done
	fi 


	
}



#
# 
#  monta o grid final 
#
monta_grib()
{
# 1  prefixo arquivos
# 2 hora inicial
# 3  inc hora
# 4  hora final 
# 5  ciclo
# 6   file grib final 
	echo $1" "$2" "$3" "$4" "$5" "$6" "$7
	mkdir -p $7
 
	for hora in `seq --format=%03g $2 $3 $4`
	do 
		file=$1"_"$5`date +"_%Y%m%d"`"_"$hora".grib2"
		fileout=$7"/"$6
		echo $file
		if test -e $file ;then 
			echo $file 
			if test -e $fileout ;then 
				wgrib2 -append -grib $fileout  $file 
			else 
				wgrib2 -grib $fileout  $file 
			fi
			mv $file $GFSALL 
		else
			echo "Em "`date`" arquivo "$file" nao foi encontrado" >>logao
		fi 	
	done 
	
}


#-----------------------------------------------------------------
#
#
# operaciona para pegar gfs 0.25
#
pega_gfs0p25_opera()
{
#-----------------------------------------------------------------------
#
# gfs0p25
#
# 1 dias para trás (0 ou vazio para data atual)
# 2 rodada 
#  
#
if test -z $1 ;then 
dia=0
datarun=`date +"%Y%m%d"`
else
dia=$1
datarun=`date +"%Y%m%d" -d"$1 days ago"`
fi 
if test -z $2 ;then
	rodada="00"
else
	rodada=$2
fi 	

fonte1="https://www.ftp.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."
fonte2="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs."

echo "Baixando GFS 0P25 OPERACIONAL"
echo $datarun" "$rodada

filegrib="GFS0P25_"$datarun$rodada".grib2"
if test -e $GFS/$filegrib ;then
	echo "Arquivo:"$filegrib" Ja foi baixado e montado"
else	
	adquire_V4 0 3 384 GFS0P25 gfs $rodada $fonte2  $dia 0p25  
	monta_grib GFS0P25_gfs 0 3 384 $rodada  $filegrib $GFS
fi 
} 




pega_gefs_0p50_operacional()
{
#
# GEFS
#
if test -z $1 ;then 
dia=0
datarun=`date +"%Y%m%d"`
else
dia=$1
datarun=`date +"%Y%m%d" -d"$1 days ago"`
fi 
if test -z $2 ;then
	rodada="00"
else
	rodada=$2
fi 

if test -z $3 ;then
	ens_inicio=0
else
		ens_inicio=$3
fi

if test -z $4 ;then
	ens_final=30
	else
	ens_final=$4
fi



fonte3="https://www.ftp.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."
fonte4="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gens/prod/gefs."
fonte5="https://ftpprd.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."

filegrib="GEFS0P50_"$datarun$rodada".grib2"
if test -e $GEFS/$filegrib ;then
	echo "Arquivo:"$filegrib" Ja foi baixado e montado"
else	

	for ens in `seq --format=%02g $ens_inicio $ens_final`
	do
		if test $ens = "00" ;then
			ensname="gec00"
		else
			ensname="gep"$ens
		fi 	
		
		adquire_V4 0 6 384 GEFS0P50 $ensname $rodada $fonte3 $dia 0p50  
		monta_grib "GEFS0P50_"$ensname 0 6 384 $rodada  $filegrib $GEFS
	done 
fi 
}


pega_gefs_0p50_extendido_operacional()
{
#
# GEFS
#
	if test -z $1 ;then 
		dia=0
		datarun=`date +"%Y%m%d"`
	else
		dia=$1
		datarun=`date +"%Y%m%d" -d"$1 days ago"`
	fi 
	if test -z $2 ;then
		rodada="00"
	else
		rodada=$2
	fi 



fonte3="https://www.ftp.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."
fonte4="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gens/prod/gefs."
fonte5="https://ftpprd.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."

filegrib="GEFS0P50X_"$datarun$rodada".grib2"
if test -e $GEFS/$filegrib ;then
	echo "Arquivo:"$filegrib" Ja foi baixado e montado"
else	
	for ens in `seq --format=%02g 0 30`
	do
		if test $ens = "00" ;then
			ensname="gec00"
		else
			ensname="gep"$ens
		fi 	
		
		adquire_V4 0 6 840 GEFS0P50 $ensname $rodada $fonte3 $dia 0p50  
		monta_grib "GEFS0P50_"$ensname 0 6 840 $rodada $filegrib $GEFS
	done 
fi 
}




pega_gefs_0p25_operacional()
{
#
# GEFS
#
if test -z $1 ;then 
dia=0
datarun=`date +"%Y%m%d"`
else
dia=$1
datarun=`date +"%Y%m%d" -d"$1 days ago"`
fi 
if test -z $2 ;then
	rodada="00"
else
	rodada=$2
fi 


	ens_inicio=0
	ens_final=30 



fonte3="https://www.ftp.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."
fonte4="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gens/prod/gefs."
fonte5="https://ftpprd.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."

filegrib="GEFS0P25_"$datarun$rodada".grib2"
if test -e $GEFS/$filegrib ;then
	echo "Arquivo:"$filegrib" Ja foi baixado e montado"
else	
	echo "[GEFS0P25 - Baixando membros de "$ens_inicio" a "$ens_final
	for ens in `seq --format=%02g $ens_inicio $ens_final`
	do
		if test $ens = "00" ;then
			ensname="gec00"
		else
			ensname="gep"$ens
		fi 	
		
		adquire_V4 0 6 240 GEFS0P25 $ensname $rodada $fonte3 $dia 0p25  
		monta_grib "GEFS0P25_"$ensname 0 6 240 $rodada $filegrib  $GEFS
		done 
fi 
}


pega_gefs_0p25_operacional_paralelo()
{
#
# GEFS
#
if test -z $1 ;then 
dia=0
datarun=`date +"%Y%m%d"`
else
dia=$1
datarun=`date +"%Y%m%d" -d"$1 days ago"`
fi 
if test -z $2 ;then
	rodada="00"
else
	rodada=$2
fi 

if test -z $3 ;then
	ens_inicio=0
	modo_monta=0
else
		ens_inicio=$3
		moda_monta=1
fi

if test -z $4 ;then
	ens_final=30
	moda_monta=0
	else
	ens_final=$4
	modo_monta=1
fi

fonte3="https://www.ftp.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."
fonte4="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gens/prod/gefs."
fonte5="https://ftpprd.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."

filegrib="GEFS0P25_"$datarun$rodada".grib2"
#if test -e $GEFS/$filegrib ;then
##	echo "Arquivo:"$filegrib" Ja foi baixado e montado"
#else	
	echo "[GEFS0P25 - Baixando membros de "$ens_inicio" a "$ens_final
	for ens in `seq --format=%02g $ens_inicio $ens_final`
		do
			if test $ens = "00" ;then
				ensname="gec00"
			else
				ensname="gep"$ens
			fi 	
		
			adquire_V4 0 6 240 GEFS0P25 $ensname $rodada $fonte3 $dia 0p25  

		
	done 
	mkdir -p $OUTPUT/GEFS0P25
	mv *.grib2 $OUTPUT/GEFS0P25
#fi 
}

monta_gefs_0p25_operacional_paralelo()
{
#
# GEFS
#
if test -z $1 ;then 
dia=0
datarun=`date +"%Y%m%d"`
else
dia=$1
datarun=`date +"%Y%m%d" -d"$1 days ago"`
fi 
if test -z $2 ;then
	rodada="00"
else
	rodada=$2
fi 


	ens_inicio=0
	ens_final=30 



fonte3="https://www.ftp.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."
fonte4="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gens/prod/gefs."
fonte5="https://ftpprd.ncep.noaa.gov/data/nccf/com/gens/prod/gefs."

filegrib="GEFS0P25x_"$datarun$rodada".grib2"
if test -e $GEFS/$filegrib ;then
	echo "Arquivo:"$filegrib" Ja foi baixado e montado"
else	
	echo "[GEFS0P25 - Baixando membros de "$ens_inicio" a "$ens_final
	for ens in `seq --format=%02g $ens_inicio $ens_final`
	do
		if test $ens = "00" ;then
			ensname="gec00"
		else
			ensname="gep"$ens
		fi 	
		cd $OUTPUT/GEFS0P25
		#adquire_V4 0 6 240 GEFS0P25 $ensname $rodada $fonte3 $dia 0p25  
		monta_grib "GEFS0P25_"$ensname 0 6 240 $rodada $filegrib  $GEFS
		done 
fi 
}

#-----------------------------------------------------------------------
#
#  INICIO 
#
#
  
source ../../config.omega
cp ../../COMMON_STUFF/get*.pl . 
mkdir -p $GFSALL

case $1 in


	adquire)
			if test -z $9 ;then 
				datarun=`date +"%Y%m%d" `
			else	
				datarun=`date +"%Y%m%d" -d "$9 day ago"`
			fi
				
			adquire_V4 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12
			mv $5"*.grib2" $GFSALL
			;;
			
	gfs)
		case $2 in 
			gfs) 
				pega_gfs0p25_opera  $3 $4	
				;;
			gefs0p25x)
			    echo $3 $4 $5 $6
				pega_gefs_0p25_operacional_paralelo  $3 $4 $5 $6 
				monta_gefs_0p25_operacional_paralelo $3 $4 $5 $6
				;;
			gefs0p25)
			    echo $3 $4 $5 $6
				pega_gefs_0p25_operacional  $3 $4 $5 $6 
				;;
			gefs0p50)
				pega_gefs_0p50_operacional  $3 $4 $5 $6
				;;
			gefsx)
				pega_gefs_0p50_extendido_operacional  $3 $4
				;;
			all) 
				pega_gfs0p25_opera  $3 $4
				pega_gefs_0p25_operacional  $3 $4
				pega_gefs_0p50_operacional  $3 $4
				#pega_gefs_0p50_extendido_operacional 1 00 
				;;
		esac 
		;;		
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


























