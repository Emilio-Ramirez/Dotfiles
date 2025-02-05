# Local LLM Setup

This directory contains configuration and models for local LLM (Large Language Model) usage, specifically optimized for coding assistance.

## Model Information

Currently using DeepSeek-Coder-V2-Lite-Instruct, a coding-specialized language model:

- Base model: [DeepSeek-Coder-V2-Instruct](https://huggingface.co/deepseek-ai/DeepSeek-Coder-V2-Instruct)
- Quantization: Q4_K_M (good quality, ~10.36GB, optimized for performance/size balance)
- GGUF version: [DeepSeek-Coder-V2-Lite-Instruct-GGUF](https://huggingface.co/bartowski/DeepSeek-Coder-V2-Lite-Instruct-GGUF)

## Directory Structure

```fileStructure
llm/
├── models/ # Storage for GGUF model files
├── config/ # Configuration files
└── README.md # This file
```

## Usage

Start the local server:

```bash
llama-server -m ~/.config/llm/models/DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf --port 8088
```

## Technical Details

- Framework: [llama.cpp](https://github.com/ggerganov/llama.cpp)
- Model size: 10.36GB
- Memory usage: ~11GB during operation
- Context length: 128k tokens
- Quantization: Q4_K_M (4-bit, medium size)

## Server Configuration

Default settings:

- Port: 8088
- Host: localhost
- API format: Compatible with OpenAI API

## Integration

This model is integrated with LazyVim for code completion and assistance.
Configuration can be found in the [nvim documentation](../nvim/README.md).

## Docker Alternative

If you prefer to run the server in a container, you can use Docker:

### Prerequisites

1. Docker installed and running
2. At least 12GB of available RAM
3. Model file in `~/.config/llm/models/`

### Starting with Docker

Start the server in detached mode:

```bash
docker-compose up -d
```

Stop the server:

```bash
docker-compose down
```

The server can also be managed through the Docker Desktop Dashboard.
