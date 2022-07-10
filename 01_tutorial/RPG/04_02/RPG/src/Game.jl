Base.@kwdef mutable struct ゲーム
    勇者::キャラクター{プレイヤー} = キャラクター{プレイヤー}("勇者", 30, 10, 10)
    モンスター::キャラクター{モンスター} = キャラクター{モンスター}("モンスター", 30, 10, 10)
end

戦闘開始処理(::ゲーム) = begin
    println("モンスターに遭遇した！")
    println("戦闘開始！")
end

戦闘終了処理(game::ゲーム) = begin
    if game.モンスター.HP === 0
        println("戦闘に勝利した！")
    elseif game.勇者.HP === 0
        println("戦闘に敗北した・・・")
    else
        throw(DomainError(game, "戦闘は終了していません"))
    end
end

先行後攻決定処理(game::ゲーム) = begin
    if rand() < 0.5
        [(game.勇者, game.モンスター), (game.モンスター, game.勇者)]
    else
        [(game.モンスター, game.勇者), (game.勇者, game.モンスター)]
    end
end
