FROM ubuntu:22.04
RUN apt update
RUN apt install -y python3
RUN apt install -y python3-pip
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . /opt/
WORKDIR /opt
CMD ["uvicorn", "main:app", "--host=0.0.0.0", "--port=80"]