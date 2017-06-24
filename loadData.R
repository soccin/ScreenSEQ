require(dplyr)
require(readr)
require(tidyr)
require(tibble)
require(magrittr)
require(xlsx)

#############################################################################
#
# Customise to format of library file
#
lib=read_csv("human-druggable-top5.csv")
colnames(lib)=c("Gene","Seq","Flag")
projectNo="proj07665"
#############################################################################

lib %>%
    group_by(Gene) %>%
    mutate(ProbeID=paste0(Gene,".",row_number())) %>%
     ungroup() -> dat

rawCounts=NULL
for(fname in dir("LibCounts",full.names=T)) {
    cat(fname,"\n")
    counts=read_tsv(fname,col_names=c("Counts","Seq"))
    dat %<>% left_join(counts,by="Seq")
    sampleName=make.names(gsub("LibCounts.","",gsub(".counts","",fname)))
    colnames(dat)[ncol(dat)]=sampleName
    colnames(counts)[1]=sampleName
    if(is.null(rawCounts)){
        rawCounts=counts %>% select(2,1)
    } else {
        rawCounts %<>% full_join(counts,by="Seq")
    }
}

na2zero<-function(x){ifelse(is.na(x),0,x)}
dat %<>% mutate_each(funs(na2zero),5:ncol(dat))
write.csv(as.data.frame(dat),cc(projectNo,"CountTable.csv"),row.names=F)

libTotals=dat[,-(1:4)] %>% summarize_each(funs(sum))
totalCounts=rawCounts[,-1] %>% summarize_each(funs(sum(.,na.rm=T)))

bind_rows(libTotals,totalCounts) %>%
    mutate(Type=c("Lib","Total")) %>%
    gather(Sample,Counts,-ncol(.)) %>%
    spread(Type,Counts) %>%
    select(Sample,Total,Lib) %>%
    mutate(PCT=Lib/Total) -> stats

rawCounts=rawCounts[order(rowSums(rawCounts[,-1],na.rm=T),decreasing=T),]
rawCounts %<>% filter(rowSums(rawCounts[,-1]>5,na.rm=T)>=2)

save(lib,dat,rawCounts,stats,file=paste0(projectNo,"_COUNTS",".rda"),compress=T)

write.xlsx(as.data.frame(stats),paste0(projectNo,"_STATS",".xlsx"),row.names=F)
