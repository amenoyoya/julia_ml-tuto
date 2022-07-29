export MaxStepHook

"""
    mutable struct MaxStepHook

エージェントの最大行動回数を設定するフック

- `max_step::Int`: 最大行動回数
- `step::Int`: 現在の行動回数

```julia
MaxStepHook(; max_step = 100) # -> 100回行動した時点で終了
```
"""
Base.@kwdef mutable struct MaxStepHook
    max_step::Int
    step::Int = 0
end

on_init!(hook::MaxStepHook, env, policy) = hook.step = 0

before_action!(hook::MaxStepHook, env, policy, state, action) = true

after_action!(hook::MaxStepHook, env, policy) = (hook.step += 1) >= hook.max_step

on_end!(hook::MaxStepHook, env, policy) = nothing

on_train_begin!(hook::MaxStepHook, env, trainer) = nothing

before_solve!(hook::MaxStepHook, env, trainer, count) = true

after_solve!(hook::MaxStepHook, env, trainer, count, diff, records) = true

on_train_end!(hook::MaxStepHook, env, trainer) = nothing