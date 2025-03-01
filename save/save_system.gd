extends Node2D

var newProject = preload("res://projects/project.tscn")




func save_data():
	print("Saving game data")
	var file = FileAccess.open("user://gamedata.save", FileAccess.WRITE)
	#first save user data
	file.store_line(JSON.stringify(global.save()))
	print("User data stored successfully")
	
	#then save project data
	for project in global.projects:
		if project != null:
			file.store_line(JSON.stringify(project.save()))
			print("Project: " + project.projectName + " saved successfully")
	
	#now save completed project data
	for project in global.completedProjects:
		if project != null:
			file.store_line(JSON.stringify(project.save()))
			print("Project: " + project.projectName + " saved successfully")
	
	file.store_line(JSON.stringify("END_PROJECTS"))
	
	#then save misc data (gifts, etc)
	
	file.close()
	print("All data saved successfully")


func load_data() -> int:
	print("Loading game data")
	if !FileAccess.file_exists("user://gamedata.save"):
		#-1 means no save to load
		return -1
	
	var file = FileAccess.open("user://gamedata.save", FileAccess.READ)
	
	print("Reading user data")
	
	var json = JSON.new()
	#set global data
	var json_string = file.get_line()
	var parse_result = json.parse(json_string)
	
	if !parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message()," in ", json_string, " at line ", json.get_error_line())
		return 0
		#0 means error in file reading
	
	#set global data
	#get data from JSON object
	var data = json.data
	for i in data.keys():
		#loop through and set data
		global.set(i, data[i])
	
	#output data to check
	print(global.username)
	print("Total focus time: " + type_convert(global.totalFocusTime, TYPE_STRING))
	print("Total current projects: " + type_convert(global.totalCurrentProjects, TYPE_STRING))
	print("Total completed projects: " + type_convert(global.totalCompletedProjects, TYPE_STRING))
	
	print("User data read successfully")
	
	print("Reading project data")
	#read each project data
	var end_of_projects : bool = false
	while file.get_position() < file.get_length() && !end_of_projects:
		json_string = file.get_line()
		parse_result = json.parse(json_string)
		
		if !parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message()," in ", json_string, " at line ", json.get_error_line())
			return 0
			#0 means error in file reading
		
		data = json.data
		print(data)
		
		if typeof(data) == TYPE_STRING:
			end_of_projects = data == "END_PROJECTS"
		
		
		if !end_of_projects:
			#create new project object
			var instance = newProject.instantiate()
			#write data to it
			for i in data.keys():
				#loop through and set data
				instance.set(i, data[i])
			
			print("Data successfully read for project: " + instance.projectName)
			
			instance.setColours()
			
			#check if completed or not
			if !instance.complete:
				#append to global array
				if global.projects[0] == null:
					global.projects[0] = instance
				else:
					global.projects.append(instance)
			else:
				#append to completed projects array
				global.completedProjects.append(instance)
			
			print("Project added to global projects array")
	
	if global.projects[0] != null:
		global.projects.append(null)
	
	#read misc data
	
	file.close()
	print("All data read successfully")
	return 1
