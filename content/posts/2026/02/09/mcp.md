---
title: "OpenCode, Cline, Mods 에 MCP Setup"
date: 2026-02-09T02:51:33+07:00
lastmod: 2026-02-09T02:51:33+07:00
author: "Crong"
categories: ["Tech"]
tags: ["Draft"]
showToc: true
TocOpen: true
---

## 제목

MCP 설정하기

## 내용

OpenCode, Cline, Mods 에 MCP 설정하기

### OpenCode

```json
# ~/.config/opencode/opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "read": {
      "*.env": "deny",
      "*": "allow"
    },
    "glob": "allow",
    "grep": "allow",
    "list": "allow",
    "task": "allow",
    "external_directory": "allow",
    "todoread": "allow",
    "webfetch": "allow",
    "websearch": "allow",
    "codesearch": "allow",
    "lsp": "allow",
    "doom_loop": "allow",
    "skill": "allow",
    "edit": "deny",
    "question": "allow",
    "bash": {
      "rm *": "deny",
      "git rm *": "deny",
      "cp *": "ask",
      "mv *": "ask",
      "git status": "allow",
      "git log": "allow",
      "git diff": "allow",
      "git pull*": "ask",
      "git reset*": "ask",
      "git checkout*": "ask",
      "git *": "ask",
      "ls *": "allow",
      "cat *": "allow",
      "head *": "allow",
      "tail *": "allow",
      "grep *": "allow",
      "mkfs*": "deny",
      "shred *": "deny",
      "dd *": "deny",
      "| xargs rm": "deny",
      "-delete": "deny",
      "-exec delete": "deny",
      "-exec rm *": "deny",
      "find *": "ask",
      "*": "ask"
    }
  },
  "mode": {
    "plan": {
      "permission": {
        "question": "allow",
        "bash": {
          "git commit *": "ask",
          "git rm *": "deny",
          "git push *": "deny",
          "git *": "allow",
          "*": "ask"
        }
      }
    },
    "build": {
      "permission": {
        "bash": {
          "rm *": "ask",
          "cp *": "ask",
          "mv *": "ask",
          "find *": "ask",
          "git rm *": "ask",
          "git push *": "ask",
          "git reset *": "ask",
          "git *": "allow",
          "*": "allow"
        },
        "edit": {
          "*.env": "deny",
          "*": "allow"
        },
        "todowrite": "allow"
      }
    }
  },
  "provider": {
    "zai-coding-plan": {
      "options": {
        "apiKey": "{{ZAI_API_KEY}}",
        "timeout": 900000,
        "setCacheKey": true
      }
    },
  "mcp": {
    "github": {
      "type": "local",
      "command": ["mcp-server-github"],
      "environment": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "{{GITHUB_PERSONAL_ACCESS_TOKEN}}"
      }
    },
    "📅⏰": {
      "type": "local",
      "command": ["mcp-server-time", "--local-timezone=Asia/Ho_Chi_Minh"]
    },
    "🖥️📂": {
      "type": "local",
      "command": [
        "mcp-server-filesystem",
        "/Users/crong"
      ]
    },
    "🖥️🐏": {
      "type": "local",
      "command": ["mcp-server-memory"]
    },
    "🤔💭": {
      "type": "local",
      "command": [
        "mcp-server-sequential-thinking"
      ]
    },
    "Ⓜ️🎭": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp@latest"]
    },
    "whistle-mcp": {
      "type": "local",
      "command": ["whistle-mcp", "--host=127.0.0.1", "--port=8888"]
    },
    "Z.ai🖼️": {
      "type": "local",
      "command": ["npx", "-y", "@z_ai/mcp-server"],
      "environment": {
        "Z_AI_API_KEY": "{{ZAI_API_KEY}}",
        "Z_AI_MODE": "ZAI"
      }
    },
    "Z.ai🌿": {
      "type": "remote",
      "url": "https://api.z.ai/api/mcp/zread/mcp",
      "headers": {
        "Authorization": "Bearer {{ZAI_API_KEY}}"
      }
    },
    "Z.ai🔎": {
      "type": "remote",
      "url": "https://api.z.ai/api/mcp/web_search_prime/mcp",
      "headers": {
        "Authorization": "Bearer {{ZAI_API_KEY}}"
      }
    },
    "Z.ai🤲": {
      "type": "remote",
      "url": "https://api.z.ai/api/mcp/web_reader/mcp",
      "headers": {
        "Authorization": "Bearer {{ZAI_API_KEY}}"
      }
    }
  },
  "plugin": ["opencode-ignore", "opencode-wakatime"]
}

```

### Cline

```json
# ~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
{
  "mcpServers": {
    "github": {
      "command": "mcp-server-github"
    },
    "💻📂": {
      "command": "mcp-server-filesystem",
      "args": ["/Users/crong"]
    },
    "💻🐏": {
      "command": "mcp-server-memory"
    },
    "📅⏰": {
      "command": "mcp-server-time"
    },
    "🤔💭": {
      "command": "mcp-server-sequential-thinking"
    },
    "Ⓜ️🎭": {
      "type": "stdio",
      "command": "npx",
      "timeout": 30,
      "args": [
        "-y",
        "@playwright/mcp@latest"
      ],
      "disabled": false
    },
    "Z.ai🖼️": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@z_ai/mcp-server"],
      "env": {
        "Z_AI_API_KEY": "{{ZAI_API_KEY}}",
        "Z_AI_MODE": "ZAI"
      },
      "autoApprove": [
        "ui_to_artifact",
        "extract_text_from_screenshot",
        "diagnose_error_screenshot",
        "understand_technical_diagram",
        "analyze_data_visualization",
        "ui_diff_check",
        "analyze_image",
        "analyze_video"
      ]
    },
    "Z.ai🔎": {
      "type": "streamableHttp",
      "url": "https://api.z.ai/api/mcp/web_search_prime/mcp",
      "headers": {
        "Authorization": "Bearer {{ZAI_API_KEY}}"
      }
    },
    "Z.ai🤲": {
      "type": "streamableHttp",
      "url": "https://api.z.ai/api/mcp/web_reader/mcp",
      "headers": {
        "Authorization": "Bearer {{ZAI_API_KEY}}"
      }
    },
    "Z.ai🌿": {
      "type": "streamableHttp",
      "url": "https://api.z.ai/api/mcp/zread/mcp",
      "headers": {
        "Authorization": "Bearer {{ZAI_API_KEY}}"
      }
    }
  }
}

```

