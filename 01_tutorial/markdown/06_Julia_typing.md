## 型

Juliaの型システムは動的だが、静的型付システムの方式も一部取り入れている

そのため、ある種の値に対しては、型を判定することができる（型推論）

型を省略した時は値がどんな型であっても許されるが、型注釈を加えると、システムのパフォーマンスと堅牢性が向上する

また、静的に型付けされることで、想定外の値が紛れ込む心配をしなくても良くなり、プログラムが非常に単純化される

### Juliaの型システムの特徴
- オブジェクトか非オブジェクトかという値の区別がない
    - Juliaでは、すべての値は型を持つ真のオブジェクト
    - Juliaの型は、すべてのノードが型として等しく第一級である、完全に連結した単一の型のグラフに属している
- 値のとる型はただ一つであり、実行時に実際にとるものだけである
    - これはオブジェクト指向言語では「実行時型」と呼ばる
    - オブジェクト指向言語において多相型の静的コンパイルを行うときは、この型の違いは重要になる
- 変数ではなく、値だけが型を持つ
    - 変数は値に束縛された単なる名前である
- 抽象型と具象型は両方とも、他の型によるパラメータ化が可能
    - 型以外にも、シンボル、値でその型が `isbits()` で真となるもの、及びこれらのタプルなどによってパラメータ化が可能
    - 参照や制限をする必要がない場合は、型パラメータは省略することができる

### 型注釈
以下のような形式で型注釈を行うことができる

```julia
<式, 変数> :: <型名>
```

型注釈を行うことで以下のようなメリットがある

1. 型注釈によりコードが自己説明的になり、プログラムに想定される動作を確認できるようになる
2. コンパイラが追加的な型情報を利用できるようなり、パフォーマンスが向上することがある


```julia
# 整数型の値を宣言
(1 + 2) :: Int
```




    3




```julia
# 誤った型を宣言すると TypeError例外が投げられる
(1 + 2) :: AbstractFloat
```


    TypeError: in typeassert, expected AbstractFloat, got a value of type Int64

    

    Stacktrace:

     [1] top-level scope

       @ In[2]:2

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
# 型注釈を行うと、その型以外の値を代入することはできなくなる
# -> 想定外の値が代入されることで発生するバグを避けることができる

add(x::Int, y::Int) :: Int = x + y

# 100 + 23 -> 123
println(add(100, 23))

# 整数以外の値を渡すとErrorになる
println(add(3.14, 0.86))
```

    123



    MethodError: no method matching add(::Float64, ::Float64)

    

    Stacktrace:

     [1] top-level scope

       @ In[3]:10

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094


### 型システムまとめ
Juliaの型システムをまとめると、以下のようになっている

- 宣言型: `DataType`のインスタンス
    - 抽象型: `abstract type`
    - 原始型: `primitive type`
    - 複合型: `struct`
- 全合併型: `{T} where T`
    - 合併型: `Union{}`
    - パラメトリック型:
        - パラメトリック抽象型
        - パラメトリック原始型
        - パラメトリック複合型
    - タプル型: `Tuple{}`


### 抽象型
抽象型とは、その子孫となる具象型の集合である

例えば `AbstractFloat` という抽象型は `Float16`, `Float32`, `Float64` という具象型の集合である

これは以下のような型の階層を表現している

```
     AbstractFloat      ... AbstractType
          |
   ----------------
   |      |       |
Float16 Float32 Float64 ... PrimitiveType
```

#### 抽象型の宣言
抽象型は以下のような形式で宣言される

```julia
# 親タイプのない抽象型
abstract type 型名 end

# 親タイプのある抽象型
abstract type 型名 <: 親型名 end
```

Juliaの型システムにおいて、階層の最上位は `Any`型である

そのため、親タイプの指定がない場合、その型は `Any`型の直下の子タイプになる

逆に、階層の最下位は `Union{}`型であり、全ての型は `Union{}`型の親タイプとなる

例えば、Juliaにおける数値型の階層は以下のようになっている

```
              Any
               |
             Number
               |
              Real
               |
       -----------------
       |               |
    Integer            |
       |               |
   ---------           |
   |       |           |
