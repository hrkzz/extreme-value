---
title: Rを使って極値理論をファイナンスへ応用してみた（その３）
tags: R 統計学 データ分析 ファイナンス
author: hrkz_szk
slide: false
---
# Thresholdモデル
その２でちらっと触れましたが、今回はThresholdモデルを紹介していきます。「Financial risk modelling and portfolio optimization with R」で指摘されていますが、Block maximaやr-block maximaを使ってファイナンスのデータを扱う場合、以下の問題点が指摘されています。

- 金融商品によっては長期間のデータが確保しずらい（10年、20年超等）。サンプル数が少ないと標準誤差が大きくなってしまい、パラメータ値の信頼区間が広めに推定されてしまう。
- 極値分布を推定する際、極値（最大値、最小値）のすべてが極値として扱われる必要はない。

ということで登場するのがThresholdモデルです。ではある閾値（$u$）を設定し、それを超える値を極値（閾値超過データ）として、サンプル抽出し、分布を推定します。

# 一般化パレート分布
この際に当てはめる分布は一般化極値分布ではなく、一般化パレート分布になります。一般化パレート分布はGP($\sigma, \xi$)で表され、次の式になります。

$$
H(y)=1-(1+\xi \frac{y}{\sigma})^{-1/\xi}
$$
パラメーターは2つで、スケールを示す$\sigma$(sigma)、形状を示す$\xi$(xi)となります。この形状パラメーターは一般化極値分布と同じで、$\xi>0$のときには超過損失の上限があり、$\xi<0$のときには超過損失の上限がないということになります。そして$\xi\rightarrow0$でリミットを取るときは
$$
H(y)=1-exp(-\frac{y}{\sigma})
$$
と標記でき、パラメーターが$-\frac{1}{\sigma}$の指数分布になります。次のグラフは一般パレート分布の確率密度関数で、$\sigma$=1とし、$\xi$を色々変えてプロットしたものです。

<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/2a4457fe-60cd-90d8-0318-4f1683f2a815.png">

# データ
さて、実際にRを使ってThresholdモデルを使っていきたいと思います。今回使用するデータは`ismev`にある`dowjones`です。1995年09月11日から2000年09月07日までのDow Jones Indexの終値になります。

```r
library(ismev)
data("dowjones")
str(dowjones)

'data.frame':	1304 obs. of  2 variables:
 $ Date : POSIXt, format: "1995-09-11 01:00:00" "1995-09-12 01:00:00" ...
 $ Index: num  4705 4747 4766 4802 4798 ...
```

### 日付
極値分析にはいらないのですが、グラフが見やすくなるので、`dowjones`に格納されている日付データを`POISXct`形式で取り出しておきます。

```r
library(lubridate)
dates <- parse_date_time(x = dowjones$Date, orders ="Y-m-d H:M:S")
```

### 終値
```r
price <- dowjones$Index
plot(x=dates, y=price, t="l")
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/2d30a7e4-a476-a41e-8af3-000b7a8a5eec.png">

### ログリータン
ログリータンを計算。100をかけてパーセント標記にしています。

```r
ret <- diff(log(price))*100
plot(x=dates[-1], y=ret, t="l", xlab="year", ylab="log-return")
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/d2902dca-aea1-6888-1131-47b116dfbe73.png">

### 損失
今回はリスク管理という観点から、どれだけ大きな損失が発生するかを見ていきたいので、ログリータンをプラスの損失に変換します。

```r
loss <- -1*ret
plot(x=dates[-1], y=loss, t="l", xlab="year", ylab="log-return")
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/67b19976-35cf-6418-3e28-341093eb7b2e.png">

# 閾値の設定
### Mean Residual Life Plot
Thresholdモデルで重要なのが閾値をどのように選ぶかという点です。閾値が高すぎるとサンプル数が減ってしまい、標準誤差が大きくなってしまいますが、逆に低すぎるとモデルのバイアスが高くなってしまうというトレードオフの関係があります。ただ、慣例としてはできるだけ低く設定し、サンプル数を増やすということが行われています。
閾値の設定でよく用いられるのはMean Residual Life Plotを用いた方法です。`ismev`の`mrl.plot`を使えば一発でグラフが表示されますが、まずはそれを用いない方法で何が行われているかを確認したいと思います。
下記がMean Residual Life Plotを表示するためのコードです。1行目で候補となる閾値を選択。ここではlossの最小値から最大値の範囲で0.01刻みで、閾値を設定しています。2行目は結果を格納するベクトルです。まずはすべてゼロにし、後で更新していくようにしています。そしてforループでそれぞれの閾値ごとに、超過するサンプルの抽出を行い、そのサンプルの超過した分だけの値のみを平均にし、先ほど作ったベクトルに格納していきます。最後にプロットします。

```r
u <- seq(min(loss) , max(loss), 0.01)
mean.excess <- vector("numeric", length(u))

