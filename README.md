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
- OS: Ubuntu 18.04 LTS

---

### Installation
[公式サイト](https://julialang.org/downloads/)の手順に従う

```bash
# install in home directory
$ cd ~

# download julia-1.1.1
$ wget -O - https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.1-linux-x86_64.tar.gz | tar zxvf -

# export path
$ echo '
export PATH="$PATH:$HOME/julia-1.1.1/bin"
' >> ~/.profile

$ source ~/.profile

# confirm version
$ julia -v
julia version 1.1.1
```
