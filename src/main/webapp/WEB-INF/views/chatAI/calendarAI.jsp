<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<style>
    /* 기본 패널 */
    .calendar-panel {
        background: #ffffff;
        border: 2px solid #F5A4B7;
        width: 500px !important;
        height: 650px !important;
        display: flex;
        flex-direction: column;
        z-index: 10001;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        border-radius: 12px;
        overflow: hidden;
    }

    /* 헤더 */
    .calendar-bg {
        background: #F5A4B7 !important;
        padding: 12px 15px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: grab;
        user-select: none;
        color: white !important;
    }

    /* 메시지 영역 */
    .calendar-msg-container {
        flex: 1;
        padding: 15px;
        overflow-y: auto;
        background: #fcf8f9;
    }

    /* 채팅 디자인 */
    .calendar-panel .msg-user { text-align: right; margin-bottom: 10px; }
    .calendar-panel .msg-user span {
        background: #F5A4B7;
        color: white;
        padding: 8px 12px;
        border-radius: 15px 15px 0 15px;
        display: inline-block;
    }

    .calendar-panel .msg-ai { text-align: left; margin-bottom: 15px; }
    .calendar-panel .msg-ai span {
        background: white;
        border: 1px solid #e0e0e0;
        padding: 15px;
        border-radius: 15px 15px 15px 0;
        display: inline-block;
        max-width: 85%;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }

    /* 입력창 */
    .calendar-input-group {
        display: flex !important;
        align-items: center;
        gap: 5px;
        padding: 5px 10px;
        border: 1px solid #eee;
        border-radius: 10px;
        margin: 5px;
    }
    #calendarInput { flex: 1; min-width: 0; }
    #calendarInput::placeholder { font-size: 0.8rem; font-weight: 300; color: #a0a0a0; }

    .button-group { display: flex; align-items: center; flex-shrink: 0; gap: 4px; }

    #calendarSendBtn {
        width: 40px; height: 40px; border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        background-color: #F5A4B7 !important; border-color: #F5A4B7 !important;
    }
    #calendarStopBtn {
        display: none; width: 40px; height: 40px;
        text-decoration: none; align-items: center; justify-content: center;
    }

    .calendar-panel .CAL-direct-input-notice {
        margin-top: 12px;
        padding-top: 10px;
        border-top: 1px dashed #ffeef1;
        font-size: 0.8rem;
        color: #F5A4B7;
        text-align: center;
        line-height: 1.4;
    }
</style>

<div class="chat-window calendar-panel" id="calendarChatWindow">
    <div class="chat-header calendar-bg" id="calendarChatHeader">
        <div class="d-flex align-items-center" style="pointer-events: none;">
            <img src="${pageContext.request.contextPath}/images/icon2.png" alt="logo" style="width: 35px; height: 30px; margin-right: 10px;">
            <strong>CALENDAR AI</strong>
        </div>
        <button type="button" class="btn-close btn-close-white" onclick="closeChat('calendar')"></button>
    </div>

    <div id="calendarMessages" class="calendar-msg-container">
        <div class="msg-ai">
            <span>
                <div class="ai-greeting">
                    <div class="ai-title">안녕하세요!</div>
                    <div class="ai-subtitle">WORKUP 일정 관리 비서입니다.</div>

                    <div class="ai-question" style="margin-top: 15px; font-size: 0.85rem; color: #888;">
                         자주 묻는 질문
                    </div>

                    <div class="quick-buttons">
                        <button class="quick-btn" onclick="clickSearchSchedule()">🔍 일정 검색하기</button>
                        <button class="quick-btn" onclick="clickAddSchedule()">📅 일정 추가하기</button>
                    </div>

                    <div class="CAL-direct-input-notice" style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed #ffeef1; font-size: 0.8rem; color: #F5A4B7;">
                        그 외에 궁금하신 내용은 아래에 <br> <strong>직접 채팅</strong>으로 물어봐 주세요!
                    </div>
                </div>
            </span>
        </div>
    </div>

    <div class="chat-input border-top bg-white p-2">
        <div class="calendar-input-group">
            <input id="calendarInput" class="form-control border-0 shadow-none" placeholder="일정을 물어보세요..." />
            <div class="button-group">
                <button id="calendarStopBtn" class="btn btn-link text-danger p-1" title="중지">
                    <i class="bi bi-stop-circle" style="font-size: 1.2rem;"></i>
                </button>
                <button id="calendarSendBtn" class="btn btn-primary">
                    <i class="bi bi-send-fill"></i>
                </button>
            </div>
        </div>
    </div>
</div>



