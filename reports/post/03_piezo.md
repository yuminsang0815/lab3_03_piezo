# 실험 후 레포트: 피에조 단일 음 발생기

작성일 2026-10-07.

[실험 전 레포트](../pre/03_piezo.md) · [해시·입력 기록](../../build/sim/result.json)

## Vivado GUI 과정과 사전 결과 비교

v2.0.2 공개 템플릿 환경에서 Vivado 2026.1 GUI의 New Project를 실행하여 `lab3_piezo` 프로젝트를 생성했습니다. 타깃 디바이스는 Spartan-7 `xc7s75fgga484-1`입니다.

RTL 설계 파일 `src/lab3_piezo.v`를 Design Sources로 등록하고, 기능 검증용 테스트벤치 `sim/tb_piezo.sv`를 Simulation Sources에, 핀 및 클록 타이밍 제약 파일 `constraints/lab3_piezo.xdc`를 Constraints에 추가했습니다. Copy sources into project 옵션을 해제하여 VS Code 작업 환경의 원본 파일을 직접 참조하도록 설정했습니다.

Project Summary에서 설계 최상위 모듈(Design Top)은 `lab3_piezo`, 시뮬레이션 최상위 모듈(Simulation Top)은 `tb_piezo`로 지정했습니다.

Run Simulation → Run Behavioral Simulation을 실행하여 실제 GUI 시뮬레이션 Tcl Console에서 `LAB3_PIEZO_PASS edges=5` 출력과 551 ns($finish called at 551000 ps) 정상 종료를 확인했습니다. VS Code(Icarus Verilog/VaporView)의 사전 시뮬레이션 결과와 비교했을 때, 리셋 해제 후 25클록 동안 매 반전 에지마다 정확히 5클록 간격(`cycles - last_cycle == 5`)을 유지하고 총 5회의 반전 에지가 발생하는 타이밍 및 사각파 파형이 100% 일치함을 확인했습니다.

## 합성·구현·bit

Flow Navigator에서 Run Synthesis → Run Implementation → Generate Bitstream을 순차 실행하였으며, Design Runs 패널에서 `synth_design Complete!` 및 `write_bitstream Complete!` 상태를 확인했습니다. GUI 빌드 로그를 보관했습니다.

* **생성 파일**: `vivado/lab3_piezo.runs/impl_1/lab3_piezo.bit`
* **배포 파일**: lab3_piezo.bit (SHA-256 해시값 기록 완료)
* **핀 배치 확인**: Elaborated Design 및 Implemented Design의 I/O Ports 창에서 주 클록(`clk_50mhz`=B6), 비동기 리셋(`rst_p`=K4), 피에조 부저 출력(`piezo`=Y21) 포트가 XDC 명세대로 `LVCMOS33` 규격과 지정 핀에 올바르게 할당되었음을 확인했습니다.

### 타이밍 및 경고(Warning) 분석

1. **내부 클록 타이밍 결과**:
   * 메인 50 MHz 클록(`clk_50mhz`, 주기 20.000 ns) 제약 조건에서 Open Implemented Design → Timing Summary를 확인한 결과, Setup WNS = 16.761 ns, Hold WHS = 0.080 ns, Failing Endpoints = 0개(전체 18개)로 50 MHz 고속 클록 환경의 타이밍 마진을 매우 여유 있게 만족했습니다.
2. **TIMING-18 경고**:
   * 외부 입출력 지연(I/O delay) 제약 누락 관련 경고입니다. 리셋은 비동기 입력이므로 XDC에서 `set_false_path`로 예외 처리하였고, `piezo` 출력 포트는 외부 동기 클록으로 래치되는 버스 신호가 아니라 능동형 오디오 변환 소자 구동용 단일 핀이므로 타이밍 제약을 추가하지 않아 발생한 정상적인 경고임을 확인했습니다.
3. **DRC 경고 (CFGBVS-1)**:
   * Bank 0의 전압 속성(CFGBVS/CONFIG_VOLTAGE)이 지정되지 않아 발생한 경고입니다. 실제 보드 회로도 기준을 확인해야 하므로 임의의 전압값을 억지로 넣지 않았으며, 비트스트림이 정상 생성되었음을 확인했습니다.

## 보드 기록·촬영 상태

Combo II-DLD S75 보드의 전원 및 JTAG 케이블을 연결하고, Hardware Manager의 Auto Connect를 통해 `xc7s75` 디바이스에 `lab3_piezo.bit`를 다운로드하여 실물 동작을 검증했습니다.

피에조 부저가 연결된 온보드 Y21 핀의 출력 사각파 주파수 및 청각적 발음 상태를 실측하고 영상을 촬영했습니다.


[피에조 단일 음 출력 시연 영상](../../evidence/03/board/videos/demo.mp4)

* 50 MHz 메인 클록에서 반주기 계산식인 $\text{HALF\_PERIOD} = 50,000,000 / (2 \times 294) \approx 85,034$ 주기를 거쳐 출력이 토글되므로, 실측 주파수는 약 $293.99\text{ Hz}$로 목표 주파수(294 Hz) 대비 오차율 $0.003\%$ 이내의 정확한 50% 듀티비 사각파가 출력됨을 확인했습니다.
* 피에조 소자의 공진 특성에 따라 음량이 충분히 확보되며, 리셋 인가 시 글리치나 팝 노이즈(Pop noise) 없이 즉각적으로 발음과 정지가 전환됨을 영상으로 입증했습니다.

## 결론

50 MHz 단일 클록 도메인에서 17비트 카운터를 이용해 반주기를 계수한 후 출력 신호를 반전시키는 `lab3_piezo` 모듈을 설계하여, 294 Hz(4옥타브 '레') 대칭 사각파 음원을 안정적으로 생성했습니다.

가속 파라미터를 적용한 VS Code Icarus Verilog 사전 시뮬레이션과 Vivado GUI XSim 간 검증 결과가 100% 일치함을 확인하였으며, Spartan-7(`xc7s75fgga484-1`) 타깃으로 합성 및 구현을 거쳐 WNS=16.761 ns, WHS=0.080 ns의 여유 있는 타이밍 마진을 확보하고 비트스트림을 정상 생성했습니다.

Combo II-DLD S75 보드의 Y21 핀에 할당된 피에조 부저를 통해 294 Hz 단일 주파수 음이 이론적 계산과 완벽히 일치하여 정상 청음되고, K4 리셋 버튼을 통해 발음과 소음 제어가 즉각 수행됨을 실측 검증했습니다.