# GEV-Profile
cgev.prof <- function (z, m, xlow, xup, conf = 0.95, nint = 500){
  if (m <= 1)
    stop("`m' must be greater than one")
  cat("If routine fails, try changing plotting interval", fill = TRUE)
  p <- 1/m
  v <- numeric(nint)
  x <- seq(xlow, xup, length = nint)
  sol <- c(z$mle[2], z$mle[3])
  gev.plik <- function(a){
    if (abs(a[2]) < 10^(-6)){
      mu <- xp + a[1] * log(-log(1 - p))
      y <- (z$data - mu)/a[1]
      if (is.infinite(mu) || a[1] <= 0) 
        l <- 10^6
      else l <- length(y) * log(a[1]) + sum(exp(-y)) + 
        sum(y)
    }
    else {
      mu <- xp - a[1]/a[2] * ((-log(1 - p))^(-a[2]) - 1)
      y <- (z$data - mu)/a[1]
      y <- 1 + a[2] * y
      if (is.infinite(mu) || a[1] <= 0 || any(y <= 0)) 
        l <- 10^6
      else l <- length(y) * log(a[1]) + sum(y^(-1/a[2])) + 
        sum(log(y)) * (1/a[2] + 1)
    }
    l
  }
  for (i in 1:nint) {
    xp <- x[i]
    opt <- optim(sol, gev.plik)
    sol <- opt$par
    v[i] <- opt$value
  }
  plot(x, -v, type = "l", xlab = "Return Level", ylab = " Profile Log-likelihood")
  ma <- -z$nllh
  abline(h = ma, col = 4)
  abline(h = ma - 0.5 * qchisq(conf, 1), col = 4)
  invisible()
  
  ###Add the following to compute the optimal value and its x
  opt.data <- data.frame(x=x, v=-v)
  opt.lik <- max(opt.data$v)
  opt.x <- opt.data$x[opt.data$v==opt.lik]
  
  ###Add the following to compute CI
  h1 <- ma - 0.5 * qchisq(conf, 1)
  SD <- NULL
  for(i in 1:(nint-1)){
    d1 <-  v[i]   + h1
    d2 <-  v[i+1] + h1
    sd <- d1 * d2
    SD <- c(SD, sd)
  }
  i0 <- which(SD < 0)
  i1 <- i0[1]
  i2 <- i0[2]
  c1 <- (abs(v[i1] + h1) * x[i1-1] + abs(v[i1-1] + h1) 
         * x[i1])/(abs(v[i1-1] + h1)  + abs(v[i1] + h1))
  c2 <- (abs(v[i2] + h1) * x[i2-1] + abs(v[i2-1] + h1)
         * x[i2])/(abs(v[i2-1] + h1)  + abs(v[i2] + h1))
  abline(v = c1)
  abline(v = c2)
  CI <- c(c1, c2)
  CI <- sort(CI)
  
  ###Add the following to return the output
  return(list(optimal.value=opt.lik, optimal.x=opt.x,
              confint.lower=CI[1],confint.upper=CI[2]))
}





# GEV-Profile.xi
cgev.profxi <- function (z, xlow, xup, conf = 0.95, nint = 500){
  cat("If routine fails, try changing plotting interval", fill = TRUE)
  v <- numeric(nint)
  x <- seq(xup, xlow, length = nint)
  sol <- c(z$mle[1], z$mle[2])
  gev.plikxi <- function(a){
    if (abs(xi) < 10^(-6)){
      y <- (z$data - a[1])/a[2]
      if (a[2] <= 0)
        l <- 10^6
      else l <- length(y) * log(a[2]) + sum(exp(-y)) + sum(y)
    }
    else{
      y <- (z$data - a[1])/a[2]
      y <- 1 + xi * y
      if (a[2] <= 0 || any(y <= 0))
        l <- 10^6
      else l <- length(y) * log(a[2]) + sum(y^(-1/xi)) + sum(log(y)) * (1/xi + 1)
    }
    l
  }
  for (i in 1:nint){
    xi <- x[i]
    opt <- optim(sol, gev.plikxi)
    sol <- opt$par
    v[i] <- opt$value
  }
  
  plot(x, -v, type = "l", xlab = "Shape Parameter", ylab = "Profile Log-likelihood")
  ma <- -z$nllh
  abline(h = ma, col = 4)
  abline(h = ma - 0.5 * qchisq(conf, 1), col = 4)
  invisible()
  
  ###Add the following to compute the optimal value and its x
  opt.data <- data.frame(x=x, v=-v)
  opt.lik <- max(opt.data$v)
  opt.x <- opt.data$x[opt.data$v==opt.lik]
  
  ###Add the following to compute CI
  h1 <- ma - 0.5 * qchisq(conf, 1)
  SD <- NULL
  for(i in 1:(nint-1)){
    d1 <-  v[i]   + h1
    d2 <-  v[i+1] + h1
    sd <- d1 * d2
    SD <- c(SD, sd)
  }
  i0 <- which(SD < 0)
  i1 <- i0[1]
  i2 <- i0[2]
  c1 <- (abs(v[i1] + h1) * x[i1-1] + abs(v[i1-1] + h1)
         * x[i1])/(abs(v[i1-1] + h1)  + abs(v[i1] + h1))
  c2 <- (abs(v[i2] + h1) * x[i2-1] + abs(v[i2-1] + h1)
         * x[i2])/(abs(v[i2-1] + h1)  + abs(v[i2] + h1))
  abline(v = c1)
  abline(v = c2)
  CI <- c(c1, c2)
  CI <- sort(CI)
  
  ###Add the following to return the output
  return(list(optimal.value=opt.lik, optimal.x=opt.x,
              confint.lower=CI[1],confint.upper=CI[2]))
}





