#loading packages
library(tidyverse)
library(readxl) #to combine the 2 sheets in the excel file

#loading the dataset into excel
sheet1 <- read_excel("/Users/berta/iCloud Drive (Archive)/Documents/MS DATA/SPRING 2024/ANA 515 Data Preparation/515P/survey.xlsx", sheet = 1)
sheet2 <- read_excel("/Users/berta/iCloud Drive (Archive)/Documents/MS DATA/SPRING 2024/ANA 515 Data Preparation/515P/survey.xlsx", sheet = 2)

#timestamp col in sheet 1 isn't formatted right in R. Need to change the format
sheet1 <- sheet1 %>%
  mutate(Timestamp = as.POSIXct(as.numeric(Timestamp) * (60*60*24), origin = "1899-12-30", tz = "UTC"))

#checking to see the timestamp column is indeed, mutated
head(sheet1$Timestamp) 
head(sheet2$Timestamp)

#combining the 2 sheets yay!
mydata <- bind_rows(sheet1, sheet2)

#renaming col names to lowercase to make it easier to refer to down the line
mydata <- mydata %>% rename_with(tolower)

#exporting the combined dataset
#write.csv(mydata, "/Users/berta/iCloud Drive (Archive)/Documents/MS DATA/SPRING 2024/ANA 515 Data Preparation/515P/my_data.csv", row.names = FALSE)

#cleaning gender column, lots of varying values, need to transform these into specified values
#doing this because I want to see the difference between the genders and mental health
#Male for male identifying respondents, including trans male
#Female for female identifying respondents, including trans female
#Non Binary for respondents that don't fit the binary gender
#Other for values that don't fit in any of the above

gendercol <- mydata %>%
  mutate(gender = tolower(gender)) %>% # Convert to lowercase
  mutate(gender = case_when(
    grepl("female|woman|cis female|femail|f|femake|trans woman|trans-female|female (trans)", gender)  ~ "Female",
    grepl("male|man|guy|m|cis male|msle", gender) ~ "Male",
    grepl("non-binary|agender|androgyne|enby|genderqueer|neuter|fluid|queer", gender) ~ "Non-Binary",
    TRUE ~ "Other" #for any other values that don't match the above, we sort them to others!
  ))

#in the age column, there are a lot of values that don't make sense like negative values or 1 or 2
#instead of guessing people's age, i think removing these values makes more sense to me

agecol <- gendercol %>%
  mutate(age = as.numeric(as.character(age))) %>% #change the weird values like 3.60e+01 ~ 3.60*10=36
  filter(!is.na(age) & age >= 9 & age <= 120) #remove na, negative, or any values that don't make sense in this context

#number of employees column are also formatted weird, 
#need to update this from date format to range values
noemployeescol <- agecol %>%
  mutate(no_employees = case_when(
    no_employees == "25-Jun" ~ "6-25", #changing dates to range, assuming 25-Jun is 6-25
    no_employees == "5-Jan" ~ "1-5",
    TRUE ~ no_employees  #this line of script is to preserve the original values that don't match the 25-jun or 5-jan, otherwise all the original values become NA
  )) %>%
  #still in the no_employees col, realizing there is weird 5 digit values like 44201, not sure what the respondent is trying to say, better remove it
  filter(!grepl("^[0-9]{5,}$", no_employees))

unique(noemployeescol$gender) #super interesting that after filtering the 5 digit values in number of employees col, the other values in gender also disappear, curious as to what could be causing this

#also i only want to see the rows that answered yes for the tech company column since this is a suvrey on tech company
techcompanycol <- noemployeescol %>%
  filter(!is.na(tech_company) & tech_company != "No") #filtering NA and No values

#now i want to subset the dataset to only view the columns that I'm thinking of visualizing
dataforplot1 <- techcompanycol %>%
  select(age, gender, tech_company, treatment) %>%
  filter(!is.na(treatment) & treatment != "-" & treatment != "NA") %>% #filtering NA values
  mutate(treatment = if_else(treatment == "Y", "Yes", treatment)) #turns out there is Y values that needs to be transformed, assuming Y is yes

unique(dataforplot1$treatment) #checking to see the select, filter, and mutating in prev lines work

#lemme export the csv file i use for plotting first
#write.csv(dataforplot1, "/Users/berta/iCloud Drive (Archive)/Documents/MS DATA/SPRING 2024/ANA 515 Data Preparation/515P/hardiman_plotdata.csv", row.names = FALSE)

#plotting bar chart for gender vs treatment
ggplot(dataforplot1, aes(x = gender, fill = treatment)) +
  geom_bar(position = "dodge") + #dodge is for side by side, stack is for on top of each other like stacked bar chart
  labs(title = "Tech Employees Who Sought Mental Health Treatment (By Gender)",
       x = "Gender",
       y = "Count",
       fill = "Sought Treatment") +
  theme_classic() +
  scale_fill_manual(values = c("Yes" = "darkgreen", "No" = "brown2"))


