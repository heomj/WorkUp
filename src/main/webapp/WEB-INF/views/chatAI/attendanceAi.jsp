<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<style>

    #attendanceInput::placeholder {
        font-size: 0.8rem;  /* 기존보다 작게 조절 */
        font-weight: 300;   /* 글자 두께를 얇게 하면 덜 커 보입니다 */
        color: #a0a0a0;     /* 색상을 조금 연하게 하면 시각적 부담이 줄어듭니다 */
    }

    .direct-input-notice {
    line-height: 1.4;
    text-align: center; /* 멘트를 중앙 정렬하면 더 부드러워 보입니다 */
    }

    .direct-input-notice strong {
        text-decoration: underline;
        text-underline-offset: 3px;
    }

    /* 자주 묻는 질문 아이콘 강조 */
    .ai-question i {
        color: #696CFF;
        margin-right: 4px;
    }

    /* 1. 기본 패널 스타일 */
    .attendance-panel {
        background: #ffffff;
        border: 1px solid #00abfb;
        width: 500px !important;
        height: 650px !important;
        display: flex;
        flex-direction: column;
        z-index: 10001;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        border-radius: 12px;
        overflow: hidden;
    }

    /* 2. 헤더 스타일 */
    .attendance-bg {
        background: #00abfb !important;
        padding: 12px 15px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: grab;
        user-select: none;
        color: white !important
    }

    /* 3. 메시지 영역 */
    .project-msg-container {
        flex: 1;
        padding: 15px;
        overflow-y: auto;
        background: #f4f5ff;
    }

    /* 4. 채팅 버블 디자인 (말풍선 유지) */
    .attendance-panel .msg-user { text-align: right; margin-bottom: 10px; }
    .attendance-panel .msg-user span {
        background: #696CFF;
        color: white;
        padding: 8px 12px;
        border-radius: 15px 15px 0 15px;
        display: inline-block;
    }

    .attendance-panel .msg-ai { text-align: left; margin-bottom: 15px; }
    .attendance-panel .msg-ai span {
        background: white;
        border: 1px solid #e0e0e0;
        padding: 15px; /* 안쪽 여백을 넉넉히 주어 버튼과 간격 확보 */
        border-radius: 15px 15px 15px 0;
        display: inline-block;
        max-width: 85%; /* 말풍선이 너무 꽉 차지 않게 조절 */
    }

    /* 5. 말풍선 내부 텍스트 및 버튼 스타일 */
    .ai-greeting { line-height: 1.5; }
    .ai-title { font-weight: 700; font-size: 1rem; color: #696CFF; margin-bottom: 2px; }
    .ai-subtitle { font-size: 0.85rem; color: #666;}
    .ai-question { margin-top: 8px; font-weight: 500; color: #333; font-size: 0.9rem; }

    .quick-buttons {
        display: flex;
        flex-direction: column;
        gap: 6px;
        margin-top: 12px;
    }
    .quick-btn {
        font-size: 0.8rem !important;
        padding: 7px 10px !important;
        background-color: #f8f9ff !important; /* 버튼 배경색을 살짝 깔아줌 */
        border: 1px solid #e0e4ff !important;
        color: #696CFF !important;
        border-radius: 6px !important;
        text-align: left;
        transition: all 0.2s ease;
        cursor: pointer;
    }
    .quick-btn:hover {
        background-color: #696CFF !important;
        color: white !important;
        border-color: #696CFF !important;
    }

    /* 6. 하단 입력창 및 버튼 레이아웃 */
    .attendance-input-group {
        display: flex !important;
        align-items: center;
        gap: 5px;
    }
    #attendanceInput { flex: 1; min-width: 0; }
    .button-group { display: flex; align-items: center; flex-shrink: 0; gap: 4px; }

    #attendancesendBtn { width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center; }
    #attendancestopBtn { display: none;
    text-decoration: none;
    align-items: center;
    justify-content: center;
    /* 추가: 전송 버튼과 크기를 맞춤 */
    width: 40px;
    height: 40px; }
    #attendancestopBtn:hover { color: #dc3545; background: #fff5f5; border-radius: 50%; }

    /* 입력창 포커스 시 테두리 강조 */
    #attendanceInput:focus {
        background-color: #fcfcff;
        border-radius: 8px;
        transition: all 0.2s;
    }

    /* 입력창 전체 그룹의 여백 살짝 조정 */
    .attendance-input-group {
        padding: 5px 10px;
        border: 1px solid #eee;
        border-radius: 10px;
        margin: 5px;
    }
</style>

<div class="chat-window attendance-panel" id="attendanceChatWindow">
    <div class="chat-header attendance-bg" id="attendanceChatHeader">
        <div class="d-flex align-items-center" style="pointer-events: none;">
            <img src="${pageContext.request.contextPath}/images/icon2.png" alt="logo" style="width: 35px; height: 30px; margin-right: 10px;">
            <strong>ATTENDANCE AI</strong>
        </div>
        <button type="button" class="btn-close btn-close-white" onclick="closeChat('attendance')"></button>
    </div>

    <div id="attendanceMessages" class="project-msg-container">
        <div class="msg-ai">
            <span>
                <div class="ai-greeting">
                    <div class="ai-title">안녕하세요!</div>
                    <div class="ai-subtitle">WORKUP 근태관리 도우미입니다.</div>

                    <div class="ai-question" style="margin-top: 15px; font-size: 0.85rem; color: #888;">
                         자주 묻는 질문
                    </div>

                    <div class="quick-buttons">
                        <button class="quick-btn" onclick="attenhandleSendMessage('이번달 외출 조회')">🏃 이번달 외출 조회</button>
                        <button class="quick-btn" onclick="attenhandleSendMessage('마지막 휴가')">🏖️ 마지막 휴가 날짜</button>
                        <button class="quick-btn" onclick="attenhandleSendMessage('마지막 출장일')">✈️ 마지막 출장일 날짜</button>
                    </div>

                    <div class="direct-input-notice" style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed #e0e4ff; font-size: 0.8rem; color: #696CFF;">
                        그 외에 궁금하신 내용은 아래에 </br> <strong>직접 채팅</strong>으로 물어봐 주세요!
                    </div>
                </div>
            </span>
        </div>
    </div>

    <div class="chat-input border-top bg-white p-2">
            <div class="attendance-input-group">
                <input id="attendanceInput" class="form-control border-0 shadow-none" placeholder="WORKUP AI에게 물어보기" />
                <div class="button-group">
                    <button id="attendancestopBtn" class="btn btn-link text-danger p-1" title="중지">
                        <i class="bi bi-stop-circle" style="font-size: 1.2rem;"></i>
                    </button>
                    <button id="attendancesendBtn" class="btn btn-primary">
                        <i class="bi bi-send-fill"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>



<script>
    // 1. 변수 선언
    const attendanceInput = document.getElementById('attendanceInput');
    const attensendBtn = document.getElementById('attendancesendBtn'); 
    const attenstopBtn = document.getElementById('attendancestopBtn');

    // 2. 초기 로직 및 이벤트 리스너 연결
    if (attendanceInput && attensendBtn && attenstopBtn) {

        // 입력값에 따른 전송 버튼 활성화/비활성화
        attendanceInput.addEventListener('input', function() {
            if (this.value.trim().length > 0) {
                attensendBtn.disabled = false;
                attensendBtn.style.opacity = "1";
            } else {
                attensendBtn.disabled = true;
                attensendBtn.style.opacity = "0.5";
            }
        });

        // 클릭 이벤트 연결
        attensendBtn.addEventListener('click', attenhandleSendMessage);
        attenstopBtn.addEventListener('click', attenfinishAIResponse);

        // 엔터 키 대응
        attendanceInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') attenhandleSendMessage();
        });
    }

    // 함수 정의
    function attenhandleSendMessage(mes) {
        if(mes && typeof mes === 'string') { // 자주 묻는 질문 클릭 했을 시에!
            console.log("메시지 :", mes);
            attendanceInput.value = mes;
        }

        const message = attendanceInput.value.trim();
        if (message === "") return;

        // 버튼 UI 교체
        attensendBtn.style.setProperty('display', 'none', 'important');
        attenstopBtn.style.setProperty('display', 'flex', 'important');

        // commonAIㅔㅇ 있는 전송 함수 실행
        if (typeof handleProjectSend === 'function') {
            handleProjectSend("attendance");
        }
    }

    function attenfinishAIResponse() {
        // 버튼 복구: 중지 숨기고 전송 보이기
        attenstopBtn.style.setProperty('display', 'none', 'important');
        attensendBtn.style.setProperty('display', 'flex', 'important');

        // 만약 AI 응답 중이었다면 SSE 연결 종료
        if (typeof handleProjectStop === 'function') {
            handleProjectStop("attendance");
        }
    }

</script>