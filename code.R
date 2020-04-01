# loading libraries 
library("sqldf")
#library("data.table")

# reading Microdata
rawdata = read.csv("D:/capstone 2/recs2009_public.csv")
attach(rawdata)
#selecting columns contain imputed_indicator i.e. named with "z%" as the first character
imputed_column <-select(rawdata,starts_with("z"))
attach(imputed_column)

#selecting columns that contain main data 
data <- select(rawdata,-starts_with("z"))

# features which have imputed values
imputed_features<-colSums(imputed_column)
imputed_features<-data.frame(imputed_features)
names(imputed_features)= c("count_of_imputation")

#count of imputed_cells

total_imputation=colSums(imputed_features)

#count of non imputed cells
total_cells=nrow(data)*ncol(data)

#percent of imputation
percentage=total_imputation/total_cells*100
names(percentage)=c("percentage of imputation")
percentage

#extracting imputed column names
imputed_column_names<-data.frame(as.character(rownames(imputed_features)),imputed_features)


#deleteing column names with 0 missing cells

imputed_column_names<-imputed_column_names[imputed_column_names[,"count_of_imputation"] != 0,]
colnames(imputed_column_names)[1]="column_name"

#reading metadata table
metadata = read.csv("D:/capstone 2/metadata.csv")
names(metadata)<- c("variable_name","variable_description","codes","label")

#gathering column defination

Extracting_actual_column_names<- sqldf("select variable_description,count_of_imputation \t
                        FROM metadata join imputed_column_names ON\t
                        variable_name=column_name")
names(Extracting_actual_column_names)= c("column_name","count_of_imp")

Extracting_variable_description<- sqldf("select variable_name,count_of_imp,label,codes\t
                        FROM metadata join Extracting_actual_column_names ON\t
                        variable_name=column_name")


#sorting count of imputed columns based on count of imputed cells
Extracting_variable_description <- Extracting_variable_description[with(Extracting_variable_description, order(-count_of_imp)), ]

#total number of imputed columns 
nrow(Extracting_variable_description)




