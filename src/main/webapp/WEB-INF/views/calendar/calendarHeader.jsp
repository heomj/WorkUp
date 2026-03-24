<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<meta charset="UTF-8">
<title>WORK UP</title>
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.14/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css">
<script src="https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/js/tabler.min.js"></script>
<style>
    /* --------------- 캘린더 --------------------------------------------------------- */
    #calendar { margin-bottom: 10px; }

    .page-content {background-color:#f5f7fe;}

    /* 좌우 배치 설정 */
    #calendar-container .row {
        display: flex;
        flex-wrap: wrap;
        gap: 0;
        background-color:#f5f7fe;
    }

    /* 컨테이너 설정 */
    .container-xxl {
        max-width: 1800px !important;
        width: 95% !important;
        margin: 0 -30px;
        padding-left: 20px !important;
        padding-right: 20px !important;
    }

    /* 그리드 간격 */
    .row.g-4 {
        --bs-gutter-x: 1.5rem !important;
    }

    /* 캘린더 카드 여백 */
    .col-lg-9 .card {
        padding: 1.5rem !important;
        border-radius: 0.75rem;
        min-height: 1200px;
        max-width: 2000px !important;
    }

    /* 사이드바(오른쪽 메뉴) 너비 및 여백 */
    .col-lg-3 {
        flex: 0 0 25% !important;
        max-width: 25% !important;
    }

    .col-lg-3 .card {
        margin-top: 0 !important;
        border-radius: 0.75rem;
        padding: 5px;
    }


    /* 커스텀 헤더 스타일 */
    .calendar-header-wrapper {
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: #fff;
        padding: 1rem 1.5rem;
        border-radius: 0.5rem;
        box-shadow: var(--bs-card-shadow);
        margin-bottom: 1.5rem;
    }


    /* 툴바 버튼 커스텀 */
    .fc .fc-button-primary {
        background-color: #fff !important;
        border: 1px solid #d9dee3 !important;
        color: #697a8d !important;
        font-weight: 500;
        box-shadow: none !important;
        transition: all 0.2s ease;
    }

    .fc .fc-button-primary:hover {
        background-color: #ebeef0 !important;
        border-color: #d9dee3 !important;
    }

    .fc .fc-button-active {
        background-color: var(--bs-primary) !important;
        border-color: var(--bs-primary) !important;
        color: #fff !important;
    }

    .header-left .title-group {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .header-left h4 {
        margin: 0;
        color: var(--bs-heading-color);
        font-weight: 700;
        font-size: 1.25rem;
    }

    .header-left .badge {
        background: rgba(105, 108, 255, 0.16);
        color: var(--bs-primary);
        padding: 5px 10px;
        border-radius: 4px;
        font-size: 0.75rem;
        font-weight: 600;
    }

    .btn-primary-custom {
        background-color: var(--bs-primary);
        color: #fff;
        border: none;
        padding: 0.6rem 1.25rem;
        border-radius: 0.375rem;
        font-weight: 500;
        cursor: pointer;
        transition: 0.2s;
        display: flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 0.125rem 0.25rem 0 rgba(105, 108, 255, 0.4);
    }

    .btn-primary-custom:hover { transform: translateY(-1px); filter: brightness(1.1); }


    /* 캘린더 날짜 칸 호버 효과 */
    .fc-daygrid-day:hover {
        background-color: rgba(105, 108, 255, 0.05);
        cursor: pointer;
    }

    /* 일정(Event) 스타일 및 애니메이션 */
    .fc-event {
        border: none !important;
        padding: 2px 4px !important;
        border-radius: 4px !important;
        font-size: 0.85rem !important;
        transition: transform 0.2s ease, box-shadow 0.2s ease !important;
    }

    .fc-event:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.15) !important;
    }


    /*  날짜 숫자 정렬 보정 */
    .fc-daygrid-day-number {
        z-index: 5;
        position: relative;
        padding: 4px 8px !important;
        text-decoration: none !important;
    }


    @keyframes pulse-red {
        0% { box-shadow: 0 0 0 0 rgba(255, 62, 29, 0.4); }
        70% { box-shadow: 0 0 0 5px rgba(255, 62, 29, 0); }
        100% { box-shadow: 0 0 0 0 rgba(255, 62, 29, 0); }
    }




    /* 캘린더 날짜 칸 기본 설정 */
    .fc-daygrid-day {
        position: relative;
    }

    /* -------- 공휴일 스타일 ---------- */
    /* 날짜 숫자와 텍스트 정렬 */
    .fc-daygrid-day-top {
        display: flex !important;
        flex-direction: row !important;
        justify-content: flex-end !important;
        align-items: center !important;
        padding-right: 8px !important;
        padding-top: 2px !important;
        flex-direction: column !important;
        align-items: flex-end;
    }

    /* 공휴일 텍스트 정렬 및 레이아웃 수정 */
    .fc-daygrid-day-top {
        display: flex !important;
        flex-direction: column !important;
        align-items: flex-start !important;
        padding-top: 2px !important;
        padding-left: 4px !important;
    }

    /* 공휴일 문구 스타일 */
    .holiday-text-top {
        display: block !important;
        background: none !important;
        color: #ff8e8e !important;
        font-size: 0.7rem !important;
        font-weight: 500 !important;
        margin-top: 0px !important;
        padding-left: 2px !important;
        white-space: nowrap;
    }

    /* 3. 일요일 및 공휴일 숫자 색상 */
    .fc-day-sun .fc-daygrid-day-number,
    .is-holiday-row .fc-daygrid-day-number {
        color: #ff8e8e !important;
        text-decoration: none !important;
    }


    /* 숫자가 너무 커서 겹친다면 간격 조정 */
    .fc-daygrid-day-number {
        padding: 4px 2px !important;
        text-decoration: none !important;
    }



    /* 모든 일정 칩 테두리 제거 및 둥글게 */
    .fc-h-event, .fc-v-event {
        border: none !important;
        box-shadow: none !important;
        margin-top: 1px !important;
        margin-bottom: 1px !important;
        border-radius: 4px !important;
    }


    /* 일요일 및 휴일 숫자 강조 */
    .fc-day-sun .fc-daygrid-day-number {
        color: #ff3e1d !important;
    }

    /* 배경 이벤트 투명도 */
    .fc-daygrid-bg-event {
        opacity: 1 !important;
        background-color: #F4EFFF !important;
    }


    /* 버튼 스타일 */
    #bottomBtn button, .modal-footer button {
        border-radius: 0.375rem;
        padding: 8px 20px;
        font-weight: 600;
        border: none;
        transition: 0.2s;
    }

    #saveBtn, #updateBtn {
        background-color: var(--bs-primary);
        color: white;
    }




    /* 버튼 컨테이너 정렬 */
    #bottomBtn {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    /* 버튼 공통 스타일 */
    .write, .csize {
        height: 30px;
        padding: 0 15px;
        border-radius: 0.375rem;
        font-weight: 600;
        font-size: 0.7rem;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
        cursor: pointer;
        border: none;
        margin-top : 20px;
        vertical-align: middle;
    }

    /* 일정 추가 (Primary) */
    .write {
        background-color: #8e91ff;
        color: white;
        box-shadow: 0 0.125rem 0.25rem 0 rgba(105, 108, 255, 0.4);
    }

    /* + 기호 스타일 정밀 조정 */
    .write .upload-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 1.1rem; /* + 기호만 살짝 키워서 시인성 확보 */
        line-height: 1;    /* 높이값에 영향을 주지 않도록 고정 */
        margin-top: -2px;  /* 시각적으로 중앙에 오도록 미세 조정 (필요시 조절) */
    }

    /* 크기 변경 (Secondary) */
    .csize {
        background-color: #ffffff !important;
        color: #8e91ff !important;
        border: 3px solid #8e91ff !important;
        box-shadow: 0 0.125rem 0.25rem 0 rgba(133, 146, 163, 0.4);
    }

    .write:hover, .csize:hover {
        filter: brightness(1.1);
        transform: translateY(-1px);
    }




    /* 사이드바 내 일정 체크박스 정렬 수정 */
    .card-body .form-check {
        display: flex !important;
        align-items: center !important;
        justify-content: flex-start !important;
        height: auto !important;
        padding: 5px 15px !important;
        gap: 10px !important;
        margin-bottom: 8px !important;
    }

    /* 글자가 세로로 나오는 현상 방지 */
    .card-body .form-check-label {
        margin-top: 0 !important;
        display: flex !important;
        align-items: center !important;
        white-space: nowrap !important;
        font-size: 0.9rem !important;
        line-height: 1.2 !important;
    }

    /* 체크박스 위치 보정 */
    .card-body .form-check-input {
        margin: 0 !important;
        flex-shrink: 0 !important;
    }

    /* 색상 점(Dot) 간격 조절 */
    .card-body .dot {
        margin-right: 8px !important;
        margin-bottom: 0 !important;
    }

    /* 연차/출장 횟수 숫자 스타일 */
    .count-text {
        color: #a1acb8 !important; /* 부드러운 회색 */
        font-size: 0.8rem !important; /* 기본보다 약간 작게 */
        font-weight: 400 !important;  /* 글자 두께를 보통으로 */
        margin-left: 4px;             /* 글자와의 간격 */
        vertical-align: middle;
    }



    #closeBtn { background-color: #ebeef0; color: #697a8d; }


    /* FullCalendar 현대화 및 일정 타입별 분리 스타일 */
    #calendar {
        background: #fff;
        padding: 25px;
        border-radius: 0.75rem;
        box-shadow: var(--bs-card-shadow);
        border: none;
        border: none !important;
    }

    /* 일요일/토요일 색상 */
    .fc-day-sun a { color: #ff3e1d !important; text-decoration: none; }
    .fc-day-sat a { color: #03c3ec !important; text-decoration: none; }

    /* 공통 일정 기본 */
    .fc-event {
        cursor: pointer !important;
        border: none !important;
        font-size: 0.75rem !important;
        margin-top: 1px !important;
        font-weight: 400;
    }


    /* --- 개인 종일 일정: 배경색 --- */
    .fc-daygrid-block-event:not(.share-event) {
        padding: 2px 5px !important;
        border-radius: 4px !important;
    }
    .fc-daygrid-block-event:not(.share-event) .fc-event-title {
        color: #fff !important;
        font-weight: 400;
        font-size: 0.9rem !important;
    }

    /* --- 공유 일정: 하단 테두리 선만 표시 --- */
    .share-event {
        border-radius: 4px !important;
        background-color: rgba(105, 108, 255, 0.1) !important;
    }

    .share-event .fc-event-main { background-color: transparent !important; }
    .share-event .fc-event-title {
        color: #333 !important;
        font-weight: 400 !important;
        font-size: 0.7rem !important;
    }


    /* ------ [일정 색상] ------- */
    .fc-daygrid-dot-event {
        background-color: var(--fc-event-bg-color, #8e91ff) !important;
        padding: 3px 6px !important;
        border-radius: 4px !important;
        border: none !important;
        margin-bottom: 2px !important;
    }



    .share-event .fc-event-title,
    .share-event .fc-event-time {
        color: #566a7f !important;
    }



    /* 모달 및 컬러팔레트 */
    #addSchedule {
        background-color: rgba(38, 43, 67, 0.5);
        backdrop-filter: blur(4px);
    }

    .modal-content-card {
        background-color: white;
        margin: 5% auto;
        width: 450px;
        border-radius: 0.75rem;
        box-shadow: 0 0.5rem 2rem 0 rgba(0, 0, 0, 0.2);
        overflow: hidden;
    }

    .color-palette { display: flex; gap: 10px; margin-top: 10px; }
    .color-item input { display: none; }
    .color-item span {
        width: 28px; height: 28px; border-radius: 50%; display: block;
        cursor: pointer; border: 3px solid #fff; box-shadow: 0 0 0 1px #d9dee3;
    }
    .color-item input:checked + span { box-shadow: 0 0 0 2px var(--bs-primary); transform: scale(1.1); }

    input, select, textarea {
        width: 100%; padding: 10px; margin-bottom: 15px;
        border: 1px solid #d9dee3; border-radius: 0.375rem; box-sizing: border-box;
    }
    input:focus { border-color: var(--bs-primary); outline: none; }



    /* 공유 대상 버튼 -------------------- */
    #bottomBtn button,
    .modal-footer button,
    #share{
        border-radius: 0.375rem;
        padding: 8px 20px;
        font-weight: 600;
        border: none;
        transition: all 0.2s ease;
        cursor: pointer;
        font-size: 0.85rem;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }

    /* 메인 강조 버튼-일정 추가, 저장, 수정 */
    #saveBtn, #updateBtn{
        background-color: var(--bs-primary);
        color: white;
        box-shadow: 0 0.125rem 0.25rem 0 rgba(105, 108, 255, 0.4);
    }

    #saveBtn:hover, #updateBtn:hover, #deleteBtn:hover, #closeBtn:hover{
        filter: brightness(1.1);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px 0 rgba(105, 108, 255, 0.4);
    }

    #closeBtn{
        background-color: #ffffff;
        color: #8e91ff !important;
        border: 1px solid #8e91ff;
    }

    /* 일정 공유 버튼 */
    #share {
        background-color: transparent;
        color: var(--bs-primary);
        border: 1px solid var(--bs-primary);
        width: auto;
    }

    #share:hover {
        background-color: rgba(105, 108, 255, 0.08);
        transform: translateY(-1px);
    }


    /* 일정 공유시 대상 목록 출력 영역 ---------------------- */
    /* 선택된 사용자 배지 스타일 */
    .user-badge {
        background-color: rgba(105, 108, 255, 0.1);
        color: #8e91ff;
        padding: 4px 10px;
        border-radius: 50px;
        font-size: 0.75rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 5px;
        border: 1px solid rgba(105, 108, 255, 0.2);
    }

    .user-badge .remove-user {
        cursor: pointer;
        font-size: 1rem;
        line-height: 1;
        color: #ff3e1d;
    }

    .user-badge .remove-user:hover {
        filter: brightness(0.8);
    }

    /* 크기 변경 버튼 */
    .csize {
        background-color: #8592a3;
        color: white;
        box-shadow: 0 0.125rem 0.25rem 0 rgba(133, 146, 163, 0.4);
        border: none !important;
    }

    /* 삭제 버튼 */
    #deleteBtn {
        background-color: var(--bs-danger);
        color: white;
    }

    /* 닫기 버튼 */
    #closeBtn {
        background-color: #ebeef0;
        color: #697a8d;
    }

    #closeBtn:hover {
        color: white;
        box-shadow: 0 0.125rem 0.25rem 0 rgba(133, 146, 163, 0.4);
        border: none !important;
    }



    /* 중요 일정 별 모양 토글 */
    .important-container {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 20px;
    }

    /* 실제 체크박스는 숨김 */
    #importantBtn {
        display: none;
    }

    /* 별 모양 아이콘 스타일 */
    .star-toggle {
        font-size: 1.1rem;
        cursor: pointer;
        color: #d9dee3;
        transition: all 0.2s ease;
        line-height: 1;
    }

    /* 체크됐을 때 (체크박스가 체크되면 바로 다음 label 안의 아이콘 변경) */
    #importantBtn:checked + .star-toggle {
        color: #ffab00;
        transform: scale(1.2);
        filter: drop-shadow(0 0.125rem 0.15rem rgba(255, 171, 0, 0.4));
    }

    /* 체크 여부에 따라 아이콘 모양 변경 */
    .star-toggle::before {
        content: '☆';
        filter: drop-shadow(0 2px 4px rgba(133, 146, 163, 0.3));
    }

    #importantBtn:checked + .star-toggle::before {
        content: '★';
    }

    .important-label {
        cursor: pointer;
        font-weight: 600;
        color: #566a7f;
        font-size: 0.9rem;
    }

    /* 중요 일정 이벤트 */
    .fc-event.important-event {
        animation: pulse-red 2s infinite;
    }

    @keyframes pulse-red {
        0% { box-shadow: 0 0 0 0 rgba(255, 62, 29, 0.4); }
        70% { box-shadow: 0 0 0 6px rgba(255, 62, 29, 0); }
        100% { box-shadow: 0 0 0 0 rgba(255, 62, 29, 0); }
    }



    /* 날짜 및 시간 선택 가로 배열 */
    .datetime-group {
        display: flex;
        gap: 10px;
        align-items: flex-end;
    }
    .datetime-item {
        flex: 1;
    }

    /* 이미지 첨부 영역 디자인 */
    .file-upload-wrapper {
        margin-top: 8px;
    }
    .file-upload-btn {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 20px;
        border: 2px dashed #d9dee3;
        border-radius: 0.5rem;
        background-color: #f9fafb;
        cursor: pointer;
        transition: all 0.2s ease-in-out;
    }

    .file-upload-btn:hover {
        border-color: var(--bs-primary);
        background-color: rgba(105, 108, 255, 0.04);
    }

    .file-upload-btn .upload-icon {
        font-size: 1.5rem;
        margin-bottom: 8px;
        color: #a1acb8;
    }

    #fileNameDisplay {
        font-size: 0.85rem;
        color: #697a8d;
        font-weight: 500;
    }

    /* 공유 버튼 스타일 */
    #share {
        border-radius: 0.375rem;
        padding: 8px 20px;
        font-weight: 600;
        border: 1px solid var(--bs-primary);
        background-color: transparent;
        color: var(--bs-primary);
        transition: 0.2s;
        cursor: pointer;
        margin-bottom: 20px;
    }
    #share:hover {
        background-color: rgba(105, 108, 255, 0.08);
    }

    /* 부서 전체 선택 버튼 커스텀 */
    .allSelectBtn, .myCalBtn {
        width: 100%;
        padding: 5px 0;
        background-color: #f0f2ff;
        color: #8e91ff;
        border: 1px solid #e0e4ff;
        border-radius: 0.375rem;
        font-size: 0.85rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
    }

    .allSelectBtn:hover, .myCalBtn:hover {
        background-color: #8e91ff;
        color: #ffffff;
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(105, 108, 255, 0.2);
    }

    .allSelectBtn:active, .myCalBtn:active {
        transform: translateY(0);
    }

    :root {
        --bs-primary: #8e91ff;
        --bs-secondary: #8592a3;
        --bs-success: #71dd37;
        --bs-danger: #ff3e1d;
        --bs-warning: #ffab00;
        --bs-info: #03c3ec;
        --bs-card-shadow: 0 2px 6px 0 rgba(67, 89, 113, 0.12);
        --bs-heading-color: #566a7f;
        --bs-body-bg: #f5f5f9;
        --bs-holiday-bg: #FFEBEB;   /* 공휴일 배경 */
        /*   --bs-holiday-text: #ff3e1d; 휴일 글자색 */
    }

    body {
        padding: 0;
    }


    .row.g-4 {
        --bs-gutter-x: 1.5rem; /* 간격을 표준화 */
    }

    /* 시간 일정의 점(dot)을 완전히 제거 */
    .fc-daygrid-event-dot,
    .fc-list-event-dot,
    .fc-daygrid-dot-event .fc-event-main::before {
        display: none !important;
    }

    /* 점 방식의 일정을 박스 방식으로 강제 전환 */
    .fc-daygrid-dot-event {
        background-color: var(--fc-event-bg-color, #8e91ff) !important;
        padding: 2px 5px !important;
        border-radius: 4px !important;
        display: flex !important;
        align-items: center;
        margin-top: 1px !important;
    }

    /* 시간 및 제목 텍스트 색상 */
    .fc-daygrid-dot-event .fc-event-time,
    .fc-daygrid-dot-event .fc-event-title {
        font-weight: 500 !important;
        text-decoration: none !important;
    }



    /* Dot 스타일 */
    .dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        display: inline-block;
        background-color: currentColor;
        margin-right: 10px;
        flex-shrink: 0;
    }


    /* FullCalendar에서 배경 이벤트의 투명도 조절 */
    .fc-daygrid-bg-event {
        opacity: 0.8 !important;
    }

    /* 주말(일요일) 기본 색상 */
    .fc-day-sun .fc-daygrid-day-number {
        color: var(--bs-danger) !important;
    }

    /* 체크박스 스타일 */
    .form-check-input {
        width: 1.2em;
        height: 1.2em;
        margin-top: 0;
        cursor: pointer;
        border: 2px solid #d9dee3;
    }

    .form-check-input:checked {
        background-color: #8e91ff;
        border-color: #8e91ff;
    }

    /* 정렬: 체크박스가 오른쪽으로, Dot이 왼쪽으로 */
    .form-check {
        display: flex !important;
        flex-direction: row;
        justify-content: flex-start;
        align-items: center !important;
        padding: 10px 40px;
        border-radius: 8px;
        transition: background 0.2s;
        gap: 10px;
        height : 10px;
    }




    .form-check-label {
        display: flex;
        align-items: center;
        cursor: pointer;
        flex-grow: 1;
        margin-bottom: 0;
        margin-top:-20px;
    }

    /* 체크박스 자체 스타일 */
    .form-check-input {
        margin-top: 0;
        cursor: pointer;
        border: 2px solid #d9dee3;
    }

    /* 사이드바 배지 스타일 */
    .bg-label-info { background-color: #e7f7ff; color: #00bad1; }
    .bg-label-secondary { background-color: #ebeef0; color: #8592a3; }

    /* 캘린더 내부 타이틀 폰트 조절 */
    .fc .fc-toolbar-title {
        font-size: 1.25rem;
        font-weight: 700;
    }

    /* 캘린더 헤더 간격 조정 */
    .fc-header-toolbar {
        margin-bottom: 1.5rem !important;
    }


    /*------------- 오른쪽 메뉴 ---------------------- */
    .member-item {
        height : 10px;
        align-items: center;
        display: flex;
    }

    /* 멤버 리스트 스크롤바 디자인 */
    .member-list-scroll::-webkit-scrollbar {
        width: 4px;
    }

    .member-list-scroll .member-item:first-child {
        margin-top: 10px !important;
        padding-top: 10px !important;
    }

    /* 스크롤 영역 내부의 첫 번째 요소가 가려지는 현상 방지 */
    .member-list-scroll {
        padding-top: 5px !important;
        overflow-y: auto;
    }

    .member-list-scroll::-webkit-scrollbar-thumb {
        background: #d9dee3;
        border-radius: 10px;
    }
    .member-check:checked + label {
        font-weight: 600;
        color: #8e91ff;
    }
    .bg-soft-primary { background-color: rgba(105, 108, 255, 0.1); }

    /* 카드 헤더 스타일 통일 */
    .card-header {
        border-bottom: 1px solid #f0f2f4 !important;
    }

    .card-body{
        margin-top:15px;
    }

    /* 사이드바 카드 */
    .card-header h5 {
        font-size: 1rem;
    }
    .badge{
        margin-right:10px;
    }
    .user-badge {
        background-color: #e7eef8;
        color: #8e91ff;
        padding: 5px 12px;
        border-radius: 50px;
        font-size: 13px;
        display: flex;
        align-items: center;
    }
    .remove-user {
        margin-left: 8px;
        cursor: pointer;
        font-weight: bold;
    }

    /* 파일 업로드, 미리보기 */
    .file-upload-btn {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 25px;
        border: 2px dashed #ebedef;
        border-radius: 10px;
        background-color: #fcfcfd;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .file-upload-btn:hover {
        background-color: #f3f4f6;
        border-color: #d1d5db;
    }

    .upload-icon {
        font-size: 30px;
        margin-bottom: 8px;
    }


    /* 입력창 커서 자동 이동 */
    .form-control:focus, .form-select:focus {
        border-color: #8e91ff !important;
        box-shadow: 0 0 0 0.2rem rgba(142, 145, 255, 0.25) !important;
        outline: none;
    }



    /* --------------------- [공유 대상 선택 모달 스타일] --------------------------- */

    /* 선택완료 버튼 */
    #confirmShare {
        background-color: #ffffff;
        color: #8e91ff !important;
        border: 1px solid #8e91ff;
    }

    #confirmShare:hover{
        filter: brightness(1.1);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px 0 rgba(105, 108, 255, 0.4);
    }


    /* 조직도 모달 헤더 스타일 */
    #orgChartModal .modal-content {
        position: relative;
        padding-top: 40px;
    }

    /* 닫기(x) 버튼 스타일 */
    #closeOrgModal {
        position: absolute;
        top: 15px;
        right: 20px;
        font-size: 1.5rem;
        cursor: pointer;
        color: #8592a3;
        transition: color 0.2s;
        border: none;
        background: none;
    }

    #closeOrgModal:hover {
        color: #5f61e6;
    }


    #allDeleteBtn {
        background-color: #ffffff;
        color: #8e91ff !important;
        border: 1px solid #8e91ff;
        border-radius: 0.375rem;
        padding: 5px 8px !important;
        display: block;
        margin-left: auto;
        margin-right: 0;
        text-align: right;
        margin-top: 10px;
    }

    #allDeleteBtn:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 8px 0 rgba(105, 108, 255, 0.4);
    }


    /* 탭 컨테이너 가로 배치 */
    .share-tab-group {
        display: flex;
        position: relative;
        background-color: #f1f3f5;
        border-radius: 8px;
        padding: 4px;
        z-index: 1;
    }

    /* 실제 라디오 인풋은 숨김 */
    .share-input {
        display: none;
    }

    /* 라벨(글씨 영역) 디자인 */
    .share-label {
        flex: 1;
        text-align: center;
        padding: 10px 0;
        font-weight: 600;
        color: #495057;
        cursor: pointer;
        z-index: 2;
        transition: color 0.3s ease;
        margin-bottom: 0; /* 라벨 기본 여백 제거 */
    }

    /* 체크되었을 때의 글자색 */
    .share-input:checked + .share-label {
        color: #8e91ff;
        background-color: #ffffff;
        border-radius: 6px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .share-label:hover {
        color: #8e91ff;
    }

    /* 배지 기본 스타일 */
    .share-badge {
        padding: 4px 12px;
        border-radius: 50px;
        color: #566a7f !important;
        background-color: #FFFFFF !important;
        margin: 2px;
        font-size: 13px;
        font-weight: 400; /* 폰트 두께 일반 */
        border: 1px solid #d9dee3;
        display: inline-flex !important;
        align-items: center;
        transition: all 0.2s ease;
        cursor: default;
    }

    /* 배지 전체 호버 */
    .share-badge:hover {
        background-color: rgba(105, 108, 255, 0.08) !important;
        border-color: #8e91ff !important;
    }

    /* 내부 아이콘 기본 색상 */
    .share-badge .fa-user {
        color: #8592a3;
        margin-right: 6px;
    }

    .share-badge .fa-times {
        color: #d9dee3;
        margin-left: 8px;
        cursor: pointer;
        transition: color 0.2s;
    }

    /* 닫기 아이콘에 마우스 올렸을 때 */
    .share-badge .fa-times:hover {
        color: #5f61e6 !important;
    }


    /* ---- 체크박스, 체크한 영역 스타일 ----- */
    .form-check-input:checked {
        background-color: #8e91ff !important;
        border-color: #8e91ff !important;
    }

    /* ---- 리스트 그룹: 체크 시 배경색 안 생기게 처리 ---- */
    .list-group-item:has(.form-check-input:checked) {
        background-color: transparent !important;
        border-color: #d9dee3 !important;
    }

    /* ---- jsTree: 선택 시 배경색 제거 ---- */
    /* 글자 부분 클릭 시 배경 제거 */
    .jstree-clicked {
        background: transparent !important;
        color: #8e91ff !important;
        box-shadow: none !important;
    }

    /* 한 줄 전체 클릭 시 배경 제거 */
    .jstree-wholerow-clicked {
        background: transparent !important;
    }

    /* 부서 리스트 배경 및 테두리 초기화 */
    #deptListGroup .list-group-item {
        background-color: transparent !important;
        border: none !important;
        border-bottom: 1px solid #f2f2f2 !important;
        box-shadow: none !important;
        outline: none !important;
        padding: 2px 10px !important;
        display: flex !important;
        align-items: center !important;
    }


    /* 체크박스 크기 조절 */
    #deptListGroup .form-check-input {
        margin-bottom:8px;
        margin-right: 3px;
    }

    /* 호버 시에만 아주 미세한 변화 (선택 사항) */
    #deptListGroup .list-group-item:hover {
        background-color: rgba(142, 145, 255, 0.02) !important;
    }

    /* 체크박스 선택 시에도 배경색이 바뀌지 않도록 고정 */
    #deptListGroup .list-group-item:has(.form-check-input:checked) {
        background-color: transparent !important;
    }

    /* 부서원 수 숫자를 위한 스타일 */
    .dept-count {
        font-size: 0.8rem;
        color: #a1acb8;
        font-weight: 400;
        margin-left: 4px;
    }



    /* ---------- alert --------------------- */
    /* 알림 컨테이너 */
    #globalAlertContainer {
        position: fixed;
        top: 30px;
        right: 30px;
        z-index: 9999;
    }

    /* 토스트 기본 스타일 */
    .custom-toast {
        display: flex;
        align-items: center;
        min-width: 300px;
        padding: 15px 20px;
        margin-bottom: 10px;
        background: #ffffff;
        border-radius: 12px;
        box-shadow: 0 8px 20px rgba(142, 145, 255, 0.15);
        border-left: 5px solid #8e91ff;
        animation: toastSlideIn 0.15s ease-out;
        transition: all 0.3s ease;
    }

    @keyframes toastSlideIn {
        from { transform: translateX(50%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }

    /* 상태별 색상 (성공/경고/삭제) */
    .custom-toast.success { border-left: 5px solid #8e91ff; }
    .custom-toast.success .toast-icon { color: #8e91ff; }

    .custom-toast.warning { border-left: 5px solid #ffab00; }
    .custom-toast.warning .toast-icon { color: #ffab00; }

    .custom-toast.danger { border-left: 5px solid #ff3e1d; }
    .custom-toast.danger .toast-icon { color: #ff3e1d; }

    /* 아이콘 & 텍스트 */
    .toast-icon {
        font-size: 1.2rem;
        margin-right: 12px;
        color: #8e91ff;
    }
    .toast-message {
        color: #566a7f;
        font-weight: 500;
        font-size: 14px;
        flex-grow: 1;
    }
    .toast-close {
        cursor: pointer;
        color: #d9dee3;
        margin-left: 10px;
    }
    .toast-close:hover { color: #566a7f; }

    .toast-exit {
        opacity: 0;
        transform: scale(0.9);
        transition: all 0.15s ease-in;
    }




    /* ------------------------------------------------------------- */
    /* ---- 도움말 ------ */
    .help-icon {
        display: inline-block;
        position: relative;
        font-size: 0.8rem;
        color: #b4bdc6;
        cursor: help;
        margin-left: 8px;
        vertical-align: middle;
    }

    /* 오른쪽 툴팁 본체 */
    .help-icon::after {
        content: attr(data-help);
        position: absolute;
        left: 140%;
        top: 50%;
        transform: translateY(-50%);
        background-color: #435971;
        color: #ffffff !important;
        padding: 8px 12px;
        border-radius: 6px;
        font-size: 12px;
        line-height: 1.4;
        z-index: 1060;
        width: max-content;
        max-width: 250px;
        white-space: normal;
        display: block;
        visibility: hidden;
        opacity: 0;
        transition: all 0.2s ease;
    }

    /* 왼쪽 화살표 (오른쪽을 향함) */
    .help-icon::before {
        content: '';
        position: absolute;
        left: 110%;
        top: 50%;
        transform: translateY(-50%);
        border: 6px solid transparent;
        border-right-color: #435971;
        visibility: hidden;
        opacity: 0;
        z-index: 1061;
    }

    /* 마우스 호버 시 효과 */
    .help-icon:hover::after {
        visibility: visible;
        opacity: 1;
        left: 150%;
    }

    .help-icon:hover::before {
        visibility: visible;
        opacity: 1;
        left: 120%;
    }




    /* 도움말 아이콘 컨테이너 */
    .help-icon2 {
        position: relative;
        cursor: pointer;
        margin-left: 5px;
        display: inline-block;
        color: #b4bdc6;
    }

    /* 도움말 박스 (실제 텍스트 영역) */
    .help-icon2::after {
        content: attr(data-help);
        position: absolute;
        bottom: 125%;
        left: 50%;
        transform: translateX(-50%);
        background-color: #435971;
        color: #fff;
        padding: 8px 12px;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 400;
        white-space: nowrap;
        z-index: 1000;
        visibility: hidden;
        opacity: 0;
        transition: all 0.2s ease-in-out;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    /* 아래쪽 화살표 꼬리 */
    .help-icon2::before {
        content: '';
        position: absolute;
        bottom: 110%;
        left: 50%;
        transform: translateX(-50%);
        border-width: 6px;
        border-style: solid;
        border-color: rgba(30, 41, 59, 0.9) transparent transparent transparent;
        visibility: hidden;
        opacity: 0;
        transition: all 0.2s ease-in-out;
        z-index: 1000;
    }

    /* 마우스 호버 시 위쪽으로 나타나게 함 */
    .help-icon2:hover::after,
    .help-icon2:hover::before {
        visibility: visible;
        opacity: 1;
        bottom: 140%;
    }

    /* 화살표 위치 보정 */
    .help-icon2:hover::before {
        bottom: 125%;
    }



    /* 외부 일정 모달창 스타일 */
    /* 닫기 버튼 호버 효과 */
    #anotherListViewBtn:hover { filter: brightness(90%); box-shadow: 0 4px 8px rgba(0,0,0,0.15); cursor: pointer; }
    #anotherListViewBtn:active { transform: translateY(0); }





    /* ---[헤더]------------------------------- */

    /* 드롭다운 메뉴 위치 및 간격 최적화 */
    .dropdown-menu.show {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
        position: absolute !important;
        inset: auto 0 auto auto !important;
        top: 100% !important;
        margin-top: 2px !important;
        padding: 0 !important;
        transform: none !important;

        z-index: 9999 !important;
    }

    .dropdown-menu .dropdown-header-custom {
        padding: 10px 15px !important;
    }


    .calendar-header-wrapper .dropdown-menu.show {
        display: block !important;
        position: absolute !important;
        inset: auto 0 auto auto !important;
        top: 45px !important;
        margin: 0 !important;
        padding: 0 !important;

        z-index: 9999 !important;
        transform: none !important;
    }

    .calendar-header-wrapper .dropdown-menu::before {
        display: none !important;
    }





</style>