Signed  Unsigned  AbstractFloat
   |       |           |
Union{}  Union{}    Union{}
```

数値型は以下のように定義されている

```julia
abstract type Number end
abstract type Real          <: Number  end
abstract type AbstractFloat <: Real    end
abstract type Integer       <: Real    end
abstract type Signed        <: Integer end
abstract type Unsigned      <: Integer end
```


```julia
# <: 演算子は「is a sub type of」（〜の子タイプである）を意味する

## Integer は Number の子タイプか -> true
Integer <: Number
```




    true




```julia
# Integer は AbstractFloat の子タイプか -> false
Integer <: AbstractFloat
```




    false



### 原始型（プリミティブ型）
原始型は、データが普通のビットで構成される具象型である

典型的な原始型は、整数や浮動小数点である

#### 原始型の宣言
Juliaでは、以下のような形式で原始型を独自に宣言することが可能である

```julia
# 親タイプのない原始型（Any型の子タイプとなる）
primitive type 型名 ビット数 end

# 親タイプのある原始型
primitive type 型名 <: 親型名 ビット数 end
```

また、Juliaにおける全ての原始型は、以下のようにJulia自身によって定義されている

```julia
primitive type Float16 <: AbstractFloat 16 end
primitive type Float32 <: AbstractFloat 32 end
primitive type Float64 <: AbstractFloat 64 end

primitive type Bool    <: Integer 8 end
primitive type Char 32 end

primitive type Int8    <: Signed   8   end
primitive type UInt8   <: Unsigned 8   end
primitive type Int16   <: Signed   16  end
primitive type UInt16  <: Unsigned 16  end
primitive type Int32   <: Signed   32  end
primitive type UInt32  <: Unsigned 32  end
primitive type Int64   <: Signed   64  end
primitive type UInt64  <: Unsigned 64  end
primitive type Int128  <: Signed   128 end
primitive type UInt128 <: Unsigned 128 end
```

抽象型、原始型を合わせて数値型の階層構造を見ると、以下のようになっている

```
                              Any
                               |
               ---------------------------------
               |                               |
             Number                            |
               |                               |
              Real                             |
               |                               |
       -----------------------------           |
       |                           |           |
    Integer                        |           |
       |                           |           |
 ------------------                |           |
 |                |                |           |
 |          ------------           |           |
 |          |          |           |           |
 |       Signed      Unsigned  AbstractFloat   |
 |          |          |           |           |
Union{}  Union{}     Union{}    Union{}      Union{}
 |          |_ Int8    |_ UInt8    |           |
 |          |_ Int16   |_ UInt16   |           |
 |          |_ Int32   |_ UInt32   |_ Float16  |
 |          |_ Int64   |_ UInt64   |_ Float32  |
 |_ Bool    |_ Int128  |_ UInt128  |_ Float64  |_ Char
```

### 複合型
複合型は、名前付きフィールドの集合体であり、言語によっては、レコード、構造体、オブジェクトなどとも呼ばれる

C++, Java, Python, Rubyなどの主流なオブジェクト指向言語では、複合型に名前付きの関数（メソッド）や変数（メンバ、フィールド）が関連付けられて「オブジェクト」と呼ばれる

Juliaでは、全ての値がオブジェクトに関連付けられるが、関数は操作対象のオブジェクトに関連付けられない

これは、各オブジェクトの"内側"にたくさんの名前付き関数を入れるよりも、メソッド群を編成して関数オブジェクトにする方が、言語設計上有益であるという思想に根ざしている

- 主流なオブジェクト指向言語
    ```
    Object1       Object2
      |_ Member1    |_ Member1
      |_ Member2    |_ Member2
      :    :        :    :
      |_ Method1    |_ Method1
      |_ Method2    |_ Method2
      :    :        :    :
    ```
- Julia
    ```
    Object1      Object2     FunctionObject
      |_ Field1    |_ Field1      |_ Method1
      |_ Field2    |_ Field2      |_ Method2
      :    :       :    :         :     :
    ```

#### 複合型の定義
複合型は以下のような形式で定義できる

```julia
struct 型名
    フィールド名1 # <- 型注釈のないフィールドは Any型になる
    フィールド名2 :: 型名2
