<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<!-- 튜토리얼 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.css"/>
<script src="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.js.iife.js"></script>

<style>

    #transInput::placeholder {
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
    .trans-panel {
        background: #ffffff;
        border: 2px solid #2F3640;
        width: 500px !important;
        height: 800px !important;
        display: flex;
        flex-direction: column;
        z-index: 10001;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        border-radius: 12px;
        overflow: hidden;
    }

    /* 2. 헤더 스타일 */
    .trans-bg {
        background: #2F3640 !important;
        padding: 12px 15px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: grab;
        user-select: none;
        color: white !important
    }

    /* 3. 메시지 영역 */
    .trans-msg-container {
        flex: 1;
        padding: 15px;
        overflow-y: auto;
        background: #f4f5ff;
    }

    /* 4. 채팅 버블 디자인 (말풍선 유지) */
    .trans-panel .msg-user { text-align: right; margin-bottom: 10px; }
    .trans-panel .msg-user span {
        background: #696CFF;
        color: white;
        padding: 8px 12px;
        border-radius: 15px 15px 0 15px;
        display: inline-block;
    }

    .trans-panel .msg-ai { text-align: left; margin-bottom: 15px; }
    .trans-panel .msg-ai span {
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
    .trans-quick-btn {
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
    .trans-quick-btn:hover, .trans-quick-btn.active{
        background-color: #696CFF !important;
        color: white !important;
        border-color: #696CFF !important;
    }
    #goupbtn{
        font-size: 0.8rem !important;
        padding: 7px 10px !important;
        background-color: #666;
        color: white;
        border: black 1px solid;
        border-radius: 6px !important;
        text-align: left;
        transition: all 0.2s ease;
        cursor: pointer;
    }
    #goupbtn:hover{
        background-color: black !important;
        color: white !important;
        border-color:  #666 !important;
    }
    #goupbtn:active {
        background-color:  #333 !important;
        transition: all 0.2s ease;
    }

    /* 6. 하단 입력창 및 버튼 레이아웃 */
    .trans-input-group {
        display: flex !important;
        align-items: center;
        gap: 5px;
    }
    #transInput { flex: 1; min-width: 0; }
    .button-group { display: flex; align-items: center; flex-shrink: 0; gap: 4px; }

    #transSendBtn { width: 40px; height: 40px; border-radius: 8px; display: flex; align-items: center; justify-content: center; }
    #transStopBtn { display: none;
    text-decoration: none;
    align-items: center;
    justify-content: center;
    /* 추가: 전송 버튼과 크기를 맞춤 */
    width: 40px;
    height: 40px; }
    #transStopBtn:hover { color: #dc3545; background: #fff5f5; border-radius: 50%; }

    /* 입력창 포커스 시 테두리 강조 */
    #transInput:focus {
        background-color: #fcfcff;
        border-radius: 8px;
        transition: all 0.2s;
    }

    /* 입력창 전체 그룹의 여백 살짝 조정 */
    .trans-input-group {
        padding: 5px 10px;
        border: 1px solid #eee;
        border-radius: 10px;
        margin: 5px;
    }
    .trans-is-hidden {
        display: none !important;
    }
</style>

