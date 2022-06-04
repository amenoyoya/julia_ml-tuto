"""
CartPole の DQN 強化学習を GIF アニメーションに保存

https://github.com/JuliaReinforcementLearning/ReinforcementLearning.jl/issues/246
"""

using ReinforcementLearning, StableRNGs, Flux, Flux.Losses, Plots

function RL.Experiment(
    ::Val{:JuliaRL},
    ::Val{:BasicDQN},
    ::Val{:CartPole},
    ::Nothing;
    seed = 123
)
    rng = StableRNG(seed)
    env = CartPoleEnv(; T = Float32, rng = rng)
    ns, na = length(state(env)), length(action_space(env))

    policy = Agent(
        policy = QBasedPolicy(
            learner = BasicDQNLearner(
                approximator = NeuralNetworkApproximator(
                    model = Chain(
                        Dense(ns, 128, relu; init = glorot_uniform(rng)),
                        Dense(128, 128, relu; init = glorot_uniform(rng)),
                        Dense(128, na; init = glorot_uniform(rng)),
                    ) |> gpu,
                    optimizer = ADAM(),
                ),
                batch_size = 32,
                min_replay_history = 100,
                loss_func = huber_loss,
                rng = rng,
            ),
            explorer = EpsilonGreedyExplorer(
                kind = :exp,
                ϵ_stable = 0.01,
                decay_steps = 500,
                rng = rng,
            ),
        ),
        trajectory = CircularArraySARTTrajectory(
            capacity = 1000,
            state = Vector{Float32} => (ns,),
        ),
    )
    stop_condition = StopAfterStep(10_000, is_show_progress=!haskey(ENV, "CI"))
    hook = TotalRewardPerEpisode()
    Experiment(policy, env, stop_condition, hook, "# BasicDQN <-> CartPole")
end

function hook_plot_func(anim)
    func_plot = function (t, agent, env)
        plot(env)
        frame(anim)
    end
    hook_plot = DoEveryNStep(func_plot)
end

function test_simple()
    experiment = E`JuliaRL_BasicDQN_CartPole`
    # policy = experiment.policy
    # env = experiment.env
    # s = state(env)
    # @show s
    # a = policy(env)
    # @show a
    anim = Animation()
    hook_plot = hook_plot_func(anim)
    hook = ComposedHook(experiment.hook, hook_plot)
    # hook = ComposedHook(experiment.hook, TotalRewardPerEpisode())
    # hook = TotalRewardPerEpisode()
    run(experiment.policy, experiment.env, experiment.stop_condition, hook)
    gif(anim, "03-BasicDQN-CartPole.gif", fps=15)
    # run(experiment.policy, experiment.env, experiment.stop_condition, experiment.hook)
end

# Progress time: 0:29:42
test_simple()
