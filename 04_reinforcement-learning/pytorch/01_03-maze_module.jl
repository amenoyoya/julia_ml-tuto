module Maze

using GLMakie, NaNStatistics, Distributions, ProgressMeter
using GLMakie: Makie.MakieLayout

export maze_plot, agent_plot!, theta_0, pi_theta_softmax, e_greedy, next_state, maze, sarsa!, sarsa_maze!, train, save_anim

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
    e_greedy(state::Int, Q::Matrix{Number}, epsilon::Number, pi_n::Matrix{Number})
        = action::Int

ε-greedy法 で行動を決定

- `state::Int`: 現在の状態
    - 1: S0, 2: S1, ..., 9: S8
- `Q::Matrix{Number}`: 行動価値関数
- `epsilon::Number`: ランダム行動確率 (0 < epsilon < 1)
- `pi_n::Matrix{Number}`: 方策 π

# returns

- `action::Int`:
    - 1: 上
    - 2: 右
    - 3: 下
    - 4: 左
"""
e_greedy(state::Int, Q::Matrix, epsilon::Number, pi_n::Matrix) = begin
    actions = 1:4

    # ランダム行動 (現在の状態における方策を行動の重みとする)
    rand() < epsilon && return wsample(actions, pi_n[state, :])

    # 行動価値関数の最大値の行動を採用
    ## nanmaximum(::Vector): NaN値を無視して最大値を取得
    ## findfirst(::Function, ::Vector): 指定関数に一致する配列のインデックスを取得
    max_val_index = findfirst(x -> x === nanmaximum(Q[state, :]), Q[state, :])
    actions[max_val_index]
end

"""
    next_state(state::Int, action::Int) = state_next::Int

現在の状態と採用する行動から次の状態を取得する関数
"""
next_state(state::Int, action::Int) = begin
    # 状態遷移表: 行動 => 状態遷移
    state_map = Dict(
        1 => -3, # 上
        2 => +1, # 右
        3 => +3, # 下
        4 => -1, # 左
    )
    # 次の状態
    state + state_map[action]
end

"""
    sarsa!(Q::Matrix{Number}, state::Int, action::Int, reward::Number, state_next::Int, action_next::Int, eta::Number, gamma::Number)
        = Q::Matrix{Number}

Sarsa による行動価値関数 Q の更新を行う関数

- `Q::Matrix{Number}`: 行動価値関数
- `state::Int`: 現在の状態
- `action::Int`: 採用する行動
- `reward::Number`: 報酬
- `state_next::Int`: 行動後の状態
- `action_next::Int`: 次に採用する行動
- `eta::Number`: 学習率
- `gamma::Number`: 時間割引率
"""
sarsa!(Q::Matrix, state::Int, action::Int, reward::Number, state_next::Int, action_next::Int, eta::Number, gamma::Number) = begin
    if state_next === 9
        # ゴールした場合
        Q[state, action] = Q[state, action] + eta * (reward - Q[state, action])
    else
        Q[state, action] = Q[state, action] + eta * (reward + gamma * Q[state_next, action_next] - Q[state, action])
    end
    Q
end

"""
    sarsa_maze!(Q::Matrix, epsilon::Number, eta::Number, gamma::Number, pi_n::Matrix)
        = state_action_history::Vector{Tuple(state::Int, action::Int)}

迷路を解いて Sarsa で行動関数を更新する関数
"""
sarsa_maze!(Q::Matrix, epsilon::Number, eta::Number, gamma::Number, pi_n::Matrix) = begin
    start, goal = 1, 9
    state = start # 初期状態
    action = NaN  # 初期行動
    state_action_history = Vector{Tuple}() # (状態, 行動) の記録

    # ゴールするまでエージェントを動かす
    while state !== goal
        if isnan(action)
            # ε-greedy法で行動採用
            action = e_greedy(state, Q, epsilon, pi_n)
        end

        # (状態, 行動) 記録
        push!(state_action_history, (state, action))

        # 次の状態を取得
        state_next = next_state(state, action)

        # 報酬と次の行動を決定
        reward = state_next === goal ? 1 : 0
        action_next = state_next === goal ? 0 : e_greedy(state_next, Q, epsilon, pi_n)

        # 価値関数の更新
        sarsa!(Q, state, action, reward, state_next, action_next, eta, gamma)

        # 状態, 行動更新
        state, action = state_next, action_next
    end

    # ゴール地点での (状態, 行動)
    push!(state_action_history, (goal, NaN))

    state_action_history
end

"""
    train(theta_0::Matrix; eta::Number = 0.1, gamma::Number = 0.9, epsilon::Number = 0.5, max_episode::Int = 100)
        = records::Vector{Tuple(v_diffsum::Number, state_action_history::Vector{Tuple(state::Int, action::Int)})}, Q::Matrix

Sarsa による強化学習実行関数

- `theta_0::Matrix`: 初期方策パラメータ
- `eta::Number`: 学習率
- `gamma::Number`: 時間割引率
- `epsilon::Number`: ε-greedy法の初期ランダム行動確率
- `max_episode::Int`: 最大エピソード数

# returns

- `records::Vector{Tuple}`: 学習記録
    - `records[episode][1]::Number`: 状態価値の変化絶対総和
    - `records[episode][2]::Vector{Tuple}`: そのエピソードでエージェントがとった行動記録
        - `records[episode][2][n][1]::Int`: そのエピソードでエージェントが辿った状態
        - `records[episode][2][n][2]::Int`: そのエピソードでエージェントがとった行動
- `Q::Matrix`: 行動価値関数
"""
train(theta_0::Matrix; eta::Number = 0.1, gamma::Number = 0.9, epsilon::Number = 0.5, max_episode::Int = 100) = begin
    pi_0 = pi_theta(theta_0) # 初期方策
    Q = rand(size(theta_0)...) .* theta_0 # 初期行動価値
    v = nanmaximum(Q; dims=2) # 状態ごとの価値の最大値
    records = Vector{Tuple}() # (状態価値の変化絶対総和, エージェントの行動記録) の記録

    @showprogress for _ = 1:max_episode
        # ランダム行動確率を少しずつ小さくする
        epsilon = epsilon / 2

        # 迷路問題を解いて Sarsa で状態価値を更新
        state_action_history = sarsa_maze!(Q, epsilon, eta, gamma, pi_0)

        # 状態価値の変化
        v_next = nanmaximum(Q; dims=2)

        # 学習記録: (状態価値の変化絶対総和, エージェントの行動記録)
        push!(records, (sum(abs.(v_next - v)), state_action_history))
    end

    records, Q
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
