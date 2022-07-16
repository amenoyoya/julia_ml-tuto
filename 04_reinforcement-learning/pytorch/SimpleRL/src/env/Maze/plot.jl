using GLMakie
using GLMakie: Makie.MakieLayout

export plot, plot!, save_anim

"""
    plot(::MazeEnv) =   fig::Figure,
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
    plot!(::MazeEnv, plt::GridPosition, init_pos::Point) = agent_pos::Observable{<:Point}

エージェント (赤色半透明のドットで表現) をプロットに追加する関数
"""
plot!(::MazeEnv, plt::GridPosition, init_pos::Point) = begin
    agent_pos = Observable(init_pos)
    scatter!(plt, agent_pos, color = (:red, 0.5), markersize = 50)

    agent_pos
end

"""
    save_anim(::MazeEnv, recorder::ArrayRecorder, save_filename::String)

迷路内をエージェントがゴールするまで移動させた記録を動画ファイルに保存する関数
"""
save_anim(env::MazeEnv, recorder::ArrayRecorder, save_filename::String) = begin
    # 初期プロット描画
    fig, plt, ax, state_positions = plot(env)
    agent_pos = plot!(env, plt, state_positions[1])

    # 動画作成
    data = records(recorder)
    n_data = length(data)
    record(fig, save_filename, 1:n_data;
        # data を10秒でアニメーションさせるように framerate 設定
        framerate = ceil(Int, n_data / 10)
    ) do frame
        # エージェント位置更新
        agent_pos[] = state_positions[data[frame].state]

        # プロットタイトル更新
        ax.title = "Step: $frame"
    end
end