### Mods

```yaml
# ~/Library/Application Support/mods/mods.yml
default-api: z-ai
default-model: glm-4.7
format-text:
  markdown: 'Format the response as markdown without enclosing backticks.'
  json: 'Format the response as json without enclosing backticks.'
mcp-servers:
  github:
    command: "mcp-server-github"
    env:
      - "GITHUB_PERSONAL_ACCESS_TOKEN={{GITHUB_PERSONAL_ACCESS_TOKEN}}"
  🖥️📂:
    command: "mcp-server-filesystem"
    args:
      - "/Users/crong"
  🖥️🐏:
    command: "mcp-server-memory"
  📅⏰:
    command: "mcp-server-time"
    args:
      - "--local-timezone=Asia/Ho_Chi_Minh"
  🤔💭:
    command: "mcp-server-sequential-thinking"
  Ⓜ️🎭:
    command: "npx"
    args:
      - "@playwright/mcp@latest"
  Z.ai🖼️:
    command: "zai-mcp-server"
    env:
      - "Z_AI_API_KEY={{ZAI_API_KEY}}"
      - "Z_AI_MODE=ZAI"
  Z.ai🔎:
    command: "mcp-remote"
    args:
      - "https://api.z.ai/api/mcp/web_search_prime/mcp"
      - "--header"
      - "Authorization: Bearer {{ZAI_API_KEY}}"
  Z.ai🤲:
    command: "mcp-remote"
    args:
      - "https://api.z.ai/api/mcp/web_reader/mcp"
      - "--header"
      - "Authorization: Bearer {{ZAI_API_KEY}}"
  Z.ai🕎:
    command: "mcp-remote"
    args:
      - "https://api.z.ai/api/mcp/zread/mcp"
      - "--header"
      - "Authorization: Bearer {{ZAI_API_KEY}}"
mcp-timeout: 60s
roles:
  "default": []
  "empty": []
  "engineer":
    - "당신은 시니어 엔지니어(Java Spring, DevOps) 이자 기술 아키텍트인 'StackOverflow'입니다."
    - "모든 답변은 다음 'Verification Protocol'을 강제로 준수해야 합니다:"
    - "1. [부정적 전제] 무조건 '예'라고 하지 마십시오. OS별(Windows/macOS/Linux) 기능 제약이나 삭제된 버전의 가능성을 먼저 언급하십시오."
    - "2. [팩트 체크] UI 메뉴 경로는 환각이 심하므로, 설정 파일(Plist, JSON, Config)의 키 이름이나 필드명을 우선적으로 제공하십시오."
    - "3. [실시간 검색] 추측하지 마십시오. 공식 문서(Changelog)나 이슈 트래커를 검색한 결과만 요약하여 제공하십시오."
    - "4. [3-Strike Rule] 동일한 잘못된 정보를 2회 반복하면 즉시 한계를 인정하고 대화를 중단하거나 접근 방식을 변경하십시오."
    - "5. [응답 형식] 반드시 '🔍 상황 분석', '🏗️ 해결 방안', '🛡️ 검증 프로토콜', '💡 전문가적 견해' 순으로 답변하고, 최소 3가지 옵션을 시각화하여 제시하십시오."
format: false
role: "engineer"
raw: false
quiet: false
temp: 1.0
topp: 1.0
topk: 50
no-limit: false
word-wrap: 80
include-prompt-args: false
include-prompt: 0
max-retries: 5
fanciness: 10
status-text: Loading
theme: catppuccin
max-input-chars: 12250
max-completion-tokens: 100
apis:
  google-gemma:
    base-url: https://generativelanguage.googleapis.com/v1beta/openai/
    api-key: ""
    api-key-env: GOOGLE_API_KEY_MODS
    models:
      gemma-3-27b-it:
        aliases: ["g3-27b", "g3l"]
        max-input-chars: 392000
      gemma-3-12b-it:
        aliases: ["g3-12b", "g3m"]
        max-tokens: 2048
        max-input-chars: 392000
      gemma-3-4b-it:
        aliases: ["g3-4b", "g3s"]
        max-input-chars: 392000
      # Gemma 3n (모바일/온디바이스 최적화 모델)
      gemma-3n-e2b-it:
        aliases: ["g3-2b", "g3o"]
        max-input-chars: 131000
      # Gemma 3 초경량 모델
      gemma-3-1b-it:
        aliases: ["g3-1b", "g3n"]
        max-input-chars: 98000
  z-ai:
    base-url: https://api.z.ai/api/coding/paas/v4
    api-key:
    api-key-env: ZAI_API_KEY_MODS
    models:
      glm-4.7:
        aliases: ["glm-4.7","glm"]
        max-input-chars: 200000
```
