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

FROM python:3.11-slim AS build

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir \
    --prefix=/dependencies \
    -r requirements.txt

#Stage 2: Runtime Image

FROM python:3.11-slim AS runtime

# Fix CVE-2026-24049 in the runtime image
RUN python -m pip install --no-cache-dir --upgrade "wheel>=0.46.2"

WORKDIR /app

COPY --from=build /dependencies /usr/local
COPY . .

EXPOSE 5000

CMD ["python","app.py"]
