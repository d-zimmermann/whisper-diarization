# Use NVIDIA's CUDA base image
FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/app/venv

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    libncurses5-dev \
    zlib1g-dev \
    libreadline-dev \
    libbz2-dev \
    libsqlite3-dev \
    cython3 \
    sox \
    wget \
    ffmpeg \
    git \
    python3 \
    python-is-python3 \
    python3-venv \
    pip \
    && apt-get clean autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

# Copy requirements & constraints file
COPY requirements.txt .
COPY constraints.txt .

RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python packages
RUN pip install --no-cache-dir numpy typing_extensions

# Install Python packages
RUN pip install --no-cache-dir -c constraints.txt -r requirements.txt

# Copy the application code
COPY . .

# Make diarize.py executable
RUN chmod +x diarize.py

ENV LD_LIBRARY_PATH="/app/venv/lib/python3.10/site-packages/nvidia/cudnn/lib"

# Set the entrypoint
ENTRYPOINT ["python", "diarize.py"]