<script>
(() => {
    let calendarEventSource = null;
    let calRequestId = null;

    const calendarInput = document.getElementById('calendarInput');
    const calendarSendBtn = document.getElementById('calendarSendBtn');
    const calendarStopBtn = document.getElementById('calendarStopBtn');
    const calendarMessages = document.getElementById('calendarMessages');
    const calendarChatWindow = document.getElementById('calendarChatWindow');


    const closeCalStream = () => {
        if (calendarEventSource) {
            calendarEventSource.close();
            calendarEventSource = null;
        }
    };

    const appendMessage = (text, sender, type) => {
        const msgDiv = document.createElement('div');
        msgDiv.className = sender === 'user' ? 'msg-user' : 'msg-ai';
        const span = document.createElement('span');
        span.innerHTML = text;
        msgDiv.appendChild(span);
        calendarMessages.appendChild(msgDiv);
        calendarMessages.scrollTop = calendarMessages.scrollHeight;
        return span;
    };


    window.searchScheduleInDb = (keyword) => {
        $.ajax({
            url: '/calendar/list',
            type: 'GET',
            data: { keyword: keyword },
            success: function(allList) {
                // 키워드 정규화 (예: '3월' -> '03', '2026년 3월' -> '2026-03')
                let normalizedKey = keyword.replace(/년\s*/g, '-').replace(/월/g, '').trim();
                if(normalizedKey.length === 1) normalizedKey = '0' + normalizedKey;     // '3' -> '03'

                const filteredList = allList.filter(item => {
                    const titleMatch = item.calTtl.includes(keyword);

                    // 날짜 비교 로직 (시작일 ~ 종료일 범위 포함 여부)
                    const searchDate = keyword.match(/\d{4}-\d{2}-\d{2}/) ? keyword : null;
                    let rangeMatch = false;

                    if (searchDate) {
                        // 특정 날짜 검색 시: 시작일 <= 검색일 <= 종료일
                        rangeMatch = (item.calBgngDt <= searchDate && item.calEndDt >= searchDate);
                    } else {
                        // '3월' 같은 월 검색이나 단순 포함 검색
                        rangeMatch = item.calBgngDt.includes(normalizedKey) ||
                                     item.calEndDt.includes(normalizedKey);
                    }

                    return titleMatch || rangeMatch;
                });

                if(filteredList.length > 0) {
                    let listHtml = `<div class="ai-greeting"><div class="ai-question">검색된 일정입니다:</div><ul ...>`;
                    filteredList.forEach(item => {
                        listHtml += `<li><b>\${item.calTtl}</b> (\${item.calBgngDt})</li>`;
                    });
                    listHtml += `</ul></div>`;
                    appendMessage(listHtml, "ai", "calendar");
                } else {
                    appendMessage("🔍 해당 조건으로 검색된 일정이 없습니다.", "ai", "calendar");
                }
            },
            error: function() {
                appendMessage("❌ 일정 조회 중 오류가 발생했습니다.", "ai", "calendar");
            }
        });
    };


    window.saveScheduleToDb = (data) => {
        data.empId = 0;

        if (data.calTtl) {
            data.calTtl = data.calTtl.replace(/&nbsp;/g, ' ').trim();
        }

        // 기본값 및 고정값 강제 할당
        data.calEndDt = data.calEndDt || data.calBgngDt;    // 종료일 없으면 시작일과 동일하게
        data.calColor = "#8e91ff";
        data.calImportant = "N";
        data.calStts = "Y";
        data.calShare = "N";
        data.calHolidayYn = "N";

        if (data.calBgngTm === "null" || !data.calBgngTm) data.calBgngTm = null;
        if (data.calEndTm === "null" || !data.calEndTm) data.calEndTm = null;

        $.ajax({
            url: '/calendar/addScheduleAi',
            type: 'POST',
            data: JSON.stringify(data),
            contentType: 'application/json; charset=utf-8',
            success: function(res) {
                if(res.result === "SUCCESS") {
                    appendMessage(`📅 일정이 성공적으로 등록되었습니다!`, "ai", "calendar");
                    setTimeout(showCalendarButtons, 600);
                } else {
                    appendMessage("❌ 일정 저장에 실패했습니다. 다시 시도해주세요.", "ai", "calendar");
                }
            },
            error: function(xhr) {
                console.error("에러 발생:", xhr);
            }
        });
    };


    window.handleCalendarSend = () => {
        const message = calendarInput.value.trim();
        if (!message) return;

        appendMessage(message, 'user', 'calendar');
        calendarInput.value = '';

        calendarSendBtn.style.setProperty('display', 'none', 'important');
        calendarStopBtn.style.setProperty('display', 'flex', 'important');

        closeCalStream();
        calRequestId = 'cal-' + Date.now();

        const aiSpan = appendMessage('<div class="spinner-border spinner-border-sm" role="status"></div>', 'ai', 'calendar');

        let fullText = "";
        let isSaveProcessed = false;   // 저장 처리 여부
        let isSearchProcessed = false; // 검색 처리 여부

        const url = `/api/chat/stream?message=\${encodeURIComponent(message)}&requestId=\${calRequestId}&botType=calendar`;
        calendarEventSource = new EventSource(url);


        calendarEventSource.onmessage = (e) => {
            if (e.data === "undefined") return;
            if (e.data === "[DONE]") {
                calendarStopBtn.style.display = 'none';
                calendarSendBtn.style.display = 'flex';
                closeCalStream();
                return;
            }

            fullText += e.data;

            let saveMatch = fullText.match(/\[SAVE_DATA:\s*(\{[\s\S]*?\})\s*\]/);

            // [일정 등록]
            if (!isSaveProcessed && fullText.includes("[SAVE_DATA:") && fullText.includes("]")) {
                let saveMatch = fullText.match(/\[SAVE_DATA:\s*(\{[\s\S]*?\})\s*\]/);

                if (saveMatch) {
                    try {
                        let rawJson = saveMatch[1].trim()
                            .replace(/\\/g, '')
                            .replace(/[\u201C\u201D]/g, '"');

                        const jsonData = JSON.parse(rawJson);
                        isSaveProcessed = true;

                        aiSpan.innerHTML = "📅 일정을 등록하는 중입니다...";
                        saveScheduleToDb(jsonData);

                        // 처리 완료 후 스트림 종료
                        setTimeout(closeCalStream, 100);
                        return;
                    } catch(err) {
                        console.warn("JSON 파싱 대기 중 혹은 에러:", err);
                    }
                }
            }

            // [일정 조회]
            let searchMatch = fullText.match(/\[SEARCH_DATA:\s*(.*?)\s*\]/);
            if (searchMatch) {
                isSearchProcessed = true;
                searchScheduleInDb(searchMatch[1]);
                setTimeout(closeCalStream, 100);
                return;
            }

            // 텍스트 출력 로직 (진행 중인 태그는 가리기)
            let displayText = fullText
                .replace(/\[SAVE_DATA:[\s\S]*?\]/g, '')
                .replace(/\[SEARCH_DATA:.*\]/g, '')
                .replace(/\[SAVE_DATA:[\s\S]*/g, '')
                .replace(/\[SEARCH_DATA:.*$/g, '');

            aiSpan.innerHTML = displayText;
            calendarMessages.scrollTop = calendarMessages.scrollHeight;
        };
    };

    window.showCalendarButtons = () => {
        const buttonHtml = `
            <div class="ai-greeting">
                <div class="ai-question" style="font-size: 0.85rem; color: #888;">원하시는 작업을 선택해주세요</div>
                <div class="quick-buttons">
                    <button class="quick-btn" onclick="clickAddSchedule()">📅 일정 추가</button>
                    <button class="quick-btn" onclick="clickSearchSchedule()">🔍 내 일정 검색</button>
                </div>
            </div>`;
        appendMessage(buttonHtml, 'ai', 'calendar');
    };

    window.initCalendarWindow = () => {
        if (calendarChatWindow) calendarChatWindow.style.display = 'flex';
        if (calendarMessages && calendarMessages.children.length === 0) {
            appendMessage(`
                <div class="ai-greeting">
                    <div class="ai-title">안녕하세요!</div>
                    <div class="ai-subtitle">일정 관리 비서입니다. 무엇을 도와드릴까요?</div>
                </div>`, 'ai', 'calendar');
            showCalendarButtons();
        }
    };

    window.clickAddSchedule = () => {
        appendMessage("📅 일정 추가하기를 선택했습니다.", 'user', 'calendar');
        setTimeout(() => {
            appendMessage("추가할 일정을 말씀해 주세요!<br>**'내일 오후 3시 대덕인재개발원에서 회의'** 처럼 말씀해주시면 제가 등록해 드립니다.", "ai", "calendar");
            calendarInput.focus();
        }, 400);
    };

    window.clickSearchSchedule = () => {
        appendMessage("🔍 일정 검색하기를 선택했습니다.", 'user', 'calendar');
        setTimeout(() => {
            appendMessage("조회하고 싶은 날짜나 내용을 말씀해 주세요!<br>'4월 7일 일정' 처럼 말씀해주세요!", "ai", "calendar");
            calendarInput.focus();
        }, 400);
    };

    calendarSendBtn.addEventListener('click', () => {
        if (typeof handleCalendarSend === 'function') {
            handleCalendarSend("calendar");
        }
    });

    calendarStopBtn.addEventListener('click', () => {
        closeCalStream();
        if (calRequestId) {
            fetch(`/api/chat/stop?requestId=\${calRequestId}`, { method: 'POST' });
        }
        calendarStopBtn.style.setProperty('display', 'none', 'important');
        calendarSendBtn.style.setProperty('display', 'flex', 'important');
    });

    calendarInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') handleCalendarSend();
    });
})();
</script>