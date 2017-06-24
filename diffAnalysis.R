library(dplyr)
require(readr)
require(tidyr)
require(tibble)
require(magrittr)
library(xlsx)
require(edgeR)

dataFile=dir(pattern="_COUNTS.rda")
load(dataFile)
projectNo=gsub("_COUNTS.rda","",dataFile)

dat %<>% filter((dat %>% select(5:ncol(dat)) %>% rowSums)>10)


dat %>% select(5:ncol(dat)) %>% data.frame -> ds
rownames(ds)=dat$ProbeID


keyFile=dir(pattern="^p.*_STATS.xlsx")
key=read.xlsx(keyFile,sheetIndex=1)
group=factor(key$Group[match(colnames(ds),key$Sample)])

y <- DGEList(counts=ds,group=group)
y <- calcNormFactors(y)

design <- model.matrix(~0+group, data=y$samples)
colnames(design) <- levels(y$samples$group)

gNames=sort(levels(y$samples$group),decreasing=T)
contrast=paste(paste0(gNames,collapse="Vs"),"=",paste0(gNames,collapse="-"))
cm=makeContrasts(contrast,levels=design)

pdf(cc(projectNo,"DiffAnalysis.pdf"))

boxplot(log2(cpm(y,normalize=T)+1))
plotMDS(y)

y <- estimateDisp(y,design)
fit <- glmFit(y,design)
lrt <- glmLRT(fit,contrast=cm[,1])

tbl=topTags(lrt,n=Inf)$table

FDR_CUT=0.05
nSig=sum(tbl$FDR<FDR_CUT)
topIds=rownames(tbl)[seq(nSig)]

plotSmear(lrt,de.tags=topIds,pch=20,cex=0.6)
abline(h=c(-1,0,1),col=c("dodgerblue","yellow","dodgerblue"),lty=2)

OUTXLSX=cc(projectNo,"DiffAnalysis.xlsx")
write.xlsx2(topTags(lrt,n=nSig)$table,OUTXLSX,sheetName="ProbeLevel")

probes=rownames(y$counts)
genes=gsub(".\\d+$","",probes)
geneLists=sapply(unique(genes),function(x){which(x==genes)})
gsa=camera(y,index=geneLists,design,contrast=cm[,1])
logFCgsa=sapply(geneLists,function(z){mean(tbl[probes[z],]$logFC)})
gsa=cbind(gsa,logFC=logFCgsa[rownames(gsa)])

topGSA=gsa[gsa$FDR<FDR_CUT,]

xMax=ceiling(max(abs(gsa$logFC)))
plot(gsa$logFC,gsa$PValue,log="y",pch=19,col=8,xlim=c(-1,1)*xMax,
            xlab="logFC",ylab="Pvalue")

abline(h=0.05,lty=2,lwd=2,col=8)
abline(v=c(-1,0,1),lty=2,lwd=2,col=8)
points(gsa$logFC,gsa$PValue)
points(topGSA$logFC,topGSA$PValue,col="#FF8888",pch=19,cex=.8)

write.xlsx2(topGSA,OUTXLSX,sheetName="GeneLevel",append=T)

dev.off()
