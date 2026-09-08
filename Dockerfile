#SINGLE stage Image Build
# FROM python:3.11-slim
# WORKDIR /app
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt
# COPY . .
# EXPOSE 5000
# CMD [ "python", "app.py" ]

#Multi stage Build
#Stage 1: Build dependencies

FROM python:3.11.16-slim-trixie AS build

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir \
    --prefix=/dependencies \
    -r requirements.txt

#Stage 2: Runtime Image

FROM python:3.11.16-slim-trixie AS runtime


WORKDIR /app

COPY --from=build /dependencies /usr/local

# Upgrade after dependencies to fix the trivy vunerability validation
RUN python -m pip install \
    --no-cache-dir \
    --upgrade "wheel>=0.46.2"

COPY . .

EXPOSE 5000

CMD ["python","app.py"]
