<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">

    <!--  임시 파비콘 -->
    <link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/images/test.png">

    <style>


        /* ==========================
           Chat Toggle Button
        ========================== */

        #chatToggleBtn:hover {
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.35);
        }

        /* 화면 하단 고정 */
        body { margin: 0; padding: 0; height: 100vh; background-color: #f4f4f4; z-index: 9999;}
        .wrapper {
            position: fixed;
            bottom: 50px;
            left: 90%;
            transform: translateX(-50%);
            width: 80px;
            height: 80px;
        }

        /* 중앙 버튼 */
        .main-btn {
            width: 80px;
            height: 80px;
            background: #696CFF;
            border-radius: 50%;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            /* 여기서부터 중요! 가운데 정렬 핵심 */
            display: flex;           /* Flexbox 사용 */
            justify-content: center; /* 가로 중앙 정렬 */
            align-items: center;     /* 세로 중앙 정렬 */

            /* 위치 제어 (기존 인라인 스타일 대신 여기서 관리하는 게 더 깔끔합니다) */
            position: fixed;
            z-index: 9999;
        }

        /* 메뉴 아이템 스타일 */
        .menu-item {
            position: absolute;
            top: 15px; left: 15px;
            width: 50px; height: 50px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
            opacity: 0;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            cursor: pointer;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        /* 활성화 시 아이템 배치 (부채꼴 모양으로 펼쳐짐) */
       .wrapper.active .menu-item:nth-child(1) { transform: rotate(-180deg) translate(100px) rotate(180deg); opacity: 1; }
        .wrapper.active .menu-item:nth-child(2) { transform: rotate(-150deg) translate(100px) rotate(150deg); opacity: 1; }
        .wrapper.active .menu-item:nth-child(3) { transform: rotate(-120deg) translate(100px) rotate(120deg); opacity: 1; }
        .wrapper.active .menu-item:nth-child(4) { transform: rotate(-90deg) translate(100px) rotate(90deg); opacity: 1; }
        .wrapper.active .menu-item:nth-child(5) { transform: rotate(-60deg) translate(100px) rotate(60deg); opacity: 1; }
        .wrapper.active .menu-item:nth-child(6) { transform: rotate(-30deg) translate(100px) rotate(30deg); opacity: 1; }
        .wrapper.active .menu-item:nth-child(7) { transform: rotate(0deg) translate(100px) rotate(0deg); opacity: 1; }
    </style>
</head>
<body>


<div class="wrapper" id="menuWrapper" style="position: fixed; z-index: 9999;">
    <div class="menu-item trans" style="z-index: 9998" onclick="openChat('trans')">
      말 다듬
    </div>
    <div class="menu-item project" style="z-index: 9998" onclick="openChat('project')">프로젝트</div>
    <div class="menu-item attendance" style="z-index: 9998" onclick="openChat('attendance')" >근태</div>
    <div class="menu-item calendar" style="z-index: 9998" onclick="openChat('calendar')" >일정</div>
    <div class="menu-item approval" style="z-index: 9998" onclick="openChat('approval')">전자결재</div>
<%--    <div class="menu-item" style="z-index: 9998">공지사항</div>
    <div class="menu-item" style="z-index: 9998">회의실</div>--%>

    <div class="main-btn"  style="position: fixed; z-index: 9999;" onclick="toggleMenu()">
        <span class="material-icons me-1" style="font-size: 32px; color: white;">psychology</span>
    </div>
</div>

<!-- ============ 채팅 jsp include 시작 ============ -->
<div id="projectChatWrapper" class="chat-wrapper" style="display:none; position:fixed; bottom:140px; right:50px; z-index:10000;">
  <jsp:include page="chatAI/projectAI.jsp" />
</div>

<div id="attendanceChatWrapper" class="chat-wrapper" style="display:none; position:fixed; bottom:140px; right:50px; z-index:10000;">
  <jsp:include page="chatAI/attendanceAi.jsp" />
</div>

<div id="transChatWrapper" class="chat-wrapper" style="display:none; position:fixed; bottom:140px; right:50px; z-index:10000;">
    <jsp:include page="chatAI/transAI.jsp" />
</div>

<div id="calendarChatWrapper" class="chat-wrapper" style="display:none; position:fixed; bottom:140px; right:50px; z-index:10000;">
    <jsp:include page="chatAI/calendarAI.jsp" />
</div>

<div id="approvalChatWrapper" class="chat-wrapper" style="display:none; position:fixed; bottom:140px; right:50px; z-index:10000;">
    <jsp:include page="chatAI/approvalAI.jsp" />
</div>

<!-- ============ 채팅 jsp include 끝 ============ -->

<script>
    let sseSource = null;
    let RequestId = null;
    let currentBotType = "";

    function toggleMenu() {
        const wrapper = document.getElementById('menuWrapper');
        wrapper.classList.toggle('active');
    }

    // 채팅방 드래그 하기 시작 =============================================================================================

    // 드래그 및 위치 저장 설정
    let draggingElement = null;
    let offsetX = 0;
    let offsetY = 0;

    function initDragEvents() {
        // 마우스 이동 시: 드래그 중인 요소가 있다면 위치 업데이트
        document.addEventListener('mousemove', (e) => {
            if (!draggingElement) return;

            // 브라우저 화면 밖으로 나가지 않게 계산
            draggingElement.style.left = (e.clientX - offsetX) + 'px';
            draggingElement.style.top = (e.clientY - offsetY) + 'px';
            draggingElement.style.right = 'auto'; // 기존 우측 정렬 해제
            draggingElement.style.bottom = 'auto'; // 기존 하단 정렬 해제
        });

        // 마우스 떼면: 드래그 종료
        document.addEventListener('mouseup', () => {
            if (draggingElement) {
                draggingElement.style.cursor = 'grab';
                draggingElement = null;
            }
        });
    }

    // wrapperId - 움직일 전체 wrapper ID / 채팅 jsp include하는 div
    // headerId  - 마우스로 잡을 부분 ID / 채팅 div의 id
    function makeDraggable(wrapperId, headerId) {
        const wrapper = document.getElementById(wrapperId);
        const header = document.getElementById(headerId);

        if (!wrapper || !header) return;

        header.style.cursor = 'grab';

        header.onmousedown = function(e) {
            // 버튼이나 닫기 아이콘 클릭 시에는 드래그 방지
            if (e.target.tagName === 'BUTTON' || e.target.closest('button')) return;

            draggingElement = wrapper;
            header.style.cursor = 'grabbing';

            const rect = wrapper.getBoundingClientRect();
            offsetX = e.clientX - rect.left;
            offsetY = e.clientY - rect.top;

            // 드래그 시 최상단으로 올리기
            document.querySelectorAll('.chat-wrapper').forEach(el => el.style.zIndex = '10000');
            wrapper.style.zIndex = '10005';

            // 텍스트 드래그 방지
            e.preventDefault();
        };
    }

    // 페이지 로드 시 이벤트 초기화
    window.addEventListener('DOMContentLoaded', () => {
        initDragEvents();
        // 프로젝트 채팅방 드래그 활성화
        makeDraggable('projectChatWrapper', 'projectChatHeader');
        makeDraggable('attendanceChatWrapper', 'attendanceChatHeader');
        makeDraggable('transChatWrapper', 'transChatHeader');
        makeDraggable('calendarChatWrapper', 'calendarChatHeader');
        makeDraggable('approvalChatWrapper', 'approvalChatHeader'); //전자결재 추가
    });

    // 채팅방 드래그 하기 끝 =============================================================================================


    // "토글/채팅방 열닫기" 시작 ==================================================================================================

    // 토글 열기
    function toggleMenu() {
        const wrapper = document.getElementById('menuWrapper');
        if (wrapper) wrapper.classList.toggle('active');
    }

    // 토글 버튼에 있는 채팅방 열기
    function openChat(type) {
        currentBotType = type; // 지금 내가 접속하는 봇 (2번 프로젝트면 => project)!

        if (!currentBotType) return;

        // 모든 창을 숨기고 선택한 창만 표시
        // document.querySelectorAll('.chat-wrapper').forEach(el => el.style.display = 'none');
        const targetWrapper = document.getElementById(type + 'ChatWrapper');

        if (targetWrapper) {
            targetWrapper.style.display = 'block';
            document.getElementById('menuWrapper').classList.remove('active');

            rearrangeChatWindows(); // 창이 열릴 때마다 위치를 계산해주는 함수
        }
    }

    // 해당 채팅 닫기 (해당 jsp는 onclick="closeChat('project')" 이렇게 줘야함!)
    function closeChat(type) {
        const targetWrapper = document.getElementById(type + 'ChatWrapper');
        if (targetWrapper) {
            targetWrapper.style.display = 'none';
        }
    }


    function rearrangeChatWindows() {
        // 공통 클래스인 .chat-window(또는 .chat-wrapper)를 모두 가져옵니다.
        // 여기서는 ID에 'ChatWrapper'가 들어가는 요소들 중 보이는 것만 골라냅니다.
        const allWrappers = Array.from(document.querySelectorAll('[id$="ChatWrapper"]'));
        const visibleWindows = allWrappers.filter(el => el.style.display !== 'none');

        const gap = 20;          // 창 사이의 간격 (px)
        const windowWidth = 500; // JSP에 설정된 창 너비 (px)
        const startRight = 30;   // 첫 번째 창이 위치할 오른쪽 여백

        visibleWindows.forEach((win, index) => {
            // 오른쪽 끝에서부터 순서대로 (창 너비 + 간격)만큼 왼쪽으로 배치
            const rightPosition = startRight + (index * (windowWidth + gap));
            win.style.position = 'fixed';
            win.style.bottom = '90px'; // 하단 높이 고정
            win.style.right = rightPosition + 'px';
            win.style.zIndex = 10000 + index; // 뒤에 열린 게 위로 오도록
        });
    }

    // "토글/채팅방 열닫기" 끝 ==================================================================================================

    let currentSource = null;

    // 전송 함수
    function handleProjectSend(sendbottype) {

        console.log("handleSendMessage", sendbottype);

        let text = "";
        let msgArea = "";

        if(sendbottype === "project") {
            const input = document.getElementById('projectInput');   // 이건 include된 채팅방 jsp의 사용자 입력한 내용 !
            msgArea = document.getElementById('projectMessages');  // 이건 include된 채팅방 jsp의 채팅내용을 띄우는 div영역
            text = input.value.trim(); // 공백제거
            input.value = '';   // 전송 시 입력한 내용 비우기

        } else if(sendbottype === "attendance") {
            const input = document.getElementById('attendanceInput');   // 이건 include된 채팅방 jsp의 사용자 입력한 내용 !
            msgArea = document.getElementById('attendanceMessages');  // 이건 include된 채팅방 jsp의 채팅내용을 띄우는 div영역
            text = input.value.trim(); // 공백제거
            input.value = '';   // 전송 시 입력한 내용 비우기
        }  else if(sendbottype === "trans") {
            const input = document.getElementById('transInput');   // 이건 include된 채팅방 jsp의 사용자 입력한 내용 !
            msgArea = document.getElementById('transMessages');  // 이건 include된 채팅방 jsp의 채팅내용을 띄우는 div영역
            text =getSelectedValue();
            text += ":::SEP:::"+input.value.trim(); // 공백제거
            console.log("번역봇을 확인합니다", text);
            input.value = '';   // 전송 시 입력한 내용 비우기

        } else if (sendbottype === "calendar") {
            const input = document.getElementById('calendarInput');
            msgArea = document.getElementById('calendarMessages');
            text = input.value.trim();
            input.value = '';
        }

         else if (sendbottype === "approval") { //전자결재 추가
            const input = document.getElementById('approvalInput');
            msgArea = document.getElementById('approvalMessages');
            text = input.value.trim();
            input.value = '';
        }

        if (!text) return;  // 사용자가 입력한 내용이 없을 시에

        // 사용자 메시지 표시
        appendMessage(text, 'user', sendbottype);  // 사용자가 입력한 내용을 추가


        // 만약 기존에 연결된 SSE가 있다면 ? 끊기
        if (currentSource) {
            currentSource.close();
            currentSource = null;
        }

        // 중지버튼을 위해 만들 임의 ID (UUID 같은 느낌)
        RequestId = 'req-' + Date.now();

        // AI 답변 공간 생성
        const aiSpan = appendMessage('답변중 ...', 'ai', sendbottype);
        aiSpan.innerHTML = `<div class="spinner-border spinner-border-sm" role="status"></div>`;

        let url = "/api/chat/stream?message=" + encodeURIComponent(text)
          + "&requestId=" +  RequestId
          + "&botType=" + sendbottype;

        // SSE(Server-Sent Events) 연결 => 서버가 클라이언트에게 일방적으로 소식을 ㅗ내는 라디오 방송 .. 같은 기술! = 실시간으로 쏘기
        currentSource = new EventSource(url);

        let full = "";  // 줄바꿈을 위한

        currentSource.onmessage = (e) => {
            console.log("머지", e.data);
            if (e.data === "[DONE]") {
                console.log("종료");
                currentSource.close();  // 서버에서 온 메시지가 없으면 라디오 방송을 끊기 .. 같은?
                currentSource = null;

                backbtn(sendbottype);

                return;
            }
            full += e.data;

            aiSpan.innerHTML = full;  // 메시지 추가

          //  aiSpan.innerHTML += e.data;  // 메시지 추가
            msgArea.scrollTop = msgArea.scrollHeight;  // 스크롤 제일 아래로 !
        };

        currentSource.onerror = () => {
            if (currentSource) currentSource.close();
        };
    }

    // 버튼 복구 함수 (ai가 답변을 다 했을 시에 중지 => 전송 아이콘으로)
    function backbtn (sendbottype) {
        console.log("어떤 버튼?", sendbottype);

        let sendBtn = "";   // 전송 아이콘 btn 담기
        let stopBtn = "";   // 중지 아이콘 btn 담기

        if (sendbottype === "project") {
            sendBtn = document.getElementById('projectSendBtn');
            stopBtn = document.getElementById('projectStopBtn');
        }
        else if(sendbottype === "attendance") {
            sendBtn = document.getElementById('attendancesendBtn');
            stopBtn = document.getElementById('attendancestopBtn');
        }
        else if(sendbottype === "trans") {
            sendBtn = document.getElementById('transSendBtn');
            stopBtn = document.getElementById('transStopBtn');
        }
        else if(sendbottype === "calendar") {
            sendBtn = document.getElementById('calendarSendBtn');
            stopBtn = document.getElementById('calendarStopBtn');
        }

        else if(sendbottype === "approval") { //전자결재 추가
            sendBtn = document.getElementById('approvalSendBtn');
            stopBtn = document.getElementById('approvalStopBtn');
        }


        if(sendBtn && stopBtn) {
            stopBtn.style.setProperty('display', 'none', 'important');
            sendBtn.style.setProperty('display', 'flex', 'important');
        }
    }

    // 중지 함수
    function handleProjectStop() {
        if (currentSource) {
            currentSource.close();
            currentSource = null;
        }
        if (RequestId) {
            fetch(`/api/chat/stop?requestId=${RequestId}`, { method: 'POST' });
        }
    }

    // =============================================================================================================

    // 메시지 추가하는 함수
    function appendMessage(content, type, botType) {
        let msgArea = ""; // 메시지 영역
        let result = content;
            if(botType === "project") {
                msgArea = document.getElementById('projectMessages');
            } else if(botType === "attendance") {
                msgArea = document.getElementById('attendanceMessages');
            }else if(botType === "trans") {
                msgArea = document.getElementById('transMessages');
                result = content.split(":::SEP:::").at(-1);
            } else if(botType === "calendar") {
                msgArea = document.getElementById('calendarMessages');
            } else if(botType === "approval") { //전자결재 추가
                msgArea = document.getElementById('approvalMessages');
            }

            const div = document.createElement('div');
            div.className = type === 'user' ? 'msg-user' : 'msg-ai';

            const span = document.createElement('span');
        // 1. 넘치면 아래로 내리는 핵심 속성
        span.style.wordBreak = "break-all";
        span.style.overflowWrap = "break-word";

// 2. 중요! span이 너비를 가질 수 있게 inline-block으로 변경
        span.style.display = "inline-block";
        span.style.maxWidth = "100%"; // 부모 영역을 절대 안 넘게

// 3. 줄바꿈/띄어쓰기 유지
        span.style.whiteSpace = "pre-wrap";
            span.innerHTML = result;
            div.appendChild(span);
            msgArea.appendChild(div);
            msgArea.scrollTop = msgArea.scrollHeight;
        return span;
    }
</script>

</body>
</html>
