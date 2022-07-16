using Test, SimpleRL

@testset "MazeEnv" begin
    @testset "execute!(::MazeEnv, ::TablerPolicy, ::ArrayRecorder)" begin
        env = MazeEnv() # 迷路問題環境
        policy = tabler_policy(env) # 表形式方策
        recorder = ArrayRecorder() # 配列式記録

        # @TODO 自動テスト時、以下の処理が終わらない
        execute!(env, policy, recorder)
        state(env) === Int(MazeState.S8)
    end
end
