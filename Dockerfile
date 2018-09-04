FROM conda/miniconda3

RUN apt-get update && apt-get install -y git wget

RUN conda create --name bigscape
#RUN source activate bigscape
RUN [ "/bin/bash", "-c","source activate bigscape"]
RUN conda install -y \
 	numpy \  
	scipy \ 
	scikit-learn 

RUN conda install -c bioconda hmmer biopython fasttree
RUN conda install -c anaconda networkx

COPY ./ /usr/src/BiG-SCAPE
WORKDIR /usr/src
## Cloning BiG-SCAPE
#RUN git clone https://github.com/greatfireball/ime_big_scape.git

## geting Pfam
WORKDIR /usr/src/BiG-SCAPE
RUN wget -O - ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.hmm.gz | zcat - >Pfam-A.hmm && hmmpress Pfam-A.hmm

RUN chmod +x /usr/src/BiG-SCAPE/*py  
RUN chmod 777 /home  
ENV PATH /usr/src/BiG-SCAPE:$PATH
USER 1000:1000
RUN mkdir /home/input /home/output
WORKDIR /home
ENTRYPOINT ["bigscape.py"]
CMD ["--help"]

