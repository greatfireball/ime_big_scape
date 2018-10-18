ARG osversion=20180904
FROM greatfireball/conda-miniconda3:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE
ARG osversion

RUN echo "osversion: "${osversion}", VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

LABEL maintainer="frank.foerster@ime.fraunhofer.de" \
      description="Dockerfile providing the Big scape pipeline" \
      version=${VERSION} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="https://github.com/greatfireball/ime_big_scape.git"

RUN apt-get update && apt-get install -y git wget

RUN conda create --name bigscape --yes
#RUN source activate bigscape
RUN [ "/bin/bash", "-c","source activate bigscape"]
RUN conda install -y \
 	numpy \  
	scipy \ 
	scikit-learn 

RUN conda install -y -c bioconda hmmer biopython fasttree
RUN conda install -y networkx

WORKDIR /usr/src
## Cloning BiG-SCAPE
RUN git clone https://github.com/greatfireball/ime_big_scape.git BiG-SCAPE && \
    cd BiG-SCAPE && \
    git checkout ${VCS_REF} && \
    rm -rf .git

## geting Pfam
WORKDIR /usr/src/BiG-SCAPE
RUN wget -O - ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.hmm.gz | \
    zcat - >Pfam-A.hmm && \
    hmmpress Pfam-A.hmm

RUN chmod +x /usr/src/BiG-SCAPE/*py  
RUN chmod 777 /home  
RUN chmod a+wr /usr/src/BiG-SCAPE/domains_color_file.tsv
ENV PATH /usr/src/BiG-SCAPE:$PATH
USER 1000:1000
RUN mkdir /home/input /home/output
WORKDIR /home
ENTRYPOINT ["bigscape.py"]
CMD ["--help"]

