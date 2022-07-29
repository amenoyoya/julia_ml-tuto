module SimpleRL

using GLMakie, NaNStatistics, Distributions

include("./envs/envs.jl")
include("./policies/policies.jl")
include("./hooks/hooks.jl")
include("./trainers/trainers.jl")

export solve!

"""
    solve!(env, policy; hook = TrajectoryHook())

強化学習のソルバー
"""
solve!(env, policy; hook = TrajectoryHook()) = begin
    init!(env)
    on_init!(hook, env, policy)

    while !is_terminated(env)
        actions = action_space(env)
        state = current_state(env)
        action = next_action(policy, actions, state)

        is_continuous = before_action!(hook, env, policy, state, action)
        !is_continuous && break

        act!(env, action)

        is_continuous = after_action!(hook, env, policy)
        !is_continuous && break
    end

    on_end!(hook, env, policy)
end

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

end # module
