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

tbl=counts %>% right_join(lib,by=c(sgRNA="Seq")) %>%
    spread(Sample,Counts,fill=0)

tbl=tbl[,colnames(tbl)!="<NA>"]

write.xlsx(tbl,cc(basename(getwd()),"___COUNTS.xlsx"))

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
    select(Sample,Total,Num.Processed,Num.Library) %>%
    mutate(PCT.Useable=Num.Library/Total)

write.xlsx(statsTbl,cc(basename(getwd()),"___STATS.xlsx"))

