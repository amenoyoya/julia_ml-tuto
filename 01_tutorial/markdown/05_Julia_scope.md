## 変数のスコープ

変数のスコープとは、変数を参照できるコードの範囲のこと（**スコープブロック**）

変数のスコープは、変数の名前が衝突するのを避けるのに役立つ

同じ変数名が、いつ同じものを参照し、いつそうではないかを決める規則は **スコープ規則** と呼ばれる

### スコープブロック

スコープ名             | スコープを採用している ブロック／構成要素
:--                    | :--
グローバルスコープ     | `module`, `baremodule`, 対話セッション (REPL)
ソフトローカルスコープ | `for`, `while`, 内包表記, `try-catch-finally`, `let`
ハードローカルスコープ | 関数 (通常構文、 無名関数 、 `do`ブロック), `struct`, `macro`

#### スコープブロックを導入しないブロック
- `begin`ブロック
- `if`ブロック


```julia
# Barモジュール定義（import .Bar で使えるようになるブロック）
module Bar
    x = 1 # この x は Bar.x で参照可能な変数
    foo() = x # foo関数は x を返す（この x は Bar.x を参照）
end
```




    Main.Bar




```julia
# カレントディレクトリで定義された Bar モジュールを import
import .Bar

x = -1 # この x はグローバルな x（Bar.x とは無関係）

# Barモジュール内にある foo() 関数
## -> Barモジュール内の x が返る -> 1
Bar.foo()
```




    1



### グローバルスコープ
各モジュールは、他のモジュールと分離した新しいグローバルスコープを導入する

変数の束縛が変更されるのは、モジュール内のグローバルスコープのみで、モジュール外では変更されない


```julia
module A
    a = 1 # global a in module A
end

module B
    # module C in module B
    module C
        c = 2 # global c in module C
    end
    
    # モジュールB内で定義されたモジュールC内の変数にアクセスできる
    b = C.c # global b in module B

    # モジュールAは モジュールBの外で定義されているため、アクセスできない
    ## d = A.a

    # 一つの上の空間で定義されている モジュールAをimport
    import ..A
    d = A.a
end

# モジュールBはこの空間内で定義されているためアクセスできる
println(B.b)
println(B.d)
```

    2
    1


上記のモジュールは以下のような階層構造になっている

```
       Main
         |
    -----------
    |         |
module A  module B
    |         |_ module C
    |         |      |_ c = 2
    |         |_ b = C.c ___:
    |         |_ import ..A (../module A)
    |_ a = 1  |_ d = A.a _:
           :___________:
```

### ローカルスコープ
`begin`, `if`ブロック等を除くほとんどのコードブロックは、新しいローカルスコールを導入する

通常、ローカルスコールは、親スコープの全ての変数を受け継いでいる

しかし、ローカルスコープにはハードとソフトの2つの派生型があり、どの変数が受け継がれるか、わずかに規則が異なる

いずれにしても、**ローカルスコープ内で新たに導入された変数は、その親スコープに逆伝播されることはない**


```julia
for i = 1:10
    z = i # forブロック内で導入されたローカル変数 z
end

# forブロック内のローカル変数 z にアクセスすることはできない
z
```


    UndefVarError: z not defined

    

    Stacktrace:

     [1] top-level scope

       @ :0

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094


#### ソフトローカルスコープ
変数の読み取りに関しては、基本的に全ての変数は親スコープから受け継がれる

ソフトローカルスコープは `for`, `while`, 内包表記, `try-catch-finally`, `let` ブロックに導入されており、親スコープの変数に対して読み取り・書き込みの両方を行うことができる

---

#### Julia 1.5 以降の注意
Julia 1.5 以降、上記のような挙動は分かりにくいため廃止された

そのため、親スコープの変数に対する読み取り・書き込みを行いたい場合は、明示的に `global` キーワードを用いる必要がある

ただし、読み取りのみであれば、引き続き親スコープの変数情報が引き継がれる


```julia
# グローバル変数 x, y
x, y = 0, 1

# letブロック
let
    # 親スコープの変数 x, y の値を読み取る
    ## x = 0, y = 1
    ## x <- y + 1 = 1 + 1 = 2
    x = y + 1
    println(x)
end

# ソフトローカルスコープは廃止されたため、letブロック内で行われた変更は、グローバル変数には影響しない
x # -> 0 のまま
```

    2





    0




```julia
# グローバル変数 x, y
x, y = 0, 1

# letブロック
let
    # 親スコープの変数 x に対して書き込みを行いたい場合は global キーワードを用いる
    global x = y + 1
    println(x)
end

# グローバル変数に変更が反映されている
x # -> 2
```

    2





    2




```julia
# グローバル変数 x, y
x, y = 0, 1

# letブロック
let
    # localキーワード
    ## ブロック内でのみ使用可能なローカル変数として宣言できる
    local y = 1000
    local x = y + 1 # -> 1000 + 1 = 1001
    println(x) # -> 1001
end

# local変数の変更はglobal変数には関係ない
x, y # -> 0, 1
```

    1001





    (0, 1)




```julia
# 変数を割り当てるブロックの挙動

# -- letブロック --
n = 0

let n = 100 # ローカル変数を割り当てる
    n += 1 # -> n = 100 + 1 = 101
end

# 親スコープの n には影響がない -> 0
println(n)


# -- forブロック --
i = 0

for i = 1:3 # ローカル変数を割り当てる
end

# 親スコープの i には影響がない -> 0
println(i)


# -- 内包表記 --
x = 0

# ローカル変数を割り当てる
[x for x = 1:3] # -> [1, 2, 3]

# 親スコープの x には影響がない -> 0
println(x)
```

    0
    0
    0


#### ハードローカルスコープ
ハードローカルスコープは、関数定義、タイプ定義(`struct`ブロック)、およびマクロ定義によって導入される

ハードローカルスコープでは、親スコープの変数に対して**読取だけが受け継がれる**

---

#### Julia 1.5 以降の注意点
先述の通り、Julia 1.5 以降は、全てハードローカルスコープとなる


```julia
x, y = 1, 2

function foo()
    x = 2 # 親スコープの変数に書込できないため、local変数 x が作られる
    return x + y # local x + global y -> 2 + 2 -> 4
end

println(foo()) # -> 4
println(x) # -> global x -> 1
```

    4
    1


## 定数

特定の変数に不変の値を与えたい場合、`const`キーワードを使い、定数を作ることができる

定数への代入は一度きりであるが、配列などの可変なオブジェクトに変数を束縛した場合に、そのオブジェクトが不変になるわけではないことに注意する


```julia
# 定数 PI = 3.14 定義
const PI = 3.14

# PI に別の値を再代入することはできない
PI = "円周率"
```


    invalid redefinition of constant PI

    

    Stacktrace:

     [1] top-level scope

       @ In[10]:5

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
# 定数 VEC = [1, 2, 3] 定義
const VEC = [1, 2, 3]

# ARY に別の値を再代入することはできない
## ARY = [3, 4, 5] -> Error

# ARY の配列の要素を変更できないわけではない
VEC[1] = 10 ## Juliaの添字は 1 から始まる
VEC[2] = 20
VEC[3] = 30

VEC
```




    3-element Vector{Int64}:
     10
     20
     30




```julia

```
