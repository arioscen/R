x=c(3,3,4,3,6,8,8,9) #藥劑量
y=c(22,25,28,20,16,9,12,5) #痊愈天數
new_x = data.frame(x=5) #預測當x=5時的痊愈天數

?lm
#訓練資料
train=data.frame(x=x,y=y)
#模型
lmtrain=lm(formula=y~x,data=train)
#預測
predicted=predict(lmtrain,newdata=new_x)

summary(lmtrain)
plot(y~x,main="依藥劑量預測痊愈天數", xlab="藥劑量",ylab="感冒痊愈天數",family="STHeiti")
points(x=new_x,y=predicted,col="green",cex=2,pch=16)
abline(reg=lmtrain$coefficients,col="red",lwd=1)

