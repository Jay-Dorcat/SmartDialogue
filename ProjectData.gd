extends Resource
class_name ProjectData

const SAVE_DIR : String = "res://Projects/%s.tres"

@export var EditorFolder : String

@export var Root : String
@export var LastMap : String
@export var OpenedMaps : PackedStringArray

@export var Global : Dictionary
@export var Groups : Dictionary

func GetCustomGroups():
	return Groups.keys()

func GetFlowMapPaths(ScanDir : String = "", MaxDepth : int = 5):
	if ScanDir == "":
		ScanDir = Root
	if !ScanDir.ends_with("/"):
		ScanDir += "/"
	var Dir := DirAccess.open(ScanDir)
	if !Dir:
		var Err : String = error_string(DirAccess.get_open_error())
		push_warning("Scan Directory Error (%s) (%s)" % [ScanDir,Err])
		return []
	Dir.list_dir_begin()
	var File : String = Dir.get_next()
	var Files : PackedStringArray = []
	while File != "":
		if Dir.current_is_dir():
			Files.append_array(GetFlowMapPaths(ScanDir + File + "/", MaxDepth - 1))
		else:
			if File.ends_with(".dg.tres"):
				Files.append(ScanDir + File)
		File = Dir.get_next()
	Dir = null
	return Files

func Save():
	var RootName : String = Root.split("/")[-1]
	ResourceSaver.save(self,SAVE_DIR % RootName)

func LocalPath(GlobalPath : String) -> String:
	return GlobalPath.trim_prefix(Root)
