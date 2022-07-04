using Test
using RPG

# ゲームに対する処理
begin
    ゲーム = RPG.ゲーム()

    # RPG.println 関数を上書きすることで標準出力の自動テストが可能
    io = IOBuffer()
    RPG.println(message) = println(io, message)

    @testset "戦闘開始処理" begin
        @testset "戦闘開始メッセージが出力されること" begin
            RPG.戦闘開始処理(ゲーム)
            @test (io |> take! |> String) === "モンスターに遭遇した！\n戦闘開始！\n"
        end
    end

    @testset "戦闘終了処理" begin
        @testset "モンスター.HP が 0 の場合: 勝利メッセージが出力されること" begin
            ゲーム.勇者.HP = 30
            ゲーム.モンスター.HP = 0
            RPG.戦闘終了処理(ゲーム)
            @test (io |> take! |> String) === "戦闘に勝利した！\n"
        end

        @testset "勇者.HP が 0 の場合: 敗北メッセージが出力されること" begin
            ゲーム.勇者.HP = 0
            ゲーム.モンスター.HP = 30
            RPG.戦闘終了処理(ゲーム)
            @test (io |> take! |> String) === "戦闘に敗北した・・・\n"
        end

        @testset "上記以外の場合: DomainError" begin
            ゲーム.勇者.HP = 30
            ゲーム.モンスター.HP = 30
            @test_throws DomainError RPG.戦闘終了処理(ゲーム)
        end
    end

    @testset "先行後攻決定処理" begin
        @testset "50% の確率: 先攻が勇者であること" begin
            # RPG.rand() 関数を上書きすることで確率処理の自動テストが可能
            RPG.rand() = 0.49

            @test RPG.先行後攻決定処理(ゲーム) == [(ゲーム.勇者, ゲーム.モンスター), (ゲーム.モンスター, ゲーム.勇者)]
        end

        @testset "50% の確率: 先攻がモンスターであること" begin
            # RPG.rand() 関数を上書きすることで確率処理の自動テストが可能
            RPG.rand() = 0.50

            @test RPG.先行後攻決定処理(ゲーム) == [(ゲーム.モンスター, ゲーム.勇者), (ゲーム.勇者, ゲーム.モンスター)]
        end
    end
end

