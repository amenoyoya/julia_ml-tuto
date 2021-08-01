## 関数

- **関数**
    - 複数の値を受け取り、戻り値を返すオブジェクト
    - Juliaにおける関数はグローバルな状態に影響を受け得るため、純粋に数学的な関数ではない
- 参照透過性
    - 同じ引数を受け取ったら必ず同じ戻り値を返すという性質
    - プログラムの見通しを良くするためには、グローバルな状態に影響されない純粋な関数を定義するべきである

### 関数の定義
Juliaでは、単一の式を定義する方法と、`function`キーワードを用いて複数の式を手続き的に処理する関数を定義する方法がある

ただし、プログラムは **そのコードの意図をシンプルに記述する** ことが望ましいため、基本的には単一式の関数定義を用いるべきである


```julia
# 2つの引数 x, y を受け取って、その合計値を返す関数

## 代入方式（単一の式を定義）
f(x, y) = x + y

## 関数呼び出し
println(f(1, 2)) # f(1, 2) = 1 + 2 -> 3

## 複数の手続きを定義する関数
### メッセージを出力してから 合計値を返す
function g(x, y)
    println("$x と $y を足すよ！")
    println("答えは $(x + y) だね！")
    x + y
end

println(g(9, 8))
```

    3
    9 と 8 を足すよ！
    答えは 17 だね！
    17



```julia
# コードの意図

# 上記のg関数は、メッセージの出力2回と足し算処理1回という3つの処理を行っている
## -> 意図が明確ではない
## -> 良いコードを書くためには、その関数が何を目的としているのか記述することが重要

# ---

# 自己記述的でシンプル・明確なコード

## 2つの引数 x, y の足し算を行う関数
add(x, y) = x + y

## 2つの引数 x, y の足し算を行うことをメッセージとして出力する関数
printMessageForAdding(x, y) = println("$x と $y を足すよ！")

## 引数 x が答えであることをメッセージとして出力する関数
printMessageForAnswer(x) = println("答えは $x だね！")

## 上記関数を一連の処理として実行
main = begin
    x = 100
    y = 23
    printMessageForAdding(x, y)
    a = add(x, y)
    printMessageForAnswer(a)
    a
end
```

    100 と 23 を足すよ！
    答えは 123 だね！





    123




```julia
# 複合式

# 上記のように begin ... end で複数の式を手続き的に処理できる
## -> (式1; 式2; ...) とも記述できる

main = (
    x = 100;
    y = 23;
    printMessageForAdding(x, y);
    a = add(x, y);
    printMessageForAnswer(a);
    a
)
```

    100 と 23 を足すよ！
    答えは 123 だね！





    123




```julia
# 参照透過性について

## グローバルな状態に影響を受ける関数は、バグを生み出しやすい

# -- 悪い例 --
state = 1 # グローバル状態: 1

## xにグローバル状態を掛ける関数
f(x) = x * state

## 呼び出す
println(f(10)) # (10) = 10 * 1 -> 10

## 誰かがグローバル状態を変更
state = 100

## f()呼び出し: 前回と同じように 10 が返ってくることを期待
println(f(10)) # グローバル状態が変わっているため 1000 が返ってしまう
```

    10
    1000



```julia
# -- 参照透過的な例 --

## x と y を掛ける関数
mul(x, y) = x * y

## mul関数は、同じ引数を渡せば必ず同じ結果が返ってくる
### -> バグが発生しにくい

println(mul(10, 1)) # (10, 1) = 10 * 1 -> 10

# 上記と同じ結果を期待すれば同じ結果が返ってくる
println(mul(10, 1)) # (10, 1) = 10 * 1 -> 10
```

    10
    10


### return キーワード

Juliaにおいて **関数の戻り値は、その関数内で最後に評価された式の結果** となる

この挙動を変えたい場合は `return` キーワードを使うことで、戻り値を明示することができる

なお、 `return`された時点でその関数の評価は終わるため、それ以降の処理は実行されない


```julia
function g(x, y)
    x * y
    x + y # <- 最後に評価される x + y の結果が返る
end

g(2, 3) # (2, 3) = 2 + 3 -> 5
```




    5




