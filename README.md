# 🎵 MATLAB 기반 OFDM 음향 통신 시스템

* 고려대학교 전기전자공학부 24-2학기 '종합설계II' 과목에서 진행한 프로젝트입니다.
* MATLAB을 사용하여, 성인 귀에 들리지 않으면서도 일반 스피커, 마이크를 이용하는 비가청음파 통신으로 이미지와 텍스트를 전송하는 OFDM(Orthogonal Frequency Division Multiplexing) 통신 시스템의 송신단(Transmitter)과 수신단(Receiver)을 모두 구현하였습니다.

---

<br>

<details>
<summary><strong>👨‍💼 비전공자를 위한 프로젝트 설명 (클릭하여 펼치기)</strong></summary>

### 1. 프로젝트 소개
*   **목표**: 스피커와 마이크를 이용하여, 성인이 인지하기 어려운 소리 신호로 이미지를 전송하고, 수신된 이미지를 복원하여 그 안의 글자까지 인식하는 통신 시스템을 개발하였습니다.
*   **의의**: 통신 시스템의 전체 과정을 처음부터 끝까지 직접 설계하고 구현하며 얻은 **SW 개발 역량**과 **통신 및 신호 처리에 대한 이해도**를 보여드리고자 하였습니다.

### 2. 주요 기능
*   **그림판 & 실시간 전송**: MATLAB GUI로 만든 그림판에 직접 그림을 그리거나 글씨를 쓰면, '전송' 버튼 하나로 즉시 소리 신호로 변환되어 스피커로 재생됩니다.
*   **이미지 → 소리 변환**: 전송할 이미지를 분석하여 QPSK 변조 및 OFDM 기술을 통해 음향 신호(.WAV 파일)로 변환합니다.
*   **소리 → 이미지 복원**: 마이크로 녹음된 소리 신호를 분석하여, 통신 과정에서 발생한 각종 잡음과 왜곡을 보정하고 원본 이미지를 복원합니다.
*   **문자 인식 (OCR)**: 복원된 이미지 안에 글자가 있다면, Python의 `easyocr` 라이브러리를 연동하여 어떤 글자인지 자동으로 인식하고 화면에 표시해줍니다.
*   **저전력 대기 모드**: 평소에는 최소한의 기능만으로 신호를 기다리다가, 약속된 'Wake-up' 신호(19kHz 사인파)가 감지되면 전체 수신 시스템을 활성화하여 효율적으로 동작합니다.

### 3. 프로젝트를 통해 얻은 역량
*   **End-to-End 개발 경험**: 보이지 않는 문제를 해결하기 위해, 이미지 처리부터 변복조, 채널 코딩, 동기화 등 복잡한 통신 시스템의 전 과정을 직접 설계하고 MATLAB 코드로 구현하였습니다.
*   **기본기 보유 증명**: 단순히 라이브러리를 사용하는 것을 넘어, OFDM, 채널 등화, 필터 설계 등 통신 및 신호 처리의 핵심 이론을 실제 오디오 신호에 적용하며 전공 지식의 **응용 능력**을 보였습니다.
*   **융합적 사고**: MATLAB 환경에서 Python OCR 라이브러리를 연동하여 프로젝트의 기능을 확장시킨 경험을 통해, 주어진 환경에 얽매이지 않고 다양한 기술을 융합하여 문제를 해결하는 **개발 역량**을 갖추었습니다.

</details>

<br>

<details>
<summary><strong>👩‍💻 전공자를 위한 프로젝트 설명 (클릭하여 펼치기)</strong></summary>

### 1. 프로젝트 개요
본 프로젝트는 MATLAB을 이용하여 이미지 데이터를 OFDM(Orthogonal Frequency Division Multiplexing) 방식으로 변조하여 음향 채널(Acoustic Channel)을 통해 전송하고, 이를 수신하여 복조 및 복원하는 통신 시스템입니다. 송신단은 실시간 GUI 그림판을 통해 생성된 이미지를 전송하며, 수신단은 특정 주파수의 Wake-up Signal을 감지하여 동작하고, 복원된 이미지에 대해 Python `easyocr` 라이브러리를 연동한 OCR 기능을 수행합니다.

### 2. 사용 기술
*   **Platform**: `MATLAB R2023b`
*   **Language**: `MATLAB`
*   **Toolboxes**: `Signal Processing Toolbox`, `Communications Toolbox`, `Image Processing Toolbox`, `Audio Toolbox`
*   **External Integration**: `Python` (`easyocr` 라이브러리)
*   **Core Concepts**: `OFDM`, `QPSK`, `Channel Coding` (Repetition, Interleaving), `Channel Estimation & Equalization`, `Digital Filter Design`, `Acoustic Communication`

### 3. 시스템 아키텍처 및 처리 흐름

#### 📡 송신단 (Transmitter) 파이프라인
송신 과정은 `Tx_Genuine_main.m`의 GUI 이벤트로부터 시작되어 `Tx_main.m`에서 통합 관리됩니다.

