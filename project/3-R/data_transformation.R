#C:\Users\lakom\Desktop\Magistras-DVDA\projektas\KTU-DVDA-PROJECT-main\project\
install.packages("tidyverse")
library(tidyverse)

data <- read_csv("C:/Users/lakom/Desktop/project/httpsgithub.com/guslak/KTU-DVDA-PROJECT/KTU-DVDA-PROJECT-main/KTU-DVDA-PROJECT/project/1-data/1-sample_data.csv")
data_additional <- read_csv("C:/Users/lakom/Desktop/project/httpsgithub.com/guslak/KTU-DVDA-PROJECT/KTU-DVDA-PROJECT-main/KTU-DVDA-PROJECT/project/1-data/2-additional_data.csv")

data_ <- read_csv("C:/Users/lakom/Desktop/project/httpsgithub.com/guslak/KTU-DVDA-PROJECT/KTU-DVDA-PROJECT-main/KTU-DVDA-PROJECT/project/1-data/3-additional_features.csv")


combined_data <- dplyr::bind_rows(data_additional, data)
joined_data <- inner_join(data, data_, by = "id")

write_csv(joined_data, "C:/Users/lakom/Desktop/project/httpsgithub.com/guslak/KTU-DVDA-PROJECT/KTU-DVDA-PROJECT-main/KTU-DVDA-PROJECT/project/1-data/train1_data.csv")