```julia
function g(x, y)
    return x * y # <- ここで評価終了: x * y の結果が返る
    x + y # <- この式は評価されない
end

g(2, 3) # (2, 3) = 2 * 3 -> 6
```




    6



### 関数として定義されている演算子
Juliaにおいて、`&&`や`||`のような短絡評価演算子以外は、全て関数として定義されている

例えば `+`演算子は、2つの引数を加算した値を返す関数である

これらの演算子は、その演算子の直前と直後の値を引数に取る関数であるため、**中置記法関数**と呼ばれる


```julia
# 中置記法関数としての `+`
println(1 + 2 + 3) # -> 6

# `+` は、通常の関数と同じ呼び出し方もできる
println(+(1, 2, 3)) # -> 6
```

    6
    6



```julia
# 他の名前の関数としても定義することは可能だが、中置記法には対応していない
sub = -

# OK: 10 - 1 -> 9
sub(10, 1)
```




    9




```julia
# 中置記法はNG
10 sub 1
```


    syntax: extra token "sub" after end of expression

    

    Stacktrace:

     [1] top-level scope

       @ In[10]:2

     [2] eval

       @ ./boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base ./loading.jl:1094


### 無名関数
Juliaにおいて、関数は第一級オブジェクトである

- 関数は、変数に代入したり、代入した変数から標準的な構文で呼び出すことが可能
- 関数の引数としても、戻り値としても関数を使うことができる
- 名前をつけずに無名で生成することもできる（無名関数）

無名関数は以下のような記法で記述することができる

```julia
(引数, ...) -> 式
```


```julia
x -> x^2 + 2x - 1
```




    #1 (generic function with 1 method)




```julia
function (x)
    x^2 + 2x - 1
end
```




    #3 (generic function with 1 method)




```julia
# 無名関数は主に別の関数を引数とする関数に渡すために使用される

# 例: map関数: 配列の各要素に対して渡された関数を適用する関数
## 配列 [1, 2, 3] の各要素を二乗する
map(x -> x^2, [1, 2, 3])
```




    3-element Vector{Int64}:
     1
     4
     9




```julia
# 単一の式ではなく、複数の処理をまとめて書きたい場合は begin ... end ブロックでくくる
map(x -> begin
        ans = x^2
        println("$x^2 = $ans")
        return ans
    end, [1, 2, 3])
```

    1^2 = 1
    2^2 = 4
    3^2 = 9





    3-element Vector{Int64}:
     1
     4
     9



### 複数の戻り値
Juliaの関数は一つの値しか返さない

しかし、タプル（別の型を入れることのできる配列）を使うことで擬似的に複数の値を返すことができる

Juliaのタプルはカッコを使わずに生成・分解が可能なため、見た目上は複数の戻り値を扱っているように見える


```julia
# (a+b, a-b)というタプルを返す関数
add_sub(a, b) = a + b, a - b

# 以下の戻り値は (3, -1) というタプルになる
x = add_sub(1, 2)
println(x)

# カンマ区切りでタプルの分解が可能なため、次のように書くことも可能
added, subed = add_sub(1, 2)
println(added) # -> 3
println(subed) # -> -1
```

    (3, -1)
    3
    -1


### 可変長引数
引数の最後の変数の後ろに省略記号 `...` を指定することで、任意の数の引数をとることができるようになる

省略記号を付与された引数はタプルとして展開される


```julia
p(x, y, vargs...) = println("$x + $y = $(x + y)\n$(vargs)")
p(1, 2, 3, 4, 5)
```

    1 + 2 = 3
    (3, 4, 5)



```julia
# 引数を省略する別の方法としてオプション引数も使える

# 文字列 str を n進数（デフォルト = 10進数）の整数に変換する関数
parseInt(str, n=10) = parse(Int, str, base=n)

## 引数を省略した場合はデフォルトの値が使われる
println(parseInt("10")) # "10" -> 10進数: 10

## 引数を指定することもできる
println(parseInt("10", 16)) # "10" -> 16進数: 16
```

    10
    16



