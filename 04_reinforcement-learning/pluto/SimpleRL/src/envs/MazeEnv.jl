export MazeAction, UP, RIGHT, DOWN, LEFT
export MazeState, S0, S1, S2, S3, S4, S5, S6, S7, S8
export MazeInitialTheta, MazeEnv, plot, plot!, save_anim

"""
- 迷路問題:
    - S0 からスタート
    - S8 がゴール
    - エージェントはスタートからゴールを目指す
        - 壁を通り抜けることは出来ない

```
+--------------+
| S0   S1   S2 |
|     ----+    |
| S3   S4 | S5 |
|         +----+
| S6 | S7   S8 |
+----+---------+
```
"""

"迷路問題の行動空間: ↑, →, ↓, ←"
@enum MazeAction UP=1 RIGHT DOWN LEFT

"迷路問題の状態空間: S0(START), S1, ..., S7, S8(GOAL)"
@enum MazeState S0=1 S1 S2 S3 S4 S5 S6 S7 S8

"""
    MazeInitialTheta::Matrix{<:Number}

迷路問題初期方策パラメータ（行動の重み）

- 行: 状態 S0 ~ S7 (S8 はゴールのため方策なし)
- 列: 移動方向 ↑, →, ↓, ←
"""
const MazeInitialTheta = [
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
    mutable struct MazeEnv

迷路問題

- `actions::Tuple{Int}`: 選択可能な行動（行動空間）
- `states::Tuple{Int}`: エージェントの全状態（状態空間）
- `state::Int`: 現在の状態 = エージェントのいる位置
- `state_transitions::Tuple{Int}`: 状態遷移マッピング
    - ↑: 状態 - 3
    - →: 状態 + 1
    - ↓: 状態 + 3
    - ←: 状態 - 1
"""
Base.@kwdef mutable struct MazeEnv
    actions = Int.(instances(MazeAction))
    states = Int.(instances(MazeState))
    state = Int(S0)
    state_transitions = (-3, +1, +3, -1)
end

init!(env::MazeEnv) = env.state = Int(S0)

is_terminated(env::MazeEnv) = env.state === Int(S8)

action_space(env::MazeEnv) = env.actions

state_space(env::MazeEnv) = env.states

current_state(env::MazeEnv) = env.state

act!(env::MazeEnv, action) = env.state += env.state_transitions[action]

"""
    plot(::MazeEnv) ->  fig::Figure,
                        plt::GridPosition,
                        ax::Axis,
                        state_positions::Vector{<:Position}

3x3 の迷路をプロット
"""
plot(::MazeEnv) = begin
	# 状態 => プロット位置マッピング
    state_positions = [
        Point2f(0.5, 2.5), # S0
        Point2f(1.5, 2.5), # S1
        Point2f(2.5, 2.5), # S2
        Point2f(0.5, 1.5), # S3
        Point2f(1.5, 1.5), # S4
        Point2f(2.5, 1.5), # S5
        Point2f(0.5, 0.5), # S6
        Point2f(1.5, 0.5), # S7
        Point2f(2.5, 0.5), # S8
    ]

    # 500x500 の Figure 作成
    fig = Figure(resolution = (500, 500))

    # Figure grid layout (1, 1) を描画対象にする
    plt = fig[1, 1]
    ax = Axis(plt) # 軸は必ず作成する必要がある (少し時間がかかる)

    # 描画範囲の設定
    MakieLayout.xlims!(ax, 0, 3)
    MakieLayout.ylims!(ax, 0, 3)

    # 軸の目盛りを非表示化
    ## グリッド線は表示する (grid = false)
    hidedecorations!(ax, grid = false)

    # 赤い壁を描画
    lines!(plt, [1, 1], [0, 1], color = :red, linewidth = 2)
    lines!(plt, [1, 2], [2, 2], color = :red, linewidth = 2)
    lines!(plt, [2, 2], [2, 1], color = :red, linewidth = 2)
    lines!(plt, [2, 3], [1, 1], color = :red, linewidth = 2)

    # 状態を示す文字 S0 ~ S8 を描画
    for i = 0:8
        text!(plt, "S$i", position = state_positions[i + 1], size = 14, align = (:center, :center))
    end
    text!(plt, "START", position = (0.5, 2.3), size = 14, align = (:center, :center))
    text!(plt, "GOAL", position = (2.5, 0.3), size = 14, align = (:center, :center))

    fig, plt, ax, state_positions
end

"""
    plot!(::MazeEnv, plt::GridPosition, init_pos::Point) -> agent_pos::Observable{<:Point}

エージェントをプロットに追加
"""
plot!(::MazeEnv, plt::GridPosition, init_pos::Point) = begin
    agent_pos = Observable(init_pos)
    scatter!(plt, agent_pos, color = (:red, 0.5), markersize = 50)

    agent_pos
end

"""
    save_anim(env::MazeEnv, records::Vector{<:NamedTuple}, save_filename::String)

迷路内をエージェントがゴールするまで移動させた記録を動画ファイルに保存
"""
save_anim(env::MazeEnv, records::Vector{<:NamedTuple}, save_filename::String) = begin
    # 初期プロット描画
    fig, plt, ax, state_positions = plot(env)
    agent_pos = plot!(env, plt, state_positions[1])

    # 動画作成
    n_records = length(records)
    record(fig, save_filename, 1:n_records;
        # records を10秒でアニメーションさせるように framerate 設定
        framerate = ceil(Int, n_records / 10)
    ) do frame
        # エージェント位置更新
        agent_pos[] = state_positions[records[frame].state]

        # プロットタイトル更新
        ax.title = "Step: $frame"
    end
end
