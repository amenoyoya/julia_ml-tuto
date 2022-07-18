using Test, SimpleRL

@testset "MazeEnv" begin
    @testset "execute!(::MazeEnv)" begin
        env = MazeEnv() # 迷路問題環境

        n_steps = execute!(env)
        records = trajectory(env)()

        @test n_steps === length(records) - 1 # 迷路問題を解くのにかかったステップ数
        @test current_state(env) === Int(S8) # 最終状態 = S8(GOAL)
        @test length(records) >= 5 # 最短経路を通っても5ステップかかるはず
        @test records[end] === (state = Int(S8), action = NaN) # 最終記録
    end
end
