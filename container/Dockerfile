FROM ubuntu:20.04
LABEL maintainer="the internet"

# volume for entrypoint
VOLUME /configs

# apt-get installs
RUN apt-get update && \
    apt-get install -y hugo git vim curl apt-transport-https ca-certificates gnupg unzip python3-pip

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN apt-get update && \
    apt-get install -y google-cloud-sdk

# Python pip installs
RUN pip install mkdocs

# binary installs
WORKDIR /configs

RUN curl -O https://releases.hashicorp.com/terraform/1.0.3/terraform_1.0.3_SHA256SUMS && \
    curl -O https://releases.hashicorp.com/terraform/1.0.3/terraform_1.0.3_linux_amd64.zip && \
    echo "$(grep terraform_1.0.3_linux_amd64.zip terraform_1.0.3_SHA256SUMS)" | sha256sum -c && \
    unzip terraform_1.0.3_linux_amd64.zip -d /usr/bin

# clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /configs*


ENTRYPOINT ["/bin/bash"]