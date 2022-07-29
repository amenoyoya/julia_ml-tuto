"""
# 強化学習環境モデル

## Env Interfaces

"初期化"
init!(env::AbstractEnv)

"終了判定"
is_terminated(env::AbstractEnv) -> ::Bool

"行動空間取得: 環境でとれるすべての行動"
action_space(env::AbstractEnv) -> actions

"状態空間取得: 環境内のすべての状態"
state_space(env::AbstractEnv) -> states

"現在の状態取得"
current_state(env::AbstractEnv) -> state

"行動をとって次の状態に遷移"
act!(env::AbstractEnv, action)
"""

export init!, is_terminated, action_space, state_space, current_state, act!

include("./MazeEnv.jl")