"cgev.diag" <- function (z) 
{
  n <- length(z$data)
  x <- (1:n)/(n + 1)
  if (z$trans) {
    oldpar <- par(mfrow = c(1, 2), pty = "s")
    plot(x, exp(-exp(- sort(z$data))), xlab = "Empirical", xlim = c(0, 1), ylim= c(0, 1), ylab = "Model")
    abline(0, 1, col = 4)
    title("Residual Probability Plot")
    x1 <- - log(-log(x))
    y1 <- sort(z$data)
    a1 <- min(x1, y1)
    a2 <- max(x1, y1)
    h <- (a2 - a1)/20
    a1 <- a1 - h
    a2 <- a2 + h
    plot(x1, y1,  xlim = c(a1, a2), ylim = c(a1, a2),  ylab = "Empirical", 
         xlab = "Model")
    abline(0, 1, col = 4)
    title("Residual Quantile Plot (Gumbel Scale)")
  }
  else {
    oldpar <- par(mfrow = c(2, 2), pty = "s")
    cgev.pp(z$mle, z$data)
    cgev.qq(z$mle, z$data)
    gev.rl(z$mle, z$cov, z$data)
    gev.his(z$mle, z$data)
  }
  par(oldpar)
  invisible()
}





# GPD-Profile
cgpd.prof <- function (z, m, xlow, xup, npy = 365, conf = 0.95, nint = 500) {
  cat("If routine fails, try changing plotting interval", fill = TRUE)
  xdat <- z$data
  u <- z$threshold
  la <- z$rate
  v <- numeric(nint)
  x <- seq(xlow, xup, length = nint)
  m <- m * npy
  sol <- z$mle[2]
  gpd.plik <- function(a) {
    if (m != Inf) 
      sc <- (a * (xp - u))/((m * la)^a - 1)
    else sc <- (u - xp)/a
    
    if (abs(a) < 10^(-4)) 
      l <- length(xdat) * log(sc) + sum(xdat - u)/sc
    else {
      y <- (xdat - u)/sc
      y <- 1 + a * y
      if (any(y <= 0) || sc <= 0) 
        l <- 10^6
      else l <- length(xdat) * log(sc) + sum(log(y)) * (1/a + 1)
    }
    l
  }
  for (i in 1:nint) {
    xp <- x[i]
    opt <- optim(sol, gpd.plik, method = "BFGS")
    sol <- opt$par
    v[i] <- opt$value
  }
  plot(x, -v, type = "l", xlab = "Return Level", ylab = "Profile Log-likelihood")
  ma <- -z$nllh
  abline(h = ma)
  abline(h = ma - 0.5 * qchisq(conf, 1))
  invisible()
  
  ###Add the following to compute the optimal value and its x
  opt.data <- data.frame(x=x, v=-v)
  opt.lik <- max(opt.data$v)
  opt.x <- opt.data$x[opt.data$v==opt.lik]
  
  ###Add the following to compute CI
  h1 <- ma - 0.5 * qchisq(conf, 1)
  SD <- NULL
  for(i in 1:(nint-1)){
    d1 <-  v[i]   + h1
    d2 <-  v[i+1] + h1
    sd <- d1 * d2
    SD <- c(SD, sd)
  }
  i0 <- which(SD < 0)
  i1 <- i0[1]
  i2 <- i0[2]
  c1 <- (abs(v[i1] + h1) * x[i1-1] + abs(v[i1-1] + h1)
         * x[i1])/(abs(v[i1-1] + h1)  + abs(v[i1] + h1))
  c2 <- (abs(v[i2] + h1) * x[i2-1] + abs(v[i2-1] + h1)
         * x[i2])/(abs(v[i2-1] + h1)  + abs(v[i2] + h1))
  abline(v = c1)
  abline(v = c2)
  CI <- c(c1, c2)
  CI <- sort(CI)
  
  ###Add the following to return the output
  return(list(optimal.value=opt.lik, optimal.x=opt.x,
              confint.lower=CI[1],confint.upper=CI[2]))
}