end
```


```julia
# 複合型 Human型を定義
struct Human
    name::String
    age::Int
end

# 複合型は関数のように呼び出し、型のインスタンスを新しく生成することができる
## これをコンストラクタと呼ぶ
human = Human("Yoya", 31)
```




    Human("Yoya", 31)




```julia
# fieldnames関数を用いて 複合型のフィールド名を列挙することができる
## fieldnames関数は、複合型を引数に取るため
## fieldnames(human) のように インスタンスを渡してもエラーになる
fieldnames(Human)
```




    (:name, :age)




```julia
# フィールドへアクセスするには instance.field 記法を使う
## フィールドはシンボルとして定義されているため
## instance[:field] と書けそうだが、この書き方はできない
println(human.name)
println(human.age)
```

    Yoya
    31



```julia
# 複合型オブジェクトは不変であり、生成後に値を変更することはできない
human.age = 120
```


    setfield! immutable struct of type Human cannot be changed

    

    Stacktrace:

     [1] setproperty!(x::Human, f::Symbol, v::Int64)

       @ Base .\Base.jl:34

     [2] top-level scope

       @ In[9]:2

     [3] eval

       @ .\boot.jl:360 [inlined]

     [4] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
# 可変複合型を定義する場合は、mutable struct を使う
mutable struct MutableHuman
    name::String
    age::Int
end

human = MutableHuman("Yoya", 31)

human.age = 120
println(human)
```

    MutableHuman("Yoya", 120)


### 宣言型
抽象型、原始型、複合型には以下のような共通点がある

- 明示的に宣言される
- 名前がある
- 親タイプが存在する
- パラメータを持つことができる

これらの特徴を持つ型は、**宣言型**と呼ばれ、内部的には `DataType`のインスタンスとして表現される

システムにおけるあらゆる型は、`DataType`のインスタンスであるため、何らかの型のインスタンスである全ての値は、何らかの`DataType`のインスタンスであると言える


```julia
typeof(Int)
```




    DataType



### 合併型
合併型は特殊な抽象型で、指定されたいずれかの型のインスタンスをオブジェクトとして含む

例として、以下のようにして定義された合併型 `IntOrString` は、整数型もしくは文字列型の値のみを取り得る

```julia
# IntOrString合併型 = Int | AbstractString
IntOrString = Union{Int, AbstractString}

1 :: IntOrString # -> 1
"1" :: IntOrString # -> "1"
1.0 :: IntOrString # -> Error
```


### パラメトリック型
パラメトリック型は、パラメータをもつ型であり、パラメータに指定された型の組み合わせの分だけ新しい型の一族を導入することができる

これにより、型の汎用性を無制限に上げることができる

#### パラメトリック複合型
パラメトリック型の例として、一番わかり易いのはパラメトリック複合型である

以下は、任意の型 `T` のフィールド x, y を持つ複合型 `Point` を定義している

```julia
struct Point{T}
    x::T
    y::T
end
```

上記の `Point` 型は、それ単体では型としてインスタンス化することはできず、型パラメータを指定する必要がある

例えば、Int型の x, y フィールドを持つ Point型を定義したい場合は、`Point{Int}`のように記述する

このようにすることで、異なる型をフィールドに持つ複合型を好きなように定義することが可能となる

#### パラメトリック抽象型
複合型同様、抽象型にもパラメータを付与することができる

```julia
abstract type 型名 {型パラメータ名} end
```

パラメトリック抽象型には、インスタンスが型`T`のみの特殊な抽象型である **シングルトン型** というものがある

これは `Type{T}` によって定義される

```julia
# Float64シングルトン型は Float64型のみをインスタンスとして持つ

## Float64型は Float64シングルトン型のインスタンスか -> true
isa(Float64, Type{Floa64})

## Real型は Float64シングルトン型のインスタンスか -> false
isa(Real, Type{Floa64})
```

