library(ggplot2)
#read data from excel file
wine<- read.csv('WhitewineQuality.csv')

#remove column 1 as it is not needed
wine <- wine[,-1]

dim(wine) #to show dimensions of data - 4898 rows and 12 columns

summary(wine) #gives a summary of values in each column

#to create a histogram to see how many wines are in each
ggplot(wine) + geom_histogram(aes(x = quality), binwidth=0.5,na.rm=TRUE, fill ='red') + 
scale_x_continuous(name='Quality rating of white wines', breaks=seq(2,9,1), limits = c(2,9))+
scale_y_continuous(name='Number of white wines', breaks=seq(0,2500,500), limits = c(0,2500))+
ggtitle("Distribution of white wine quality") 

print(" Number of wines for a partcular rating of wine:")
table(wine$quality)

#to create a heatmap to find correlation between different parameters and the quality of wine
library(gplots)
heatmap.2(cor(wine), Rowv = FALSE, Colv = FALSE, dendrogram = "none", 
          cellnote = round(cor(wine),2),
          notecol = "black", key = FALSE, trace = 'none', margins = c(10,10))

#to create boxplot to see patterns in values of each attribute based on quality of wine
w1 <- ggplot(wine, aes(as.factor(quality),fixed.acidity))+ geom_boxplot() + coord_cartesian(ylim = c(4.5,10.5))
w2 <- ggplot(wine, aes(as.factor(quality),volatile.acidity))+ geom_boxplot()+ coord_cartesian(ylim = c(0,0.6))
w3 <- ggplot(wine, aes(as.factor(quality),citric.acid))+ geom_boxplot()+ coord_cartesian(ylim = c(0,0.5))
w4 <- ggplot(wine, aes(as.factor(quality),residual.sugar))+ geom_boxplot()+ coord_cartesian(ylim = c(0,20))
w5 <- ggplot(wine, aes(as.factor(quality),chlorides))+ geom_boxplot()+ coord_cartesian(ylim = c(0,0.07))
w6 <- ggplot(wine, aes(as.factor(quality),free.sulfur.dioxide))+ geom_boxplot()+ coord_cartesian(ylim = c(0,70))
w7 <- ggplot(wine, aes(as.factor(quality),total.sulfur.dioxide))+ geom_boxplot()+ coord_cartesian(ylim = c(0,220))
w8 <- ggplot(wine, aes(as.factor(quality),density))+ geom_boxplot()+ coord_cartesian(ylim = c(0.98,1.0))
w9 <- ggplot(wine, aes(as.factor(quality),pH))+ geom_boxplot()+ coord_cartesian(ylim = c(2.8,3.6))
w10 <- ggplot(wine, aes(as.factor(quality),sulphates))+ geom_boxplot()+ coord_cartesian(ylim = c(0.3,0.8))
w11 <- ggplot(wine, aes(as.factor(quality),alcohol))+ geom_boxplot()+ coord_cartesian(ylim = c(8,13))

library(gridExtra)
grid.arrange(w1,w2, nrow=1)
grid.arrange(w3,w4,w5, nrow=1)
grid.arrange(w6,w7, nrow=1)
grid.arrange(w8,w9, nrow=1)
grid.arrange(w10,w11, nrow=1)

#adding a new attribute for wine being good and not good
wine$rating   <- ifelse (as.integer(wine$quality) >=7, 1, 0)
table(wine$rating)

# splitting data into training and validation sets
set.seed(7)  
winetrain.index <- sample(c(1:dim(wine)[1]), dim(wine)[1]*0.7)  
winetrain <- wine[winetrain.index, ]
winevalid <- wine[-winetrain.index, ]

#logistic regression model 1 with all variables
winelogit.reg <- glm(rating ~ .-quality, data = winetrain, family = "binomial") 
options(scipen=999)
summary(winelogit.reg)

library(caret)

winelogit.reg.pred <- predict(winelogit.reg, winevalid, type = "response")
winelogit.reg.pred.classes <- ifelse(winelogit.reg.pred > 0.5, 1, 0)
confusionMatrix(as.factor(winelogit.reg.pred.classes), as.factor(winevalid$rating), mode="everything")

#logistic regression model 2 with less significant variables removed
winelogit.reg2 <- glm(rating ~ .-quality-residual.sugar-total.sulfur.dioxide-citric.acid, data = winetrain, family = "binomial") 
summary(winelogit.reg2)

