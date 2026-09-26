# Multi-stage  build
# Install app dependencies in the  build stage
# Copy them into the runtine stage to produce final light weight image

# -------------- Build Stage --------------
FROM python:3.11.16-slim-trixie AS build

WORKDIR /app

# Apply Debian security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    --prefix=/dependencies \
    -r requirements.txt


# -------------- Runtime Stage --------------
FROM python:3.11.16-slim-trixie AS runtime

WORKDIR /app

# Apply Debian security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /dependencies /usr/local

# Upgrade Python packaging tools
RUN python -m pip install \
    --no-cache-dir \
    --upgrade \
    "setuptools==84.0.0" \
    "wheel==0.48.0"

COPY . .

# Create deterministic non-root application user/group.
# Numeric UID/GID allows Kubernetes to verify runAsNonRoot.
RUN groupadd --gid 10001 appgroup \
    && useradd \
    --uid 10001 \
    --gid 10001 \
    --create-home \
    --shell /usr/sbin/nologin \
    appuser

# Application files are owned by the non-root runtime identity.
RUN chown -R 10001:10001 /app

USER 10001:10001

EXPOSE 5000

CMD ["python", "app.py"]