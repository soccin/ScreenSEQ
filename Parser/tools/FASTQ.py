from dataclasses import dataclass
import gzip

def read4Lines(fp):
    res=[]
    for line in fp:
        if type(line)==bytes:
            line=line.decode('ascii')
        res.append(line.strip())
        if len(res)==4:
            yield res
            res=[]

    if len(res)>0:
        print(res)

@dataclass
class FASTQ:
    seq: str
    desc: str
    qual: str

def read_FASTQ(fqFile):
    if fqFile.endswith(".gz"):
        fp=gzip.open(fqFile,"rb")
    else:
        fp=open(fqFile,"r")

    for rec4 in read4Lines(fp):
        yield FASTQ(rec4[1],rec4[0],rec4[3])

    fp.close()
