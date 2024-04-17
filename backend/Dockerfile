FROM python:3.11.7-slim-bullseye

WORKDIR /code

# Install dependencies
COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./sql_app /code/sql_app

EXPOSE 80

CMD ["uvicorn", "sql_app.main:app", "--host", "0.0.0.0", "--port", "80"]
