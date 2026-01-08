# Security / Secrets Handling

요약: 민감 정보(비밀번호, API 키, 개인키 등)는 리포지토리에 절대 커밋하지 마세요.

권장 정책

- 로컬에서 환경변수 사용: `.env` 파일은 `.gitignore`에 포함되어야 하며 실제 값은 로컬에서만 보관하세요. 샘플값은 `.env.example`에 두세요.
- 개인 키(`*.key`, `*.pem`), 인증서(`*.crt`), 시크릿 파일은 절대 커밋 금지.
- 커밋 전에 간단한 시크릿 체크(pre-commit)를 도입하세요.

간단한 pre-commit 훅 설치

로컬 개발자용으로는 다음을 실행하면 됩니다:

```bash
cp scripts/pre-commit-check.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

추가 권장 도구

- `pre-commit` 프레임워크와 `detect-secrets` 또는 `git-secrets` 플러그인 사용 권장
- CI(예: GitHub Actions)에서 시크릿 스캐닝(TruffleHog, GitLeaks 등) 실행 권장

유출이 의심되는 시크릿 발견 시 대처

1. 즉시 관련 키/시크릿을 폐기하고 교체하세요.
2. 교체된 값은 환경변수/시크릿 매니저에 저장하세요.
3. 리포지토리 역사에서 시크릿을 제거하려면 `git filter-repo` 또는 `bfg` 사용 후 강제 푸시가 필요합니다(주의: 기록 변경은 협업에 영향).

문의: 자동 설치(예: `pre-commit` 설정, CI 워크플로 추가)를 원하시면 제가 초안을 만들어 드리겠습니다.