for(i in 1:length(mean.excess)){
  threshold.exceedances <- ret[ret > u[i]]
  mean.excess[i] <- mean(threshold.exceedances - u[i])
}

plot(x=u, y=mean.excess, t="l")
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/81058799-adf9-07a7-cc1a-04443e25ebaf.png">

`ismev`の`mrl.plot`を使うとこちら。95パーセンタイルも分かります。

```r
library(ismev)
mrl.plot(loss)
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/4fe0b022-5068-3e7f-9127-6f59c76bb3e3.png">

このグラフの解釈の仕方ですが、綺麗な線形状になっていて、95パーセンタイルの幅がそこまで広くなりすぎていないところを選択します。ここでは2を閾値として選択したいと思います。かなり主観的ではありますが…、色んな文献で指摘されています…。

### 他の方法
「An Introduction to Statistical Modeling of Extreme Values」で言われている別の方法が、何種類かの閾値を用いてGPD推定を行い、パラメーターの標準誤差を比較し、比較的標準誤差の低い中で、最大の閾値を用いたモデルを選択するというものです。ここでは上記のMRLを踏まえて、0~3の閾値を用いて、二つのパラメータとその95パーセンタイルを求めます。

```r
gpd.fitrange(ret, umin = 0, umax = 3, nint = 31)
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/21751b86-9cfa-8b66-435f-b954fb2bd181.png">

やはり閾値2を超えるあたりから標準誤差が大きくなっているので、2を閾値として選びたいと思います。

#### 閾値のまとめ
閾値を超えるサンプル数は42となりました。これは全体1303のうち、およそ3％となっています。この3%はExceedance rateと呼ばれます。

```r
# number of exceedance
num.exc <- length(loss[loss > 2])
num.exc

[1] 42


# number of complete sample
num.all <- length(loss)
num.all

[1] 1303


# exceedance prob
ex.prob <- len.sam/len.com
ex.prob

[1] 0.03223331
```

#### プロット
プロットして確認したのが、こちらです。

```r
col.exceed <- loss
col.exceed[col.exceed > 2] <- "red"
col.exceed[col.exceed <= 2] <- "black"

plot(x= dates[-1], y=loss, pch=20,
     xlab="Year", ylab="Loss of Dow Jones 30", col=col.exceed)
abline(h=2)
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/aad2d766-5fcd-1579-7fa3-ed11fa17633d.png">

# GPDへの当てはめ
`ismev`の`gpd.fit`を使って当てはめを行っていきます。

```r
fitgpd <- gpd.fit(loss, threshold = 2)

$threshold
[1] 2

$nexc
[1] 42

$conv
[1] 0

$nllh
[1] 34.16881

$mle
[1] 0.6181962 0.2943859

$rate
[1] 0.03223331

$se
[1] 0.1496050 0.1919394
```

## パラメーターの検証
### 信頼区間
前回に引き続き、同じ手法で95%信頼区間を計算します。またしても、形状パラメーターがゼロをまたいでしまっています…。

```r
low <- fitgpd$mle - 1.96*fitgpd$se
upper <- fitgpd$mle + 1.96*fitgpd$se
data.frame(low=low, upper=upper, row.names = c("sigma", "xi"))
```
|   |lower  |upper  |
|---|---|---|
|sigma  |0.32497037　|0.9114220	|
|xi  |-0.08181527  |0.6705872	|

### プロファイル尤度
ということでextRemesを使って、$\xi$のプロファイル尤度を見てみると、ギリギリゼロをまたいでいないので、一応$\xi$はゼロではないと言えます。

```r 
library(extRemes)
fitgpd2 <- fevd(loss, threshold = 2, type = "GP")
ci.fevd(fitgpd2, type = "parameter", which.par = 2, method = "proflik")

[1] "Profile Likelihood"

[1] "shape: 0.294"