# GPD-Profile.xi
cgpd.profxi <- function (z, xlow, xup, conf = 0.95, nint = 500) {
  cat("If routine fails, try changing plotting interval", fill = TRUE)
  xdat <- z$data
  u <- z$threshold
  v <- numeric(nint)
  x <- seq(xup, xlow, length = nint)
  sol <- z$mle[1]
  gpd.plikxi <- function(a) {
    if (abs(xi) < 10^(-4)) 
      l <- length(xdat) * log(a) + sum(xdat - u)/a
    else {
      y <- (xdat - u)/a
      y <- 1 + xi * y
      if (any(y <= 0) || a <= 0)
        l <- 10^6
      else l <- length(xdat) * log(a) + sum(log(y)) * (1/xi + 1)
    }
    l
  }
  for (i in 1:nint) {
    xi <- x[i]
    opt <- optim(sol, gpd.plikxi, method = "BFGS")
    sol <- opt$par
    v[i] <- opt$value
  }
  plot(x, -v, type = "l", xlab = "Shape Parameter", ylab = "Profile Log-likelihood")
  ma <- -z$nllh
  abline(h = ma, lty = 1)
  abline(h = ma - 0.5 * qchisq(conf, 1), lty = 1)
  invisible()
  
  ###Add the following to compute the optimal value and its x
  opt.data <- data.frame(x=x, v=-v)
  opt.lik <- max(opt.data$v)
  opt.x <- opt.data$x[opt.data$v==opt.lik]
  
  ###Add the following to compute CI
  h1 <- ma - 0.5 * qchisq(conf, 1)
  SD <- NULL
  for(i in 1:(nint-1)){
    d1 <-  v[i]   + h1
    d2 <-  v[i+1] + h1
    sd <- d1 * d2
    SD <- c(SD, sd)
  }
  i0 <- which(SD < 0)
  i1 <- i0[1]
  i2 <- i0[2]
  c1 <- (abs(v[i1] + h1) * x[i1-1] + abs(v[i1-1] + h1)
         * x[i1])/(abs(v[i1-1] + h1)  + abs(v[i1] + h1))
  c2 <- (abs(v[i2] + h1) * x[i2-1] + abs(v[i2-1] + h1)
         * x[i2])/(abs(v[i2-1] + h1)  + abs(v[i2] + h1))
  abline(v = c1)
  abline(v = c2)
  CI <- c(c1, c2)
  CI <- sort(CI)
  
  ###Add the following to return the output
  return(list(optimal.value=opt.lik, optimal.x=opt.x,
              confint.left=CI[1],confint.right=CI[2]))
}





cgpd.pp <- function (z) {
  n <- length(z$data)
  x <- (1:n)/(n + 1)
  if (z$trans) {
    plot(x, 1 - exp(-sort(z$data)), xlab = "Empirical", ylab = "Model")
    abline(0, 1, col = 4)
    title("Residual Probability Plot")
  }
  else {
    gpd.pp(z$mle, z$threshold, z$data)
  }
}





cgpd.qq <- function (z) {
  n <- length(z$data)
  x <- (1:n)/(n + 1)
  if (z$trans) {
    plot(-log(1 - x), sort(z$data), ylab = "Empirical", xlab = "Model")
    abline(0, 1, col = 4)
    title("Residual Quantile Plot (Exptl. Scale)")
  }
  else {
    gpd.qq(z$mle, z$threshold, z$data)
  }
}




cgpd.rl <- function (z, xmax=max(m)/npy, 
                     ymax=max(xdat, q[q > u - 1] + 1.96 * sqrt(v)[q > u - 1])) 
{
  a <- z$mle
  u <- z$threshold
  la <- z$rate
  n <- z$n
  npy <- z$npy
  mat <- z$cov
  dat <- z$data
  xdat <- z$xdata
  
  a <- c(la, a)
  eps <- 1e-06
  a1 <- a
  a2 <- a
  a3 <- a
  a1[1] <- a[1] + eps
  a2[2] <- a[2] + eps
  a3[3] <- a[3] + eps
  jj <- seq(-1, 3.75 + log10(npy), by = 0.1)
  m <- c(1/la, 10^jj)
  q <- gpdq2(a[2:3], u, la, m)
  d <- t(gpd.rl.gradient(a = a, m = m))
  mat <- matrix(c((la * (1 - la))/n, 0, 0, 0, mat[1,1], mat[1,2], 0, mat[2,1], mat[2,2]), ncol = 3)
  v <- apply(d, 1, q.form, m = mat)
  plot(m/npy, q, log = "x", type = "n", xlim = c(0.1, xmax), 
       ylim = c(u, ymax), 
       xlab = "Return period (years)", ylab = "Return level", 
       main = "Return Level Plot")
  lines(m[q > u - 1]/npy, q[q > u - 1])
  lines(m[q > u - 1]/npy, q[q > u - 1] + 1.96 * sqrt(v)[q > u - 1], col = 4)
  lines(m[q > u - 1]/npy, q[q > u - 1] - 1.96 * sqrt(v)[q > u - 1], col = 4)
  nl <- n - length(dat) + 1
  sdat <- sort(xdat)
  points((1/(1 - (1:n)/(n + 1))/npy)[sdat > u], sdat[sdat > u])
}


