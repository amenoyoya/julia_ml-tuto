"プレイヤー Trait"
struct プレイヤー end

prompt(message::String) = Base.prompt(message)

const COMMAND = Dict(
    "1" => :攻撃,
    "2" => :大振り
)

"プレイヤーの行動選択処理"
行動選択処理(::プレイヤー) = begin
    input = prompt("[1]攻撃 [2]大振り")
    COMMAND[input]
end
