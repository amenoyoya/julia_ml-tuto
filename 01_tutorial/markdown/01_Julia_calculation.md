# Julia入門

## 変数

- **変数**
    - Juliaにおける変数は、値に紐づく名前を示す
    - 計算によって得た値などを保存しておくために使用する


```julia
# 変数 x に 値 10 を保存しておく
x = 10
```




    10




```julia
# 変数 x に 1 を足す
x + 1
```




    11




```julia
# 変数には別の型を入れ直すこともできる
## 現在、変数 x には 数値 10 が入っているが、文字列 "Hello!" を入れ直すことが可能
x = "Hello!"
```




    "Hello!"



### 使用可能な変数名

- アルファベット（a-z, A-Z）
- 数字（0-9）
- `_`, `!`, ...等の記号
- Unicode文字

ただし、ビルトインステートメントの名前（`if`, `else`, ...等）を変数名として使用することはできない

また、`+`, `-` 等の演算子記号も変数名として定義されてはいるが、再割り当てを行うことはできない


```julia
else = 3.14
```


    syntax: unexpected "else"

    

    Stacktrace:

     [1] top-level scope

       @ In[4]:1

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
try = "No"
```


    syntax: unexpected "="

    

    Stacktrace:

     [1] top-level scope

       @ In[5]:1

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
(+) = function (a, b)
    return a - b
end
```


    cannot assign a value to variable Base.+ from module Main

    

    Stacktrace:

     [1] top-level scope

       @ In[6]:1

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094


## 数値

### 数値プリミティブ型
- **数値**
    - 整数と浮動小数点があり、演算処理の基本的要素となっている
    - コード内では、整数（1, 2, ...）は即値、浮動小数点（1.0, 1.1, ...）は数値リテラルと呼ばれる
        - 即値と数値リテラルを合わせて数値プリミティブと呼ぶ
 
#### 整数型
型      | 符号の有無 | バイト数 | 最小値   | 最大値
:--     |    :--     |   :--    |   :--    |   :--
Int8    |     o      |     8    |   -2^7   |   2^7 - 1
UInt8   |     x      |     8    |      0   |   2^8 - 1
Int16   |     o      |    16    |  -2^15   |  2^15 - 1
UInt16  |     x      |    16    |      0   |  2^16 - 1
Int32   |     o      |    32    |  -2^31   |  2^31 - 1
UInt32  |     x      |    32    |      0   |  2^32 - 1
Int64   |     o      |    64    |  -2^63   |  2^63 - 1
UInt64  |     x      |    64    |      0   |  2^64 - 1
Int128  |     o      |   128    | -2^127   | 2^127 - 1
UInt128 |	  x      |   128    |      0   | 2^128 - 1
Bool    |   N/A      |     8    | false(0) |  true(1)

#### 浮動小数点
型      |  精度  | バイト数 　　　　
:--     |  :--   |  :--
Float16 |  half	 |   16
Float32 | single |   32
Float64 | double |   64

#### 特殊な浮動小数点値
Float16 | Float32 | Float64 |    名称    |  概要
:--     |  :--    |  :--    |    :--     |  :--
 Inf16  |  Inf32  |  Inf    | 正の無限大 | 全ての有限の浮動小数点値よりも大きい値
-Inf16  | -Inf32  | -Inf    | 負の無限大 | 全ての有限の浮動小数点数値よりも小さい値
 NaN16  |  NaN32  |  NaN    |   非数値   | 浮動小数点値以外の値


```julia
# Systemが32bitか64bitか確認
## -> Int32: 32bit, Int64: 64bit
typeof(1)
```




    Int64




```julia
# 内部変数 Sys.WORD_SIZE でも　System bit を判別できる
Sys.WORD_SIZE
```




    64




```julia
# 整数型いろいろ
println(typeof(3000000000))
println(typeof(0xff)) # 16進数 ff -> 10進数 255
println(typeof(0x123)) # 16進数 123 -> 10進数 291

# 2進数 10 -> 10進数 2
println(0b10)

# 8進数 10 -> 10進数 8
println(0o10)
```

    Int64
    UInt8
    UInt16
    2
    8



```julia
# 数値プリミティブ型の最小値、最大値を取得
for T in [Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128]
    println("$(lpad(T, 7)): 最小値=$(typemin(T)), 最大値=$(typemax(T))")
end
```

       Int8: 最小値=-128, 最大値=127
      Int16: 最小値=-32768, 最大値=32767
      Int32: 最小値=-2147483648, 最大値=2147483647
      Int64: 最小値=-9223372036854775808, 最大値=9223372036854775807
     Int128: 最小値=-170141183460469231731687303715884105728, 最大値=170141183460469231731687303715884105727
      UInt8: 最小値=0, 最大値=255
     UInt16: 最小値=0, 最大値=65535
     UInt32: 最小値=0, 最大値=4294967295
     UInt64: 最小値=0, 最大値=18446744073709551615
    UInt128: 最小値=0, 最大値=340282366920938463463374607431768211455



