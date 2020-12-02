require(tidyverse)
require(readxl)
require(openxlsx)
require(fs)

keyFile=dir_ls(regex="____STATS.xlsx")

key=read_xlsx(keyFile)
key$Group=gsub("_\\d$","",key$Sample)
write.xlsx(key,keyFile)
