<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<style>

    #approvalInput::placeholder {
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
    .approval-panel {
        background: #ffffff;
        border: 2px solid #fd992c;
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
    .approval-bg {
        background: #fd992c !important;
        padding: 12px 15px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: grab;
        user-select: none;
        color: white !important
    }

    /* 3. 메시지 영역 */
    .approval-msg-container {
        flex: 1;
        padding: 15px;
        overflow-y: auto;
        background: #f4f5ff;
    }
    
    /* 4. 채팅 버블 디자인 (말풍선 유지) */
    .approval-panel .msg-user { text-align: right; margin-bottom: 10px; }
    .approval-panel .msg-user span { 
        background: #696CFF; 
        color: white; 
        padding: 8px 12px; 
        border-radius: 15px 15px 0 15px; 
        display: inline-block; 
    }

    .approval-panel .msg-ai { text-align: left; margin-bottom: 15px; }
    .approval-panel .msg-ai span { 
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
    .approval-input-group {
        display: flex !important;
        align-items: center;
        gap: 5px;
    }
    #approvalInput { flex: 1; min-width: 0; }
    .button-group { display: flex; align-items: center; flex-shrink: 0; gap: 4px; }

    #approvalSendBtn { width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center; }
    #approvalStopBtn { display: none;
    text-decoration: none; 
    align-items: center; 
    justify-content: center; 
    /* 추가: 전송 버튼과 크기를 맞춤 */
    width: 40px; 
    height: 40px; }
    #approvalStopBtn:hover { color: #dc3545; background: #fff5f5; border-radius: 50%; }

    /* 입력창 포커스 시 테두리 강조 */
    #approvalInput:focus {
        background-color: #fcfcff;
        border-radius: 8px;
        transition: all 0.2s;
    }

    /* 입력창 전체 그룹의 여백 살짝 조정 */
    .approval-input-group {
        padding: 5px 10px;
        border: 1px solid #eee;
        border-radius: 10px;
        margin: 5px;
    }
</style>
<!-- ///////////////////////////////////////////////CSS 끝 ///////////////////////////////////////////-->

<div class="chat-window approval-panel" id="approvalChatWindow">
    <div class="chat-header approval-bg" id="approvalChatHeader">
        <div class="d-flex align-items-center" style="pointer-events: none;">
            <img src="${pageContext.request.contextPath}/images/icon2.png" alt="logo" style="width: 35px; height: 30px; margin-right: 10px;">
            <strong>APPROVAL AI</strong>
        </div>
        <button type="button" class="btn-close btn-close-white" onclick="closeChat('approval')"></button>
    </div>

    <div id="approvalMessages" class="approval-msg-container">
        <div class="msg-ai">
            <span>
                <div class="ai-greeting">
                    <div class="ai-title">안녕하세요!</div>
                    <div class="ai-subtitle">WORKUP 전자결재 도우미입니다.</div>
                    
                    <div class="ai-question" style="margin-top: 15px; font-size: 0.85rem; color: #888;">
                         자주 묻는 질문
                    </div>
                    
                    <div class="quick-buttons">
                        <button class="quick-btn" onclick="AprvhandleSendMessage('내가 결재해야 하는 문서')">📅 내가 결재해야 하는 문서</button>
                        <button class="quick-btn" onclick="AprvhandleSendMessage('결재 반려 된 문서')">⛔ 결재 반려 된 문서</button>
                    </div>

                    
                    <div class="direct-input-notice" style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed #e0e4ff; font-size: 0.8rem; color: #696CFF;">
                        그 외에 궁금하신 내용은 아래에 </br> <strong>직접 채팅</strong>으로 물어봐 주세요!
                    </div>
                </div>
            </span>
        </div>
    </div>

    <div class="chat-input border-top bg-white p-2">
            <div class="approval-input-group">
                <input id="approvalInput" class="form-control border-0 shadow-none" placeholder="WORKUP AI에게 물어보기" />
                <div class="button-group">
                    <button id="approvalStopBtn" class="btn btn-link text-danger p-1" title="중지">
                        <i class="bi bi-stop-circle" style="font-size: 1.2rem;"></i>
                    </button>
                    <button id="approvalSendBtn" class="btn btn-primary">
                        <i class="bi bi-send-fill"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

