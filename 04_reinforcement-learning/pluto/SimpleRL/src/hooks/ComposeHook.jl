export ComposeHook

"""
    struct ComposeHook

複数のフックイベントを合成するフック

```julia
# エージェントの最大回数を設定し、エージェントの行動記録を取りたい場合
ComposeHook((MaxStepHook(; max_step = 100), TrajectoryHook()))
```
"""
struct ComposeHook
    hooks::Tuple
end

on_init!(hook::ComposeHook, env, policy) = map(hook.hooks) do h
    on_init!(h, env, policy)
end

before_action!(hook::ComposeHook, env, policy, state, action) = reduce(hook.hooks; init = true) do is_continuous, h
    is_continuous && before_action!(h, env, policy, state, action)
end

after_action!(hook::ComposeHook, env, policy) = reduce(hook.hooks; init = true) do is_continuous, h
    is_continuous && after_action!(h, env, policy)
end

on_end!(hook::ComposeHook, env, policy) = map(hook.hooks) do h
    on_end!(h, env, policy)
end

on_train_begin!(hook::ComposeHook, env, trainer) = map(hook.hooks) do h
    on_train_begin!(h, env, trainer)
end

before_solve!(hook::ComposeHook, env, trainer, count) = reduce(hook.hooks; init = true) do is_continuous, h
    is_continuous && before_solve!(h, env, trainer, count)
end

after_solve!(hook::ComposeHook, env, trainer, count, diff, records) = reduce(hook.hooks; init = true) do is_continuous, h
    is_continuous && after_solve!(h, env, trainer, count, diff, records)
end

on_train_end!(hook::ComposeHook, env, trainer) = map(hook.hooks) do h
    on_train_end!(h, env, trainer)
end
