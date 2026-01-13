---
---
title: "Docker에서 Podman으로 — 이유와 마이그레이션 가이드"
date: 2026-01-13T08:00:00+09:00
lastmod: 2026-01-13T08:00:00+09:00
author: "Crong"
categories: ["Tech"]
tags: ["docker","podman","container","devops"]
showToc: true
TocOpen: true
draft: false
---

## 제목

Docker에서 Podman으로 — 이유와 마이그레이션 가이드

## 내용

**요약**

이 글은 Docker에서 Podman으로 전환하는 이유와 실무에서 바로 적용 가능한 마이그레이션 절차(명령어 매핑, 권한·네임스페이스 차이, 베스트 프랙티스)를 정리합니다. 컨테이너 런타임을 바꾸려는 엔지니어가 빠르게 참고할 수 있게 핵심 위주로 구성했습니다.

**왜 Podman인가?**

- 루트리스(rootless) 실행: Podman은 root 권한 없이 컨테이너를 실행할 수 있어 보안 경계를 줄입니다.
- 데몬리스(daemonless): 별도 데몬 없이 CLI가 직접 컨테이너를 관리하므로 데몬 장애 지점이 없습니다.
- Docker CLI 호환성: 많은 기본 명령어가 호환되며 `podman`에 `docker` 별칭을 걸어 이식성을 높일 수 있습니다.
- Open-source 생태계 및 OCI 호환: 표준 이미지 형식을 지키므로 레지스트리, 오케스트레이션 도구와의 연동이 수월합니다.

**핵심 차이 정리**

- 아키텍처: Docker는 데몬 기반(dockerd), Podman은 데몬리스(라이브러리 기반) 및 rootless 지원.
- 네임스페이스와 권한: rootless 모드에서 UID/GID 맵핑에 주의 필요. 포트 바인딩(특히 1024 이하)은 추가 권한 또는 포트 포워딩이 필요할 수 있음.
- Compose 지원: `docker-compose`는 바로 호환되지 않을 수 있으나 `podman-compose` 또는 `docker-compose`(새 버전)로 대응 가능.
- 시스템 서비스: 시스템 서비스로 컨테이너를 관리하려면 `podman generate systemd`로 unit 파일을 생성 가능.

**즉시 사용 가능한 명령어 매핑**

- 이미지 풀: `docker pull image` → `podman pull image`
- 컨테이너 실행: `docker run -d --name app image` → `podman run -d --name app image`
- 백그라운드/로그 확인: `docker logs` → `podman logs`
- 이미지 목록: `docker images` → `podman images`
- 컨테이너 목록: `docker ps` → `podman ps`
- 빌드: Dockerfile 빌드 `docker build -t name .` → `podman build -t name .`

팁: `/usr/bin/docker`를 `podman`으로 심볼릭 링크하거나 별칭(alias)을 걸어 기존 스크립트를 최소 수정으로 유지할 수 있습니다.

**마이그레이션 체크리스트(실무 절차)**

1. 환경 평가
   - 현재 Docker 사용 패턴(로컬 개발, CI, 프로덕션 서비스)을 파악.
   - `docker-compose` 사용 여부, 포트·볼륨 마운트, 사용자 네트워크 요구사항 점검.
2. 로컬 테스트
   - 개발용 워크스테이션에 Podman 설치 후 간단한 컨테이너로 동작 확인.
   - 루트리스 모드와 루트 모드에서 각각 테스트해 권한 이슈 확인.
3. 이미지 호환성 검증
   - 기존 이미지로 `podman run` 실행, 환경변수·볼륨·네트워크 동작 확인.
4. Compose/멀티 컨테이너
   - `docker-compose.yml`을 `podman-compose`로 시도하거나 `podman play kube`로 변환 가능.
5. 시스템 통합
   - CI/CD 파이프라인에서 `podman` 빌드/테스트 단계로 교체.
   - 운영서버에서는 `podman generate systemd --name <container>`로 systemd unit 생성 후 서비스화.
6. 모니터링·로깅
   - 기존 로그 수집 파이프라인(Fluentd/Promtail 등)과 연동되는지 확인.
7. 롤백 계획
   - 문제 발생 시 Docker로 빠르게 되돌릴 수 있는 절차(이미지 보존, Compose 파일 원본 유지) 마련.

**자주 마주치는 문제와 해결법**

- 포트 바인딩 실패(특히 80/443): 루트리스 환경은 특권 포트 바인딩이 제한됩니다. 해결책: 인증된 포트 포워딩, `setcap`으로 바이너리 권한 조정 또는 systemd의 포트 리디렉션 사용.
- 권한 문제(볼륨 마운트): 루트리스 UID 매핑으로 인해 파일 소유권이 달라질 수 있음. 해결책: 적절한 UID 매핑 설정 또는 호스트 권한 조정.
- Compose 비호환: `podman-compose`를 사용하거나 컨테이너를 개별적으로 관리하면서 `podman generate kube`로 Kubernetes manifest 생성 후 `podman play kube`로 기동 가능.

**예시: systemd 유닛 생성**

- 컨테이너를 서비스로 만들려면:

```sh
podman generate systemd --name myapp --files
sudo mv container-myapp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now container-myapp.service
```

**결론 및 권장 접근법**

- 소규모나 데스크톱 환경: 빠르게 전환해 보안(루트리스) 이점을 누리기 좋음.
- 프로덕션 환경: 단계적 전환 권장 — 로컬·스테이징에서 충분히 검증한 뒤 CI와 운영에 적용.
- 자동화: 기존 스크립트와 CI를 `podman`으로 교체하되, `podman generate systemd`와 같은 도구를 이용해 운영 자동화를 준비하세요.

원하시면 이 초안을 바탕으로 다음 중 하나를 추가로 진행하겠습니다:

- `podman` 설치 및 예제 스크립트 추가
- `docker-compose.yml` → `podman-compose` 변환 예시
- 시스템 서비스(unit) 심화 가이드

