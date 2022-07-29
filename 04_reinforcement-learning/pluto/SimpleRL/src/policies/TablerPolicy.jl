export TablerPolicy, tabler_policy_theta_ratio

"""
    mutable struct TablerPolicy

表形式方策

- `pi::Matrix{<:Number}`: 行動方策π
"""
mutable struct TablerPolicy
	pi::Matrix{<:Number}
end

"""
    next_action(policy::TablerPolicy, action_space, current_state) -> next_action

表形式方策: 行動空間と現在の状態から次の行動を決定
"""
next_action(policy::TablerPolicy, action_space, current_state) = begin
    # 行動を決定
    ## Distributions.wsample(samples::Vector, weights::Vector) = choiced_sample
    ### samples の中から任意の値を1つ選択する。ただしその選択確率は weights で定められた重みによって決められる
    wsample(collect(action_space), policy.pi[current_state, :])
end

"""
    tabler_policy_theta_ratio(theta::Matrix{<:Number}) -> policy::TablerPolicy

方策パラメータθを割合計算して表形式方策に変換

- 例: S0 [NaN 1.0 1.0 NaN] の場合
  - 行動の採用確率は [0.0 0.5 0.5 0.0] となる
"""
tabler_policy_theta_ratio(theta::Matrix{<:Number}) = TablerPolicy(
    # 各値をその行での割合 (値 / その行の合計値) に変換
    ## NaN 値を無視して合計を出すには NaNStatistics.nansum を使うと良い
    theta ./ nansum(theta, dims = 2) |>
        # NaN 値を 0.0 に変換
        theta -> map(t -> isnan(t) ? 0.0 : t, theta)
)
