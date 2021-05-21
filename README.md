# julia-tuto

Julia入門

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

## Environment

- OS: Windows 10 (or Linux + Docker 環境)
- GPU: nVidia RTX 2060
- Shell: PowerShell
- PackageManager: Chocolatey 0.10.15
- Julia: 1.6.1
    - Anaconda: 1.5.2
        - JupyterLab: 3.0.15

### Setup
`Win + X` |> `A` => 管理者権限 PowerShell 起動

```powershell
# chocolateyパッケージマネージャを入れていない場合は導入する
> Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Julia インストール
> conda install -c conda-forge julia

# => 環境変数を反映するために一度 PowerShell 再起動

# Julia バージョン確認
> julia -v
julia version 1.6.1

# Julia REPL 起動
> julia

# PyCall, Conda パッケージインストール
## PyCall: Julia から Python を使うためのモジュール
## Conda: Anaconda python 環境を Julia 内に作成するモジュール
## * PyCall をインストールすれば Conda は自動的に入るかもしれない

# `]` キーでパッケージモードに切り替え
julia> ]

pkg> add PyCall
pkg> add Conda

# Ctrl + C => パッケージモード終了
pkg> ^C

# Conda で JupyterLab インストール
## JupyterLab: Jupyter Notebook の後継
## * Jupyter Notebook: ノートブック形式でデータを可視化しながらプログラミング言語（主にPython）を実行できるIDE環境
# $ conda install -y -c conda-forge jupyterlab
julia> using Conda
julia> Conda.add("jupyterlab"; channel="conda-forge")

# JupyterLab で Julia カーネルを使えるようにするため IJulia パッケージインストール
julia> ]
pkg> add IJulia
pkg> ^C

# 一旦 Julia REPL 終了
julia> exit()

# ユーザ環境変数 PATH に Anaconda in Julia の PATH 追加
> [System.Environment]::SetEnvironmentVariable("PATH", [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";${ENV:USERPROFILE}\.julia\conda\3\Scripts;${ENV:USERPROFILE}\.julia\conda\3\Library\bin", "User")

# => 環境変数を反映するために一度 PowerShell 再起動

# Jupyter カーネル確認
> jupyter kernelspec list
Available kernels:
  julia-1.6    C:\Users\<ユーザ名>\AppData\Roaming\jupyter\kernels\julia-1.6 # <= IJulia
  python3      C:\Users\<ユーザ名>\.julia\conda\3\share\jupyter\kernels\python3

# JupyterLab 起動
## * 実行ポート: 8888
## * token不要
## * Project.toml へのパス: ./
###  + --project=<Project.tomlへのパス> を指定することで対応する仮想環境で作業できるようになる
###  + 指定しない場合、デフォルトのグローバル環境で作業することになるため、環境を汚してしまうデメリットがある
> jupyter lab --port=8888 --ServerApp.token='' --project=@.

# => http://localhost:8888/lab で JupyterLab が開く
```

![jupyterlab.png](./img/jupyterlab.png)

Juliaのプログラムを実行できるノートを新規作成するためには `+` > `Notbook` > `Julia 1.6.1` を選択する 

***

## Dockerによる環境構築

### Structure
```bash
./ # カレントディレクトリ = 作業ディレクトリ (docker://app:/work/)
|_ .env # 環境変数設定ファイル
|_ Dockerfile # appコンテナビルド設定
|_ docker-compose.yml # docker構成ファイル
|_ Manifest.toml # Juliaプロジェクト依存パッケージ設定ファイル
|_ Project.toml  # Juliaプロジェクト設定ファイル
|_ x # docker関連CLI
```

### Setup
```bash
# enable execution permission to cli interface
$ chmod +x ./x

# build all docker containers
$ ./x build

# execute all docker containers
$ ./x up -d

# appコンテナ起動確認
$ ./x logs -f app

# => 初回起動時は Julia パッケージのインストールに時間がかかる
# => JupyterLab の起動メッセージを確認できたら Ctrl + C で抜ける
```

### Docker containers
- networks:
    - **appnet**: All docker containers belong to this network.
- services:
    - **app**: `julia:1.6.1-buster`
        - Julia + JupyterLab server container.
        - routes:
            - HTTP(S): http://localhost:${JUPYTER_PORT:-8888} => http://app:8888

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
