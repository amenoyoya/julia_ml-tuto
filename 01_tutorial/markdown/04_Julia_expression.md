## 制御構文

Juliaには以下の6つの制御構文がある

1. 複合式
    - `begin ... end`
    - `(...; ...; ...)`
2. 条件評価
    - `if ... elseif ... else ... end`
    - 三項演算子: `... ? ... : ...`
3. 短絡評価
    - `&&`, `||`, 比較演算子 の連鎖
4. 繰り返し評価
    - `while ... end`
    - `for ... end`
5. 例外処理
    - `try ... catch ... finally ... end`
    - `error()`, `throw()`
6. タスク（コルーチン）
    - `yieldto()`

### 複合式
複数の部分式を手続き的に評価していき、最後の式の値を戻り値とする式


```julia
# beginブロックによる複合式
z = begin
    x = 1
    y = 2
    x + y
end
```




    3




```julia
# (;)連鎖構文による複合式
z = (x = 1; y = 2; x + y)
```




    3



### 条件評価
条件評価では、与えられたブール式の値に応じて、特定のコードのみを実行することが可能

条件により評価される式が分岐するため、これを **条件分岐** と呼ぶ


```julia
# 2つの引数 x, y をとり、メッセージ文字列を返す関数
## 返される文字列は以下の条件で分岐する
### x < y -> "$x is less than $y"
### x > y -> "$x is larger than $y"
### 上記以外(x == y) -> "$x is equal to $y"
test(x, y) = begin
    if x < y
        "$x is less than $y"
    elseif x > y
        "$x is larger than $y"
    else
        "$x is equal to $y"
    end
end

# 動作確認
println(test(1, 2)) # -> "1 is less than 2"
println(test(1, 0)) # -> "1 is larger than 0"
println(test(1, 1)) # -> "1 is equal to 1"
```

    1 is less than 2
    1 is larger than 0
    1 is equal to 1



```julia
# ifブロックの変数スコープは、ローカルスコープではない
# -> ifブロック内で定義した変数を ifブロックの後ろで使用することが可能

printTest(x, y) = begin
    if x < y
        rel = "less than"
    elseif x > y
        rel = "larger than"
    else
        rel = "equal to"
    end
    println("$x is $rel $y")
end

printTest(1, 2)
printTest(1, 0)
printTest(1, 1)
```

    1 is less than 2
    1 is larger than 0
    1 is equal to 1


#### 三項演算子
三項演算子は以下のような形式で記述される

```julia
a ? b : c
```

上記の式は、`a`が`true`の場合に`b`を評価し、`false`なら`c`を評価する


```julia
age = 13

# ageが18未満なら "未成年", 18以上なら "青年" を出力
println(age < 18 ? "未成年" : "成人")
```

    未成年


### 短絡評価
短絡評価とは `&&` や `||` で連結されたブール式の評価のことである

このとき、評価されるのは式全体のブール値のブール値を決定する最小限のものだけなので、以下のような評価がなされる

- `a && b`という式で、bが評価されるのは、aが`true`の場合のみ
    - aが`false`であれば、その時点でこの式は`false`であることが決定されるため
- `a || b`という式で、bが評価されるのは、aが`false`の場合のみ
    - aが`true`であれば、その時点でこの式は`true`であることが決定されるため

`&&`, `||` はともに、右から結合されるが、優先順位は `&&` > `||` である


```julia
# Juliaでは条件評価(ifブロック)の代わりに短絡評価が頻繁に利用される
## 条件評価: if <条件式> <実行文> end   if ! <条件式> <実行文> end
## -> 短絡評価: <条件式> && <実行文>   <条件式> || <実行文>

# Int型の引数 n の階乗を返す関数
## 以下のように条件分岐しながら計算
### n < 0 -> Error
### n == 0 -> 1
### 上記以外 -> n * self(n - 1)
fact(n::Int) = begin
    n < 0 && error("階乗を計算する場合は正の整数を指定してください")
    n == 0 && return 1
    n * fact(n - 1)
end

# 動作確認
## 5! = 5 * 4 * 3 * 2 * 1 -> 120
println(fact(5))

## 0! -> 1
println(fact(1))

## -5! -> Error
println(fact(-5))
```

    120
    1



    階乗を計算する場合は正の整数を指定してください

    

    Stacktrace:

     [1] error(s::String)

       @ Base .\error.jl:33

     [2] fact(n::Int64)

       @ Main .\In[6]:11

     [3] top-level scope

       @ In[6]:24

     [4] eval

       @ .\boot.jl:360 [inlined]

     [5] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094