#### パラメトリック原始型
同様に、原始型にもパラメータを付与することができる

```julia
# 32-bit system:
primitive type Ptr{T} 32 end

# 64-bit system:
primitive type Ptr{T} 64 end
```


### タプル型
タプル型は、関数の引数部分のみを抜き出した型である

その特徴は、順序と型が対応しているということである

そのため、タプル型は、複数パラメータを持つパラメトリック複合型によく似ている

例えば、2要素のタプル型は、以下のようなパラメトリック複合型に似ている

```julia
struct Tuple2{A, B}
    a::A
    b::B
end
```

ただし、タプル型とパラメトリック複合型には明確な違いが3つある

1. タプル型は任意の数のパラメータを持つことができる
2. タプル型は、そのパラメータと共変である
    - 例えば Int型は Any型の子タイプであるため、Any型と共変（置き換え可能）である
    - タプル型 `Tuple{Int}` は、Int型の親タイプである Any型をパラメータに持つ `Tuple{Any}` と共変（置き換え可能）である
    - 一方で、パラメトリック複合型 `Point{Int}` は、`Point{Any}` に置き換えることができない（不変である）
3. タプル型にはフィールド名がなく、インデックスによってのみアクセスできる

タプル型は、タプルの値が宣言された時点で、新しいタプル型が生成される


```julia
# 以下のタプル値が宣言されたタイミングで
## Tuple{Int64,String,Float64} 型が新たに生成される

tuple = (1, "foo", 3.14)
typeof(tuple)
```




    Tuple{Int64, String, Float64}




```julia
# -- パラメトリック複合型は不変 --
struct Point{T}
    x::T
    y::T
end

println("パラメトリック複合型")

# Int <: Real -> true だが
## Point{Int} <: Point{Real} -> false
println(Point{Int} <: Point{Real})

# Point{Int} のインスタンスの型のみが唯一 Point{Int} の子タイプである
println(typeof(Point(10, 20)) <: Point{Int})

# Point{Int} のインスタンスは、Point{Real} のインスタンスではない
println(isa(Point(10, 20), Point{Real}))


# -- シングルトン型も不変 --
println("\nシングルトン型")

# Type{Int}シングルトン型 のインスタンスは Int型のみ
## パラメトリック複合型と異なり
## Type{Int}シングルトン型は、Int型の親タイプではない
println(Int <: Type{Int}) # -> false
println(isa(Int, Type{Int})) # -> true


# -- Tuple型はパラメータと共変 --
println("\nタプル型")

# Int <: Real -> true より
## Tuple{Int} <: Tuple{Real} -> true
println(Tuple{Int} <: Tuple{Real})

# Int <: AbstractString -> false より
## Tuple{Int, Int} <: Tuple{Real, AbstractString} -> false
println(Tuple{Int, Int} <: Tuple{Real, AbstractString})
```

    パラメトリック複合型
    false
    true
    false
    
    シングルトン型
    false
    true
    
    タプル型
    true
    false


#### 可変引数タプル型
タプル型の最後のパラメータは、特殊な可変引数型 `Vararg{}` として任意の数の皇族の要素を示すことができる

`Vararg{T}`は、0個以上の型`T`に対応する


```julia
# 文字列型の後ろに任意の数のInt型が続くタプル型
vatuple = Tuple{AbstractString, Vararg{Int}}
```




    Tuple{AbstractString, Vararg{Int64, N} where N}




```julia
# 文字列のみのタプル -> false
println(isa(("1"), vatuple))

# 文字列の後ろに0個のInt値がある -> true
println(isa(("1", ), vatuple))

# 文字列の後ろに2個のInt値がある -> true
println(isa(("1", 1, 2), vatuple))

# 文字列の後ろに1個のFloat64値がある -> false
println(isa(("1", 3.14), vatuple))
```

    false
    true
    true
    false


### 全合併型
`Ptr{T}` のようなパラメトリック型は、全てのインスタンス型（`Ptr{Int64}` など）の親タイプのように振る舞う

