<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="sec"
	uri="http://www.springframework.org/security/tags"%>

<sec:authentication property="principal.empVO.empId" var="loginEmpId" />

<link
	href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css"
	rel="stylesheet">
<script
	src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
/* 상단 헤더와의 겹침 방지 및 모달 위치 설정 */
.modal {
	z-index: 10050 !important;
}

.modal-backdrop {
	z-index: 10040 !important;
}

.swal2-container {
	z-index: 10100 !important;
}

#calendar {
	max-width: 100%;
	margin: 0 auto;
	background: white;
	border-radius: 12px;
	padding: 15px;
}

/* 캘린더 상단 툴바 여백 최적화 */
.fc-toolbar {
	margin-top: 5px !important;
	margin-bottom: 20px !important;
}

* {
	box-sizing: border-box;
}

.fc-daygrid-day {
	cursor: pointer;
}

.fc-daygrid-day:hover {
	background-color: rgba(105, 108, 255, 0.04) !important;
}

.fc-event {
	cursor: pointer;
	border: none !important;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	transition: all 0.2s ease;
}

.fc-daygrid-event {
	border-radius: 4px;
	margin-bottom: 2px !important;
	padding: 2px 6px !important;
}

.fc-timegrid-event-harness {
	padding: 0 3px !important;
}

.fc-timegrid-event {
	border-radius: 12px !important;
	border: none !important;
	opacity: 0.95;
}

.fc-v-event .fc-event-main {
	flex-direction: column;
	align-items: flex-start;
	gap: 2px;
}

.fc-event-main {
	display: flex;
	align-items: center;
	gap: 6px;
	color: #fff;
	font-weight: 500;
	overflow: hidden;
}

/* 대기 중인 예약에 대한 텍스트 색상 처리 */
.fc-event.waiting-event .fc-event-main {
	color: #4B5563 !important;
}

/* 🔥 반려된 예약에 대한 디자인 추가 (취소선 및 반투명) 🔥 */
.fc-event.rejected-event .fc-event-main {
	text-decoration: line-through;
	color: #ffebeb !important;
}
.fc-event.rejected-event {
	opacity: 0.8;
}

.event-emoji {
	font-size: 1.1rem;
}

.tooltip-inner {
	max-width: 350px;
	padding: 15px;
	background-color: rgba(33, 37, 41, 0.98);
	border-radius: 10px;
	font-size: 0.85rem;
	text-align: left;
	line-height: 1.6;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
	border: 1px solid rgba(255, 255, 255, 0.1);
}

.tooltip-header {
	font-weight: bold;
	font-size: 1rem;
	color: #666CFF;
	border-bottom: 1px solid rgba(255, 255, 255, 0.1);
	padding-bottom: 6px;
	margin-bottom: 8px;
}

.tooltip-row {
	display: flex;
	margin-bottom: 4px;
}

.tooltip-label {
	color: #b0b0b0;
	min-width: 70px;
	font-weight: 600;
}

.tooltip-value {
	color: #ffffff;
	flex: 1;
}

.room-block {
	border: 2px solid #e9ecef;
	border-radius: 12px;
	padding: 15px 8px;
	text-align: center;
	transition: all 0.2s ease;
	background: #fff;
	height: 100%;
	display: flex;
	flex-direction: column;
	justify-content: center;
	position: relative;
}

.room-block.available {
	cursor: pointer;
}

.room-block.available:hover {
	border-color: #b0b4ff;
	background-color: #f8f7ff;
	transform: translateY(-2px);
}

.room-block.selected {
	border-color: #666CFF;
	background-color: #f0f1ff;
	box-shadow: 0 4px 12px rgba(102, 108, 255, 0.15);
}

.room-block.unavailable {
	opacity: 0.6;
	background-color: #f8f9fa;
	cursor: not-allowed;
	pointer-events: none;
	border-color: #dee2e6;
}

.room-block.maintenance {
	border-color: #ffb4b4;
	background-color: #fff5f5;
	color: #ff4d4f;
	cursor: not-allowed;
	pointer-events: none;
}

.room-block-title {
	font-weight: bold;
	font-size: 1.05rem;
	margin-bottom: 4px;
	color: #333;
}

.room-block-desc {
	font-size: 0.8rem;
	color: #6c757d;
	line-height: 1.3;
}

.room-usage-time {
	font-size: 0.75rem;
	color: #ff4d4f;
	font-weight: bold;
	margin-top: 8px;
	background: #ffebeb;
	padding: 3px 6px;
	border-radius: 4px;
	display: inline-block;
}

.room-block.maintenance .room-block-title {
	color: #ff4d4f;
}

.btn-reserve-choice {
	transition: all 0.2s ease;
	border: 2px solid #f0f0f0;
	background: #fff;
	width: 100%;
	height: 90px;
}

.btn-reserve-choice:hover {
	border-color: #666CFF;
	background-color: #f8f7ff;
	transform: translateY(-3px);
}
</style>

