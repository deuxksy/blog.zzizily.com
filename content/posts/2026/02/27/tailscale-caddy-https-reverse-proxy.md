---
title: "Tailscale + Caddy로 HTTPS 리버스 프록시 구성하기"
date: 2026-02-26T01:38:51+07:00
lastmod: 2026-02-26T01:38:51+07:00
author: "Crong"
categories: ["DevOps", "Container"]
tags: ["Tailscale", "Caddy", "Podman", "Reverse-Proxy", "HTTPS"]
showToc: true
TocOpen: true
draft: false
---

## 제목

Tailscale + Caddy로 HTTPS 리버스 프록시 구성하기

## 개용

내부 네트워크의 레거시 서비스를 안전하게 외부에서 접근해야 할 때가 많습니다. 일반적으로는 VPN을 통해 직접 접근하거나, 공개 IP와 도메인을 할당받아 Nginx/Traefik 같은 리버스 프록시를 구성합니다. 하지만 이 방식은 방화벽 규칙 관리, SSL 인증서 갱신, 보안 노출 등 여러 가지 복잡성을 수반합니다.

[Tailscale Serve](https://tailscale.com/kb/1085/magicdns/#tls-certificates)와 Caddy를 조합하면 이 문제를 매우 간단하게 해결할 수 있습니다. Tailscale이 HTTPS 종료(Termination)를 담당하고, Caddy가 경로 기반 라우팅을 처리하는 아키텍처입니다.

> **⚠️ 제약 사항:** 이 구성은 Tailscale Tailnet 내부에서만 접근 가능합니다. 인터넷 공개 접속이 필요한 경우 추가 구성이 필요합니다.

## 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│  사용자 (Tailscale 네트워크에 접속된 클라이언트)             │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS (443)
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  Tailscale 사이드카 컨테이너 (heritage)                      │
│  - HTTPS 인증서 자동 발급 및 갱신                            │
│  - HTTPS 종료 처리                                           │
│  - localhost:9091로 프록시                                   │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP (9091)
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  Caddy 컨테이너 (caddy)                                      │
│  - 경로 기반 라우팅 (/rutorrent, /jellyfin 등)               │
│  - 정적 파일 서빙 (/srv)                                     │
│  - Gzip 압축, 보안 헤더 추가                                  │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ↓               ↓               ↓
   정적 파일      rutorrent:8080   jellyfin:8096
   (/srv)        whisparr:6969     (추후 확장)
```

**버전 정보:**

| 도구 | 버전 | 상태 |
|------|------|------|
| Tailscale | v1.86.2 | ✅ 현재 버전 |
| Caddy | v2.11.1 | ✅ 현재 버전 |
| Podman | 5.7.1 | 권장 버전 |

## 전제 조건

다음 항목들이 사전에 구성되어 있어야 합니다.

| 항목 | 설명 | 확인 방법 |
|------|------|----------|
| Tailscale 계정 | Tailnet이 구성되어 있어야 함 | https://login.tailscale.com/admin |
| HTTPS 활성화 | DNS 탭에서 HTTPS 인증서 활성화 필요 | Admin Console → DNS → HTTPS |
| AuthKey | 컨테이너 인증용 키 필요 | Settings → Keys → Generate Auth Key |
| Podman 설치 | 컨테이너 런타임 필요 | `podman --version` |

### Tailscale HTTPS 활성화 절차

Tailscale Admin Console에서 다음 단계를 수행하세요:

1. **DNS 탭 이동**
   - `https://login.tailscale.com/admin/dns`

2. **HTTPS 활성화**
   - "Enable HTTPS" 체크박스 선택
   - Tailnet 호스트네임이 `your-hostname.tailnet-name.ts.net` 형식으로 자동 할당됨

3. **AuthKey 생성**
   - `https://login.tailscale.com/admin/settings/keys`
   - **Reusable** 옵션 선택 (컨테이너 재시작에 대비)
   - 키를 복사하여 `.env` 파일에 저장

> **⚠️ 주의:** AuthKey는 노출되지 않도록 주의하세요. `.env` 파일은 `.gitignore`에 추가되어야 합니다.

## 구현 방법

### 1. 프로젝트 구조

```text
08-ts-heritage/
├── .env.example          # 환경변수 템플릿
├── .gitignore
├── compose.yaml          # Podman Compose 설정
├── config/
│   ├── Caddyfile         # Caddy 리버스 프록시 설정
│   └── serve-config.json # Tailscale Serve 설정
└── site/
    └── index.html        # 검증용 정적 파일
```

### 2. Compose 설정 (compose.yaml)

```blog.zzizily.com/content/posts/2026/02/27/tailscale-caddy-https-reverse-proxy.md
services:
  heritage:
    image: tailscale/tailscale:latest
    container_name: heritage
    hostname: heritage
    environment:
      - TS_AUTHKEY=${TS_AUTHKEY}
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=false  # rootless 모드가 아닌 경우
      - TS_SERVE_CONFIG=/config/serve-config.json
      - TS_CERT_DOMAIN=${TS_CERT_DOMAIN}
    volumes:
      - ./state:/var/lib/tailscale
      - ./config:/config
    devices:
      - /dev/net/tun:/dev/net/tun  # TUN 디바이스 필요
    cap_add:
      - net_admin  # 네트워크 관리 권한
    restart: unless-stopped

  caddy:
    image: caddy:latest
    container_name: caddy
    network_mode: service:heritage  # Tailscale 네트워크 공유
    depends_on:
      - heritage
    volumes:
      - ./config/Caddyfile:/etc/caddy/Caddyfile:ro
      - ./site:/srv:ro
      - ./caddy-data:/data
      - ./caddy-config:/config
    restart: unless-stopped
```

**핵심 포인트:**
- `TS_USERSPACE=false`: rootless Podman이 아닌 경우 필요
- `network_mode: service:heritage`: Caddy가 Tailscale 네트워크를 직접 사용
- `devices: /dev/net/tun`: TUN 디바이스 마운트 필수
- `cap_add: net_admin`: 네트워크 관리 권한 필요

### 3. Caddy 설정 (config/Caddyfile)

```blog.zzizily.com/content/posts/2026/02/27/tailscale-caddy-https-reverse-proxy.md
# Caddy 리버스 프록시 설정
# 현재 기본 정적 파일 서버로 동작
# 추후 rutorrent, whisparr, jellyfin 등의 경로를 추가하여 확장 가능

:9091 {
    root * /srv
    file_server

    encode gzip

    log {
        output file /var/log/caddy/access.log
    }

    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        Referrer-Policy no-referrer
    }

    # 추후 다중 서비스 설정 예시:
    # handle_path /rutorrent* {
    #     reverse_proxy rutorrent:8080
    # }
    # handle_path /whisparr* {
    #     reverse_proxy whisparr:6969
    # }
    # handle_path /jellyfin* {
    #     reverse_proxy jellyfin:8096
    # }
}
```

**설명:**
- `:9091`: localhost의 9091 포트에서 리슨
- `file_server`: 정적 파일 서빙
- `encode gzip`: 응답 압축
- `header`: 보안 관련 HTTP 헤더 추가

### 4. Tailscale Serve 설정 (config/serve-config.json)

```blog.zzizily.com/content/posts/2026/02/27/tailscale-caddy-https-reverse-proxy.md
{
  "TCP": {
    "443": {
      "HTTPS": true
    }
  },
  "Web": {
    "${TS_CERT_DOMAIN}:443": {
      "Handlers": {
        "/": {
          "Proxy": "http://127.0.0.1:9091"
        }
      }
    }
  },
  "AllowFunnel": {
    "${TS_CERT_DOMAIN}:443": false
  }
}
```

**설명:**
- `TCP/443/HTTPS`: 포트 443에서 HTTPS 종료
- `Web`: 모든 경로(`"/"`)를 `http://127.0.0.1:9091`로 프록시
- `AllowFunnel`: Funnel 기능 비활성화 (Tailnet 내부 접속만 허용)

### 5. 환경변수 설정 (.env)

```bash
# .env.example에서 복사 후 값 수정
TS_AUTHKEY=tskey-auth-<YOUR_AUTH_KEY_HERE>
TS_CERT_DOMAIN=heritage.bun-bull.ts.net  # 실제 Tailnet 호스트네임
```

## 실행 및 검증

### 1. 컨테이너 시작

```bash
# 프로젝트 디렉토리 이동
cd 08-ts-heritage

# 환경변수 파일 생성
cp .env.example .env

# .env 파일 편집 (TS_AUTHKEY, TS_CERT_DOMAIN 값 설정)
vim .env

# 컨테이너 시작
podman compose up -d

# 상태 확인
podman compose ps
```

### 2. 로그 확인

```bash
# Tailscale 로그
podman compose logs -f heritage

# Caddy 로그
podman compose logs -f caddy
```

### 3. 접속 검증

| 검증 항목 | 기대 동작 | 확인 방법 |
|----------|----------|----------|
| Tailscale 연결 | 로그에 "Connected to" 메시지 | `podman compose logs heritage` |
| HTTPS 인증서 | 인증서가 자동 발급됨 | Admin Console의 DNS 탭 확인 |
| 웹 접속 | `https://heritage.bun-bull.ts.net` 접속 가능 | 브라우저에서 접속 |

## 다중 서비스 확장

단일 도메인에서 여러 서비스를 경로 기반으로 구분하여 접근할 수 있습니다.

### 1. Compose 파일에 서비스 추가

```blog.zzizily.com/content/posts/2026/02/27/tailscale-caddy-https-reverse-proxy.md
services:
  heritage:  # 기존 Tailscale 컨테이너
    # ... 기존 설정 ...

  caddy:  # 기존 Caddy 컨테이너
    # ... 기존 설정 ...
    networks:
      - backend  # 추가 서비스와 통신용 네트워크

  rutorrent:
    image: linuxserver/rutorrent:latest
    container_name: rutorrent
    networks:
      - backend
    # ... rutorrent 설정 ...

  jellyfin:
    image: linuxserver/jellyfin:latest
    container_name: jellyfin
    networks:
      - backend
    # ... jellyfin 설정 ...

networks:
  backend:
    driver: bridge
```

### 2. Caddyfile 경로 라우팅 설정

```blog.zzizily.com/content/posts/2026/02/27/tailscale-caddy-https-reverse-proxy.md
:9091 {
    # /rutorrent 경로 → rutorrent:8080
    handle_path /rutorrent* {
        reverse_proxy rutorrent:8080
    }

    # /whisparr 경로 → whisparr:6969
    handle_path /whisparr* {
        reverse_proxy whisparr:6969
    }

    # /jellyfin 경로 → jellyfin:8096
    handle_path /jellyfin* {
        reverse_proxy jellyfin:8096
    }

    # 기본: 정적 파일
    root * /srv
    file_server
}
```

### 3. 접근 예시

| 서비스 | URL |
|--------|-----|
| 메인 페이지 | `https://heritage.bun-bull.ts.net` |
| rTorrent | `https://heritage.bun-bull.ts.net/rutorrent` |
| Jellyfin | `https://heritage.bun-bull.ts.net/jellyfin` |
| Whisparr | `https://heritage.bun-bull.ts.net/whisparr` |

## 트러블슈팅

### 1. TUN 디바이스 관련 오류

**증상:**
```
Error: failed to open /dev/net/tun: no such file or directory
```

**해결 방법:**
```bash
# TUN 모듈 로드 확인
ls -l /dev/net/tun

# 없을 경우 모듈 로드 (root 권한 필요)
sudo modprobe tun

# 영구 적용 (시스템마다 다름)
echo "tun" | sudo tee /etc/modules-load.d/tun.conf
```

### 2. net_admin 권한 관련 오류

**증상:**
```
Error: could not bring up Tailscale: failed to start: exit status 1
```

**해결 방법:**
- `cap_add: net_admin`이 compose.yaml에 있는지 확인
- rootless Podman 사용 시 권한 문제 발생 가능

### 3. HTTPS 인증서 발급 실패

**증상:**
```
TLS handshake error: x509: certificate signed by unknown authority
```

**해결 방법:**
1. Admin Console에서 HTTPS가 활성화되어 있는지 확인
2. `TS_CERT_DOMAIN` 값이 정확한지 확인
3. Tailscale 로그에서 인증서 발급 관련 에러 확인

### 4. 접속 불가

**진단 체크리스트:**

| 항목 | 확인 명령어 | 기대 결과 |
|------|-----------|----------|
| 컨테이너 상태 | `podman compose ps` | Up 상태 |
| 네트워크 | `podman network ls` | 백엔드 네트워크 존재 |
| 포트 바인딩 | `podman port caddy` | (없음 - Tailscale 네트워크 사용) |
| Tailscale 로그 | `podman logs heritage` | "Connected to" 메시지 |
| Caddy 로그 | `podman logs caddy` | "server running" 메시지 |

## 결론

Tailscale + Caddy 조합은 다음과 같은 장점을 제공합니다:

1. **간단한 HTTPS 구성**: 별도의 SSL 인증서 관리 불필요
2. **안전한 네트워크**: Tailnet 내부에서만 접근 가능
3. **유연한 라우팅**: 경로 기반 다중 서비스 지원
4. **간편한 확장**: Compose 파일에 서비스만 추가하면 됨

특히 방화벽 규칙, 공인 IP, DNS 레코드, 인증서 갱신 같은 복잡성에서 해방되는 것이 큰 장점입니다.

다음 단계로 고려할 수 있는 확장:
- OIDC 인증 통합
- 접근 로그 분석
- 서비스 모니터링 (Prometheus + Grafana)
- 백업 구성

> **참고 자료:**
> - [Tailscale Serve 문서](https://tailscale.com/kb/1085/magicdns/#tls-certificates)
> - [Caddy 문서](https://caddyserver.com/docs/)
> - [GitHub 레포지토리](https://github.com/deuxksy/podman-guide-code-examples/tree/main/08-ts-heritage)
