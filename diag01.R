require(tidyverse)
require(magrittr)
require(openxlsx)
require(readxl)
require(edgeR)

dataFile=dir(pattern="^Proj.*_COUNTS.xlsx")
if(len(dataFile)==0) {
    cat("\n\n   Can not find COUNTS.xlsx file\n\n")
    stop("FATAL ERROR")
}
dat=read_xlsx(dataFile)
projectNo=gsub("____COUNTS.xlsx","",dataFile)
keyFile=dir(pattern="^Proj.*_STATS.xlsx")
if(len(keyFile)==0) {
    cat("\n\n   Can not find STATS.xlsx file\n\n")
    stop("FATAL ERROR")
}
key=read_xlsx(keyFile,sheet=1)
nSamps=nrow(key)
if(is.null(key$Group)) {
    cat("\n    ERROR: Need to assign Group variable in key/stats file\n\n")
    quit()
}
dat %<>% filter((dat %>% select( tail(seq(ncol(dat)),nSamps) ) %>% rowSums)>10)
dat %>% select( tail(seq(ncol(dat)),nSamps) ) %>% data.frame(.,check.names=F) -> ds
rownames(ds)=dat$ProbeID
group=factor(key$Group[match(colnames(ds),key$Sample)])
group.o=group

colnames(ds)=colnames(ds) %>% gsub("3-SB-.-","",.) %>% gsub("-BC.*","",.)

y <- DGEList(counts=ds,group=group)
y <- calcNormFactors(y,Acutoff=-16)

dd=log2(cpm(y,normalize=T)+1) %>%
    data.frame %>%
    rownames_to_column("ProbeID") %>%
    tibble %>%
    gather(Sample,Counts,-ProbeID) %>%
    mutate(Group=gsub("...$","",Sample)) %>%
    mutate(NormCounts=2^Counts)

pg1=dd %>% ggplot(aes(Sample,NormCounts,fill=Group)) + theme_linedraw(base_size=16) + coord_flip() + ggrastr::rasterize(geom_jitter(alpha=0.02,width=.4,size=.1)) + geom_violin(alpha=.5) + scale_y_log10()

x <- cpm(y, log = TRUE, prior.count = 2)

zz=MASS::isoMDS(dist(t(x)))
ww=zz$points %>% data.frame %>% rownames_to_column("Sample") %>% mutate(Group=gsub("...$","",Sample))
pg2=ww %>% ggplot(aes(X1,X2,label=Sample,color=Group,pch=Group)) + theme_linedraw(16) + ggrepel::geom_label_repel(color="black",force_pull=-.1) + geom_point(size=6,alpha=.75)

require(patchwork)

pdf(file="pltDiag01.pdf",width=8.5,height=11)
print(pg1/pg2)
dev.off()

