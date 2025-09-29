extends Node

# シナリオ管理システム
class_name ScenarioManager

# シナリオデータ
var scenario_data: Dictionary = {}
var current_scenario: Array = []
var current_index: int = 0

# 序章のサンプルシナリオ
var prologue_scenario: Array = [
	{
		"type": "narration",
		"text": "夕暮れ時の探偵事務所。窓から差し込む夕日が、室内を銀色に染めている。"
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
		"text": "今日も一日、何も事件らしい事件はなかった..."
	},
	{
		"type": "show_character",
		"character": "saori",
		"position": "right",
		"expression": "smile"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "みずきさん、お疲れ様でした。お茶をお入れしますね。"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "ありがとう、沙織。君がいてくれて本当に助かるよ。"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "そんな...私こそ、みずきさんに色々教えていただいて。"
	},
	{
		"type": "narration",
		"text": "その時、事務所のドアがノックされた。"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "こんな時間に？どうぞ、開いています。"
	},
	{
		"type": "show_character",
		"character": "ruri",
		"position": "left",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "失礼いたします...一条瑠璃と申します。"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "一条...まさか、あの一条財閥の？"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "はい...お恥ずかしながら。お二人に、どうしてもお願いがあって参りました。"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "どのようなご依頼でしょうか？"
	},
	{
		"type": "change_expression",
		"character": "ruri",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "私の父が...行方不明になってしまったのです。"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "行方不明...警察には届けを？"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "それが...父は最近、変な宗教団体に関わっていたようで..."
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "『銀の黄昏会』という団体です。警察に相談しても、まともに取り合ってもらえません。"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "宗教団体...それは確かに複雑な問題ですね。"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "詳しくお聞かせください。いつ頃から、お父様の様子がおかしくなったのですか？"
	},
	{
		"type": "change_expression",
		"character": "ruri",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "三ヶ月ほど前からです。最初は古美術品の収集が趣味だった父が..."
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "『アザゼルの鍵』という古い遺物を探し始めたのです。"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "アザゼルの鍵...聞いたことがない名前ですね。"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "その鍵を探すうちに、銀の黄昏会という団体と関わるようになって..."
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "最後に父を見たのは一週間前です。『真実を知った』と言って出かけたきり..."
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "それは心配ですね...お一人でさぞ不安でしょう。"
	},
	{
		"type": "change_expression",
		"character": "ruri",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "はい...どうか、父を見つけてください。お礼はいくらでも..."
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "お礼の心配はいりません。お困りの方を放っておけないのが、探偵の性分ですから。"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "smile"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "みずきさんの言う通りです。私たちにお任せください。"
	},
	{
		"type": "change_expression",
		"character": "ruri",
		"expression": "smile"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "ありがとうございます...本当に、ありがとうございます。"
	},
	{
		"type": "narration",
		"text": "こうして、私たちの新たな事件が始まった。まだ知らない、恐ろしい真実への第一歩を踏み出したのだ..."
	},
	{
		"type": "hide_all_characters"
	}
]

signal scenario_command_executed(command: Dictionary)

func _ready():
	load_scenario_data()

# シナリオデータの読み込み
func load_scenario_data():
	scenario_data["prologue"] = prologue_scenario

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

# 現在のシナリオ位置を取得
func get_current_position() -> Dictionary:
	return {
		"scenario": current_scenario,
		"index": current_index
	}

# シナリオ位置を設定
func set_scenario_position(scenario: Array, index: int):
	current_scenario = scenario
	current_index = index
