## メタプラグラミング

Juliaは、Lispのような強力なメタプログラミングをサポートしている

Lispと同様に、Juliaは自身のコードを言語自体のデータ構造として表すことができる

Juliaコードは言語内から作成・操作可能なオブジェクトとして表されるため、プログラムが独自のコードを変換・生成することができる

これにより、追加のビルド手順なしで高度なコード生成が可能になり、抽象構文木（AST）レベルで動作する真の Lisp スタイルマクロが記述できるようになっている（対照的に、CやC++のようなプリプロセッサマクロシステムは、実際の解析や解釈が行われる前にテキストの操作と置換を実行する）


```julia
# すべてJuliaコードは文字列として表現される
prog = "1 + 1"

# Juliaコードはコンパイラにより、式（Expr）オブジェクトに解析される
ex1 = Meta.parse(prog)
```




    :(1 + 1)




```julia
typeof(ex1)
```




    Expr



### Exprオブジェクト
`Expr`オブジェクトは、以下の2つの部分から構成されている

- `head`:
    - 式の種類を表す `Sysmbol` 型
- `args`:
    - 式の引数として渡される記号、リテラル値、または他の式が `Vector` 型で格納されている

ここで重要な点は、**Juliaコード（`Expr`）が言語自体からアクセス可能なデータ構造として内部的に表現されていること**である


```julia
ex1.head
```




    :call




```julia
ex1.args
```




    3-element Vector{Any}:
      :+
     1
     1




```julia
# 式はポーランド記法で直接構築することも可能
ex2 = Expr(:call, :+, 1, 1)
```




    :(1 + 1)




```julia
ex1 == ex2
```




    true




```julia
# dump関数を使うと、Exprオブジェクトをインデントと注釈付きで表示可能
dump(ex2)
```

    Expr
      head: Symbol call
      args: Array{Any}((3,))
        1: Symbol +
        2: Int64 1
        3: Int64 1



```julia
# Exprオブジェクトはネスト可能
ex3 = Meta.parse("(4 + 4) / 2")

# Meta.show_sexpr関数を使うと、ExprオブジェクトをS式形式（逆ポーランド記法）で表示可能
Meta.show_sexpr(ex3)
```

    (:call, :/, (:call, :+, 4, 4), 2)

### 記号
`:`記号は、Julia上で2つの意味がある

一つは、`Symbol`型オブジェクトを生成するためのビルディングブロックである

```julia
s1 = :foo # => :foo
typeof(s1) # => Symbol

s2 = Symbol("foo") # => :foo
s1 == s2 # => true

s3 = Symbol(:s2, "_", "sym") # => :foo_sym
```

2つ目は、明示的な`Expr`コンストラクタを使用せずに式オブジェクトを作成するための構文である

これは **引用** と呼ばれる

```julia
ex = :(a + b * c + 1) # => :(a + b * c + 1)
typeof(ex) # => Expr
```


```julia
ex = :(a + b * c + 1)
dump(ex)
```

    Expr
      head: Symbol call
      args: Array{Any}((4,))
        1: Symbol +
        2: Symbol a
        3: Expr
          head: Symbol call
          args: Array{Any}((3,))
            1: Symbol *
            2: Symbol b
            3: Symbol c
        4: Int64 1



```julia
# 複数の式を引用するためには quote ... end コードブロックを利用する
ex = quote
    x = 1
    y = 2
    x + y
end
```




    quote
        #= In[10]:3 =#
        x = 1
        #= In[10]:4 =#
        y = 2
        #= In[10]:5 =#
        x + y
    end




```julia
dump(ex)
```

    Expr
      head: Symbol block
      args: Array{Any}((6,))
        1: LineNumberNode
          line: Int64 3
          file: Symbol In[10]
        2: Expr
          head: Symbol =
          args: Array{Any}((2,))
            1: Symbol x
            2: Int64 1
        3: LineNumberNode
          line: Int64 4
          file: Symbol In[10]
        4: Expr
          head: Symbol =
          args: Array{Any}((2,))
            1: Symbol y
            2: Int64 2
        5: LineNumberNode
          line: Int64 5
          file: Symbol In[10]
        6: Expr
          head: Symbol call
          args: Array{Any}((3,))
            1: Symbol +
            2: Symbol x
            3: Symbol y