1.  **Source & GUI (`Tx_Genuine_main.m`)**: MATLAB `uicontrol`과 `axes`로 구현된 그림판 GUI를 통해 사용자로부터 128x128 크기의 흑백 이미지를 입력받습니다. '전송' 버튼 클릭 시, 해당 이미지를 `IMG.PNG`로 저장하고 송신 절차를 시작합니다.
2.  **Image to Bitstream (`Tx_Step_1_...m`)**:
    *   저장된 이미지를 `imread`로 읽어와 이진(Binary) 데이터로 변환하고, 1차원 벡터로 직렬화(Flatten)합니다.
3.  **Channel Coding**:
    *   **Repetition Coding**: 오류 정정을 위해 각 비트를 설정된 횟수(e.g., 3회)만큼 반복합니다.
    *   **Interleaving**: `randperm` 함수를 이용해 비트 순서를 무작위로 섞어 연집 오류(Burst Error)에 대한 강인함을 확보합니다.
4.  **Modulation (`Tx_Step_2_...m`)**:
    *   `bit2int`와 `pskmod` 함수를 이용해 비트 스트림을 **QPSK (Quadrature Phase Shift Keying)** 심볼로 변조합니다.
5.  **OFDM Symbol Generation**:
    *   **Subcarrier Mapping (`Tx_Step_3_...m`)**: 변조된 심볼들을 IFFT를 위한 주파수 배열에 매핑합니다. 저주파 대역 잡음을 회피하기 위해 고주파수 대역의 부반송파(Subcarrier)에만 데이터를 할당하며, 실수(real-valued) 시간 영역 신호를 얻기 위해 허미션 대칭(Hermitian Symmetry)을 만족시키도록 구조화합니다.
    *   **IFFT (`Tx_Step_3_...m`)**: 각 OFDM 블록에 대해 `ifft`를 수행하여 시간 영역 신호로 변환합니다.
6.  **Frame Structuring & Conditioning**:
    *   **Pilot Insertion (`Tx_Step_4_...m`)**: 수신단에서의 채널 추정을 위해, 4개의 데이터 심볼마다 1개의 파일럿 심볼을 주기적으로 삽입합니다.
    *   **Cyclic Prefix (CP) Insertion (`Tx_Step_4_...m`)**: 다중 경로 채널로 인한 심볼 간 간섭(ISI)을 방지하기 위해 각 OFDM 심볼의 뒷부분을 복사하여 앞에 덧붙입니다.
    *   **High-pass Filtering (`Tx_Step_5_...m`)**: `butter` 함수로 설계된 고역 통과 필터를 `filtfilt`으로 적용하여 신호가 의도된 고주파 대역에만 존재하도록 합니다.
    *   **Preamble & Wake-up Signal (`Tx_Step_9_...m`)**:
        *   수신단의 저전력 대기 상태를 깨우기 위한 **19kHz 사인파**를 신호의 가장 앞부분에 추가합니다.
7.  **Acoustic Signal Output (`Tx_Step_9_...m`)**:
    *   최종 생성된 디지털 신호를 `audiowrite`를 통해 `.WAV` 파일로 저장하거나, `sound` 함수로 스피커를 통해 직접 재생합니다.
    *   전송 신호를 배경 음악(Base WAV)에 숨겨서 보내는 기능(Acoustic Steganography)도 구현되어 있습니다.

#### 📥 수신단 (Receiver) 파이프라인
수신 과정은 `Rx_main.m`에서 제어됩니다.

1.  **Listening & Wake-up State (`Rx_main.m`)**:
    *   평상시에는 `audioDeviceReader`를 통해 짧은 시간(1초) 동안만 소리를 녹음하고, 저장된 19kHz Wake-up 신호와의 상호 상관(`xcorr`) 값을 계산합니다.
    *   상관 값이 임계치를 넘으면 'Wake-up'으로 판단하고, 전체 데이터 수신을 위한 녹음 절차를 시작합니다.
2.  **Signal Acquisition & Synchronization (`Rx_main.m`, `Rx_Step_2_...m`)**:
    *   전체 데이터 전송 시간만큼 마이크를 통해 신호를 녹음합니다.
    *   송신 시 사용된 배경 음악(Base WAV)과의 상호 상관을 통해 데이터 프레임의 정확한 시작점을 탐지하여 동기화를 수행합니다.
3.  **OFDM Demodulation (`Rx_Step_2_...m`)**:
    *   동기화된 신호에서 각 심볼의 CP를 제거합니다.
    *   `fft`를 수행하여 시간 영역 신호를 주파수 영역의 부반송파 데이터로 변환합니다.
4.  **Channel Estimation & Equalization (`Rx_Step_2_...m`)**:
    *   수신된 파일럿 심볼과 기지의 파일럿 심볼을 비교하여 주파수 영역에서의 채널 응답(H)을 추정합니다.
    *   Zero-Forcing 방식을 통해, 수신된 데이터 심볼들을 추정된 채널 응답의 역수(1/H)로 나누어 채널에 의한 왜곡을 보상합니다.
