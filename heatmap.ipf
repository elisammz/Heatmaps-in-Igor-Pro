


//new_folder is the folder in where the heatmaps will be stored 

Function heatmaps("new_folder")
	String new_folder
	string thewave,wave_name, myHiststr, thewave2, wave_name2, thewave3, wave_name3
	variable i, j, y_min, y_max, x_min, x_max


	
	Pre_heatmp("myDataFolder", "myNewDataFolder", min_value, max_value) //this function eliminates outliers. It removes the points outside the 
	//the indicated range (min_value to max_value) and will store the new data without outliers in myNewDataFolder so, the raw data is conserved within the original folder
	
	 
	Folder_Maker("new_folder")
	 
 	DFREF path = GetDataFolderDFR()	//path = root
 	
 	cd new_folder
	DFREF new_path = GetDataFolderDFR() //new_path is path for new_folder
	
	cd path
	
	Separate_Force( new_folder, "no_outliers")
		 
	cd root:no_outliers
	
	//the histograms will be created and stored in new_folder
	i = 0
	j = 0
	
	thewave = wavelist ("*",";","")
	
	Do 
	
		wave_name = stringfromlist (i, thewave)
		
		if (strlen (wave_name) == 0)
			break	
		endif			
		
		cd new_path
		make/o/n = (65,20) myHist	//number of　bins in vertical and horizontal axis, 65x20 bins in this line	
		
		cd path
		cd new_folder
		
		thewave2 = wavelist ("*",";","")
		thewave3 = wavelist ("*",";","")
		 
		wave_name2 = stringfromlist (j, thewave2)
		wave_name3 = stringfromlist (j, thewave3)
		
		Duplicate/O $wave_name2, newwave2		
		
		y_min = WaveMin(newwave2)
		y_max = WaveMax(newwave2)
			
		print "y-scale: ", y_min, y_max
					
		Duplicate/O $wave_name3, newwave3	
		
		x_min = WaveMin(newwave3)
		x_max = WaveMax(newwave3)		
			
		print "x-scale: ", x_min, x_max
	
		setscale y, 0, 350e-12, myHist	//here limit for y can be assigned
		setscale x, min_value, max_value myHist	//here limit for y and x axis can be adjusted according to your min_value and max_value
		
		JointHistogram(newwave3, newwave2, myHist)
		
		myHiststr = wave_name + "_Hist" //suffix of the heatmaps is "Hist"
		
		Duplicate/O myHist, new_path:$myHiststr
		
		print wave_name
		
		plot_htmp(new_path:$myHiststr,wave_name)
					
		killwaves myHist, newwave2, newwave3
		
		i += 1
		j += 1
		
	while(1)	
	 	
	cd path	 
End




Function Insert_textbox (wave_name)
	string wave_name
	TextBox/C/N=text1 "\\Z18\\f01"+ wave_name + "_Ret" //ALWAYS MODIFY HERE IF NEEDED
End



Function plot_htmp (data, wave_name) //also saves the heatmap
	wave data
	string wave_name
	string myHiststr=""
	
	newimage data
	SetAxis/A left
	ModifyGraph width=360,height=360
	ModifyImage $myHiststr ctab= {50,*,YellowHot,0}
	ModifyGraph margin(left)=60,margin(bottom)=60,margin(top)=60,margin(right)=75
	ModifyGraph lblMargin(top)=20;DelayUpdate
	Label top "\\Z16\\f01\\u#2Separation (nm)"
	ModifyGraph nticks(top)=10,minor(top)=0
	ModifyGraph fStyle(top)=1,fSize(top)=12
	ModifyGraph lblMargin(left)=20;DelayUpdate
	Label left "\\Z16\\f01\\u#2Force (pN)"
	ModifyGraph fStyle(left)=1,fSize(left)=12
	ModifyGraph nticks(left)=10,minor(left)=0
	ColorScale/C/N=text0/A=MC image=$myHiststr,nticks=3
	ColorScale/C/N=text0/A=RC/X=-18.33/Y=5.21 image=$myHiststr
	ModifyGraph mirror(top)=3
	
	Insert_textbox (wave_name) 
	
	SavePICT/E=-6/B=288/I/W=(0,0,6,6) as wave_name
End