### 補間
`Expr`オブジェクトの直接生成は強力だが、変数を使いたい場合もある

こういった場合、Juliaではリテラルまたは式を引用符で囲まれた式に挿入することが出来る

これを **補間** と呼び、`$`接頭辞を用いて記述する


```julia
a = 1
ex = :($a + b)
```




    :(1 + b)




```julia
ex = :(a in $:((1, 2, 3)))
```




    :(a in (1, 2, 3))



### スプレッド補間
`$`補間構文では、囲んでいる式に一つの式しか挿入できない

しかし、場合によっては配列形式の式を引数にする必要があるかもしれない

こういった場合は、スプレッド構文（`変数...`）を用いて `$(xs...)` という形式で記述することが出来る


```julia
args = [:x, :y, :z]
:(f(1, $(args...)))
```




    :(f(1, x, y, z))



### 式の評価
`Expr`オブジェクトは、`eval`関数により評価（実行）される

このとき、`eval`関数実行スコープ内の状態（変数）を変更する副作用を生じる可能性があることに注意


```julia
x = 123
println(x) # => 123

ex = :(x = 1)
eval(ex) # => `x = 1` 式が評価され、グローバルスコープの x の値が変更される

println(x) # => 1
```

    123
    1


### マクロ
マクロは、生成されたコードをプログラムの最終的な本文に含める方法を提供する

マクロは引数のタプルを返された式にマップし、結果の式は `eval` 呼び出しを必要とせずに直接コンパイルされる

マクロ引数には、式、リテラル値、および記号を含めることができるが、これらは、マクロ内においては `Symbol` として扱われることに注意


```julia
# マクロ定義は macro ... end ブロックで行う
## マクロが返す Expr オブジェクトは、マクロ呼び出し時に直接コンパイルされて実行される
macro sayhello()
    return :( println("Hello, macro!!") )
end
```




    @sayhello (macro with 1 method)




```julia
# マクロ実行は `@` 接頭辞をつけることで行われる
## マクロが返す Expr オブジェクトが即時 eval される
@sayhello
```

    Hello, macro!!



```julia
# 引数付きのマクロ
macro sayhello(name, lf=true)
    return :(
        if $lf === true
            println("Hello, ", $name)
        else
            print("Hello, ", $name)
        end
    )
end

# マクロは通常の関数のように呼び出すことが可能
@sayhello("world...", false)
@sayhello("world!!!")

# マクロ引数はスペース区切りで指定することも可能
@sayhello "julia..." false
@sayhello "jula!!!"
```

    Hello, world...Hello, world!!!
    Hello, julia...Hello, jula!!!



```julia
# macroexpandマクロを使うと、後続のマクロが返すExprオブジェクトを確認することができる
@macroexpand @sayhello("julia", false)
```




    :(if false === true
          #= In[18]:5 =#
          Main.println("Hello, ", "julia")
      else
          #= In[18]:7 =#
          Main.print("Hello, ", "julia")
      end)




```julia
# マクロ引数を確認したい場合は println, show, display, dump 等の関数をマクロ内で呼び出すと良い
macro showarg(a)
    show(a)
    :($a)
end

@showarg(1 + 1)
```

    :(1 + 1)




    2




```julia
# マクロ内では特殊変数 __source__, __module__ を利用可能
## __source__: マクロ呼び出しが行われたパーサ位置情報
## __module__: マクロ呼び出しが行われたモジュール情報
macro info()
    dump(__source__) # => LineNumberNode(line::Int64 = 行, file::Symbol = スクリプトファイル)
    dump(__module__) # => Main
end

@info
```

    LineNumberNode
      line: Int64 9
      file: Symbol In[21]
    Module Main


### 高度なマクロの構築
マクロの内部で定義されたローカル変数は、マクロ呼び出し元の環境には影響を与えない（通常関数のローカル変数と同様の挙動をする）

マクロ内ローカル変数を引用したい場合は、戻り値の `Expr` オブジェクト内で補間する（`$`接頭辞をつける）必要がある

これはつまり、マクロ内ローカル変数は `Symbol` 型オブジェクトであることを意味している

#### 例題
引数に指定された変数に `_sym` をつけた変数をグローバルスコープに生成し、0 で初期化するマクロを実装する

