export TrajectoryHook

"""
    mutable struct TrajectoryHook

学習記録フック

- `records::Vector{<:NamedTuple}`: 1シナリオ実行時の状態・行動記録
    - `[(state = 現在の状態, action = 次の行動), ...]`
- `trains::Vector{<:NamedTuple}`: 学習記録
    - `[(diff = パラメータ変化量, records = 1シナリオ実行時の状態・行動記録)]`
"""
Base.@kwdef mutable struct TrajectoryHook
	records::Vector{<:NamedTuple} = NamedTuple[]
	trains::Vector{<:NamedTuple} = NamedTuple[]
end

on_init!(hook::TrajectoryHook, env, policy) = hook.records = NamedTuple[]

before_action!(hook::TrajectoryHook, env, policy, state, action) = begin
    push!(hook.records, (state = state, action = action))
    true
end

after_action!(hook::TrajectoryHook, env, policy) = true

on_end!(hook::TrajectoryHook, env, policy) = push!(hook.records, (state = current_state(env), action = NaN))

on_train_begin!(hook::TrajectoryHook, env, trainer) = hook.trains = NamedTuple[]

before_solve!(hook::TrajectoryHook, env, trainer, count) = true

after_solve!(hook::TrajectoryHook, env, trainer, count, diff, records) = begin
    push!(hook.trains, (diff = diff, records = records))
    true
end

on_train_end!(hook::TrajectoryHook, env, trainer) = nothing
