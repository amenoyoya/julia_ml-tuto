### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 1156f5a0-0e69-11ed-33c6-9322059a03c1
# Revise パッケージを最初に読み込んでおき、
# 開発中のパッケージに変更が加えられる度に自動でリロードするようにする
using Revise, Pkg

# ╔═╡ 8bab5c0d-1662-4d4e-908c-d55b919b2fd4
Pkg.activate("./SimpleRL")

# ╔═╡ 165f0eaa-6cfc-4eb7-8eff-eddd6e9f4fe2
Pkg.add([
	"GLMakie",
	"NaNStatistics",
	"Distributions",
	"ProgressMeter"
])

# ╔═╡ d9abfae2-9ebf-4e1b-9ca4-0dfab53faddc
using SimpleRL, NaNStatistics, ProgressMeter, GLMakie

# ╔═╡ d95ed1c0-e8bf-44ef-8738-b3e1799a4aab
md"""
# 迷路問題

## パッケージ作成

[Maze-01.jl](./Maze-01.jl) のコードを元に `SimpleRL` パッケージを作成する
"""

# ╔═╡ 520efc52-c8de-4577-a59e-ede2d1338a8d
if !isdir("./SimpleRL")
	Pkg.generate("./SimpleRL")
end

# ╔═╡ 09eabe5e-d39a-47ac-9c52-8e5ef8ca32b8
# SimpleRL パッケージ動作確認
## Maze-01.jl と同等のコード
(() -> begin
	env = MazeEnv()
	policy = tabler_policy_theta_ratio(MazeInitialTheta)
	hook = TrajectoryHook()

	solve!(env, policy; hook = hook)

	env, policy, hook
end)()

# ╔═╡ dc6b4e72-b322-4f73-988f-05276ccb9aa3
md"""
## 強化学習実行

強化学習を行う処理を擬似コードで書くと以下のような形になる

```julia
"
- トレーナー:
  - 方策勾配法, SARSA, Q学習等
  - 方策を内包する
"
train!(環境, トレーナー; フック = デフォルトフック, 最大学習回数 = 100_000) = begin
	trajectory = TrajectoryHook() # 行動記録用フック

	初期化!(トレーナー, 環境)
	on_train_begin!(フック, 環境, トレーナー)

	# プログレスバー表示
	@showprogress for count = 1 : 最大学習回数
		継続フラグ = before_solve!(フック, 環境, トレーナー, count)
		!継続フラグ && break

		solve!(環境, 方策取得(トレーナー); hook = trajectory)

		パラメータ変化量 = パラメータ更新!(トレーナー, 環境, trajectory.records)

		継続フラグ = after_solve!(フック, 環境, トレーナー, count, パラメータ変化量, trajectory.records)
		!継続フラグ && break
	end

	on_train_end!(フック, 環境, 方策, トレーナー)
end
```
"""

# ╔═╡ 045c2138-6ffb-4855-9e2b-3d52505c00dc
md"""
### 方策勾配法

- トレーナー: 方策勾配法
  - 内部方策: 表形式方策（TablerPolicy）
  - パラメータ更新式:
    - $\theta_{s_i, a_j} = \theta_{s_i, a_j} + \eta \cdot \Delta\theta_{s, a_j}$
    - $\Delta\theta_{s, a_j} = \{N(s_i, a_j) + P(s_i, a_j) N(s_i, a)\} / T$
      - ※ $P(s_i, a_j)$: 状態 $s_i$ で行動 $a_j$ をとる確率
      - ※ $N(s_i, a)$: 状態 $s_i$ で何らかの行動をとった回数の合計
      - ※ $T$: 問題解決までにかかった総ステップ数
"""

# ╔═╡ cc941ef7-5b6d-413d-9556-4df32c43352e
"""
	tabler_policy_theta_softmax(theta::Matrix{<:Number}) -> ::TablerPolicy

方策パラメータ θ をソフトマックス関数を通して方策 π に変換
"""
tabler_policy_theta_softmax(theta::Matrix{<:Number}) = begin
    # 逆温度β: 小さいほど行動がランダムになりやすい
    beta = 1.0

    # exp(βθ)::Matrix{Number} (8x4): ここでマイナス値も正規化される
    exp_theta = exp.(beta .* theta)

    # π_softmax(θ)
    ## 欠損値を無視して行ごとの列値合計を算出するために nansum(::Matrix, dims=2) を使う
    pi = exp_theta ./ nansum(exp_theta, dims=2)

    # 欠損値を 0.0 に変換
    pi = map(pi) do v isnan(v) ? 0.0 : v end

	TablerPolicy(pi)
