extends Node

# シナリオ管理システム（拡張版）
class_name ScenarioManagerExtended

# シナリオデータ
var scenario_data: Dictionary = {}
var current_scenario: Array = []
var current_index: int = 0

# 第一章のシナリオ
var chapter_01_scenario: Array = [
	{
		"type": "narration",
		"text": "一条瑠璃からの依頼を受けた翌朝。みずきと沙織は、銀の黄昏会について調査を開始した。"
	},
	{
		"type": "show_character",
		"character": "mizuki",
		"position": "center",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "沙織、昨夜調べた『銀の黄昏会』の情報をまとめてくれる？"
	},
	{
		"type": "show_character",
		"character": "saori",
		"position": "right",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "はい。この団体は約10年前に設立され、表向きは古代文明の研究を目的とした学術団体です。"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "しかし、実態は不明な点が多く、一部では新興宗教団体とも噂されています。"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "10年前...それほど歴史のある団体なのね。一条氏が関わるようになったのは最近だというのに。"
	},
	{
		"type": "change_background",
		"background": "living_room_crime_scene"
	},
	{
		"type": "narration",
		"text": "みずきと沙織は、一条氏が最後に目撃された場所へと向かった。そこは、奇妙な痕跡が残された現場だった。"
	},
	{
		"type": "hide_character",
		"character": "saori"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "ここが一条氏が最後に目撃された場所...確かに何かあったようね。"
	},
	{
		"type": "show_character",
		"character": "saori",
		"position": "right",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "みずきさん、こちらをご覧ください。床に奇妙な文様が描かれています。"
	},
	{
		"type": "change_background",
		"background": "late_night_diner"
	},
	{
		"type": "narration",
		"text": "夜。みずきと沙織は、瑠璃から新たな情報を得るため、深夜のダイナーで待ち合わせをした。"
	},
	{
		"type": "hide_character",
		"character": "saori"
	},
	{
		"type": "show_character",
		"character": "ruri",
		"position": "center",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "お二人とも...調査の進展はありましたか？"
	},
	{
		"type": "show_character",
		"character": "mizuki",
		"position": "left",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "ええ。あなたのお父様が最後に目撃された現場を調べました。そこには儀式の痕跡がありました。"
	},
	{
		"type": "narration",
		"text": "こうして、みずきと沙織は銀の黄昏会の本拠地とされる廃教会へと向かう決意を固めた。"
	},
	{
		"type": "hide_all_characters"
	},
	{
		"type": "narration",
		"text": "第一章 完"
	}
]

# 第二章のシナリオ
var chapter_02_scenario: Array = [
	{
		"type": "change_background",
		"background": "mysterious_assembly_hall"
	},
	{
		"type": "narration",
		"text": "深夜。みずきと沙織は、旧市街の廃教会へと潜入した。建物の内部は薄暗く、不気味な雰囲気に包まれていた。"
	},
	{
		"type": "show_character",
		"character": "mizuki",
		"position": "left",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "静かに...誰かいるかもしれない。"
	},
	{
		"type": "show_character",
		"character": "saori",
		"position": "right",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "みずきさん、あちらを...ろうそくの灯りが見えます。"
	},
	{
		"type": "narration",
		"text": "二人は慎重に奥へと進む。そこには、奇妙な祭壇と、壁一面に描かれた古代文字が広がっていた。"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "これは...まるで儀式の場所ね。ここで一体何が行われていたの？"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "この文字...古代シュメール語のようです。『アザゼルの鍵を用いて、禁断の扉を開く』と書かれています。"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "やはり、この団体は本気でその鍵を探しているのね。そして一条氏も、その儀式に巻き込まれた可能性が高い。"
	},
	{
		"type": "narration",
		"text": "その時、背後から足音が聞こえた。二人は振り返ると、そこには黒いローブを纏った男が立っていた。"
	},
	{
		"type": "hide_character",
		"character": "saori"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "誰！？"
	},
	{
		"type": "narration",
		"text": "二人は日記を手に、さらなる手がかりを求めて調査を続けることにした。しかし、銀の黄昏会の真の目的とは何なのか。そして、一条氏は本当に無事なのか。謎は深まるばかりだった..."
	},
	{
		"type": "hide_all_characters"
	},
	{
		"type": "narration",
		"text": "第二章 完"
	}
]

signal scenario_command_executed(command: Dictionary)

func _ready():
	load_scenario_data()

# シナリオデータの読み込み
func load_scenario_data():
	scenario_data["chapter_01"] = chapter_01_scenario
	scenario_data["chapter_02"] = chapter_02_scenario

# シナリオを開始
func start_scenario(scenario_name: String):
	if scenario_name in scenario_data:
		current_scenario = scenario_data[scenario_name]
		current_index = 0
		execute_next_command()
	else:
		print("Scenario not found: ", scenario_name)

# 次のコマンドを実行
func execute_next_command():
	if current_index >= current_scenario.size():
		print("Scenario finished")
		return
	
	var command = current_scenario[current_index]
	current_index += 1
	
	scenario_command_executed.emit(command)

# シナリオを進める
func advance_scenario():
	execute_next_command()

# 次のコマンドがあるか確認
func has_next_command() -> bool:
	return current_index < current_scenario.size()
