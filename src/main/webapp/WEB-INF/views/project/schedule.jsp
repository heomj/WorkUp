<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@400;500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<style>
    :root {
        --color-high: #d32f2f;   --bg-high: #ffebee;
        --color-normal: #ef6c00; --bg-normal: #fff3e0;
        --color-low: #1976d2;    --bg-low: #e3f2fd;
        --color-done: #2e7d32;   --bg-done: #e8f5e9;
        --tudio-border: #e9ecef;
    }
    
    .container-tudio { 
        display: flex; 
        flex-direction: row-reverse; 
        gap: 15px; 
        max-width: 100%; 
        margin: 0; 
        height: calc(100vh - 20px); 
    }

    .filter-aside { width: 300px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px; overflow-y: auto; }
    .filter-card { background: #fff; border-radius: 12px; border: 1px solid var(--tudio-border); padding: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
    
    .calendar-main { 
        flex-grow: 1; 
        background: #fff; 
        border-radius: 12px; 
        border: 1px solid var(--tudio-border); 
        padding: 15px; 
        display: flex;
        flex-direction: column;
    }

    #calendar { flex-grow: 1; height: 100% !important; }

    /* 중요도 가이드 태그 */
    .importance-tag { width: 45px; height: 22px; border-radius: 6px; display: inline-block; border: 1.5px solid; }
    .tag-high { background-color: var(--bg-high); border-color: #ffcdd2; }
    .tag-normal { background-color: var(--bg-normal); border-color: #ffe0b2; }
    .tag-low { background-color: var(--bg-low); border-color: #bbdefb; }
    .tag-done { background-color: var(--bg-done); border-color: #c8e6c9; position: relative; }
    .tag-done::after {
        content: ""; position: absolute; top: 50%; left: 10%; width: 80%; height: 2px;
        background-color: #ff3b3b; transform: translateY(-50%);
    }

    /* 캘린더 이벤트 스타일 */
    .fc-daygrid-event { border: none !important; padding: 2px 5px !important; margin-bottom: 2px !important; border-radius: 4px !important; }
    .event-high { background-color: var(--bg-high) !important; border-left: 4px solid var(--color-high) !important; }
    .event-high .fc-event-title { color: var(--color-high) !important; font-weight: 600; }
    .event-normal { background-color: var(--bg-normal) !important; border-left: 4px solid var(--color-normal) !important; }
    .event-normal .fc-event-title { color: var(--color-normal) !important; }
    .event-low { background-color: var(--bg-low) !important; border-left: 4px solid var(--color-low) !important; }
    .event-low .fc-event-title { color: var(--color-low) !important; }
    .event-done { background-color: var(--bg-done) !important; border-left: 4px solid var(--color-done) !important; }
    .event-done .fc-event-title { color: var(--color-done) !important; text-decoration: line-through !important; text-decoration-color: #ff3b3b !important; }

    /* 모달 스타일 커스텀 */
    .assignee-badge {
        display: inline-flex;
        align-items: center;
        background: #f1f3ff;
        border-radius: 20px;
        padding: 4px 12px;
        border: 1px solid #e0e4ff;
        margin-right: 5px;
        margin-bottom: 5px;
    }
</style>

<div class="container-tudio">
    <aside class="filter-aside">
        <div class="filter-card">
            <h6 class="fw-bold mb-3">중요도</h6>
            <div class="d-flex align-items-center justify-content-between mb-2"><span>높음</span><div class="importance-tag tag-high"></div></div>
            <div class="d-flex align-items-center justify-content-between mb-2"><span>보통</span><div class="importance-tag tag-normal"></div></div>
            <div class="d-flex align-items-center justify-content-between mb-2"><span>낮음</span><div class="importance-tag tag-low"></div></div>
            <div class="d-flex align-items-center justify-content-between"><span>완료</span><div class="importance-tag tag-done"></div></div>
        </div>
        <div class="filter-card">
		    <h6 class="fw-bold mb-3">일감 참여자</h6>
		
		    <div class="form-check mb-3">
		        <input class="form-check-input" type="checkbox" id="filter-done" checked>
		        <label class="form-check-label fw-bold" for="filter-done" style="cursor:pointer;">완료된 일감 보기</label>
		    </div>
		
		    <div id="participant-filters"></div>
		
		    <hr>
		
		    <button id="btn-toggle-all" class="btn btn-outline-secondary btn-sm w-100 mb-2 fw-bold" onclick="toggleAllParticipants()">
		        참여자 전체 해제
		    </button>
		</div>
    </aside>

    <main class="calendar-main">
        <div id="calendar"></div>
    </main>
</div>

<div class="modal fade" id="detailMdal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 20px; padding: 30px;">
            <div class="modal-header d-flex justify-content-between align-items-start border-0 p-0 mb-4">
                <h3 class="fw-bold mb-0" id="detailTitle" style="color: #4a5568; letter-spacing: -0.5px;">제목</h3>
                <span id="detailImpt" class="badge" style="padding: 6px 12px; font-size: 0.85rem; border-radius: 8px;">중요도</span>
            </div>
            <div class="modal-body p-0">
                <div class="mb-4">
                    <p class="text-muted fw-bold small mb-2">상세 내용</p>
                    <div id="detailContent" style="background:#f8f9fa; border-radius:12px; padding:20px; min-height:100px; color:#4e5968; border: 1px solid #edf2f7;"></div>
                </div>
                <div class="row g-4 mb-4">
                    <div class="col-7">
                        <p class="text-muted fw-bold small mb-2">담당자</p>
                        <div id="detailAssigneeArea" class="d-flex flex-wrap">
                            </div>
                    </div>
                    <div class="col-5">
                        <p class="text-muted fw-bold small mb-2">진행 상태</p>
                        <strong id="detailStatus" style="font-size:1.2rem; color: #6366f1;"></strong>
                    </div>
                </div>
                <hr style="border-top: 1px solid #edf2f7; margin: 25px 0;">
                <div class="row g-4">
                    <div class="col-7">
                        <p class="text-muted fw-bold small mb-2">예상 일감 기간</p>
                        <strong id="detailPeriod" style="color:#718096; font-size: 0.95rem; font-weight: 500;"></strong>
                    </div>
                    <div class="col-5">
                        <p class="text-muted fw-bold small mb-2">진행률</p>
                        <strong id="detailProgress" style="font-size:1.2rem; color: #6366f1;">0%</strong>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 p-0 mt-4">
                <button class="btn btn-primary ms-auto py-2 fw-bold" data-bs-dismiss="modal" 
                        style="background:#707cff; border:none; border-radius:10px; width: 100px; height: 45px;">닫기</button>
            </div>
        </div>
    </div>
</div>

<script>
let serverProjNo = window.projNo || '${projNo}';
if(!serverProjNo || serverProjNo === '0') {
    const urlParams = new URLSearchParams(window.location.search);
    serverProjNo = urlParams.get('projNo') || "305305"; 
}
const loginEmpId = '<sec:authentication property="principal.username"/>';

window.scheduleCalendar = null;
window.rawEvents = [];

window.initScheduleCalendar = function() {
    const calendarEl = document.getElementById('calendar');
    window.scheduleCalendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        locale: 'ko',
        headerToolbar: { left: 'prev,next today', center: 'title', right: 'dayGridMonth,listMonth' },
        buttonText: { month: '월', list: '목록' },
        height: 'parent',
        eventClick: function(info) {
            const p = info.event.extendedProps;
            
            // 1. 기본 텍스트 정보 채우기
            document.getElementById('detailTitle').innerText = info.event.title.replace(/⭐ |\[.*?\] /g, "");
            document.getElementById('detailContent').innerText = p.content || '내용 없음';
            document.getElementById('detailStatus').innerText = p.status || '상태 없음';
            document.getElementById('detailPeriod').innerText = p.period || '-';
            document.getElementById('detailProgress').innerText = (p.progress || 0) + '%';

            // 2. 담당자 영역을 이미지처럼 배지 스타일로 변경
            const assigneeArea = document.getElementById('detailAssigneeArea');
            assigneeArea.innerHTML = '';
            const names = (p.assignees && p.assignees.length > 0) ? p.assignees : ['미지정'];
            names.forEach(name => {
                const badge = document.createElement('div');
                badge.className = 'assignee-badge';
                badge.innerHTML = `<span class="material-icons-outlined me-1" style="font-size:16px; color:#6366f1;">person</span>
                                   <span style="font-size:0.9rem; font-weight:600; color:#4a5568;">\${name.trim()}</span>`;
                assigneeArea.appendChild(badge);
            });

            // 3. 중요도 배지 로직 (기존 로직 유지)
            const imptBadge = document.getElementById('detailImpt');
            if (p.status === '완료') {
                imptBadge.innerText = '완료';
                imptBadge.style.backgroundColor = "var(--bg-done)";
                imptBadge.style.color = "var(--color-done)";
                imptBadge.style.textDecoration = "line-through";
            } else {
                imptBadge.innerText = p.importance;
                imptBadge.style.textDecoration = "none";
                const imptColorMap = { '높음': 'high', '낮음': 'low', '보통': 'normal' };
                const type = imptColorMap[p.importance] || 'normal';
                imptBadge.style.backgroundColor = `var(--bg-\${type})`;
                imptBadge.style.color = `var(--color-\${type})`;
            }

            // 4. 상태 및 진행률 텍스트 색상 강조
            const statusColor = (p.status === '완료') ? "var(--color-done)" : "#6366f1";
            document.getElementById('detailStatus').style.color = statusColor;
            document.getElementById('detailProgress').style.color = statusColor;

            bootstrap.Modal.getOrCreateInstance(document.getElementById('detailMdal')).show();
        }
    });
    window.scheduleCalendar.render();
    window.loadScheduleData(serverProjNo);
};

window.loadScheduleData = function(pNo) {
    axios.get('/schedule/list', { params: { projNo: pNo } }).then(function(res) {
        const eventList = res.data.events || [];
        const participantList = res.data.participants || [];
        
        window.rawEvents = eventList.map(item => {
        	// [수정] 리스트 데이터에서 이름만 뽑아서 배열로 만듭니다.
            let names = [];
            
            // 1. 참여자 리스트가 있고 비어있지 않은 경우
            if (item.taskParticipantVOList && item.taskParticipantVOList.length > 0) {
                names = item.taskParticipantVOList.map(p => p.empNm);
            } 
            // 2. 혹시 몰라 기존 empNm이나 taskNm도 체크 (백업)
            else if (item.empNm || item.taskNm) {
                let rawName = (item.empNm || item.taskNm).trim();
                names = rawName.split(',').map(n => n.trim());
            } 
            // 3. 둘 다 없으면 미지정
            else {
                names = ["미지정"];
            }
            
            // 2. 캘린더 제목용 이름 설정 (여러 명일 경우 "홍길동 외 N명")
            let displayTitleName = names.length > 1 ? `\${names[0]} 외 \${names.length - 1}명` : names[0];
            
            let status = (item.taskStts || "대기");
            let impt = (item.taskImpt || "보통");
            
            // 상태 및 중요도에 따른 CSS 클래스 결정
            let className = (status === '완료') ? 'event-done' : (impt === '높음' ? 'event-high' : (impt === '낮음' ? 'event-low' : 'event-normal'));
            
            // 날짜 포맷팅 함수
            const fixDate = (d) => d ? String(d).split('T')[0].split(' ')[0].replace(/\//g, '-') : null;
            let start = fixDate(item.taskBgngDt);
            let end = fixDate(item.taskEndDt);
            
            return {
            	id: String(item.taskNo),
                title: (String(item.empId) === loginEmpId ? "⭐ " : "") + "[" + displayTitleName + "] " + (item.taskTtl || "제목없음"),
                start: start,
                // 종료일이 있을 경우 FullCalendar의 특성상 하루를 더해줘야 기간이 정확히 표시됩니다.
                end: end ? new Date(new Date(end).getTime() + 86400000).toISOString().split('T')[0] : start,
                allDay: true,
                className: className,
                extendedProps: { 
                    assignees: names, // 중요: 필터링을 위해 배열 형태로 저장
                    content: item.taskCn || "", 
                    status: status, 
                    importance: impt,
                    progress: item.taskPrgrt || 0,
                    period: start + " ~ " + (end || start)
                }
            };
        }).filter(e => e.start !== null);
        
        renderSidebar(participantList);
        window.applyFilters();
    });
};

function renderSidebar(pList) {
    const container = document.getElementById('participant-filters');
    let html = '';
    pList.forEach(emp => {
        let name = (emp.empNm || emp).trim();
        let position = emp.empJbgd || "사원";
        html += `<div class="form-check mb-2">
                    <input class="form-check-input p-filter" type="checkbox" 
                           value="\${name}" id="chk_\${name}" checked onchange="applyFilters()">
                    <label class="form-check-label" for="chk_\${name}" style="cursor:pointer; font-size: 0.9rem;">
                        \${name} <span class="text-muted small">\${position}</span>
                    </label>
                 </div>`;
    });
    container.innerHTML = html;
}

function toggleAllParticipants() {
    const btn = document.getElementById('btn-toggle-all');
    const checkboxes = document.querySelectorAll('.p-filter');
    const isAllChecked = Array.from(checkboxes).every(chk => chk.checked);

    checkboxes.forEach(chk => {
        chk.checked = !isAllChecked;
    });

    btn.innerText = isAllChecked ? '참여자 전체 선택' : '참여자 전체 해제';
    window.applyFilters();
}

window.applyFilters = function() {
    // [추가] 완료 여부 체크 상태 가져오기
    const showDone = document.getElementById('filter-done')?.checked;
    
    // 1. 현재 사이드바에서 체크된 사람들의 이름 목록 (배열)
    const checkedNames = Array.from(document.querySelectorAll('.p-filter:checked'))
                              .map(el => el.value);
    
    // 버튼 텍스트 제어 로직 (기존 기능 유지)
    const btn = document.getElementById('btn-toggle-all');
    if (btn) {
        const checkboxes = document.querySelectorAll('.p-filter');
        const anyChecked = Array.from(checkboxes).some(chk => chk.checked);
        btn.innerText = anyChecked ? '참여자 전체 해제' : '참여자 전체 선택';
    }

    // 2. 필터링 핵심 로직
    const filtered = window.rawEvents.filter(ev => {
        // [수정 포인트] 일감 참여자(assignees 배열) 중 한 명이라도 체크된 명단에 있는지 확인
        const hasTargetAssignee = ev.extendedProps.assignees.some(name => 
            checkedNames.includes(name)
        );

        // 완료된 일감 표시 여부 확인
        const statusMatch = showDone ? true : (ev.extendedProps.status !== '완료');
        
        return hasTargetAssignee && statusMatch;
    });

    // 3. 캘린더에 필터링된 결과 반영
    window.scheduleCalendar.removeAllEvents();
    window.scheduleCalendar.addEventSource(filtered); 
};

document.addEventListener('DOMContentLoaded', () => {
    const doneChk = document.getElementById('filter-done');
    if(doneChk) doneChk.addEventListener('change', window.applyFilters);
    setTimeout(window.initScheduleCalendar, 300);
});
</script>