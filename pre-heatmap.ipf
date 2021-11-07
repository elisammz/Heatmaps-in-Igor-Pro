//removes outliers
//creates pre-heatmap waves
//old_folder is ext_folder or ret_folder
Function Pre_heatmp(old_folder, new_folder, min_s, max_s) 
	String old_folder, new_folder
	Variable min_s, max_s
	Variable i, numPoints, numOutliers, k, j
	Variable val_f, val_s
	String theWave, wave_name
	
	DuplicateDataFolder $old_folder, $new_folder
	
	DFREF path = GetDataFolderDFR()
	
	cd new_folder

	i = 0		//counter for the waves in the main folder
	
	theWave = wavelist("*", ";", "")

	Do
		wave_name = stringfromlist(i, theWave)

		if(strlen(wave_name) == 0)
			break
		endif
		
		Duplicate/O/D $wave_name new		//new wave named new

		Make/O/N=(dimsize(new, 0)) newwave_f	
		Make/O/N=(dimsize(new, 0)) newwave_s
		newwave_f[]=new[p][0] //force
		newwave_s[]=new[p][1] //sep
		
		numOutliers = 0	//counter for the number of outliers

		numPoints = dimsize(new, 0) // number of times to loop
		print numPoints
		
		
		for (k = 0; k < numPoints; k += 1)	//k counter for the rows in newwave_s
			val_s = newwave_s[k]
			val_f = newwave_f[k]
		
			if ( (val_s < min_s) || (val_s > max_s) ) // is this an outlier?
				numOutliers += 1
			else // if not an outlier
				newwave_s[k-numOutliers] = val_s  // copy to input wav		
				newwave_f[k-numOutliers] = val_f  // copy to input wav	
			endif
	
		endfor

	
		// Truncate the wave
		DeletePoints numPoints-numOutliers, numOutliers, newwave_s
		DeletePoints numPoints-numOutliers, numOutliers, newwave_f
				
		//merge to newwave2	
		make/O/D/N=(dimsize(newwave_s, 0)) newwave2 //final wave newave2 contains data without outliers
		insertPoints /M=1 1, 1, newwave2	//adds new column to newwave2
		newwave2[][0]=newwave_f[p]  //force
		newwave2[][1]=newwave_s[p] //sep
			
			
		//change wavename
		Duplicate/O/D newwave2, $wave_name
						
		i += 1 
	
		killwaves newwave_f, newwave_s, new, newwave2  
	
	while(1)
	
	cd path
		
		
End