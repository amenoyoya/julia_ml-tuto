# Julia and Machine Learning tutorial

## What's Julia?

- **Julia**(ジュリア)
    - [x] 汎用プログラミング言語水準から高度の計算科学や数値解析水準まで対処するよう設計された高水準言語かつ仕様記述言語、及び動的プログラミング言語
    - [x] 標準ライブラリがJulia自身により作成されており、コア言語は極めてコンパクト
    - [x] オブジェクトの構築または記述する型の種類が豊富にある
    - [x] マルチディスパッチにより、引数の型の多くの組み合わせに対して関数の動作を定義することが可能
    - [x] 異なる引数の型の効率的な特殊コードの自動生成が可能
    - [x] C言語のような静的にコンパイルされた言語を使用しているかのような高いパフォーマンスを発揮する
    - [x] フリーオープンソース（MITライセンス）
    - [x] ユーザ定義の型は既存の型と同じくらい早くコンパクト
    - [x] 非ベクトル化コード処理が早いため、パフォーマンス向上のためにコードをベクトル化する必要がない
    - [x] 並列処理と分散計算ができるよう設計
    - [x] 軽く「エコ」なスレッド（コルーチン）
    - [x] 控えめでありながら処理能力が高いシステム
    - [x] 簡潔かつ拡張可能な数値および他のデータ型のための変換と推進
    - [x] 効率的なUnicodeへの対応（UTF-8を含む）
    - [x] C関数を直接呼び出すことが可能（ラッパーや特別なAPIは不要）
    - [x] 他のプロセスを管理するための処理能力が高いシェルに似た機能
    - [x] Lispに似たマクロや他のメタプログラミング機能
    - [ ] JITコンパイラで事前ビルドされるため、起動が遅い
        - 基本的に研究目的で使われるため、JupyterLab 等で常時起動状態で使われるのが現状の最適解
        - PackageCompiler.jl など、あらかじめコンパイルして高速化するプロジェクトが頑張っている

***

## Setup

### Julia 1.6.1
- Setup for Windows 10: [Julia 1.6.1 on Windows 10](./setup/SetupWindows.md)
- Setup for Ubuntu 20.04: [Julia 1.6.1 on Ubuntu 20.04](./setup/SetupUbuntu.md)
- Setup for Docker: [Julia 1.6.1 on Docker](./setup/SetupDocker.md)

### Julia 1.7.2 with 機械学習環境
- [Julia 1.7.2 with 機械学習環境](./setup/SetupDeepLearning.md)

***

## Get Started

### REPL
`julia`コマンドで対話型セッション（REPL）を起動できる

```bash
$ julia

# REPL
julia> 1 + 2
3

# 最後に評価された式の結果は ans 変数に格納されている
julia> ans
3

# 終了するには ^D (Ctrl + D) or `exit()`
julia> quit()
```

### コマンドライン
Juliaのソースコードは `.jl`ファイルに記述される

jlファイルを実行するには以下のコマンドを叩く

```bash
# execute script.jl
$ julia script.jl

# コマンドライン引数を指定することもできる
## コマンドライン引数は グローバル変数 ARGS に渡される
## スクリプト自体の名前は グローバル変数 PROGRAM_FILE に渡される
$ julia script.jl arg1 arg2 ...
```

`-e`オプションでコマンドライン引数に渡された式をそのまま実行することも可能

```bash
# スクリプトの名前を出力
$ julia -e 'println(PROGRAM_FILE)'
## => スクリプトファイルを実行しているわけではないため、何も出力されない

# コマンドライン引数を順に出力
$ julia -e 'for arg in ARGS; println(arg); end' hello world
hello
world
```

***

## Tutorial

See jupyter notebooks in [01_tutorial](./01_tutorial/).

***

## パッケージ開発

### 雛形作成
```bash
$ julia

julia> using Pkg

# execute `generate` Pkg command
julia> Pkg.generate("./EventUtils")

## => ./EventUtils/ template package directory will be generated
```

#### Structure
```bash
$PackageName/
|_ src/
|  |_ $PackageName.jl
|
|_ Project.toml
```

