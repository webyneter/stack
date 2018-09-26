# Build as: docker build -t aws-stack .
# Run as: docker run --rm -it --net=host \
#    -v $PWD:$PWD -w $PWD \
#    -v /tmp:/tmp -v ~/.aws:/root/.aws \
#    -e AWS_DEFAULT_REGION=us-east-1 aws-stack make amis

FROM python:3.5-slim

RUN pip3 install mypy-lang==0.4 flake8==2.5.4 pyyaml boto3
RUN apt-get update \
    && apt-get install -y curl unzip make \
    && apt-get clean

COPY ./tools /usr/local/bin/

RUN curl -sL "https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip"> terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/

RUN curl -sL "https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip" > packer.zip \
    && unzip packer.zip \
    && mv packer /usr/local/bin/

RUN curl -sL -o /usr/local/bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64" \
    && chmod +x /usr/local/bin/dumb-init

ADD . /src

RUN cd /src && make install

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
