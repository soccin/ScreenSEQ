require(dplyr)
require(readr)
require(tidyr)
require(tibble)
require(magrittr)

# Need this or will get an error on loading
# See: https://github.com/dragua/xlsx/issues/83
#
options( java.parameters = c("-Xss2560k", "-Xmx8g") )
require(xlsx)

#############################################################################
#
# Customise to format of library file
#
stop("NEED TO CUSTOM INPUT READER TO LIBRARY FORMAT")

##projectNo=getwd() %>% basename %>% tolower
##lib=read_csv("PrepLibrary/Human_GeCKOv2_LibA,B__Collapsed.csv")

## Example B
# libFiles=c(
#     "Mouse_GeCKOv2_Library_A_09Mar2015.csv",
#     "Mouse_GeCKOv2_Library_B_09Mar2015.csv")
#
# lib=lapply(libFiles,read_csv) %>% bind_rows %>% arrange(seq)
# colnames(lib)=c("Gene","ProbeID","Seq")
#
# # Collapse duplicate sequences
# lib=lib %>%
#     select(-ProbeID) %>%
#     group_by(Seq) %>%
#     summarize(Gene=paste(Gene,collapse=";"))


# dat variable must have 3 columns
#   Seq
#   Gene
#   ProbeID
#
# where multiple ProbeID's resolve multiple genes in the
# format:
#   GENE_NAME.NUMBER_TAG
#
# a (.) can __NOT__ appear in the GENE_NAME

## lib %>%
##     mutate(Gene=gsub("\\.","_",Gene)) %>%
##     group_by(Gene) %>%
##     mutate(ProbeID=paste0(Gene,".",row_number())) %>%
##     ungroup() -> dat

#############################################################################

rawCounts=NULL
countFiles=dir("LibCounts",full.names=T)
for(fname in countFiles) {
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
dat %<>% mutate_at(funs(na2zero),.vars=(ncol(dat)-length(countFiles)+1):ncol(dat))
write.csv(as.data.frame(dat),cc(projectNo,"CountTable.csv"),row.names=F)

libTotals=dat[,-(1:(ncol(dat)-length(countFiles)))] %>% summarize_all(funs(sum))

totalCounts=rawCounts[,-1] %>% summarize_all(funs(sum(.,na.rm=T)))

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