```julia
# 多数の引数をとり、その順番を覚えにくい関数に対してはキーワード引数が使える
## -> 引数の指定をキーワードで行うことができる
## 関数宣言を行う行で `;` 以降にキーワード引数を定義する

# x, y を加算する関数
## オプション:
### showAddingMessageキーワード: trueなら加算することを宣言するメッセージを表示
### showAnswerMessageキーワード: trueなら計算結果のメッセージを表示
function addWithShowingMessage(x, y; showAddingMessage=false, showAnswerMessage=false)
    if showAddingMessage
        printMessageForAdding(x, y)
    end
    a = add(x, y)
    if showAnswerMessage
        printMessageForAnswer(a)
    end
    a
end

# 計算結果のメッセージ付きで加算関数を実行
## 100 + 99 -> 199
addWithShowingMessage(100, 99, showAnswerMessage=true)
```

    答えは 199 だね！





    199




```julia
# キーワード引数に対して省略記号を付与することも可能

function addWithShowingMessage(x, y; kwargs...)
    # 省略記号を付与されたキーワード引数はシンボルの添字で取得可能
    if kwargs[:showAddingMessage]
        printMessageForAdding(x, y)
    end
    a = add(x, y)
    if kwargs[:showAnswerMessage]
        printMessageForAnswer(a)
    end
    a
end

addWithShowingMessage(3.14, 0.86, showAddingMessage=true, showAnswerMessage=false)
```

    3.14 と 0.86 を足すよ！





    4.0



### do ブロック構文
関数を引数をとる関数を使うとき、引数に渡す関数が複数行に渡る場合は記述が複雑になりがちである

そのような場合は、`do`ブロックを使うとシンプルに書ける


```julia
# 普通に書くと以下のように 無名関数を beginブロックでくくることになる

# 配列の各要素に対して以下の処理を施す
## 偶数の場合は2倍にする
## 基数の場合は3倍にする
map(x->begin
        if x % 2 == 0
            return x * 2
        else
            return x * 3
        end
    end,
    [1, 2, 3, 4, 5]
)
```




    5-element Vector{Int64}:
      3
      4
      9
      8
     15




```julia
# doブロックは、無名関数を生成し、直前にある関数の第一引数に渡す
## -> シンプルに書ける

map([1, 2, 3, 4, 5]) do x
    if x % 2 == 0
        return x * 2
    else
        return x * 3
    end
end
```




    5-element Vector{Int64}:
      3
      4
      9
      8
     15




```julia
# ファイルを開いて処理を行った後、ファイルを閉じる関数
fopen(callback, filename, mode="r") = begin
    io = open(filename, mode)
    try
        callback(io)
    finally
        close(io)
    end
end

# ../.gitignore を読み込んで 内容を出力する
fopen("../.gitignore") do io
    println(read(io, String))
end
```

    .ipynb_checkpoints/
    


### ドット構文
- **関数のベクトル化**
    - 既存の関数を配列の各要素に適用して新しい配列を作ること
    - Juliaにおける map関数

Juliaでは、関数のベクトル化を行うのに `map`関数を使う以外の方法として、ドット構文が用意されている

```julia
関数 . (配列)
# -> map(関数, 配列)
```


```julia
f(x) = 3x

A = [1, 2, 3]
B = [4, 5, 6]

# map(f, A, B)
## 3 * [1, 2, 3] + 4 * [4, 5, 6]
## -> [19, 26, 33]
f.(A, B)
```




    3-element Vector{Int64}:
     5
     7
     9



### パイプ処理
ほとんどの関数型言語はパイプライン処理をサポートしているが、Juliaも同様に、パイプ演算子を使った関数の連鎖が可能である

Juliaのパイプ演算子は `|>` であり、左辺の戻り値を直接、右辺にある関数の引数に渡すことができる


```julia
# [3, 2, 1, 1, 3, 2, 4] を昇順並び替え => 重複削除
vec = unique(sort([3, 2, 1, 1, 3, 2, 4]))
println(vec) # => [1, 2, 3, 4]

# パイプ演算子でチェイン形式で記述
vec = [3, 2, 1, 1, 3, 2, 4] |> sort |> unique
println(vec) # => [1, 2, 3, 4]
```

    [1, 2, 3, 4]
    [1, 2, 3, 4]



```julia

```
