# julia-tuto

Julia入門

## What's Julia?
- **JUlia**(ジュリア)
    - 汎用プログラミング言語水準から高度の計算科学や数値解析水準まで対処するよう設計された高水準言語かつ仕様記述言語、及び動的プログラミング言語
    - 標準ライブラリがJulia自身により作成されており、コア言語は極めてコンパクト
    - オブジェクトの構築または記述する型の種類が豊富にある
    - マルチディスパッチにより、引数の型の多くの組み合わせに対して関数の動作を定義することが可能
    - 異なる引数の型の効率的な特殊コードの自動生成が可能
    - C言語のような静的にコンパイルされた言語を使用しているかのような高いパフォーマンスを発揮する
    - フリーオープンソース（MITライセンス）
    - ユーザ定義の型は既存の型と同じくらい早くコンパクト
    - 非ベクトル化コード処理が早いため、パフォーマンス向上のためにコードをベクトル化する必要がない
    - 並列処理と分散計算ができるよう設計
    - 軽く「エコ」なスレッド（コルーチン）
    - 控えめでありながら処理能力が高いシステム
    - 簡潔かつ拡張可能な数値および他のデータ型のための変換と推進
    - 効率的なUnicodeへの対応（UTF-8を含む）
    - C関数を直接呼び出すことが可能（ラッパーや特別なAPIは不要）
    - 他のプロセスを管理するための処理能力が高いシェルに似た機能
    - Lispに似たマクロや他のメタプログラミング機能

***

## Setup

### Environment
- OS:
    - Ubuntu 18.04 LTS
    - Windows 10
- Python: `3.7.3` (Miniconda `4.7.10`)
    - Jupyter Notebook: `6.0.0`

---

### Installation
[公式サイト](https://julialang.org/downloads/)の手順に従う

#### Installation in Ubuntu
```bash
# install in home directory
$ cd ~

# download julia-1.1.1
$ wget -O - https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.1-linux-x86_64.tar.gz | tar zxvf -

# create symbolic link to /usr/local/bin/ => enable `julia` command
$ sudo ln -s ~/julia-1.1.1/bin/julia /usr/local/bin/julia

# confirm version
$ julia -v
julia version 1.1.1
```

#### Installation in Windows
管理者権限のPowerShellで以下を実行

```powershell
# chocolateyパッケージマネージャを入れていない場合は導入する
> Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install julia
> choco install -y julia

# confirm version
> julia -v
julia version 1.1.1
```

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

---

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

---

### Jupyter Notebook で使う

#### Jupyter Notebook のインストール
```bash
# install python (Miniconda)
$ wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
$ chmod +x ./Miniconda3-latest-Linux-x86_64.sh
$ ./Miniconda3-latest-Linux-x86_64.sh

# clean up
$ rm ./Miniconda3-latest-Linux-x86_64.sh

# confirm conda version
$ conda -V
conda 4.7.10

# install jupyter notebook
$ conda install jupyter
```

#### Jupyter Notebook 用のJuliaカーネルのインストール
```bash
# REPL起動
$ julia

julia> # `]` キーを叩いてパッケージモードに移行

# IJuliaパッケージをインストール
(v1.1) pkg> add IJulia

# => インストールされたら Ctrl + D でREPL終了

# jupyter notebook のカーネルを確認
$ jupyter kernelspec list
Available kernels:
  julia-1.1    /home/user/.local/share/jupyter/kernels/julia-1.1   # <- Juliaが使えるようになっている
  python3      /home/user/miniconda3/share/jupyter/kernels/python3
```

#### Jupyter Notebook 起動
```bash
$ jupyter notebook
# => localhost:8888 で Jupyter Notebook 起動
```

Juliaを使うには `New` > `Julia 1.1.1` を選択する
