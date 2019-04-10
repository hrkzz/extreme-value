---
title: Rを使って極値理論をファイナンスへ応用してみた（その２）
tags: R 統計学 データ分析 ファイナンス
author: hrkz_szk
slide: false
---
その１はこちら（極値理論の簡単な解説、Block maximaの実装を行っています）
<https://qiita.com/hrkz_szk/items/43debffda9697d9dd7a9>

# r-block maximaモデル
Block maximaでは最大値のみを抽出しましたが、問題となるのはサンプル数。特にファイナンス系のデータの場合、数十年単位で最大値を確保できないことが多いです。そこで、r-block maximaモデルとThresholdモデルがその対処法になります。r-block maximaは、上からr個の値を抽出します。例えば、2-block maximaモデルでは、最大値とその次に大きい値を抽出します。Thresholdモデルは次回紹介したいと思いますが、これらを統合したのが点過程というモデルです。

### データ
ここでは、BMWの株価の損失について、2-block maximaモデルで推定していきたいと思います。具体的に、1年ごとの最大値とその次に大きい値を抽出し、`ismev`の`rlarg.fit`を使ってGEV分布への推定を行います。
データに関しては、`evir`というパッケージにある`data(bmw)`を使用します。こちらは1973年1月2日から1996年7月23日におけるBMW社の株価のログリータンが`vector`で入っています。

```r
library(evir)
data("bmw")
head(bmw)

[1]  0.047704097  0.007127223  0.008883307 -0.012440569 -0.003569961  0.000000000
```

```r
plot(bmw, t="l")
```

<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/f03c6dd1-a1e0-5f24-9480-2d821499738e.png">

### データの抽出
ログリータンをプラスの損失に変換し、さらにパーセント表示に変換。その後、一年間の最大値とその次に大きい値を抽出。

```r
BmwLoss <- -1.0 * bmw * 100 
Years <- format(attr(BmwLoss, "time"), "%Y")
attr(BmwLoss, "years") <- Years
Yearu <- unique(Years)
idx <- 1:length(Yearu)
r <- 2
BmwOrder <- t(sapply(idx, function(x)
              head(sort(BmwLoss[attr(BmwLoss, "years") == Yearu[x]], decreasing = TRUE), r)))
rownames(BmwOrder) <- Yearu
colnames(BmwOrder) <- paste("r", 1:r, sep = "")
```

### サンプルの分布
```r
plot(Yearu, BmwOrder[, 1], col = "black", ylim = range(BmwOrder),
     ylab = "Losses BMW (percentages)", xlab = "",
     pch = 20, bg = "black")
points(Yearu, BmwOrder[, 2], col = "blue", pch = 20, bg = "blue")
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/68fb9ebe-9587-99db-eb38-c671302e4c94.png">

### 推定
```r
library(ismev)
BmwOrderFit <- rlarg.fit(BmwOrder)

$conv
[1] 0

$nllh
[1] 77.76214

$mle
[1] 4.4798274 1.7524702 0.3034724

$se
[1] 0.3411369 0.2891531 0.1587266
```
`conv`のゼロは、うまく推定されたことを示しています。`nllh`はマイナスのログ尤度の最小値で、`mle`が尤度関数を用いて推定されたパラメータ、`se`はパラメータの標準誤差になります。$\xi$が0.3034724とプラスなので、今回の分布はFrechet分布に従うことが分かります。このため、この分布はヘビーテイルであり、損失が有限ではないということになります。

### パラメータの検証
#### 信頼区間
私の知る限り`ismev`にはパラメータの信頼区間を自動的に計算してくれるコードを知らないので、ここでは原始的な方法で95%の信頼区間を求めてみます。

```r
lower <- BmwOrderFit$mle - 1.96*BmwOrderFit$se
upper <- BmwOrderFit$mle + 1.96*BmwOrderFit$se
data.frame(lower=lower, upper=upper, row.names = c("mu", "sigma", "xi"))
```
|   |lower  |upper  |
|---|---|---|
|mu  |3.811199061  |5.1484558  |
|sigma  |1.185730115  |2.3192103  |
|xi  |-0.007631649  |0.6145765  |

muとsigmaはゼロをまたいでいませんが、最も大切なxiがゼロの可能性が。しかし、ゼロをまたいでいると行ってもとても小さな幅なので、ここでは深追いはせずに…。

### モデルの検証
```r
rlarg.diag(BmwOrderFit)
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/217e9fc7-ca8d-afc4-1dbb-dbcb62a1a041.png">

Block maximaモデルの事例と同じように、Probability PlotとQuantilte Plotとともに右上の方がラインに沿っておらず、推定したモデルでは説明しきれていないことを示しています。しかし、再現レベルはサンプルデータが95%の内側に入っているので、この点は良いのかなと思います。

#### 続編
その３はこちら。Thresholdモデルを使った分析を行っています。
<https://qiita.com/hrkz_szk/items/8b01552e0e09583d4c35>

# 参考文献
<div  class="amazon Default"><div  align="left" class="pictBox"><a  target="_blank" href="https://www.amazon.co.jp/Introduction-Statistical-Modeling-Springer-Statistics/dp/1852334592?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;tag=lvdrfree-22&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=1852334592"><img  class="pict" style="margin-right:10px" align="left" hspace="5" border="0" alt="An Introduction to Statistical Modeling of Extreme Values (Springer Series in Statistics)" src="https://images-fe.ssl-images-amazon.com/images/I/41R%2BHU7X%2B4L._SL160_.jpg"></a></div><div  class="itemTitle"><a  target="_blank" href="https://www.amazon.co.jp/Introduction-Statistical-Modeling-Springer-Statistics/dp/1852334592?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;amp;tag=lvdrfree-22&amp;amp;linkCode=xm2&amp;amp;camp=2025&amp;amp;creative=165953&amp;amp;creativeASIN=1852334592">An Introduction to Statistical Modeling of Extreme Values (Springer Series in Statistics) [ハードカバー]</a></div><div  class="itemSubTxt">Stuart Coles</div><div  class="itemSubTxt">Springer</div><div  class="itemSubTxt">2001-12-15</div></div><br  style="clear:left" clear="left"><br />

<div  class="amazon Default"><div  align="left" class="pictBox"><a  target="_blank" href="https://www.amazon.co.jp/Financial-Risk-Modelling-Portfolio-Optimization/dp/1119119669?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;tag=lvdrfree-22&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=1119119669"><img  class="pict" style="margin-right:10px" align="left" hspace="5" border="0" alt="Financial Risk Modelling and Portfolio Optimization with R" src="https://images-fe.ssl-images-amazon.com/images/I/518E1j--3fL._SL160_.jpg"></a></div><div  class="itemTitle"><a  target="_blank" href="https://www.amazon.co.jp/Financial-Risk-Modelling-Portfolio-Optimization/dp/1119119669?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;amp;tag=lvdrfree-22&amp;amp;linkCode=xm2&amp;amp;camp=2025&amp;amp;creative=165953&amp;amp;creativeASIN=1119119669">Financial Risk Modelling and Portfolio Optimization with R</a></div><div  class="itemSubTxt">Bernhard Pfaff</div><div  class="itemSubTxt">Wiley</div><div  class="itemSubTxt">2016-10-03</div></div><br  style="clear:left" clear="left"><br />

