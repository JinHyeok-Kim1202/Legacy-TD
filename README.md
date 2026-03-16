# Legacy TD

Legacy TD는 **Godot 4** 기반의 데이터 중심 타워 디펜스 프로젝트입니다.  
런타임 클라이언트는 `game-client/godot`에 있고, 게임 규칙과 콘텐츠 데이터는 `game-shared`에 분리되어 있습니다.

## 프로젝트 개요
- 장르: 그리드 기반 타워 디펜스 / 조합 성장형 디펜스
- Engine: **Godot 4.2.2**
- Runtime: `game-client/godot`
- 공유 게임 데이터: `game-shared/data`
- 데이터 검증: `npm run validate:data`

## 개발 환경
현재 작업은 다음 환경 기준으로 진행되었습니다.

- OS: **Windows**
- Shell: **PowerShell**
- Engine: **Godot 4.2.2 Stable**
- Runtime scripting: **GDScript**
- Data / Tooling: **Node.js / npm**

## 현재 구현 상태
- 전\ccb4 보드는 **7x7**
- 아군 배치 영역은 내부 **5x5**
- 적은 외곽 경로를 따라 순환 이동
- 난이도 선택 후 라운드 자동 진행
- 첫 라운드 전 대기 시간: **30초**
- 기본 라운드 길이: **60초**
- 라운드 적 스폰 규칙
  - 일반 라운드: 일반 적 40마리
  - 보스 라운드: 일반 적 40마리 + 보스 1마리
- Storage / Board / Story 영역 간 유닛 이동 지원
- Merge(조합) 시스템 지원
- Story Boss 3슬롯 / 15스테이지 진행 구조 지원
- Mission Boss 해금 및 소환 시스템 지원
- 유닛 / 적 표현은 billboard 기반 프레젠테이션 사용

## 디렉터리 구조
- `docs/`
  - 설계 문서, 세션 인수인계 문서, 작업 메모
- `game-client/`
  - 런타임 클라이언트 코드
  - 현재 Godot 프로젝트는 `game-client/godot`
- `game-shared/`
  - 게임 규칙, 유닛 데이터, 레시피, 보드 / 웨이브 / 보상 데이터
- `game-tools/`
  - 검증기, 생성기, 데이터 파이프라인 스크립트

## 중요한 파일
- Godot 프로젝트 루트
  - `game-client/godot/project.godot`
- 게임 상태 / 진행 관리
  - `game-client/godot/scripts/autoload/game_state.gd`
- HUD / UI
  - `game-client/godot/scripts/ui/main_hud.gd`
- 메인 씬 런타임
  - `game-client/godot/scripts/main.gd`
- 공유 유닛 데이터
  - `game-shared/data/units/units.json`
- 공유 레시피 데이터
  - `game-shared/data/progression/recipes.json`
- 세션 인수인계 문서
  - `docs/session-handoff.md`

## 실행 / 검증
### 데이터 검증
```powershell
cd D:\work\oh-my\legacy-td
npm run validate:data
```

### Godot 프로젝트 열기
Godot 4에서 아래 프로젝트를 열면 됩니다.

```text
game-client/godot/project.godot
```

## Git 운영 목적
이 저장소는 단순 백업이 아니라, **다음 세션이 이전 세션의 맥락을 빠르게 이어받을 수 있도록** 관리합니다.

그래서 커밋은 다음 역할을 해야 합니다.
- 무엇을 바꿨는지
- 왜 바꿨는지
- 어떤 시스템에 영향이 있는지
- 무엇을 검증했는지
- 남은 리스크가 무엇인지

## 세션 종료 전 커밋 메시지 규칙
세션을 마치기 전 커밋 메시지는 가능한 한 **상세한 handoff 역할**을 해야 합니다.

권장 형식:
- 1줄 제목: 이번 세션의 핵심 요약
- 본문 bullet:
  - 변경 시스템
  - 주요 파일
  - 데이터 / 런타임 / UI 변경점
  - 검증 결과
  - 남은 이슈 / 다음 작업 포인트

## 다음 세션 시작 포인트
다음 세션은 아래 순서로 보면 맥락을 빠르게 이어받을 수 있습니다.

1. 최신 커밋 메시지
2. `docs/session-handoff.md`
3. `README.md`
4. 필요하면 `game-client/godot/scripts/autoload/game_state.gd`
5. 필요하면 `game-client/godot/scripts/ui/main_hud.gd`

## 주의 사항
- 게임 규칙 / 데이터는 가능한 한 `game-shared`에 유지
- Godot 전용 프레젠테이션 / 런타임은 `game-client/godot`에 유지
- `.godot/`, `debug_logs/`, 로컬 캐시 / IDE 설정은 커밋하지 않음
- 세이브 / 설정 포맷은 함부로 깨지지 않도록 주의