# キャラクターに対する処理
begin
    # RPG.println 関数を上書きすることで標準出力の自動テストが可能
    io = IOBuffer()
    RPG.println(message) = println(io, message)

    @testset "行動入力処理" begin
        @testset "1 が入力された場合: 攻撃コマンド" begin
            # RPG.prompt() 関数を上書きすることで標準入力の自動テストが可能
            RPG.prompt(message::String) = "1"

            @test RPG.行動入力処理() === :攻撃
        end

        @testset "2 が入力された場合: 大振りコマンド" begin
            # RPG.prompt() 関数を上書きすることで標準入力の自動テストが可能
            RPG.prompt(message::String) = "2"

            @test RPG.行動入力処理() === :大振り
        end

        @testset "上記以外が入力された場合: DomainError" begin
            # RPG.prompt() 関数を上書きすることで標準入力の自動テストが可能
            RPG.prompt(message::String) = "3"

            @test_throws KeyError RPG.行動入力処理()
        end
    end

    @testset "行動選択処理" begin
        @testset "攻撃コマンドが選択されること" begin
            @test RPG.行動選択処理() === :攻撃
        end
    end

    @testset "行動メッセージ処理" begin
        @testset "行動メッセージが出力されること" begin
            RPG.行動メッセージ処理("勇者", "攻撃")
            @test io |> take! |> String === "----------\n勇者の攻撃！\n"
        end
    end

    @testset "ダメージメッセージ処理" begin
        勇者 = RPG.キャラクター("勇者", true, 30, 10, 10)

        @testset "ダメージ量が 0 の場合: ミスのメッセージが出力されること" begin
            RPG.ダメージメッセージ処理(勇者, 0)
            @test io |> take! |> String === "ミス！勇者はダメージを受けなかった\n勇者のHP: 30\n"
        end

        @testset "ダメージ量が 0 より大きい場合: ダメージメッセージが出力されること" begin
            RPG.ダメージメッセージ処理(勇者, 10)
            @test io |> take! |> String === "勇者は 10 のダメージを受けた！\n勇者のHP: 30\n"
        end
    end

    @testset "攻撃ダメージ計算処理" begin
        # 正常ケースの攻撃力, 防御力, ダメージ量
        正常ケース配列 = [
            (攻撃力=10, 防御力=10, ダメージ量=10),
            (攻撃力=14, 防御力=100, ダメージ量=1),
            (攻撃力=15, 防御力=100, ダメージ量=2),
            (攻撃力=0, 防御力=10, ダメージ量=0)
        ]
        for 正常ケース in 正常ケース配列
            @testset "攻撃力: $(正常ケース.攻撃力), 防御力: $(正常ケース.防御力) のとき: ダメージ量: $(正常ケース.ダメージ量) であること" begin
                @test RPG.攻撃ダメージ計算処理(正常ケース.攻撃力, 正常ケース.防御力) === 正常ケース.ダメージ量
            end
        end

        # 例外ケースの攻撃力, 防御力
        例外ケース配列 = [
            (攻撃力=-10, 防御力=10),
            (攻撃力=10, 防御力=-10),
            (攻撃力=-10, 防御力=-10),
            (攻撃力=10, 防御力=0)
        ]
        for 例外ケース配列 in 例外ケース配列
            @testset "攻撃力: $(例外ケース配列.攻撃力), 防御力: $(例外ケース配列.防御力) のとき: 例外が発生すること" begin
                @test_throws DomainError RPG.攻撃ダメージ計算処理(例外ケース配列.攻撃力, 例外ケース配列.防御力)
            end
        end
    end

    @testset "ダメージ処理!" begin
        モンスター = RPG.キャラクター("モンスター", false, 100, 10, 10)

        @testset "1回ダメージを受けたとき: ダメージ分HPが減ること" begin
            RPG.ダメージ処理!(モンスター, 10)
            @test モンスター.HP === 90
        end

        @testset "連続ダメージを受けたとき: ダメージ合計分HPが減ること" begin
            RPG.ダメージ処理!(モンスター, 20)
            RPG.ダメージ処理!(モンスター, 30)
            @test モンスター.HP === 40
        end

        @testset "ダメージ量が0のとき: HPが減らないこと" begin
            RPG.ダメージ処理!(モンスター, 0)
            @test モンスター.HP === 40
        end

        @testset "ダメージ量がマイナスのとき: 例外" begin
            @test_throws DomainError RPG.ダメージ処理!(モンスター, -10)
        end

        @testset "ダメージ量がHPを超えたとき: HPが0になること" begin
            RPG.ダメージ処理!(モンスター, 50)
            @test モンスター.HP === 0
        end
    end

    @testset "大振り攻撃処理!" begin
        勇者 = RPG.キャラクター("勇者", true, 50, 30, 20)
        モンスター = RPG.キャラクター("モンスター", false, 100, 40, 10)

        @testset "60% の確率: 攻撃力の2倍のダメージを与えること" begin
            # RPG.rand() 関数を上書きすることで確率処理の自動テストが可能
            RPG.rand() = 0.59

            RPG.大振り攻撃処理!(勇者, モンスター)
            @test モンスター.HP === 40
            @test io |> take! |> String === """
----------
勇者の大振り攻撃！
モンスターは 60 のダメージを受けた！
モンスターのHP: 40
"""
        end

        @testset "40% の確率: 攻撃が失敗すること" begin
            # RPG.rand() 関数を上書きすることで確率処理の自動テストが可能
            RPG.rand() = 0.60

            RPG.大振り攻撃処理!(勇者, モンスター)
            @test モンスター.HP === 40
            @test io |> take! |> String === """
----------
勇者の大振り攻撃！
ミス！モンスターはダメージを受けなかった
モンスターのHP: 40
"""
        end
    end
end
