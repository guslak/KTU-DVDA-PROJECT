install.packages(h2o)
library(h2o)
h2o.init()
library(h2o)
library(tidyverse)
h2o.init(max_mem_size = "8g")

df <- h2o.importFile("C:/Users/lakom/Desktop/Magistras-DVDA/projektas/KTU-DVDA-PROJECT-main/project/1-data/train_data.csv")
test_data <- h2o.importFile("C:/Users/lakom/Desktop/Magistras-DVDA/projektas/KTU-DVDA-PROJECT-main/project/1-data/test_data.csv")
df
class(df)
summary(df)

y <- "y"
x <- setdiff(names(df), c(y, "id"))
df$y <- as.factor(df$y)
summary(df)

splits <- h2o.splitFrame(df, c(0.6,0.2), seed=123)
train  <- h2o.assign(splits[[1]], "train") # 60%
valid  <- h2o.assign(splits[[2]], "valid") # 20%
test   <- h2o.assign(splits[[3]], "test")  # 20%

####
aml <- h2o.automl(x = x,
                  y = y,
                  training_frame = train,
                  validation_frame = valid,
                  max_runtime_secs = 1200) #1200
####
aml@leaderboard

#model <- aml@leader

##ivesti lenteles pav
model <- h2o.getModel("StackedEnsemble_AllModels_2_AutoML_1_20240107_192000")

h2o.performance(model, train = TRUE)
h2o.performance(model, valid = TRUE)
perf <- h2o.performance(model, newdata = test)
perf

h2o.auc(perf)
plot(perf, type = "roc")

#h2o.performance(model, newdata = test_data)

predictions <- h2o.predict(model, test_data)

predictions

predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("C:/Users/lakom/Desktop/Magistras-DVDA/projektas/KTU-DVDA-PROJECT-main/project/5-predictions/predictions4.csv") #sita siusti destytojui


### ID, Y

h2o.saveModel(model, "C:/Users/lakom/Desktop/Magistras-DVDA/projektas/KTU-DVDA-PROJECT-main/project/4-model/", filename = "my_best_automlmode_new")
model <- h2o.loadModel("C:/Users/lakom/Desktop/Magistras-DVDA/projektas/KTU-DVDA-PROJECT-main/project/4-model/my_best_automlmode_new")
h2o.varimp_plot(model)

# 2023.11.24

rf_model <- h2o.randomForest(x = x,
                             y = y,
                             training_frame = train,
                             validation_frame = valid,
                             ntrees = 20,
                             max_depth = 10,
                             stopping_metric = "AUC",
                             seed = 1234)
rf_model
h2o.auc(rf_model)
h2o.auc(h2o.performance(rf_model, valid = TRUE))
h2o.auc(h2o.performance(rf_model, newdata = test))

h2o.saveModel(rf_model, "C:/Users/lakom/Desktop/Magistras-DVDA/projektas/KTU-DVDA-PROJECT-main/project/4-model/", filename = "rf_model_new")
var_imp <- h2o.varimp_plot(model)