#### Project.toml
```javascript Project.toml
name = "$(PackageName)"
uuid = "$(using UUIDs; string(uuid1()))"
authors = ["$(YourName) <$(YourEmail)>"]
version = "0.1.0"
```

### パッケージ開発
パッケージ開発時は、最初に `Revise.jl` を読み込んでおくと良い

- [Revise.jl](https://github.com/timholy/Revise.jl) 
    - Julia環境を再起動せずにコードの変更を即時反映するパッケージ
    - `using` で読み込んだ開発中のパッケージに変更を加えたとき、REPL環境を再起動せずにその場で実行確認できる

```bash
julia> using Pkg
julia> Pkg.add("Revise")

# Revise.jl を使う
julia> using Revise

# 開発中のパッケージを読み込む
## add ではなく develop コマンドを使うと、ローカルパッケージをインストールできる
julia> Pkg.develop(path="./EventUtils")
julia> using EventUtils

# => 以降 ./EventUtils/src/*.jl でパッケージ開発を行うと REPL 環境に即座に変更が反映される

# 開発が完了したら free コマンドでローカルパッケージを削除する
# > Pkg.free("EventUtils")
## 正式版のパッケージを add コマンドで追加していない場合は free コマンドは失敗するため、通常通り rm コマンドで削除する
## > Pkg.rm("EventUtils")
```

#### src/EventUtils.jl
```julia src/EventUtils.jl
module EventUtils

#################################
# module EventUtils.EventEmitter #
#################################
export EventEmitter, on!, remove!, emit

"type EventEmitter = Dict(:eventName => [event1(), event2(), ...])"
const EventEmitter = Dict{Symbol, Vector{Function}}

"""
    on!(self::EventEmitter, eventName::Symbol, eventFunction::Function)

Append an event function corresponding to the event name.
"""
on!(self::EventEmitter, eventName::Symbol, eventFunction::Function) = haskey(self, eventName) ?
    push!(self[eventName], eventFunction) :
    self[eventName] = [eventFunction]

"""
    remove!(self::EventEmitter, eventName::Symbol)

Remove all events corrensponding to the event name.
"""
remove!(self::EventEmitter, eventName::Symbol) = haskey(self, eventName) && pop!(self, eventName)

"""
    emit(self::EventEmitter, arguments...)

Emit events corresponding to the event name.
"""
emit(self::EventEmitter, eventName::Symbol, arguments...) = haskey(self, eventName) && map(self[eventName]) do event event(arguments...) end

end # module
```

### 依存パッケージのインストール
新規作成したパッケージは独立した環境を持つため、そのパッケージ環境で使える依存パッケージを登録する場合は `Pkg.activate` コマンドを実行した上で依存パッケージを追加する必要がある

```bash
# 開発中のパッケージ環境に切り替える
julia> Pkg.activate("EventUtils")
  Activating project at `/path/to/EventUtils`

# 依存パッケージを追加する
## 単体テスト用に Test.jl はどのプロジェクトでも入れておいたほうが良い
julia> Pkg.add("Test")

## => ./EventUtils/Project.toml, ./EventUtils/Manifest.toml に依存パッケージ情報が登録される

# グローバル環境に戻す
julia> Pkg.activate()
```

### 単体テストの追加
単体テストは `$PackageName/test/runtests.jl` に記述する

※ あらかじめ、パッケージ環境内で `Test.jl` は追加しておくこと

#### test/runtests.jl
```julia test/runtests.jl
using Test, EventUtils

@testset "EventUtils.EventEmitter" begin
    event = EventEmitter()

    # register 2 functions to :test event.
    on!(event, :test, array -> push!(array, 1))
    on!(event, :test, array -> push!(array, 2))

    @test haskey(event, :test)

    # call :test events.
    array = Vector{Int}()
    @test emit(event, :test, array) == [[1, 2], [1, 2]]
    @test array == [1, 2]

    # remove :test events.
    remove!(event, :test)
    @test !haskey(event, :test)
end
```

#### テスト実行
```bash
julia> Pkg.test("EventUtils")

Test Summary:           | Pass  Total
EventUtils.EventEmitter |    4      4
     Testing EventUtils tests passed 
```

***

## 機械学習入門

See jupyter notebooks in [02_machine-learning](./02_machine-learning/).