### 繰り返し評価
式を繰り返し評価する制御構造は以下の2つがある

1. `while`ブロック
    ```julia
    # 条件式の評価結果が true である限り繰り返し実行する
    while <条件式>
        <実行式>
    end
    ```
2. `for`ブロック
    ```julia
    # <イテレータ式>を順に実行する
    for <イテレータ式>
        <実行式>
    end
    ```


```julia
i = 1

# 変数 i が 5 以下である限り実行する
while i <= 5
    println(i)
    i += 1
end
```

    1
    2
    3
    4
    5



```julia
# forブロック イテレータ式
## <変数> = <開始値> : <終了値>

# 変数 i に 1〜5 を順に適用して実行
for i = 1:5
    println(i)
end

# forブロックでは、変数はローカルスコープである
# -> ブロックの後ろでforブロックの変数を使うことはできない
```

    1
    2
    3
    4
    5



```julia
# forブロック イテレータ式
## <変数> in <配列>
## <変数> ∈ <配列>

# 変数 i に [1, 4, 0] の各要素を順に適用して実行
## for i ∈ [1, 4, 0] でも可
for i in [1, 4, 0]
    println(i)
end
```

    1
    4
    0



```julia
# ループの途中で評価を終了する場合は break
for i = 1:1000 # 1〜1000 まで実行
    println(i)
    i >= 5 && break # i が 5以上になったらループ終了
end
```

    1
    2
    3
    4
    5



```julia
# 次の繰り返しにすぐに移りたい場合は continue

# 1〜10のうち3の倍数である数値のみ出力する
for i = 1:10
    i % 3 != 0 && continue # i が 3の倍数でないならスキップ
    println(i)
end
```

    3
    6
    9



```julia
# 複数のネストしているforブロックは結合できる
# -> イテラブル型の直積に対するループに変換することができる

# 1〜2 それぞれに対して 3〜4 のループ評価する場合

println("ネストした複数のforブロック")
for i = 1:2
    for j = 3:4
        println((i, j))
    end
end

println("\nイテラブル型の直積")
for i = 1:2, j = 3:4
    println((i,j))
end
```

    ネストした複数のforブロック
    (1, 3)
    (1, 4)
    (2, 3)
    (2, 4)
    
    イテラブル型の直積
    (1, 3)
    (1, 4)
    (2, 3)
    (2, 4)


### 例外処理
予想外の状態が発生した場合、関数の実行を途中で終了し、例外が起こったことを知らせる必要がある

例外が起こった際の対応は、プログラマに委ねられるため、本来例外が発生するようなプログラムは作成するべきではない

しかし、プログラムの使用者が想定外の操作をしたり、ハードウェア的なハプニングが起こったりすることを完全に防ぐことはできないため、ほとんどの言語には例外機構が備わっている

#### Julia標準の例外
- ArgumentError
- BoundsError
- CompositeException
- DivideError
- DomainError
- EOFError
- ErrorException
- InexactError
- InitError
- InterruptException
- InvalidStateException
- KeyError
- LoadError
- OutOfMemoryError
- ReadOnlyMemoryError
- RemoteException
- MethodError
- OverflowError
- ParseError
- SystemError
- TypeError
- UndefRefError
- UndefVarError
- UnicodeError

#### 独自の例外の定義
Julia標準の例外以外に自分で例外を作成することもできる

例外の定義は以下のような式で行う

```julia
struct 例外名 <: Exception
    <定義>
end
```


