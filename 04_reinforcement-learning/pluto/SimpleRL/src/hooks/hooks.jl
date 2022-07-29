"""
# 強化学習のソルバーに対するフック

## Hook interfaces

### solve! 関数で使われるイベント

"環境初期化の直後に実行されるフック"
on_init!(hook::AbstractHook, env::AbstractEnv, policy::AbstractPolicy) -> ::Nothing

"
行動実行前に実行されるフック
- false を返した場合、そこでソルバーの実行を終了する
- true を返した場合、ソルバーの実行を継続する
"
before_action!(hook::AbstractHook, env::AbstractEnv, policy::AbstractPolicy, current_state, next_action) -> ::Bool

"
行動実行後に実行されるフック
- false を返した場合、そこでソルバーの実行を終了する
- true を返した場合、ソルバーの実行を継続する
"
after_action!(hook::AbstractHook, env::AbstractEnv, policy::AbstractPolicy) -> ::Bool

"ソルバーの最後に実行されるフック"
on_end!(hook::AbstractHook, env::AbstractEnv, policy::AbstractPolicy) -> ::Nothing


### train! 関数で使われるイベント

"トレーナー初期化の直後に実行されるフック"
on_train_begin!(hook::AbstractHook, env::AbstractEnv, trainer::AbstractTrainer) -> ::Nothing

"
ソルバー実行前に実行されるフック
- false を返した場合、そこで強化学習の実行を終了する
- true を返した場合、強化学習の実行を継続する
"
before_action!(hook::AbstractHook, env::AbstractEnv, trainer::AbstractTrainer, count::Int) -> ::Bool

"
ソルバー実行後に実行されるフック
- false を返した場合、そこで強化学習の実行を終了する
- true を返した場合、強化学習の実行を継続する
"
after_action!(hook::AbstractHook, env::AbstractEnv, trainer::AbstractTrainer, count::Int, diff, records::Vector{<:NamedTuple}) -> ::Bool

"強化学習終了時に実行されるフック"
on_train_end!(hook::AbstractHook, env::AbstractEnv, trainer::AbstractTrainer) -> ::Nothing
"""

export on_init!, before_action!, after_action!, on_end!, on_train_begin!, before_solve!, after_solve!, on_train_end!

include("./ComposeHook.jl")
include("./TrajectoryHook.jl")
include("./MaxStepHook.jl")
