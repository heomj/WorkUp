<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<%@ page import="java.util.Date"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 튜토리얼 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.css"/>
<script src="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.js.iife.js"></script>

<!-- 알람 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="/js/common-alert.js"></script>



<style>

    /* 🚨 결재 페이지 전용 레이아웃 붕괴 방지 (main-wrapper 폭 제한 해제) */
    .main-wrapper {
        width: auto !important;
    }


    :root {
        --bs-card-border-radius: 0.625rem;
        --bs-card-box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        /* main.css의 배경색을 변수로 지정 */
        --bs-body-bg: #f4f7ff;
    }

    body {
        background-color: var(--bs-body-bg) !important;
        display: block !important;
        font-family: "Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
    }

    .main-content {
        width: 100% !important;

        display: block !important;
        background-color: transparent !important;
    }

    .card {
        border: none;
        border-radius: var(--bs-card-border-radius);
        box-shadow: var(--bs-card-box-shadow);
    }

    .clickable-card {
        cursor: pointer;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .clickable-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1) !important;
    }

    /* 상태별 배지 및 테두리 색상 */
    .bg-label-primary { background-color: #e7e7ff !important; color: #696cff !important; }
    .bg-label-success { background-color: #e8fadf !important; color: #71dd37 !important; }
    .bg-label-danger { background-color: #ffe5e5 !important; color: #ff3e1d !important; }
    .bg-label-warning { background-color: #fff2d6 !important; color: #ffab00 !important; }
    .bg-label-info { background-color: #d7f5fc !important; color: #03c3ec !important; }
    .bg-label-secondary { background-color: #ebeef0 !important; color: #8592a3 !important; }

    .border-primary { border-color: #696cff !important; }
    .border-warning { border-color: #ffab00 !important; }
    .border-info { border-color: #03c3ec !important; }
    .border-success { border-color: #71dd37 !important; }
    .border-secondary { border-color: #8592a3 !important; }

    .avatar-soft {
        width: 42px;
        height: 42px;
        display: flex;
        align-items: center;
        justify-content: center;
    }


    /* 모달 및 기타 UI 유지 */
    .modal-content {
        border-radius: 0.75rem;
    }

    .list-group-item-action {
        transition: all 0.2s;
    }

    .list-group-item-action:hover {
        background-color: #f8f9ff;
        color: #696cff;
        padding-left: 1.5rem;
    }


    /* ///// 🤍 깔끔한 화이트톤 결재 정보 스타일 (동료 UI 오마주) ///// */

    /* 타임라인 전용 스타일 */
    .timeline-container {
        position: relative;
        padding-left: 3.5rem;
        margin-top: 1.5rem;
    }

    /* 타임라인 세로 연결선 (튀는 파란색 -> 은은한 그레이톤) */
    .timeline-container::before {
        content: '';
        position: absolute;
        top: 10px;
        bottom: 0;
        left: 27px;
        width: 2px;
        background-color: #E2E8F0;
        z-index: 0;
    }

    .timeline-item {
        position: relative;
        margin-bottom: 2rem;
        z-index: 1;
    }

    /* 프로필 이미지 아이콘 (테두리 빼고 부드러운 그림자 추가) */
    .timeline-icon {
        position: absolute;
        left: -3rem;
        top: 0;
        width: 42px;
        height: 42px;
        border-radius: 50%;
        background-color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08); /* 부드러운 그림자 유지 */
    }

    .timeline-icon img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    /* 🟣 기안자 및 결재 완료 (메인 보라색 테두리) */
    .timeline-icon.approved {
        border: 2px solid #696cff;
    }

    /* 🔴 반려 (빨간색 테두리) */
    .timeline-icon.rejected {
        border: 2px solid #E53E3E;
    }

    /* ⚪ 대기 상태 (회색 테두리 + 흑백 처리) */
    .timeline-icon.pending {
        border: 2px solid #E2E8F0;
        filter: grayscale(100%);
        opacity: 0.5;
        box-shadow: none; /* 대기 중엔 그림자를 빼서 얌전하게 */
    }



    /* 의견 말풍선 박스 (퓨어 화이트 + 깔끔한 테두리) */
    .comment-box {
        background-color: #ffffff;
        border-radius: 12px; /* 동료 코드처럼 둥글게 */
        padding: 0.85rem 1.2rem;
        font-size: 0.85rem;
        margin-top: 0.8rem;
        border: 1px solid #E2E8F0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.02);
    }

    /* 승인 의견 선 (보라색 포인트) */
    .comment-box.approve {
        border-left: 4px solid #696cff;
    }

    /* 반려 의견 선 (빨간색 포인트) */
    .comment-box.reject {
        border-left: 4px solid #E53E3E;
        background-color: #FFF5F5;
        border-color: #FFE5E5;
        color: #C53030;
    }

    /* 🏷️ 동료 스타일 상태 뱃지 */
    .status-badge-clean {
        padding: 4px 12px;
        font-size: 0.75rem;
        border-radius: 20px;
        font-weight: 800;
        display: inline-block;
        letter-spacing: -0.3px;
    }

    /* 상태별 뱃지 컬러 (파스텔톤 배경 + 쨍한 글씨) */
    .bg-clean-info { background: #EDF2F7; color: #718096; } /* 대기 - 차분한 회색 */
    .bg-clean-primary { background: #EBF2FF; color: #696cff; } /* 승인 - 메인 보라색 */
    .bg-clean-danger { background: #FFF5F5; color: #E53E3E; } /* 반려 - 붉은색 */


    /* 🏷️ 업무 태그 전용 사각 뱃지 (메인 컬러 #696cff 베이스) */
    .work-tag-badge {
        display: inline-flex;
        align-items: center;
        background-color: #f0f2ff; /* 메인 컬러의 아주 연한 파스텔톤 배경 */
        color: #696cff; /* 메인 텍스트 컬러 */
        border: 1px solid #d9dcff; /* 텍스트보다 살짝 연한 은은한 테두리 */
        border-radius: 6px; /* 동료 핏: 네모 반듯하면서 끝만 살짝 부드럽게 */
        padding: 4px 10px;
        font-size: 0.75rem;
        font-weight: 700;
        letter-spacing: -0.3px;
        margin-bottom: 8px;
        box-shadow: 0 2px 4px rgba(105, 108, 255, 0.05); /* 메인 컬러 톤의 옅은 그림자 */
    }



    /* ///// 스타일 끝 ///// */


    /* --- 전자결재 전용 카드 스타일 (다른 메뉴와 절대 안 겹침!) --- */

    .aprv-dash-card {
        height: 75px !important;
        background-color: #ffffff !important; /* 배경색을 무조건 퓨어 화이트로 강제 고정! */
    }

    .aprv-dash-card .card-body {
        padding: 0 24px !important; /* 좌측 여백 넉넉하게 */
        display: flex !important;
        align-items: center !important; /* 수직(위아래) 중앙 정렬 */
        justify-content: flex-start !important; /* 수평(좌우) 무조건 좌측 끝으로 강제 밀착 */
    }

    .aprv-dash-icon-box {
        width: 50px !important;
        height: 50px !important;
        border-radius: 12px !important;
        padding: 0 !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        flex-shrink: 0 !important;
    }

    .aprv-dash-icon-box .material-icons {
        font-size: 26px !important;
    }


    .aprv-dash-label {
        font-size: 0.85rem !important;
        color: #4b5563 !important;
        margin-bottom: 2px !important;
        letter-spacing: -0.5px !important;
        text-align: left !important;
    }

    .aprv-dash-card .text-secondary {
        color: #5c6b7a !important;
    }
    .aprv-dash-card .bg-label-secondary {
        background-color: #e2e6ea !important;
    }

    .aprv-dash-number {
        font-size: 1.6rem !important;
        color: #212b36 !important;
        line-height: 1 !important;
        text-align: left !important; /* 숫자 좌측 정렬 쐐기 */
    }

    /* 리스트 제목 강조 스타일 */
    .board-main-title {
        font-size: 1.3rem !important;
        font-weight: 600 !important;
        color: #2c3e50 !important;
        letter-spacing: -0.5px !important;
    }

    /* 2. 요약 카드 높이 및 간격 미세 조정 */
    .row.g-3.mb-4 {
        margin-bottom: 1rem !important; /* 아래 표와의 간격 축소 */
    }

    /*테이블 css 수정*/

    /* 1. 표 바탕 및 모든 셀을 완벽한 흰색으로 강제 코팅! (투명도 방어) */
    #aprvTb,
    #aprvTb tbody tr,
    #aprvTb tbody td {
        background-color: #ffffff !important;
        border-bottom: 1px solid #f0f2f5 !important;
        transition: background-color 0.15s ease-in-out; /* 부드러운 전환 효과 */
        cursor: pointer;
    }


    /* 2. 마우스 호버 시 은은하고 고급스러운 회색으로 변경! */
    #aprvTb tbody tr:hover td {
        background-color: #f4f5f7 !important; /* 바탕색과 확실히 구별되는 예쁜 회색 */
    }

    /* 페이징 블럭 디자인 통일 (가운데 정렬 및 둥근 테두리) */
    #tdPagingArea {
        text-align: center;
        padding: 0.5rem 0 !important; /* 내부 패딩도 축소 */
        background-color: #ffffff !important; /* 페이징 구역도 흰색 강제 */
    }
    #tdPagingArea .pagination {
        justify-content: center !important;
        margin-bottom: 0;
    }
    #tdPagingArea .pagination .page-link {
        border: none;
        margin: 0 3px;
        border-radius: 5px !important;
        color: #2f353e;
        transition: all 0.2s;
    }
    #tdPagingArea .pagination .page-link:hover {
        background-color: #e2e6ea; /* 호버 시 버튼 배경색 */
    }
    #tdPagingArea .pagination .page-item.active .page-link {
        background-color: #696cff;
        color: #fff;
    }

    /* 4. 페이징 영역(card-footer) 공백 박멸 */
    .card-footer.bg-white.py-4 {
        padding-top: 0.5rem !important;  /* 기존 py-4(1.5rem)에서 대폭 축소 */
        padding-bottom: 0.5rem !important;
    }


    /*테이블 css 수정끝 */


    /*테이블 너비 고정용*/
    /* --- 표 흔들림 방지 절대 고정 CSS --- */

    #aprvTb {
        /* ★ 핵심: 브라우저 맘대로 넓이 계산 금지! 지정한 넓이 무조건 엄수! */
        table-layout: fixed !important;
        width: 100%;
    }

    /* 각 열별 고유 클래스로 너비 강제 고정 (합치면 100%가 되도록 비율 조정) */
    .th-aprv-no      { width: 9% !important; }
    .th-aprv-status  { width: 9% !important; } /* 💡 상태 뱃지 넓이 추가! */
    .th-aprv-title   { width: auto !important; } /* 남는 공간은 제목이 쫙 흡수! */
    .th-aprv-attach  { width: 100px !important; } /* 첨부파일 클립은 50px 고정 */
    .th-aprv-date    { width: 13% !important; }
    .th-aprv-history { width: 13% !important; } /* 💡 문서 정보 버튼 넓이 추가! */

    /* 글자가 길어져서 표를 밀어내는 현상 방지 (넘치면 '...' 처리) */
    #aprvTb td {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    /*테이블 너비 고정용*/


    /* --- 새 결재문서 작성 버튼 (포인트 컬러 & 입체감) --- */
    .btn-aprv-new {
        background-color: #696cff !important; /* 메인 테마 색상 */
        color: #ffffff !important;
        border: none;
        padding: 10px 24px;
        font-size: 1rem;
        font-weight: 600;
        border-radius: 8px; /* 모던한 둥근 모서리 */
        box-shadow: 0 4px 10px rgba(105, 108, 255, 0.3); /* 은은한 보랏빛 그림자 */
        transition: all 0.2s ease-in-out;
    }

    .btn-aprv-new:hover {
        background-color: #5f61e6 !important; /* 호버 시 살짝 진하게 */
        color: #ffffff !important;
        transform: translateY(-2px); /* 마우스 올리면 살짝 떠오르는 느낌 */
        box-shadow: 0 6px 15px rgba(105, 108, 255, 0.4);
    }


    /* --- 결재 양식 선택 모달 커스텀 --- */

    /* 모달 헤더를 메인 보라색(#696cff)으로 변경 */
    .modal-header.custom-aprv-header {
        background-color: #696cff !important;
        border-bottom: none;
        padding: 1.25rem 1.5rem;
    }

    /* 아이콘과 텍스트가 더 돋보이도록 조정 */
    .modal-header.custom-aprv-header .modal-title {
        font-weight: 700;
        letter-spacing: -0.5px;
    }

    /* 리스트 아이템 호버 시 배경색을 더 부드럽게 */
    .list-group-item-action:hover {
        background-color: #f8f9ff !important;
        color: #696cff !important;
    }


    /* --- 밀어내기 슬라이딩 효과 전용 CSS --- */
    :root {
        --drawer-width: 450px;
        --header-actual-height: 70px;
    }

    /* 본문 전체를 감싸는 컨테이너 */
    .aprv-main-container {
        /* 동료 코드의 부드러운 쫀득 애니메이션 훔쳐오기 😆 */
        transition: padding-right 0.4s cubic-bezier(0.19, 1, 0.22, 1);
        width: 100%;
    }

    /* 창이 열렸을 때 여백을 줘서 본문 비율을 줄임 */
    .aprv-main-container.shrunk {
        padding-right: var(--drawer-width);
    }

    .custom-offcanvas {
        top: var(--header-actual-height) !important;
        height: calc(100vh - var(--header-actual-height)) !important;
        border-top-left-radius: 12px;
        transition: transform 0.4s cubic-bezier(0.19, 1, 0.22, 1) !important;
    }


    /* --- 회수 버튼 전용 스타일 --- */
    .btn-withdraw-custom {
        background-color: #f0f2ff; /* 메인 컬러의 아주 연한 배경 */
        color: #696cff;            /* 텍스트는 메인 컬러 */
        border: 1px solid #d9dcff;
        border-radius: 8px;
        padding: 10px 0;
        font-weight: 700;
        font-size: 0.95rem;
        transition: all 0.2s ease-in-out;
        box-shadow: 0 2px 4px rgba(105, 108, 255, 0.05);
    }

    .btn-withdraw-custom:hover {
        background-color: #696cff; /* 마우스 올리면 메인 컬러로 전환! */
        color: #ffffff;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(105, 108, 255, 0.2);
    }

    /* 회수 안내 문구 박스 */
    .withdraw-info-box {
        background-color: #f8f9fa;
        border-radius: 6px;
        padding: 10px;
        color: #566a7f;
        font-size: 0.75rem;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        border: 1px solid #eaeaec;
    }





</style>

<div id="mainSection" class="aprv-main-container">
<!-- Page Content -->
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
            <span class="material-icons" style="color: #696cff; font-size: 32px;">description</span>

            <div style="display: flex; align-items: baseline; gap: 8px;">
                <span style="font-size: x-large; font-weight: 800;">전자결재</span>
                <span style="font-weight: normal; color: #717171; font-size: 15px;">| 결재 상신함</span>
            </div>
        </div>

        <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
            새 결재 문서 작성 및 내가 상신한 문서를 관리할 수 있는 페이지 입니다.
        </div>
    </div>


    <div class="d-flex gap-2">
        <!-- 튜토리얼 버튼 -->
        <button onclick="startApprovalTutorial()" style="display: flex; align-items: center; gap: 5px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 10px 15px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.2s;" onmouseover="this.style.backgroundColor='#f8f9fa'" onmouseout="this.style.backgroundColor='#fff'">
            <span class="material-icons" style="font-size: 1.1rem;">help_outline</span> 튜토리얼
        </button>

        <!-- 새 결재문서 작성 버튼 -->
        <button class="btn btn-aprv-new d-flex align-items-center" data-bs-toggle="modal" data-bs-target="#newApprovalModal">
            <span class="material-icons me-2" style="font-size: 20px;">edit_document</span>
            새 결재문서 작성
        </button>
    </div>


</div>





<div class="row g-3 mb-4">

    <div class="col-xl col-md-4 col-sm-6">
        <div class="card border-start border-primary border-4 shadow-sm clickable-card aprv-dash-card" onclick="showProgressList2()">
            <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                    <div class="avatar-soft bg-label-primary aprv-dash-icon-box">
                        <span class="material-icons text-primary">pending_actions</span>
                    </div>
                    <div class="text-start"> <div class="fw-bold aprv-dash-label">미완료 문서</div>
                        <div class="d-flex align-items-center gap-2">
                            <div class="fw-bold aprv-dash-number">${ingTotal} <span class="text-secondary fw-normal" style="font-size: 0.65em;">/ ${aprvTotal}</div>
                            <span class="badge bg-label-danger" style="font-size: 0.7rem; padding: 0.35em 0.5em;">반려 ${retrunTotal}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div class="col-xl col-md-6 col-sm-6">
        <div class="card border-start border-success border-4 shadow-sm clickable-card aprv-dash-card" onclick="myDoneAprvList()">
            <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                    <div class="avatar-soft bg-label-success aprv-dash-icon-box">
                        <span class="material-icons text-success">task_alt</span>
                    </div>
                    <div class="text-start">
                        <div class="fw-bold aprv-dash-label">완료 문서</div>
                        <div class="fw-bold text-success aprv-dash-number">
                            ${doneTotal} <span class="text-secondary fw-normal" style="font-size: 0.65em;">/ ${aprvTotal}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div class="col-xl col-md-6 col-sm-6">
        <div class="card border-start border-info border-4 shadow-sm clickable-card aprv-dash-card" onclick="myAprvList()">
            <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                    <div class="avatar-soft bg-label-info aprv-dash-icon-box">
                        <span class="material-icons text-info">fact_check</span>
                    </div>
                    <div class="text-start">
                        <div class="fw-bold aprv-dash-label">전체 상신 문서</div>
                        <div class="fw-bold text-success aprv-dash-number">${aprvTotal}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div class="col-xl col-md-6 col-sm-6">
        <!--  onclick 이벤트 추가!(임시로 빈거..) -->
        <div class="card border-start border-secondary border-4 shadow-sm clickable-card aprv-dash-card" onclick="showEmptyRecallList()">
            <div class="card-body">
                <div class="d-flex align-items-center gap-3">
                    <div class="avatar-soft bg-label-secondary aprv-dash-icon-box">
                        <span class="material-icons text-secondary">history</span>
                    </div>
                    <div class="text-start">
                        <div class="fw-bold aprv-dash-label">회수 문서</div>
                        <div class="fw-bold text-success aprv-dash-number">

                            ${recallTotal}

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 카드 영역 끝 -->



<!-- 본문 영역 -->
<div class="row">
    <div class="col-12">
        <div class="card shadow-sm border-0">
            <div class="card-header bg-white d-flex justify-content-between align-items-center border-bottom pb-3 pt-4">
                <h4 class="board-main-title mb-0" id="myList">전체 상신 문서 목록</h4>

                <div class="input-group input-group-sm" style="width: 300px;">
                    <select name="mode" class="form-select" id="searchCondition" style="max-width: 90px; padding-right: 20px;">
                        <option value="aprvTtl" selected>제목</option>
                        <option value="aprvNo">문서번호</option>
                    </select>
                    <input name="keyword" type="text" class="form-control" id="searchKeyword" placeholder="검색어 입력(최대 30자)" maxlength="30">
                    <button class="btn btn-outline-primary d-inline-flex align-items-center" type="button" id="btnSearch">
                        <span class="material-icons fs-6">search</span>
                    </button>
                </div>
            </div>

            <div class="table-responsive border-bottom">
                <table class="table align-middle mb-0" id="aprvTb">
                    <thead class="table-light">
                    <tr>
                        <th class="ps-4 th-aprv-no">문서번호</th>
                        <th class="text-center th-aprv-status">상태</th>
                        <th class="text-start th-aprv-title">제목</th>
                        <th class="text-center th-aprv-attach" style="width: 50px;"></th>
                        <th class="text-start th-aprv-date">상신일</th>
                        <th class="text-center th-aprv-history">문서 정보</th>
                    </tr>
                    </thead>
                    <tbody id="aprvTbody">
                    <tr><td colspan="6" class="text-center">결재 문서가 없습니다.</td></tr>
                    </tbody>
                </table>
            </div>

            <div class="card-footer bg-white border-0 py-4">
                <div id="tdPagingArea" class="d-flex justify-content-center w-100">
                </div>
            </div>
<!-- 본문 영역 끝 -->



<!-- 결재 신청 모달 -->
<div class="modal fade" id="newApprovalModal" tabindex="-1" aria-labelledby="newApprovalModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header custom-aprv-header text-white">
                <h5 class="modal-title d-flex align-items-center" id="newApprovalModalLabel">
                    <span class="material-icons me-2">edit_note</span> 결재 양식 선택
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-0">
                <div class="list-group list-group-flush">

                    <a href="/approval/vctAprv" class="list-group-item list-group-item-action d-flex align-items-center py-3">
                        <span class="material-icons text-success me-3">beach_access</span> 휴가 신청
                    </a>
                    <a href="/approval/bztripAprv" class="list-group-item list-group-item-action d-flex align-items-center py-3">
                        <span class="material-icons text-warning me-3">flight_takeoff</span> 출장 신청
                    </a>
                    <a href="/approval/excsAprv" class="list-group-item list-group-item-action d-flex align-items-center py-3">
                        <span class="material-icons text-danger me-3">more_time</span> 초과근무 신청
                    </a>

                    <a href="/approval/expndAprv" class="list-group-item list-group-item-action d-flex align-items-center py-3">
                        <span class="material-icons text-primary me-3">payments</span> 지출품의
                    </a>


                    <a href="/approval/nmlAprv" class="list-group-item list-group-item-action d-flex align-items-center py-3">
                        <span class="material-icons text-secondary me-3">description</span> 일반기안
                    </a>
                    <a href="#" class="list-group-item list-group-item-action d-flex align-items-center py-3">
                        <span class="material-icons text-info me-3">today</span> 주간업무보고
                    </a>
                    <a href="#" class="list-group-item list-group-item-action d-flex align-items-center py-3 border-bottom-0">
                        <span class="material-icons text-dark me-3">logout</span> 사직서 제출
                    </a>
                </div>
            </div>
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">취소</button>
            </div>
        </div>
    </div>
</div>

        </div>

<!-- 결재 정보란 시작 -->
        <div class="offcanvas offcanvas-end custom-offcanvas" data-bs-scroll="true" data-bs-backdrop="false" tabindex="-1" id="approvalTimelineOffcanvas" aria-labelledby="approvalTimelineLabel" style="width: 450px; border-left: none; box-shadow: -5px 0 15px rgba(0,0,0,0.05);">

            <div class="offcanvas-header border-bottom bg-white d-flex justify-content-between align-items-center">
                <h5 class="offcanvas-title fw-bold d-flex align-items-center mb-0" id="approvalTimelineLabel">
                     문서 요약 정보
                </h5>

                <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close" style="margin-top: 2px;"></button>
            </div>

            <div class="offcanvas-body">

                <div class="mb-4 pb-3 border-bottom">
                    <div class="mb-2">
                        <h6 class="fw-bold mb-0" id="offcanvasDocTitle" style="line-height: 1.4; padding-right: 15px; word-break: keep-all;">문서 제목</h6>
                    </div>

                    <div class="d-flex justify-content-between small text-muted">
                        <span id="offcanvasDocNo">문서번호</span>
                        <span id="offcanvasDraftDate">기안일</span>
                    </div>
                </div>

                <div class="timeline-container" id="timelineContentArea">
                </div>


                <div id="withdrawBtnArea" class="mt-4 d-grid gap-2 d-none">
                    <hr class="text-muted opacity-25 mb-2"> <button type="button" class="btn btn-withdraw-custom d-flex justify-content-center align-items-center" id="withdrawBtn">
                    <span class="material-icons me-1" style="font-size: 1.1rem;">settings_backup_restore</span>
                    문서 회수하기
                </button>

                    <div class="withdraw-info-box mt-1">
                        <span class="material-icons" style="font-size: 14px; color: #8592a3;">info</span>
                        최종 결재자가 문서를 처리하기 전까지만 회수할 수 있습니다.
                    </div>
                </div>




            </div>
        </div>
<!-- 결재 정보란 끝 -->






<script type="text/javascript">

    //현재 어떤 목록을 보고 있는지 저장하는 전역 변수 (기본값: 내 상신 문서)
    let currentSearchType = 'MY_APRV';


    // 진행 중 카드 클릭 시 목록 전환 함수(DB)
    function showProgressList2() {
        console.log("진행중 목록 불러오기");

        currentSearchType = 'ING'; // 진행중 상태 업데이트(검색용)
        console.log("카드 눌렀을때 currentSearchType : ", currentSearchType);

        document.getElementById("myList").innerText = '미완료 상신 문서 목록';

        let data = {
            "currentPage": 1,
        };
        axios.post("/approval/aprvIngAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                console.log("result(진행중) : ", response.data);

                //response.data : Article<BookVO> articlePage
                //목록 핸들러 함수 호출
                listShowFn(response.data)
            })
            .catch(err => {
                console.error("err : ", err);
            });
    }//end showProgressList2


    //내 상신 내역 클릭 시 전체 목록 다시 출력
    function myAprvList(){

        currentSearchType = 'MY_APRV'; // 내상신으로 상태 업데이트(검색용)

        document.getElementById("myList").innerText = '전체 상신 문서 목록';

        let data = {
            "currentPage": 1,
            "mode": "",
            "keyword": ""
        };
        console.log("data : ", data);

        axios.post("/approval/aprvDashBoardAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                console.log("result : ", response.data);

                //response.data : Article<BookVO> articlePage
                //목록 핸들러 함수 호출
                listShowFn(response.data)

            })
            .catch(err => {
                console.error("err : ", err);
            });
    }//end myAprvList






    //내 상신 내역 클릭 시 전체 목록 다시 출력
    function myDoneAprvList(){

        currentSearchType = 'DONE'; // 결재완료로 업데이트(검색용)

        document.getElementById("myList").innerText = '결재 완료 문서 목록';

        let data = {
            "currentPage": 1,
            "mode": "",
            "keyword": ""
        };
        console.log("data : ", data);

        axios.post("/approval/aprvDashBoardDoneAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                console.log("result : ", response.data);

                listShowFn(response.data)

            })
            .catch(err => {
                console.error("err : ", err);
            });
    }//end myAprvList











    // 비동기로 리스트 가져오기
    //[페이징 블록 핸들러 함수]
    //: 페이징블록에서 페이지 번호를 클릭하면 리스트를 조회하는 비동기 처리
    //		요청 URI currentPage mode keyword
    //listFn('/list', 2)		, '', ''
    function listFn(url, currentPage, mode, keyword){//매개변수(지역변수)
        let data = {
            "currentPage":currentPage,
            "mode":mode,
            "keyword":keyword,
            "url":url
        };

        console.log("listFn->data : ", data);



        if("/approval/aprvIngAxios")


        /*
        요청파라미터 :
        요청방식 : post
        */
            axios.post(url, data, {
            headers :{
                "Content-Type" : "application/json;charset=utf-8"
            }
        })
            .then(response=>{
                console.log("result : ", response.data);

                    // 내 상신 전체 목록 or 미완료 문서
                    listShowFn(response.data)

            })
            .catch(err=>{
                console.error("err : ", err);
            });
    }//end listFn


    //전역함수
    //목록 출력, 페이징처리 해주는 전역 함수
    function listShowFn(articlePage){

        let str = `
        <thead class="table-light">
            <tr>
                <th class="ps-4 text-start th-aprv-no">결재번호</th>
                <th class="text-center th-aprv-status">상태</th>
                <th class="text-start th-aprv-title">제목</th>
                <th class="text-center th-aprv-attach"></th>
                <th class="text-start th-aprv-date">기안일</th>
                <th class="text-center th-aprv-history">문서 정보</th>
            </tr>
        </thead>
        <tbody id="aprvTbody">
        `;

        const approvalVOList = articlePage.content;

        if (!approvalVOList || approvalVOList.length === 0) {
            str += `
            <tr>
                <td colspan="6" class="text-center text-muted py-5" style="background-color: #fff !important; cursor: default;">
                    <div class="d-flex flex-column align-items-center my-4">
                        <span class="material-icons mb-2" style="font-size: 3.5rem; color: #e1e4e8;">folder_off</span>
                        <span class="fw-bold" style="color: #8592a3;">조회된 결재 문서가 없습니다.</span>
                    </div>
                </td>
            </tr>
            `;
        } else {
            approvalVOList.forEach(function(approvalVO){
                let badgeColor = "bg-label-primary";
                if (approvalVO.aprvStts === '반려') {
                    badgeColor = "bg-label-danger";
                } else if (approvalVO.aprvStts === '진행중') {
                    badgeColor = "bg-label-info ";
                }

                str += `
            <tr>
                <td class="ps-4 text-start">\${approvalVO.aprvNo}</td>

                <td class="text-center">
                    <span class="badge rounded-pill \${badgeColor}">\${approvalVO.aprvStts}</span>
                </td>

                <td class="text-start">
                   <a href="javascript:void(0);"
                   onclick="openAprvDetail('\${approvalVO.aprvNo}')"
                   class="text-decoration-none fw-bold text-dark">
                   \${approvalVO.aprvTtl}
                   </a>
                </td>

                <td class="text-center">
                    \${approvalVO.aprvData ? '<span class="fas fa-paperclip text-muted"></span>' : ''}
                </td>

                <td class="text-start">\${approvalVO.aprvDt ? approvalVO.aprvDt.substring(0, 10) : ''}</td>
                <td class="text-center">
                    <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill"
                            onclick="openTimeline('\${approvalVO.aprvNo}', '\${approvalVO.aprvTtl}', '\${approvalVO.aprvDt}')">
                        정보 보기 <span class="material-icons align-middle ps-1" style="font-size: 16px;">info</span>
                    </button>
                </td>


            </tr>
            `;
            });
        }

        str += `
        </tbody>
        `;
        document.querySelector("#aprvTb").innerHTML = str;

        // 페이징 블록 처리
        document.getElementById("tdPagingArea").innerHTML = articlePage.pagingArea || "";
    }







    //진행중, 내 상신 문서 등등... 클릭 시 새창 열기 함수
    function openAprvDetail(aprvNo) {
        const url = `/approval/openAprvDetail?aprvNo=\${aprvNo}`;
        const name = "ApprovalDetail";
        const specs = "width=900,height=1000,scrollbars=yes";
        window.open(url, name, specs);
    }


    ////////////////// 결재 정보 띄우는 함수 시작
    // 오프캔버스 열기 및 데이터 로딩 함수
    function openTimeline(aprvNo, aprvTtl, aprvDt) {


        document.getElementById('offcanvasDocNo').innerText = "문서번호: " + aprvNo;
        document.getElementById('offcanvasDocTitle').innerText = aprvTtl;
        document.getElementById('offcanvasDraftDate').innerText = "기안일: " + (aprvDt ? aprvDt.substring(0, 10) : '');

        const offcanvasElement = document.getElementById('approvalTimelineOffcanvas');

        // new 대신 getOrCreateInstance를 써야 여러 번 눌러도 꼬이지 않습니다.
        const bsOffcanvas = bootstrap.Offcanvas.getOrCreateInstance(offcanvasElement);
        bsOffcanvas.show();

        // 창이 열릴 때 본문 찌그러뜨리기 클래스 추가
        document.getElementById('mainSection').classList.add('shrunk');

        // 3. 내용 초기화 (로딩중 표시)
        const timelineArea = document.getElementById('timelineContentArea');
        timelineArea.innerHTML = `<div class="text-center mt-5"><div class="spinner-border text-primary" role="status"></div><p class="mt-2 text-muted">결재 히스토리를 불러오는 중입니다...</p></div>`;

        // ★ 4. Axios로 문서 정보(기안자)와 결재선(결재자들) 둘 다 가져오기!
        Promise.all([
            axios.get(`/approval/getPendingDoc?aprvNo=\${aprvNo}`),
            axios.get(`/approval/getAprvLine?aprvNo=\${aprvNo}`)
        ])
            .then(response => {
                const docData = response[0].data;  // 문서 본체 (기안자 정보)
                const lineList = response[1].data; // 결재선 목록


                // 문서 종류(aprvSe)에 따라 근태/휴가 여부 판별 로직 추가
                let isVctDoc = "N";
                let isAttDoc = "N";

                if (docData.aprvSe === 'APRV01002') { // 휴가신청서
                    isVctDoc = "Y";
                    isAttDoc = "Y";
                } else if (docData.aprvSe === 'APRV01003' || docData.aprvSe === 'APRV01004') { // 출장 또는 초과근무
                    isAttDoc = "Y";
                }



                //업무태그 값 ..
                const workTagText = docData.aprvWorkTagNm || '업무태그가 없습니다.';


                // 문서 제목 위에 업무태그 추가함 (깔끔한 사각 뱃지 버전)
                document.getElementById('offcanvasDocTitle').innerHTML = `
                    <span class="work-tag-badge">
                        <span class="material-icons" style="font-size: 13px; margin-right: 4px;">local_offer</span>
                        \${workTagText}
                    </span><br>
                    <span class="fw-bold" style="font-size: 1.15rem; color: #2c3e50; line-height: 1.4;">\${aprvTtl}</span>
                `;

                let html = '';

                // 문서 작성자(기안자) 타임라인 첫번째로 넣기
                // 작성자 프로필 이미지 설정 (없으면 기본 이미지)
                const docWriterEmpProfile = docData.docWriterEmpProfile ? `/displayPrf?fileName=\${docData.docWriterEmpProfile}` : 'https://i.pravatar.cc/150?u=a042581f4e29026704d';


                // 기안자(첫 번째로 나타날) 프로필에 'approved' 클래스 추가!
                html += `
                <div class="timeline-item">
                    <div class="timeline-icon approved">
                        <img src="\${docWriterEmpProfile}" alt="Profile">
                    </div>
                    <div>
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <h6 class="mb-0 fw-bold">\${docData.docWriterNm || ''} (\${docData.posNm || ''}) <span class="badge bg-secondary ms-1">기안</span></h6>
                            <small class="text-muted">\${docData.aprvDt ? docData.aprvDt.substring(0, 16).replace('T', ' ') : '-'}</small>
                        </div>
                        <p class="text-muted small mb-1" style="font-size: 0.8rem;">\${docData.docWriterDeptNm || '부서 미지정'}</p>
                    </div>
                </div>
                `;

                //실제 결재선(결재자들) 데이터 반복문 돌리기
                lineList.forEach((line) => {
                    let statusBadge = '';
                    let commentHtml = '';
                    let pendingClass = '';
                    let statusClass = ''; // 💡 아이콘 테두리용 상태 클래스 변수!


                    // 프로필 이미지 설정 (없으면 기본 이미지)
                    const profileImg = line.empProfile ? `/displayPrf?fileName=\${line.empProfile}` : 'https://i.pravatar.cc/150?u=a042581f4e29026704d';

                    // 상태별 뱃지 및 의견(코멘트) 처리
                    if (line.aprvLnStts === 'APRV02001') {
                        statusBadge = `<span class="status-badge-clean bg-clean-info ms-2">대기</span>`;
                        statusClass = 'pending'; // ⚪ 대기 (회색)
                    } else if (line.aprvLnStts === 'APRV02002') {
                        statusBadge = `<span class="status-badge-clean bg-clean-primary ms-2">결재</span>`;
                        statusClass = 'approved'; // 🟣 결재 완료 (보라색)
                        if (line.aprvLnCn) {
                            commentHtml = `<div class="comment-box approve"><span class="material-icons align-middle me-1" style="font-size: 14px; color: #696cff;">chat</span>\${line.aprvLnCn}</div>`;
                        }
                    } else if (line.aprvLnStts === 'APRV02003') {
                        statusBadge = `<span class="status-badge-clean bg-clean-danger ms-2">반려</span>`;
                        statusClass = 'rejected'; // 🔴 반려 (빨간색)
                        if (line.aprvLnCn) {
                            commentHtml = `<div class="comment-box reject"><span class="material-icons align-middle me-1" style="font-size: 14px; color: #E53E3E;">report_problem</span>\${line.aprvLnCn}</div>`;
                        }
                    }

                    // 타임라인 아이템 HTML 생성
                    html += `
                    <div class="timeline-item">
                        <div class="timeline-icon \${statusClass}">
                            <img src="\${profileImg}" alt="Profile">
                        </div>
                        <div>
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <h6 class="mb-0 fw-bold">\${line.aprvNm || line.empNm} (\${line.empJbgd}) \${statusBadge}</h6>
                                <small class="text-muted">\${line.aprvLnDt ? line.aprvLnDt.substring(0, 16).replace('T', ' ') : '-'}</small>
                            </div>
                            <p class="text-muted small mb-1" style="font-size: 0.8rem;">\${line.deptNm || '부서 미지정'}</p>
                            \${commentHtml}
                        </div>
                    </div>
                    `;
                });

                timelineArea.innerHTML = html;

                // ↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️회수 로직 추가 함!!!!!
                const withdrawBtnArea = document.getElementById('withdrawBtnArea');
                const withdrawBtn = document.getElementById('withdrawBtn');

                console.log("이 문서 상태 뭔데? : ",docData.aprvStts);

                // 진행중인 문서일 때만 버튼 노출
                if(docData.aprvStts === '진행중') {

                    withdrawBtnArea.classList.remove('d-none'); //안보이게 하는거 지움

                    withdrawBtn.onclick = function() {
                        // 판별된 isVctDoc, isAttDoc 값을 포함하여 데이터 조립
                        const withdrawData = {
                            "aprvNo" : docData.aprvNo,
                            "isVctDoc" : isVctDoc,         // 휴가 여부
                            "isAttDoc" : isAttDoc,         // 근태 여부
                            "vctTotalDays" : docData.vctTotalDays || 0,
                            "aprvDocNo" : docData.aprvDocNo,
                            "aprvSe" : docData.aprvSe,
                            "docWriterId" : docData.docWriterId,
                            "aprvLnStts" : "회수",
                            "aprvStts" : docData.aprvStts, // 흠...?
                            "aprvLnCn" : "기안자에 의한 회수"
                        };

                        console.log("서버로 보낼 회수 데이터:", withdrawData);
                        handleWithdraw(withdrawData); // 객체 통째로 전달
                    };
                } else {
                    // '진행중'이 아니면(결재완료, 반려 등) 숨김 클래스(d-none)를 추가해서 버튼을 숨깁니다.
                    withdrawBtnArea.classList.add('d-none');
                }
                // ↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️↘️회수 로직 추가 함!!!!!





            })
            .catch(err => {
                console.error("결재선 로딩 에러:", err);
                timelineArea.innerHTML = `<div class="alert alert-danger">데이터를 불러오는 중 오류가 발생했습니다.</div>`;
            });
    }
    ////////////////// 결재 정보 띄우는 함수 끝




    // 회수 함수
    // 회수 함수
    function handleWithdraw(withdrawData) { // 객체를 인자로 받음
        // (알람 리팩토링) 기존 기본 confirm 대신 AppAlert.confirm 적용. 아이콘은 'history', 테마는 'warning' 추천!
        AppAlert.confirm('문서 회수', '이 문서를 정말 회수하시겠습니까?', '회수하기', '취소', 'history', 'warning') // (알람 리팩토링)
            .then((result) => { // (알람 리팩토링)
                if (result.isConfirmed) { // (알람 리팩토링)
                    // 이미 withdrawData가 객체이므로 그대로 post에 전달
                    axios.post('/approval/withdrawApproval', withdrawData, {
                        headers: {
                            "Content-Type": "application/json;charset=utf-8"
                        }
                    })
                        .then(res => { //반환값으로 확인하기...!
                            if (res.data === "success") {
                                AppAlert.success('회수 완료', '문서가 정상적으로 회수되었습니다.', null, 'check_circle')
                                    .then(() => { location.reload(); });
                            } else if (res.data === "invalid_status") {
                                AppAlert.warning('회수 불가', '이미 결재가 진행되어 회수할 수 없는 문서입니다.');
                            } else if (res.data === "권한없음") {
                                AppAlert.error('권한 없음', '문서를 회수할 권한이 없습니다.');
                            } else {
                                AppAlert.error('오류 발생', '회수 처리 중 알 수 없는 오류가 발생했습니다.');
                            }
                        })
                        .catch(err => {
                            console.error("회수 에러:", err);
                            // (알람 리팩토링) 에러 발생 시 error 모달 적용. 아이콘은 'error_outline'
                            AppAlert.error('오류 발생', err.response?.data || "회수 처리 중 오류가 발생했습니다.", null, 'error_outline'); // (알람 리팩토링)
                        });
                } // (알람 리팩토링)
            }); // (알람 리팩토링)
    }


    // 회수 함수





    ///////////////////DOM


    document.addEventListener("DOMContentLoaded", function() {

        // 요소 값 불러오기(value로 불러오면 오류 발생..)
        const modeSelect = document.querySelector("select[name='mode']");
        const keywordInput = document.querySelector("input[name='keyword']");

        // 요소가 존재할 때만 value를 가져오고, 없으면 ""(빈값)
        let modeValue = (modeSelect) ? modeSelect.value : "";
        let keywordValue = (keywordInput) ? keywordInput.value : "";


        let data = {
            "currentPage": 1,
            "mode": modeValue,
            "keyword": keywordValue
        };


        console.log("data : ", data);

        axios.post("/approval/aprvDashBoardAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                console.log("result : ", response.data);

                //response.data : Article<BookVO> articlePage
                //목록 핸들러 함수 호출
                listShowFn(response.data)

            })
            .catch(err => {
                console.error("err : ", err);
            });



        /////////// 비동기 검색 실행() /////////////////
        const btnSearch = document.getElementById("btnSearch");

        btnSearch.addEventListener("click", () => {


            //검색어 길이 유효성 검사 추가(혹시모를...)
            const keywordInput = document.querySelector("input[name='keyword']");
            const keywordVal = keywordInput.value || "";

            if (keywordVal.length > 30) {
                AppAlert.warning('검색어 길이 초과', '검색어는 최대 30자까지만 입력할 수 있습니다.', 'searchKeyword', 'text_fields');
                return;
            }





            // 1. 공통 데이터 추출 (검색 조건, 검색어)
            const data = {
                "currentPage": 1,
                "mode": document.querySelector("select[name='mode']").value || "",
                "keyword": document.querySelector("input[name='keyword']").value || ""
            };

            console.log(`[\${currentSearchType}] 검색 실행 -> data :`, data);

            // 2. 현재 상태(currentSearchType)에 따라 다른 URL과 함수 호출!
            if (currentSearchType === 'MY_APRV') {
                console.log("내상신문서 전체 문서 검색 실행");
                axios.post("/approval/aprvDashBoardAxios", data, { headers: { "Content-Type": "application/json;charset=utf-8" } })
                    .then(response => listShowFn(response.data))
                    .catch(err => console.error(err));

            } else if (currentSearchType === 'DONE') {
                console.log("결재완료 문서 검색 실행");
                axios.post("/approval/aprvDashBoardDoneAxios", data, { headers: { "Content-Type": "application/json;charset=utf-8" } })
                    .then(response => listShowFn(response.data)) //결재완료
                    .catch(err => console.error(err));

            } else if (currentSearchType === 'ING') {
                console.log("진행중 문서 검색 실행");
                axios.post("/approval/aprvIngAxios", data, { headers: { "Content-Type": "application/json;charset=utf-8" } })
                    .then(response => listShowFn(response.data))
                    .catch(err => console.error(err));
            }
            else if (currentSearchType === 'RECALL') {
                console.log("회수 문서 검색 실행");
                axios.post("/approval/aprvWithDrawListAxios", data, { headers: { "Content-Type": "application/json;charset=utf-8" } })
                    .then(response => listShowFn(response.data))
                    .catch(err => console.error(err));
            }
        });//end click
        /////////// 비동기 검색 실행끝 /////////////////


        // 오프캔버스가 닫힐 때 본문 다시 넓어지게 복구하기!
        const offcanvasElement = document.getElementById('approvalTimelineOffcanvas');
        offcanvasElement.addEventListener('hide.bs.offcanvas', function () {
            document.getElementById('mainSection').classList.remove('shrunk');

            //창 닫힐때 회수 버튼 숨기기
            document.getElementById('withdrawBtnArea').classList.add('d-none');
        });

    })//DOM



    // ==========================================
    // 💡 Driver.js 튜토리얼 가이드
    // ==========================================
    function startApprovalTutorial() {
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
                {
                    element: '.btn-aprv-new', // 클래스로 타겟팅
                    popover: {
                        title: '새 결재문서 작성',
                        // 기존 내용 유지, 파란색 강조
                        description: '휴가, 출장, 초과근무 등 <span style="color: #696cff; font-weight: bold;">새로운 기안</span>을 <br />작성하려면 이 버튼을 클릭하세요.',
                        side: "left", align: 'start'
                    }
                },

                // 요약 카드 - 미완료 문서
                {
                    element: '.col-xl:nth-child(1) .aprv-dash-card', // 1번째 카드 (미완료)
                    popover: {
                        title: '미완료 문서',
                        description: '내가 상신한 문서 중 <span style="color: #ffab00; font-weight: bold;">결재가 진행 중,</span>' +
                            ' 혹은<br /> <span style="color: #ff3e1d; font-weight: bold;">반려된 문서</span>를 확인할 수 있습니다.',
                        side: "bottom", align: 'start'
                    }
                },
                // 요약 카드 - 완료 문서
                {
                    element: '.col-xl:nth-child(2) .aprv-dash-card', // 2번째 카드 (완료)
                    popover: {
                        title: '결재 완료 문서',
                        description: '모든 결재권자가 승인하여 <span style="color: #28a745; font-weight: bold;">최종 완료된 문서</span>를 확인할 수 있습니다.',
                        side: "bottom", align: 'center'
                    }
                },

                // 요약 카드 - 전체 상신 문서
                {
                    element: '.col-xl:nth-child(3) .aprv-dash-card', // 3번째 카드 (전체 상신)
                    popover: {
                        title: '전체 상신 문서',
                        description: '지금까지 <span style="color: #03c3ec; font-weight: bold;">내가 상신한 모든 문서</span>를 확인할 수 있습니다. <br/><br/>' +
                            '미완료 문서와 완료 문서 모두 조회할 때 사용하세요.',
                        side: "bottom", align: 'center'
                    }
                },
                // 요약 카드 - 회수 문서
                {
                    element: '.col-xl:nth-child(4) .aprv-dash-card',
                    popover: {
                        title: '회수 문서',
                        description: '결재가 완료되기 전 <span style="color: #8592a3; font-weight: bold;">기안을 회수한 문서</span>들을<br /> 모아볼 수 있습니다.<br><br>클릭하면 회수 문서 목록이 나타납니다.',
                        side: "bottom", align: 'center'
                    }
                },

                // 하단 테이블 목록
                {
                    element: '#aprvTb', // 테이블 아이디
                    popover: {
                        title: '문서 목록',
                        description: '<span style="color: #696cff; font-weight: bold;">요약 카드를 클릭</span>하면, 조건에 맞는 문서목록이 이곳에 나타납니다.<br /><br />' +
                            '<span style="color: #696cff; font-weight: bold;">제목을 클릭하면 상세 내용</span>을 새 창으로 확인할 수 있습니다.',
                        side: "top", align: 'start'
                    }
                },

                // 이력보기 버튼(클릭이벤트 훅이랑 연결되어있음(훅은 바로 하단에 써잇음!))
                {
                    element: '#aprvTb tbody tr:first-child .btn-outline-secondary',
                    popover: {
                        title: '문서 정보 확인 및 회수',
                        description: '문서를 열지 않고도, 우측에서 <span style="color: #696cff; font-weight: bold;">업무 태그 및 <br />결재 진행 현황</span> 등 문서 정보를 쉽게 확인할 수 있습니다!<br><br>또한, 결재가 진행 중인 문서는 우측 하단의<br /> 버튼을 통해 <span style="color: #ff3e1d; font-weight: bold;">회수</span>할 수 있습니다.',
                        side: "left", align: 'center'
                    }
                },

                // 타겟팅 예시 (화면 밖 사이드바/헤더)
                {
                    element: '#aprvSidebar', // 결재 사이드바 id
                    popover: {
                        title: '메뉴 이동',
                        description: '결재 해야할 문서(수신함), 부서 문서함 등 <br /><span style="color: #696cff; font-weight: bold;">다른 문서를 확인하려면 왼쪽 사이드바</span>를 <br />이용하세요.',
                        side: "right", align: 'start'
                    }
                }
            ],

            // 클릭 이벤트 훅!!!!!(드라이버에서 제공)
            onHighlightStarted: (element, step, options) => {
                if(step.popover.title === '문서 정보 확인 및 회수') {
                    const historyBtn = document.querySelector('#aprvTb tbody tr:first-child .btn-outline-secondary');
                    if(historyBtn) {
                        historyBtn.click();
                    }
                }
            },

            // 클릭 이벤트 훅!!!!!(드라이버에서 제공)
            onDeselected: (element, step, options) => {
                if(step.popover.title === '문서 정보 확인') {
                    const closeBtn = document.querySelector('#approvalTimelineOffcanvas .btn-close');
                    if(closeBtn) {
                        closeBtn.click();
                    }
                }
            }
        });

        // 튜토리얼 시작!
        driverObj.drive();
    }



    // 회수 문서 카드 클릭 시 '데이터 없음' 화면 출력 (임시 구현)
    function showEmptyRecallList() {
        console.log("회수 문서 목록 불러오기 (임시 빈 화면)");

        currentSearchType = 'RECALL'; // 나중에 검색 연동을 위해 상태 업데이트

        // 테이블 제목 변경
        document.getElementById("myList").innerText = '회수 문서 목록';

        let data = {
            "currentPage": 1,
            "mode": "",
            "keyword": ""
        };
        console.log("data : ", data);

        axios.post("/approval/aprvWithDrawListAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                console.log("result : ", response.data);

                //response.data : Article<BookVO> articlePage
                //목록 핸들러 함수 호출
                listShowFn(response.data)

            })
            .catch(err => {
                console.error("err : ", err);
            });
    } //회수 임시 끝





</script>