end

# ╔═╡ 4ccfb8dc-3756-412f-aeae-d57889ca17b1
"""
	mutable struct TablerPolicyGradientTrainer

表形式方策を方策勾配法で訓練するトレーナー

- `theta::Matrix{<:Number}`: 内部方策パラメータ
- `policy::TablerPolicy`: 内部方策
- `eta::Number`: 学習率 (0 < eta < 1)
"""
Base.@kwdef mutable struct TablerPolicyGradientTrainer
	theta::Matrix{<:Number} = zeros(0, 0)
	policy::TablerPolicy = TablerPolicy(zeros(0, 0))
	eta::Number = 0.1
end

# ╔═╡ 7b4ec10a-e106-4981-8b78-64f949162ba1
"""
	init!(trainer::TablerPolicyGradientTrainer, ::MazeEnv)

迷路問題用にトレーナーを初期化
"""
init!(trainer::TablerPolicyGradientTrainer, ::MazeEnv) = begin
	trainer.theta = MazeInitialTheta
	trainer.policy = tabler_policy_theta_softmax(trainer.theta)
end

# ╔═╡ dafa9301-2307-4679-af2d-81a56605cd96
"""
	update!(trainer::TablerPolicyGradientTrainer, env, records::Vector{<:NamedTuple}) -> delta_pi::Number

方策勾配法によるパラメータ更新
"""
update!(trainer::TablerPolicyGradientTrainer, env, records::Vector{<:NamedTuple}) = begin
    # ゴールまでの総ステップ数: ゴール地点のステップは除外
    T = length(records) - 1

	theta = trainer.theta
	pi = trainer.policy.pi

    # Δθ の計算
    delta_theta = [
        isnan(theta[i, j]) ? NaN : (
            begin
                # 状態 = s_i である記録を取得
                SA_i = filter(record -> record.state === i, records)

                # 状態 = s_i で 行動 = a_j をとった記録を取得
                SA_ij = filter(record -> record.state === i && record.action === j, records)

                # N(s_i, a), N(s_i, a_j)
                N_i = length(SA_i)
                N_ij = length(SA_ij)

                # Δθ
                (N_ij + pi[i, j] * N_i) / T
            end
        )
        for i = 1:size(theta, 1), j = 1:size(theta, 2)
    ]

    # 方策パラメータ更新
    trainer.theta = theta .+ trainer.eta .* delta_theta
    
	# 方策更新 + 方策変化量計算
	pi_old = trainer.policy.pi
	trainer.policy = tabler_policy_theta_softmax(trainer.theta)

	sum(abs.(trainer.policy.pi .- pi_old))
end

# ╔═╡ ad35abc9-fcad-4ac2-9763-a882c93ecf22
"""
	policy(trainer::TablerPolicyGradientTrainer) -> policy

トレーナーの内部方策取得
"""
policy(trainer::TablerPolicyGradientTrainer) = trainer.policy

# ╔═╡ 28785bc8-c889-4b22-97d4-421ceef62b3d
"""
	struct ThresholdHook

強化学習によるパラメータ変化量が閾値以下になったときにループ終了するフック

- `threshold::Number`: パラメータ変化量の閾値
"""
struct ThresholdHook
	threshold::Number
end

# ╔═╡ ba830e45-e966-4ed3-8baf-91dde9475bac
SimpleRL.on_train_begin!(hook::ThresholdHook, env, trainer) = nothing

# ╔═╡ 34a994ca-875e-42ef-a219-bff74b055967
SimpleRL.before_solve!(hook::ThresholdHook, env, trainer, count) = true

# ╔═╡ 9a60baf5-fbdf-4282-b5ab-4f910674bb40
SimpleRL.after_solve!(hook::ThresholdHook, env, trainer, count, diff, records) = hook.threshold < diff

# ╔═╡ 0680c5e2-6ba1-46c8-a9a7-6ca1cc48cc87
SimpleRL.on_train_end!(hook::ThresholdHook, env, trainer) = nothing

# ╔═╡ 1f7e8ca1-cff5-425e-b00a-61536283b87d
md"""
TablerPolicyGradientTrainer の初期状態確認
"""

# ╔═╡ 74aa307a-5f0f-4617-a550-343b9757a00b
(() -> begin
	trainer = TablerPolicyGradientTrainer()
	init!(trainer, MazeEnv())
	trainer
end)()

# ╔═╡ e0a91481-ff11-4f37-9f5a-eb94d9b0242c
md"""
### 強化学習実行関数の実装
"""

