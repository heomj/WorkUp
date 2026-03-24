<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<%@ page import="java.util.Date"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<!-- 튜토리얼 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.css"/>
<script src="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.js.iife.js"></script>


<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="/js/common-alert.js"></script>


<style>

    /* 🚨 결재 페이지 전용 레이아웃 붕괴 방지 (main-wrapper 폭 제한 해제) */
    .main-wrapper {
        width: auto !important;
    }

    :root {
        --header-actual-height: 70px; /* 💡 실제 헤더 높이에 맞춰 조정 (필요시 60px, 75px 등) */
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

    .page-wrapper {
        padding: 1.5rem;
        width: 100%;
        box-sizing: border-box;
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


    /* ///// 🤍 깔끔한 화이트톤 결재 정보 스타일 (상신함과 동일) ///// */

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

    /* 🚨 누락되었던 상태별 테두리 색상 부활! 🚨 */
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
        background-color: #f0f2ff;
        color: #696cff;
        border: 1px solid #d9dcff;
        border-radius: 6px;
        padding: 4px 10px;
        font-size: 0.75rem;
        font-weight: 700;
        letter-spacing: -0.3px;
        margin-bottom: 8px;
        box-shadow: 0 2px 4px rgba(105, 108, 255, 0.05);
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
    .th-aprv-no      { width: 13% !important; } /* 💡 8% -> 13%로 통일! */
    .th-aprv-status  { width: 10% !important; } /* 💡 8% -> 10%로 통일! */
    .th-aprv-title   { width: auto !important; }
    .th-aprv-attach  { width: 50px !important; }
    .th-aprv-date    { width: 13% !important; }
    .th-aprv-history { width: 13% !important; }

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
        --drawer-width: 450px; /* 우측 결재이력 창 너비 */
    }

    /* 본문 전체를 감싸는 컨테이너 */
    .aprv-main-container {
        transition: padding-right 0.4s cubic-bezier(0.19, 1, 0.22, 1);
        width: 100%;
    }

    /* 창이 열렸을 때 여백을 줘서 본문 비율을 줄임 */
    .aprv-main-container.shrunk {
        padding-right: var(--drawer-width);
    }

    /* Bootstrap Offcanvas 등장 속도 맞추기 */
    .custom-offcanvas {
        top: var(--header-actual-height) !important; /* 헤더 밑에서 시작 */
        height: calc(100vh - var(--header-actual-height)) !important; /* 헤더 뺀 높이만큼만! */
        border-top-left-radius: 12px;
        transition: transform 0.4s cubic-bezier(0.19, 1, 0.22, 1) !important;
    }

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







</style>




<!-- Page Content -->
<div id="mainSection" class="aprv-main-container">







    <div id="mainSection" class="aprv-main-container">
        <!-- Page Content -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                    <span class="material-icons" style="color: #696cff; font-size: 32px;">description</span>

                    <div style="display: flex; align-items: baseline; gap: 8px;">
                        <span style="font-size: x-large; font-weight: 800;">전자결재</span>
                        <span style="font-weight: normal; color: #717171; font-size: 15px;">| 결재 수신함</span>
                    </div>
                </div>

                <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                    수신한 문서의 결재 처리, 결재 완료/수신 참조 문서를 확인할 수 있는 페이지 입니다.
                </div>
            </div>


            <div class="d-flex gap-2">
                <!-- 튜토리얼 버튼 -->
                <button onclick="startApprovalTutorial()" style="display: flex; align-items: center; gap: 5px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 10px 15px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.2s;" onmouseover="this.style.backgroundColor='#f8f9fa'" onmouseout="this.style.backgroundColor='#fff'">
                    <span class="material-icons" style="font-size: 1.1rem;">help_outline</span> 튜토리얼
                </button>

            </div>


        </div>



<!-- 카드 영역 -->
    <!-- 상단 요약 카드 영역 -->
    <div class="row g-3 mb-4">

        <div class="col-xl col-md-4 col-sm-6">
            <div class="card border-start border-warning border-4 shadow-sm clickable-card aprv-dash-card" onclick="getMyPendingAprv()">
                <div class="card-body">
                    <div class="d-flex align-items-center gap-3">
                        <div class="avatar-soft bg-label-warning aprv-dash-icon-box">
                            <span class="material-icons text-warning">assignment_late</span>
                        </div>
                        <div class="text-start">
                            <div class="fw-bold aprv-dash-label">결재 대기</div>
                            <div class="fw-bold text-warning aprv-dash-number">${pendingTotal}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl col-md-4 col-sm-6">
            <!-- 임시로 넣어둠 -->
            <div class="card border-start border-info border-4 shadow-sm clickable-card aprv-dash-card" onclick="showEmptyReferenceList()">
                <div class="card-body">
                    <div class="d-flex align-items-center gap-3">
                        <div class="avatar-soft bg-label-info aprv-dash-icon-box">
                            <span class="material-icons text-info">mark_email_unread</span>
                        </div>
                        <div class="text-start">
                            <div class="fw-bold aprv-dash-label">수신 참조 문서</div>
<%--                            <div class="fw-bold aprv-dash-number">${recallTotal}</div>--%>
                            <div class="fw-bold text-warning aprv-dash-number">
                            0 <span class="text-secondary fw-normal" style="font-size: 0.65em;">/ 0</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl col-md-4 col-sm-12">
            <div class="card border-start border-success border-4 shadow-sm clickable-card aprv-dash-card" onclick="getPendingDoneAprv()">
                <div class="card-body">
                    <div class="d-flex align-items-center gap-3">
                        <div class="avatar-soft bg-label-success aprv-dash-icon-box">
                            <span class="material-icons text-success">task_alt</span>
                        </div>
                        <div class="text-start">
                            <div class="fw-bold aprv-dash-label">결재한 문서</div>
                            <div class="fw-bold text-success aprv-dash-number">${pendingDoneTotal}</div>
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
                    <h4 class="board-main-title mb-0" id="myList">결재 대기 문서 목록</h4>

                    <div class="input-group input-group-sm" style="width: 300px;">
                        <select name="mode" class="form-select" id="searchCondition" style="max-width: 90px; padding-right: 20px;">
                            <option value="aprvTtl" selected>제목</option>
                            <option value="empNm">성명</option>
                            <option value="empId">사번</option>
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
                        <!-- 💡 표 제목(넓이 고정 클래스 포함) 제대로 적용! -->
                        <tr>
                            <th class="ps-4 text-start th-aprv-no">문서번호</th>
                            <th class="text-start th-aprv-title">제목</th>
                            <th class="text-center th-aprv-attach"></th>
                            <th class="text-start th-aprv-witer">문서 작성자</th>
                            <th class="text-start th-aprv-date">기안일</th>
                            <th class="text-center th-aprv-history">문서 정보</th>
                        </tr>
                        </thead>
                        <tbody id="aprvTbody">
                        <tr><td colspan="6" class="text-center py-5 text-muted">결재 문서가 없습니다.</td></tr>
                        </tbody>
                    </table>
                </div>

                <div class="card-footer bg-white border-0 py-4">
                    <div id="tdPagingArea" class="d-flex justify-content-center w-100">
                    </div>
                </div>

            </div> <!-- 🚨🚨🚨 card 닫기 🚨🚨🚨 -->
        </div> <!-- 🚨🚨🚨 col-12 닫기 🚨🚨🚨 -->
    </div> <!-- 🚨🚨🚨 row 닫기 🚨🚨🚨 -->
    <!-- 본문 영역 끝 -->


</div>

    <!-- 결재 정보란 시작 (오프캔버스) -->
    <div class="offcanvas offcanvas-end custom-offcanvas" data-bs-scroll="true" data-bs-backdrop="false" tabindex="-1" id="approvalTimelineOffcanvas" aria-labelledby="approvalTimelineLabel" style="width: 450px; border-left: none; box-shadow: -5px 0 15px rgba(0,0,0,0.05);">

        <!-- 💡 bg-light를 bg-white로 변경 & X버튼 헤더로 이동! -->
        <div class="offcanvas-header border-bottom bg-white d-flex justify-content-between align-items-center">
            <h5 class="offcanvas-title fw-bold d-flex align-items-center mb-0" id="approvalTimelineLabel">
                문서 요약 정보
            </h5>
            <!-- 💡 본문에 있던 X 버튼을 여기(헤더)로 구출 완료! -->
            <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
        </div>

        <div class="offcanvas-body">
            <div class="mb-4 pb-3 border-bottom">
                <!-- 💡 버튼이 빠져나갔으므로 flex 정렬을 풀고 깔끔하게 둡니다 -->
                <div class="mb-2">
                    <h6 class="fw-bold mb-0" id="offcanvasDocTitle" style="line-height: 1.4; word-break: keep-all;">문서 제목</h6>
                </div>
                <div class="d-flex justify-content-between small text-muted">
                    <span id="offcanvasDocNo">문서번호</span>
                    <span id="offcanvasDraftDate">기안일</span>
                </div>
            </div>

            <div class="timeline-container" id="timelineContentArea">
            </div>
        </div>
    </div>
    <!-- 결재 정보란 끝 -->

</div> <!-- 💡 container-fluid 닫기  -->




<script type="text/javascript">

    // 현재 어떤 목록을 보고 있는지 저장하는 전역 변수 (기본값: 결재대기문서)
    let currentSearchType = 'PENDING';


    // 결재대기 목록 불러오기
    function getMyPendingAprv(){
        currentSearchType = 'PENDING'; // 결재대기 상태 업데이트(검색용)
        document.getElementById("myList").innerText = '결재 대기 문서 목록';

        let data = {
            "currentPage": 1,
            "mode": "",
            "keyword": ""
        };

        axios.post("/approval/getMyPendingAprvAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                listShowFn(response.data);
            })
            .catch(err => {
                console.error("err : ", err);
                // 💡 리팩토링: 데이터 로딩 실패 에러 알림
                AppAlert.error('조회 실패', '결재 대기 목록을 불러오는 중 오류가 발생했습니다.');
            });
    }


    // 결재한 문서 목록 불러오기
    function getPendingDoneAprv(){
        currentSearchType = 'PENDINGDONE'; // 결재한 상태 업데이트(검색용)
        document.getElementById("myList").innerText = '결재한 문서 목록';

        let data = {
            "currentPage": 1,
            "mode": "",
            "keyword": ""
        };

        axios.post("/approval/getPendingDoneAprvAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                listDoneShowFn(response.data);
            })
            .catch(err => {
                console.error("err : ", err);
                // 💡 리팩토링: 데이터 로딩 실패 에러 알림
                AppAlert.error('조회 실패', '결재 완료 목록을 불러오는 중 오류가 발생했습니다.');
            });
    }


    // 비동기로 리스트 가져오기 (페이징 클릭 등)
    function listFn(url, currentPage, mode, keyword){
        let data = {
            "currentPage":currentPage,
            "mode":mode,
            "keyword":keyword,
            "url":url
        };

        axios.post(url, data, {
            headers :{
                "Content-Type" : "application/json;charset=utf-8"
            }
        })
            .then(response=>{
                if(url === "/approval/getPendingDoneAprvAxios"){
                    listDoneShowFn(response.data);
                } else {
                    listShowFn(response.data);
                }
            })
            .catch(err=>{
                console.error("err : ", err);
                AppAlert.error('통신 오류', '페이지 데이터를 가져오는 중 오류가 발생했습니다.');
            });
    }


    // 결재 대기 목록 출력 및 페이징 처리
    function listShowFn(articlePage){
        let str = `
            <thead class="table-light">
                <tr>
                    <th class="ps-4 text-start th-aprv-no">문서번호</th>
                    <th class="text-start th-aprv-title">제목</th>
                    <th class="text-center th-aprv-attach"></th>
                    <th class="text-start th-aprv-witer">문서 작성자</th>
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
                str += `
                    <tr>
                        <td class="ps-4 text-start">\${approvalVO.aprvNo}</td>
                        <td class="text-start">
                            <a href="javascript:void(0);"
                           onclick="openPendingAprvDetail('\${approvalVO.aprvNo}')"
                           class="text-decoration-none fw-bold text-dark">
                           \${approvalVO.aprvTtl}
                           </a>
                        </td>
                        <td class="text-center">
                            \${approvalVO.aprvData ? '<span class="fas fa-paperclip text-muted"></span>' : ''}
                        </td>
                        <td class="text-start">\${approvalVO.docWriterNm}</td>
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
        str += `</tbody>`;
        document.querySelector("#aprvTb").innerHTML = str;
        document.getElementById("tdPagingArea").innerHTML = articlePage.pagingArea || "";
    }


    // 결재 완료 목록 출력 및 페이징 처리
    function listDoneShowFn(articlePage){
        let str = `
            <thead class="table-light">
                <tr>
                    <th class="ps-4 text-start th-aprv-no">문서번호</th>
                    <th class="text-center th-aprv-status">상태</th>
                    <th class="text-start th-aprv-title">제목</th>
                    <th class="text-center th-aprv-attach"></th>
                    <th class="text-start th-aprv-witer">문서 작성자</th>
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
                        <td class="text-start">\${approvalVO.docWriterNm}</td>
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
        str += `</tbody>`;
        document.querySelector("#aprvTb").innerHTML = str;
        document.getElementById("tdPagingArea").innerHTML = articlePage.pagingArea || "";
    }


    // 상세 창 열기 함수들
    function openPendingAprvDetail(aprvNo) {
        const url = `/approval/openPendingAprvDetail?aprvNo=\${aprvNo}`;
        const name = "ApprovalDetail";
        const specs = "width=900,height=1000,scrollbars=yes";
        window.open(url, name, specs);
    }

    function openAprvDetail(aprvNo) {
        const url = `/approval/openAprvDetail?aprvNo=\${aprvNo}`;
        const name = "ApprovalDetail";
        const specs = "width=900,height=1000,scrollbars=yes";
        window.open(url, name, specs);
    }


    // 오프캔버스 정보 로딩
    function openTimeline(aprvNo, aprvTtl, aprvDt) {
        document.getElementById('offcanvasDocNo').innerText = "문서번호: " + aprvNo;
        document.getElementById('offcanvasDocTitle').innerText = aprvTtl;
        document.getElementById('offcanvasDraftDate').innerText = "기안일: " + (aprvDt ? aprvDt.substring(0, 10) : '');

        const offcanvasElement = document.getElementById('approvalTimelineOffcanvas');
        const bsOffcanvas = bootstrap.Offcanvas.getOrCreateInstance(offcanvasElement);
        bsOffcanvas.show();

        document.getElementById('mainSection').classList.add('shrunk');

        const timelineArea = document.getElementById('timelineContentArea');
        timelineArea.innerHTML = `<div class="text-center mt-5"><div class="spinner-border text-primary" role="status"></div><p class="mt-2 text-muted">결재 히스토리를 불러오는 중입니다...</p></div>`;

        Promise.all([
            axios.get(`/approval/getPendingDoc?aprvNo=\${aprvNo}`),
            axios.get(`/approval/getAprvLine?aprvNo=\${aprvNo}`)
        ])
            .then(response => {
                const docData = response[0].data;
                const lineList = response[1].data;

                const workTagText = docData.aprvWorkTagNm || '업무태그가 없습니다.';
                document.getElementById('offcanvasDocTitle').innerHTML = `
                <span class="work-tag-badge">
                    <span class="material-icons" style="font-size: 13px; margin-right: 4px;">local_offer</span>
                    \${workTagText}
                </span><br>
                <span class="fw-bold" style="font-size: 1.15rem; color: #2c3e50; line-height: 1.4;">\${aprvTtl}</span>
            `;

                let html = '';
                const docWriterEmpProfile = docData.docWriterEmpProfile ? `/displayPrf?fileName=\${docData.docWriterEmpProfile}` : 'https://i.pravatar.cc/150?u=a042581f4e29026704d';

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

                lineList.forEach((line) => {
                    let statusBadge = '';
                    let commentHtml = '';
                    let statusClass = '';

                    const profileImg = line.empProfile ? `/displayPrf?fileName=\${line.empProfile}` : 'https://i.pravatar.cc/150?u=a042581f4e29026704d';

                    if (line.aprvLnStts === 'APRV02001') {
                        statusBadge = `<span class="status-badge-clean bg-clean-info ms-2">대기</span>`;
                        statusClass = 'pending';
                    } else if (line.aprvLnStts === 'APRV02002') {
                        statusBadge = `<span class="status-badge-clean bg-clean-primary ms-2">결재</span>`;
                        statusClass = 'approved';
                        if (line.aprvLnCn) {
                            commentHtml = `<div class="comment-box approve"><span class="material-icons align-middle me-1" style="font-size: 14px; color: #696cff;">chat</span>\${line.aprvLnCn}</div>`;
                        }
                    } else if (line.aprvLnStts === 'APRV02003') {
                        statusBadge = `<span class="status-badge-clean bg-clean-danger ms-2">반려</span>`;
                        statusClass = 'rejected';
                        if (line.aprvLnCn) {
                            commentHtml = `<div class="comment-box reject"><span class="material-icons align-middle me-1" style="font-size: 14px; color: #E53E3E;">report_problem</span>\${line.aprvLnCn}</div>`;
                        }
                    }

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
            })
            .catch(err => {
                console.error("결재선 로딩 에러:", err);
                timelineArea.innerHTML = `<div class="alert alert-danger">데이터를 불러오는 중 오류가 발생했습니다.</div>`;
            });
    }


    document.addEventListener("DOMContentLoaded", function() {
        const modeSelect = document.querySelector("select[name='mode']");
        const keywordInput = document.querySelector("input[name='keyword']");
        let modeValue = (modeSelect) ? modeSelect.value : "";
        let keywordValue = (keywordInput) ? keywordInput.value : "";

        let data = {
            "currentPage": 1,
            "mode": modeValue,
            "keyword": keywordValue
        };

        axios.post("/approval/getMyPendingAprvAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                listShowFn(response.data);
            })
            .catch(err => {
                console.error("err : ", err);
            });

        const btnSearch = document.getElementById("btnSearch");
        btnSearch.addEventListener("click", () => {


            //검색어 길이 유효성 검사 추가함
            const keywordInput = document.querySelector("input[name='keyword']");
            const keywordVal = keywordInput.value || "";

            if (keywordVal.length > 30) {
                AppAlert.warning('검색어 길이 초과', '검색어는 최대 30자까지만 입력할 수 있습니다.', 'searchKeyword', 'text_fields');
                return;
            }


            const data = {
                "currentPage": 1,
                "mode": document.querySelector("select[name='mode']").value || "",
                "keyword": document.querySelector("input[name='keyword']").value || ""
            };

            if (currentSearchType === 'PENDING') {
                axios.post("/approval/getMyPendingAprvAxios", data, { headers: { "Content-Type": "application/json;charset=utf-8" } })
                    .then(response => listShowFn(response.data))
                    .catch(err => console.error(err));
            } else if (currentSearchType === 'PENDINGDONE') {
                axios.post("/approval/getPendingDoneAprvAxios", data, { headers: { "Content-Type": "application/json;charset=utf-8" } })
                    .then(response => listDoneShowFn(response.data))
                    .catch(err => console.error(err));
            }
        });

        const offcanvasElement = document.getElementById('approvalTimelineOffcanvas');
        offcanvasElement.addEventListener('hide.bs.offcanvas', function () {
            document.getElementById('mainSection').classList.remove('shrunk');
        });
    });


    function startApprovalTutorial() {
        const driver = window.driver.js.driver;
        const driverObj = driver({
            showProgress: true,
            animate: true,
            allowClose: true,
            doneBtnText: '튜토리얼 종료',
            closeBtnText: '건너뛰기',
            nextBtnText: '다음 ❯',
            prevBtnText: '❮ 이전',
            steps: [
                {
                    element: '.col-xl:nth-child(1) .aprv-dash-card',
                    popover: {
                        title: '결재 대기 문서',
                        description: '현재 내가 <span style="color: #ff3e1d; font-weight: bold;">가장 먼저 확인하고 결재해야 할</span><br> 문서들의 수입니다.',
                        side: "bottom", align: 'start'
                    }
                },
                {
                    element: '.col-xl:nth-child(2) .aprv-dash-card',
                    popover: {
                        title: '수신 참조 문서',
                        description: '직접 결재할 필요는 없지만, 업무 파악을 위해 <span style="color: #03c3ec; font-weight: bold;">나를 참조인으로 지정한 문서</span>들입니다.',
                        side: "bottom", align: 'center'
                    }
                },
                {
                    element: '.col-xl:nth-child(3) .aprv-dash-card',
                    popover: {
                        title: '결재 완료(내역)',
                        description: '내가 이미 승인하거나 반려 처리를 <span style="color: #71dd37; font-weight: bold;">완료한 문서 목록</span>입니다.',
                        side: "bottom", align: 'start'
                    }
                },
                {
                    element: '#aprvTb',
                    popover: {
                        title: '결재 처리하기 (승인/반려)',
                        description: '목록에서 <span style="color: #696cff; font-weight: bold;">문서 제목을 클릭</span>하면 결재 상세 창이 열립니다.',
                        side: "top", align: 'start'
                    }
                },
                {
                    element: '#aprvTb tbody tr:first-child .btn-outline-secondary',
                    popover: {
                        title: '문서 정보 확인',
                        description: '우측에서 <span style="color: #696cff; font-weight: bold;">업무 태그 및 결재 진행 현황</span>등 문서 정보를 쉽게 확인할 수 있습니다!',
                        side: "left", align: 'center'
                    }
                }
            ],
            onHighlightStarted: (element, step, options) => {
                if(step.popover.title === '문서 정보 확인') {
                    const historyBtn = document.querySelector('#aprvTb tbody tr:first-child .btn-outline-secondary');
                    if(historyBtn) {
                        historyBtn.click();
                    }
                }
            },
            onDeselected: (element, step, options) => {
                if(step.popover.title === '문서 정보 확인') {
                    const closeBtn = document.querySelector('#approvalTimelineOffcanvas .btn-close');
                    if(closeBtn) {
                        closeBtn.click();
                    }
                }
            }
        });
        driverObj.drive();
    }


    function showEmptyReferenceList() {
        currentSearchType = 'REFERENCE';
        document.getElementById("myList").innerText = '수신 참조 문서 목록';
        const emptyHtml = `
            <tr>
                <td colspan="6" class="text-center text-muted py-5" style="background-color: #fff !important; cursor: default;">
                    <div class="d-flex flex-column align-items-center my-4">
                        <span class="material-icons mb-2" style="font-size: 3.5rem; color: #e1e4e8;">folder_off</span>
                        <span class="fw-bold" style="color: #8592a3;">조회된 결재 문서가 없습니다.</span>
                    </div>
                </td>
            </tr>
        `;
        document.querySelector("#aprvTbody").innerHTML = emptyHtml;
        document.getElementById("tdPagingArea").innerHTML = "";
    }

</script>