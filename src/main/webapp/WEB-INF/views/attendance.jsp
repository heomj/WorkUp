<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.css"/>

<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.js.iife.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="/js/common-alert.js"></script>

<style>
    :root {
        --primary-color: #696CFF;
        --secondary-color: #8592a3;
        --success-color: #71dd37;
        --info-color: #03c3ec;
        --warning-color: #ffab00;
        --danger-color: #ff3e1d;
        --card-shadow: 0 2px 10px 0 rgba(67, 89, 113, 0.15);
    }

    body { 
        font-family: 'Public Sans', sans-serif; 
        background-color: #f4f7ff; 
        color: #566a7f; 
        margin: 0; 
        overflow-x: hidden !important; 
        user-select: none; 
        -webkit-user-select: none;
    }
    #main-wrapper2 {transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1) !important;width: 100% !important; position: relative;}
    #main-wrapper2.pushed {margin-right: 400px !important;width: calc(100% - 400px) !important;}

    .card { border: none !important; border-radius: 0.75rem !important; box-shadow: var(--card-shadow) !important; background: #fff; margin-bottom: 24px; }

    .commute-widget {display: grid;grid-template-columns: 1.3fr 1px 4fr;gap: 35px;align-items: center;padding: 35px !important;}
    .time-display { font-size: 2.5rem; font-weight: 700; color: var(--primary-color); letter-spacing: -1px; }

    .commute-btns { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; width: 100%; }
    .commute-btns .btn { padding: 8px 12px; font-weight: 600; font-size: 0.9rem; display: flex; align-items: center; justify-content: center; gap: 6px; border-radius: 6px; }

    /* 대시보드 카드 스케일 업! 🦾 */
    .dashboard-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 20px; }
    .stat-card { padding: 25px 15px; text-align: center; background: #f9faff; border-radius: 12px; transition: all 0.3s; }
    .stat-card:hover { transform: translateY(-5px); background: #fff; box-shadow: 0 4px 12px rgba(105, 108, 255, 0.1); }
    .stat-icon { width: 50px; height: 50px; border-radius: 10px; display: flex; align-items: center; justify-content: center; margin: 0 auto 15px; }
    .stat-icon span { font-size: 28px; }
    .stat-card .value { font-size: 1.6rem; font-weight: 800; color: #566a7f; display: block; margin-bottom: 5px; }
    .stat-card .label { font-size: 0.9rem; color: #a1acb8; font-weight: 600; text-transform: uppercase; }

    /* 내비 버튼 & 뷰 스위치 현대화 🦾 */
    .nav-btn {
        border: none; background: #f0f2f5; border-radius: 6px; padding: 6px 12px;
        cursor: pointer; transition: 0.2s; color: #566a7f; display: flex; align-items: center; font-weight: 600;
    }
    .nav-btn:hover { background: var(--primary-color); color: white; }

    .view-switch { background: #f0f2f5; border-radius: 8px; padding: 4px; display: inline-flex; gap: 4px; }
    .view-switch button {
        border: none; padding: 8px 20px; border-radius: 6px; font-size: 0.85rem; font-weight: 700;
        cursor: pointer; transition: 0.3s; background: transparent; color: #8592a3;
    }
    .view-switch button.active { background: var(--primary-color); color: white; box-shadow: 0 2px 6px rgba(105, 108, 255, 0.3); }
    .mode-btn-group { background: #f0f2f5; border-radius: 8px; padding: 4px; display: inline-flex; gap: 4px; border: none; }
    .mode-btn-group .mode-btn {border: none; padding: 8px 20px; border-radius: 6px; font-size: 0.85rem; font-weight: 700;cursor: pointer; transition: 0.3s; background: transparent; color: #8592a3;
        display: flex;align-items: center;justify-content: center;
    }
    .mode-btn-group .mode-btn.active { background: var(--primary-color, #696cff); color: white; box-shadow: 0 2px 6px rgba(105, 108, 255, 0.3); }
    .mode-btn-group .mode-btn:hover:not(.active) {color: #696cff;background: rgba(105, 108, 255, 0.05);}

    /* 달력 그리드 & 드래그 스타일 🦾 */
    .calendar-grid { display: grid; grid-template-columns: 0.7fr repeat(5, 1fr) 0.7fr; gap: 1px; background: #eef0f2; border: 1px solid #eef0f2; border-radius: 12px; overflow: hidden; }
    .calendar-day { background: white; min-height: 140px; padding: 12px; position: relative; transition: 0.2s; cursor: pointer; }
    .calendar-day.selected { background: rgba(105, 108, 255, 0.1) !important; border: 1px solid rgba(105, 108, 255, 0.3); border-radius: 8px; z-index: 1; }

    .day-num { font-weight: 700; font-size: 1rem; margin-bottom: 8px; }
    .event-item { font-size: 0.75rem; padding: 4px 8px; border-radius: 6px; margin-bottom: 4px; font-weight: 700; width: 100%; box-sizing: border-box; }
    .event-vacation { background: rgba(105, 108, 255, 0.1); color: var(--primary-color); border-left: 4px solid var(--primary-color); }
    .event-trip { background: rgba(3, 195, 236, 0.1); color: var(--info-color); border-left: 4px solid var(--info-color); }
    .event-overtime {background: rgba(255, 171, 0, 0.1) !important; color: var(--warning-color) !important; border-left: 4px solid var(--warning-color) !important;}

    .time-text { font-size: 0.75rem; color: #697a8d; margin-bottom: 2px; display: block; }
    .time-text.late { color: var(--danger-color); font-weight: 800; }
    .time-text.over { color: var(--success-color); font-weight: 800; }

    /* 기존 필수 스타일 유지 */
    .calendar-day.sat .day-num { color: var(--success-color); }
    .calendar-day.sun .day-num, .calendar-day.holiday .day-num { color: var(--danger-color); }
    .calendar-day.other-month { opacity: 0.3; pointer-events: none; }
    .calendar-day.today .day-num { background: var(--primary-color); color: white; border-radius: 50%; width: 26px; height: 26px; display: flex; align-items: center; justify-content: center; }
    

    #application-form-container {position: fixed; right: -450px;top: 70px; width: 400px; height: calc(100vh - 70px);background: #fff; z-index: 1050; border-left: 1px solid #d9dee3; 
        padding: 40px;opacity: 0;visibility: hidden;   display: block !important; transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); 
    }
    #application-form-container.show { right: 0 !important; opacity: 1 !important; visibility: visible !important;box-shadow: -15px 0 35px rgba(0,0,0,0.08) !important;}

    #application-list-view .table {background-color: #ffffff !important;border-collapse: collapse !important;}
    #application-list-view .table tbody tr, 
    #application-list-view .table tbody td {background-color: #ffffff !important;border-bottom: 1px solid #fcfdff !important;transition: background-color 0.3s ease, transform 0.3s ease, box-shadow 0.3s ease !important;}

    #application-list-view .table-hover tbody tr:hover {background-color: #fcfdff !important; transform: translateY(-0.5px);box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.03) !important;}

    #application-list-view .table-hover tbody tr:hover td {background-color: #fcfdff !important;}

    .badge.rounded-pill {font-weight: 600;padding: 0.5em 0.85em;text-transform: uppercase;}

    .bg-label-primary {background-color: #e7e7ff !important;color: #696cff !important;}
    .bg-label-info {background-color: #d7f5fc !important;color: #03c3ec !important;}
    .bg-label-danger {background-color: #ffe5e5 !important;color: #ff3e1d !important;}
    .bg-label-warning {background-color: #fff2d6 !important;color: #ffab00 !important;}
    
    #pagination-container .pagination {display: flex !important;justify-content: center !important;list-style: none !important;padding: 1.5rem 0 !important;gap: 4px !important; /* 버튼 사이 간격 */margin: 0 !important;}

    #pagination-container .page-link {
        display: flex !important;align-items: center !important;justify-content: center !important;height: 34px !important;padding: 0 0.8rem !important;font-size: 0.875rem !important;
        font-weight: 500 !important;color: #566a7f !important; background-color: #fff !important;border: none !important; border-radius: 6px !important; text-decoration: none !important;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05) !important; transition: all 0.2s ease-in-out !important;
    }

    #pagination-container .page-link:hover {background-color: #f0f2f4 !important;color: #696cff !important;transform: translateY(-1px) !important;}

    #pagination-container .page-item.active .page-link {background-color: #696cff !important;color: #fff !important;font-weight: 700 !important;box-shadow: 0 3px 8px rgba(105, 108, 255, 0.3) !important;}

    #pagination-container .page-item.disabled .page-link {background-color: #f8f9fa !important;color: #b4bdc6 !important;cursor: not-allowed !important;box-shadow: none !important;opacity: 0.7 !important;}
   
    .btn-sm .material-icons {line-height: 1;display: flex;align-items: center;}


</style>

<div id="main-wrapper2">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                <span class="material-icons" style="color: #696cff; font-size: 32px;">timer</span>
                <span style="font-size: x-large; font-weight: 800;">근태 관리</span>
            </div>
            <div style="font-size: 15px; color: #717171; margin-top: 8px;">실시간 근무 현황 및 관리를 위한 페이지입니다.</div>
        </div>
        <button onclick="startApprovalTutorial()" class="btn btn-outline-secondary d-flex align-items-center gap-2" style="border-radius: 8px; font-weight: 600;">
            <span class="material-icons" style="font-size: 1.1rem;">help_outline</span> 튜토리얼
        </button>
    </div>

    <div class="commute-widget card">
        <div class="d-flex flex-column gap-3 border-end pe-4">
            <div>
                <div class="text-muted small mb-1 fw-bold">현재시간</div>
                <div id="real-time-clock" style="font-variant-numeric: tabular-nums; " class="time-display">12:00:00 PM</div>
                <div id="attendance-status" class="mt-2 fw-bold" style="color: #696cff; font-size: 0.95rem;">
                    상태 정보를 불러오는 중...
                </div>
            </div>
            <div class="commute-btns">
                <button id="btn-checkin" class="btn btn-primary" style="background:#696CFF" onclick="handleCommute('in')"><span class="material-icons" style="font-size: 1.1rem;">login</span>출근</button>
                <button id="btn-checkout" class="btn btn-outline-danger" onclick="handleCommute('out')"><span class="material-icons" style="font-size: 1.1rem;">logout</span>퇴근</button>
                <button id="btn-out" class="btn btn-outline-warning" onclick="handleCommute('away')"><span class="material-icons" style="font-size: 1.1rem;">directions_run</span>외출</button>
                <button id="btn-return" class="btn btn-outline-info" onclick="handleCommute('back')"><span class="material-icons" style="font-size: 1.1rem;">undo</span>복귀</button>
            </div>
        </div>
        <div class="vr" style="opacity: 0.1;"></div>
        <div class="dashboard-grid">
            <div class="stat-card">
                <div class="stat-icon bg-label-primary"><span class="material-icons text-primary">event_available</span></div>
                <span class="value" id="ann-leave-remain">0 / 0</span> <span class="label">잔여 / 연차</span>
            </div>

            <div class="stat-card">
                <div class="stat-icon bg-label-info"><span class="material-icons text-info">flight_takeoff</span></div>
                <span class="value" id="month-bztrp-count">0회</span> <span class="label">이번달 출장</span>
            </div>

            <div class="stat-card">
                <div class="stat-icon bg-label-success"><span class="material-icons text-success">beach_access</span></div>
                <span class="value" id="month-vct-count">0회</span> <span class="label">이번달 휴가</span>
            </div>

            <div class="stat-card">
                <div class="stat-icon bg-label-warning"><span class="material-icons text-warning">schedule</span></div>
                <span class="value" id="month-work-time">0h</span> <span class="label">총 근무시간</span>
            </div>

            <div class="stat-card">
                <div class="stat-icon bg-label-danger"><span class="material-icons text-danger">alarm_off</span></div>
                <span class="value" id="month-late-count">0회</span> <span class="label">지각 횟수</span>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center gap-3">
                <div class="d-flex gap-2">
                    <button class="nav-btn" onclick="moveMonth(-1)"><span class="material-icons">chevron_left</span></button>
                    <button class="nav-btn" onclick="moveMonth(0)">오늘</button>
                    <button class="nav-btn" onclick="moveMonth(1)"><span class="material-icons">chevron_right</span></button>
                </div>
                <h4 id="current-month-display" class="fw-bold mb-0" style="color: #566a7f; min-width: 150px;">2024년 5월</h4>
                <div class="mode-btn-group" role="group" aria-label="Application Mode">
                    <button type="button" class="mode-btn" data-mode="vacation">휴가</button>
                    <button type="button" class="mode-btn" data-mode="trip">출장</button>
                    <button type="button" class="mode-btn" data-mode="overtime">초과근무</button>
                </div>
            </div>
            
            <div class="view-switch">
                <button id="btn-view-cal" class="active" onclick="switchView('calendar')">달력</button>
                <button id="btn-view-list" onclick="switchView('list')">신청 목록</button>
            </div>
        </div>
        <div class="card-body">
            <div id="attendance-calendar-view">
                <div class="calendar-grid" id="calendar-grid"></div>
            </div>
            <div id="attendance-list-view" style="display: none;">
                <table class="table table-hover">
                    <thead class="table-light"><tr><th>신청종류</th><th>기간</th><th>사유</th><th>상태</th></tr></thead>
                    <tbody><tr><td><span class="badge bg-label-primary">연차</span></td><td>2024-05-20 ~ 2024-05-21</td><td>개인 사정</td><td><span class="badge bg-success">승인</span></td></tr></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div id="application-form-container" >
    <div class="d-flex justify-content-between align-items-center mb-5">
        <h3 class="fw-bold mb-0" id="form-title">신청서 작성</h3>
        <button type="button" class="btn-close" onclick="closeForm()"></button>
    </div>

    <form id="form-vacation" class="mode-form" style="display:none;">
        <div class="mb-4">
            <label class="form-label fw-bold small text-muted">휴가 종류 (Vacation Type)</label>
            <select class="form-select border-primary-subtle py-2" id="vacation-type">
                <option value="일반" selected>일반 (Annual)</option>
                <option value="오전반차">오전반차 (Half-AM)</option>
                <option value="오후반차">오후반차 (Half-PM)</option>
                <option value="병가">병가 (Sick Leave)</option>
                <option value="공가">공가 (Sick Leave)</option>
            </select>
        </div>
        <div class="mb-4">
            <label class="form-label fw-bold small text-muted">기간 (Period)</label>
            <div class="d-flex align-items-center gap-2">
                <input type="date" class="form-control" id="v-start" readonly>
                <span class="text-muted">~</span>
                <input type="date" class="form-control" id="v-end" readonly>
            </div>
        </div>
        <div class="mb-5">
            <label class="form-label fw-bold small text-muted">상세 사유 (Reason)</label>
            <textarea class="form-control" id="v-reason" rows="4" placeholder="휴가 사유를 입력해주세요."></textarea>
        </div>
        <div class="d-flex flex-column gap-2">
            <button type="button" class="btn btn-primary py-3 fw-bold" style="background:#696CFF" onclick="submitVacation()">신청 완료 (Submit)</button>
            <button type="button" class="btn btn-link text-muted" onclick="closeForm()">창 닫기 (Cancel)</button>
        </div>
    </form>

    <form id="form-trip" class="mode-form" style="display:none;">
        <div class="mb-4">
            <label class="form-label fw-bold small text-muted">출장지 (Location)</label>
            <input type="text" class="form-control border-primary-subtle py-2" id="t-location" placeholder="방문처를 입력해주세요.">
        </div>
        <div class="mb-4">
            <label class="form-label fw-bold small text-muted">출장 기간 (Period)</label>
            <div class="d-flex align-items-center gap-2">
                <input type="date" class="form-control" id="t-start" readonly>
                <span class="text-muted">~</span>
                <input type="date" class="form-control" id="t-end" readonly>
            </div>
        </div>
        <div class="mb-5">
            <label class="form-label fw-bold small text-muted">출장 목적 (Purpose)</label>
            <textarea class="form-control" id="t-reason" rows="4" placeholder="출장 목적 및 업무 내용을 입력해주세요."></textarea>
        </div>
        <div class="d-flex flex-column gap-2">
            <button type="button" class="btn btn-primary py-3 fw-bold" style="background:#696CFF; border:none;" onclick="submitTrip()">신청 완료 (Submit)</button>
            <button type="button" class="btn btn-link text-muted" onclick="closeForm()">창 닫기 (Cancel)</button>
        </div>
    </form>

    <form id="form-overtime" class="mode-form" style="display:none;">
        <div class="mb-4">
            <label class="form-label fw-bold small text-muted" readonly>근무일 (Work Date)</label>
            <input type="date" class="form-control border-primary-subtle py-2" id="o-date">
        </div>
        <div class="mb-5">
            <label class="form-label fw-bold small text-muted">작업 내용 (Work Details)</label>
            <textarea class="form-control" id="o-reason" rows="6" placeholder="초과근무 사유 및 예정된 업무 내용을 상세히 입력해주세요."></textarea>
        </div>
        <div class="d-flex flex-column gap-2">
            <button type="button" class="btn btn-primary py-3 fw-bold" style="background:#696CFF; border:none;" onclick="submitOvertime()">신청 완료 (Submit)</button>
            <button type="button" class="btn btn-link text-muted" onclick="closeForm()">창 닫기 (Cancel)</button>
        </div>
    </form>
</div>
<div class="modal fade" id="qrModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="width: 300px;">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.2);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold w-100 text-center" style="color: #566a7f;">출근 QR 인증</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center pt-4 pb-5">
                <div id="qrcode" class="d-inline-block p-3 bg-white shadow-sm rounded-3"></div>
                <p class="mt-4 mb-0 small text-muted fw-medium">카카오톡으로 QR을 스캔하여<br>본인 인증을 진행해 주세요.</p>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="outModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="width: 350px;">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.2);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold w-100 text-center" style="color: #566a7f;">
                    <span class="material-icons" style="vertical-align: middle; color: #ffab00;">directions_run</span>
                    외출 신청
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center pt-4 pb-4">
                <p class="small text-muted mb-3 fw-medium">외출 사유를 간단히 입력해 주세요</p>
                <div class="px-2">
                    <textarea id="out-reason" class="form-control border-light shadow-sm" rows="3"
                              placeholder="예: 개인 용무, 병원 방문 등"
                              style="border-radius: 10px; resize: none; background-color: #f8f9fa;"></textarea>
                </div>
            </div>
            <div class="modal-footer border-0 pt-0 pb-4 d-flex justify-content-center">
                <button type="button" id="confirm-out" class="btn btn-warning px-5 fw-bold"
                        style="border-radius: 8px; background: #ffab00; border: none; color: #fff;">
                    외출 확정
                </button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="returnModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="width: 300px;">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.2);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold w-100 text-center" style="color: #566a7f;">
                    <span class="material-icons" style="vertical-align: middle; color: #71dd37;">undo</span>
                    업무 복귀
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center pt-4 pb-5">
                <div class="mb-3">
                    <span class="material-icons" style="font-size: 48px; color: #696cff; opacity: 0.2;">task_alt</span>
                </div>
                <p class="mb-0 small text-muted fw-medium">지금 즉시 업무로 복귀하시겠습니까?
            </div>
            <div class="modal-footer border-0 pt-0 pb-4 d-flex justify-content-center">
                <button type="button" id="confirm-return" class="btn btn-primary px-5 fw-bold"
                        style="border-radius: 8px; background: #696CFF; border: none;">
                    복귀 완료
                </button>
            </div>
        </div>
    </div>
</div>

<script>
let currentYear = new Date().getFullYear();
let currentMonth = new Date().getMonth();

const holidays = { '1-1': '신정', '3-1': '삼일절', '5-5': '어린이날', '6-6': '현충일', '8-15': '광복절', '10-3': '개천절', '10-9': '한글날', '12-25': '크리스마스' };

function updateClock() {
    const now = new Date();
    document.getElementById('real-time-clock').textContent = now.toLocaleTimeString('en-US', { hour12: true, hour: '2-digit', minute: '2-digit', second: '2-digit' });
}
setInterval(updateClock, 1000);

function moveMonth(step) {
    if (step === 0) { currentYear = new Date().getFullYear(); currentMonth = new Date().getMonth(); }
    else { const d = new Date(currentYear, currentMonth + step, 1); currentYear = d.getFullYear(); currentMonth = d.getMonth(); }
    renderCalendar();
}

// 1. 달력 렌더링 (서버 데이터 포함 버전) 🦾
async function renderCalendar() {
    // JSP EL 충돌 방지를 위해 백틱 내부 변수 앞에는 \를 붙여주는 게 King-Chad의 매너!
    document.getElementById('current-month-display').textContent = `\${currentYear}년 \${currentMonth + 1}월`;
    const grid = document.getElementById('calendar-grid');
    grid.innerHTML = '';

    // 📡 서버에서 데이터 가져오기
    const formattedMonth = String(currentMonth + 1).padStart(2, '0');
    let attendanceList = [];
    let eventList = [];

    try {
        const res = await axios.get(`/attendance/calenderList?year=\${currentYear}&month=\${formattedMonth}`);
        console.log("달력 전체 데이터:", res.data);
        attendanceList = res.data.attendanceList || [];
        eventList = res.data.eventList || [];
    } catch (err) {
        console.error("데이터 로드 실패 🥊", err);
    }

    // 요일 헤더 그리기
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    days.forEach((d, idx) => {
        const color = idx === 0 ? 'var(--danger-color)' : (idx === 6 ? 'var(--success-color)' : '#8592a3');
        grid.innerHTML += `<div class="bg-light p-3 text-center fw-bold small" style="color:\${color}">\${d}</div>`;
    });

    const firstDay = new Date(currentYear, currentMonth, 1).getDay();
    const lastDate = new Date(currentYear, currentMonth + 1, 0).getDate();
    const prevLastDate = new Date(currentYear, currentMonth, 0).getDate();

    // 이전 달 빈칸
    for (let i = firstDay - 1; i >= 0; i--) createDay(prevLastDate - i, 'other-month');

    // 🦾 이번 달 날짜 그리기
    for (let i = 1; i <= lastDate; i++) {
        const d = new Date(currentYear, currentMonth, i);
        const dayOfWeek = d.getDay();
        const holidayName = holidays[`\${currentMonth + 1}-\${i}`];
        const isToday = i === new Date().getDate() && currentMonth === new Date().getMonth() && currentYear === new Date().getFullYear();
        
        let className = dayOfWeek === 0 ? 'sun' : (dayOfWeek === 6 ? 'sat' : '');
        if (holidayName) className += ' holiday';
        if (isToday) className += ' today';

        // 🎯 [변수 매칭] strCheckIn을 활용한 철벽 방어막! 🦾
        const dayData = attendanceList.find(item => {
            if (!item) return false;

            // 1. 시차 없는 strCheckIn을 먼저 보고, 없으면 attCheckIn이라도 본다!
            // (형 데이터에서 attCheckIn이 null인 경우가 있으니 strCheckIn이 구세주야)
            const targetDate = item.strCheckIn || item.attCheckIn; 
            if (!targetDate) return false;

            // 2. "2026-03-19 08:58" (공백) 이든 "2026-03-19T08:58" (T) 이든 날짜만 컷!
            const datePart = targetDate.includes('T') ? targetDate.split('T')[0] : targetDate.split(' ')[0];
            
            // 3. 현재 그리는 칸의 날짜(i)와 비교 (안전하게 연/월까지 체크)
            const dateArr = datePart.split('-'); // ["2026", "03", "19"]
            return parseInt(dateArr[0]) === currentYear && 
                parseInt(dateArr[1]) === (currentMonth + 1) && 
                parseInt(dateArr[2]) === i;
        });

        // 🎯 [변수 매칭] ev가 null일 경우를 대비해 안전하게!
        const dayEvents = eventList.filter(ev => {
            if (!ev) return false; // null 방어막 쉴드 쳐! 🛡️
            
            return ev.eventDate && parseInt(ev.eventDate.split('-')[2]) === i;
        });

        createDay(i, className, dayOfWeek, holidayName, dayData, dayEvents);
    }

    const remaining = 42 - (firstDay + lastDate);
    for (let i = 1; i <= remaining; i++) createDay(i, 'other-month');
}

function createDay(num, className, dayOfWeek, holidayName, dayData, dayEvents) {
    const grid = document.getElementById('calendar-grid');
    const isOther = className.includes('other-month');
    const isWeekend = (dayOfWeek === 0 || dayOfWeek === 6);
    const isHoliday = className.includes('holiday');

    // 🛡️ [Giga-Guard] 기존 일정이 있는지 체크 
    const hasFullDayEvent = dayEvents && dayEvents.some(ev => 
        ['정기휴가', '일반휴가', '공가', '병가', '오후반차'].includes(ev.eventLabel) || 
        ev.eventType === 'trip' || 
        ev.eventType === 'overtime'
    );

    // 🎯 [Giga-Logic] 다른 달, 주말, 공휴일, 이미 일정이 있는 날은 드래그 금지!
    const isDisabled = isOther || isWeekend || isHoliday || hasFullDayEvent;
    
    // ⚠️ JSP EL 충돌 방지를 위해 \${} 처리 완료 🦾
    const dragEvents = `onmousedown="startDrag(\${num})" onmouseenter="doDrag(\${num})" onmouseup="endDrag()"`;

    let dataHtml = '';
    if (!isOther) {
        // 1. 🕒 출퇴근 및 지각 노출 (풀타임 이벤트 없을 때만)
        if (dayData && !hasFullDayEvent) {
            const formatTime = (isoString) => {
                if (!isoString) return null;
                const date = new Date(isoString);
                return date.getHours().toString().padStart(2, '0') + ':' + 
                       date.getMinutes().toString().padStart(2, '0');
            };

            const on = formatTime(dayData.strCheckIn)
            const off = formatTime(dayData.strCheckOut);
            if (on) dataHtml += `<span class="time-text">\${on} IN</span>`;
            if (dayData.attLateYn === 'Y') { 
                dataHtml += `<span class="time-text late">지각 (LATE)</span>`;
            }
            if (off) dataHtml += `<span class="time-text">\${off} OUT</span>`;
        }

        // 2. 📅 신청 데이터 렌더링
        if (dayEvents && dayEvents.length > 0) {
            const uniqueEvents = dayEvents.filter((ev, index, self) =>
                index === self.findIndex((t) => t.eventLabel === ev.eventLabel)
            );

            uniqueEvents.sort((a, b) => {
                const priority = { 'vacation': 1, 'trip': 2, 'overtime': 3 };
                return (priority[a.eventType] || 99) - (priority[b.eventType] || 99);
            });

            uniqueEvents.forEach(ev => {
                let colorClass = 'event-vacation';
                if (ev.eventType === 'trip') colorClass = 'event-trip';
                if (ev.eventType === 'overtime') colorClass = 'event-overtime';

                dataHtml += `<div class="event-item \${colorClass}">\${ev.eventLabel}</div>`;
            });
        }
    }

    // 최종 렌더링 (백슬래시 처리 완벽 🦾)
    grid.innerHTML += `
        <div class="calendar-day \${className} \${isDisabled ? 'disabled' : ''}" data-day="\${num}" \${dragEvents}>
            <div class="day-num">\${num}</div>
            \${holidayName ? `<div class="holiday-name" style="position:absolute; top:12px; right:12px; font-size:0.65rem; color:var(--danger-color); font-weight:700;">\${holidayName}</div>` : ''}
            <div class="event-container">\${dataHtml}</div>
        </div>
    `;
}

let isDragging = false, startDay = null, endDay = null;

function startDrag(day) {
    // 🛡️ [Giga-Guard 1] 신청 모드 선택 여부 체크
    if (!currentMode) return;
    // 해당 날짜 요소 가져오기
    const dayElement = document.querySelector(`.calendar-day[data-day="\${day}"]`);
    
    // 🛡️ [Giga-Guard 2] 여기서 'disabled' 클래스를 체크해서 Swal 소환! 🦾
    if (dayElement && dayElement.classList.contains('disabled')) {
        Swal.fire({
            icon: 'warning',
            title: '신청 불가',
            text: '이미 일정이 등록되어 있거나 신청할 수 없는 날짜입니다.',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true
        });
        return; // ❌ 여기서 중단시키면 드래그 시작 안 됨!
    }

    // 🛡️ [Giga-Guard 2] 과거 날짜 차단 (오늘 포함 이후만 허용) 🦾
    const selectedDate = new Date(currentYear, currentMonth, day);
    const today = new Date();
    today.setHours(0, 0, 0, 0); // 시간 값 초기화해서 날짜만 비교!

    if (selectedDate < today) {
        Swal.fire({
        icon: 'warning',       
        title: '날짜 선택 제한',
        text: '지난 날짜에 대해서는 신청이 불가능합니다.',
        toast: true,            
        position: 'top-end',    
        showConfirmButton: false,
        timer: 2000,            
        timerProgressBar: true,
        background: '#fff',
        color: '#566a7f'       
    });
        return; 
    }

    // 🎯 검문 통과 시 드래그 시작
    isDragging = true;
    startDay = day;
    endDay = day;

    // 드래그 시작 시 기존 UI 깔끔하게 밀어버리기
    if (typeof clearSelection === 'function') {
        document.querySelectorAll('.calendar-day').forEach(el => el.classList.remove('selected'));
    }
}

function doDrag(day) { 
    if (!isDragging) return;

    // 🛡️ [Giga-Guard 3] 드래그 도중 마우스가 과거로 가도 차단!
    const targetDate = new Date(currentYear, currentMonth, day);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (targetDate < today) return; 

    endDay = day; 
    updateSelection(); 
}

function endDrag() {
    if (!isDragging) return;
    isDragging = false;

    const actualStart = Math.min(startDay, endDay);
    const actualEnd = Math.max(startDay, endDay);

    // 🛡️ [Giga-Sweep] 드래그 영역 내 검문 시작 🦾
    let hasRealBlockedDay = false;
    
    for (let i = actualStart; i <= actualEnd; i++) {
        const dayEl = document.querySelector(`.calendar-day[data-day="\${i}"]`);
        
        if (dayEl && dayEl.classList.contains('disabled')) {
            // 🎯 [Giga-Logic] 주말인지 확인 (0: 일요일, 6: 토요일)
            const d = new Date(currentYear, currentMonth, i);
            const isWeekend = (d.getDay() === 0 || d.getDay() === 6);
            
            // 주말이 아닌데 disabled다? -> 이건 '기존 일정'이나 '공휴일'임! 🚫
            if (!isWeekend) {
                hasRealBlockedDay = true;
                break; 
            }
        }
    }
     // 🛡️ [Check 2] 연차 모드일 때만 잔여량 체크 🦾
    if (currentMode === 'vacation') {
        const totalWorkDays = calculateWorkDays(actualStart, actualEnd);
        
        // 형이 아까 만든 함수 호출!
        if (!checkLeaveBalance(totalWorkDays)) {
            // 연차 부족하면 여기서 컷! (openForm 안 가고 바로 종료)
            if (typeof clearSelection === 'function') clearSelection();
            return; 
        }
    }

    // 🚫 진짜 '안 되는 날'이 포함된 경우만 컷트!
    if (hasRealBlockedDay) {
        Swal.fire({
            icon: 'warning',
            title: '신청 불가',
            text: '이미 일정이 등록된 날짜가 포함되어 있습니다.',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true
        });
        
        if (typeof clearSelection === 'function') clearSelection();
        return; 
    }
   

    // ✨ 주말은 포함되어 있어도 통과! 폼 열기 호출 🦾
    if (typeof openForm === 'function') {
        openForm(actualStart, actualEnd);
    }
}
/* 🎯 [Giga-Logic] 주말 제외 일수 계산 함수 */
function calculateWorkDays(start, end) {
    let count = 0;
    // 시작일부터 종료일까지 루프를 돌며 체크 🦾
    for (let i = start; i <= end; i++) {
        const d = new Date(currentYear, currentMonth, i);
        const dayOfWeek = d.getDay(); // 0: 일요일, 6: 토요일
        
        // 주말이 아닐 때만 카운트 업!
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
            count++;
        }
    }
    return count;
}

function updateSelection() {
    document.querySelectorAll('.calendar-day').forEach(el => {
        const d = parseInt(el.dataset.day);
        const min = Math.min(startDay, endDay || startDay), max = Math.max(startDay, endDay || startDay);
        if (!el.classList.contains('disabled') && d >= min && d <= max) el.classList.add('selected');
        else el.classList.remove('selected');
    });
}
function clearSelection() {
    // 1. 🎨 UI 초기화: 달력에 칠해진 파란색 하이라이트 제거
    document.querySelectorAll('.calendar-day').forEach(el => el.classList.remove('selected'));
    
    // 2. 🧠 데이터 초기화: 드래그 상태와 날짜 변수 리셋
    isDragging = false;
    startDay = null;
    endDay = null; // 만약 네 코드에서 dragEndDay를 쓴다면 그 이름을 써줘!
    
}

function switchView(v) {
    // 1. 뷰 전환 (Giga-Smooth 🦾)
    const calView = document.getElementById('attendance-calendar-view');
    const listView = document.getElementById('application-list-view'); // 아까 우리가 만든 id
    const btnCal = document.getElementById('btn-view-cal');
    const btnList = document.getElementById('btn-view-list');

    if (v === 'list') {
        calView.classList.add('d-none');
        listView.classList.remove('d-none');
        
        // 버튼 활성화 스타일 토글
        if(btnCal) btnCal.classList.remove('active');
        if(btnList) btnList.classList.add('active');

        // 🔥 [핵심] 리스트로 바뀔 때 서버에서 데이터를 새로 긁어온다!
        loadApplicationList(1); 
    } else {
        calView.classList.remove('d-none');
        listView.classList.add('d-none');

        if(btnCal) btnCal.classList.add('active');
        if(btnList) btnList.classList.remove('active');
    }
}

function openForm(s, e) {
    // 1. 🛡️ 메인 컨테이너 강제 노출
    const container = document.getElementById('application-form-container');
    container.style.display = 'block'; 
    
    container.classList.add('show');
    document.getElementById('main-wrapper2').classList.add('pushed');

    // 2. 🧹 모든 개별 폼 일단 숨기기 (초기화)
    document.querySelectorAll('.mode-form').forEach(form => {
        form.style.display = 'none';
    });

    // 3. 📅 날짜 및 일수 계산
    if(s) {
        const actualStart = Math.min(s, e || s);
        const actualEnd = Math.max(s, e || s);
        
        const yStr = `\${currentYear}-\${(currentMonth+1).toString().padStart(2,'0')}-`;
        const startDateStr = yStr + actualStart.toString().padStart(2,'0');
        const endDateStr = yStr + actualEnd.toString().padStart(2,'0');

        // 🔥 [Giga-Chad Point] 평일 일수 계산 소환!
        const totalWorkDays = calculateWorkDays(actualStart, actualEnd);
        

        console.log(`✅ [Giga-Calc] 선택: \${actualStart}~\${actualEnd} | 실제 평일: \${totalWorkDays}일`);

        // 4. 🎯 현재 모드에 따라 폼 보여주기 및 데이터 입력
        if (currentMode === 'vacation') {
            document.getElementById('form-vacation').style.display = 'block';
            document.getElementById('v-start').value = startDateStr;
            document.getElementById('v-end').value = endDateStr;
            document.getElementById('form-title').innerText = "휴가 신청서";
            
            // 🎯 계산된 일수를 'v-days'(예시) 인풋에 자동 입력! 🦾
            const vDaysInput = document.getElementById('v-days');
            if(vDaysInput) vDaysInput.value = totalWorkDays;
        } 
        else if (currentMode === 'trip') {
            document.getElementById('form-trip').style.display = 'block';
            document.getElementById('t-start').value = startDateStr;
            document.getElementById('t-end').value = endDateStr;
            document.getElementById('form-title').innerText = "출장 신청서";
            
            // 출장도 일수 계산이 필요하다면 여기에 추가! 🦾
            const tDaysInput = document.getElementById('t-days');
            if(tDaysInput) tDaysInput.value = totalWorkDays;
        } 
        else if (currentMode === 'overtime') {
            document.getElementById('form-overtime').style.display = 'block';
            document.getElementById('o-date').value = startDateStr;
            document.getElementById('form-title').innerText = "초과근무 신청서";
            
            // 초과근무는 보통 하루 단위니 일수 입력이 필요 없을 수도 있지만, 일관성을 위해!
        }
    }
}


function closeForm() {
    const container = document.getElementById('application-form-container');
    container.classList.remove('show');
    document.getElementById('main-wrapper2').classList.remove('pushed');
    
    // 0.3초 뒤에 완전히 숨기기 (애니메이션 시간 고려)
    setTimeout(() => {
        container.style.display = 'none';
    }, 300);
    clearSelection();
}

function handleCommute(t) { alert(t + ' Success! 🦾'); }
function submitForm() { alert('Application Submitted! 🚀'); closeForm(); }

window.onload = () => { updateClock(); };
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//전역변수자리//
// 1. 페이지 로드 시 버튼 객체 낚아채기 🦾
let btnCheckIn, btnCheckOut, btnOut, btnReturn;

// [1] 전역 변수 설정 (Control Tower) 🦾
let qrModalInstance = null;
let outModalInstance = null;
let returnModalInstance = null;
let checkInterval = null;
let currentMode = null;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

document.addEventListener('DOMContentLoaded', function() {
    btnCheckIn = document.getElementById('btn-checkin');
    btnCheckOut = document.getElementById('btn-checkout');
    btnOut = document.getElementById('btn-out');
    btnReturn = document.getElementById('btn-return');

    // 첫 실행 시 상태 로드
    refreshData()

    // 1. 모든 모달 인스턴스 초기화
    const qrModalEl = document.getElementById('qrModal');
    const outModalEl = document.getElementById('outModal');
    const returnModalEl = document.getElementById('returnModal');

    if (qrModalEl) qrModalInstance = new bootstrap.Modal(qrModalEl);
    if (outModalEl) outModalInstance = new bootstrap.Modal(outModalEl);
    if (returnModalEl) returnModalInstance = new bootstrap.Modal(returnModalEl);

    // 2. 출근 QR 모달 이벤트 (QR 생성 및 폴링)
    if (qrModalEl) {
        qrModalEl.addEventListener('show.bs.modal', function () {
            const qrContainer = document.getElementById("qrcode");
            qrContainer.innerHTML = ""; 
            
            const restApiKey = '';
            const redirectUri = '';
            const kakaoAuthUrl = `https://kauth.kakao.com/oauth/authorize?client_id=\${restApiKey}&redirect_uri=\${redirectUri}&response_type=code`;
            
            new QRCode(qrContainer, { text: kakaoAuthUrl, width: 180, height: 180 });

            if (checkInterval) clearInterval(checkInterval);
            checkInterval = setInterval(() => {
                axios.get("/attendance/checkStatus").then(res => {
                    if (res.data.status === "SUCCESS") {
                        clearInterval(checkInterval);
                        qrModalInstance.hide();
                        onAttendanceSuccess(); 
                    }
                }).catch(err => console.error("QR Check Error:", err));
            }, 2000);
        });

        qrModalEl.addEventListener('hidden.bs.modal', () => {
            if (checkInterval) clearInterval(checkInterval);
        });
    }

    // 3. 외출 확정 버튼 (모달 내부)
    const confirmOutBtn = document.getElementById('confirm-out');
    if (confirmOutBtn) {
        confirmOutBtn.addEventListener('click', function() {
            const reason = document.getElementById('out-reason').value;
            if(!reason.trim()) {
                Swal.fire({ icon: 'warning', title: '입력 확인!', text: '사유를 입력해 주세요!', confirmButtonColor: '#ff9800' });
                return;
            }
            executeAway(reason); // 외출 API 실행
        });
    }

    // 4. 복귀 확정 버튼 (모달 내부)
    const confirmReturnBtn = document.getElementById('confirm-return');
    if (confirmReturnBtn) {
        confirmReturnBtn.addEventListener('click', function() {
            executeBack(); // 복귀 API 실행
        });
    }

    // 5. 실시간 시계 작동
    updateClock();
    setInterval(updateClock, 1000);

    const modeButtons = document.querySelectorAll('.mode-btn');

    modeButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            const clickedMode = this.getAttribute('data-mode');

            // 🎯 [Giga-Check] 이미 선택된 모드를 또 눌렀어? (토글 취소)
            if (currentMode === clickedMode) {
                this.classList.remove('active');
                currentMode = null; // 모드 해제 🧹
                if (typeof closeForm === 'function') closeForm(); // 폼도 닫아주는 Chad의 매너
                return; // 아래 로직 실행 안 하고 여기서 끝!
            }

            // 1. 다른 버튼들 active 싹 다 지우기
            modeButtons.forEach(b => b.classList.remove('active'));
            
            // 2. 현재 버튼 활성화 및 모드 저장
            this.classList.add('active');
            currentMode = clickedMode;
            
            // 3. 지우개 소환 및 로그
            if (typeof clearSelection === 'function') clearSelection();
        });
    });
    // 1. 기존 달력 뷰 찾기 (아이디 두 개 다 체크하는 센스 🦾)
    const calendarView = document.getElementById('attendance-calendar-view') || document.getElementById('calendar-view');
    
    // 2. 목록 뷰 그릇 생성
    const applicationListView = document.createElement('div');
    applicationListView.id = 'application-list-view';
    applicationListView.className = 'card d-none'; // 초기엔 숨김
    
    // 🔥 [Giga-HTML] 검색창이 포함된 카드 헤더와 테이블 구조
    applicationListView.innerHTML = `
        <div class="card-header d-flex justify-content-between align-items-center py-3">
            <h5 class="mb-0 fw-bold">
                <i class="material-icons me-2" style="vertical-align: bottom;">list_alt</i>통합 신청 목록
            </h5>
            
            <div class="d-flex gap-2">
                <select id="searchMode" class="form-select form-select-sm" style="width: 110px;">
                    <option value="">전체 유형</option>
                    <option value="type">유형</option>
                    <option value="reason">사유</option>
                </select>
                <div class="input-group input-group-merge" style="width: 280px;">
                    <input type="text" id="searchKeyword" class="form-control form-control-sm" placeholder="검색어를 입력하세요...">
                    <button type="button" class="input-group-text" onclick="loadApplicationList(1)"><i class="material-icons" style="font-size: 1.1rem;">search</i></button>
                </div>
            </div>
        </div>
        
        <div class="card-body p-0">
            <div class="table-responsive text-nowrap">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4">유형</th>
                            <th>신청 기간 / 일자</th>
                            <th>사유</th>
                            <th class="text-center">상태</th>
                            <th class="text-center pe-4">관리</th>
                        </tr>
                    </thead>
                    <tbody id="application-list-body" class="table-border-bottom-0">
                        </tbody>
                </table>
            </div>
        </div>
        
        <div id="pagination-container" class="card-footer d-flex justify-content-center py-4 bg-transparent border-top-0">
            <ul class="pagination pagination-sm mb-0"></ul>
        </div>
    `;

    // 3. 달력 뒤에 안전하게 꽂기 🦾
    if (calendarView && calendarView.parentNode) {
        calendarView.parentNode.insertBefore(applicationListView, calendarView.nextSibling);
    }
    
    // 3. 삭제 버튼 이벤트 위임 🦾
    applicationListView.addEventListener('click', function(e) {
        const deleteBtn = e.target.closest('.delete-application-btn');
        if (deleteBtn) {
            const docId = deleteBtn.dataset.id;
            Swal.fire({
                title: '삭제하시겠습니까?',
                text: "삭제 후에는 복구가 불가능합니다.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ff3e1d',
                confirmButtonText: '삭제',
                cancelButtonText: '취소'
            }).then((result) => {
                if (result.isConfirmed) {
                    axios.post("/attendance/deleteApplication", { "attTypeId": docId })
                        .then(res => {
                            if(res.data === "success") {
                                Swal.fire('완료', '삭제되었습니다.', 'success');
                                loadApplicationList(1); // 리스트 새로고침
                            }
                        }).catch(err => console.error(err));
                }
            });
        }
    });
});
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//대쉬보드
function updateDashboard() {
    axios.get('/attendance/getDashboardSummary')
        .then(res => {
            const data = res.data;
            if(!data) return;

            // 1. 연차 (잔여 / 전체 느낌으로 가려면 쿼리에서 전체 연차도 가져와야 해! 🦾)
            const remain = data.ANN_LEAVE_REMAIN ?? 0;
            document.getElementById('ann-leave-remain').innerText = `\${remain}/15일`;

            // 2. 출장 건수 🚀
            document.getElementById('month-bztrp-count').innerText = `\${data.BZTRP_COUNT ?? 0}회`;

            // 3. 휴가 건수 🏖️
            document.getElementById('month-vct-count').innerText = `\${data.VCT_COUNT ?? 0}회`;

            // 4. 근무 시간 🦾
            const workTime = data.ATT_MON_TIME ? parseFloat(data.ATT_MON_TIME).toFixed(1) : "0.0";
            document.getElementById('month-work-time').innerText = `\${workTime}h`;

            // 5. 지각 횟수 🚨
            document.getElementById('month-late-count').innerText = `\${data.ATT_LATE_CT ?? 0}회`;
            
        })
        .catch(err => console.error("대쉬보드 로드 실패.. 🚨 서버 로그 확인해봐!", err));
}
// 남은연차를 계산해 드레그를 제한하는 함수
function checkLeaveBalance(requestedDays) {
    // 1. 대시보드에서 잔여 연차 텍스트 가져오기 (예: "12.5") 🦾
    const remainText = document.getElementById('ann-leave-remain').innerText;
    const remainDays = parseFloat(remainText); // 숫자로 변환

    console.log(` 신청일수: \${requestedDays}일 | 잔여연차: \${remainDays}일`);

    // 2. 🛡️ 잔여량보다 많이 긁었는지 체크
    if (requestedDays > remainDays) {
        Swal.fire({
            icon: 'error',
            title: '신청 불가',
            text: `현재 잔여 연차는 \${remainDays}일입니다. 신청 가능 범위를 초과했습니다.`,
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true
        });
        
        return false; // 통과 실패!
    }

    return true; // 통과!
}

// 🧠 오늘 하루의 상세 근태 기록을 가져오는 함수
function fetchTodayDetails() {
    axios.get('/attendance/getTodayDetail') // 👈 동생이 서버에 만들 엔드포인트!
        .then(res => {
            const data = res.data;
            const att = data.attendance; // 출퇴근 VO
            const out = data.outInfo;     // 외출 VO (다른 테이블 데이터)

            // 출퇴근 버튼 업데이트 🦾
            if (att) {
                updateBtnToTime('btn-checkin', att.attCheckIn2, '출근', 'login');
                updateBtnToTime('btn-checkout', att.attCheckOut2, '퇴근', 'logout');
                if (att.attCheckIn2) {
                    const btnIn = document.getElementById('btn-checkin');
                    btnIn.disabled = true; // 못 누르게 막기! 
                }
            }

            // 외출/복귀 버튼 업데이트 (외출 테이블 데이터 사용) 🚀
            if (out) {
                updateBtnToTime('btn-out', out.attOutStartDt2, '외출', 'directions_run');
                updateBtnToTime('btn-return', out.attOutEndDt2, '복귀', 'undo');
                // 2. 🔥 여기가 핵심! 외출 기록이 존재하면 외출 버튼을 죽여버린다!
                if (out.attOutEndDt2) {
                    const btnOut = document.getElementById('btn-out');
                    btnOut.disabled = true; // 못 누르게 막기! 
                }
                // 🔥 복귀 완료(종료 시간)까지 찍혔다면 '복귀' 버튼도 비활성화
                if (out.attOutEndDt2) {
                    const btnReturn = document.getElementById('btn-return');
                    if (btnReturn) btnReturn.disabled = true;
                }
            }
        })
        .catch(err => {
            console.log("오늘 기록이 없음 ", err);
        });
}

// 🛠️ 버튼 내용을 시간으로 바꿔주는 헬퍼 (동생 ID 전용)
function updateBtnToTime(id, time, defaultText, icon) {
    const target = document.getElementById(id);
    if (target) {
        // 시간이 있으면 시간으로, 없으면 원래 텍스트로!
        target.innerHTML = `<span class="material-icons" style="font-size: 1.1rem;">\${icon}</span> \${time ? time : defaultText}`;
    }
}




// 2. 상태값에 따라 UI를 업데이트하는 함수 (형의 원본 Logic + Alpha) 🧠
function updateStatusUI() {
    axios.get('/attendance/currentStatus')
        .then(res => {
            const statusText = res.data.status;
            const statusDiv = document.getElementById('attendance-status'); // 상태 메시지 창
            // [상태별 버튼 제어 가이드] 🦾
            if (statusText === '외출') {
                if(statusDiv) statusDiv.innerHTML = "현재 외출 중입니다 🏃";
                setBtnStatus(true, true, true, false); // 복귀만 가능
            } 
            else if (statusText === '출근' || statusText === '복귀') {
                if(statusDiv) statusDiv.innerHTML = "현재 근무 중입니다 💻";
                setBtnStatus(true, false, false, true); // 퇴근/외출 가능
            } 
            else if (statusText === '퇴근') {
                if(statusDiv) statusDiv.innerHTML = "현재 퇴근 상태입니다. 고생하셨습니다! 🌙";
                setBtnStatus(false, true, true, true); // 출근만 가능
            } 
            else {
                if(statusDiv) statusDiv.innerHTML = "출근 전입니다 ";
                setBtnStatus(false, true, true, true); // 출근만 가능
            }
        })
        .catch(err => console.error("상태 로드 실패!", err));
}

// 3. 버튼 비활성화 헬퍼 (코드 다이어트 🦾)
function setBtnStatus(inDis, outDis, awayDis, backDis) {
    if(btnCheckIn) btnCheckIn.disabled = inDis;
    if(btnCheckOut) btnCheckOut.disabled = outDis;
    if(btnOut) btnOut.disabled = awayDis;
    if(btnReturn) btnReturn.disabled = backDis;
}

/**
 * [STEP 1] 마일리지 계산기 🧮
 * 기능: 출근 시간부터 지금(퇴근)까지 몇 시간 일했는지 계산해서 점수를 매김
 */
function getMileageInfo(inTimeStr) {
    if (!inTimeStr) return { mileage: 0, workTime: "0.0" };

    const now = new Date();
    // 버튼에서 긁어온 "09:00:00"에 오늘 날짜를 붙여서 날짜 객체 생성
    const today = new Date().toISOString().split('T')[0]; 
    const inTime = new Date(`\${today} \${inTimeStr.replace(/-/g, '/')}`);// 오늘 + 출근시간 합체
    
    // 3. 일한 시간 계산 (밀리초 단위 차이를 시간 단위로 변환)
    const diffHrs = (now - inTime) / (1000 * 60 * 60); 
    // 4. 마일리지 산정 기준
    let mileage = 0;
    if (diffHrs >= 8) {
        // 8시간 만근 시 100점 + 초과 시간당 10점
        mileage = 100 + Math.floor((diffHrs - 8) * 10);
    } else {
        // 8시간 미만은 시간당 10점 (예: 7.8시간 = 78점)
        mileage = Math.floor(diffHrs * 10);
    }

    return {
        mileage: mileage,// 계산된 점수
        workTime: diffHrs.toFixed(1)// 소수점 한자리까지(예: 8.5시간)
    };
}

// 메인 핸들러: HTML의 onclick="handleCommute('...')"과 연결
function handleCommute(type) {
    if (type === 'in') {
        if (qrModalInstance) qrModalInstance.show();
    } else if (type === 'out') {
        
        // 🦾 [핵심] 출근 버튼에서 시간 텍스트만 쏙 빼오기
        const attendBtn = document.getElementById('btn-checkin'); // 버튼 ID 확인!
        // 정규표현식으로 숫자랑 콜론(:)만 남기고 다 지워버리는 게 핵심!
        const inTimeStr = attendBtn ? attendBtn.innerText.replace(/[^0-9:]/g, '').trim() : "";

        if (!inTimeStr) {
            Swal.fire('알림', '출근 기록을 찾을 수 없습니다', 'info');
            return;
        }

        const info = getMileageInfo(inTimeStr);
        // 퇴근 버튼 클릭 시 실행되는 컨펌창
        AppAlert.confirm(
            '퇴근하시겠습니까?',
            `오늘 하루도 고생하셨습니다!<br>` +
            `적립 예정 마일리지: <b style="color:#696CFF;">\${info.mileage} M</b>`,
            '퇴근 완료',
            '취소',
            'door_back', // 아이콘 추천: 퇴근/나감
            'primary'
        ).then((result) => {
            if (result.isConfirmed) processCommute('OUT');
        }); // (알람 리팩토링)
    } else if (type === 'away') {
        if (outModalInstance) outModalInstance.show();
    } else if (type === 'back') {
        if (returnModalInstance) returnModalInstance.show();
    }
}

// A. 출근 성공 UI 처리
function onAttendanceSuccess() {
    AppAlert.autoClose(
        '출근 완료!',
        `<b style="color:#696CFF">인증 성공!</b> 오늘 하루도 힘내봅시다!`,
        'rocket_launch', // 아이콘 추천: 활기찬 시작
        'success',
        2000
    ); // (알람 리팩토링)
    refreshData();
}

// B. 퇴근/외출/복귀 실제 API 처리 로직 🦾
function processCommute(type) {
    if (type === 'OUT') {
        axios.post('/attendance/end').then(res => {
            if(res.data.status === 'SUCCESS') {
                // 1. 퇴근 완료 알림
                AppAlert.autoClose(
                    '퇴근 완료!',
                    res.data.message,
                    'task_alt', // 아이콘 추천: 작업 완료
                    'success',
                    1200
                ).then(() => { // (알람 리팩토링)
                    
                    // 🎯 2. 퇴근 알림이 닫히면 바로 로그아웃 물어보기
                    AppAlert.confirm(
                        '로그아웃 하시겠습니까?',
                        '떠나기 전 오늘 업무를 모두 마무리하셨나요?',
                        '로그아웃',
                        '취소',
                        'logout', // 아이콘 추천: 로그아웃
                        'warning'
                    ).then((result) => { // (알람 리팩토링)
                        if (result.isConfirmed) {
                            // 3. 실제 로그아웃 처리
                            axios.post('/logout')
                            .then((res) => {
                                AppAlert.autoClose(
                                    '로그아웃 완료',
                                    '정상적으로 로그아웃 되었습니다.',
                                    'check_circle', // 아이콘 추천: 성공 체크
                                    'success',
                                    1500
                                ).then(() => { // (알람 리팩토링)
                                    location.href = "/";
                                });
                            })
                            .catch((err) => {
                                console.error("로그아웃 실패:", err);
                                AppAlert.error('오류', '로그아웃 처리 중 문제가 발생했습니다.'); // (알람 리팩토링)
                            });
                        } else {
                            refreshData();
                        }
                    });
                });
            } else { 
                AppAlert.error('실패', res.data.message); // (알람 리팩토링)
            }
        }).catch(err => {
            console.error("진짜 에러 원인 발견:", err);
            AppAlert.error('에러', '퇴근 처리 중 문제가 발생했습니다 🥊'); // (알람 리팩토링)
        });
    }
}

// C. 외출 전송 함수
function executeAway(reason) {
    axios.post('/attendance/out/start', { "attOutRsn": reason }).then(res => {
        if(res.data.status === 'SUCCESS') {
            Swal.fire({ icon: 'success', title: '외출 신청 완료!', timer: 1500, showConfirmButton: false });
            outModalInstance.hide();
            refreshData();
        }
    }).catch(err => Swal.fire('에러', '외출 처리 실패', 'error'));
}

// D. 복귀 전송 함수
function executeBack() {
    axios.post('/attendance/out/end').then(res => {
        if(res.data.status === 'SUCCESS') {
            Swal.fire({ icon: 'success', title: '복귀 완료!', timer: 1500, showConfirmButton: false });
            returnModalInstance.hide();
            refreshData();
        }
    }).catch(err => Swal.fire('에러', '복귀 처리 실패', 'error'));
}


// 데이터 새로고침
function refreshData() {
    if (typeof updateStatusUI === 'function') updateStatusUI();
    if (typeof fetchTodayDetails === 'function') fetchTodayDetails();
    if (typeof updateDashboard === 'function') updateDashboard();
    renderCalendar();
}

function updateClock() {
    const clockEl = document.getElementById('real-time-clock');
    if (clockEl) {
        clockEl.textContent = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });
    }
}
///////////////////////////////////////////////////////////////////////////////
//신청목록


// 2. 테이블 렌더링 함수 🦾
function renderTableBody(list) {
    const tbody = document.getElementById('application-list-body');
    let html = "";
    if (!list || list.length === 0) {
        html = '<tr><td colspan="5" class="text-center py-5 text-muted">신청 내역이 존재하지 않습니다.</td></tr>';
    } else {
        list.forEach(item => {
            const isWaiting = (item.status === '대기');
            const isProcessing = (item.status === '신청중');
            const isActive = isWaiting || isProcessing;

            // 🎨 동료가 쓴 그 스타일! bg-label 시리즈로 매칭 🦾
            let statusBadgeClass = "";
            if (item.status === '대기') {
                statusBadgeClass = "bg-label-warning";
            } else if (item.status === '신청중') {
                statusBadgeClass = "bg-label-info";
            } else if (item.status === '반려') {
                statusBadgeClass = "bg-label-danger";
            } else {
                // 결재완료 등 나머지는 primary (또는 success)
                statusBadgeClass = "bg-label-primary";
            }

            const startDate = item.appDate ? item.appDate.substring(0, 10) : "";
            const endDate = item.appEndDate ? item.appEndDate.substring(0, 10) : "";

            html += `
                <tr>
                    <td class="ps-4 fw-bold" style="color: #566a7f;">
                        \${item.type}\${item.vctDocCd ? `(\${item.vctDocCd})` : ''}
                    </td>
                    <td>
                        <div class="d-flex flex-column">
                            <span class="fw-semibold">\${startDate} ~ \${endDate}</span>
                            <small class="text-primary fw-bold">(총 \${item.totalDays || 1}일)</small>
                        </div>
                    </td>
                    <td><span class="text-truncate" style="max-width: 200px; display: inline-block;">\${item.reason}</span></td>
                    <td class="text-center">
                        <span class="badge rounded-pill \${statusBadgeClass}">\${item.status}</span>
                    </td>
                    <td class="text-center pe-4">
                        <div class="d-flex justify-content-center gap-2">
                            \${isActive ? `
                                <a href="\${getApprovalUrl(item)}" 
                                class="btn btn-sm btn-primary \${isProcessing ? 'disabled' : ''}" 
                                style="background-color: #696CFF; border-color: #696CFF; display: inline-flex; align-items: center;"
                                \${isProcessing ? 'onclick="return false;"' : ''}>
                                    <i class="material-icons" style="font-size: 1.1rem; margin-right: 4px;">description</i> 결재
                                </a>

                                \${isWaiting ? `
                                    <button type="button" 
                                            class="btn btn-sm btn-outline-danger delete-application-btn" 
                                            style="background-color: #ffffff; color: #ff3e1d; border: 1.5px solid #ff3e1d; 
                                                width: 32px; height: 32px; 
                                                display: inline-flex; align-items: center; justify-content: center;
                                                padding: 0; transition: all 0.2s ease;"
                                            data-id="\${item.attTypeId}" 
                                            data-type="\${item.type}">
                                        <i class="material-icons" style="font-size: 1.1rem;">delete_outline</i>
                                    </button>` : ''}
                            ` : `
                                <button class="btn btn-sm btn-secondary" disabled style="display: inline-flex; align-items: center; opacity: 0.7;">
                                    <i class="material-icons" style="font-size: 1.1rem; margin-right: 4px;">check_circle</i> 처리완료
                                </button>
                            `}
                        </div>
                    </td>
                </tr>`;
        });
    }
    tbody.innerHTML = html;
}

// 결재 URL 헬퍼 🦾
function getApprovalUrl(item) {
    if (item.type === '휴가') return '/approval/vctAprv?attTypeId=' + item.attTypeId;
    if (item.type === '초과근무') return '/approval/excsAprv?attTypeId=' + item.attTypeId;
    if (item.type === '출장') return '/approval/bztripAprv?attTypeId=' + item.attTypeId;
    return '#';
}

function renderPagination(paging) {
    const paginationArea = document.querySelector('#pagination-container .pagination');
    if (!paginationArea) return;

    let html = "";

    // 1. [Previous] - 1페이지면 클릭 안되게 disabled 🦾
    const prevDisabled = paging.currentPage === 1 ? 'disabled' : '';
    html += `
        <li class="page-item \${prevDisabled}">
            <a class="page-link" href="javascript:void(0);" 
               \${prevDisabled ? '' : `onclick="loadApplicationList(\${paging.currentPage - 1})"`}>
               Previous
            </a>
        </li>`;

    // 2. [Numbers] - 기존 로직 그대로 유지 🦾
    for (let i = paging.startPage; i <= paging.endPage; i++) {
        const activeClass = paging.currentPage === i ? 'active' : '';
        html += `<li class="page-item \${activeClass}">
                    <a class="page-link fw-bold" href="javascript:void(0);" onclick="loadApplicationList(\${i})">\${i}</a>
                 </li>`;
    }

    // 3. [Next] - 마지막 페이지거나 데이터 없으면 disabled 🦾
    const nextDisabled = (paging.currentPage === paging.totalPages || paging.totalPages === 0) ? 'disabled' : '';
    html += `
        <li class="page-item \${nextDisabled}">
            <a class="page-link" href="javascript:void(0);" 
               \${nextDisabled ? '' : `onclick="loadApplicationList(\${paging.currentPage + 1})"`}>
               Next
            </a>
        </li>`;

    paginationArea.innerHTML = html;
}
// 1. 서버에서 신청 목록 가져오는 Giga-Axios 함수 🦾
function loadApplicationList(page = 1) {
    // 검색 조건 읽기 (엘리먼트 없으면 빈값 처리하는 센스)
    const modeEl = document.getElementById('searchMode');
    const keywordEl = document.getElementById('searchKeyword');
    const mode = modeEl ? modeEl.value : "";
    const keyword = keywordEl ? keywordEl.value : "";

    console.log(` Page: \${page} | Mode: \${mode} | Keyword: \${keyword}`);

    // 🔥 실제 서버 통신 시작
    axios.get('/attendance/applicationList', {
        params: {
            currentPage: page,
            mode: mode,
            keyword: keyword
        }
    })
    .then(response => {
        const articlePage = response.data;
        // 우리가 아까 만든 렌더링 함수들 호출!
        if (typeof renderTableBody === 'function') renderTableBody(articlePage.content);
        if (typeof renderPagination === 'function') renderPagination(articlePage);
    })
    .catch(err => {
        console.error("❌ [Giga-Error] 리스트 로드 실패:", err);
        Swal.fire({
            icon: 'error',
            title: '로드 실패',
            text: '데이터를 가져오는 중 문제가 발생했습니다.',
            confirmButtonColor: '#696CFF'
        });
    });
}
//신청서들 insert로직
/* =================================================================
   🎯 [Pure Logic] 주말 제외 일수 계산 함수
   ================================================================= */
function calculateWorkDays(startDateStr, endDateStr) {
    if (!startDateStr || !endDateStr) return 0;
    const start = new Date(startDateStr);
    const end = new Date(endDateStr);
    let count = 0;
    let cur = new Date(start);
    while (cur <= end) {
        const dayOfWeek = cur.getDay(); // 0:일, 6:토
        if (dayOfWeek !== 0 && dayOfWeek !== 6) count++;
        cur.setDate(cur.getDate() + 1);
    }
    return count;
}

/* =================================================================
   ✍️ [DOM Functions] 각 신청서 제출 함수 (HTML onclick 매핑)
   ================================================================= */

// 1. 휴가 신청 (submitVacation) 🦾
function submitVacation() {
    const vctType = document.getElementById('vacation-type').value;
    const startDate = document.getElementById('v-start').value;
    const endDate = document.getElementById('v-end').value;
    const reason = document.getElementById('v-reason').value;

    const totalDays = calculateWorkDays(startDate, endDate);

    if(!reason) return Swal.fire({
            icon: 'warning',
            title: '신청 불가',
            text: '상세 사유를 입력해주세요.',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true
        });

    // 🎯 2. [Giga-Check] 반차인데 1일 초과 선택했을 때 막기 🦾
    if (vctType.includes('반차') && totalDays > 1) {
        return Swal.fire({
            icon: 'warning',
            title: '신청 불가',
            text: '반차는 하루만 선택 가능합니다. 기간을 다시 확인해주세요.',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true
        });
    }
    // 반차는 무조건 종료일을 시작일과 맞추고, 일수는 0.5로 고정한다.
    const isHalfDay = vctType.includes('반차');
    let finalEndDate = isHalfDay ? startDate : endDate;
    let finalTotalDays = isHalfDay ? 0.5 : totalDays;

    const data = {
        "vctDocCd": vctType,
        "vctDocBgng": startDate,
        "vctDocEnd": finalEndDate,
        "vctDocRsn": reason,
        "vctTotalDays": finalTotalDays
    };

    confirmAndSubmit('/attendance/insertVacation', data, '휴가 신청');
}

// 2. 출장 신청 (submitTrip) 🦾
function submitTrip() {
    const location = document.getElementById('t-location').value;
    const startDate = document.getElementById('t-start').value;
    const endDate = document.getElementById('t-end').value;
    const reason = document.getElementById('t-reason').value;

    if(!location) return Swal.fire({
            icon: 'warning',
            title: '신청 불가',
            text: '출장지를 입력해주세요.',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true
        });
    if(!reason) return Swal.fire({
            icon: 'warning',
            title: '신청 불가',
            text: '출장목적 자세히 입력해주세요.',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true
        });

    const totalDays = calculateWorkDays(startDate, endDate);

    const data = {
        "bztrpStart": startDate,
        "bztrpEnd": endDate,
        "bztrpRsn": reason,
        "bztrpPlc": location,
        "bztrpTotalDays": totalDays
    };

    confirmAndSubmit('/attendance/insertTrip', data, '출장 신청');
}

// 3. 초과근무 신청 (submitOvertime) 🦾
function submitOvertime() {
    const otDate = document.getElementById('o-date').value;
    const reason = document.getElementById('o-reason').value;

    if(!otDate) return Swal.fire('Wait!', '근무 일자를 선택해주세요', 'warning');
    if(!reason) return Swal.fire({
            icon: 'warning',
            title: '신청 불가',
            text: '작업 내용을 입력해주세요.',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true
        });

    const data = {
        "excsWorkDocBgng": otDate,
        "excsWorkDocEnd": otDate,
        "excsWorkDocRes": reason
    };

    confirmAndSubmit('/attendance/insertOvertime', data, '초과근무 신청');
}

/* =================================================================
   🛡️ [Common Helpers] 전송 및 결과 처리
   ================================================================= */

// 공통 컨펌창 🦾 (AppAlert 리팩토링 버전)
function confirmAndSubmit(url, data, titleText) {
    const daysInfo = (data.vctTotalDays || data.bztrpTotalDays) 
                    ? ` (총 \${data.vctTotalDays || data.bztrpTotalDays}일)` : '';

    // 아이콘 추천: 'post_add' (문서 신청/등록 느낌)
    AppAlert.confirm(
        titleText + ' 하시겠습니까?',
        `내용을 확인해 주세요.\${daysInfo}`,
        '신청 완료',
        '취소',
        'post_add', 
        'primary'
    ).then((result) => { // (알람 리팩토링)
        if (result.isConfirmed) {
            axios.post(url, data)
                .then(res => handleSuccess(res, titleText))
                .catch(err => {
                    console.error("통신 에러:", err);
                    AppAlert.error('Error!', '서버 통신에 실패했습니다.'); // (알람 리팩토링)
                });
        }
    });
}

// 성공 처리 🦾 (AppAlert 리팩토링 버전)
function handleSuccess(res, titleText) {
    if (res.data.status === 'success') {
        // 아이콘 추천: 'check_circle' (성공)
        AppAlert.success(
            titleText + ' 완료!',
            res.data.message
        ).then(() => { // (알람 리팩토링)
            if (typeof updateDashboard === 'function') updateDashboard();
            if (typeof loadApplicationList === 'function') loadApplicationList(1);
            if (typeof closeForm === 'function') closeForm(); // 폼 닫기 함수 호출
        });
    } else {
        // 아이콘 추천: 'warning_amber' (비즈니스 로직 실패)
        AppAlert.warning('실패', res.data.message); // (알람 리팩토링)
    }
}

//튜토리얼 함수
function startApprovalTutorial() {
    // 1. 🦾 하이라이트할 대상들을 찾아서 영역(Rect) 계산
    const days = document.querySelectorAll('#calendar-grid .calendar-day:nth-child(10), #calendar-grid .calendar-day:nth-child(11), #calendar-grid .calendar-day:nth-child(12)');
    currentMode = 'vacation';

    if (days.length === 0) return;

    // 첫 번째 칸과 마지막 칸의 위치를 계산해서 합치기
    const firstRect = days[0].getBoundingClientRect();
    const lastRect = days[days.length - 1].getBoundingClientRect();

    // 2. 👻 유령 요소(Ghost Element) 생성
    let ghost = document.getElementById('tutorial-ghost');
    if (!ghost) {
        ghost = document.createElement('div');
        ghost.id = 'tutorial-ghost';
        document.body.appendChild(ghost);
    }

    // 유령 요소 스타일링 (위치와 크기 세팅)
    // 스크롤 위치까지 고려해서 절대 좌표로 박아버리기!
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;

    Object.assign(ghost.style, {
        position: 'absolute',
        top: `\${firstRect.top + scrollTop}px`,
        left: `\${firstRect.left + scrollLeft}px`,
        width: `\${(lastRect.right - firstRect.left)}px`,
        height: `\${firstRect.height}px`,
        pointerEvents: 'none', // 클릭 방해 안 되게!
        zIndex: '9999',
        backgroundColor: 'transparent' // 투명하게!
    });


    // 3. 🚀 Driver.js 실행
    const driver = window.driver.js.driver;
    const driverObj = driver({
        showProgress: true,
        animate: true,
        doneBtnText: '완료',
        closeBtnText: '건너뛰기',
        nextBtnText: '다음 ❯',
        prevBtnText: '❮ 이전',
        steps: [
            {
                element: '.mode-btn-group',
                popover: {
                    title: '신청할 결재문서 선택',
                    description: '휴가, 출장, 초과근무 등을 신청하려면 이 버튼을 클릭하세요.',
                    side: "bottom", align: 'start'
                }
            },
            {
                // 🔥 드디어 형이 원하던 '여러 칸 묶음' 타겟팅!
                element: '#tutorial-ghost', 
                popover: {
                    title: '달력 드래그',
                    description: '원하시는 날짜를 마우스로 쭉~ 드래그하여 선택하세요.',
                    side: "top", 
                    align: 'center',
                    offset: 10
                },
                // 🎯 드라이버 2단계 onDeselected 부분
                onDeselected: () => {
                    openForm(10, 12); 
                    
                    const container = document.getElementById('application-form-container');
                    if (container) {
                        // 1. 이미 방패가 있는지 확인하고 없으면 생성
                        let shield = document.getElementById('tutorial-shield');
                        if (!shield) {
                            shield = document.createElement('div');
                            shield.id = 'tutorial-shield';
                            container.appendChild(shield); // 컨테이너 안에 넣기! 🦾
                        }

                        // 2. 방패 스타일: 신청서 전체를 완전히 덮어버림
                        Object.assign(shield.style, {
                            position: 'absolute',
                            top: '0',
                            left: '0',
                            width: '100%',
                            height: '100%',
                            zIndex: '99999',         // 무조건 맨 위로! 🥊
                            backgroundColor: 'rgba(255, 255, 255, 0.01)', // 아주 미세하게 불투명 (클릭 방지용)
                            cursor: 'not-allowed'   // 마우스 커서 변경
                        });
                        
                    }
                }
            },

            
            {
                element: '#application-form-container', 
                popover: { 
                    title: '신청서 자동 완성', 
                    description: '나머지 세부사항을 작성해주세요.', 
                    side: "left",
                    align: 'start'
                }
            }
            
        ],
        // 튜토리얼 끝나면 유령 요소 지우기
        onDestroyed: () => {
            if (ghost) ghost.remove();
            // 방패 제거 🔓
            const shield = document.getElementById('tutorial-shield');
            if (shield) shield.remove();
            closeForm();
            currentMode = null;
        }
    });

    driverObj.drive();
}

</script>