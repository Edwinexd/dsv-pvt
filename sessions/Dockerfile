FROM python:3.11.7-slim-bullseye

# Install dependencies
COPY ./requirements.txt /app/requirements.txt
RUN python3.11 -m pip install -r /app/requirements.txt

COPY . /app

WORKDIR /app

EXPOSE 80

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
