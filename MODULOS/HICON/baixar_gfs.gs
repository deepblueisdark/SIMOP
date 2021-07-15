













'quit'




function baixagfs(config,ciclo,model)



if (model = "1p0") 
say "modleo gfs 1 grau"

'sdfopen http://nomads.ncep.noaa.gov:80/dods/gfs_1p00/gfs'config'/gfs_1p00_'ciclo'z'
'set lon 280 330'
'set lat -40 10'
t=1
k=1

'set fwrite 'config'_'ciclo'z_1P00.bin'
'set gxout fwrite'
while (t<=126)

if (t=1) 
'd sum(pratesfc*3*3600,t=2,t=8)' 
else
'd sum(pratesfc*3*3600,t='t',t='t+7')' 
endif 

t=t+8
k=k+1
'q time'
say t' 'k' 'result
endwhile
'disable fwrite'
'set gxout shaded'
say k' 't
'close 1'
endif 


if (model = "0p25") 
say "modleo gfs 0.25 de grau"
'sdfopen https://nomads.ncep.noaa.gov:9090/dods/gfs_0p25/gfs'config'/gfs_0p25_'ciclo'z'
'set lon 280 330'
'set lat -40 10'
t=1
k=1
'set fwrite 'config'_'ciclo'z_0P25.bin'
'set gxout fwrite'
while (t<=81)
'set t 't

if (t=1) 
'd sum(pratesfc*3*3600,t=2,t=8)' 
else
'd sum(pratesfc*3*3600,t='t',t='t+7')' 
endif 

t=t+8
k=k+1
'q time'
say t' 'k' 'result
endwhile
'disable fwrite'
'set gxout shaded'
say k' 't
'close 1'
endif 





if (model = "0p25h") 
say "modleo gfs 0.25 de grau horario"
***http://nomads.ncep.noaa.gov:9090/dods/gfs_0p25_1hr/gfs20170209/gfs_0p25_1hr_'ciclo'z
'sdfopen http://nomads.ncep.noaa.gov:80/dods/gfs_0p25_1hr/gfs'config'/gfs_0p25_1hr_'ciclo'z'
'set lon 280 330'
'set lat -40 10'
t=1
k=1
'set fwrite 'config'_'ciclo'z_0P25h.bin'
'set gxout fwrite'
while (t<=120)
'set t 't

if (t=1) 
'd sum(pratesfc*3*3600,t=2,t=24)' 
else
'd sum(pratesfc*3*3600,t='t',t='t+23')' 
endif 

t=t+24
k=k+1
'q time'
say t' 'k' 'result
endwhile
'disable fwrite'
'set gxout shaded'
say k' 't
'close 1'
endif 


if (model = "0p50") 
say "modleo gfs meio grau"
'sdfopen http://nomads.ncep.noaa.gov:80/dods/gfs_0p50/gfs'config'/gfs_0p50_'ciclo'z'
'set lon 280 330'
'set lat -40 10'
t=1
k=1
'set fwrite 'config'_'ciclo'z_0P50.bin'
'set gxout fwrite'
while (t<=126)
'set t 't
if (t =1)
'd sum(pratesfc*3*3600,t=2,t=8)' 
else
'd sum(pratesfc*3*3600,t='t',t='t+7')' 
endif 
t=t+8
k=k+1
'q time'
say t' 'k' 'result
endwhile
'disable fwrite'
'set gxout shaded'
say k' 't
'close 1'
endif 


return

