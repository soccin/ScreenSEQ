args=commandArgs(trailing=T)

if(len(args)!=1) {
    cat("\n    usage: joinCounts.R LIBRARY_FILE.csv\n\n")
    quit()
}

library(tidyverse)
library(magrittr)
options( java.parameters = c("-Xss2560k", "-Xmx8g") )
library(xlsx)

libraryFile=args[1]
lib=read_csv(libraryFile)

if(!all(c("Seq","Gene","ProbeID") %in% colnames(lib))) {
    cat("\n    ERROR: library file must have Seq,Gene,ProbeID columns\n")
    cat("    cols:= [",paste0(colnames(lib),collapse=","),"]\n\n")
    quit()
}

cfiles=dir("Counts",full.names=T)
dd=lapply(cfiles,read_tsv,col_names=F)

names(dd)=make.names(gsub(".*__","",cfiles))
dx=bind_rows(dd,.id="Sample")
dat=dx %>% spread(Sample,X2) %>% rename(ProbeID=X1)

na2zero<-function(x){ifelse(is.na(x),0,x)}

dat %<>% mutate_at(funs(na2zero),.vars=(ncol(dat)-length(cfiles)+1):ncol(dat))

dat=left_join(dat,lib) %>% select(Seq,Gene,ProbeID,2:(ncol(dat)))

base=tolower(basename(getwd()))
dat %>% write_csv(paste0(base,"_COUNTS.csv"))
save(dat,file=paste0(base,"_COUNTS.rda"),compress=T)

libCounts=dx %>% group_by(Sample) %>% summarize(Lib=sum(X2))

ff=dir("out___",pattern="AS.txt",full.names=T)
stats=lapply(ff,read_tsv,comment="#",skip=1)
names(stats)=basename(ff) %>% gsub("s_","",.) %>% gsub("___.*","",.)

totalCounts=bind_rows(stats,.id="Sample") %>%
    filter(CATEGORY=="FIRST_OF_PAIR") %>%
    select(Sample,TOTAL_READS) %>%
    mutate(Sample=make.names(Sample)) %>%
    rename(Total=TOTAL_READS) %>%
    mutate(Total=as.numeric(Total))

stats=full_join(totalCounts,libCounts) %>%
    mutate(PCT=Lib/Total) %>%
    mutate(Group=gsub(".$","",Sample))

write.xlsx(as.data.frame(stats),paste0(base,"_STATS.xlsx"),row.names=F)

