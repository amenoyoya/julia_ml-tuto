export ThresholdHook

"""
    struct ThresholdHook

強化学習によるパラメータ変化量が閾値以下になったときにループ終了するフック

- `threshold::Number`: パラメータ変化量の閾値
"""
struct ThresholdHook
    threshold::Number
end

on_init!(hook::ThresholdHook, env, policy) = nothing

before_action!(hook::ThresholdHook, env, policy, state, action) = true

after_action!(hook::ThresholdHook, env, policy) = true

on_end!(hook::ThresholdHook, env, policy) = nothing

on_train_begin!(hook::ThresholdHook, env, trainer) = nothing

before_solve!(hook::ThresholdHook, env, trainer, count) = true

after_solve!(hook::ThresholdHook, env, trainer, count, diff, records) = hook.threshold < diff

on_train_end!(hook::ThresholdHook, env, trainer) = nothing
