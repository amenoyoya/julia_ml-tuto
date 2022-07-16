using Test, SimpleRL

@testset "MazeEnv" begin
    @testset "execute!(::MazeEnv, ::TablerPolicy, ::ArrayRecorder)" begin
        env = MazeEnv() # 迷路問題環境
        policy = tabler_policy(env) # 表形式方策
        recorder = ArrayRecorder() # 配列式記録

        n_steps = execute!(env, policy, recorder)

        @test n_steps === length(records(recorder)) - 1 # 迷路問題を解くのにかかったステップ数
        @test state(env) === Int(S8) # 最終状態 = S8(GOAL)
        @test length(records(recorder)) >= 5 # 最短経路を通っても5ステップ
        @test records(recorder)[end] == (state = Int(S8), action = nothing) # 最終記録
    end
end
