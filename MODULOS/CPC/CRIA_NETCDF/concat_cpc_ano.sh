#!/bin/sh





	dirout="/mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/NETCDF/DIARIO/NCRCAT/"
	mkdir -p $dirout
	for ano in `seq 1979 2021`
	do
		fileout="CPC_CU_GAUGE_DIARIO_NCRCAT_"$ano".nc"
                echo "Montanbdo "$fileout  
		filein="/mnt/d/DADOS/OBS/CHUVAOBS/CPC_GAUGE_0P50/NETCDF/DIARIO/CPC_CU_GAUGE_DIARIO_"$ano"*"  
		ncrcat  $filein $dirout$fileout 
	done
