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
		"text": "今日も一日、何も事件らしい事件はなかった...。平和なのは良いことだけど、少し退屈ね。"
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
		"text": "みずきさん、お疲れ様でした。お茶をお入れしますね。少し甘めの紅茶はいかがですか？"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "あら、気が利くわね、沙織。ありがとう。君がいてくれて本当に助かるよ。"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "そんな...私こそ、みずきさんに探偵のいろはを教えていただいて。毎日が刺激的です。"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "ふふ、そう言ってもらえると嬉しいわ。でも、たまにはゆっくりしたい日もあるでしょう？"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "smile"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "ええ、そうですね。でも、みずきさんと一緒なら、どんな日でも楽しいです。"
	},
	{
		"type": "narration",
		"text": "穏やかな時間が流れる探偵事務所。しかし、その平和は突然の来訪者によって破られる。"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "あら、こんな時間に？どうぞ、開いています。"
	},
	{
		"type": "hide_character",
		"character": "saori"
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
		"text": "一条...まさか、あの財閥の一条家のご令嬢が、こんなところに？"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "はい...お恥ずかしながら。お二人に、どうしてもお願いがあって参りました。"
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
		"text": "どのようなご依頼でしょうか？わたくしどもでお力になれることがあれば。"
	},
	{
		"type": "change_expression",
		"character": "ruri",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "私の父が...一週間前から行方不明になってしまったのです。"
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
		"text": "それが...父は最近、『銀の黄昏会』という怪しげな宗教団体に関わっていたようで..."
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "警察に相談しても、まともに取り合ってもらえません。財閥の体面を気にして、事を荒立てたくないという思惑もあるようです。"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "宗教団体...しかも財閥が絡むとなると、確かに複雑な問題ですね。"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "詳しくお聞かせください。いつ頃から、お父様の様子がおかしくなったのですか？そして、その『銀の黄昏会』とは？"
	},
	{
		"type": "change_expression",
		"character": "ruri",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "三ヶ月ほど前からです。最初は古美術品の収集が趣味だった父が、ある日を境に『アザゼルの鍵』という古い遺物を探し始めたのです。"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "surprised"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "アザゼルの鍵...？それはまた、物騒な響きですね。"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "その鍵を探すうちに、父は『銀の黄昏会』という団体と接触を持つようになり、急速に傾倒していきました。"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "最後に父を見たのは一週間前です。『真実を知った』と言って、夜の闇に消えていきました。"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "それは...さぞご心配でしょう。お一人で抱え込まず、わたくしどもにお任せください。"
	},
	{
		"type": "change_expression",
		"character": "ruri",
		"expression": "sad"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "はい...どうか、父を見つけてください。お礼はいくらでも...。このままでは、父が危険な目に遭うかもしれません。"
	},
	{
		"type": "change_expression",
		"character": "mizuki",
		"expression": "normal"
	},
	{
		"type": "dialog",
		"speaker": "みずき",
		"text": "お礼の心配はいりません。お困りの方を放っておけないのが、探偵の性分ですから。それに...『アザゼルの鍵』と『銀の黄昏会』。興味深い響きだわ。"
	},
	{
		"type": "change_expression",
		"character": "saori",
		"expression": "smile"
	},
	{
		"type": "dialog",
		"speaker": "沙織",
		"text": "みずきさんの言う通りです。私たちにお任せください。必ず、お父様を見つけ出します。"
	},
	{
		"type": "change_expression",
		"character": "ruri",
		"expression": "smile"
	},
	{
		"type": "dialog",
		"speaker": "瑠璃",
		"text": "ありがとうございます...本当に、ありがとうございます。これで、少しだけ希望が持てました。"
	},
	{
		"type": "narration",
		"text": "こうして、私たちの新たな事件が始まった。一条財閥の令嬢からの依頼。それは、銀の黄昏に包まれた都市の裏側で蠢く、恐ろしい真実への第一歩を踏み出した瞬間だった...。"
	},
	{
		"type": "hide_all_characters"
	},
	{
		"type": "narration",
		"text": "To be continued..."
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
		GameManager.instance.change_state(GameManager.GameState.MENU) # シナリオ終了時にメニュー状態に戻す
		return
	
	var command = current_scenario[current_index]
	current_index += 1
	
	push_error("Executing command: " + str(command)) # コマンド実行ログをエラーとして出力
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



# 次のコマンドがあるか確認
func has_next_command() -> bool:
	return current_index < current_scenario.size()