[1] "95% Confidence Interval: (0.0073, 0.7859)"
```

# 再現レベル
推定された分布から、損失額の再現レベルが分かります。約10％の損失が10年に一度、約20％の損失が100年に一度起こるという推定結果になります。というか、二つのグラフとも右のすそ野の広がり方が尋常じゃないですね…。
ここでは100年に一度を再現してみましたが、100年に一度といえばリーマンショックの際によく使われた言葉です。1995年09月11日から2000年09月07日までのでデータを基にした分布約20%が最もらしい再現レベルだと伝えてくれています。2008年のダウ平均株価下落率を見てみると7~8％前後でしたので、今回のモデルはあまり精度が良くないということになるんでしょうか？いやいや、リーマンショックは100年に一度のレベルじゃないという見方も可能だと思います。というのも、1987年のブラックマンデーの際のダウ平均の下落率は約22％。モデルは良いところをついているようにも思えます。

```r
gpd.prof(fitgpd, m = 10, xlow = 5, xup = 50)
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/1bfa7dd6-64ef-ed99-95ca-32d673050770.png">

```r
gpd.prof(fitgpd, m = 100, xlow = 7, xup = 200, nint = 1000)
```
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/418ee113-1ac6-98df-6ba1-064b8c783a96.png">

# モデルの検証
最後にモデルの検証を行っていきます。

```r
gpd.diag(fitgpd)
```
<img width="800" height="600" src="https://qiita-image-store.s3.amazonaws.com/0/246473/5c626832-0c40-c787-a583-c4959ddf7529.png">

PPプロットとReturn Levelは概ね一致していますが、qqプロットは右のすそ野をうまく説明できていません。

さて、最後の最後に超過データのグラフを見てみたいのですが、今回採用された42のサンプルは一定の期間で固まって発生しています。2000年の後のドットコムバブル崩壊後が顕著ですね。これは互いに独立であるという点を満たしていないのではないかという疑いが非常に濃厚で、Thresholdモデルを使った際の短所になります。次回以降でこの点を克服するDeclusteringという手法を紹介していきたいと思います。
<img width="800" height="400" src="https://qiita-image-store.s3.amazonaws.com/0/246473/aad2d766-5fcd-1579-7fa3-ed11fa17633d.png">

# 参考文献


<div  class="amazon Default"><div  align="left" class="pictBox"><a  target="_blank" href="https://www.amazon.co.jp/Introduction-Statistical-Modeling-Springer-Statistics/dp/1852334592?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;tag=lvdrfree-22&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=1852334592"><img  class="pict" style="margin-right:10px" align="left" hspace="5" border="0" alt="An Introduction to Statistical Modeling of Extreme Values (Springer Series in Statistics)" src="https://images-fe.ssl-images-amazon.com/images/I/41R%2BHU7X%2B4L._SL160_.jpg"></a></div><div  class="itemTitle"><a  target="_blank" href="https://www.amazon.co.jp/Introduction-Statistical-Modeling-Springer-Statistics/dp/1852334592?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;amp;tag=lvdrfree-22&amp;amp;linkCode=xm2&amp;amp;camp=2025&amp;amp;creative=165953&amp;amp;creativeASIN=1852334592">An Introduction to Statistical Modeling of Extreme Values (Springer Series in Statistics) [ハードカバー]</a></div><div  class="itemSubTxt">Stuart Coles</div><div  class="itemSubTxt">Springer</div><div  class="itemSubTxt">2001-12-15</div></div><br  style="clear:left" clear="left"><br />

<div  class="amazon Default"><div  align="left" class="pictBox"><a  target="_blank" href="https://www.amazon.co.jp/Financial-Risk-Modelling-Portfolio-Optimization/dp/1119119669?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;tag=lvdrfree-22&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=1119119669"><img  class="pict" style="margin-right:10px" align="left" hspace="5" border="0" alt="Financial Risk Modelling and Portfolio Optimization with R" src="https://images-fe.ssl-images-amazon.com/images/I/518E1j--3fL._SL160_.jpg"></a></div><div  class="itemTitle"><a  target="_blank" href="https://www.amazon.co.jp/Financial-Risk-Modelling-Portfolio-Optimization/dp/1119119669?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;amp;tag=lvdrfree-22&amp;amp;linkCode=xm2&amp;amp;camp=2025&amp;amp;creative=165953&amp;amp;creativeASIN=1119119669">Financial Risk Modelling and Portfolio Optimization with R</a></div><div  class="itemSubTxt">Bernhard Pfaff</div><div  class="itemSubTxt">Wiley</div><div  class="itemSubTxt">2016-10-03</div></div><br  style="clear:left" clear="left"><br />