```julia
# 例外は throw関数を使って意図的に発生させることができる

# 引数が正の場合は、それを出力する関数
## 負の場合は、DomainErrorを投げる
f(x) = x >= 0 ? println(x) : throw(DomainError(x))

# 動作確認
f(1)
f(-1)
```

    1



    DomainError with -1:


    

    Stacktrace:

     [1] f(x::Int64)

       @ Main .\In[13]:5

     [2] top-level scope

       @ In[13]:9

     [3] eval

       @ .\boot.jl:360 [inlined]

     [4] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
# error関数を使えば、ErrorExceptionを生成し、通常の制御の流れを中断することができる

# 引数が正の場合は、それを出力する関数
## 負の場合は、エラーメッセージを出力してプログラム停止
f(x) = x >= 0 ? println(x) : error("正の値を指定してください")

# 動作確認
f(1)
f(-1)

# 例外が発生すると以降の処理は実行されない
f(3)
```

    1



    正の値を指定してください

    

    Stacktrace:

     [1] error(s::String)

       @ Base .\error.jl:33

     [2] f(x::Int64)

       @ Main .\In[14]:5

     [3] top-level scope

       @ In[14]:9

     [4] eval

       @ .\boot.jl:360 [inlined]

     [5] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
# 例外的な状況ではないが、警告や情報を標準エラー出力に出力したい場合
## @info, @warn マクロが使える
## -> 例外を投げないため実行が中断されない

# 情報メッセージを出力 -> 処理継続
@info "Hi"
println(1 + 1)

# 警告メッセージを出力 -> 処理継続
@warn "Hi"
println(1 + 1)

# エラーメッセージを出力 -> 処理停止
error("Hi")
println(1 + 1) # <- 実行されない
```

    2
    2


    ┌ Info: Hi
    └ @ Main In[15]:6
    ┌ Warning: Hi
    └ @ Main In[15]:10



    Hi

    

    Stacktrace:

     [1] error(s::String)

       @ Base .\error.jl:33

     [2] top-level scope

       @ In[15]:14

     [3] eval

       @ .\boot.jl:360 [inlined]

     [4] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
# なお @error マクロはエラーメッセージを出力するが、処理は継続する
@error "Hi"
println(1 + 1)
```

    2


    ┌ Error: Hi
    └ @ Main In[16]:2


#### try / catch 文
`try`, `catch`文により、例外を検査することができる

```julia
try
    <例外が起こり得る処理>
catch [例外変数]
    <例外が起こった場合の処理>
end
```

#### finally 節
try / catch 文に `finally`節を追加することができる

`finally`節で記述された処理は、例外発生の有無に関わらず実行される

そのため、プログラムの終了時に行うべきクリーンアップ処理（ファイルを閉じるなど）は `finally`節に記述する


```julia
# ファイルを開いて処理を行った後、ファイルを閉じる関数
fopen(callback, filename, mode="r") = begin
    # try / catch 文で定義される変数はローカルスコープであるため
    # ブロック以降も使いたい変数はここで宣言しておく
    io = nothing
    try
        io = open(filename, mode)
    catch
        error("$filename は 存在しないファイルです")
    end
    
    try
        callback(io)
    finally # ファイルを閉じる処理は必ず行う
        close(io)
    end
end

# ../.gitignore を読み込んで 内容を出力する
fopen("../.gitignore") do io
    println(read(io, String))
end

# 存在しないファイルを読み込もうとした場合
fopen(".gitignore") do io
    println(read(io, String))
end
```

    .ipynb_checkpoints/
    



    .gitignore は 存在しないファイルです

    

    Stacktrace:

     [1] error(s::String)

       @ Base .\error.jl:33

     [2] fopen(callback::var"#3#4", filename::String, mode::String)

       @ Main .\In[17]:9

     [3] fopen(callback::Function, filename::String)

       @ Main .\In[17]:5

     [4] top-level scope

       @ In[17]:25

     [5] eval

       @ .\boot.jl:360 [inlined]

     [6] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia

```
