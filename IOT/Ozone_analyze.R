#建制臭氧濃度預測模型

install.packages("RJDBC")
library(RJDBC)

#Step1建立MySQL連結
drv=JDBC("com.mysql.jdbc.Driver",
         "C:\\myLib\\mysql-connector-java-5.1.42-bin.jar")
conn=dbConnect(drv,
               "jdbc:mysql://172.104.90.53:3306/iii",
               "iii",
               "iii@WSX1qaz"
               )
#show tables
dbListTables(conn)
a=dbGetQuery(conn,"select*from airquality")
#a會是一個data.frame的格式
class(a)

#Step2 整理機器學習演算法所需的資料
sensor=dbGetQuery(conn,"select * from sensor")
airquality=dbGetQuery(conn,"select * from airquality")

install.packages("sqldf")
library(sqldf)

df_sensor=sqldf("SELECT cast(substr(trim(dt),7,1) as int) month
                ,cast(substr(trim(dt),9,2) as int) day
                ,avg(temperature) avg_temperature
                ,avg(humidity) avg_humidity
                FROM sensor
                group by
                        cast(substr(trim(dt),7,1) as int)
                        ,cast(substr(trim(dt),9,2) as int)
                having cast(substr(trim(dt),7,1) as int) <>0
                ")

head(airquality,10)
head(df_sensor,10)


df_allitems=sqldf("select a.*,b.avg_temperature,b.avg_humidity
                   from airquality a
                   left join df_sensor b
                   on a.Month=b.month and a.Day=b.day
                  ")
head(df_allitems)

#Step3 建置多元回歸模型
lmTrain = lm(formula=Ozone~Solar_R+Wind+avg_temperature+avg_humidity,
             data=subset(df_allitems,complete.cases(df_allitems)))#排除null
#模型摘要
#Adjusted R-squared 為0~1，越接近1預測力越好
summary(lmTrain)

#Step4預測明日臭氧濃度
New_data = data.frame(Solar_R=200,Wind=12,avg_temperature=32.1,avg_humidity=62.7)
predicted=predict(lmTrain,newdata=New_data)
predicted/1000
#0.03699786 低於0.06，對人體沒有影響

#結束連線
dbDisconnect(conn)