winelogit.reg.pred2 <- predict(winelogit.reg2, winevalid, type = "response")
winelogit.reg.pred.classes2 <- ifelse(winelogit.reg.pred2 > 0.5, 1, 0)
confusionMatrix(as.factor(winelogit.reg.pred.classes2), as.factor(winevalid$rating), mode="everything")



#logistic regression model 3 with significant variables and normalized data
#fn to do normalization
min_max_normalize <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}
wine_norm <- as.data.frame(lapply(wine[1:11], min_max_normalize))
wine_norm<-cbind(wine_norm,wine[,c(12,13)]) #combining the quality and rating columns

#partition after normalization
winetrain_norm <- wine_norm[winetrain.index, ]
winevalid_norm <- wine_norm[-winetrain.index, ]

winelogit.reg3 <- glm(rating ~ .-quality-residual.sugar-total.sulfur.dioxide-citric.acid, data = winetrain_norm, family = "binomial") 
summary(winelogit.reg3)

winelogit.reg.pred3 <- predict(winelogit.reg3, winevalid_norm, type = "response")
winelogit.reg.pred.classes3 <- ifelse(winelogit.reg.pred3 > 0.5, 1, 0)
confusionMatrix(as.factor(winelogit.reg.pred.classes3), as.factor(winevalid_norm$rating))


# R code for decision tree model 1
library(rpart)
library(rpart.plot)
wine.tree <- rpart(rating ~ .-quality, data = winetrain ,method = "class")  
prp(wine.tree, type = 1, extra = 2, under = TRUE, split.font = 1, varlen = 10)
# count number of leaves
length(wine.tree$frame$var[default.ct$frame$var == "<leaf>"])

wine.tree.point.pred.valid <- predict(wine.tree,winevalid,type = "class")
confusionMatrix(wine.tree.point.pred.valid, as.factor(winevalid$rating))


#random forest model 1
library(randomForest)
set.seed(7)
wine.rf1 <- randomForest(as.factor(rating) ~ .-quality, data = winetrain, ntree = 500, 
                   mtry = 4, nodesize = 5, importance = TRUE)  

## variable importance plot
varImpPlot(wine.rf1, type=1) #shows the importance of the variables


## confusion matrix
wine.rf.pred <- predict(wine.rf1, winevalid)
confusionMatrix(wine.rf.pred, as.factor(winevalid$rating))

#random forest model 2
library(randomForest)
set.seed(7)
wine.rf2 <- randomForest(as.factor(rating) ~ .-quality-total.sulfur.dioxide-citric.acid, data = winetrain_norm, ntree = 700, 
                        mtry = 4, nodesize = 5, importance = TRUE)  

## variable importance plot
varImpPlot(wine.rf2, type=1) #shows the importance of the variables


## confusion matrix
wine.rf.pred <- predict(wine.rf2, winevalid_norm)
confusionMatrix(wine.rf.pred, as.factor(winevalid_norm$rating))


#neural network 1- with all variables
library(neuralnet)
wine.nn1 <- neuralnet(rating ~ .-quality, data = winetrain, linear.output = F, stepmax=9000) 

#since the algorithm did not converge, we can try with significant variables and normalized data

#neural network 2 - with significant variables and normalized data set
wine.nn2 <- neuralnet(rating ~.-quality-total.sulfur.dioxide-citric.acid, data = winetrain_norm, linear.output = F, hidden=2)

plot(wine.nn2, rep="best")
#run either one of the above lines to get nn

wine.nn.pred <- predict(wine.nn2, winevalid_norm, type = "response")
wine.nn.pred.classes <- ifelse(wine.nn.pred > 0.5, 1, 0)
confusionMatrix(as.factor(wine.nn.pred.classes), as.factor(winevalid_norm$rating))

#area under ROC curve
library(pROC)
#logisitc regression
r1 <- roc(winevalid$rating, winelogit.reg.pred2)
plot.roc(r1, print.auc=T, main= "ROC curve of regression model 2")
auc(r1)

#random forest
wine.rf1.roc <- predict(wine.rf1, winevalid, type="prob") # to get probabilities
r2 <- roc(winevalid$rating, wine.rf1.roc[,1])
plot.roc(r2, print.auc=T, main= "ROC curve of Random forest model")

#nerual network
wine.nn.pred.roc <- predict(wine.nn2, winevalid_norm, type = "prob")
r3 <- roc(winevalid$rating, wine.nn.pred.roc)
plot.roc(r3, print.auc=T, main= "ROC curve of Neural Network model")


