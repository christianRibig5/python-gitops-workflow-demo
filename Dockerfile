# Multi-stage  build
# Install app dependencies in the  build stage
# Copy them into the runtine stage to produce final light weight image

# --------------Build Stage------------- 
FROM python:3.11.16-slim-trixie AS build
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir \
    --prefix=/dependencies \
    -r requirements.txt

#------------Runtime Stage----------------

FROM python:3.11.16-slim-trixie AS runtime
WORKDIR /app
COPY --from=build /dependencies /usr/local

# Upgrade packaging to pass trivy scan
# Trivy checks the built image against a list of
# known security problems and flag when it highly critical
RUN python -m pip install \
    --no-cache-dir \
    --upgrade \
    "setuptools==84.0.0" \
    "wheel==0.48.0"
COPY . .
EXPOSE 5000
CMD ["python","app.py"]