しかし、`Ptr`自体は、参照するデータの種類がわからなければ、その型を記憶操作に使用することができない

これを実現するために、パラメトリック型のような型は、あるパラメータを全ての値に対して繰り返し合併した型を表現する

そのため、このような型を **全合併型** と呼ぶ

#### 全合併型の型宣言
全合併型であることを明示するためには `where` キーワードを使う

```julia
# -- 例 --

# パラメトリック複合型
## パラメータ T をフィールド x, y に対して繰り返し合併する
struct Point{T} where T
    x::T
    y::T
end

# パラメトリック抽象型
## パラメータ T, N を型に対してネストして繰り返し合併する
abstract type Array{T, N} where T where N end
```


```julia
# -- 部分インスタンス化 --

# 複数パラメータはネストして繰り返し合併されるため、部分的に適用することが可能
## -> A{B, C} と A{B}{C} は等価

# 例: N次元のFloat64型配列
## -> Array{Float64, N} where N と等価
const FloatArray = Array{Float64}
println(FloatArray)

# 例: 全ての2次元の配列
## ※ Julia 1.6 においては Array{T,2} (2次元配列) = Matrix{T} である
const Array2D = Array{T, 2} where T
println(Array2D)
```

    Array{Float64, N} where N
    Matrix{T} where T


## 型パターンマッチング

型で縛ることにより、例外処理を減らし、コードをシンプルに保つことができる

以下、値による分岐と、型による分岐を対比し、型パターンマッチングの強力さを体感する

```julia
# --- 値による分岐 ---
## 性別により出力する挨拶を変更する
hello(name::String, sex::String="male") = begin
    if sex === "male"
        # 性別が男性の場合
        println("吾輩は" * name * "である")
    elseif sex === "female"
        # 性別が女性の場合
        println("私は" * name * "です")
    else
        # 想定されていない値 = 例外
        println("性別は male か female を指定してください")
    end
end

## 上記 hello関数は文字列ならなんでも受け入れるため 想定外の問題が起こりうる
## 例えば、性別として「男性」を指定するつもりで"man"を渡したりする可能性がある
### "吾輩はJohnである" と出力されることを期待
hello("John", "man")

### -> 実際には "性別は male か female を指定してください" と出力される


# --- 型による分岐 ---
## 性別を表現する複合型を定義する
struct Male
    name::String
end

struct Female
    name::String
end

## 男性の場合の挨拶
hello(person::Male) = println("吾輩は" * person.name * "である")

## 女性の場合の挨拶
hello(person::Female) = println("私は" * person.name * "です")

## 上記 hello関数は Male か Female しか受け入れないため 想定外の問題は起こり得ない
### -> コンパイルエラーで止まってくれる
```

### Matchパッケージ
型パターンマッチングを行うのに有用なパッケージとして`Match`パッケージがある

#### インストール
インストールは、以下のいずれかの方法で行う

- REPLのパッケージモードで `add Match` コマンドを叩く
- コマンドラインで `julia -e 'using Pkg; Pkg.add("Match")'` を実行

#### 使い方
```julia
@match 変数 begin
    パターン1 => マッチング1
    パターン2 => マッチング2
    # ...
end
```