```julia
# アンダースコアは桁区切り文字として使用可能
10_000, 0.000_000_005, 0xdead_beef, 0b1011_0010
```




    (10000, 5.0e-9, 0xdeadbeef, 0xb2)




```julia
# 浮動小数点には +0.0 と -0.0 がある
## 2つは同一の値だが、異なるバイナリ表現をもつ（最上位ビットで正負を表現）
println(+0.0 == -0.0)
println(bitstring(+0.0))
println(bitstring(-0.0))
```

    true
    0000000000000000000000000000000000000000000000000000000000000000
    1000000000000000000000000000000000000000000000000000000000000000



```julia
# 1÷無限 -> 0
println(1 / Inf)

# 1÷0 -> 無限
println(1 / 0)

# -5÷0 -> -無限
println(-5 / 0)

# 0÷0 -> 計算できない
println(0 / 0)

# 無限÷無限 -> 計算できない
print(Inf / Inf)
```

    0.0
    Inf
    -Inf
    NaN
    NaN

### 計算機イプシロン

- **計算機イプシロン**
    - 1より大きい最小の数と1との差のこと
    - 実数の差は無限に小さいため、計算機では正確に表現できない
        - -> 計算機で表現可能な最小の浮動小数点間の距離を計算機イプシロンとして表現する
    - Juliaにおける計算機イプシロンは `eps` 関数で取得可能
        - 32bit浮動小数点の計算機イプシロン: 2.0^-23 = 1.1920929e-7
        - 64bit浮動小数点の計算機イプシロン: 2.0^-52 = 2.220446049250313e-16


```julia
# Float32の計算機イプシロン
println(eps(Float32))

# Float64の計算機イプシロン
println(eps(Float64))
```

    1.1920929e-7
    2.220446049250313e-16



```julia
x = 1.25f0

# 1.25より大きい最小の値を取得 -> 1.2500001
println(nextfloat(x))

# 1.25より小さい最大の値を取得 -> 1.2499999
println(prevfloat(x))
```

    1.2500001
    1.2499999


### 数値リテラル

Juliaでは変数を使った乗算などを、より一般的な数式表現で記述することができる

```julia
1.5 * x^2 - 0.5 * x + 1
==
1.5x^2 - .5x + 1
```


```julia
x = 3

1.5 * x^2 - 0.5 * x + 1
```




    13.0




```julia
1.5x^2 - .5x + 1
```




    13.0




```julia
2(x - 1)^2 - 3(x - 1) + 1
```




    3




```julia
# ただし、乗算を示すためにカッコの前に変数やカッコ式を置くことはできない
## <- カッコが後ろにある式は 関数 と解釈されるため
x(x-1)(x+1)
```


    MethodError: objects of type Int64 are not callable

    

    Stacktrace:

     [1] top-level scope

       @ In[19]:3

     [2] eval

       @ .\boot.jl:360 [inlined]

     [3] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094


## 演算子

### 算術演算子
以下の算術演算子は全ての数値プリミティブ型でサポートされている

式      |    名称    |   概要
:--     |    :--     |   :--
`+x`    | 単一項加法 | 恒等作用素
`-x`    | 単一項減法 | 値を逆数と関連付ける
`x + y` | 二項加法   | 加法を実施
`x - y` | 二項減法   | 減法を実施
`x * y` | 乗法       | 乗法を実施
`x / y` | 除法       | 除法を実施 (`÷`でもOK)
`x \ y` | 逆数除法   | `y / x` と同等
`x ^ y` | 累乗       | xをy分だけ掛ける
`x % y` | 余り       | `rem(x,y)` と同等

`Bool(@ref)`型の否定形についても同様

式       | 名称   | 概要
:--      | :--    | :--
`!x`     | 否定形 | `true`を`false`に, `false`を`true`に変換する
`x && y` |  AND   | x と y が両方`true`の場合に`true`として評価される
`x｜｜y` |  OR    | x と y のいずれかが`true`の場合に`true`として評価される


### ビット演算子
以下のビット演算子は全ての数値プリミティブ型でサポートされている

式        |    名称
:--       |    :--
`~x`      | ビット単位の否定
`x & y`   | ビット単位の論理積
`x｜y`    | ビット単位の論理和
`x ⊻ y`   | ビット単位の排他的論理和（`xor`関数でもOK）
`x >>> y` | 論理右桁送り
`x >> y`  | 算術右桁送り
`x << y`  | 論理/算術左桁送り

