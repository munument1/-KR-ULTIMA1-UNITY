# Ultima I Unity 한국어 패치

Ultima I Unity의 비공식 한국어 패치입니다.

현재 최신 버전은 **v0.5**이며, **2026-09-13 Ultima I Unity 빌드**를 대상으로 합니다.

## 현재 적용 범위

- 게임 UI 및 주요 시스템 문구 한국어화
- 캐릭터 생성 / HUD / 전투 / 던전 / 퀘스트 문구 한국어화
- 도시·성·던전·상점·아이템 데이터 한국어화
- Apple II 성별 선택 / 캐릭터 등록부 / 신규 UI 문구 한국어화
- 최신 컨트롤러 및 `Mondain Fight` 관련 문구 한국어화
- **Galmuri11** 기반 한글 폰트 적용
- HUD의 `Hits`를 `체력`으로 번역 유지

## 설치

1. GitHub Releases에서 `Ultima1Unity_Korean_v0.5_DeltaPatch.zip`을 받습니다.
2. 압축 안의 파일을 `Ultima I Unity.exe`가 있는 게임 폴더에 풉니다.
3. `Install_Korean_Patch.bat`를 실행합니다.
4. 설치기가 원본 파일의 SHA-256을 확인한 뒤 자동 백업하고 패치를 적용합니다.

지원하는 2026-09-13 원본 해시는 다음과 같습니다.

- `Ultima.Runtime.dll`: `d08f5bb3e02c0ecdab37d4c99200984a8a1979d0be6c5a835f9e2b4449fa6852`
- `resources.assets`: `472e002b9fd4e1479614a54ea64e70cebfe5cb5e0f3b67aa1368abdc259c3f49`

패치는 원본 게임 파일 전체를 포함하지 않고 **변경 데이터만 포함하는 델타 패치**입니다. 지원하는 게임 빌드와 파일 해시가 다르면 설치가 중단됩니다.

v0.5 원본 백업은 각 파일 옆에 `.u1k-original-v0.5` 확장자로 생성됩니다.

## 현재 알려진 제한

도시 화면의 `TRANSPORT`, `MAGIC`, `PUB`, `ARMOUR`, `WEAP`, `FOOD` 같은 **상점 간판은 그래픽에 포함된 문자열이라 현재 영문으로 남아 있습니다.**

최신 업데이트에서 추가된 일부 고유명사와 음악 세트 이름은 원문을 유지합니다. 일부 문장의 오역, 잘림, 줄바꿈 문제가 남아 있을 수 있습니다.

## 폰트

한글 폰트는 [Galmuri](https://github.com/quiple/galmuri)의 **Galmuri11**을 사용합니다.

Galmuri는 SIL Open Font License 1.1에 따라 배포됩니다. 자세한 내용은 `LICENSE_Galmuri.txt`를 확인하세요.

## 버전

### v0.5

- 2026-09-13 최신 게임 빌드 대응
- 기존 한국어 문자열 1,332개 최신 DLL 구조로 재이식
- 신규 성별 선택 / Apple II 캐릭터 UI / 컨트롤러 / 옵션 문구 보강
- 최신 DLL의 폰트 참조 209곳을 Galmuri11 경로로 통일
- 최신 `resources.assets`에 Galmuri11 재이식

### v0.4

- 이전 업데이트 빌드 대응
- v0.3 번역 이식 및 추가 UI 문구 보강

### v0.3

- 한국어 번역 및 Galmuri11 폰트 적용
- 메인 메뉴 레이아웃용 문구 축약
- `Hits:` 오역 수정: `명중:` → `체력:`
- 원본 파일을 포함하지 않는 자동 델타 패처 제공

## 주의

이 저장소는 비공식 팬 번역 프로젝트이며 원본 게임은 별도로 필요합니다.
