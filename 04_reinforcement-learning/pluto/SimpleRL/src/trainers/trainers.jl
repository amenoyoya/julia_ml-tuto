"""
# 強化学習トレーナー

## Trainer interfaces

"初期化"
init!(trainer::AbstractTrainer, env::AbstractEnv)

"パラメータ更新 -> 更新したパラメータの変化量を返す"
update!(trainer::AbstractTrainer, env::AbstractEnv, records::Vector{<:NamedTuple}) -> param_diff

"内部方策取得"
policy(trainer::AbstractTrainer) -> inner_policy::AbstractPolicy
"""

export init!, update!, policy

include("./TablerPolicyGradientTrainer.jl")
