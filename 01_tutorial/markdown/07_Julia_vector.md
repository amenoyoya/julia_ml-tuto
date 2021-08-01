# Juliaにおける配列・行列関連操作まとめ

## 配列

### 一次元配列
Juliaにおいて、配列とは一次元配列であり、`[要素, 要素, ...]` のように `,` 区切りで表現される

なお、一次元配列とは列ベクトルを表しているため注意が必要（Julia以外の大抵の言語では、一次元配列は行ベクトルとなっている）


```julia
[1, 3, 4]
```




    3-element Vector{Int64}:
     1
     3
     4



### 固定長配列の作成
固定長配列の作成方法は以下のようにいくつか用意されている

- Vector型のコンストラクタ: `Vector{型}(undef, 要素数)`
    - 要素数分、任意の値で埋めた配列が生成される
- zeros: `zeros([型,] 要素数)`
    - 要素数分 0 で埋めた配列が生成される
- ones: `ones([型,] 要素数)`
    - 要素数分 1 で埋めた配列が生成される
- fill: `fill(要素, 要素数)`
    - 要素数分、指定要素で埋めた配列が生成される


```julia
a = Array{Float64, 1}(undef, 3)
println("a: $(typeof(a)) $(a)")

z = zeros(2)
println("z: $(typeof(z)) $(z)")

o = ones(4)
println("o: $(typeof(o)) $(o)")

f = fill(1.23, 5)
println("f: $(typeof(f)) $(f)")
```

    a: Vector{Float64} [5.0e-324, 0.0, 6.89896358286034e-310]
    z: Vector{Float64} [0.0, 0.0]
    o: Vector{Float64} [1.0, 1.0, 1.0, 1.0]
    f: Vector{Float64} [1.23, 1.23, 1.23, 1.23, 1.23]



```julia
"""
連番、等差数列の作成
"""
# start:end
a = Vector{Int}(1:3) # = Array{Int,1}(1:3)
println("a: $(typeof(a)) $(a)")

# start:step:end
b = Vector(1:2:5)
println("b: $(typeof(b)) $(b)")

# リスト表記も可能（末尾の ; を忘れないように）
c = [1:2:5;]
println("c: $(typeof(c)) $(c)")

# collect関数
d = collect(1:2:5)
println("d: $(typeof(d)) $(d)")

# リスト内包表記
e = [
    if v % 15 === 0
        "Fizz Buzz"
    elseif v % 5 === 0
        "Buzz"
    elseif v % 3 === 0
        "Fizz"
    else
        string(v)
    end
    for v in 1:15]
println("e: $(typeof(e)) $(e)")
```

    a: Vector{Int64} [1, 2, 3]
    b: Vector{Int64} [1, 3, 5]
    c: Vector{Int64} [1, 3, 5]
    d: Vector{Int64} [1, 3, 5]
    e: Vector{String} ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "Fizz Buzz"]


## 行列

### 二次元配列
一次元以上の配列もまた、一次元配列と同様の方法で作成できる

ただし、各要素（列）は空白で区切り、行を追加するなら `;` または 改行 を使う

なお、バージョン 1.6.1 時点で、多次元配列は `Array` 型ではなく `Matrix` 型として定義されている


```julia
a = [1 3 4]
println("a: $(size(a,1))×$(size(a,2)) $(typeof(a)) $(a)")

b = [1; 3; 4]
println("a: $(size(b,1))×$(size(b,2)) $(typeof(b)) $(b)")

c = [1 2 3; 4 5 6]
println("b: $(size(c,1))×$(size(c,2)) $(typeof(c)) $(c)")

d = [1 2 3
    4 5 6]
println("c: $(size(d,1))×$(size(d,2)) $(typeof(d)) $(d)")
```

    a: 1×3 Matrix{Int64} [1 3 4]
    a: 3×1 Vector{Int64} [1, 3, 4]
    b: 2×3 Matrix{Int64} [1 2 3; 4 5 6]
    c: 2×3 Matrix{Int64} [1 2 3; 4 5 6]



```julia
"""
ベクトル（一次元配列）から行列（二次元配列）に変換
"""
# 一次元配列 [1, 2, 3]
a = Vector(1:3)
println("a: $(size(a,1))×$(size(a,2)) $(typeof(a)) $(a)")

# 軸追加による行列化
## 3x1-Vector => 3x1-Matrix に変換される
b = a[:, :]
println("b: $(size(b,1))×$(size(b,2)) $(typeof(b)) $(b)")

# 列を追加することによる行列化
c = [a Vector(4:6)]
println("c: $(size(c,1))×$(size(c,2)) $(typeof(c)) $(c)")

## 列の追加＝水平結合のため hcat でも可
d = hcat(a, Vector(4:6))
println("d: $(size(d,1))×$(size(d,2)) $(typeof(d)) $(d)")
```

    a: 3×1 Vector{Int64} [1, 2, 3]
    b: 3×1 Matrix{Int64} [1; 2; 3]
    c: 3×2 Matrix{Int64} [1 4; 2 5; 3 6]
    d: 3×2 Matrix{Int64} [1 4; 2 5; 3 6]


## 要素アクセス

N次元配列（テンソル）へのアクセスは以下のように添字で行う

```
tensor[1次元目のindex, 2次元目のindex, ..., N次元目のindex]
```

なお特殊な添字として `end` は、配列の最後の要素を示す