<div class="chat-window trans-panel" id="transChatWindow">
    <div class="chat-header trans-bg" id="transChatHeader">
        <div class="d-flex align-items-center" style="pointer-events: none;">
            <img src="${pageContext.request.contextPath}/images/icon2.png" alt="logo" style="width: 35px; height: 30px; margin-right: 10px;">
            <strong>말다듬 AI</strong>
        </div>
        <button onclick="AiTransTutorial()" style="display: flex; align-items: center; gap: 5px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 5px 5px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.2s;" onmouseover="this.style.backgroundColor='#f8f9fa'" onmouseout="this.style.backgroundColor='#fff'">
            <span class="material-icons" style="font-size: 1.1rem;">help_outline</span> AI튜토리얼
        </button>
        <button type="button"  id="goupbtn" onclick="goUp()" style="margin-left: 100px;">맨 위로</button>
        <button type="button" class="btn-close btn-close-white" onclick="closeChat('trans')"></button>
    </div>

    <div id="transMessages" class="trans-msg-container">
        <div class="msg-ai">
            <span id="transFirstBubble">
                <div class="ai-greeting">
                    <div class="ai-title">안녕하세요!</div>
                    <div class="ai-subtitle">WORKUP 말다듬 도우미입니다.</div>

                    <div class="ai-question" style="margin-top: 15px; font-size: 0.85rem; color: #888;">
                         자주 묻는 질문
                    </div>

                    <div class="quick-buttons">
                        <button class="trans-quick-btn" id="switchSentences" >🪄 문장 스타일 변환</button>
                        <button class="trans-quick-btn" id="translateTo" >🗣️ 다국어 변역</button>
                    </div>

                    <div class="direct-input-notice" style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed #e0e4ff; font-size: 0.8rem; color: #696CFF;">
                        그 외에 궁금하신 내용은 아래에 </br> <strong>직접 채팅</strong>으로 물어봐 주세요!
                    </div>
                </div>
            </span><br>

            <span  class='trans-is-hidden'  id="switchSentencesOptions">
                <div class="ai-selectOption">
                    <div class="ai-title">🪄 문장 스타일 변환</div>
                    <div class="ai-subtitle">어떤 말투로 변환해드릴까요?</div>
                    <div class="ai-subtitle">원하는 말투를 기타 입력칸에 입력 후 </div>
                    <div class="ai-subtitle">엔터를 누른 뒤 글감을 보내주세요!</div>
                    <div class="ai-question" style="margin-top: 15px; font-size: 0.85rem; color: #888;">
                         자주 쓰는 스타일
                    </div>
                    <div class="quick-buttons">
                        <button class="trans-quick-btn option" value="정중한 말투" id="transSecondBubble" >정중한 말투</button>
                        <button class="trans-quick-btn option" value="보고서 요목화" >보고서 요목화</button>
                        <input type="text" class="trans-quick-btn option" placeholder="기타 말투 입력칸" id="transLastBubble" />
                    </div>
                    <div class="direct-input-notice" style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed #e0e4ff; font-size: 0.8rem; color: #696CFF;">
                        그 외에 궁금하신 내용은 아래에 </br> <strong>직접 채팅</strong>으로 물어봐 주세요!
                    </div>
                </div>
            </span>

            <span class='trans-is-hidden' id="translateToOptions">
                <div class="ai-selectOption">
                    <div class="ai-title">🗣️ 다국어 변역</div>
                    <div class="ai-subtitle">어떤 언어로 변환해드릴까요?</div>
                    <div class="ai-subtitle">기타 언어는 입력칸에 입력 후 </div>
                    <div class="ai-subtitle">엔터를 누른 뒤 글감을 보내주세요!</div>

                    <div class="ai-question" style="margin-top: 15px; font-size: 0.85rem; color: #888;">
                         자주 찾는 언어
                    </div>
                    <div class="quick-buttons">
                        <button class="trans-quick-btn option" value="영어">영어</button>
                        <button class="trans-quick-btn option" value="일본어">일본어</button>
                        <input type="text" class="trans-quick-btn option" placeholder="기타 언어 입력칸"  />
                    </div>
                    <div class="direct-input-notice" style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed #e0e4ff; font-size: 0.8rem; color: #696CFF;">
                        그 외에 궁금하신 내용은 아래에 </br> <strong>직접 채팅</strong>으로 물어봐 주세요!
                    </div>
                </div>
            </span>

        </div>


    </div>

    <div class="chat-input border-top bg-white p-2">
            <div class="trans-input-group">
                <input id="transInput" class="form-control border-0 shadow-none" placeholder="WORKUP AI에게 물어보기" />
                <div class="button-group">
                    <button id="transStopBtn" class="btn btn-link text-danger p-1" title="중지">
                        <i class="bi bi-stop-circle" style="font-size: 1.2rem;"></i>
                    </button>
                    <button id="transSendBtn" class="btn btn-primary">
                        <i class="bi bi-send-fill"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

<script>
    // 1. 변수 선언
    const transInput = document.getElementById('transInput');
    const transsendBtn = document.getElementById('transSendBtn');
    const transstopBtn = document.getElementById('transStopBtn');
    const switchSentences = document.getElementById('switchSentences');
    const translateTo = document.getElementById('translateTo');
    const transMessages = document.getElementById("transMessages")

//(trans 고유) : 맨 위로 가기
    function goUp(){ transMessages.scrollTop = 0;}
//(trans 고유) : 자주묻는 질문 대응 (1)
        switchSentences.addEventListener("click",()=> {
            //만약 아래 항목이 선택된 상태면 active 삭제
            translateTo.classList.remove('active');
            document.getElementById('translateToOptions').classList.add('trans-is-hidden') //하위 선택도 안보이게
            //본인 클릭 여러번시 active 토글
            switchSentences.classList.toggle('active');
            // 'trans-is-hidden' 클래스가 있으면 제거하고, 없으면 추가함 (열기/닫기)
            const options = document.getElementById('switchSentencesOptions');
            options.classList.toggle('trans-is-hidden');
            // 스크롤 제일 아래로 !
            //transMessages.scrollTop = transMessages.scrollHeight;
        })
        translateTo.addEventListener("click",()=> { //위와 같음
            switchSentences.classList.remove('active');
            document.getElementById('switchSentencesOptions').classList.add('trans-is-hidden')
            translateTo.classList.toggle('active');
            const options = document.getElementById('translateToOptions');
            options.classList.toggle('trans-is-hidden');
            //transMessages.scrollTop = transMessages.scrollHeight;
        });
