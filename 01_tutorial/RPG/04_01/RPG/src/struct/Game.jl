Base.@kwdef mutable struct ゲーム
    勇者::キャラクター = キャラクター("勇者", true, 30, 10, 10)
    モンスター::キャラクター = キャラクター("モンスター", false, 30, 10, 10)
end
