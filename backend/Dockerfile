FROM python:3.11.7-slim-bullseye

WORKDIR /code

# Install dependencies
COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./sql_app /code/sql_app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