```julia
# Pkgパッケージを使って Matchパッケージをインストールする
using Pkg
Pkg.add("Match")

# Matchパッケージを使う
using Match

# 性別表現の抽象型定義
abstract type Male end
abstract type Female end

# 型パターンマッチングを行うためシングルトンの合併型を定義
const Sex = Union{Type{Male}, Type{Female}}

# 性別により出力する挨拶を変更する関数
hello(name::String, sex::Sex) = begin
    @match sex begin
        m::Type{Male}   => println("吾輩は$(name)である")
        f::Type{Female} => println("私は$(name)です")
    end
end
```

        [36m[1mFetching:[22m[39m [========================================>]  100.0 %[36m[1mFetching:[22m[39m [===========>                             ]  25.8 %>         ]  76.8 %




    hello (generic function with 1 method)




```julia
# hello関数のsexは Male or Female のみ受け付ける
hello("一郎", Male)
hello("花子", Female)
```

    吾輩は一郎である
    私は花子です



```julia
# 想定外の値が渡されればコンパイル時点でエラーになる
hello("John", "Male")
```


    MethodError: no method matching hello(::String, ::String)
    Closest candidates are:
      hello(::String, ::Union{Type{Female}, Type{Male}}) at In[17]:16

    

    Stacktrace:

     [1] top-level scope

       @ In[19]:2

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
# 合併型そのものを渡されてもコンパイルエラーになる
hello("存在X", Sex)
```


    MethodError: no method matching hello(::String, ::Type{Union{Type{Female}, Type{Male}}})
    Closest candidates are:
      hello(::String, ::Union{Type{Female}, Type{Male}}) at In[17]:16

    

    Stacktrace:

     [1] top-level scope

       @ In[20]:2

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094


## 関数のオーバーロード

Juliaにおいては、同名の関数であっても、引数にとる値が異なれば別の関数として定義することが出来る

これを **関数のオーバーロード** と呼ぶ


```julia
# 文字列に "_doubled" を追加する関数
function double(str::AbstractString)
    str * "_doubled"
end

# 数値を2倍にする関数
function double(num::Number)
    num * 2
end

# 同名の関数（double）であっても異なる挙動をとる
println(double("hello")) # => "hello_doubled"
println(double(123)) # => 246
```

    hello_doubled
    246


### 演算子のオーバーロード
[03_julia_function.ipynb](./03_julia_function.ipynb) で記したように、Juliaにおいては、`&&` や `||` のような短絡評価演算子以外は、全て関数として定義されている

```julia
# 中置記法関数としての `+`
println(1 + 2 + 3) # -> 6

# `+` は、通常の関数と同じ呼び出し方もできる
println(+(1, 2, 3)) # -> 6
```

したがって、通常の関数と同様にオーバーロードすることができる

ただし、オーバーロード時は `モジュール名.:演算子` という形式で関数名を定義する必要がある

例えば `+` 演算子は `Base` モジュールで定義されている関数であるため、以下のように定義する


```julia
using Base # Baseモジュールは最初から使用可能なため、本当は明示的に using する必要はない

# Point 可変複合型
mutable struct Point
    x::Number
    y::Number
end

# Point型に対して `+` 演算子をオーバーロード
function Base.:+(a::Point, b::Point)
    Point(a.x + b.x, a.y + b.y)
end

a = Point(1, 2)
b = Point(2, 3)
a + b
```




    Point(3, 5)




```julia
# 転置演算子 `'` は LinearAlgebraモジュールで adjoint 関数として定義されているため、以下のように記述する
using LinearAlgebra

function LinearAlgebra.:adjoint(a::Point)
    Point(a.y, a.x)
end

a'
```




    Point(2, 1)



### オブジェクト指向風プログラミング
Juliaは、基本的に関数型言語であり、オブジェクト指向言語ではない

しかし、可変複合型と関数オーバーロードにより、より柔軟なオブジェクト指向風の記述が可能となっている


```julia
# Player 可変複合型
mutable struct Player
    name::AbstractString
    hp::Integer  # HP
    atk::Integer # 攻撃力
    def::Integer # 防御力
end

# Playerコンストラクタ
## 複合体名と同名の関数を定義（関数オーバーロード）することでコンストラクタを代替
function Player(name; hp = 100, atk = 10, def = 10)
    Player(name, hp, atk, def)
end

# `*` 演算子オーバーロード
## Player同士の攻撃力と防御力の差から各々のHPを減じる
function Base.:*(a::Player, b::Player)
    (
        Player(a.name; hp = a.hp - (b.atk - a.def < 0 ? 0 : b.atk - a.def), atk = a.atk, def = a.def),
        Player(b.name; hp = b.hp - (a.atk - b.def < 0 ? 0 : a.atk - b.def), atk = b.atk, def = b.def)
    )
end

# Player同士の戦闘実行関数
## Juliaでは慣例的に、副作用のある関数には `!` をつける
function battle!(a::Player, b::Player)
    (new_a, new_b) = a * b
    a.hp = new_a.hp
    b.hp = new_b.hp
    (a, b)
end

# `()` call演算子オーバーロード
## 自身の name を表示
function (self::Player)(append_message = "")
    println(append_message, self.name)
end

# ----------

player = Player("Hero"; atk = 15)
enemy = Player("Monster"; hp = 50, atk = 20)

player("I'm ") # => "I'm Hero"

battle!(player, enemy)
dump(player)
dump(enemy)
```

    I'm Hero
    Player
      name: String "Hero"
      hp: Int64 90
      atk: Int64 15
      def: Int64 10
    Player
      name: String "Monster"
      hp: Int64 45
      atk: Int64 20
      def: Int64 10


#### 内部コンストラクタメソッド
上記のように、複合体と同名の関数をオーバーライドしてコンストラクタを定義する方法を **外部コンストラクタメソッド** と呼ぶ

外部コンストラクタメソッドはオブジェクトの構築をより簡単にする（複合体の全フィールドを毎回指定しなくて良いようにする）が、**不変条件の強制**と、**自己参照的なオブジェクトの構築**には対応できない

この二つの問題の解決には **内部コンストラクタメソッド** を使うことになる

内部コンストラクタメソッドは基本的に外部コンストラクタメソッドと同様だが、以下の二つの違いがある

- 型宣言と同じブロックで定義される
- ローカルに定義される特殊な関数 `new` へのアクセスを持つ
    - `new` は内部コンストラクタメソッドが属するブロックで定義される型のインスタンスを生成する

例として、「一つ目の数が二つ目の数以下である」という制約を持つ実数の組を保持する型は次のように宣言できる

```julia
struct OrderedPair
    x::Real
    y::Real
    
    # 内部コンストラクタメソッド
    function OrderedPair(x, y)
        x > y ? error("out of order") : new(x,y)
    end
end
```

こうして定義される `OrderedPair` 型のオブジェクトは、`x <= y` の制約条件を満たすときにだけ構築できる


```julia
struct OrderedPair
    x::Real
    y::Real
    
    # 内部コンストラクタメソッド
    function OrderedPair(x, y)
        x > y ? error("out of order") : new(x,y)
    end
end

# 生成可能な OrderedPair
pair1 = OrderedPair(1, 2)
dump(pair1)

# 生成不可能な OrderedPair
pair2 = OrderedPair(2, 1)
dump(pair2)
```

    OrderedPair
      x: Int64 1
      y: Int64 2



    out of order

    

    Stacktrace:

     [1] error(s::String)

       @ Base ./error.jl:33

     [2] OrderedPair(x::Int64, y::Int64)

       @ Main ./In[12]:7

     [3] top-level scope

       @ In[12]:16

     [4] eval

       @ ./boot.jl:360 [inlined]

     [5] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base ./loading.jl:1094


ただし、上記の型が `mutable` として宣言されていれば、フィールドの値を直接変更してこの不変条件を破ることができる

しかしながら、オブジェクトの内部情報をいじるのは招かれざる操作であり、行うべきではない（他のオブジェクト指向言語では `private` 宣言等でフィールドへのアクセスを禁止し隠蔽することが出来るが、現状の Julia ではサポートされていない）

また、外部コンストラクタメソッドは後から追加可能だが、内部コンストラクタメソッドを後から追加する方法はない

外部コンストラクタメソッドは他のコンストラクタメソッドを呼ぶことでしかオブジェクトを構築できないため、オブジェクトの構築では必ずどこかで内部コンストラクタメソッドが呼ばれることになる

これにより、被宣言型の任意のオブジェクトが型の定義と共に提供される内部コンストラクタメソッドで構築されることが保証され、型の不変条件をある程度強制できるようになる、という仕組みである

なお、**内部コンストラクタメソッドが一つでも定義されると、デフォルトのコンストラクタメソッドは提供されなくなる**ため注意


```julia

```