<script>
    (() => {
        // 1. 변수 선언
        const approvalInput = document.getElementById('approvalInput');
        const approvalSendBtn = document.getElementById('approvalSendBtn');
        const approvalStopBtn = document.getElementById('approvalStopBtn');
        const approvalMessages = document.getElementById('approvalMessages');

        let approvalEventSource = null;
        let aprvRequestId = null;

        // 스트림 종료 함수
        const closeAprvStream = () => {
            if (approvalEventSource) {
                approvalEventSource.close();
                approvalEventSource = null;
            }
        };

        // 말풍선 추가 함수
        const appendAprvMessage = (text, sender) => {
            const msgDiv = document.createElement('div');
            msgDiv.className = sender === 'user' ? 'msg-user' : 'msg-ai';
            const span = document.createElement('span');
            span.innerHTML = text;
            msgDiv.appendChild(span);
            approvalMessages.appendChild(msgDiv);
            approvalMessages.scrollTop = approvalMessages.scrollHeight;
            return span;
        };

        // 🌟 [핵심] 일괄 결재/반려 처리 (Axios) 🌟
        window.processAiApprovalAxios = async (jsonData) => {
            const aprvNos = jsonData.aprvNos; // 예: [15, 18]
            const action = jsonData.action;   // 'CONFIRM' 또는 'REJECT'
            let aprvLnStts = (action === 'CONFIRM') ? "APRV02002" : "APRV02003";
            let successCount = 0;

            appendAprvMessage(`처리 중입니다... 잠시만 기다려주세요!`, 'ai');

            for (let aprvNo of aprvNos) {
                try {
                    // 1) 기존 결재 화면 로직처럼, 해당 문서의 상세 정보를 먼저 조회
                    const res = await axios.get(`/approval/getPendingDoc?aprvNo=\${aprvNo}`);
                    const docData = res.data;

                    console.log("결재(반려) 처리 전 상세 문서 데이터 받아와짐?:", docData);

                    // 2) 컨트롤러에 보낼 데이터 세팅
                    const data = {
                        "aprvNo" : aprvNo,
                        "isVctDoc" : (docData.vctDocCd) ? 'Y' : 'N',
                        "vctDocCd" : docData.vctDocCd,
                        "vctUsedDays" : docData.vctTotalDays,
                        "vctTotalDays" : docData.vctTotalDays,
                        "aprvDocNo" : docData.aprvDocNo,
                        "aprvSe" : docData.aprvSe,
                        "isAttDoc" : (docData.vctDocCd || docData.bztrpPlc || docData.excsWorkDocBgng) ? 'Y' : 'N',
                        "docWriterId" : docData.docWriterId,
                        "aprvLnStts" : aprvLnStts,
                        "aprvLnCn" : "AI 비서를 통한 결재 처리"
                    };

                    // 3) 실제 승인/반려 Axios 요청
                    await axios.post("/approval/processAprvAxios", data);
                    successCount++;

                } catch (error) {
                    console.error(`\${aprvNo}번 문서 처리 실패:`, error);
                }
            }

            const actionText = (action === 'CONFIRM') ? "결재" : "반려";
            appendAprvMessage(`✅ 총 <strong>\${successCount}건</strong>의 문서가 성공적으로 \${actionText} 되었습니다!`, 'ai');
        };//결재 처리 보내는 데이터 세팅



        // 메인 전송 함수 (commonAI.jsp를 안 거치고 여기서 직접 통신)
        window.AprvhandleSendMessage = (mes) => {

            // ---------------------------------------------------------
            // 1단계 - 사용자 입력 준비 및 화면 세팅
            // ---------------------------------------------------------
            if(mes && typeof mes === 'string') {
                approvalInput.value = mes; // 버튼을 눌러서 들어온 텍스트면 인풋창에 넣기
            }

            const message = approvalInput.value.trim();
            if (!message) return; // 빈칸이면 무시

            appendAprvMessage(message, 'user'); // 내 채팅창에 내가 쓴 말 띄우기
            approvalInput.value = ''; // 인풋창 비우기

            // 전송 버튼은 숨기고, 로딩 중(정지) 버튼 띄우기
            approvalSendBtn.style.setProperty('display', 'none', 'important');
            approvalStopBtn.style.setProperty('display', 'flex', 'important');

            closeAprvStream(); // 혹시 이전 통신이 덜 끝났으면 강제 종료
            aprvRequestId = 'aprv-' + Date.now(); // 이번 통신의 고유 ID 생성

            // 화면에 '답변중...' 이라는 AI 말풍선을 미리 만들어두고 스피너 띄우기
            const aiSpan = appendAprvMessage('답변중...', 'ai');
            aiSpan.innerHTML = `<div class="spinner-border spinner-border-sm" role="status"></div>`;

            let fullText = "";   // AI가 보내주는 텍스트 조각들을 계속 이어붙일 빈 바구니
            let isSaved = false; // 결재(Axios)를 중복해서 2번 쏘지 않게 막아주는 자물쇠 역할

            // ---------------------------------------------------------
            // 2단계 - AI 서버와 실시간 통신 파이프(스트리밍) 연결
            // ---------------------------------------------------------
            // EventSource: 한글자씩 조각조각 가져옴..
            const url = `/api/chat/stream?message=\${encodeURIComponent(message)}&requestId=\${aprvRequestId}&botType=approval`;
            approvalEventSource = new EventSource(url);

            // ---------------------------------------------------------
            // [3단계] AI가 답변 조각을 보낼 때마다 이 함수가 계속 반복 실행됨!
            // ---------------------------------------------------------
            approvalEventSource.onmessage = (e) => {
                if (e.data === "undefined") return; // 쓰레기 데이터 무시
                if (e.data === "[DONE]") {
                    // AI: 통신 파이프 닫기
                    closeAprvStream();
                    approvalStopBtn.style.setProperty('display', 'none', 'important');
                    approvalSendBtn.style.setProperty('display', 'flex', 'important');
                    return;
                }

                // 텍스트조각 이어붙이기(말풍선 내에..)
                fullText += e.data;

                // ---------------------------------------------------------
                // [4단계] 데이터 가로채기 단계..  말풍선(fullText) 속에 [ACTION_DATA : .. 있는지 검사하기..
                // ---------------------------------------------------------
                // 데이터가 조각조각 오기 때문에, 처음엔 "[AC" 였다가 나중에 완벽한 "[ACTION_DATA:{...}]" 형태가 됨.
                //          => 이거 잡는건 좀 어렵군요...
                // 완벽한 형태가 모였는지 정규식으로 확인
                let dataMatch = fullText.match(/\[ACTION_DATA:[\s\S]*?(\{[\s\S]*?\})[\s\S]*?\]/);

                // 만약 암호가 완성되었고, 아직 결재 서버로 전송하지 않았다면(isSaved === false)
                if (dataMatch && !isSaved) {
                    isSaved = true; // 자물쇠 처리... (이후에 조각이 더 와도 다시 결재 쏘지 않음)

                    try {
                        // [5단계] 암호 세척 작업 (html 태그나 불순물 제거)
                        let cleanJsonStr = dataMatch[1]
                            .replace(/<br\s*\/?>/gi, '')
                            .replace(/&nbsp;/gi, ' ')
                            .replace(/\*\*/g, '') // AI가 강조한다고 넣은 ** 지우기
                            .trim();

                        console.log("파싱 시도할 텍스트:", cleanJsonStr);

                        // 세척된 글자를 진짜 자바스크립트 객체(JSON)로 변환!
                        // 성공하면 {"action": "APPROVE", "aprvNo": "123"} 모양이 됨
                        const jsonData = JSON.parse(cleanJsonStr);
                        console.log("완벽하게 청소된 JSON 데이터 도착!!!", jsonData);

                        // [6단계] 해독 완료! 백엔드로 진짜 결재 처리 명령 보내기
                        processAiApprovalAxios(jsonData);

                        // 명령 내렸으니 AI가 말 더 길게 하기 전에 통신 끊어버림 (0.1초 뒤)
                        setTimeout(closeAprvStream, 100);
                    } catch(err) {
                        // 아직 JSON 괄호가 덜 닫혔거나 불순물이 남아서 파싱에 실패한 경우
                        console.error("파싱 실패 (조각이 덜 모였거나 불순물 있음):", err.message);
                        isSaved = false; // 파싱 실패했으니 자물쇠 다시 풀고 다음 조각 기다림
                    }
                    return; // 암호 처리 중에는 사용자 화면에 암호 글자를 찍지 않게 여기서 멈춤!
                }

                // ---------------------------------------------------------
                // [7단계] 화면 출력: 사용자에게 암호는 숨기고 예쁜 답변만 보여주기
                // ---------------------------------------------------------
                // 만약 fullText 안에 "[ACTION_DATA:" 가 섞여 있다면, 그 뒤쪽 텍스트는 싹 다 날려버림
                //              => 근데 조금씩 보이긴함.. ..
                let displayText = fullText.replace(/\[ACTION_DATA:[\s\S]*/, '');

                // 화면에 있는 AI 말풍선에 지금까지 모인 예쁜 텍스트를 업데이트 (엔터키는 <br>로 변환)
                aiSpan.innerHTML = displayText.replace(/\n/g, '<br>');

                // 스크롤 맨 아래로 내리기
                approvalMessages.scrollTop = approvalMessages.scrollHeight;
            };

            // 혹시 통신 중 에러가 나면 파이프 닫기
            approvalEventSource.onerror = () => {
                closeAprvStream();
                approvalStopBtn.style.setProperty('display', 'none', 'important');
                approvalSendBtn.style.setProperty('display', 'flex', 'important');
            };
        }

        // 중지 버튼 함수
        window.AprvfinishAIResponse = () => {
            closeAprvStream();
            if (aprvRequestId) {
                fetch(`/api/chat/stop?requestId=\${aprvRequestId}`, { method: 'POST' });
            }
            approvalStopBtn.style.setProperty('display', 'none', 'important');
            approvalSendBtn.style.setProperty('display', 'flex', 'important');
        };

        // 이벤트 리스너 연결
        if (approvalInput && approvalSendBtn && approvalStopBtn) {
            approvalInput.addEventListener('input', function() {
                if (this.value.trim().length > 0) {
                    approvalSendBtn.disabled = false;
                    approvalSendBtn.style.opacity = "1";
                } else {
                    approvalSendBtn.disabled = true;
                    approvalSendBtn.style.opacity = "0.5";
                }
            });

            // 클릭 및 엔터 시 위에서 새로 만든 독자 함수 실행
            approvalSendBtn.addEventListener('click', () => AprvhandleSendMessage());
            approvalStopBtn.addEventListener('click', AprvfinishAIResponse);
            approvalInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter') AprvhandleSendMessage();
            });
        }
    })();
</script>