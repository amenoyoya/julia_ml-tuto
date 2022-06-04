module Maze

using GLMakie, NaNStatistics, Distributions
using GLMakie: Makie.MakieLayout

export maze_plot, agent_plot!, theta_0, pi_theta, next_state, maze, save_anim

"""
    maze_plot() =   fig::Figure,
                    plt::GridPosition,
                    ax::Axis,
                    state_positions::Vector{<:Position}

迷路を描画する関数 (500x500 の Figure に以下のようにプロット)

```plot
 S0   S1   S2
     ----┐
 S3   S4 | S5
         └---
 S6 | S7   S8
```
"""
maze_plot() = begin
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
    agent_plot!(plt::GridPosition, init_pos::Point) = agent_pos::Observable{<:Point}

エージェント (赤色半透明のドットで表現) をプロットに追加する関数
"""
agent_plot!(plt::GridPosition, init_pos::Point) = begin
    agent_pos = Observable(init_pos)
    scatter!(plt, agent_pos, color = (:red, 0.5), markersize = 50)

    agent_pos
end

"""
    theta_0::Matrix{Number} (8x4)

初期方策を決定するパラメータ theta_0

- 行: 状態 S0 ~ S7 (S8 はゴールのため方策なしで良い)
- 列: 行動 ↑, →, ↓, ← (ただし赤い壁への移動は不可)
- 各値: 行動の重み θ
    - 初期値はすべての行動の重みを 1.0 と設定
    - 移動不可の行動は欠損値 (NaN) を設定
"""
theta_0 = [
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
    pi_theta(theta::Matrix{Number}) = pi::Matrix{Number} (8x4)

方策パラメータ θ を行動方策 π に変換する関数

- 行動の重み θ から、行動の採用確率 π_θ に変換する
- 例: S0 [NaN 1.0 1.0 NaN] の場合
    - 行動の採用確率は [0.0 0.5 0.5 0.0] となる
"""
pi_theta(theta::Matrix) =
    # 各値をその行での割合 (値 / その行の合計値) に変換
    ## NaN 値を無視して合計を出すには NaNStatistics.nansum を使うと良い
    theta ./ nansum(theta, dims = 2) |>
        # NaN 値を 0.0 に変換する
        theta -> map(theta) do t isnan(t) ? 0.0 : t end

"""
    next_state(pi::Matrix{<:Number}, state::Int) = state_next::Int

1step 後の状態 s を求める関数

- `pi::Matrix{Number}`: 方策 π
- `state::Int`: 現在の状態 1..8
    - 1: S0, 2: S1, ... 8: S7
"""
next_state(pi::Matrix{<:Number}, state::Int) = begin
    directions = [:up, :right, :down, :left]

    # 行動を決定
    ## Distributions.wsample(samples::Vector, weights::Vector) = choiced_sample
    ### samples の中から任意の値を1つ選択する。ただしその選択確率は weights で定められた重みによって決められる
    direction_next = wsample(directions, pi[state, :])

    # 状態遷移
    # - 上: 状態 - 3
    # - 右: 状態 + 1
    # - 下: 状態 + 3
    # - 左: 状態 - 1
    state_transitions = Dict(
        :up    => -3,
        :right => +1,
        :down  => +3,
        :left  => -1,
    )
    state_next = state + state_transitions[direction_next]
    state_next
end

"""
    maze(pi::Matrix{<:Number}) = state_history::Vector{Int}

迷路内をエージェントがゴールするまで移動させる関数

ゴールするまでにエージェントが通った状態の軌跡 state_history を返す
"""
maze(pi::Matrix) = begin
    # スタート地点: S0, ゴール地点: S8
    start, goal = 1, 9

    state::Int = start # 状態: 初期値 = S0
    state_history::Vector{Int} = [1] # エージェントの移動記録

    # ゴールするまで step を繰り返す
    while state !== goal
        state = next_state(pi, state)
        push!(state_history, state)
    end

    state_history
end

"""
    save_anim(save_filename::String, state_history::Vector{Int})

迷路内をエージェントがゴールするまで移動させた記録を動画ファイルに保存する関数
"""
save_anim(save_filename::String, state_history::Vector{Int}) = begin
    # 初期プロット描画
    fig, plt, ax, state_positions = maze_plot()
    agent_pos = agent_plot!(plt, state_positions[1])

    # 動画作成
    n_states = length(state_history)
    record(fig, save_filename, 1:n_states;
        # state_history を15秒でアニメーションさせるように framerate 設定
        framerate = ceil(Int, n_states / 15)
    ) do frame
        # エージェント位置更新
        agent_pos[] = state_positions[state_history[frame]]

        # プロットタイトル更新
        ax.title = "Step: $frame"
    end
end

end # module
