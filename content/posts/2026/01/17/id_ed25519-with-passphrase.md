---
title: "id_ed25519 와 passphrase 로 시작하는 보안강호하"
date: 2026-01-17T17:15:47+07:00
lastmod: 2026-01-17T17:15:47+07:00
author: "Crong"
categories: ["DevOps"]
tags: ["SSH", "Security", "Network"]
showToc: true
TocOpen: true
---

## 제목

id_ed25519 와 passphrase 로 시작하는 보안 강호화

## 내용

이때 까지는 id_rsa 에 passphrase 없이 사용을 했는데, 요즘은 보안이 중요한 시대니깐 나도 보안을 한단계 레벨을 올려야 겠다.
id_ed25519 를 사용하고 passphrase 를 등록해서 써보자, 불편하겠지 라고 생각했는데 결론은 사용자 OS 의 Client 장비에서 부팅후 1번만 입력 하면 된다.

### Linux

ssh-agent 와 keychain 을 이용한 관리

```~/.zshrc
eval $(keychain --eval id_rsa id_ed25519)
```

```~/.ssh/config
Host *
    ForwardAgent yes         # 내가 클라이언트일 때 에이전트를 넘겨줌
    AddKeysToAgent yes       # 키 사용 시 로컬 에이전트에 등록
    IdentityFile ~/.ssh/id_ed25519
```

### macOS

자체 암호화 앱 과 연동 해서 관리

```~/.ssh/config
Host *
    ForwardAgent yes         # 인증 정보 전달 활성화
    AddKeysToAgent yes       # 키 사용 시 에이전트에 자동 등록
    UseKeychain yes          # [macOS 전용] 패스프레이즈를 키체인에 저장
    IdentityFile ~/.ssh/id_ed25519
```

### 1. Single Jump Host

기존에 편하게 사용한 Jump Host 방식은 Single 이였는데 이때는 아무생각이 없었다.

```mermaid
graph LR
    A[Local] -->|SSH| B[Jump Host]
    B -->|SSH| C[Target Server]
```

### 2. Multi Jump Host (Cascaded)

이번에 passphase 를 도입 하면 jump2 에서 하면 id_ed25519 키가 있어야 하나?

```mermaid
graph LR
    A[Local] -->|SSH| B[Jump1]
    B -->|SSH| C[Jump2]
    C -->|SSH| D[Target Server]
```

그럼 passphase 도 중간에 입력은 이런 생각이들어서 처음에 Jump2 에 ssh-agent 와 keycahin 을 올렸는데.
그럴 필요가 없었음 ssh 의 옵션을 넣어주면 Local 에서 부터 등록된 값을 가지고 계속 이동.

- ForwardAgent yes: 내가 클라이언트일 때 에이전트를 넘겨줌
- AddKeysToAgent yes: 키 사용 시 로컬 에이전트에 등록