//(trans 고유) : 자주묻는 질문 대응 (2)
        // 1. 모든 버튼과 input 요소를 선택
        const quickBtns = document.querySelectorAll('.trans-quick-btn');
        quickBtns.forEach(el => {
            // [클릭 이벤트] 버튼과 input 공통
            el.addEventListener('click', function() {
                if (this.tagName === 'BUTTON') {
                    activateAndLog(this);
                }
            });
            // [엔터 이벤트] INPUT 전용
            if (el.tagName === 'INPUT') {
                el.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        if (this.value.trim() !== '') {
                            activateAndLog(this);
                            this.blur(); // 입력 완료 후 포커스 해제
                        }
                    }
                });
            }
        });
        // 2. 활성화 스타일 적용 및 로그 출력 함수
        function activateAndLog(target) {
            // 모든 요소에서 active 제거
            quickBtns.forEach(btn => btn.classList.remove('active'));

            // 선택된 타겟만 active 추가
            target.classList.add('active');

            // 현재 선택된 값 확인 (테스트용)
            console.log("현재 선택된 값:", getSelectedValue());
        }

        // 3. 최종 선택된 값을 가져오는 함수 (서버 전송 시 사용)
        function getSelectedValue() {
            const activeEl = document.querySelector('.trans-quick-btn.active');
            if (!activeEl) return null; // 선택된 게 없음
            // 버튼이면 innerText, input이면 value 반환
            return activeEl.value;
        }

    // 2. 초기 로직 및 이벤트 리스너 연결
    if (transInput && transsendBtn && transstopBtn) {

        // 입력값에 따른 전송 버튼 활성화/비활성화
        transInput.addEventListener('input', function() {
            if (this.value.trim().length > 0) {
                transsendBtn.disabled = false;
                transsendBtn.style.opacity = "1";
            } else {
                transsendBtn.disabled = true;
                transsendBtn.style.opacity = "0.5";
            }
        });

        // 클릭 이벤트 연결
        transsendBtn.addEventListener('click', TranshandleSendMessage);
        transstopBtn.addEventListener('click', transfinishAIResponse);

        // 엔터 키 대응
        transInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') TranshandleSendMessage();
        });
    }

    // 함수 정의
    function TranshandleSendMessage(mes) {
        if(mes && typeof mes === 'string') { // 자주 묻는 질문 클릭 했을 시에! && 버튼으로 클릭시에
            console.log("메시지 :", mes);
            transInput.value = mes;
        }
        let message =getSelectedValue();

         message += transInput.value.trim();

        if (transInput.value.trim() === "") return;

        // 버튼 UI 교체
        transsendBtn.style.setProperty('display', 'none', 'important');
        transstopBtn.style.setProperty('display', 'flex', 'important');

        // commonAI에 있는 전송 함수 실행
        if (typeof handleProjectSend === 'function') {
            handleProjectSend("trans");
        }
    }

    function transfinishAIResponse() {
        // 버튼 복구: 중지 숨기고 전송 보이기
        transstopBtn.style.setProperty('display', 'none', 'important');
        transsendBtn.style.setProperty('display', 'flex', 'important');

        // 만약 AI 응답 중이었다면 SSE 연결 종료
        if (typeof handletransStop === 'function') {
            handletransStop("trans");
        }
    }


    // ==========================================
    // 💡 Driver.js 튜토리얼 가이드
    // ==========================================
    function AiTransTutorial() {
        const driver = window.driver.js.driver;

        const driverObj = driver({
            showProgress: true,      // 상단에 1/7 같은 진행률 표시
            animate: true,           // 부드러운 이동 애니메이션
            allowClose: true,        // 배경 눌러서 닫기 허용
            doneBtnText: '완료',
            closeBtnText: '건너뛰기',
            nextBtnText: '다음 ❯',
            prevBtnText: '❮ 이전',

            steps: [
                // 1-2. 말다듬 AI: 스타일 제안
                {
                    element: '#transFirstBubble',
                    popover: {
                        title: '✨ 스마트한 교정 제안',
                        description: `가장 자주 쓰이는 <span style="color: #696cff; font-weight: bold;">맞춤형 교정 스타일</span>들이 준비되어 있어요!<br><br>목록에 없는 특별한 요청사항은 입력창에 직접 작성하셔도 좋습니다.`,
                        side: "left", align: 'start'
                    },
                    onDeselected: (element, step, options) => {
                        const transFirstBubble = document.querySelector('#switchSentences');
                        if(transFirstBubble) transFirstBubble.click();
                    }
                },

// 1-3. 말다듬 AI: 기능 전환
                {
                    element: '#switchSentences',
                    popover: {
                        title: '🔄 스타일 모드 전환',
                        description: `단순 교정을 넘어, 이번에는 문장의 <span style="color: #696cff; font-weight: bold;">분위기 자체를 바꾸는 기능</span>을 선택해 볼게요!`,
                        side: "left", align: 'start'
                    }
                },

// 1-4. 말다듬 AI: 상세 옵션 선택
                {
                    element: '#switchSentencesOptions',
                    popover: {
                        title: '🎭 나만의 말투 고르기',
                        description: `어떤 <span style="color: #696cff; font-weight: bold;">말투</span>로 변환해 드릴까요?<br><br>하단 옵션을 클릭하면 <span style="color: #696cff; font-weight: bold;">보라색</span>으로 활성화되며 해당 스타일이 즉시 적용됩니다.`,
                        side: "left", align: 'start'
                    },
                    onDeselected: (element, step, options) => {
                        const transSecondBubble = document.querySelector('#transSecondBubble');
                        if(transSecondBubble) transSecondBubble.click();
                    }
                },

// 1-5. 말다듬 AI: 상태 확인
                {
                    element: '#transSecondBubble',
                    popover: {
                        title: '✅ 설정 완료!',
                        description: `현재 <span style="color: #696cff; font-weight: bold;">'정중한 말투'</span> 옵션이 선택되었습니다.<br><br>버튼이 보라색으로 빛나고 있다면 AI가 변환할 준비를 마친 상태입니다.`,
                        side: "left", align: 'start'
                    },
                },
                {
                    element: '#transLastBubble',
                    popover: {
                        title: '✏️ 원하는 말투 직접 지정',
                        description: `목록에 없는 말투도 문제없습니다! <br/><span style="color: #696cff; font-weight: bold;">'기타'</span> 입력창에 원하는 말투를 입력하고 "엔터"를 하여 활성화 하십시오.`,
                        side: "left", align: 'start'
                    },
                },

// 1-6. 말다듬 AI: 최종 입력
                // 1-6. 말다듬 AI: 최종 입력 안내 및 자동 입력
                {
                    element: '#transInput',
                    popover: {
                        title: '✍️ 문장 입력하기',
                        description: `이제 다듬고 싶은 내용을 입력해 보세요. <br><br>예시로 <span style="color: #696cff; font-weight: bold;">"나 오늘 늦어"</span>라는 문장을 정중하게 바꿔볼까요?`,
                        side: "left", align: 'start'
                    },
                    onDeselected: (element, step, options) => {
                        const transInput = document.querySelector('#transInput');
                        if(transInput) {
                            // 사용자가 입력하지 않아도 자동으로 예시 문구를 채워줍니다.
                            transInput.value = "나 오늘 좀 늦을 것 같아";
                        }
                    }
                },

// 1-7. 말다듬 AI: 전송 버튼 클릭 가이드
                {
                    element: '#transSendBtn',
                    popover: {
                        title: '🚀 AI에게 부탁하기',
                        description: `모든 준비가 끝났습니다! <span style="color: #696cff; font-weight: bold;">전송 버튼</span>을 누르면 AI가 실시간으로 문장을 다듬어 드립니다.`,
                        side: "top", align: 'center'
                    },
                    onDeselected: (element, step, options) => {
                        const transSendBtn = document.querySelector('#transSendBtn');
                        if(transSendBtn) {
                            // 튜토리얼이 끝나면서 실제로 AI 응답이 시작되도록 클릭!
                            transSendBtn.click();
                        }
                    }
                },
                // 다른 옵션을 선택하고 싶을 때는
                {
                    element: '#goupbtn',
                    popover: {
                        title: '🚀 맨 위로',
                        description: `다른 옵션을 선택하고 싶으면 <span style="color: #696cff; font-weight: bold;">맨 위로</span>버튼을 눌러서 설정하면 됩니다`,
                        side: "top", align: 'center'
                    },
                    onDeselected: (element, step, options) => {
                        const transSendBtn = document.querySelector('#goupbtn');
                        if(transSendBtn) {
                            // 튜토리얼이 끝나면서 실제로 AI 응답이 시작되도록 클릭!
                            transSendBtn.click();
                        }
                    }
                },


// 1-4. '기타' 언어 설정 (직접 입력)


            ],

        });

        // 튜토리얼 시작!
        driverObj.drive();
    }

</script>