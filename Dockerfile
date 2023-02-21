FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
RUN curl -L https://foundry.paradigm.xyz | bash
RUN foundryup

COPY ./ ./


WORKDIR /script/deploy/

CMD [ "./deploy-all-contracts.sh" ]