5.  **Demodulation (`Rx_Step_2_...m`)**:
    *   채널 등화가 완료된 심볼들을 `pskdemod`를 통해 QPSK 복조하여 비트 스트림으로 변환합니다.
6.  **Channel Decoding**:
    *   **De-interleaving**: 송신 시 적용된 순서의 역순으로 비트들을 재배치하여 원래 순서로 복원합니다.
    *   **Repetition Decoding**: 반복된 비트들을 그룹으로 묶어 다수결(Majority Voting) 원칙에 따라 최종 비트를 결정하여 오류를 정정합니다.
7.  **Bitstream to Image & Post-processing (`Rx_Step_2_...m`)**:
    *   최종 복원된 비트 스트림을 128x128 2차원 행렬로 재구성하여 이미지를 생성합니다.
    *   `medfilt2`를 이용한 미디언 필터를 적용하여 통신 과정에서 발생한 임펄스성 잡음(Salt & Pepper Noise)을 제거하는 옵션을 제공합니다.
8.  **Optical Character Recognition (OCR) (`performEasyOCR.m`)**:
    *   MATLAB의 Python 연동 기능을 통해, 복원된 이미지를 `uint8` 배열로 변환하여 Python 함수에 전달합니다.
    *   Python에서는 `easyocr` 라이브러리를 사용하여 이미지 내의 한국어와 영어 텍스트를 인식하고, 그 결과를 다시 MATLAB으로 반환하여 화면에 출력합니다.

### 4. 코드 리뷰 및 고찰

#### 🟢 잘된 점 (Strengths)

1.  **End-to-End 시스템 구현 역량**
    아이디어 구상부터 신호처리, 변복조, 채널코딩, 동기화 등 통신 시스템의 핵심 파이프라인 전체를 MATLAB으로 직접 구현하여, 복잡한 시스템을 설계하고 완성하는 개발 능력을 보여줍니다.

2.  **실용성을 고려한 설계**
    단순한 시뮬레이션을 넘어, 그림판 GUI, 저전력 Wake-up 메커니즘, 배경음에 데이터 신호를 숨기는 기능 등 실제 사용 환경을 고려한 실용적인 기능들을 구현하며 문제 해결에 대한 깊이를 더하였습니다.

3.  **다양한 기술 스택의 융합 능력**
    주력 언어인 MATLAB 환경에서 Python의 강력한 `easyocr` 라이브러리를 성공적으로 연동하여 OCR 기능을 구현하였습니다. 이는 특정 기술에 국한되지 않고, 문제 해결을 위해 최적의 도구를 찾아내고 통합할 수 있음을 보인 것입니다.

#### 🟡 프로젝트 회고 및 개선 방향 (Retrospective & Future Improvements)

1.  **하드코딩된 경로 문제**
    `Tx_main.m`, `Rx_main.m` 등 다수 파일에 `"C:\Users\user\..."` 와 같이 절대 경로가 하드코딩되어 있어, 다른 환경에서의 실행을 어렵게 만듭니다. 이를 상대 경로로 변경하거나, 별도의 설정 파일(`config.m`)을 두어 경로를 관리한다면 코드의 이식성과 재사용성을 크게 향상시킬 수 있습니다.

2.  **코드 가독성 및 유지보수성**
    `Whether_NOT_Repetition_coding__OR__Repetition_How_Many` 와 같이 변수명이 지나치게 길거나, `N`, `Subcarrier_Freq_Divided_by` 등 의미를 파악하기 어려운 매직 넘버들이 코드 전반에 사용되고 있습니다. 변수명은 간결하고 명확하게 규칙을 정하고, 주요 파라미터들은 구조체(struct)나 별도의 설정 함수를 통해 관리하면 가독성과 유지보수성이 높아질 수 있습니다.

3.  **동기화 및 채널 추정 알고리즘 고도화**
    현재 동기화는 `Base_WAV`와의 상호 상관에 의존하고 있어, 배경음이 바뀌거나 잡음이 심한 환경에서는 성능 저하가 있을 수 있습니다. PN 시퀀스와 같은 자기 상관 특성이 우수한 프리앰블을 설계하여 적용하면 동기화 성능을 높일 수 있습니다. 또한, 채널 추정 역시 간단한 Zero-Forcing 방식 대신, 잡음까지 고려하는 MMSE(Minimum Mean Square Error) 등화 기법을 적용하면 복원 성능을 개선할 수 있습니다.

4.  **모듈화(Modularity) 개선**
    `Rx_Step_2_Get_Estimated_Img.m` 파일 하나가 동기화부터 이미지 복원까지 수신단의 거의 모든 과정을 처리하는 거대 함수(Monolithic Function) 형태를 띠고 있습니다. 이를 `synchronize.m`, `equalize.m`, `decode.m` 등 기능 단위의 작은 함수들로 분리(리팩토링)한다면, 각 모듈의 독립적인 테스트가 용이해지고 코드의 전체적인 구조를 파악하기 쉬워져 유지보수성이 향상될 것입니다.

</details>
