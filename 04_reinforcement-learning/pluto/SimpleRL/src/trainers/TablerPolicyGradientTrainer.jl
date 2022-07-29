export TablerPolicyGradientTrainer, tabler_policy_theta_softmax

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

"""
    init!(trainer::TablerPolicyGradientTrainer, ::MazeEnv)

迷路問題用にトレーナーを初期化
"""
init!(trainer::TablerPolicyGradientTrainer, ::MazeEnv) = begin
    trainer.theta = MazeInitialTheta
    trainer.policy = tabler_policy_theta_softmax(trainer.theta)
end

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

policy(trainer::TablerPolicyGradientTrainer) = trainer.policy
