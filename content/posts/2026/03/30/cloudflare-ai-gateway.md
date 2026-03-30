---
title: "Cloudflare AI Gateway 사용 예제"
date: 2026-03-30T14:50:17+07:00
lastmod: 2026-03-30T14:50:17+07:00
author: "Crong"
categories: ["Tech"]
tags: ["Cloudflare", "AI", "Gateway", "API"]
showToc: true
TocOpen: true
---

## Cloudflare AI Gateway란?

Cloudflare AI Gateway는 여러 AI 제공자(OpenAI, Anthropic, Google AI Studio 등)의 API를 단일 엔드포인트로 통합 관리할 수 있는 프록시 서비스다. 사용량 모니터링, 캐싱, 속도 제한, 로깅 등의 기능을 제공한다.

## 사전 준비

다음 환경 변수들이 필요하다:

| 변수명 | 설명 |
| -------- | ------ |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare 계정 ID |
| `CLOUDFLARE_AI_GATEWAY_NAME` | AI Gateway 이름 |
| `CF_AIG_TOKEN` | Cloudflare AI Gateway 토큰 |

> **참고**: Cloudflare AI Gateway 대시보드에서 Provider를 등록하고 API 키를 미리 설정하면, CLI 요청 시 `Authorization`이나 `x-goog-api-key` 헤더를 별도로 추가하지 않아도 Cloudflare가 자동으로 인증을 처리한다.

### 예제 1: ZAI API (GLM-4.5-air)

ZAI의 GLM-4.5-air 모델을 사용하는 예제다. OpenAI 호환 엔드포인트(`/chat/completions`)를 사용한다.

```bash
curl https://gateway.ai.cloudflare.com/v1/${CLOUDFLARE_ACCOUNT_ID}/${CLOUDFLARE_AI_GATEWAY_NAME}/custom-zai/api/coding/paas/v4/chat/completions \
  -H "cf-aig-authorization: Bearer $CF_AIG_TOKEN" \
  -H "Authorization: Bearer $ZAI_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{ "model": "glm-4.5-air", "messages": [{"role": "user", "content": "Hello!"}] }'
```

- **URL 경로**: `/custom-zai/api/coding/paas/v4/chat/completions` - Custom 엔드포인트 설정
- **cf-aig-authorization**: Cloudflare AI Gateway 인증 헤더
- **Authorization**: 원본 AI 제공자(ZAI) 인증 (Cloudflare에 등록 시 생략 가능)

### 예제 2: Google AI Studio (Gemma 3 1B IT)

Google AI Studio의 Gemma 3 1B IT 모델을 사용하는 예제다. Google의 네이티브 API 형식을 사용한다.

```bash
curl -s "https://gateway.ai.cloudflare.com/v1/${CLOUDFLARE_ACCOUNT_ID}/${CLOUDFLARE_AI_GATEWAY_NAME}/google-ai-studio/v1beta/models/gemma-3-1b-it:generateContent" \
  -H "cf-aig-authorization: Bearer $CF_AIG_TOKEN" \
  -H "x-goog-api-key: $GEMMA_AI_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Hello!"}]}]}'
```

- **URL 경로**: `/google-ai-studio/v1beta/models/gemma-3-1b-it:generateContent`
- **x-goog-api-key**: Google AI Studio 인증 헤더 (Cloudflare에 등록 시 생략 가능)

### 주요 차이점

| 항목 | ZAI (OpenAI 호환) | Google AI Studio |
| ------ | ------------------- | ------------------ |
| 엔드포인트 | `/chat/completions` | `:generateContent` |
| 인증 헤더 | `Authorization: Bearer` | `x-goog-api-key` |
| 메시지 형식 | `messages` 배열 | `contents` 배열 |

### 참고 자료

- [Cloudflare AI Gateway 공식 문서](https://developers.cloudflare.com/ai-gateway/)
- [Non Standard Custom Provider 설정](https://developers.cloudflare.com/ai-gateway/configuration/custom-providers/#example-2-provider-with-a-non-standard-api-path)
- [Google AI Studio Provider 설정](https://developers.cloudflare.com/ai-gateway/usage/providers/google-ai-studio/)
