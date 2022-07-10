mutable struct キャラクター{T}
    名前::String
    HP::Int
    攻撃力::Int
    防御力::Int
end

include("./traits/Player.jl")
include("./traits/Monster.jl")

"キャラクター => プレイヤー or モンスター 型変換関数"
toプレイヤーorモンスター(::キャラクター{T}) where T <: Union{プレイヤー, モンスター} = T()

行動メッセージ処理(名前::String, 行動名::String) = begin
    println("----------")
    println("$(名前)の$(行動名)！")
end

ダメージメッセージ処理(防御者::キャラクター{T}, ダメージ量::Int) where T = begin
    if ダメージ量 === 0
        println("ミス！$(防御者.名前)はダメージを受けなかった")
    else
        println("$(防御者.名前)は $(ダメージ量) のダメージを受けた！")
    end
    println("$(防御者.名前)のHP: $(防御者.HP)")
end

攻撃ダメージ計算処理(攻撃力::Int, 防御力::Int) = begin
    if 攻撃力 < 0 || 防御力 < 0
        throw(DomainError((攻撃力, 防御力), "攻撃力, 防御力は正の値である必要があります")) 
    end
    if 防御力 === 0
        throw(DomainError(防御力, "防御力は0より大きい値である必要があります")) 
    end
    round(Int, 10 * 攻撃力 / 防御力)
end

ダメージ処理!(防御者::キャラクター{T}, ダメージ量::Int) where T = begin
    if ダメージ量 < 0
        throw(DomainError(ダメージ量, "ダメージ量は 0 以上である必要があります"))
    end

    防御者.HP -= ダメージ量

    if 防御者.HP < 0
        防御者.HP = 0
    end
end

大振り攻撃処理!(攻撃者::キャラクター{T}, 防御者::キャラクター{N}) where T where N = begin
    行動メッセージ処理(攻撃者.名前, "大振り攻撃")
    ダメージ量 = 攻撃ダメージ計算処理(
        # 60% の確率で攻撃力2倍, 40% の確率で攻撃を外す（＝攻撃力0）
        rand() < 0.6 ? 攻撃者.攻撃力 * 2 : 0,
        防御者.防御力
    )
    ダメージ処理!(防御者, ダメージ量)
    ダメージメッセージ処理(防御者, ダメージ量)
end
