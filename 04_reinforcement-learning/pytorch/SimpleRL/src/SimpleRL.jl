module SimpleRL

export next_action, execute!

"""
方策
- Interface:
    - 行動決定: (行動空間, 状態) -> (次の行動)
"""
abstract type RLPolicy end

(::RLPolicy)(action_space, state) = "(::RLPolicy)(action_space, state) -> (next_action): Determine next action from the current state."

"""
記録者
- Interface:
    - 記録取得: () -> (記録データ)
    - 記録実行: (現在の状態, 次の行動)!
"""
abstract type RLRecorder end

records(::RLRecorder) = "records(::RLRecorder) -> (records::Vector): Get the records."
(::RLRecorder)(state, next_action) = "(::RLRecorder)(state, next_action): Record the current state and next action."

"""
強化学習環境
- Interface:
    - 行動空間取得: () -> (行動空間)
    - 状態空間取得: () -> (状態空間)
    - 報酬取得: () -> (報酬)
    - 終了判定: () -> (終了フラグ::Bool)
    - 初期化: ()!
    - 現在の状態取得: () -> (現在の状態)
    - 状態遷移: (行動)!
- Function:
    - 行動決定: (方策) -> (次の行動)
    - シナリオ実行: (方策, 記録)!
"""
abstract type RLEnv end

action_space(::RLEnv) = "action_space(::RLEnv) -> (actions::Union{Vector, Tuple}): Get actions of the environment."
state_space(::RLEnv) = "state_space(::RLEnv) -> (states::Union{Vector, Tuple}): Get states of the environment."
reward(::RLEnv) = "reward(::RLEnv) -> (reward): Get reward of the environment."
is_terminated(::RLEnv) = "is_terminated(::RLEnv) -> (is_terminated::Bool): Determine if the environment is terminated."
init!(::RLEnv) = "init!(::RLEnv): Initialize the environment."
state(::RLEnv) = "state(::RLEnv) -> (state): Get the current state of the environment."
(::RLEnv)(action) = "(::RLEnv)(action): Execute the action to transition to the next state."

next_action(env::RLEnv, policy::RLPolicy) = policy(action_space(env), state(env))

"""
    execute!(env::RLEnv, policy::RLPolicy, recorder::RLRecorder; max_step::Int = -1) -> n_steps::Int

シナリオ実行

- `env::RLEnv`: 強化学習環境
- `policy::RLPolicy`: 方策
- `recorder::RLRecorder`: 状態・行動の記録を行うオブジェクト
- `max_step::Int`: 最大ステップ数。マイナス値を指定した場合は終了するまで無限ループ
"""
execute!(env::RLEnv, policy::RLPolicy, recorder::RLRecorder; max_step::Int = -1) = begin
    n_steps = 0
    init!(env)
    while !is_terminated(env)
        action = next_action(env, policy)
        recorder(state(env), action) # Record the history.
        env(action) # Transition to the next state.

        n_steps += 1
        if max_step > 0 && max_step <= n_steps
            break
        end
    end
    # Record the final state.
    recorder(state(env), NaN)

    n_steps
end

#=
実装
- 方策
    - TablerPolicy
- 記録
    - ArrayRecorder
- 環境
    - MazeEnv
=#
include("./policy/TablerPolicy.jl")
include("./recorder/ArrayRecorder.jl")
include("./env/Maze/Maze.jl")

end # module
