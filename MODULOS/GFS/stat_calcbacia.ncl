
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
 


;
;
; stat 
begin
	YYYYMMDD=systemfunc("date +'%Y%m%d' -d '0 day ago'")
	config=True
	config@input_stat="/mnt/e/OPERACIONAL/OUTPUT/"+YYYYMMDD+"/gfs_saida2_"+YYYYMMDD+".csv"
	config@output_stat="/mnt/e/OPERACIONAL/OUTPUT/"+YYYYMMDD+"/gfs_stat_"+YYYYMMDD+".csv"
	
	
	units=systemfunc("date +'days since  %Y-%m-%d 00:00:00' -d '0 day ago'")
	num_bacias=13
    print(units)
	; le arquivo de pre-estatitisca 
	;
	nrow = numAsciiRow(	config@input_stat)
	ncol = numAsciiCol(	config@input_stat)+3
	print("Arquivo com "+nrow+" linhas e "+ncol+" colunas")
	base = readAsciiTable(	config@input_stat, ncol, "float",0)
	ens=tointeger(base(:,2)) 
	
		
	;print(ens)
	;print(base(:,8:10))
	;print(tointeger(base(0,1)))


    tempos=new((/nrow,4/),"integer")
	tempos(:,0:3)=tointeger(base(:,8:11))
	id_tempos=tointeger(cd_inv_calendar(tempos(:,0),tempos(:,1),tempos(:,2),tempos(:,3),tempos(:,3)*0,tempos(:,3)*0,units,0) )
	id_tempos@units=units
	itime_max=tointeger(max(id_tempos))
	itime_min=tointeger(min(id_tempos))
	
	
	temp=new((/itime_max+1/),"float")
	do i=0,itime_max
		temp(i)=i
	end do 	
	temp@units=units
	tempos_dias=tointeger(cd_calendar(temp,0))

	
		
		
	;print(id_tempos(0:3352)+" "+tempos(0:3352,0)+" "+tempos(0:3352,1)+" "+tempos(0:3352,2)+" ==>"+base(0:3352,8)+" "+base(0:3352,9)+" "+base(0:3352,10))
	print(itime_max)
	
	;
	; cria matriz de trabalho a partir do arquivo de estattisdtica
	;
	chuva=new((/itime_max+1,num_bacias+1,max(ens)+1/),"float") 
	chuva=0.0
	do i=0,nrow-1
		do j=0,num_bacias-1
		;print(i+" "+j+" "+id_tempos(i)) 
			if (base(i,j+12) .eq. 0) 
				chuva(id_tempos(i),j,ens(i))=chuva(id_tempos(i),j,ens(i))+0.00000001
			else
				chuva(id_tempos(i),j,ens(i))=chuva(id_tempos(i),j,ens(i))+base(i,j+12)
			end if 
		end do
    end do 		
		
	;print(base(0:1,:))
		;printVarSummary(chuva)

	;
	; cria matrix stat 
	;
	g=new((/itime_max,30,num_bacias/),"float",0)
	opt=False
	do t=itime_min,itime_max-1
		do j=0,num_bacias-1
			g(t,:,j)=stat_dispersion(chuva(t,j,:),opt)
			;
			;  22,23 e 24 só funciona para n=1000 por isso 
			; uso para outros calculos
			; 
			;  22 = media dos percentis altos
			;  23  = media dos percentis baixos
			;  24  = diferença entre a média e o maximo dos maximos
			;
			g(t,22,j)=(g(t,11,j)+g(t,12,j)+g(t,13,j))/3
			g(t,23,j)=(g(t,3,j)+g(t,4,j)+g(t,5,j))/3
			g(t,24,j)=(g(t,14,j)-g(t,10,j)) 
			
		end do
	end do 		
	
	;print(chuva(0,0,:)+" "+chuva(0,1,:)) 
	;print(g(0,0,:))
	;print(g(1,0,:))
	;
	;  apenas  para  plotar valores das estatisticas
	;
	; nStat = num(.not.ismissing(g(0,:,:)))
	; statLabel = new ( nStat, "string")
	;
	;
	statLabel = (/ "    mean", "  stddev", "     min" \
               , "  lowDec", "  LowOct", "  LowSex" \
               , "LowQuart", "  LowTri" \
               , "  Median" \
               , "   HiTri", " HiQuart","   HiSex","   HiOct", "   HiDec" \
               , "     Max", "   Range","  Disper","     RMS" \
               , "    nTot", "    nUse","    nMsg","    %Msg" /)
	asciiwrite(".stat_headers.dat",statLabel)
	;
	;
	;  grava em opt@fout a saida dos dados
	;
	;
	;  inicialziacao dos arquivos temporarios e finais
	;
	opt=True
	opt@fout="temp_stat.csv"
	if (fileexists("out.csv")) then
		system("rm out.csv")
		title="lxx xxx xxx xx"
		asciiwrite("out.csv",title)
	else
		title="xxx xxx xx xxx "
		asciiwrite("out.csv",title)
	end if
	if (fileexists("temp_stat.csv")) then
		system("rm temp_stat.csv")
	end if 
	;
	;   cria a tabela e depois grava em arquivo
	;
    fmt=sprinti("%d",num_bacias)+"f10.4"
	do t=itime_min,itime_max-1
		;opt@title=sprinti("%02i",tointeger(base(t,0)))+" "+sprinti("%02i",tointeger(base(t,1)))+" "+sprinti("%02i",tointeger(base(t,2)))+" "+sprinti("%02i",tointeger(base(t,3)))
		title1=sprinti("%02i",tempos_dias(t,0))+" "+sprinti("%02i",tempos_dias(t,1))+" "+sprinti("%02i",tempos_dias(t,2))+" "+sprinti("%02i",tempos_dias(t,3))
		do i=0,num_bacias-5
			title=title1+" -99 "
			title1=title
		end do	
	    opt@title=title
		b=g(t,:,:)
	    b@_FillValue=-1
		write_matrix(b,fmt,opt)
		system("cat temp_stat.csv >> out.csv")
	end do
	system("mv out.csv "+config@output_stat) 
	system("rm temp_stat.csv")	
end 