# ╔═╡ 33fd503c-4afe-408c-aef5-b4dfe462f65e
"""
	train!(env, trainer; hook = ThresholdHook(10^-8), max_count = 100_000)

強化学習実行
"""
train!(env, trainer; hook = ThresholdHook(10^-8), max_count = 100_000) = begin
	trajectory_hook = TrajectoryHook()

	init!(trainer, env)
	on_train_begin!(hook, env, trainer)

	@showprogress for i = 1 : max_count
		is_continuous = before_solve!(hook, env, trainer, i)
		!is_continuous && break

		solve!(env, policy(trainer); hook = trajectory_hook)
		diff = update!(trainer, env, trajectory_hook.records)

		is_continuous = after_solve!(hook, env, trainer, i, diff, trajectory_hook.records)
		!is_continuous && break
	end

	on_train_end!(hook, env, trainer)
end

# ╔═╡ 8557e30b-b5f5-4627-b89c-a7780aab91bc
env, trainer, hook = (() -> begin
	env = MazeEnv()
	trainer = TablerPolicyGradientTrainer()
	hook = ComposeHook((TrajectoryHook(), ThresholdHook(10^-8)))

	train!(env, trainer; hook = hook)

	env, trainer, hook
end)()

# ╔═╡ 41af12a6-fff4-4b34-9eaf-bc5241014a77
# 学習回数
length(hook.hooks[1].trains)

# ╔═╡ 96bbc7ee-b3a0-4be7-9149-4f888d4451e1
# 最終ソルバー実行時のステップ数
## 最短経路の 5 step になっていれば学習は上手く行っている
length(hook.hooks[1].trains[end].records)

# ╔═╡ 4cba6351-1b6d-4b97-a01c-db82d9b1e05e
# 学習曲線（方策変化量）プロット
GLMakie.plot(map(hook.hooks[1].trains) do train train.diff end)

# ╔═╡ 949e590b-3f17-4a16-ad69-0bd79aa6f6d3
# 学習曲線（ステップ数）プロット
GLMakie.plot(map(hook.hooks[1].trains) do train train.records |> length end)

# ╔═╡ 3b9e20ee-a7b8-4987-aeb1-1f511b6a5363


# ╔═╡ Cell order:
# ╠═d95ed1c0-e8bf-44ef-8738-b3e1799a4aab
# ╠═1156f5a0-0e69-11ed-33c6-9322059a03c1
# ╠═520efc52-c8de-4577-a59e-ede2d1338a8d
# ╠═8bab5c0d-1662-4d4e-908c-d55b919b2fd4
# ╠═165f0eaa-6cfc-4eb7-8eff-eddd6e9f4fe2
# ╠═d9abfae2-9ebf-4e1b-9ca4-0dfab53faddc
# ╠═09eabe5e-d39a-47ac-9c52-8e5ef8ca32b8
# ╠═dc6b4e72-b322-4f73-988f-05276ccb9aa3
# ╠═045c2138-6ffb-4855-9e2b-3d52505c00dc
# ╠═cc941ef7-5b6d-413d-9556-4df32c43352e
# ╠═4ccfb8dc-3756-412f-aeae-d57889ca17b1
# ╠═7b4ec10a-e106-4981-8b78-64f949162ba1
# ╠═dafa9301-2307-4679-af2d-81a56605cd96
# ╠═ad35abc9-fcad-4ac2-9763-a882c93ecf22
# ╠═28785bc8-c889-4b22-97d4-421ceef62b3d
# ╠═ba830e45-e966-4ed3-8baf-91dde9475bac
# ╠═34a994ca-875e-42ef-a219-bff74b055967
# ╠═9a60baf5-fbdf-4282-b5ab-4f910674bb40
# ╠═0680c5e2-6ba1-46c8-a9a7-6ca1cc48cc87
# ╠═1f7e8ca1-cff5-425e-b00a-61536283b87d
# ╠═74aa307a-5f0f-4617-a550-343b9757a00b
# ╠═e0a91481-ff11-4f37-9f5a-eb94d9b0242c
# ╠═33fd503c-4afe-408c-aef5-b4dfe462f65e
# ╠═8557e30b-b5f5-4627-b89c-a7780aab91bc
# ╠═41af12a6-fff4-4b34-9eaf-bc5241014a77
# ╠═96bbc7ee-b3a0-4be7-9149-4f888d4451e1
# ╠═4cba6351-1b6d-4b97-a01c-db82d9b1e05e
# ╠═949e590b-3f17-4a16-ad69-0bd79aa6f6d3
# ╠═3b9e20ee-a7b8-4987-aeb1-1f511b6a5363
