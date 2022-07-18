module SimpleRL

export Policy, Trajectory, Env, next_action, execute!

"""
方策
- Interface:
    - 行動決定: (行動空間, 状態) -> (次の行動)
"""
abstract type Policy end

(::Policy)(action_space, state) = error("(::Policy)(action_space, state) -> (next_action): Determine next action from the current state.")

"""
軌道
- Interface:
    - 記録取得: () -> (記録データ)
    - 記録実行: (現在の状態, 次の行動)!
"""
abstract type Trajectory end

(::Trajectory)() = "(::Trajectory)() -> (records::Vector): Get the records."
(::Trajectory)(state, next_action) = error("(::Trajectory)(state, next_action): Record the current state and next action.")

"""
強化学習環境
- Wrapper:
    - 方策: () -> (方策)
    - 軌道: () -> (軌道)
- Interface:
    - 行動空間取得: () -> (行動空間)
    - 状態空間取得: () -> (状態空間)
    - 報酬取得: () -> (報酬)
    - 終了判定: () -> (終了フラグ::Bool)
    - 初期化: ()!
    - 現在の状態取得: () -> (現在の状態)
    - 状態遷移: (行動)!
- Function:
    - 行動決定: () -> (次の行動)
    - 記録実行: ()!
    - シナリオ実行: ()!
"""
abstract type Env end

action_space(::Env) = error("action_space(::Env) -> (actions::Union{<:Vector, <:Tuple}): Get actions of the environment.")
state_space(::Env) = error("state_space(::Env) -> (states::Union{<:Vector, <:Tuple}): Get states of the environment.")
reward(::Env) = error("reward(::Env) -> (reward): Get reward of the environment.")
is_terminated(::Env) = error("is_terminated(::Env) -> (is_terminated::Bool): Determine if the environment is terminated.")
init!(::Env) = error("init!(::Env): Initialize the environment.")
current_state(::Env) = error("current_state(::Env) -> (state): Get the current state of the environment.")
(::Env)(action) = error("(::Env)(action): Execute the action to transition to the next state.")

"""
    next_action(env::Env, state = nothing) = (action)

方策に従って次の行動を決定

- `state`: 現在の状態
    - nothing の場合: `current_state(env)` が設定される
    - nothing 以外の場合: 指定された値が設定される
"""
next_action(env::Env; state = nothing) = policy(env)(
    action_space(env),
    isnothing(state) ? current_state(env) : state
)

"""
    record!(env::Env, state = nothing, action = nothing)

現在の状態と次の行動を記録

- `state`: 現在の状態
    - nothing の場合: `current_state(env)` が設定される
    - nothing 以外の場合: 指定された値が設定される
- `action`: 次の行動
    - nothing の場合: `next_action(env)` が設定される
    - nothing 以外の場合: 指定された値が設定される
"""
record!(env::Env; state = nothing, action = nothing) = begin
    state = isnothing(state) ? current_state(env) : state
    action = isnothing(action) ? next_action(env) : action
    trajectory(env)(state, action)
end

"""
    execute!(env::Env; max_step::Int = 0) = (n_steps::Int)

環境終了までエージェントを行動させ、実行ステップ数を返す

- `max_step::Int`: 最大ステップ数
    - 0 より大きい場合: 環境の終了条件を満たすか指定したステップ数に達した時点で終了する
    - 0 以下の場合: 環境の終了条件を満たすまで無限ループする
"""
execute!(env::Env; max_step::Int = 0) = begin
    n_steps = 0
    init!(env)
    while !is_terminated(env)
        state = current_state(env)
        action = next_action(env; state = state)
        record!(env; state = state, action = action) # Record the history.
        env(action) # Transition to the next state.

        n_steps += 1
        if max_step > 0 && max_step <= n_steps
            break
        end
    end
    # Record the final state.
    record!(env; action = NaN)

    n_steps
end

#=
実装
- 方策
    - TablerPolicy
- 軌道
    - ArrayTrajectory
- 環境
    - MazeEnv
=#
include("./policy/TablerPolicy.jl")
include("./trajectory/ArrayTrajectory.jl")
include("./env/Maze/Maze.jl")

end # module
