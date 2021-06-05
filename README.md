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
    - [ ] 配列の添字が 1 から始まる
    - [ ] 活発に開発されており、バージョンにより言語仕様が大きく変わることがある

***

## Setup

- Setup for Windows 10: [Julia 1.6.1 on Windows 10](./SetupWindows.md)
- Setup for Ubuntu 20.04: [Julia 1.6.1 on Ubuntu 20.04](./SetupUbuntu.md)
- Setup for Docker: [Julia 1.6.1 on Docker](./SetupDocker.md)

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

## 機械学習入門

See jupyter notebooks in [02_machine-learning](./02_machine-learning/).
