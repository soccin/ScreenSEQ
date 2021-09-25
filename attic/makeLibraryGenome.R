
args=commandArgs(trailing=T)

if(len(args)<2) {
    cat("\n    usage: makeLibraryGenome.R AMPLICON.TXT LIBRARY.CSV\n\n")
    quit()
}

library(tidyverse)
library(stringr)

amplicon=scan(args[1],"")
lib=read_csv(args[2])
base=paste0(gsub(".csv","",basename(args[2])),"__LibGenome")

lib=lib %>%
    group_by(Gene.Symbol) %>%
    mutate(ProbeID=paste0(Gene.Symbol,";",row_number())) %>%
    ungroup

lib$Sequence=as.character(
    sapply(lib$sgRNA.sequence,
        function(x){
            gsub(amplicon[3],tolower(x),paste0(amplicon,collapse=""))
        }
        )
    )

write_tsv(
    as.data.frame(lib %>% select(ProbeID,Sequence)),
    paste0(base,".txt"),col_names=F)

lib %>%
    select(sgRNA.sequence,Gene.Symbol,ProbeID) %>%
    rename(Seq=sgRNA.sequence,Gene=Gene.Symbol) %>%
    write_csv(paste0(base,".csv"))