<div class="container-fluid pb-4" style="margin-top: 5px;">
	<div class="row">
		<div class="col-12">
			<h3 class="fw-bold mt-0 mb-3 px-2">
				<span class="material-icons align-middle me-1 text-primary">event_available</span>
				통합 예약 현황 및 신청
			</h3>
			<div class="card shadow-sm border-0">
				<div class="card-body">
					<div id="calendar"></div>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="reserveChoiceModal" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered modal-sm">
		<div class="modal-content border-0 shadow-lg">
			<div class="modal-header border-bottom-0 pb-0">
				<h5 class="modal-title fw-bold" id="selectedDateTitle">일정 예약</h5>
				<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
			</div>
			<div class="modal-body text-center py-4">
				<div class="d-grid gap-3">
					<button type="button"
						class="btn btn-reserve-choice d-flex align-items-center justify-content-center"
						onclick="openStepTwo('ROOM')">
						<span class="material-icons text-primary me-2">meeting_room</span><span
							class="fw-bold">회의실 예약</span>
					</button>
					<button type="button"
						class="btn btn-reserve-choice d-flex align-items-center justify-content-center"
						onclick="openStepTwo('FIXT')">
						<span class="material-icons text-success me-2">inventory_2</span><span
							class="fw-bold">비품/자산 대여</span>
					</button>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="roomDetailModal" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered modal-lg">
		<div class="modal-content border-0 shadow">
			<div class="modal-header bg-light">
				<h5 class="modal-title fw-bold text-primary">🚪 회의실 예약 상세</h5>
				<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
			</div>
			<div class="modal-body p-4">
				<form id="roomForm">
					<div class="mb-4">
						<label class="form-label fw-bold">회의실 선택</label> <input
							type="hidden" id="rmNo" value="">
						<div id="roomGrid" class="row g-3"></div>
					</div>
					<div class="mb-3">
						<label class="form-label fw-bold">사용 목적</label> <input type="text"
							id="rmExpln" class="form-control" placeholder="목적을 입력하세요">
					</div>
					<div class="row">
						<div class="col-md-6 mb-3">
							<label class="form-label fw-bold">시작 일시</label> <input
								type="datetime-local" id="rmBgngDt" class="form-control"
								onchange="filterRooms()">
						</div>
						<div class="col-md-6 mb-3">
							<label class="form-label fw-bold">종료 일시</label> <input
								type="datetime-local" id="rmEndDt" class="form-control"
								onchange="filterRooms()">
						</div>
					</div>
					<div class="mb-3">
						<label class="form-label fw-bold">결재 승인자</label> <select
							id="roomAprvId" class="form-select"></select>
					</div>
				</form>
			</div>
			<div class="modal-footer d-flex justify-content-between">
				<button type="button" id="btnDeleteRoom" class="btn btn-danger d-none" onclick="deleteReservation('ROOM')">
					예약취소
				</button>
				<div>
					<button type="button" class="btn btn-outline-secondary"
						data-bs-dismiss="modal">닫기</button>
					<button type="button" id="btnInsertRoom"
						class="btn btn-primary px-4"
						onclick="saveReservation('ROOM', 'insert')">결재 요청</button>
					<button type="button" id="btnUpdateRoom"
						class="btn btn-info px-4 d-none text-white"
						onclick="saveReservation('ROOM', 'update')">수정 완료</button>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="fixtDetailModal" tabindex="-1">
	<div class="modal-dialog modal-dialog-centered modal-lg">
		<div class="modal-content border-0 shadow">
			<div class="modal-header bg-light">
				<h5 class="modal-title fw-bold text-success">💻 비품 및 자산 신청 상세</h5>
				<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
			</div>
			<div class="modal-body p-4">
				<form id="fixtForm">
					<div class="mb-4 p-3 rounded bg-light border">
						<div class="d-flex gap-4">
							<div class="form-check">
								<input class="form-check-input" type="radio" name="fixtType"
									id="typeRental" value="RENTAL" checked
									onchange="onFixtTypeChange()"> <label
									class="form-check-label fw-bold text-primary" for="typeRental">🔄
									비품 대여</label>
							</div>
							<div class="form-check">
								<input class="form-check-input" type="radio" name="fixtType"
									id="typeConsume" value="CONSUMABLE" onchange="onFixtTypeChange()">
								<label class="form-check-label fw-bold text-success"
									for="typeConsume">📦 소모품 신청</label>
							</div>
						</div>
					</div>
					
					<div class="mb-3">
						<div class="d-flex justify-content-between align-items-center mb-2">
							<label class="form-label fw-bold mb-0">비품/자산 선택</label>
							<select id="fixtCategoryFilter" class="form-select form-select-sm border-primary" style="width: auto; font-weight: bold;" onchange="filterFixtures()">
								<option value="ALL">전체 항목 보기</option>
							</select>
						</div>
						<input type="hidden" id="fixtNo" name="fixtNo" value="" />
						<div class="table-responsive mt-2">
							<table class="table table-bordered table-hover text-center align-middle" style="font-size: 0.9rem; table-layout: fixed;">
								<thead class="table-light">
									<tr>
										<th width="15%">분류</th>
										<th width="50%">항목명</th>
										<th width="20%">재고</th>
										<th width="15%">선택</th>
									</tr>
								</thead>
								<tbody id="fixtTbody">
									</tbody>
							</table>
						</div>
						<div id="fixtPagination" class="d-flex justify-content-center mt-3"></div>
					</div>
					
					<div class="mb-3">
						<label class="form-label fw-bold">사용 사유</label> <input type="text"
							id="fixtExpln" class="form-control" placeholder="사유를 입력하세요">
					</div>
					<div class="row">
						<div class="col-md-6 mb-3">
							<label class="form-label fw-bold">신청 일시</label> <input
								type="datetime-local" id="fixtBgngDt" class="form-control"
								onchange="filterFixtures()">
						</div>
						<div class="col-md-6 mb-3" id="fixtEndDtDiv">
							<label class="form-label fw-bold">반납 예정 일시</label> <input
								type="datetime-local" id="fixtEndDt" class="form-control"
								onchange="filterFixtures()">
						</div>
					</div>
					<div class="mb-3">
						<label class="form-label fw-bold">결재 승인자</label> <select
							id="fixtAprvId" class="form-select"></select>
					</div>
				</form>
			</div>
			<div class="modal-footer d-flex justify-content-between">
				<button type="button" id="btnDeleteFixt"
					class="btn btn-danger d-none" onclick="deleteReservation('FIXT')">삭제</button>
				<div>
					<button type="button" class="btn btn-outline-secondary"
						data-bs-dismiss="modal">닫기</button>
					<button type="button" id="btnInsertFixt"
						class="btn btn-success px-4"
						onclick="saveReservation('FIXT', 'insert')">결재 요청</button>
					<button type="button" id="btnUpdateFixt"
						class="btn btn-info px-4 d-none text-white"
						onclick="saveReservation('FIXT', 'update')">수정 완료</button>
				</div>
			</div>
		</div>
	</div>
