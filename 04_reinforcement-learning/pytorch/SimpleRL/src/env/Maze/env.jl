using NaNStatistics, Distributions

export MazeAction, UP, RIGHT, DOWN, LEFT
export MazeState, S0, S1, S2, S3, S4, S5, S6, S7, S8
export MazeEnv, set_theta!, policy, trajectory, action_space, state_space, reward, is_terminated, init!, current_state

"エージェントの行動: 上、右、下、左移動"
@enum MazeAction UP=1 RIGHT DOWN LEFT

"迷路問題の状態: S0(START), S1, ..., S8(GOAL)"
@enum MazeState S0=1 S1 S2 S3 S4 S5 S6 S7 S8

"迷路問題の初期行動重み"
MazeEnvInitialTheta = [
    NaN  1.0  1.0  NaN  # S0での移動可能方向: →, ↓
    NaN  1.0  NaN  1.0  # S1での移動可能方向: →, ←
    NaN  1.0  1.0  1.0  # S2での移動可能方向: ↓, ←
    1.0  1.0  1.0  NaN  # S3での移動可能方向: ↑, →, ↓
    NaN  NaN  1.0  1.0  # S4での移動可能方向: ↓, ←
    1.0  NaN  NaN  NaN  # S5での移動可能方向: ↑
    1.0  NaN  NaN  NaN  # S6での移動可能方向: ↑
    1.0  1.0  NaN  NaN  # S7での移動可能方向: ↑, →
]

"""
迷路問題環境
- 方策: () -> (方策)
- 軌道: () -> (軌道)
- 行動空間取得: () -> (行動空間)
- 状態空間取得: () -> (状態空間)
- 報酬取得: () -> (報酬)
- 終了判定: () -> (終了フラグ)
- 初期化: ()!
- 現在の状態取得: () -> (現在の状態)
- 状態遷移: (行動)!
"""
Base.@kwdef mutable struct MazeEnv <: Env
    # 方策
    policy::TablerPolicy = TablerPolicy(zeros(8, 4))

    # 軌道
    trajectory::ArrayTrajectory = ArrayTrajectory()

    # 行動空間: ↑, →, ↓, ← 移動
    actions = Int.(instances(MazeState))

    # 状態空間: S0(START), S1, ..., S7, S8(GOAL)
    states = Int.(instances(MazeState))

    # 状態: エージェントのいる位置
    state = Int(S0)

    # 状態遷移
    # - 上: 状態 - 3
    # - 右: 状態 + 1
    # - 下: 状態 + 3
    # - 左: 状態 - 1
    state_transitions = (-3, +1, +3, -1)

    # 行動の重み: 8x4-Matrix
    theta::Matrix{<:Number} = MazeEnvInitialTheta
end

"行動の重みパラメータ設定"
set_theta!(env::MazeEnv, theta::Matrix{<:Number}) = begin
    env.theta = theta

    #=
    迷路問題の表形式方策を作成する
    - 行動の重み θ から、行動の採用確率 π_θ に変換する
    - 例: S0 [NaN 1.0 1.0 NaN] の場合
        - 行動の採用確率は [0.0 0.5 0.5 0.0] となる
    =#
    env.policy.pi =
        # 各値をその行での割合 (値 / その行の合計値) に変換
        ## NaN 値を無視して合計を出すには NaNStatistics.nansum を使うと良い
        env.theta ./ nansum(env.theta, dims = 2) |>
            # NaN 値を 0.0 に変換する
            theta -> map(theta) do t isnan(t) ? 0.0 : t end 
end

policy(env::MazeEnv) = env.policy
trajectory(env::MazeEnv) = env.trajectory

action_space(env::MazeEnv) = env.actions
state_space(env::MazeEnv) = env.states
reward(env::MazeEnv) = is_terminated(env) ? 1.0 : 0.0 # ゴールした時点で初めて報酬発生
is_terminated(env::MazeEnv) = env.state === Int(S8)
init!(env::MazeEnv) = begin
    set_theta!(env, env.theta) # 方策パラメータ => 方策マトリクス 変換
    env.state = Int(S0)
end
current_state(env::MazeEnv) = env.state
(env::MazeEnv)(action::Int) = env.state += env.state_transitions[action]
