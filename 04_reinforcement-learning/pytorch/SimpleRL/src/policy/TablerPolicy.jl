export TablerPolicy

"""
表形式方策
- 行動決定: (状態) -> (次の行動)
"""
Base.@kwdef mutable struct TablerPolicy <: RLPolicy
    pi::Matrix{<:AbstractFloat} # 行動の採用確率
end

(policy::TablerPolicy)(state::Int) ::Int = begin
    actions = action_space(env) # 行動空間

    # 行動を決定
    ## Distributions.wsample(samples::Vector, weights::Vector) = choiced_sample
    ### samples の中から任意の値を1つ選択する。ただしその選択確率は weights で定められた重みによって決められる
    wsample(collect(actions), policy.pi[state, :])
end
