# Julia入門

## 複素数と有理数

### 複素数
グローバル定数`im`は`√-1`を示す

複素数を使って全ての標準的な算術処理が可能


```julia
println(1 + 2im)
println((1 + 2im) * (2 - 3im))
println((-1 + 2im)^2)
```

    1 + 2im
    8 + 1im
    -3 - 4im



```julia
z = 1 + 2im

# 実数部を取得 -> 1
println(real(z))

# 複素数部を取得 -> 2
println(imag(z))

# 複素共役を取得 -> 1 - 2im
println(conj(z))

# 絶対値を取得
## |(1 + 2im)| = √(1 + 2im)^2 = √5 = 2.236...
println(abs(z))

# 絶対値の二乗を取得 -> 5
println(abs2(z))

# 位相角をラジアンで取得 -> 1.107...
println(angle(z))
```

    1
    2
    1 - 2im
    2.23606797749979
    5
    1.1071487177940904


### 有理数

Juliaには、整数の正確な比率を表すために有理数型がある

有理数は`//`演算子で構成される

例えば、`2/3`を浮動小数点で表すと`0.666...`となるため、これに3を掛けると`1.999...`という計算結果を得る（2にならない）

一方で、有理数型`2//3`に3を掛けると正確に`2`という計算結果を得ることができる


```julia
f = 2 / 3
println(f) # -> 0.666...
println(f * 3) # -> 1.999... ~ 2.0

r = 2 // 3
println(r) # -> 2//3
println(r * 3) # -> 2//1
```

    0.6666666666666666
    2.0
    2//3
    2//1



```julia
# 有理数は約分されて保持される
println(6 // 9) # -> 2//3
println(-4 // -12 == 1 // 3) # -> 1//3 == 1//3 -> true

# 分子を得る
println(numerator(2//3)) # -> 2

# 分母を得る
println(denominator(2//3)) # -> 3
```

    2//3
    true
    2
    3


## 文字列

- **文字列**
    - 文字列は有限の記号の連続を意味する
    - Juliaにおける文字列を扱うビルトインの型は`String`型
        - UTF-8エンコーディング下で全てのUnicode文字列を使える
    - 全ての文字列型は抽象型`AbstractString`のサブタイプ
    - Juliaは1文字を表す`Char`型が存在する
    - Javaと同様に文字列は変更不可能
        - 異なる文字列の値を作成したい場合は、他の文字列の一部から新しく作成する
    - 概念的には、文字列はインデックスから文字への部分的な関数である
        - `AbstractString: Int64 -> Char`

### 文字
1文字を表す`Char`値は、シングルクオテーションで表す

これは特殊なリテラル表現と算術演算を持つ32ビットのプリミティブ型であり、数値はUnicodeコードポイントとして解釈される


```julia
'x'
```




    'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)




```julia
typeof(ans)
```




    Char




```julia
# Charを整数値（コードポイント）に変換する
Int('x') # 0x0078 -> 120
```




    120




```julia
# 整数値から文字に変換する
Char(0x0078)
```




    'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)




```julia
Char(0x110000)
```




    '\U110000': Unicode U+110000 (category In: Invalid, too high)




```julia
# 有効なUnicodeコードポイントか確認
isvalid(Char, 0x1100000)
```




    false




```julia
# Charの演算

## 比較
println('A' < 'a') # -> true

## 算術演算
println('x' - 'a') # -> 23
println('A' + 1) # -> 'B'
```

    true
    23
    B


### 文字列
文字列リテラルはダブルクオーテーションまたは3つのダブルクオーテーションで表す

文字列から文字を抽出する場合は`String[index]`という形式で、インデックスを添える

ただし、Juliaでは**インデックスは1から始まる**（配列なども同様）


```julia
str = "Hello, world.\n"
println(str)

# ヒアドキュメント
doc = """Hello, world.
This is "heredoc".
Contains "quote" characters"""

println(doc)
```

    Hello, world.
    
    Hello, world.
    This is "heredoc".
    Contains "quote" characters



```julia
# 文字列の先頭文字を取得
println(str[1]) # -> 'H'

# 文字列の最後の文字を取得
println(str[end]) # -> '\n'

# 文字列の最後から2番めの文字を取得
println(str[end-1]) # -> '.'
```

    H
    
    
    .



```julia
# 4〜9文字目の文字列を抽出
str[4:9]
```




    "lo, wo"



### 文字列の連結
文字列を連結する場合は`string(...)` もしくは`*`演算子を使用する

