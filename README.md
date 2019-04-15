# 極値理論解析
修士論文で極値理論を用いた解析を行っていました。その際、日本語の文献がほとんどないことを知ったため、少しでも極値理論の普及に繋がればと思い、極値理論の標準的な教科書である"An Introduction to Statistical Modelling of Extreme Values, Coles 2001"(ISMEV)のサンプルコードを公開しております。`ISMEV`が入っているものになります。

このほか、極値理論を用いたファイナンスの分析を紹介しています。`extreme_finance`が入ったものになります。

なお、主にRmarkdownを使って解析を行っていたのですが、RmarkdownはGitHubとの相性が良くないため、Markdownをメインにコードを公開しています。図が付いているものに関してはとPDFをご覧ください…。

# 極値理論用のパッケージ
統計分析で良く用いられるRに有益なパッケージがいくつかあります。その中で最もメジャーだと思われるのが`ismev`と`extRemes`です。ただし、これらのパッケージもやや使いにくいところがあるので、少し修正したものをこちらで公開していますので、ご参考にしてください。`ismev`のうち、いくつかの関数を修正しています。
https://github.com/hrkzz/extreme-value/blob/master/extreme_functions.r

なお、機械学習やディープラーニングで注目を集めているPythonには極値理論の分析を助けてくれるパッケージはほとんどありません。

# 参考文献
### ISMEV
極値理論を理論から丁寧に勉強したい人へのおススメ。世界標準の教科書ともいえる一冊です。
<div  class="amazon Default"><div  align="left" class="pictBox"><a  target="_blank" href="https://www.amazon.co.jp/Introduction-Statistical-Modeling-Springer-Statistics/dp/1852334592?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;tag=lvdrfree-22&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=1852334592"><img  class="pict" style="margin-right:10px" align="left" hspace="5" border="0" alt="An Introduction to Statistical Modeling of Extreme Values (Springer Series in Statistics)" src="https://images-fe.ssl-images-amazon.com/images/I/41R%2BHU7X%2B4L._SL160_.jpg"></a></div><div  class="itemTitle"><a  target="_blank" href="https://www.amazon.co.jp/Introduction-Statistical-Modeling-Springer-Statistics/dp/1852334592?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;amp;tag=lvdrfree-22&amp;amp;linkCode=xm2&amp;amp;camp=2025&amp;amp;creative=165953&amp;amp;creativeASIN=1852334592">An Introduction to Statistical Modeling of Extreme Values (Springer Series in Statistics) [ハードカバー]</a></div><div  class="itemSubTxt">Stuart Coles</div><div  class="itemSubTxt">Springer</div><div  class="itemSubTxt">2001-12-15</div></div><br  style="clear:left" clear="left"><br />

### 極値統計学
日本語で書かれた唯一といっていい極値理論の本です。上記のISMEVの和訳中心に理論から応用まで、とりあえず極値理論を使って解析してみたい人へおススメです。
<div  class="amazon Default"><div  align="left" class="pictBox"><a  target="_blank" href="https://www.amazon.co.jp/%E6%A5%B5%E5%80%A4%E7%B5%B1%E8%A8%88%E5%AD%A6-ISM%E3%82%B7%E3%83%AA%E3%83%BC%E3%82%BA-%E9%80%B2%E5%8C%96%E3%81%99%E3%82%8B%E7%B5%B1%E8%A8%88%E6%95%B0%E7%90%86-%E9%AB%98%E6%A9%8B-%E5%80%AB%E4%B9%9F/dp/4764905159?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;tag=lvdrfree-22&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=4764905159"><img  class="pict" style="margin-right:10px" align="left" hspace="5" border="0" alt="極値統計学 (ISMシリーズ:進化する統計数理)" src="https://images-fe.ssl-images-amazon.com/images/I/417XdrqDoyL._SL160_.jpg"></a></div><div  class="itemTitle"><a  target="_blank" href="https://www.amazon.co.jp/%E6%A5%B5%E5%80%A4%E7%B5%B1%E8%A8%88%E5%AD%A6-ISM%E3%82%B7%E3%83%AA%E3%83%BC%E3%82%BA-%E9%80%B2%E5%8C%96%E3%81%99%E3%82%8B%E7%B5%B1%E8%A8%88%E6%95%B0%E7%90%86-%E9%AB%98%E6%A9%8B-%E5%80%AB%E4%B9%9F/dp/4764905159?SubscriptionId=AKIAIM37F4M6SCT5W23Q&amp;amp;tag=lvdrfree-22&amp;amp;linkCode=xm2&amp;amp;camp=2025&amp;amp;creative=165953&amp;amp;creativeASIN=4764905159">極値統計学 (ISMシリーズ:進化する統計数理) [単行本]</a></div><div  class="itemSubTxt">高橋 倫也</div><div  class="itemSubTxt">近代科学社</div><div  class="itemSubTxt">2016-09-01</div></div><br  style="clear:left" clear="left"><br />
