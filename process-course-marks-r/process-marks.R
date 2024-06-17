library("openxlsx")

## FUNCTIONS DEFINED HERE ======================================================

#-------------------------------------------------------------------------------
# function to do sum of columns (e.g. for assgns, class, etc.)
#-------------------------------------------------------------------------------
gs_col_sum <- function(df, cols, newColName) {
  newDf <- df
  newDf[newColName] <- rowSums(newDf[, cols], na.rm = TRUE)
  return(newDf)
}
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# function to do weighted sum of columns (e.g. for assgns, class, etc.)
#-------------------------------------------------------------------------------
gs_col_wt_sum <- function(df, colName, wt, newColName) {
  newDf <- df
  full_marks = newDf[ allData$RollNo == "99999999", colName]
  newDf[newColName] <- round(newDf[colName] * wt / full_marks, 2)
  return(newDf)
}

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# function to send all marks by email
#-------------------------------------------------------------------------------
# uses gs-py-send (email sender written in python: see synology-drive/code/python)
# symlink available in ~/code/bin [which is in $PATH]
gs_send_all_marks <- function(df) {
  #marks start from 6th column (first 5 columns are student details)
  colNames <- names(df)
  #assumes last row has the maximum possible marks (ideal marks)
  ideal_row <- df[nrow(df),]
  for(i in 1:nrow(df)-1) {
    row <- df[i,]
    print(paste0("Sending email to: ", row[["Student.Name"]]))
    email_msg <- paste0("Dear ", row[["Student.Name"]], ", here are your marks:\n")
    for(j in 6:ncol(df)) {
      email_msg <- paste0(email_msg, 
                          colNames[j], ": ",
                          row[[colNames[[j]]]], " out of ",
                          ideal_row[[colNames[j]]], ".\n\n")
    }
    email_msg <- paste0(email_msg, 
                        "In case of any discrepancy, please let me know.\n",
                        "Regards,\nCourse Instructor.\n")
    
    #print(email_msg)
    send_cmd <- paste0("~/code/bin/gs-py-send -t ",
                       #"it.gaurav@gmail.com",
                       row[["Email.Id"]],
                       " -s \"CExxx Marks\" -m \"", email_msg, "\"")
    #print(send_cmd)
    # uncomment the following for action!
    #send_cmd_out <- system(send_cmd, intern = TRUE)
  }
}

#-------------------------------------------------------------------------------
# function to calculate statistics on marks
#-------------------------------------------------------------------------------
gs_calculate_statistics <- function(df) {
  #marks start from 6th column (first 5 columns are student details)
  colNames <- names(df)
  #assumes last row has the maximum possible marks (ideal marks)
  ideal_row <- df[nrow(df),]
  for(j in 6:ncol(df)) {
    print(mean(df[1:nrow(df)-1, j]))
  }
}


## MAIN CODE STARTS HERE =======================================================
allData <- read.xlsx("ce304-marks-2024-04-27.xlsx", sheet = 1, na.strings = "0")
# set all NA values to 0
allData[is.na(allData)] <- 0
weightage <- read.xlsx("ce304-marks-2024-04-27.xlsx", sheet = "weightage")

# columns as lists / get weightage data
all_work = weightage[["Work"]]
all_weights = weightage[["Weight"]]

#head(allData)   #print first few rows
#typeof(allData) #check type

# names(allData)   #print all column headers
#dim(allData)    #print dimensions of data frame
#str(allData)    #print structure (column names, data types, etc.) --useful

#print(allData["Student.Name"])  #print column of a given header

#create new column using existing column
#allData["New.Col"] <- 5*allData["A2"]

#sum specific columns
#cols_to_sum = names(allData) %in% c("A1", "A2", "A3", "A4", "A5", "A6", "A7")
#allData <- gs_col_sum(allData, cols_to_sum, "New.Col")

# access by specific row value of a column
#weightage[ weightage$Work == "Assignment", ]

# ------- process assignment marks ---------------------------------------------
cols_to_sum <- names(allData) %in% c("A1", "A2", "A3", "A4", "A5", "A6", "A7")
allData <- gs_col_sum(allData, cols_to_sum, "A.Total")

assgn_weight <- all_weights[which(all_work == "Assignment")]
allData <- gs_col_wt_sum(allData, "A.Total", assgn_weight, "W.A.Total")

# ------- write new output excel file ------------------------------------------
write.xlsx(allData, "outfile.xlsx", asTable = TRUE, overwrite = TRUE)

gs_send_all_marks(allData)