#### 補完
文字列内で `$変数名` を使うことで 変数埋め込みすることもできる


```julia
greet = "Hello"
whom = "world"

# Hello, world.
println(string(greet, ", ", whom, "."))
println(greet * ", " * whom * ".")
println("$(greet), $whom.")
```

    Hello, world.
    Hello, world.
    Hello, world.



```julia
# 任意の式を文字列に保管することができる
"1 + 2 = $(1 + 2)"
```




    "1 + 2 = 3"




```julia
# $そのものを表現する場合

## エスケープ
println("I have \$100 in my account.")

## raw文字列
println(raw"I have $100 in my account.")
```

    I have $100 in my account.
    I have $100 in my account.


### 文字列処理

#### 比較演算
文字列は標準比較演算子で比較できる

```
<  >  <=  >=  == !=
```

#### 関数
- `search(String, Char, Int64=1) -> Int64`
    - 文字列内にある指定文字のインデックスを検索（最初に見つかったインデックス）
    - 文字が見つからなかった場合は 0 が返る
    - 三番目の引数に検索開始する文字列のオフセットを指定できる
- `contains(String, String) -> Bool`
    - 1番目の文字列に2番目の文字列が含まれるか判定
- `endof(String) -> Int64`
    - 文字列に添えられる最大の（バイト）インデックスを取得
- `length(String) -> Int64`
    - 文字列の文字数を取得
- `next(String, Int64) -> Char, Int64`
    - 文字列の指定（バイト）インデックス以降で有効な文字とインデックスを取得
- `ind2chr(String, Int64) -> Int64`
    - 文字列の先頭から指定（バイト）インデックスまでの文字数を取得
- `chr2ind(String, Int64) -> Int64`
    - 文字列の指定番目の文字が格納されている（バイト）インデックスを取得

### 正規表現
Juliaでは、`r"..."`で正規表現パターンを表現する

正規表現は`Regex`型として定義される

正規表現型は閉じクオートの後ろにフラグ `i`, `m`, `s`, `x` を付与して、正規表現の挙動に変更を加えることができる

- `i`:
    - 大文字・小文字を区別しないパターンマッチングを行う
- `m`:
    - 文字列を複数行として扱う
    - `^`, `$` が全ての行の先頭と行末にマッチするようになる
- `s`:
    - 文字列を一行として扱う
    - `.`が改行などにもマッチするようになる
- `x`:
    - 正規表現パーサにバックスラッシュ付きもしくは文字列クラス内の空白を除いた大部分の空白を無視させる

#### 正規表現関数
- `ismatch(Regex, String) -> Bool`
    - 正規表現が文字列に一致するか判定
- `match(Regex, String, Int64=1) -> RegexMatch`
    - 正規表現が文字列にどのように一致するかを取得
    - 一致がない場合は`nothing`が返る
    - 3番目の引数に検索開始オフセットを指定できる
    - `RegexMatch`オブジェクトから以下の情報を取得できる
        - `RegexMatch.match: String`
            - 一致した部分文字列
        - `RegexMatch.captures: Array{String, 1}`
            - キャプチャされた部分文字列の配列
        - `RegexMatch.offset: Int64`
            - 一致が始まるオフセット
        - `RegexMatch.offsets: Array{Int64, 1}`
            - ベクトルとしてキャプチャされた部分文字列のオフセットの配列


```julia
pattern = r"(a|b)(c)?(d)"
typeof(pattern)
```




    Regex




```julia
m = match(pattern, "acd")
```




    RegexMatch("acd", 1="a", 2="c", 3="d")




```julia
println(m.match)
println(m.offset)
println(m.captures)
println(m.offsets)
```

    acd
    1
    Union{Nothing, SubString{String}}["a", "c", "d"]
    [1, 2, 3]



```julia
# 大文字小文字無視, 複数行マッチング
## 以下のような文字列にマッチ
### "a" or "A" から始まる
### その後ろのどこか（途中改行可）に "b" or "B" が含まれる
### 行末が "d" or "D" で終わる
pattern = r"a+.*b+.*d$"ism

target = """
Goodbye,
Oh,
angry,
Bad world
"""

match(pattern, target)
```




    RegexMatch("angry,\nBad world")



### 文字列置換
`replace`関数を使い、文字列を置換できる

```julia
replace(置換対象文字列::String, 置換パターン::Pair{Pattern, Replaced}; count::Integer=typemax(Int))
```

`Pair` 型は2つの値をセットで保持する型で、以下のような書き方ができる

