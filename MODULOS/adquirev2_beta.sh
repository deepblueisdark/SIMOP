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








adquire_V4B()
{
#### adquire_V4 0 3 240 GEFS0P25 gep01 00 "https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs." 0 0p25 
### o arquivo será 
## 1 hora inicial 
## 2 modelo workflow exemplo: GEFS0P25 
## 3 membro ensemble ou operacional   exemplo: gep01 ensemble gfs operacional 
## 4 rodada  exemplo: (0,6,12,18) 
## 5 fonte 
## 6 dia_da_previsao ( vazio data atual) 
## 7 resolução do modelo 
#
#  verifica o dia 
#
echo $1 $2 $3 $4 $5 $6 $7 $8 $9
hora=$1
modelo=$2
ens=$3
rodada=$4
fonte=$5
diap=$6
opt_app=$7
 
#
# tratamento da data 
#
if test -z $6 ;then 
		datarun=`date +"%Y%m%d" `
	else
		datarun=`date +"%Y%m%d" -d "$diap day ago"`
fi 

if test -z $7 ;then 
	opt_app="no"
fi 	

#
# cria o formato definido para os dados
#
file_grib=$modelo"_"$ens"_"$rodada"_"$datarun"_"$hora".grib2"
path_filegrib=$GFSALL"/"$file_grib

res="no"
#
#    baixa produto GFS
#	
if test $modelo = "GFS0P25" ;then 
		res="0p25"
		site_inv=$fonte$datarun"/"$rodada"/atmos/"$3".t"$rodada"z.pgrb2."$res".f"$hora".idx"
		site_grib=$fonte$datarun"/"$rodada"/atmos/"$3".t"$rodada"z.pgrb2."$res".f"$hora
		var=":PRATE:" 
		
elif test $modelo = "GEFS0P25" ;then 
		res="0p25"
		site_inv=$fonte$datarun"/"$rodada"/atmos/pgrb2sp25/"$ens".t"$rodada"z.pgrb2s."$res".f"$hora".idx"
		site_grib=$fonte$datarun"/"$rodada"/atmos/pgrb2sp25/"$ens".t"$rodada"z.pgrb2s."$res".f"$hora
		echo $site_grib 
		var=":APCP:"
		
elif test $modelo = "GEFS0P50" ;then 
		res="0p50"
		site_inv=$fonte$datarun"/"$rodada"/atmos/pgrb2bp5/"$ens".t"$rodada"z.pgrb2b."$res".f"$hora".idx"
		site_grib=$fonte$datarun"/"$rodada"/atmos/pgrb2bp5/"$ens".t"$rodada"z.pgrb2b."$res".f"$hora
		echo $site_grib 
		var=":PRATE:"
fi

if test $res = "no";then
	return 
else
echo $path_filegrib

if test -e $path_filegrib ;then 
	if test  $opt_app =  "rw" ;then 
		echo "Baixando novamente "$file_grib
		./get_inv.pl $site_inv | grep $var | ./get_grib.pl $site_grib $file_grib   > /dev/null 2>&1
		
		cp $file_grib $GFSALL 
	else
		echo "arquivo "$file_grib" ja foi baixado"
	fi	
else
	echo "Baixando "$file_grib
	./get_inv.pl $site_inv | grep $var | ./get_grib.pl $site_grib $file_grib   > /dev/null 2>&1
	cp $file_grib $GFSALL 
fi
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




#-----------------------------------------------------------------------
#
#  INICIO 
#historyff
#
  
source ../../config.omega
cp ../../COMMON_STUFF/get*.pl . 
mkdir -p $GFSALL

case $1 in


	adquire)
			adquire_V4B $2 $3 $4 $5 $6 $7 $8 $9 
			;;
	adquire_all)
			case $2 in 
			gfs)
				#
				# simop add gfs rodada fonte diap opt_app
				#
				echo "Baixando GFS operacional"
				for hora in `seq --format=%03g 0 3 384`
					do
						adquire_V4B $hora GFS0P25 gfs $3 $4 $5 $6 $7 $8 $9
					done
				;;
			gefs0p25)
				#
				# simop add gefs0p25 rodada fonte diap opt_app
				#
				echo "Baixando GEFS0P25 operacional"
				for hora in `seq --format=%03g 6 6 240`
				do
						for ens in `seq --format=%02g 0 1 30`
							do
								if test $ens = "00" ;then
									ensname="gec00"
								else
									ensname="gep"$ens
								fi 	
								echo "baixando "$hora" ens "$ens" " $ensname
								adquire_V4B $hora GEFS0P25 $ensname $3 $4 $5 $6  $7 $8 $9
							done	
				done
				;;
			gefs0p50)
				#
				# simop add gefs0p25 rodada fonte diap opt_app
				#
				echo "Baixando GEFS0P50 operacional"
				for hora in `seq --format=%03g 6 6 384`
				do
						for ens in `seq --format=%02g 0 1 30`
							do
								if test $ens = "00" ;then
									ensname="gec00"
								else
									ensname="gep"$ens
								fi 	
								echo "baixando "$hora" ens "$ens" " $ensname
								adquire_V4B $hora GEFS0P50 $ensname $3 $4 $5 $6  $7 $8 $9
							done	
				done				
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