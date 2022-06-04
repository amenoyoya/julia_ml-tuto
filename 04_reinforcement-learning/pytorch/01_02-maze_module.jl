module Maze

using GLMakie, NaNStatistics, Distributions, ProgressMeter
using GLMakie: Makie.MakieLayout

export maze_plot, agent_plot!, theta_0, pi_theta_softmax, next_step, maze, update_theta, train, save_anim

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
    pi_theta_softmax(theta::Matrix{Union{Nothing, Number}}) = pi::Matrix{Number} (8x4)

方策パラメータ θ を行動方策 π に変換する Softmax 関数
"""
pi_theta_softmax(theta::Matrix) = begin
    # 逆温度β: 小さいほど行動がランダムになりやすい
    beta = 1.0

    # exp(βθ)::Matrix{Number} (8x4): ここでマイナス値も正規化される
    exp_theta = exp.(beta .* theta)

    # π_softmax(θ)
    ## 欠損値を無視して行ごとの列値合計を算出するために nansum(::Matrix, dims=2) を使う
    pi = exp_theta ./ nansum(exp_theta, dims=2)

    # 欠損値を 0.0 に変換して完了
    map(pi) do v isnan(v) ? 0.0 : v end
end

"""
    next_step(pi_n::Matrix{<:Number}, state::Int) = action_and_next_state::Tuple{Int, Int}

採用した行動 a と行動後の状態 s を求める関数

- `pi_n::Matrix{Number}`: 方策 π
- `state::Int`: 現在の状態 1..8
    - 1: S0, 2: S1, ... 8: S7
- `action_and_next_state::Tuple{Int, Int}`:
    - `(採用した行動, 行動後の状態)`
    - 行動: 1: UP, 2: RIGHT, 3: DOWN, 4: LEFT
"""
next_step(pi_n::Matrix{<:Number}, state::Int) = begin
    actions = [1, 2, 3, 4] # UP, RIGHT, DOWN, LEFT

    # 行動を決定
    ## Distributions.wsample(samples::Vector, weights::Vector) = choiced_sample
    ### samples の中から任意の値を1つ選択する。ただしその選択確率は weights で定められた重みによって決められる
    action = wsample(actions, pi_n[state, :])

    # 状態遷移
    # - 上: 状態 - 3
    # - 右: 状態 + 1
    # - 下: 状態 + 3
    # - 左: 状態 - 1
    state_transitions = Dict(
        1 => -3,
        2 => +1,
        3 => +3,
        4 => -1,
    )
    state_next = state + state_transitions[action]
    (action, state_next)
end

"""
    maze(pi_n::Matrix{<:Number}) = state_action_history::Vector{Tuple{Int, Int}}

迷路内をエージェントがゴールするまで移動させる関数

ゴールするまでにエージェントが通った状態と行動の軌跡 state_action_history を返す

- `state_action_history::Vector{Tuple{Int, Int}}`: `[(state1, action1), (state2, action2), ...]`
"""
maze(pi_n::Matrix) = begin
    # スタート地点: S0, ゴール地点: S8
    start, goal = 1, 9
    # 状態: 初期値 = S0
    state::Int = start
    # エージェントの移動記録: (状態, 行動)
    state_action_history::Vector{Tuple} = []

    # ゴールするまで step を繰り返す
    while state !== goal
        action, state_next = next_step(pi_n, state)
        push!(state_action_history, (state, action))
        state = state_next
    end

    # ゴール地点の記録
    push!(state_action_history, (state, NaN))

    state_action_history
end

"""
    update_theta(theta_n::Matrix, pi_n::Matrix, state_action_history::Vector{Tuple}) = theta_next::Matrix

方策勾配法による方策パラメータの更新関数

θ_{s_i, a_j} = θ_{s_i, a_j} + η⋅Δθ_{s_i, a_j}
Δθ_{s_i, a_j} = [N(s_i, a_j) + P(s_i, a_j)N(s_i, a)] / T

- θ_{s_i, a_j}
    - 状態（迷路問題の場合は位置）s_i で行動 a_j を採用する確率を決めるパラメータ
- η
    - 学習係数: θ_{s_i, a_j} が1回の学習で更新される大きさ
    - η が小さすぎると学習がなかなか進まないが、大きすぎるとうまく学習できない
