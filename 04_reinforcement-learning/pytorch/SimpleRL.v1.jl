module SimpleRL

"強化学習環境モデル"
abstract type AbstractEnv end

"""
    state_space(::AbstractEnv) -> states::Union{AbstractArray, Tuple}

状態空間: 環境モデル内のすべての状態
"""
state_space(::E where E <: AbstractEnv) = error("state_space(::AbstractEnv) must be implemented to return all the environment states.")

"""
    action_space(::AbstractEnv) -> actions::Union{AbstractArray, Tuple}

行動空間: エージェントがとりうるすべての行動
"""
action_space(::E where E <: AbstractEnv) = error("action_space(::AbstractEnv) must be implemented to return all the environment actions.")

"""
    state(::AbstractEnv) -> state::Int

現在の状態
"""
state(::E where E <: AbstractEnv)::Int = error("state(::AbstractEnv) must be implemented to return the current environment state.")

"""
    reward(::AbstractEnv) -> reward::Number

報酬
"""
reward(::E where E <: AbstractEnv)::Number = error("reward(::AbstractEnv) must be implemented to return the environment reward.")

"""
    is_terminated(::AbstractEnv) -> terminated::Bool

終了条件
"""
is_terminated(::E where E <: AbstractEnv)::Bool = error("is_terminated(::AbstractEnv) must be implemented to return flag to determine if the environment is terminated.")

"""
    reset!(::AbstractEnv)

環境モデル初期化
"""
reset!(::E where E <: AbstractEnv) = error("reset!(::AbstractEnv) must be implemented to reset the environment.")

"""
    (::AbstractEnv)(action::Int)

1ステップの実行処理
"""
(::E where E <: AbstractEnv)(action::Int) = error("(::AbstractEnv)(action::Int) must be implemented to process the environment 1 step.")

"方策モデル"
abstract type AbstractPolicy end

"""
    (::AbstractPolicy)(::AbstractEnv) -> action::Int

行動を決定する方策
"""
(::P where P <: AbstractPolicy)(::E where E <: AbstractEnv)::Int = error("(::AbstractPolicy)(::AbstractEnv) must be implemented to return the next action by the policy.")

"""
    update!(::AbstractPolicy, trajactory::Vector{NamedTuple})

訓練時の方策更新処理

- `trajactory::Vector{NamedTuple}`: エージェントが辿った状態と行動の記録
    - `trajectory[n].state`: エージェントが辿った状態
    - `trajectory[n].action`: エージェントがとった行動
"""
update!(::P where P <: AbstractPolicy, trajactory::Vector{NamedTuple}) = error("update!(::AbstractPolicy, trajactory::Vector{NamedTuple}) must be implemented to update the policy.")

"訓練停止条件モデル"
abstract type AbstractStopCondition end

"フックモデル"
abstract type AbstractHook end

"""
    train!(::AbstractPolicy, ::AbstractEnv, ::AbstractStopCondition, ::AbstractHook)

方策の訓練
"""
train!(
    ::P where P <: AbstractPolicy,
    ::E where E <: AbstractEnv,
    ::S where S <: AbstractStopCondition,
    ::H where H <: AbstractHook
)

end # module
