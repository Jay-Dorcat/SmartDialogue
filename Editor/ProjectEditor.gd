extends Control

const PROJECTS_DIR : String = "res://Projects/"

var CurrentProject : ProjectData

func _ready():
	GetProjects()

func GetProjects():
	var Empty : bool = true
	%LoadOptions.clear()
	for i in DirAccess.get_files_at(PROJECTS_DIR):
		print(i)
		Empty = false
		%LoadOptions.add_item(i)
	%LoadVBox.visible = !Empty

func OpenProject(Project : ProjectData):
	var ProjectMaps : PackedStringArray = Project.GetFlowMapPaths()
	
	for i in len(ProjectMaps):
		var Map = ProjectMaps[i]
		if Map in Project.OpenedMaps:
			CreateMapTab(ResourceLoader.load(Map))
			if Map == Project.LastMap:
				$Tabs.current_tab = i

func NewProject():
	var NewProj = ProjectData.new()
	NewProj.Root = %ProjectRoot.text
	NewProj.Save()
	OpenProject(NewProj)

func LoadProjectIndex(Index : int):
	var ProjFile = DirAccess.get_files_at(PROJECTS_DIR)[Index]
	var Proj = ResourceLoader.load(ProjFile)

func CreateMapTab(Map : FlowMapResource):
	pass