```julia
a = [1:2:5;] # => [1, 3, 5]

# 2(列目)の要素にアクセス
println("a[2]: $(a[2])")

# 最後の要素にアクセス
println("a[end]: $(a[end])")

b = [1 2 3; 4 5 6]

# 2行目, 3列目 の要素にアクセス
println("b[2,3]: $(b[2,3])")

# 1行目の2〜3列目の要素にアクセス
println("b[1, 2:3]: $(b[1, 2:3])")

# 3列目のすべての要素にアクセス
println("b[:, 3]: $(b[:, 3])")
```

    a[2]: 3
    a[end]: 5
    b[2,3]: 6
    b[1, 2:3]: [2, 3]
    b[:, 3]: [3, 6]



```julia
"""
要素検索
"""
# [1, 4, 7, 10]
a = [1:3:10;]

# 特定条件の要素を検索することができる
## 各演算子は、ドット(.)演算子を使い、テンソルの各要素に対する演算に変換する必要がある
even = a[a .% 2 .=== 0] # 偶数のみ検索
println("even: $(even)")

# 特定条件の要素のindexは、findall で検索することができる
indexes = findall(a .% 2 .=== 1) # 奇数の要素のindexを取得
println("indexes: $(indexes)")

# index配列を添字にしても要素を取得できる
odd = a[indexes]
println("odd: $(odd)")
```

    even: [4, 10]
    indexes: [1, 3]
    odd: [1, 7]


## ベクトルの変形

### 次元変形
次元変形は、次元数の合計を変更せずに各次元数を変更することである

次元変形には、`reshape`関数を使う

これにより、例えば、1×6の行列を2×3の行列に変形することができる


```julia
# 1x6 Matrix{Int64}
a = [1 2 3 4 5 6]
println("a: $(size(a,1))×$(size(a,2)) $(typeof(a)) $(a)")

# 1x6 => 2x3 に次元変形
b = reshape(a, 2, 3)
println("b: $(size(b,1))×$(size(b,2)) $(typeof(b)) $(b)")
```

    a: 1×6 Matrix{Int64} [1 2 3 4 5 6]
    b: 2×3 Matrix{Int64} [1 3 5; 2 4 6]


### 転置行列
行列の行と列を入れ替えた行列を転置行列と呼ぶ

転置行列は、`'`演算子もしくは`transpose`関数で求めることができる


```julia
a = [1 2 3; 4 5 6; 7 8 9]

# 転置行列: transpose(a) でも可
a'
```




    3×3 adjoint(::Matrix{Int64}) with eltype Int64:
     1  4  7
     2  5  8
     3  6  9



### 入れ子配列の行列化
C言語等、テンソルを `Array{Array{Type, 1}, 1}` のような入れ子配列で表す言語に慣れていると、Juliaの行列がよくわからなくなることが多い

そのような時は、一旦入れ子配列にした後で行列化するという操作が必要になる

この操作は、基本的には、水平全結合（`hcat(vec...)`）もしくは垂直全結合（`vcat(vec...)`）を使えば実現できる


```julia
# 2-Array{3-Array{Int64}}
a = [
    [1, 2, 3],
    [4, 5, 6],
]
dump(a)

# 6x1-Vector{Int64} にしたい場合: vcat
v = vcat(a...)
println("v: $(size(v,1))×$(size(v,2)) $(typeof(v)) $(v)")

# 3x2-Matrix{Int64} にしたい場合: hcat
h = hcat(a...)
println("h: $(size(h,1))×$(size(h,2)) $(typeof(h)) $(h)")

# 2x3-Matrix{Int64} にしたい場合
## vcat |> reshape
v = reshape(vcat(a...), 2, 3)
println("v: $(size(v,1))×$(size(v,2)) $(typeof(v)) $(v)")

## 水平結合後、転置行列を求める
h = hcat(a...) |> transpose
println("h: $(size(h,1))×$(size(h,2)) $(typeof(h)) $(h)")
```

    Array{Vector{Int64}}((2,))
      1: Array{Int64}((3,)) [1, 2, 3]
      2: Array{Int64}((3,)) [4, 5, 6]
    v: 6×1 Vector{Int64} [1, 2, 3, 4, 5, 6]
    h: 3×2 Matrix{Int64} [1 4; 2 5; 3 6]
    v: 2×3 Matrix{Int64} [1 3 5; 2 4 6]
    h: 2×3 LinearAlgebra.Transpose{Int64, Matrix{Int64}} [1 2 3; 4 5 6]


## 行列の内積

行列の内積は `tensorA * tensorB` で表され、行列の各要素の乗算である `tensorA .* tensorB` とは明確に区別される

内積は、被乗数Aの列と乗数Bの行が同サイズである必要があるが、各要素の乗算では、被乗数Aと乗数Bの行・列ともに同サイズである必要がある

例えば、2×3行列A`(1 2 3; 4 5 6)` と 3×1行列B`(9; 8; 7)` は内積を計算することはできるが、各要素の乗算を行うことはできない


```julia
A = [1 2 3; 4 5 6]
B = [9; 8; 7]

# 内積: [1*9 + 2*8 + 3*7; 4*9 + 5*8 + 6*7]
A * B
```




    2-element Vector{Int64}:
      46
     118




```julia
A = [1 2; 3 4]
B = [5 6; 7 8]

# 各要素の乗算: [1*5 2*6; 3*7 4*8]
A .* B
```




    2×2 Matrix{Int64}:
      5  12
     21  32




```julia

```
