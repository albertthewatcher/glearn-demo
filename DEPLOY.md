# GitHub Pages 배포 가이드

## 자동 배포 (권장)

GitHub Actions 워크플로우가 이미 설정되어 있습니다. 다음 단계를 따르세요:

### 1. GitHub에 푸시

터미널에서 다음 명령어를 실행하세요:

```bash
cd /Users/albert/Dev/glearn-demo/glearn
git push origin main
```

인증 문제가 발생하면:
- GitHub Personal Access Token 사용: `git remote set-url origin https://YOUR_TOKEN@github.com/albertthewatcher/glearn.git`
- 또는 SSH 사용: `git remote set-url origin git@github.com:albertthewatcher/glearn.git`

### 2. GitHub Pages 활성화

1. GitHub 리포지토리로 이동: https://github.com/albertthewatcher/glearn
2. Settings > Pages 메뉴로 이동
3. Source를 "GitHub Actions"로 선택
4. 저장

### 3. 배포 확인

- Actions 탭에서 워크플로우 실행 상태 확인
- 완료되면 Settings > Pages에서 배포 URL 확인
- 일반적으로: `https://albertthewatcher.github.io/glearn/`

## 수동 배포

자동 배포가 작동하지 않는 경우:

```bash
cd /Users/albert/Dev/glearn-demo/glearn
flutter build web --release

# gh-pages 브랜치에 배포
git checkout --orphan gh-pages
git rm -rf .
cp -r build/web/* .
git add .
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages -f
git checkout main
```

## 중요 사항

- API 키는 `.gitignore`에 포함되어 있어 GitHub에 올라가지 않습니다
- 프로덕션 환경에서는 환경 변수나 안전한 방식으로 API 키를 관리해야 합니다
- GitHub Pages는 정적 호스팅이므로 서버 사이드 로직이 필요하면 다른 플랫폼을 고려하세요