### 更新演算子
更新演算子: 変数の値を更新する演算子

`<変数名> <演算子>'=' <値>` は `<変数名> '=' <変数名> <演算子> <値>` と等価

更新機能を持つ演算子は以下の通り

```
+=  -=  *=  ÷=  /=  \=  %=  ^=  &=  |=  ⊻=  >>>=  >>=  <<=
```


```julia
# (1 + 2) * 3 * 4 / 6 
println((1 + 2) * 3 * 2^2 ÷ 6)

# 余り
## 9 % 2 = 1
println(rem(9, 2))
```

    6
    1



```julia
# ビット演算
## AND: 1 & 1 のみ 1, それ以外は 0
println([0 & 0, 0 & 1, 1 & 0, 1 & 1])

## OR: 0 | 0 のみ 0, それ以外は 1
println([0 | 0, 0 | 1, 1 | 0, 1 | 1])

## XOR: 0と1の組み合わせのときのみ 1, 同一の組み合わせなら 0
println([0 ⊻ 0, xor(0, 1), 1 ⊻ 0, xor(1, 1)])
```

    [0, 0, 0, 1]
    [0, 1, 1, 1]
    [0, 1, 1, 0]



```julia
# 更新機能を使うと変数の型が変わることがある

# x = 1: UInt8
x = 0x01
println(x)
println(typeof(x))

# x = x * 2 = 2: Int64
x *= 2
println(x)
println(typeof(x))
```

    1
    UInt8
    2
    Int64



```julia
# ドット演算子: ベクトル計算
## 配列など、数値の固まりに対してドット演算子と算術演算子を適用すると
## 固まりの各数値に対して算術演算を行うことができる

# [1^3, 2^3, 3^3] = [1, 8, 27]
[1, 2, 3] .^ 3
```




    3-element Vector{Int64}:
      1
      8
     27



### 比較演算子
以下の比較演算子は全ての数値プリミティブ型でサポートされている

演算子     |  名称
:--        |  :--
`==`       | 等しい
`!=`, `≠` | 等しくない
`<`        | より小さい
`<=`, `≤` | より大きい
`>`        | 以下
`>=`, `≥` | 以上

ハッシュ値の比較など、特別な値を比較するには比較演算子を使うことができないため、以下のような関数を使う

関数            |   検証内容
:--             |   :--
`isequal(x, y)` | x および y は一致するか
`isfinite(x)`   | x は有限数であるか
`isinf(x)`      | x は無限であるか
`isnan(x)`      | x は数字以外であるか


```julia
println(1 == 2) # false
println(1 != 2) # true
println(1 == 1.0) # true
println(-1 <= -1) # true
println(-1 <= -2) # false
println(3 < 0.5) # false
```

    false
    true
    true
    true
    false
    false



```julia
println(isequal(NaN, NaN)) # true
println([1 NaN] == [1 NaN]) # false: 配列の比較を演算子で行うことはできない
println(isequal([1 NaN], [1 NaN])) # true
```

    true
    false
    true



```julia
# 符号付き0を区別する際も isequal を使う
println(-0.0 == 0.0) # true
println(isequal(-0.0, 0.0)) # false
```

    true
    false



```julia
# 連続した比較を行うこともできる
1 < 2 <= 3 > 2.5
```




    true



### 演算子の優先順位
演算子の優先順位は高いものから順に以下のようになっている

式           |                         演算子                         | 優先順位
:--          |                         :--                            | :--
構文         | `::` を伴う `.`                                        | 高い
累乗         | `^`                                                    |
分数         | `//`                                                   |
乗法         | `* / % & \`                                            |
ビットシフト | `<< >> >>>`                                            |
加法         | `+ - ｜ ⊻`                                            |
構文         | `｜>`を伴う `: ..`                                     |
比較         | `> < >= <= == === != !== <:`                           |
制御フロー	| `｜` および `?` を伴う `&&`                            |
割り当て     |`= += -= *= /= //= \= ^= ÷= %= ｜= &= ⊻= <<= >>= >>>=`| 低い

### 数値処理関数

#### 数値変換
- `T(x)`, `convert(T, x)`:
    - `x`を`T`型の値に変換する
    - `T`が浮動小数点型の場合、変換の結果は最も近い表現可能な値になる
    - `T`が整数型の場合、`x`が`T`で表現できない際は`InexactError`が発生する
- `x % T`:
    - 整数`x`を法とする `2^n` (`n`は`T`のビット数)に一致する整数型`T`の値に変換する

