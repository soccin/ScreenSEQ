#
# Library .csv file must have these columns
# Seq,Gene,ProbeID,LibName
# CATCTTCTTTCACCTGAACG,A1BG,A1BG;1,Brunello
#
# ProbeID must be semi-colon delimited
#

args=commandArgs(trailing=T)
if(len(args)==0) {
    cat("\n  usage: joinCounts.R LIBRARY_FILE.CSV [COUNT_DIR|default==\".\"]\n\n")
    quit()
}

LIBFILE=args[1]
if(len(args)>1) {
    COUNT_DIR=args[2]
} else {
    COUNT_DIR="."
}

require(tidyverse)
require(readxl)
require(fs)
require(openxlsx)

lib=read_csv(LIBFILE)
countFiles=dir_ls(COUNT_DIR,regexp="___COUNTS.txt")

if(len(countFiles)==0) {
    cat("\n\n  No count files found in [",COUNT_DIR,"]\n")
    cat("  Please specify COUNT_DIR\n")
    cat("\n  usage: joinCounts.R LIBRARY_FILE.CSV [COUNT_DIR|default==\".\"]\n\n")
    quit()
}

counts=countFiles %>%
    map(read_tsv,col_types = cols(.default = "c")) %>%
    bind_rows(.id="Sample") %>%
    type_convert() %>%
    mutate(Sample=basename(Sample)) %>%
    mutate(Sample=gsub("___COUNTS.txt","",Sample)) %>%
    mutate(Sample=gsub("_IGO_.*","",Sample))

tbl0=counts %>% left_join(lib,by=c(sgRNA="Seq")) %>%
  group_by(sgRNA) %>%
  mutate(Total=sum(Counts)) %>%
  ungroup %>%
  spread(Sample,Counts,fill=0)

tbl=tbl0[,colnames(tbl0)!="<NA>"] %>%
  filter(!is.na(Gene)) %>%
  select(-Total)

projTag=grep("Proj_",strsplit(getwd(),"/")[[1]],value=T)
if(len(projTag)==0) {
    projTag="Proj_xyz"
} else {
    projTag=projTag[1]
}

write.xlsx(tbl,cc(projTag,"___COUNTS.xlsx"))

tbl0=tbl0 %>% arrange(desc(Total),sgRNA) %>% mutate(Rank=row_number())

write_csv(head(tbl0,10000),cc(projTag,"___Debug.csv"))

stats=dir_ls(COUNT_DIR,regexp="___TOTAL.txt") %>%
    map(read_tsv,col_names=c("Sample","Total")) %>%
    bind_rows %>%
    mutate(Sample=basename(Sample)) %>%
    mutate(Sample=gsub("_IGO_.*","",Sample)) %>%
    gather(Metric,Value,Total)

numProc=counts %>%
    group_by(Sample) %>%
    summarize(Num.Processed=sum(Counts)) %>%
    gather(Metric,Value,Num.Processed)

numLib=counts %>%
    right_join(lib,by=c(sgRNA="Seq")) %>%
    group_by(Sample) %>%
    summarize(Num.Library=sum(Counts)) %>%
    gather(Metric,Value,Num.Library) %>%
    filter(!is.na(Sample))

statsTbl=bind_rows(stats,numProc) %>%
    bind_rows(numLib) %>%
    spread(Metric,Value) %>%
    mutate(PCT.Useable=Num.Library/Total) %>%
    mutate(PCT.Processed=Num.Processed/Total) %>%
    select(Sample,Total,Num.Processed,PCT.Processed,Num.Library,PCT.Useable)

write.xlsx(statsTbl,cc(projTag,"___STATS.xlsx"))

