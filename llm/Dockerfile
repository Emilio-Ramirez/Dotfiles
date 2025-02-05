FROM ubuntu:latest

# Install dependencies in a single RUN command to reduce layers
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*  # Clean up apt cache

# Clone and build llama.cpp
WORKDIR /app
RUN git clone https://github.com/ggerganov/llama.cpp . && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_C_FLAGS="-mcpu=generic" -DCMAKE_CXX_FLAGS="-mcpu=generic" \
        -DLLAMA_BLAS=ON -DLLAMA_AVX=ON -DLLAMA_F16C=ON && \
    cmake --build . --config Release -j$(nproc)

# Create directory for models
RUN mkdir /models

# Set working directory
WORKDIR /app

EXPOSE 8088

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8088/health || exit 1

# Command to run when container starts
CMD ["./build/bin/server", "-m", "/models/DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf", \
     "--port", "8088", "--host", "0.0.0.0", "--ctx-size", "2048", "--threads", "4"]