</div>

<script>
let calendar, choiceModal, roomModal, fixtModal;
let selectedStartDt = "", selectedEndDt = "";
let currentResId = "", targetFixtNo = ""; 

window.allRooms = [];
window.allFixtures = [];
window.allReservations = [];

function getAssetIcon(type, cat, name) {
    if (type === 'ROOM') return '🚪';
    if (cat === '소모품') return '📝';
    if (name.includes('노트북')) return '💻';
    if (name.includes('빔') || name.includes('프로젝터')) return '📽️';
    if (name.includes('카메라')) return '📷';
    if (name.includes('태블릿')) return '📱';
    if (name.includes('웹캠')) return '📹';
    if (name.includes('모니터')) return '🖥';
    if (name.includes('스피커')) return '🔊';
    if (name.includes('배터리')) return '🔋';
    if (name.includes('마이크')) return '🎤';
    if (name.includes('포인터')) return '🪄';
    if (name.includes('보드')) return '⬜';
    if (name.includes('라이트')) return '⚪';
    if (name.includes('멀티탭')) return '🔌';
    if (name.includes('파쇄')) return '🗑️ ';
    return '📦';
}

function formatKrDate(date) {
    if (!date) return '없음';
    const d = new Date(date);
    return d.toLocaleString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'short', hour: '2-digit', minute: '2-digit', hour12: false });
}

function toDateTimeLocal(dateObj) {
    if (!dateObj) return "";
    if (typeof dateObj === 'string') dateObj = new Date(dateObj);
    const offset = dateObj.getTimezoneOffset() * 60000; 
    return new Date(dateObj.getTime() - offset).toISOString().slice(0, 16);
}

function formatShortDateTime(date) {
    if (!date) return '';
    const m = date.getMonth() + 1;
    const d = date.getDate();
    const time = date.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: false });
    return m + '/' + d + ' ' + time;
}