ただし、引数は複数指定可能とする

```julia
# 例)
@zeros(x, y, z)

"""
 ↓
x_sym = 0
y_sym = 0
z_sym = 0
"""
```


```julia
# マクロ引数にキーワード引数は使えないが、可変引数は使うことができる
macro zeros(vars...)
    dump(vars)
end

@zeros(x, y, z)
```

    Tuple{Symbol, Symbol, Symbol}
      1: Symbol x
      2: Symbol y
      3: Symbol z



```julia
macro zeros(vars...)
    # 変数名（引数+"_sym"）配列を生成
    names = [Symbol(var, "_sym") for var in vars]
    dump(names)
end

@zeros(x, y, z)
```

    Array{Symbol}((3,))
      1: Symbol x_sym
      2: Symbol y_sym
      3: Symbol z_sym



```julia
macro zeros(vars...)
    # 変数名（引数+"_sym"）配列を生成
    names = [Symbol(var, "_sym") for var in vars]
    
    # `変数名 = 0` の式を `;` で連結して一つの Expr に変換
    ## グローバルスコープに新規変数を宣言することになるため global キーワードをつけること
    exps = ["global $(name) = 0" for name in names]
    return Meta.parse(join(exps, ";"))
end

@macroexpand @zeros(x, y, z)
```




    :($(Expr(:toplevel, :(global x_sym = 0), :(global y_sym = 0), :(global z_sym = 0))))




```julia
@zeros(x, y, z)
println(x_sym, ", ", y_sym, ", ", z_sym) # => 0, 0, 0
```

    0, 0, 0


#### デコレータの実装
マクロ機能を使って、Python風のデコレータ（指定された関数を修飾して再定義する機能）を実装する


```julia
macro log_calls(func)
    """
    func に function を指定した場合: Expr(
        head::Symbol = function,
        args::Array{Any}(
            [1] = Expr(
                head::Symbol = call,
                args::Array{Any}(
                    [1] = 関数名,
                    [2...] = 関数の引数
                )
            ),
            [2] = Expr(
                head::Symbol = block,
                args::Array{Any}
            )
        )
    )
    """
    # 渡されてきた関数名を取得
    name = func.args[1].args[1]
    
    dump(func)
    dump(name)
end

@log_calls function hello(str)
    println("Hello, ", str)
end
```

    Expr
      head: Symbol function
      args: Array{Any}((2,))
        1: Expr
          head: Symbol call
          args: Array{Any}((2,))
            1: Symbol hello
            2: Symbol str
        2: Expr
          head: Symbol block
          args: Array{Any}((3,))
            1: LineNumberNode
              line: Int64 27
              file: Symbol In[26]
            2: LineNumberNode
              line: Int64 28
              file: Symbol In[26]
            3: Expr
              head: Symbol call
              args: Array{Any}((3,))
                1: Symbol println
                2: String "Hello, "
                3: Symbol str
    Symbol hello



```julia
macro log_calls(func)
    # 渡されてきた関数名を取得
    name = func.args[1].args[1]
    
    # 他の変数名と衝突しない任意変数名を生成
    hiddenname = gensym()
    
    # 渡されてきた元の関数名を hiddenname で置換
    func.args[1].args[1] = hiddenname
    
    dump(name)
    dump(hiddenname)
    dump(func)
end

@log_calls function hello(str)
    println("Hello, ", str)
end
```

    Symbol hello
    Symbol ##257
    Expr
      head: Symbol function
      args: Array{Any}((2,))
        1: Expr
          head: Symbol call
          args: Array{Any}((2,))
            1: Symbol ##257
            2: Symbol str
        2: Expr
          head: Symbol block
          args: Array{Any}((3,))
            1: LineNumberNode
              line: Int64 16
              file: Symbol In[27]
            2: LineNumberNode
              line: Int64 17
              file: Symbol In[27]
            3: Expr
              head: Symbol call
              args: Array{Any}((3,))
                1: Symbol println
                2: String "Hello, "
                3: Symbol str