```julia
# 通常のPairコンストラクタ
Pair("a", "A")
## -> "a" => "A"

# 簡易記法で `値1 => 値2` という書き方もできる
("val" => 123)
## -> "val" => 123
```

上記のような `Pair` 型で `置換前のパターン => 置換後の文字列` を指定することで文字列の置換ができる

```julia
# 全ての"a"を"A"に置換
replace("apple banana", Pair("a", "A"))
## -> "Apple bAnAnA"

# "a"を1つだけ"A"に置換
replace("apple banana", "a" => "A"; count=1)
## -> "Apple banana"

# 正規表現による置換
## Replacedには関数を渡すことが可能
replace("apple banana", Pair(r"\s([a-z])", uppercase))
## -> "apple Banana"

# Replaced: special substring
## s"\n" で n番目のキャプチャを表現できる (n::Int)
replace("AppleBanana", r"([A-Z])" => s"_\1")
## -> "_Apple_Banana"
```


```julia
# CamelCase を snake_case に変換する
snakecase = replace("CamelCase", Pair("Camel", "Snake")) # -> "SnakeCase"
println(snakecase)

snakecase = replace(snakecase, r"([A-Z])" => c -> "_" * lowercase(c)) # -> "_snake_case"
println(snakecase)

snakecase = replace(snakecase, r"^_" => s"") # -> "snake_cake"
println(snakecase)
```

    SnakeCase
    _snake_case
    snake_case


## シンボル

Juliaには `:symbol` で表現される `Symbol`型が存在する

これは、メタプログラミングにおける変数を表すもので、自身のコードをプログラムで操作することができる

`:(...)` もしくは `quote ... end` でコードラップすることで、そのコード自身を表現するデータ構造が生成される


```julia
println(:foo) # -> foo
println(typeof(:foo)) # -> Symbol
```

    foo
    Symbol



```julia
# (x + 1) という式をデータ構造として保持する
fx = :(x + 1)

# コードラップされた式の型 -> Expr
typeof(fx)

# データ構造を詳細表示
"""
Expr: (x + 1)
    - 数値 1 をスタック
        - Stack: [1]
    - シンボル x をスタック
        - 例えば x が 数値 10 を保持する変数であれば、10がスタック
        - Stack: [10, 1]
    - シンボル + をスタック
        - 例えば + が 2つの数値を引数として 合計値を返す関数であれば
            - スタックから2つの値を取り出す
                - 10, 1 <- Stack: []
            - 合計値をスタック: 10 + 1 = 11
                - Stack: [11]
"""
dump(fx)
```




    Base.dump



### 連想配列
他の言語には、特定の名前のキーに値が関連づいている連想配列というものがある

- 例: Python
    ```python
    human = {
        "name": "Tom", # 名前 = "Tom"
        "sex": "Male", # 性別 = 男性
        "age": 20      # 年齢 = 20 歳
    }
    
    # 年齢を取得 -> 20
    human["age"]
    ```
- Julia
    ```julia
    human = Dict(
        "name" => "Tom", # 名前 = "Tom"
        "sex" => "Male", # 性別 = 男性
        "age" => 20      # 年齢 = 20 歳
    )
    
    # 年齢を取得 -> 20
    human["age"]
    ```

これは要するに `Pair` 型の配列（`Vector` 型）であるため、`Vector{Pair{T,N}}` とほぼ同じ構造をしている

```julia
Dict(Pair("name", "Tom"), "sex" => "Male")
## => Dict{String, String} with 2 entries:
##     "name" => "Tom"
##     "sex" => "Male"

[Pair("name", "Tom"), "sex" => "Male"]
## => 2-element Vector{Pair{String, String}}:
##     "name" => "Tom"
##     "sex" => "Male"
```


他の言語では、キーは 文字列 or 数値 で表現するしかなかったが、Juliaではシンボルで表現することもできる


```julia
# human連想配列定義
human = Dict(:name => "Tom", :sex => :Male, :age => 20)
println(human)

# humanの `age`シンボルキーを取得 -> 20
println(human[:age])
```

    Dict{Symbol, Any}(:sex => :Male, :age => 20, :name => "Tom")
    20



```julia
# 正規表現でグループ名をつけてキャプチャした際
## グループ名はシンボルとして定義される
## -> そのシンボルキーにキャプチャされた文字列が紐付けられる
m = match(r"(?<hour>\d+):(?<minute>\d+)", "12:45")
```




    RegexMatch("12:45", hour="12", minute="45")




```julia
println(m[:hour])
println(m[:minute])
```

    12
    45



```julia

```