- N(s_i, a_j)
    - 状態 s_i で行動 a_j を採用した回数
- P(s_i, a_j)
    - 現在の方策において、状態 s_i で行動 a_j を採用する確率
- N(s_i, a)
    - 状態 s_i で何らかの行動をとった回数の合計
- T
    - ゴールまでにかかった総ステップ数
"""
update_theta(theta_n::Matrix, pi_n::Matrix, state_action_history::Vector{Tuple}) = begin
    # 学習率 η: とりあえず 0.1 で試す
    eta = 0.1
    
    # ゴールまでの総ステップ数: ゴール地点のステップは除外
    T = length(state_action_history) - 1

    # Δθ の計算
    delta_theta = [
        isnan(theta_n[i, j]) ? NaN : (
            begin
                # 状態 = s_i である記録を取得
                SA_i = filter(SA -> SA[1] === i, state_action_history)

                # 状態 = s_i で 行動 = a_j をとった記録を取得
                SA_ij = filter(SA -> SA[1] === i && SA[2] === j, state_action_history)

                # N(s_i, a), N(s_i, a_j)
                N_i = length(SA_i)
                N_ij = length(SA_ij)

                # Δθ
                (N_ij + pi_n[i, j] * N_i) / T
            end
        )
        for i = 1:size(theta_n, 1), j = 1:size(theta_n, 2)
    ]

    # 更新されたθ
    theta_next = theta_n .+ eta .* delta_theta
    theta_next
end

"""
    train(theta_0::Matrix{Number}) =
        records::Vector{Tuple{Number, Int}},
        theta_n::Matrix{Number},
        pi_n::Matrix{Number}

方策勾配法で迷路問題の学習を実行する関数

- `theta_0::Matrix{Number}`: 初期方策を決定するパラメータ

# returns

- `records::Vector{Tuple{Number, Int}}`: 学習記録
    - `[(方策変化の絶対値和, ゴールまでのステップ数), ...]`
- `theta_n::Matrix{Number}`: 最終的な方策パラメータ
- `pi_n::Matrix{Number}`: 最終的な方策
"""
function train(theta_0::Matrix)
    # 学習完了の方策変化しきい値
    stop_epsilon = 10^-8

    # 最大学習回数
    max_count = 10_0000

    # 初期 θ, π
    theta_n = theta_0
    pi_n = pi_theta_softmax(theta_0)

    # 学習記録: [(方策変化の絶対値和, ゴールまでのステップ数), ...]
    records = Vector{Tuple}()

    # 方策勾配法により学習ループする
    @showprogress for _ = 1:max_count
        state_action_history = maze(pi_n) # 方策 π で迷路内を探索した履歴を取得
        theta_next = update_theta(theta_n, pi_n, state_action_history) # 方策パラメータ θ の更新
        pi_next = pi_theta_softmax(theta_next) # 方策 π の更新

        # 方策変化の絶対値和
        delta_pi = sum(abs.(pi_next .- pi_n))
        # 記録: (方策変化の絶対値和, ゴールまでのステップ数)
        push!(records, (delta_pi, length(state_action_history)))

        # 終了条件
        delta_pi < stop_epsilon && break

        # θ, π 更新
        theta_n, pi_n = theta_next, pi_next
    end

    records, theta_n, pi_n
end

"""
    save_anim(save_filename::String, state_action_history::Vector{Tuple})

迷路内をエージェントがゴールするまで移動させた記録を動画ファイルに保存する関数
"""
save_anim(save_filename::String, state_action_history::Vector{Tuple}) = begin
    # 初期プロット描画
    fig, plt, ax, state_positions = maze_plot()
    agent_pos = agent_plot!(plt, state_positions[1])

    # 動画作成
    n_states = length(state_action_history)
    record(fig, save_filename, 1:n_states;
        # state_action_history を10秒でアニメーションさせるように framerate 設定
        framerate = ceil(Int, n_states / 10)
    ) do frame
        # エージェント位置更新
        agent_pos[] = state_positions[state_action_history[frame][1]]

        # プロットタイトル更新
        ax.title = "Step: $frame"
    end
end

end # module