```julia
macro log_calls(func)
    # 渡されてきた関数名を取得
    name = func.args[1].args[1]
    
    # 他の変数名と衝突しない任意変数名で元の関数名を置換
    hiddenname = gensym()
    func.args[1].args[1] = hiddenname
    
    # 修飾した関数を定義
    ## 関数呼び出し前後で info レベルロギング
    _decorator(f) = (args...) -> begin
        Base.@info "calling $(name)"
        f(args...)
        Base.@info "called $(name)"
    end
    
    quote
        # 元の関数定義を別名で再定義
        $func
        
        # 元の関数名: 修飾された関数として再定義
        ## `$name = ...` では `var"#インデックス#hello" = ...` という形式で展開されてしまう
        $name = $_decorator($hiddenname)
    end
end

@macroexpand @log_calls function hello(str)
    println("Hello, ", str)
end
```




    quote
        #= In[28]:19 =#
        function var"#75###258"(var"#77#str")
            #= In[28]:27 =#
            #= In[28]:28 =#
            Main.println("Hello, ", var"#77#str")
        end
        #= In[28]:23 =#
        var"#76#hello" = (var"#_decorator#8"{Symbol}(:hello))(var"#75###258")
    end




```julia
macro log_calls(func)
    # 渡されてきた関数名を取得
    name = func.args[1].args[1]
    
    # 他の変数名と衝突しない任意変数名で元の関数名を置換
    hiddenname = gensym()
    func.args[1].args[1] = hiddenname
    
    # 修飾した関数を定義
    ## 関数呼び出し前後で info レベルロギング
    _decorator(f) = (args...) -> begin
        Base.@info "calling $(name)"
        f(args...)
        Base.@info "called $(name)"
    end
    
    quote
        # 元の関数定義を別名で再定義
        $func
        
        # 元の関数名: 修飾された関数として再定義
        ## `hello = ...` という形式で展開されて欲しいため `$(esc(name)) = ...` という形式で記述する
        $(esc(name)) = $_decorator($hiddenname)
    end
end

@macroexpand @log_calls function hello(str)
    println("Hello, ", str)
end
```




    quote
        #= In[29]:19 =#
        function var"#124###259"(var"#125#str")
            #= In[29]:27 =#
            #= In[29]:28 =#
            Main.println("Hello, ", var"#125#str")
        end
        #= In[29]:23 =#
        hello = (var"#_decorator#11"{Symbol}(:hello))(var"#124###259")
    end




```julia
@log_calls function hello(str)
    println("Hello, ", str)
end

hello("World!!!")
```

    Hello, World!!!


    ┌ Info: calling hello
    └ @ Main In[29]:12
    ┌ Info: called hello
    └ @ Main In[29]:14



```julia
"""
型アノテーション付き関数への対応
"""
macro log_calls(func)
    name = func.args[1].args[1]
    hiddenname = gensym() # 元の関数名を置換する任意変数名
    
    # 元の関数名を hiddenname で置換
    if typeof(name) == Expr # 型アノテーション付き関数に対応
        name = name.args[1]
        func.args[1].args[1].args[1] = hiddenname
    else
        func.args[1].args[1] = hiddenname
    end
    
    # 修飾した関数を定義
    ## 関数呼び出し前後で info レベルロギング
    _decorator(f) = (args...) -> begin
        Base.@info "calling $(name)"
        f(args...)
        Base.@info "called $(name)"
    end
    
    quote
        # 元の関数定義を別名で再定義
        $func
        
        # 元の関数名: 修飾された関数として再定義
        ## `hello = ...` という形式で展開されて欲しいため `$(esc(name)) = ...` という形式で記述する
        $(esc(name)) = $_decorator($hiddenname)
    end
end

@macroexpand @log_calls function hello(str::AbstractString)
    println("Hello, ", str)
end
```




    quote
        #= In[31]:26 =#
        function var"#179###261"(var"#180#str"::Main.AbstractString)
            #= In[31]:34 =#
            #= In[31]:35 =#
            Main.println("Hello, ", var"#180#str")
        end
        #= In[31]:30 =#
        hello = (var"#_decorator#14"(Core.Box(:hello)))(var"#179###261")
    end




```julia
@log_calls function hello(str::AbstractString)
    println("Hello, ", str)
end

hello("World!!!")
```

    Hello, World!!!


    ┌ Info: calling hello
    └ @ Main In[31]:19
    ┌ Info: called hello
    └ @ Main In[31]:21



```julia

```
