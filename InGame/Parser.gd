extends Resource
class_name DialogueParser

@export_file("*.txt") var DialogueFile : String
@export var BeginName : String = "Begin"

signal TextChanged(NewText)
signal SelectionsChanged()
signal Trigger(TriggerIdentity)
signal DialogueEnded()

var Commands : PackedStringArray
var CurrentSector : String = "Begin"
var Sectors : Dictionary

var MainPointer : Pointer

var Selections : Array[Dictionary]

var LocalVariables : Dictionary

var Ended : bool = false
var MustSelect : bool = false

class Pointer:
	var Index : int = 0
	var Indent : int = 0
	var SubPointer : Pointer
	func _init(NewIndex : int, NewIndent : int):
		Index = NewIndex
		Indent = NewIndent
	func Next():
		if SubPointer != null:
			SubPointer.Next()
		else:
			Index += 1
	func GetIndex() -> int:
		if SubPointer != null:
			return SubPointer.GetIndex()
		return Index
	func GetIndent() -> int:
		if SubPointer != null:
			return SubPointer.GetIndent()
		return Indent
	func NewPointer(NewIndex : int, NewIndent : int = -1):
		if SubPointer != null:
			SubPointer.NewPointer(NewIndex, NewIndent)
		else:
			if NewIndent == -1:
				NewIndent = GetIndent() + 1
			SubPointer = Pointer.new(NewIndex, NewIndent)
	func RemovePointer():
		if SubPointer != null:
			if !SubPointer.RemovePointer():
				SubPointer = null
			return true
		else:
			return false
	func GetPointerDepth(Depth : int = 0):
		if SubPointer != null:
			return SubPointer.GetPointerDepth(Depth + 1)
		else:
			return Depth + 1

func Reset():
	MainPointer = null
	LocalVariables.clear()
	Selections.clear()
	Sectors.clear()
	Commands.clear()
	CurrentSector = BeginName

func Parse():
	Reset()
	var Txt := FileAccess.open(DialogueFile,FileAccess.READ)
	if Txt == null:
		push_error("File '%s' failed to open" % DialogueFile)
		return
	var Line : String = Txt.get_line()
	var Index : int = -1
	while Txt.get_position() < Txt.get_length():
		if Line.length() == 0:
			Line = Txt.get_line()
			continue
		if Line.begins_with("#"):
			CreateSector(Line.replace("# ",""), Index + 1)
			Line = Txt.get_line()
			continue
		if Line.begins_with("!"):
			Commands.append(Line)
			Index += 1
			Line = Txt.get_line()
			continue
		if Line.begins_with(">"):
			var Split := Line.trim_prefix("> ").split(" = ")
			var Value = Split[1]
			if Value.is_valid_int():
				Value = Value.to_int()
			elif Value.is_valid_float():
				Value = Value.to_float()
			elif Value == "true":
				Value = true
			elif Value == "false":
				Value = false
			LocalVariables[Split[0]] = Value
		
		var Indent : int = GetIndent(Line)
		if Indent > 0:
			var First : bool = true
			for i in Line.split(";> "):
				if First:
					First = false
					Commands.append(i)
				else:
					Commands.append("	".repeat(Indent + 1) + WithoutIndent(i))
				Index += 1
		
		Line = Txt.get_line()
	if false:
		print("## Local Variables ##")
		for i in LocalVariables:
			print(i, " = ", LocalVariables[i])
		print("## Sectors ##")
		for i in Sectors:
			print(i, " - ", Sectors[i])
		print("## Command List ##")
		for i in Commands:
			print(i)
	if Sectors.find_key(BeginName) != -1:
		GotoSector(BeginName)
	else:
		push_warning("Cannot find Begin Sector, going to first scanned.")
		GotoSector(Sectors.keys()[0])

func GetIndent(Str : String):
	var Indent : int = 0
	while Str[Indent] == "	":
		Indent += 1
	return Indent

func WithoutIndent(Str : String):
	return Str.trim_prefix("	".repeat(GetIndent(Str)))

func CreateSector(Name : String, StartIndex : int):
	Sectors[Name] = StartIndex

func GotoSector(Name : String, Offset : int = 0):
	CurrentSector = Name
	if MainPointer == null:
		MainPointer = Pointer.new(Sectors[Name] + Offset, 1)
	else:
		MainPointer.NewPointer(Sectors[Name] + Offset, 1)

func Next():
	if MustSelect:
		return
	var CurrentIndex : int = MainPointer.GetIndex()
	var CurrentIndent : int = MainPointer.GetIndent()
	var Command : String = Commands[CurrentIndex]
	var CommandIndent : int = GetIndent(Command)
	
	MainPointer.Next()
	
	if CommandIndent > CurrentIndent:
		Next()
		return
	elif CommandIndent < CurrentIndent:
		Return()
		return
	
	ParseCommand(Command, CurrentIndex)

func End():
	DialogueEnded.emit()
	MainPointer = null
	GotoSector(BeginName)

func ParseCommand(Command : String, Index : int):
	print(MainPointer.GetPointerDepth(),":",Command)
	Command = WithoutIndent(Command)
	if Command.begins_with("Text"):
		SetText(Command.split(" : ")[1].replace(" (\\n) ", "\n"))
	elif Command.begins_with("Goto"):
		var Split := Command.split(" ")
		GotoSector(Split[1], Split[2].to_int())
		Next()
	elif Command.begins_with("Selection"):
		var Split := Command.split(" : ")
		AddSelection(Split[1], Index + 1)
		Next()
	elif Command.begins_with("If"):
		var Query : String = Command.trim_prefix("If ").replace("=","==")
		if Evaluate(Query):
			MainPointer.Next()
			MainPointer.NewPointer(Index + 1)
		Next()
	elif Command.begins_with("Var"):
		var Split := Command.trim_prefix("Var ").split(" = ")
		SetVariable(Split[0], Evaluate(Split[1]))
		Next()
	elif Command.begins_with("Wait"):
		return
	elif Command.begins_with("Select"):
		MustSelect = true
		return
	elif Command.begins_with("End"):
		End()

func Return():
	if !MainPointer.RemovePointer():
		End()
	else:
		Next()

func SetVariable(VarIdentifier : String, Value):
	if VarIdentifier.contains(":"):
		pass # Get Global Vars and Groups here
	else:
		LocalVariables[VarIdentifier] = Value

func Evaluate(Query : String):
	var Exp := Expression.new()
	Exp.parse(Query, GetAllVariableNames())
	var Value = Exp.execute(GetAllVariableValues())
	return Value

func GetAllVariableNames():
	return LocalVariables.keys()

func GetAllVariableValues():
	return LocalVariables.values()

func SetText(Text : String):
	TextChanged.emit(Text)

func AddSelection(Prompt : String, Index : int = -1):
	var NewIndex = len(Selections)
	Selections.append({
		"Prompt":Prompt,
		"GotoIndex":Index,
		"ArrIndex":NewIndex
	})
	SelectionsChanged.emit(Selections)

func Select(Index : int):
	MustSelect = false
	MainPointer.NewPointer(Selections[Index].GotoIndex)
	Selections.clear()
	SelectionsChanged.emit(Selections)
	Next()