#### 端数処理関数
関数          |                 概要                 | 戻り値の型
:--           |                 :--                  | :--
`round(x)`    | x を最も近い整数になるよう丸めを行う | `typeof(x)`
`round(T, x)` | x を最も近い整数になるよう丸めを行う | `T`
`floor(x)`    | x を -Inf に向かって丸めを行う       | `typeof(x)`
`floor(T, x)` | x を -Inf に向かって丸めを行う       | `T`
`ceil(x)`     | x を +Inf に向かって丸めを行う       | `typeof(x)`
`ceil(T, x)`  | x を +Inf に向かって丸めを行う       | `T`
`trunc(x)`    | x を0に向かって丸めを行う            | `typeof(x)`
`trunc(T, x)` | x を0に向かって丸めを行う            | `T`

#### 除算関数
関数        |   概要
:--         |   :--
`div(x,y)`  | 0に向かって丸めを行う除算
`fld(x,y)`  | 床関数のように -Inf に向かって丸めを行う除算
`cld(x,y)`  | 天井関数のように +Inf に向かって丸めを行う除算
`rem(x,y)`  | 余り; `x == div(x,y)*y + rem(x,y)` を満たす; 記号は x と一致
`mod(x,y)`  | 剰余演算; `x == fld(x,y)*y + mod(x,y)` を満たす; 記号は y と一致
`mod1(x,y)` | オフセットが1の`mod()`

#### 符号と絶対値関数
関数            | 概要
:--             | :--
`abs(x)`        | 絶対値 x の正の値
`abs2(x)`       | 絶対値 x の2乗
`sign(x)`       | x の符号を示し、 -1、 0、 または +1を返す
`signbit(x)`    | 符号ビットがオン（true）またはオフ（false）であるかを示す
`copysign(x,y)` | 絶対値 x と符号 y を持つ値
`flipsign(x,y)` | 絶対値 x と符号 x*y を持つ値

#### 累乗、対数、根
関数             | 概要
:--              | :--
`sqrt(x)`, `√x` | x の平方根
`cbrt(x)`, `∛x`  | x の立方根
`hypot(x,y)`     | 長さ x および y をその他の辺に持つ直角三角形の斜辺
`exp(x)`         | x における自然指数関数
`expm1(x)`       | 0に近い x の正確な `exp(x)-1` の結果
`ldexp(x,n)`     | n の整数値に対して効率的に計算された `x*2^n`
`log(x)`         | x の自然対数
`log(b,x)`       | b を底とした x の対数
`log2(x)`        | 2を底とした x の対数
`log10(x)`       | 10を底とした x の対数
`log1p(x)`       | 0に近い x の正確な `log(1+x)` の結果
`exponent(x)`    | x の2進指数
`significand(x)` | 浮動小数点数 x の2進仮数

#### 三角関数と双曲線関数
以下はラジアン単位の引数をとる三角関数、双曲線関数

```
sin    cos    tan    cot    sec    csc
sinh   cosh   tanh   coth   sech   csch
asin   acos   atan   acot   asec   acsc
asinh  acosh  atanh  acoth  asech  acsch
sinc   cosc   atan2
```

ラジアンではなく角度で三角関数を計算するためには、 `d`を関数の末尾に付与する

```
sind   cosd   tand   cotd   secd   cscd
asind  acosd  atand  acotd  asecd  acscd
```

#### 特殊な関数
関数         |    概要
:--          |    :--
`gamma(x)`   | x における ガンマ関数
`lgamma(x)`  | 大きな値 x における `log(gamma(x))`
`lfact(x)`   | 大きな値 x における `log(factorial(x))`
`beta(x,y)`  | x, y における ベータ関数
`lbeta(x,y)` | 大きな値 x または y における正確な `log(beta(x,y))`


```julia
# 数値を文字列に変換
println(typeof(100), " => ", typeof(string(100)))
```

    Int64 => String



```julia
# 浮動小数点を整数に変換
# => 整数型で表現できない場合、エラーが発生する
println(convert(Int, 3.1415))
```


    InexactError: Int64(3.1415)

    

    Stacktrace:

     [1] Int64

       @ .\float.jl:723 [inlined]

     [2] convert(#unused#::Type{Int64}, x::Float64)

       @ Base .\number.jl:7

     [3] top-level scope

       @ In[29]:3

     [4] eval

       @ .\boot.jl:360 [inlined]

     [5] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)

       @ Base .\loading.jl:1094



```julia
# sin(θ)^2 + cos(θ)^2 = 1
println(sin(10)^2 + cos(10)^2)
```

    1.0



```julia
# ドット演算子（ベクトル計算）は数値処理関数に対しても適用可能

# abs.([-1, -2, 3, 4, -5]) => [abs(-1), abs(-2), abs(3), abs(4), abs(-5)]
println(abs.([-1, -2, 3, 4, -5]))
```

    [1, 2, 3, 4, 5]



```julia

```
