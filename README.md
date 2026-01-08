# 새로운 기술은 언제나 환영이야! 👋 (blog.zzizily.com)

15년 차 DevOps 엔지니어 **Crong** 의 기술 블로그입니다. 

Java 와 DevOps 경험, 그리고 새로운 기술적 인사이트를 기록합니다.

## 🚀 Tech Stack

- **Framework**: [Hugo](https://gohugo.io/) (Extended version)
- **Theme**: [PaperMod](https://github.com/adityatelange/hugo-PaperMod)
- **Deployment**: [GitHub Pages](https://pages.github.com/) via GitHub Actions
- **Search Engine**: Fuse.js

## 🛠️ 로컬 개발 환경 설정

이 블로그는 SCSS 빌드를 위해 Hugo **Extended** 버전이 필요합니다.

### 1. Hugo 설치 (macOS 기준)
```bash
brew install hugo
```

### 2. 저장소 클론 및 서브모듈 초기화
테마가 Git 서브모듈로 관리되므로 `--recursive` 옵션이 필요합니다.
```bash
git clone --recursive https://github.com/zzizily/blog.zzizily.com.git
cd blog.zzizily.com
```

### 3. 로컬 서버 실행
```bash
hugo server -D
```
- `-D`: 드래프트(`draft: true`) 상태인 글도 포함하여 렌더링합니다.
- 서버 주소: `http://localhost:1313/`

## 📝 새 포스트 작성하기

아래 명령어를 사용하여 새로운 포스트를 생성할 수 있습니다.

```bash
hugo new posts/my-new-post.md
```

생성된 파일의 Front Matter에서 `draft: false`로 변경해야 실제 빌드 시 포함됩니다.

## 🚢 배포 (Deployment)

`main` 브랜치에 코드가 `push`되면 GitHub Actions가 자동으로 빌드 및 배포를 수행합니다.

- **Workflow**: `.github/workflows/deploy.yml`
- **Target**: [https://blog.zzizily.com/](https://blog.zzizily.com/)

## 📂 프로젝트 구조

- `content/posts/`: 블로그 포스트(Markdown) 파일 위치
- `content/static/`: 포스트에서 사용하는 이미지 등 정적 자산
- `layouts/`: 테마 설정을 덮어쓰기 위한 커스텀 레이아웃
- `hugo.yaml`: 사이트 전역 설정 및 메뉴 구성

---
© 2026 ZZiZiLY. Powered by Hugo & PaperMod.
