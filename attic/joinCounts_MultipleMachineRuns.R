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

counts=dir_ls(COUNT_DIR,regexp="___COUNTS.txt") %>%
    map(read_tsv) %>%
    bind_rows(.id="Sample") %>%
    mutate(Sample=basename(Sample)) %>%
    mutate(Sample=gsub("___COUNTS.txt","",Sample)) %>%
    mutate(Sample=gsub("_IGO_.*","",Sample)) %>%
    mutate(Sample=gsub(",.*","",Sample)) %>%
    group_by(Sample,sgRNA) %>%
    summarize(Counts=sum(Counts))

tbl=counts %>% right_join(lib,by=c(sgRNA="Seq")) %>%
    spread(Sample,Counts,fill=0) %>%
    select(-`<NA>`)

write.xlsx(tbl,cc(basename(getwd()),"___COUNTS.xlsx"))

stats=dir_ls(COUNT_DIR,regexp="___TOTAL.txt") %>%
    map(read_tsv,col_names=c("Sample","Total")) %>%
    bind_rows %>%
    mutate(Sample=basename(Sample)) %>%
    mutate(Sample=gsub("_IGO_.*","",Sample)) %>%
    gather(Metric,Value,Total) %>%
    group_by(Sample,Metric) %>%
    summarize(Value=sum(Value))

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

