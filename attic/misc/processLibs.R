library(readxl)
library(readr)
library(dplyr)
library(tidyr)

# Sample Code to process screen library files into a consistent format

l1=read_csv("Human_GeCKOv2_Library_A_09Mar2015.csv")
l2=read_csv("Human_GeCKOv2_Library_B_09Mar2015_1.csv")
ll=rbind(l1,l2)

ll %>%
    select(gene_id, seq) %>%
    group_by(seq) %>%
    summarize(Gene=paste0(unique(gene_id),collapse=";")) %>%
    rename(Seq=seq) -> xx

write.csv(as.data.frame(xx),"Human_GeCKOv2_LibA,B__Collapsed.csv",row.names=F,quote=F)