document.addEventListener('DOMContentLoaded', function() {
    choiceModal = new bootstrap.Modal(document.getElementById('reserveChoiceModal'));
    roomModal = new bootstrap.Modal(document.getElementById('roomDetailModal'));
    fixtModal = new bootstrap.Modal(document.getElementById('fixtDetailModal'));

    axios.get('/reserve/api/teamLeader/' + '${loginEmpId}').then(res => {
        const leader = res.data;
        const $roomAprv = $('#roomAprvId').empty();
        const $fixtAprv = $('#fixtAprvId').empty();
        
        if (leader && leader.empId) {
            const deptName = leader.deptNm ? leader.deptNm : '팀장';
            const optionHtml = '<option value="' + leader.empId + '" selected>[' + deptName + '] ' + leader.empNm + ' ' + leader.empJbgd + '</option>';
            $roomAprv.append(optionHtml).css('pointer-events', 'none').css('background-color', '#e9ecef');
            $fixtAprv.append(optionHtml).css('pointer-events', 'none').css('background-color', '#e9ecef');
        } else {
            const errorHtml = '<option value="" disabled selected>팀장 정보를 찾을 수 없습니다.</option>';
            $roomAprv.append(errorHtml);
            $fixtAprv.append(errorHtml);
        }
    }).catch(err => {
        console.error("팀장 정보 로드 실패:", err);
        $('#roomAprvId, #fixtAprvId').empty().append('<option value="" disabled selected>팀장 오류</option>');
    });

    const calendarEl = document.getElementById('calendar');
    calendar = new FullCalendar.Calendar(calendarEl, {
        locale: 'ko', height: 800, fixedWeekCount: false, showNonCurrentDates: false, nowIndicator: true, eventDisplay: 'block',
        selectable: true, selectMirror: true, unselectAuto: false,  eventDurationEditable: true,
        headerToolbar: { left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek' },
        views: { 
            timeGridWeek: { 
                dayHeaderFormat: { weekday: 'short', day: 'numeric' }, slotMinTime: '08:00:00', slotMaxTime: '22:00:00', 
                slotEventOverlap: false, expandRows: true, slotDuration: '00:30:00', 
                slotLabelFormat: { hour: 'numeric', minute: '2-digit', meridiem: 'short', hour12: true } 
            } 
        },
        titleFormat: { year: 'numeric', month: 'long' },
        
        eventContent: function(arg) { 
            const isWeekView = arg.view.type === 'timeGridWeek';
            const emoji = arg.event.extendedProps.emoji;
            const title = arg.event.title;
            if (isWeekView) {
                return { html: '<div class="fc-event-main d-flex justify-content-center align-items-center h-100 w-100"><span class="event-emoji" style="font-size: 1.6rem;">' + emoji + '</span></div>' };
            } else {
                return { html: '<div class="fc-event-main"><span class="event-emoji">' + emoji + '</span><span class="text-truncate">' + title + '</span></div>' };
            }
        },
        
        eventDidMount: function(info) {
            const props = info.event.extendedProps;
            
            const isConsumable = props.emoji === '📝' || 
                                 props.targetTitle.includes('용지') || 
                                 (props.expln && props.expln.includes('소모품'));
            
            // 🔥 툴팁에 결재 상태 명시적으로 추가 🔥
            let statusText = '<span style="color:#b0b0b0">승인 대기</span>';
            if (props.status === 'CONFIRMED' || props.status === '예약 확정') {
                statusText = '<span style="color:#28C76F; font-weight:bold;">승인 완료</span>';
            } else if (props.status === 'REJECTED' || props.status === '반려됨') {
                statusText = '<span style="color:#FF4D4F; font-weight:bold;">반려됨(기각)</span>';
            }

            let tooltipHtml = 
                '<div class="tooltip-header">' + props.targetTitle + '</div>' +
                '<div class="tooltip-row"><span class="tooltip-label">신청자</span><span class="tooltip-value">' + (props.empNm || '미상') + '</span></div>' +
                '<div class="tooltip-row"><span class="tooltip-label">결재상태</span><span class="tooltip-value">' + statusText + '</span></div>' +
                '<div class="tooltip-row"><span class="tooltip-label">사유</span><span class="tooltip-value">' + (props.expln || '사유 없음') + '</span></div>' +
                '<div class="tooltip-row"><span class="tooltip-label">시작</span><span class="tooltip-value">' + formatKrDate(info.event.start) + '</span></div>';
            
            if (!isConsumable) {
                tooltipHtml += '<div class="tooltip-row"><span class="tooltip-label">종료</span><span class="tooltip-value">' + formatKrDate(info.event.end) + '</span></div>';
            }
            
            new bootstrap.Tooltip(info.el, { 
                title: tooltipHtml, 
                html: true, 
                placement: 'top', 
                trigger: 'hover', 
                container: 'body' 
            });
        },
        
        select: function(info) {
            currentResId = "";
            let startObj = new Date(info.start);
            let endObj = new Date(info.end);

            if (info.view.type === 'dayGridMonth') {
                startObj.setHours(9, 0, 0); 
                endObj.setDate(endObj.getDate() - 1);
                endObj.setHours(18, 0, 0); 
            }

            selectedStartDt = toDateTimeLocal(startObj);
            selectedEndDt = toDateTimeLocal(endObj);

            const shortDate = startObj.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric' });
            document.getElementById('selectedDateTitle').innerText = shortDate + ' 예약 신청';
            choiceModal.show();
        },

        eventClick: function(info) {
            const props = info.event.extendedProps;
            if ('${loginEmpId}'.trim() !== String(props.empId || '').trim()) { Swal.fire('알림', '본인 예약만 관리할 수 있습니다.', 'info'); return; }
            currentResId = info.event.id; 
            
            let eStart = info.event.start;
            let eEnd = info.event.end || new Date(eStart.getTime() + 60 * 60 * 1000);

            if (props.type === 'ROOM') {
                axios.get('/reserve/api/rooms').then(res => {
                    window.allRooms = res.data; 
                    
                    $('#rmNo').val(props.refNo); $('#rmExpln').val(props.expln);
                    $('#rmBgngDt').val(toDateTimeLocal(eStart)); $('#rmEndDt').val(toDateTimeLocal(eEnd));
                    
                    filterRooms(); 
                    
                    $('#btnInsertRoom').addClass('d-none'); $('#btnUpdateRoom, #btnDeleteRoom').removeClass('d-none'); 
                    roomModal.show();
                });
            } else {
                axios.get('/reserve/api/fixts').then(res => {
                    window.allFixtures = res.data; 
                    
                    targetFixtNo = props.refNo; $('#fixtExpln').val(props.expln);
                    $('#fixtBgngDt').val(toDateTimeLocal(eStart)); $('#fixtEndDt').val(toDateTimeLocal(eEnd));
                    
                    if (props.expln && props.expln.includes('소모품')) { 
                        document.getElementById('typeConsume').checked = true;
                    } else {
                        document.getElementById('typeRental').checked = true;
                    }
                    
                    updateCategoryDropdown();
                    filterFixtures(); 
                    $('#btnInsertFixt').addClass('d-none'); $('#btnUpdateFixt, #btnDeleteFixt').removeClass('d-none'); 
                    fixtModal.show();
                });
            }
        },

        eventDrop: function(info) { handleEventMove(info); },
        eventResize: function(info) { handleEventMove(info); },

        events: function(info, successCallback, failureCallback) {
            axios.get('/reserve/api/all').then(res => {
                
                // 🔥 반려된 예약은 달력 렌더링에서 필터링하여 제외 (filter 사용) 🔥
                const validEvents = res.data.filter(e => {
                    const stts = String(e.STTS || e.stts || '').toUpperCase();
                    if(stts === 'REJECTED' || stts === '반려됨') return false; 
                    return true;
                }).map(e => {
                    const type = e.TYPE || e.type || '';
                    const isRoom = type.toUpperCase() === 'ROOM';
                    
                    const stts = String(e.STTS || e.stts || '').toUpperCase();
                    const isWaiting = (stts === 'WAITING' || stts === '승인 대기');
                    
                    const resId = e.RES_ID || e.resId || '';
                    const empNm = e.EMP_NM || e.empNm || '미상';
                    let title = e.TITLE || e.title || '';
                    let refNo = e.REF_NO || e.refNo || e.RM_NO || e.rmNo || e.FIXT_NO || e.fixtNo || '';
                    
                    if (!isRoom) {
                        if (!isNaN(title) && isNaN(refNo)) {
                            let temp = title;
                            title = refNo;
                            refNo = temp;
                        }
                    }

                    const startDt = e.START || e.start || '';
                    const endDt = e.END || e.end || '';
                    const expln = e.EXPLN || e.expln || '';
                    
                    let displayTitle = '';
                    if (isWaiting) {
                        displayTitle = '[대기] [' + empNm + '] ' + title;
                    } else {
                        displayTitle = '[' + empNm + '] ' + title;
                    }

                    let bgColor = isRoom ? '#666CFF' : '#28C76F'; 
                    if (isWaiting) bgColor = '#D1D5DB';

                    return {
                        id: resId,
                        title: displayTitle,
                        start: startDt, 
                        end: endDt,
                        backgroundColor: bgColor,
                        borderColor: 'transparent',
                        classNames: isWaiting ? ['waiting-event'] : [],
                        extendedProps: {
                            empNm: empNm,      
                            type: isRoom ? 'ROOM' : 'FIXTURE',
                            empId: e.EMP_ID || e.empId,
                            refNo: refNo,
                            aprvId: e.APRV_ID || e.aprvId, 
                            expln: expln,
                            targetTitle: title,
                            status: stts,
                            emoji: getAssetIcon(isRoom ? 'ROOM' : 'FIXT', '', title)
                        }
                    };
                });
                
                successCallback(validEvents);
            });
        }
    });
    calendar.render();
});

function handleEventMove(info) {
    const props = info.event.extendedProps;
    if ('${loginEmpId}'.trim() !== String(props.empId || '').trim()) {
        Swal.fire('권한 없음', '본인이 신청한 예약만 이동할 수 있습니다.', 'warning');
        info.revert(); return;
    }

    // 반려된 예약은 달력에 안 뜨므로 이 블록은 사실상 실행 안됨 (방어 코드)
    if (props.status === 'REJECTED' || props.status === '반려됨') {
        Swal.fire('수정 불가', '반려(기각) 처리된 예약은 수정할 수 없습니다.', 'error');
        info.revert(); return;
    }

    let startObj = info.event.start;
    let endObj = info.event.end;
    
    if (!endObj || startObj.getTime() === endObj.getTime()) {
        endObj = new Date(startObj);
        endObj.setHours(startObj.getHours() + 1); 
    }

    let reqData = { 
        empId: '${loginEmpId}', 
        resId: info.event.id, 
        bgngDt: toDateTimeLocal(startObj), 
        endDt: toDateTimeLocal(endObj) 
    };
    
    if (props.type === 'ROOM') { 
        reqData.rmNo = props.refNo; 
        reqData.expln = props.expln; 
        reqData.aprvId = $('#roomAprvId').val(); 
    } else { 
        reqData.fixtNo = props.refNo; 
        reqData.expln = props.expln; 
        reqData.aprvId = $('#fixtAprvId').val(); 
    }

    const url = '/reserve/api/update' + (props.type === 'ROOM' ? 'Room' : 'Fixt');
    axios.post(url, reqData).then(res => {
        if (res.data === 'overlap') { 
            Swal.fire('경고', '해당 시간대에 이미 다른 예약이 있습니다.', 'error'); 
            info.revert(); 
        } else { 
            Swal.fire({ toast: true, position: 'top-end', showConfirmButton: false, timer: 1500, icon: 'success', title: '예약 시간이 변경되었습니다.' }); 
            if(props.type === 'ROOM') filterRooms(); else filterFixtures(); 
        }
    }).catch(err => { 
        console.error("이동 에러:", err);
        Swal.fire('오류', '서버 통신 중 문제가 발생했습니다.', 'error'); 
        info.revert(); 
    });
}

function onFixtTypeChange() {
    updateCategoryDropdown();
    $('#fixtCategoryFilter').val('ALL'); // 탭 이동 시 필터 초기화
    filterFixtures();
}

function updateCategoryDropdown() {
    const isConsume = $('#typeConsume').is(':checked');
    const $select = $('#fixtCategoryFilter').empty();
    
    if (isConsume) {
        $select.addClass('d-none');
    } else {
        $select.removeClass('d-none');
        $select.append('<option value="ALL">전체 항목 보기</option>');
        
        let validFixtures = window.allFixtures.filter(f => {
            const cat = f.fixtCat || f.FIXT_CAT || '기타';
            return cat !== '소모품' && (f.fixtNm || f.FIXT_NM);
        });

        validFixtures.sort((a, b) => {
            const catA = a.fixtCat || a.FIXT_CAT || '';
            const catB = b.fixtCat || b.FIXT_CAT || '';
            
            const catOrder = { '전자기기': 1, '일반비품': 2 };
            const orderA = catOrder[catA] || 3;
            const orderB = catOrder[catB] || 3;
            
            if (orderA !== orderB) return orderA - orderB;
            
            const noA = parseInt(a.fixtNo || a.FIXT_NO, 10) || 0;
            const noB = parseInt(b.fixtNo || b.FIXT_NO, 10) || 0;
            return noA - noB;
        });
        
        const itemNames = new Set();
        validFixtures.forEach(f => {
            itemNames.add(f.fixtNm || f.FIXT_NM);
        });
        
        [...itemNames].forEach(name => $select.append('<option value="'+name+'">'+name+'</option>'));
    }
}

function openStepTwo(type) {
    choiceModal.hide(); 
    targetFixtNo = ""; 
    setTimeout(() => {
        if (type === 'ROOM') {
            axios.get('/reserve/api/rooms').then(res => {
                window.allRooms = res.data;
                $('#roomForm')[0].reset(); 
                $('#rmBgngDt').val(selectedStartDt); 
                $('#rmEndDt').val(selectedEndDt); 
                filterRooms(); 
                roomModal.show();
            });
        } else {
            axios.all([axios.get('/reserve/api/fixts'), axios.get('/reserve/api/all')])
            .then(axios.spread((fRes, rAll) => {
                window.allFixtures = fRes.data;
                window.allReservations = rAll.data;
                $('#fixtForm')[0].reset(); 
                document.getElementById('typeRental').checked = true; 
                $('#fixtBgngDt').val(selectedStartDt); 
                $('#fixtEndDt').val(selectedEndDt); 
                
                updateCategoryDropdown();
                filterFixtures(); 
                fixtModal.show();
            }));
        }
    }, 350);
}

function selectRoom(rmNo) {
    const $target = $('#room-block-' + rmNo);
    if ($target.hasClass('unavailable') || $target.hasClass('maintenance')) return;
    
    $('#rmNo').val(rmNo); 
    $('.room-block').removeClass('selected'); 
    $target.addClass('selected');
}

function filterRooms() {
    const $grid = $('#roomGrid').empty();
    const bgngVal = $('#rmBgngDt').val() || selectedStartDt;
    const endVal = $('#rmEndDt').val() || selectedEndDt;
    
    if(!bgngVal || !endVal) return;

    const bgngTime = new Date(bgngVal).getTime();
    const endTime = new Date(endVal).getTime();
    
    const occupiedMap = {};
    calendar.getEvents().forEach(function(e) {
        if (e.extendedProps && e.extendedProps.type === 'ROOM' && String(e.id) !== String(window.currentResId)) {
            // 🔥 반려된 예약은 회의실 사용 가능 여부 계산 시 완전히 무시! 🔥
            if (e.extendedProps.status === 'REJECTED' || e.extendedProps.status === '반려됨') return;

            if (bgngTime < e.end.getTime() && endTime > e.start.getTime()) {
                const sTime = formatShortDateTime(e.start);
                const eTime = formatShortDateTime(e.end);
                occupiedMap[String(e.extendedProps.refNo)] = sTime + ' ~ ' + eTime;
            }
        }
    });

    window.allRooms.forEach(function(r) {
        const rNo = r.rmNo || r.RM_NO;
        const rNm = r.rmNm || r.RM_NM || "이름없음";
        const rPlc = r.rmPlc || r.RM_PLC || "";
        const rNope = r.rmActcNope || r.rmNope || 0;
        const rStts = r.rmStts || r.RM_STTS || "01";
        
        let sttsStart = r.sttsBgngDt || r.STTS_BGNG_DT || r.rmSttsBgngDt || r.RM_STTS_BGNG_DT || '';
        let sttsEnd = r.sttsEndDt || r.STTS_END_DT || r.rmSttsEndDt || r.RM_STTS_END_DT || '';
        sttsStart = String(sttsStart).replace('null', '').replace('undefined', '').trim();
        sttsEnd = String(sttsEnd).replace('null', '').replace('undefined', '').trim();
        
        const overlapTimeStr = occupiedMap[String(rNo)];
        const isSelected = String($('#rmNo').val()) === String(rNo);
        
        let statusClass = 'available';
        let statusBadge = '<span class="badge bg-success">✅ 예약 가능</span>';
        let isDisabled = false;
        let isActuallyUnavailable = false;

        if (rStts !== '01' && rStts !== '사용가능') {
            if (sttsStart !== '' && sttsEnd !== '') {
                const limitStart = new Date(sttsStart).getTime();
                const limitEnd = new Date(sttsEnd + ' 23:59:59').getTime();
                if (bgngTime <= limitEnd && endTime >= limitStart) {
                    isActuallyUnavailable = true;
                }
            } else {
                isActuallyUnavailable = true;
            }
        }

        if (isActuallyUnavailable) {
            if (rStts === '02' || rStts === '사용불가') {
                statusClass = 'unavailable';
                statusBadge = '<span class="badge bg-secondary">🚫 사용불가</span>';
            } else if (rStts === '03' || rStts === '수리중') {
                statusClass = 'maintenance';
                statusBadge = '<span class="badge bg-danger">🔧 수리중</span>';
            } else if (rStts === '04' || rStts === '용도변경') { 
                statusClass = 'maintenance'; 
                statusBadge = '<span class="badge bg-warning text-dark">🔄 용도변경</span>';
            }
            
            let sDate = sttsStart.length >= 10 ? sttsStart.substring(5, 10).replace('-', '/') : sttsStart;
            let eDate = sttsEnd.length >= 10 ? sttsEnd.substring(5, 10).replace('-', '/') : sttsEnd;
            if (sDate && eDate) {
                statusBadge += '<div style="font-size:0.75rem; color:#8592a3; margin-top:5px; font-weight:600;">(' + sDate + ' ~ ' + eDate + ')</div>';
            }
            isDisabled = true;
        }

        if (!isDisabled && overlapTimeStr) {
            statusClass = 'unavailable';
            statusBadge = '<span class="badge bg-secondary">⏳ 예약됨</span>';
            statusBadge += '<div style="font-size:0.75rem; color:#8592a3; margin-top:4px; font-weight:bold;">' + overlapTimeStr + '</div>';
            isDisabled = true;
        }

        const blockClass = statusClass + (isSelected && !isDisabled ? ' selected' : '');
        const onClickFn = isDisabled ? "" : "selectRoom('" + rNo + "')";

        const blockHtml = 
            '<div class="col-6 col-md-4">' +
                '<div class="room-block ' + blockClass + '" id="room-block-' + rNo + '" onclick="' + onClickFn + '">' +
                    '<div class="room-block-title">' + rNm + '</div>' +
                    '<div class="room-block-desc">' + rPlc + ' (' + rNope + '인)</div>' +
                    '<div class="room-badge" id="room-badge-' + rNo + '">' + statusBadge + '</div>' +
                '</div>' +
            '</div>';
        $grid.append(blockHtml);
    });
}

let currentFixtPage = 1;
const FIXT_PER_PAGE = 5; 
let currentFilteredFixtures = [];

const fetchFixtureData = async () => {
    try {
        const response = await axios.get('/reserve/api/fixts');
        window.allFixtures = response.data;
        return window.allFixtures;
    } catch (error) {
        console.error("❌ 비품 데이터 로드 실패:", error);
        return [];
    }
};

$(document).ready(() => {
    fetchFixtureData();
});

function filterFixtures() {
    try {
        const isConsume = $('#typeConsume').is(':checked');
        const selItem = $('#fixtCategoryFilter').val(); 
        const bgngDt = new Date($('#fixtBgngDt').val());
        const endDt = new Date($('#fixtEndDt').val());
        $('#fixtEndDtDiv').toggleClass('d-none', isConsume);

        const overlapMap = {};
        window.allReservations.forEach(res => {
            const resId = String(res.RES_ID || res.resId || '');
            const type = String(res.TYPE || res.type || '');
            const refNo = String(res.REF_NO || res.refNo || res.FIXT_NO || res.fixtNo || '');
            
            // 🔥 반려된 예약은 비품 재고(사용량) 계산에서 무조건 제외 🔥
            const stts = String(res.STTS || res.stts || '').toUpperCase();
            if (stts === 'REJECTED' || stts === 'CANCELED' || stts === '반려됨') return;

            if (type === 'FIXTURE' && resId !== String(window.currentResId)) {
                const item = window.allFixtures.find(f => String(f.fixtNo || f.FIXT_NO) === refNo);
                const isConsumable = item && (item.fixtCat === '소모품' || item.FIXT_CAT === '소모품');

                if (isConsumable) {
                    overlapMap[refNo] = { count: (overlapMap[refNo]?.count || 0) + 1 };
                } else if (!isNaN(bgngDt.getTime())) {
                    const s = new Date(res.START || res.start).getTime();
                    const e = new Date(res.END || res.end).getTime();
                    if (bgngDt.getTime() < e && endDt.getTime() > s) {
                        let current = overlapMap[refNo] || { count: 0, maxEnd: 0 };
                        current.count += 1;
                        if (e > current.maxEnd) current.maxEnd = e;
                        overlapMap[refNo] = current;
                    }
                }
            }
        });

        currentFilteredFixtures = window.allFixtures.filter(f => {
            const cat = f.fixtCat || f.FIXT_CAT || '';
            const name = f.fixtNm || f.FIXT_NM || '';
            const isCatMatch = isConsume ? (cat === '소모품') : (cat !== '소모품');
            
            let isDropdownMatch = true;
            if (!isConsume && selItem !== 'ALL' && selItem) {
                isDropdownMatch = (name === selItem);
            }
            
            return isCatMatch && isDropdownMatch;
        }).map(f => {
            const fNo = String(f.fixtNo || f.FIXT_NO || '');
            const fQty = parseInt(f.fixtQty || f.FIXT_QTY || 0);
            const overlapInfo = overlapMap[fNo] || { count: 0, maxEnd: 0 };
            const availQty = fQty - overlapInfo.count;
            
            let expectedReturn = "";
            if (availQty <= 0 && overlapInfo.maxEnd > 0) {
                expectedReturn = formatShortDateTime(new Date(overlapInfo.maxEnd));
            }

            const fStts = f.fixtStts || f.FIXT_STTS || "정상";
            let sS = String(f.sttsBgngDt || f.STTS_BGNG_DT || '').replace('null',''), sE = String(f.sttsEndDt || f.STTS_END_DT || '').replace('null','');
            let isM = false;
            if (['정상', '대여가능', '신청가능', '사용가능'].indexOf(fStts) === -1) {
                if (sS && sE && !isNaN(bgngDt.getTime())) {
                    const lS = new Date(sS).getTime(), lE = new Date(sE + ' 23:59:59').getTime();
                    if (bgngDt.getTime() <= lE && endDt.getTime() >= lS) isM = true;
                } else isM = true;
            }
            return { ...f, availQty, isActuallyUnavailable: isM, fStts, sS, sE, expectedReturn };
        });
        
        currentFilteredFixtures.sort((a, b) => {
            const catA = a.fixtCat || a.FIXT_CAT || '';
            const catB = b.fixtCat || b.FIXT_CAT || '';
            
            const catOrder = { '전자기기': 1, '일반비품': 2, '소모품': 3 };
            const orderA = catOrder[catA] || 4;
            const orderB = catOrder[catB] || 4;
            
            if (orderA !== orderB) return orderA - orderB;
            
            const noA = parseInt(a.fixtNo || a.FIXT_NO, 10) || 0;
            const noB = parseInt(b.fixtNo || b.FIXT_NO, 10) || 0;
            return noA - noB;
        });
        
        changeFixtPage(1);
    } catch (e) { console.error("filterFixtures 에러:", e); }
}

function renderFixtTable() {
    const $tbody = $('#fixtTbody').empty();
    const isConsume = $('#typeConsume').is(':checked');
    if (currentFilteredFixtures.length === 0) {
        $tbody.append('<tr style="height: 55px;"><td colspan="4" class="text-center text-muted py-4">조회된 항목이 없습니다.</td></tr>');
        $('#fixtPagination').empty(); return;
    }

    const pageData = currentFilteredFixtures.slice((currentFixtPage - 1) * FIXT_PER_PAGE, currentFixtPage * FIXT_PER_PAGE);

    pageData.forEach(f => {
        const fNm = f.fixtNm || f.FIXT_NM || "이름없음";
        const fMd = f.fixtMdNm || f.FIXT_MD_NM || "";
        const fNo = f.fixtNo || f.FIXT_NO;
        const isSelected = String($('#fixtNo').val()) === String(fNo);
        
        let displayTitle = fNm; 
        if (!isConsume && fMd) displayTitle += ' <small class="text-muted">(' + fMd + ')</small>';

        let trClass = isSelected ? "table-primary" : "", statusHtml = "", btnHtml = "";
        
        if (f.isActuallyUnavailable) {
            trClass = "table-light text-muted";
            let bTxt = '불가', bCol = 'bg-secondary';
            if (f.fStts === '03' || f.fStts === '수리중') { bTxt = '수리중'; bCol = 'bg-danger'; }
            else if (f.fStts === '04' || f.fStts === '용도변경') { bTxt = '용도변경'; bCol = 'bg-warning text-dark'; }
            let sd = f.sS.substring(5).replace('-','/'), ed = f.sE.substring(5).replace('-','/');
            statusHtml = '<span class="badge ' + bCol + '">' + bTxt + '</span>' + (sd ? '<div style="font-size:0.7rem; color:#8592a3; margin-top:2px; font-weight:bold;">(' + sd + '~' + ed + ')</div>' : '');
            btnHtml = '<button disabled class="btn btn-sm btn-outline-secondary" style="width: 65px;">불가</button>';
        } else if (f.availQty <= 0 && String(fNo) !== String(window.targetFixtNo)) {
            trClass = "table-light text-muted"; 
            let bTxt = isConsume ? '재고없음' : '대여중';
            statusHtml = '<span class="badge bg-secondary">' + bTxt + '</span>';
            
            if (!isConsume && f.expectedReturn) {
                statusHtml += '<div style="font-size:0.75rem; color:#8592a3; margin-top:4px; font-weight:bold;">(~' + f.expectedReturn + ')</div>';
            }
            btnHtml = '<button disabled class="btn btn-sm btn-outline-secondary" style="width: 65px;">불가</button>';
        } else {
            statusHtml = '<span class="fw-bold text-primary">' + f.availQty + '개</span>';
            btnHtml = '<button class="btn btn-sm ' + (isSelected ? 'btn-primary' : 'btn-outline-primary') + '" style="width: 65px;" onclick="selectFixt(\'' + fNo + '\')">' + (isSelected ? '선택됨' : '선택') + '</button>';
        }

        $tbody.append('<tr class="' + trClass + '" style="height: 55px;"><td>' + (f.fixtCat || f.FIXT_CAT) + '</td><td class="text-start fw-bold">' + displayTitle + '</td><td>' + statusHtml + '</td><td>' + btnHtml + '</td></tr>');
    });

    for (let i = 0; i < (FIXT_PER_PAGE - pageData.length); i++) $tbody.append('<tr style="height: 55px;"><td colspan="4" style="border: none;"></td></tr>');
    renderFixtPagination(); 
}
function renderFixtPagination() {
    const $pageArea = $('#fixtPagination').empty();
    const totalPages = Math.ceil(currentFilteredFixtures.length / FIXT_PER_PAGE);

    if (totalPages <= 1) return; 

    let html = '<ul class="pagination pagination-sm mb-0">';
    
    html += '<li class="page-item ' + (currentFixtPage === 1 ? 'disabled' : '') + '">' +
                '<a class="page-link" href="#" onclick="event.preventDefault(); changeFixtPage(' + (currentFixtPage - 1) + ')">〈</a>' +
             '</li>';

    for (let i = 1; i <= totalPages; i++) {
        html += '<li class="page-item ' + (currentFixtPage === i ? 'active' : '') + '">' +
                    '<a class="page-link" href="#" onclick="event.preventDefault(); changeFixtPage(' + i + ')">' + i + '</a>' +
                 '</li>';
    }

    html += '<li class="page-item ' + (currentFixtPage === totalPages ? 'disabled' : '') + '">' +
                '<a class="page-link" href="#" onclick="event.preventDefault(); changeFixtPage(' + (currentFixtPage + 1) + ')">〉</a>' +
             '</li>';
    
    html += '</ul>';
    $pageArea.append(html);
}

function changeFixtPage(page) {
    const totalPages = Math.ceil(currentFilteredFixtures.length / FIXT_PER_PAGE);
    if (page < 1 || page > totalPages) return;
    
    currentFixtPage = page; 
    renderFixtTable();      
}

function selectFixt(fixtNo) {
    $('#fixtNo').val(fixtNo); 
    renderFixtTable();        
}

function saveReservation(type, action) {
    let data = { 
        empId: '${loginEmpId}', 
        resId: currentResId 
    };

    if (type === 'ROOM') { 
        data.rmNo = $('#rmNo').val(); 
        data.expln = $('#rmExpln').val(); 
        data.bgngDt = $('#rmBgngDt').val(); 
        data.endDt = $('#rmEndDt').val(); 
        data.aprvId = $('#roomAprvId').val(); 
    } else { 
        data.fixtNo = $('#fixtNo').val(); 
        data.expln = $('#fixtExpln').val(); 
        data.bgngDt = $('#fixtBgngDt').val(); 
        
        if (document.getElementById('typeConsume').checked) {
            data.endDt = data.bgngDt; 
        } else {
            data.endDt = $('#fixtEndDt').val();
        }
        data.aprvId = $('#fixtAprvId').val(); 
    }
    
    if(!data.bgngDt || !data.endDt || (type==='ROOM' && !data.rmNo) || (type==='FIXT' && !data.fixtNo)) {
        return Swal.fire('알림', '예약 대상을 선택하고 시간을 정확히 입력해 주세요.', 'warning');
    }

    const url = '/reserve/api/' + action + (type === 'ROOM' ? 'Room' : 'Fixt');
    axios.post(url, data).then(res => {
        if (res.data === 'overlap') return Swal.fire('실패', '이미 예약된 시간입니다.', 'error');
        Swal.fire('성공', '결재 요청이 전송되었습니다.', 'success').then(() => location.reload());
    }).catch(err => {
        console.error("전송 에러:", err);
        Swal.fire('오류', '서버 통신 실패', 'error');
    });
}

function deleteReservation(type) {
    Swal.fire({ title: '삭제하시겠습니까?', text: '삭제된 예약은 복구할 수 없습니다.', icon: 'warning', showCancelButton: true, confirmButtonColor: '#d33', cancelButtonColor: '#6c757d', confirmButtonText: '삭제', cancelButtonText: '취소' }).then((result) => {
        if (result.isConfirmed) { const url = '/reserve/api/delete' + (type === 'ROOM' ? 'Room' : 'Fixt'); axios.post(url, { resId: currentResId }).then(() => location.reload()); }
    });
}

async function fetchMasterData() {
    try {
        const [roomRes, fixtRes, resAll] = await Promise.all([
            axios.get('/reserve/api/rooms'),
            axios.get('/reserve/api/fixts'),
            axios.get('/reserve/api/all')
        ]);
        window.allRooms = roomRes.data || [];
        window.allFixtures = fixtRes.data || [];
        window.allReservations = resAll.data || [];
    } catch (error) {
        console.error("데이터 로드 실패:", error);
    }
}

$(document).ready(function() {
    fetchMasterData();
});
</script>