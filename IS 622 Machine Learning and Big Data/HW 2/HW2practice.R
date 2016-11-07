X <- matrix(c(0,0,1,1,0,1,0,1), nrow=4)
W <- matrix(c(1,1,1,1), nrow = 2)
c <- matrix(c(0,-1), nrow = 2)
w <- matrix(c(1,-2), nrow=2)

c <- rbind(t(c), t(c), t(c), t(c))

X %*% W
(X %*% W) + c
c
rbind(t(c), t(c), t(c), t(c))
