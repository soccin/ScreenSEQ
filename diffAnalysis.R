require(dplyr)
require(readr)
require(tidyr)
require(tibble)
require(magrittr)
require(readxl)
require(edgeR)

dataFile=dir(pattern="_COUNTS.rda")
load(dataFile)
projectNo=gsub("_COUNTS.rda","",dataFile)

keyFile=dir(pattern="^p.*_STATS.xlsx")
key=read_xlsx(keyFile,sheet=1)
nSamps=nrow(key)

if(is.null(key$Group)) {
    cat("\n    ERROR: Need to assign Group variable in key/stats file\n\n")
    quit()
}

dat %<>% filter((dat %>% select( tail(seq(ncol(dat)),nSamps) ) %>% rowSums)>10)
dat %>% select( tail(seq(ncol(dat)),nSamps) ) %>% data.frame -> ds
rownames(ds)=dat$ProbeID
group=factor(key$Group[match(colnames(ds),key$Sample)])

#
# setTag="" if only one comp
# setTag=<regexp> to pick out specific comp
#
setTag="_NEED_TO_SET"
stop("Set setTag")
if(setTag!="") {
    cat("Processing Set",setTag,"\n")
    ds=ds[,grepl(setTag,colnames(ds))]
    ds=ds[rowSums(ds)>10,]
    group=droplevels(group[grepl(setTag,group)])
}

if(nlevels(group)>2) {
    cat("\n   More than two groups [",nlevels(group),"]\n")
    cat("   Can not do auto analysis\n\n")
    quit()
}

y <- DGEList(counts=ds,group=group)
y <- calcNormFactors(y)

design <- model.matrix(~0+group, data=y$samples)
colnames(design) <- levels(y$samples$group)

gNames=sort(levels(y$samples$group),decreasing=T)
contrast=paste(paste0(gNames,collapse="Vs"),"=",paste0(gNames,collapse="-"))
cm=makeContrasts(contrast,levels=design)

pdf(cc(projectNo,cc("DiffAnalysis",make.names(setTag),".pdf")))

boxplot(log2(cpm(y,normalize=T)+1))
plotMDS(y)

y <- estimateDisp(y,design)
fit <- glmFit(y,design)
lrt <- glmLRT(fit,contrast=cm[,1])

tbl=topTags(lrt,n=Inf)$table

FDR_CUT=0.05
nSig=sum(tbl$FDR<FDR_CUT)
if(nSig<1) {
    cat("\n\n\n\tNO SIGNIFICANT PROBES at FDR<=",FDR_CUT,"\n\n")
}
topIds=rownames(tbl)[seq(nSig)]

plotSmear(lrt,de.tags=topIds,pch=20,cex=0.6)
abline(h=c(-1,0,1),col=c("dodgerblue","yellow","dodgerblue"),lty=2)

options( java.parameters = c("-Xss2560k", "-Xmx8g") )
require(xlsx)
OUTXLSX=cc(projectNo,cc("DiffAnalysis",make.names(setTag),".xlsx"))

ans=topTags(lrt,n=nSig)$table
dn=cpm(y)
pseudo=min(dn[dn>0])

avgCounts=t(apply(dn[rownames(ans),,drop=F],1,function(x){2^tapply(log2(x+pseudo),group,mean)-pseudo}))
avgAll=2^(apply(log2(dn[rownames(ans),,drop=F]+pseudo),1,mean))-pseudo
logFC=ans$logFC
FC=ifelse(logFC<0,-2^(-logFC),2^logFC)
libDat=dat[match(rownames(ans),dat$ProbeID),c(1,2,3)]

ans1=cbind(libDat,FC,ans[,c(1,4,5)],avgAll,avg=avgCounts)

write.xlsx2(ans1,OUTXLSX,sheetName="ProbeLevel",row.names=F)

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

dev.off()

write.xlsx2(topGSA,OUTXLSX,sheetName="GeneLevel",append=T)

