FROM python:3.10-slim

RUN apt-get update && apt-get install -y sysbench iperf3 curl procps default-mysql-client \
    && pip install --upgrade pip matplotlib psutil

WORKDIR /app

COPY benchmark_docker.sh .

RUN chmod +x benchmark_docker.sh

CMD ["./benchmark_docker.sh"]