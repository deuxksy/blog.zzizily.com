---
title: "MLX with OpenCode"
date: 2026-01-11T19:46:31+07:00
lastmod: 2026-01-11T19:46:31+07:00
author: "Crong"
categories: ["Tech"]
tags: ["MLX","OpenCode", "10K"]
showToc: true
TocOpen: true
---

## 제목

MLX 와 OpenCode 연동 하기: 10k 토큰은 버텨야 한다

## 내용

결론은 **10k 토큰은 버텨야한다.**

맥미니 M4 에서 MLX 로 `mlx-community/Meta-Llama-3.1-8B-Instruct-8bit` 올려서 OpenCode 로 연동 해봄.

```bash
# Mac Mini 에서 돌릴수 있는 크고 아름다운 Model
mlx_lm.server \
    --model mlx-community/Meta-Llama-3.1-8B-Instruct-8bit \
    --max-tokens 4096 \
    --log-level DEBUG \
    --host 0.0.0.0 \
    --port 8080
```

OpenCode 와 MLX 연동 api-key 값은 아무거나 dumy 값 으로 아무거나

```json
# ~/.config/opencode/config.json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "mlx": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "MLX (local)",
      "options": {
        "baseURL": "http://127.0.0.1:8080/v1"
      },
      "models": {
        "mlx-community/Meta-Llama-3.1-8B-Instruct-8bit": {
          "name": "MLX Llama"
        }
      }
    }
  }
}
```

첫 Prompt 를 날려  테스트 하니깐 처음 명령어 `Hi` 날리때 10,000 토큰 넘개 날아감 와.... local 이라서 다행이다.
아무튼 10k 토큰 처리 하는데만 56초 걸림 M4 Mac mini는 초당 약 200~250 토큰을 처리한다고함, 산술적으로 **10,601 / 200 ≈ 50초** 그래도 초당 190 정도 나오냉.
두번째 날리까 빨라짐 물론 두번째는 15 토큰만 날림, 캐시된 10,600 토큰 재사용 + 신규 15 토큰 연산 (약 2~3초 소요).
하지만 세번째 날리니깐 터짐.

```bash
127.0.0.1 - - [11/Jan/2026 19:25:19] "POST /v1/chat/completions HTTP/1.1" 200 -
127.0.0.1 - - [11/Jan/2026 19:27:16] "POST /v1/chat/completions HTTP/1.1" 200 -
libc++abi: terminating due to uncaught exception of type std::runtime_error: [METAL] Command buffer execution failed: Caused GPU Timeout Error (00000002:kIOGPUCommandBufferCallbackErrorTimeout)
[1]    35712 abort      mlx_lm.server --model mlx-community/Meta-Llama-3.1-8B-Instruct-8bit    5  409
/opt/homebrew/Cellar/python@3.14/3.14.2/Frameworks/Python.framework/Versions/3.14/lib/python3.14/multiprocessing/resource_tracker.py:396: UserWarning: resource_tracker: There appear to be 1 leaked semaphore objects to clean up at shutdown: {'/mp-5y73nmc1'}
  warnings.warn(
```

**libc++abi: terminating due to uncaught exception of type std::runtime_error: [METAL] Command buffer execution failed: Caused GPU Timeout Error**

VRAM 부족으로 및 연산 지연 오류라고 함 그래서 `mlx-community/Llama-3.2-3B-Instruct-4bit` 낮추어서 다시 해봄.

```bash
# Mac Mini 에서 돌릴수 있는 귀엽고 아름다운 Model
mlx_lm.server \
    --model mlx-community/Llama-3.2-3B-Instruct-4bit \
    --max-tokens 4096 \
    --log-level DEBUG \
    --host 0.0.0.0 \
    --port 8080
```

10k 토큰 나가는 건 동일한 아마 처음 연결할때 항상 이런저런 정보다 넣겨서 그런거 같음, 그래도 처리하는데 20초 로 Model 사이즐 줄은 만큼 속도 빨라짐.
두번째 부터는 실사용에 무리가 없음....

10k 토큰 엄청 크고 책이나 그런거 아니면  쓸까 했는데.
아님 Agent 애서 처음 연결할때 그냥 10k 토큰 부터 박고 시작하는구나.

역시 귀여운게 최고야!~
