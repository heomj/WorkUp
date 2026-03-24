<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<%@ page import="java.util.Date"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/themes/default/style.min.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/jstree.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<!-- 알람 커스텀 -->
<script src="/js/common-alert.js"></script>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.css"/>
<script src="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.js.iife.js"></script>



<style>
    /* 전체 리스트 스타일 */
    .my-attachment-list {
        display: flex;
        flex-wrap: wrap;
        padding: 0;
        margin: 0;
        list-style: none;
    }

    /* 개별 아이콘 박스 */
    .my-attachment-item {
        width: 150px;
        border: 1px solid #ddd;
        border-radius: 5px;
        margin-right: 15px;
        margin-bottom: 15px;
        background: #fff;
        text-align: center;
        padding: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }

    /* 큰 아이콘 영역 */
    .my-attachment-icon {
        display: block;
        font-size: 40px;
        color: #555;
        margin-bottom: 10px;
    }

    /* 파일명 텍스트 */
    .my-attachment-name {
        display: block;
        font-size: 11px;
        font-weight: bold;
        color: #333;
        text-overflow: ellipsis;
        white-space: nowrap;
        overflow: hidden;
    }

    /* 파일 용량 텍스트 */
    .my-attachment-size {
        font-size: 10px;
        color: #888;
    }

    /* 문서 양식 전용 스타일 */
    .document-container {
        width: 100%;
        max-width: 800px;
        min-height: 900px;
        margin: 0 auto;
        padding: 40px;
        background-color: #fff;
        border: 1px solid #ddd;
        box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        font-family: "Malgun Gothic", "맑은 고딕", sans-serif;
    }
    .top-center-header {
        text-align: center;
        margin-bottom: 30px;
    }
    .slogan {
        font-size: 14px;
        color: #666;
        margin-bottom: 5px;
    }
    .logo-company-wrapper {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 15px;
    }
    .logo-company-wrapper img {
        height: 40px;
        /* 로고 이미지 크기 조절 */
    }
    .company-name {
        font-size: 28px;
        font-weight: 900;
        letter-spacing: 5px;
    }

    .info-approval-wrapper {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 30px;
    }
    .doc-info {
        font-size: 14px;
        line-height: 1.8;
    }

    .approval-section {
        /* 결재란 우측 정렬 */
    }
    .approval-table {
        border-collapse: collapse;
        text-align: center;
        font-size: 13px;
    }
    .approval-table th, .approval-table td {
        border: 1px solid #333;
        padding: 5px;
    }
    .aprv-side-title {
        width: 30px;
        background-color: #f4f4f4;
        font-weight: bold;
    }
    .approval-table td:not(.aprv-side-title) {
        width: 75px;
        height: 25px;
        /* 직급 행 높 */
    }

    .doc-title {
        font-size: 22px;
        font-weight: bold;
        text-align: center;
        margin: 20px 0;
        letter-spacing: 2px;
    }
    .section-divider {
        border-top: 2px solid #333;
        margin-bottom: 30px;
    }

    .main-content-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
        font-size: 14px;
    }
    .main-content-table th, .main-content-table td {
        border: 1px solid #666;
        padding: 10px;
    }
    .bg-label {
        background-color: #f8f9fa;
        text-align: center;
        font-weight: bold;
    }

    /* jsTree 조직도 모달 전용 스타일 */
    .org-tree-wrapper {
        height: 450px;
        width: 100%;
        overflow-y: auto;
        overflow-x: auto; /* 가로 스크롤 허용 */
    }

    #jstree_div {
        width: 100%;
        min-width: 200px; /* 트리가 너무 찌그러지지 않게 최소 너비 보장 */
    }

    /* 트리의 글자가 줄바꿈되어 깨지지 않도록 한 줄로 유지 */
    #jstree_div .jstree-anchor {
        white-space: nowrap !important;
    }

    /* 💡 버튼 공통 애니메이션 및 둥글기 */
    .btn-custom {
        transition: all 0.2s ease-in-out;
        border-radius: 6px;
    }
    .btn-custom:hover {
        transform: translateY(-2px);
    }

    /* 1. 취소 버튼 */
    .btn-cancel {
        background-color: #fff;
        color: #ff3e1d;
        border: 1px solid #ff3e1d;
        box-shadow: 0 2px 4px rgba(255, 62, 29, 0.15);
    }
    .btn-cancel:hover {
        background-color: #fff2f0;
        color: #ff3e1d;
        box-shadow: 0 4px 8px rgba(255, 62, 29, 0.3);
    }



    /* 3. 결재선 지정 버튼 */
    .btn-aprv-line {
        background-color: #fff;
        color: #696cff;
        border: 1px solid #696cff;
        box-shadow: 0 2px 4px rgba(105, 108, 255, 0.15);
    }
    .btn-aprv-line:hover {
        background-color: #f8f9ff;
        color: #696cff;
        box-shadow: 0 4px 8px rgba(105, 108, 255, 0.3);
    }

    /* 4. 상신 버튼 */
    .btn-submit {
        background-color: #696cff;
        color: #ffffff;
        border: none;
        box-shadow: 0 2px 4px rgba(105, 108, 255, 0.4);
    }
    .btn-submit:hover {
        background-color: #5f61e6;
        color: #ffffff;
        box-shadow: 0 4px 8px rgba(105, 108, 255, 0.6);
    }


    /* --- 결재선 모달 커스텀 스타일 --- */
    #approverModal .modal-content {
        border-radius: 12px;
        overflow: hidden;
    }

    /* 헤더 메인 컬러 적용 */
    #approverModal .modal-header {
        background-color: #696cff !important;
        border-bottom: none;
        padding: 1.25rem 1.5rem;
    }

    #approverModal .modal-title {
        letter-spacing: -0.5px;
    }

    /* 검색창 & 버튼 스타일 */
    #approverModal .input-group .form-control {
        border-color: #d9dee3;
        border-radius: 6px 0 0 6px;
    }
    #approverModal .input-group .btn-primary {
        background-color: #696cff;
        border-color: #696cff;
        border-radius: 0 6px 6px 0;
    }
    #approverModal .input-group .btn-primary:hover {
        background-color: #5f61e6;
    }

    /* 탭 메뉴 스타일 */
    #approverModal .nav-tabs {
        border-bottom: 2px solid #eaeaec;
    }
    #approverModal .nav-tabs .nav-link {
        color: #566a7f;
        border: none;
        border-bottom: 2px solid transparent;
        margin-bottom: -2px;
        padding: 0.75rem 1.5rem;
    }
    #approverModal .nav-tabs .nav-link.active {
        color: #696cff;
        font-weight: 800;
        border-bottom: 2px solid #696cff;
        background: transparent;
    }

    /* 테이블 스타일 */
    #approverModal .table {
        border-radius: 8px;
        overflow: hidden;
        border: 1px solid #eaeaec;
    }
    #approverModal .table-light {
        background-color: #f8f9fa;
        color: #566a7f;
        font-size: 0.85rem;
    }

    /* 기안자 로우(Row) 스타일 */
    #approverModal .table-secondary {
        background-color: #f0f2ff !important; /* 메인 컬러의 아주 연한 톤 */
    }
    #approverModal .badge.bg-secondary {
        background-color: #696cff !important; /* 기안 뱃지를 메인 컬러로 */
    }

    /* 적용 버튼 */
    #applyApprovalLineBtn {
        background-color: #696cff;
        border: none;
        border-radius: 6px;
        transition: all 0.2s;
    }
    #applyApprovalLineBtn:hover {
        background-color: #5f61e6;
        transform: translateY(-2px);
        box-shadow: 0 4px 10px rgba(105, 108, 255, 0.3);
    }


    /* --- 결재선 모달: 순서 변경 및 삭제 버튼 커스텀 --- */
    .btn-order-ctrl {
        width: 28px;
        height: 28px;
        padding: 0;
        border-radius: 6px;
        border: 1px solid #d9dee3;
        background-color: #fff;
        color: #a1acb8;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
        box-shadow: 0 1px 2px rgba(0,0,0,0.02);
    }

    /* 마우스 호버 시 메인 컬러(#696cff)로 부드럽게 강조! */
    .btn-order-ctrl:hover {
        background-color: #f0f2ff;
        border-color: #696cff;
        color: #696cff;
        transform: translateY(-1px);
    }

    .btn-order-ctrl .material-icons {
        font-size: 18px;
    }

    /* 삭제 버튼 전용 (빨간색 포인트) */
    .btn-delete-ctrl {
        width: 30px;
        height: 30px;
        padding: 0;
        border-radius: 6px;
        border: none;
        background-color: transparent;
        color: #ff3e1d;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
    }

    .btn-delete-ctrl:hover {
        background-color: #ffe0db;
        color: #ff3e1d;
        transform: scale(1.05);
    }

    .btn-delete-ctrl .material-icons {
        font-size: 20px;
    }


    /* 결재선 모달 내 '결재' 배지 */
    .bg-label-info {
        background-color: #d7f5fc !important;
        color: #03c3ec !important;
        font-weight: 700 !important;
    }



</style>

<div class="row g-4 mb-4">
    <div class="d-flex justify-content-between align-items-center mb-4 bg-white p-3 rounded shadow-sm">

        <!-- 왼쪽 영역 -->
        <div class="d-flex gap-2">
            <button class="btn btn-custom btn-cancel d-flex align-items-center fw-bold px-3" onclick="location.href='/approval/myAprvBoard'">
                <span class="material-icons me-1">close</span> 취소
            </button>

            <!-- 자동완성 -->
            <button type="button" class="btn d-flex align-items-center fw-bold px-3" onclick="fillDummyData()"
                    style="background-color: #e2e6ea; color: #566a7f; border: 1px solid #d9dee3; border-radius: 6px; transition: 0.2s;"
                    onmouseover="this.style.backgroundColor='#d3d8de'" onmouseout="this.style.backgroundColor='#e2e6ea'">
                <span class="material-icons me-1" style="font-size: 18px;">auto_fix_high</span> 자동완성
            </button>
        </div>

        <!-- 오른쪽 영역 -->
        <div class="d-flex gap-2">
            <button onclick="startVctTutorial()" style="display: flex; align-items: center; gap: 5px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 10px 15px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.2s;" onmouseover="this.style.backgroundColor='#f8f9fa'" onmouseout="this.style.backgroundColor='#fff'">
                <span class="material-icons" style="font-size: 1.1rem;">help_outline</span> 튜토리얼
            </button>

            <button class="btn btn-custom btn-aprv-line d-flex align-items-center fw-bold px-3" data-bs-toggle="modal" data-bs-target="#approverModal">
                <span class="material-icons me-1">account_tree</span> 결재선 지정
            </button>

            <button id="submitAprvBtn" class="btn btn-custom btn-submit d-flex align-items-center fw-bold px-4">
                <span class="material-icons me-1" style="color: #ffffff;">approval</span> 상신
            </button>
        </div>


    </div>

    <div class="row">
        <div class="col-lg-8">
            <div class="card shadow-sm mb-4 border-0" style="background-color: #f8f9fa;">
                <div class="card-body p-4 mx-auto bg-white shadow-sm document-container" id="pdfArea">
                    <div class="top-center-header">
                        <div class="slogan">개발자가 행복한 회사</div>
                        <div class="logo-company-wrapper">
                            <img src="/images/icon.png" alt="Logo" onerror="this.src='https://via.placeholder.com/40x40?text=LOGO'">
                            <div class="company-name">일업주식회사</div>
                        </div>
                    </div>

                    <div class="info-approval-wrapper">
                        <div class="doc-info mt-auto"></div>

                        <div class="approval-section">
                            <table class="approval-table">
                                <tr>
                                    <td rowspan="2" class="aprv-side-title">결<br>재</td>
                                    <td id="posNm1" class="bg-light">${empJbgd}</td>
                                    <td id="posNm2" class="bg-light">-</td>
                                    <td id="posNm3" class="bg-light">-</td>
                                    <td id="posNm4" class="bg-light">-</td>
                                    <td id="posNm5" class="bg-light">-</td>
                                </tr>
                                <tr style="height: 60px;">
                                    <td id="aprvLine1" class="align-middle fw-bold">-</td>
                                    <td id="aprvLine2">-</td>
                                    <td id="aprvLine3">-</td>
                                    <td id="aprvLine4">-</td>
                                    <td id="aprvLine5">-</td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div class="doc-title"></div>
                    <hr class="section-divider">

                    <div id="docBody" class="mt-4">
                        <div class="d-flex justify-content-between align-items-end mb-2">
                            <div>
                                <label class="form-label fw-bold mb-0">
                                    부서 예산 지출 내역
                                </label>
                                <div class="small text-muted mt-1">※ 지출할 비목에만 금액과 사유를 입력해 주세요. (잔액 초과 불가)</div>
                            </div>
                            <div class="small fw-bold text-muted pb-1">
                                (단위: 원)
                            </div>
                        </div>

                        <table class="main-content-table text-center" id="expenseTable">
                            <colgroup>
                                <col style="width: 20%;"> <col style="width: 15%;"> <col style="width: 15%;"> <col style="width: 15%;"> <col style="width: 35%;">
                            </colgroup>
                            <thead>
                            <tr class="bg-label">
                                <th>예산 비목</th>
                                <th>현재 예산</th>
                                <th>지출 금액</th>
                                <th>예산 잔액</th>
                                <th>적요 (사유)</th>
                            </tr>
                            </thead>
                            <tbody id="expenseTbody">
                            <c:forEach var="budget" items="${budgetList}" varStatus="status">
                                <tr class="budget-row">
                                    <td class="text-start fw-bold bg-light">
                                        <input type="hidden" class="bgtCd" value="${budget.bgtCd}">
                                        <input type="hidden" class="bgtMCd" value="${budget.bgtMCd}">
                                            ${budget.bgtItmNm}
                                    </td>
                                    <td class="text-end text-primary fw-bold bg-light">
                                        <c:set var="balance" value="${budget.bgtAmt - budget.bgtExcn}" />
                                        <fmt:formatNumber value="${balance}" pattern="#,###" />
                                        <input type="hidden" class="bgtBalance" value="${balance}">
                                    </td>
                                    <td>
                                        <input type="text" class="form-control form-control-sm text-end bgtChgAmt calc-input" placeholder="0">
                                    </td>
                                    <td class="text-end fw-bold align-middle">
                                        <span class="afterBalance text-muted">-</span>
                                    </td>
                                    <td>
                                        <input type="text" class="form-control form-control-sm bgtChgRsn" placeholder="사유 입력">
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty budgetList}">
                                <tr>
                                    <td colspan="5" class="text-center text-muted py-3">배정된 예산 비목이 없습니다.</td>
                                </tr>
                            </c:if>
                            </tbody>

                            <tfoot>
                            <tr class="bg-light fw-bold">
                                <td colspan="2" class="text-center align-middle">총 지출 합계</td>
                                <td class="text-end text-danger align-middle">
                                    <span id="totalExpenseAmt">0</span>
                                </td>
                                <td colspan="2"></td>
                            </tr>
                            </tfoot>
                        </table>


                        <input type="hidden" id="selectedAttTypeId" name="attTypeId" value="0">
                        <div class="mt-4 fw-bold text-start ps-2">위와 같이 기안하오니 재가하여 주시기 바랍니다.</div>
                        <div class="mt-2 fw-bold text-start ps-2">끝.</div>
                    </div>




                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card shadow-sm mb-4">
                <div class="card-header bg-light">
                    <h6 class="card-title mb-0 fw-bold">결재선 정보</h6>
                </div>
                <div class="card-body p-0">
                    <ul class="list-group list-group-flush" id="approvalLineInfoList">
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            <div>
                                <div class="fw-bold">${empNm} ${empJbgd} (기안)</div>
                                <div class="small text-muted">${deptNm} | 2026-02-11</div>
                            </div>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            <div>
                                <div class="fw-bold"></div>
                                <div class="small text-muted"></div>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="card shadow-sm border-top border-primary border-3">
                <div class="card-header bg-light d-flex justify-content-between align-items-center">
                    <h6 class="card-title mb-0 fw-bold">문서 정보</h6>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label small fw-bold">업무 태그</label>
                        <select class="form-select form-select-sm" id="workTagSelect" name="workTag">
                            <option value="" selected disabled>-- 업무 태그를 선택해 주세요 --</option>
                            <optgroup label="[공통 / 일반 업무]">
                                <option value="C01">일반 행정/서무</option>
                                <option value="C02">근태</option>
                                <option value="C03">예산</option>
                            </optgroup>
                            <optgroup label="[현재 진행 중인 프로젝트]">
                                <c:forEach var="project" items="${ingProjectList}">
                                    <option value="${project.projNo}">${project.projTtl}</option>
                                </c:forEach>
                                <c:if test="${empty ingProjectList}">
                                    <option value="" disabled>진행 중인 프로젝트가 없습니다.</option>
                                </c:if>
                            </optgroup>
                            <c:if test="${not empty doneProjectList}">
                                <optgroup label="[최근 종료된 프로젝트 (정산/보고용)]">
                                    <c:forEach var="donePrj" items="${doneProjectList}">
                                        <option value="${donePrj.projNo}">${donePrj.projTtl}</option>
                                    </c:forEach>
                                </optgroup>
                            </c:if>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-bold">문서 제목</label>
                        <input type="text" class="form-control form-control-sm" placeholder="제목을 입력하세요 (최대 50자)" id="docTitle" maxlength="50">
                    </div>

                    <div class="mb-3 p-2 bg-light rounded">
                        <div class="form-check form-switch mb-2">
                            <input class="form-check-input" type="checkbox" id="urgentCheck">
                            <label class="form-check-label fw-bold text-danger small" for="urgentCheck">긴급 문서로 처리</label>
                        </div>
                        <div class="d-flex gap-3">
                            <label class="small text-muted">공개여부:</label>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="openYn" id="openY" checked>
                                <label class="form-check-label small" for="openY">부서공개</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="openYn" id="openN">
                                <label class="form-check-label small" for="openN">비공개</label>
                            </div>
                        </div>
                    </div>

                    <div class="mb-0">
                        <label class="form-label small fw-bold">첨부파일</label>
                        <div class="form-group">
                            <label>첨부파일 (여러 개 선택 가능)</label>
                            <div class="custom-file">
                                <input type="file" name="multipartFiles" id="input_file" class="form-control custom-file-input" multiple>
                            </div>
                        </div>
                        <div class="mt-3" style="border:1px solid #ddd; padding:10px; min-height:100px;">
                            <p>선택된 파일 목록:</p>
                            <ul id="file_list_area" style="display: flex; flex-wrap: wrap; list-style: none; padding: 0;"></ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- 결재선 모달 -->
<div class="modal fade" id="approverModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content shadow-lg border-0">
            <div class="modal-header text-white">
                <h5 class="modal-title fw-bold d-flex align-items-center">
                    <span class="material-icons align-middle me-2">person_add</span> 결재정보 설정
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body p-4">
                <div class="row" style="min-height: 500px;">
                    <div class="col-md-4 border-end pe-4">
                        <div class="input-group mb-3 shadow-sm">
                            <input type="text" id="orgSearchInput" class="form-control px-3" placeholder="성명 또는 부서 검색">
                            <button class="btn btn-primary px-3" id="orgSearchBtn">
                                <span class="material-icons align-middle" style="font-size: 20px;">search</span>
                            </button>
                        </div>
                        <div class="p-3 bg-light rounded org-tree-wrapper shadow-sm border" style="border-color: #eaeaec !important;">
                            <div id="jstree_div"></div>
                        </div>
                    </div>

                    <div class="col-md-8 ps-4">
                        <nav>
                            <div class="nav nav-tabs mb-4" id="nav-tab" role="tablist">
                                <button class="nav-link active fw-bold" data-bs-toggle="tab" data-bs-target="#tab-approver">결재선 (최대 4인)</button>
                            </div>
                        </nav>

                        <div class="table-responsive shadow-sm rounded">
                            <table class="table table-hover align-middle mb-0" id="approvalTable">
                                <thead class="table-light">
                                <tr class="text-center">
                                    <th style="width: 80px;">순서</th>
                                    <th style="width: 100px;">타입</th>
                                    <th class="text-start">성명/직급</th>
                                    <th class="text-start">부서</th>
                                    <th style="width: 110px;">순서변경</th>
                                    <th style="width: 80px;">삭제</th>
                                </tr>
                                </thead>
                                <tbody>
                                <tr class="table-secondary" data-emp-id="${docWriterId}">
                                    <td class="text-center fw-bold text-muted">1</td>
                                    <td class="text-center"><span class="badge bg-secondary px-2 py-1">기안</span></td>
                                    <td class="text-start"><strong style="color: #696cff;">${empNm}</strong> <span class="text-muted small">(${empJbgd})</span></td>
                                    <td class="text-start text-muted">${deptNm}</td>
                                    <td class="text-center text-muted">-</td>
                                    <td class="text-center text-muted">-</td>
                                </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="alert mt-4 d-flex align-items-center" style="background-color: #f0f2ff; color: #696cff; border: 1px solid #d9dcff; border-radius: 8px; padding: 12px 16px;">
                            <span class="material-icons align-middle me-2">info</span>
                            <small class="fw-bold">화살표 버튼을 클릭하여 결재 우선순위를 자유롭게 변경할 수 있습니다.</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer bg-light border-top-0 px-4 py-3">
                <button type="button" class="btn btn-outline-secondary px-4 fw-bold" data-bs-dismiss="modal" style="border-radius: 6px;">취소</button>
                <button type="button" id="applyApprovalLineBtn" class="btn btn-primary px-5 fw-bold text-white shadow-sm">결재선 적용</button>
            </div>
        </div>
    </div>
</div>

<script>
    //////////// 결재선 설정 ////////////
    function addApprover(empId, name, rank, dept) {
        const table = document.getElementById('approvalTable').getElementsByTagName('tbody')[0];
        const rowCount = table.rows.length;

        if(rowCount >= 5) {
            AppAlert.warning('인원 초과', '결재선은 최대 4명(기안자 포함 5명)까지<br>설정 가능합니다.', null, 'priority_high');
            return;
        }

        const newRow = table.insertRow();
        newRow.setAttribute('data-emp-id', empId);

        // 💡 텍스트 정렬과 커스텀 버튼 디자인 적용!
        newRow.innerHTML = `
        <td class="text-center fw-bold text-muted">\${rowCount + 1}</td>
        <td class="text-center"><span class="badge bg-label-info px-2 py-1">결재</span></td>
        <td class="text-start"><strong style="color: #566a7f;">\${name}</strong> <span class="text-muted small">(\${rank})</span></td>
        <td class="text-start text-muted">\${dept}</td>
        <td class="text-center">
            <div class="d-flex justify-content-center gap-1">
                <button class="btn-order-ctrl" onclick="moveRow(this, 'up')" title="위로">
                    <span class="material-icons">keyboard_arrow_up</span>
                </button>
                <button class="btn-order-ctrl" onclick="moveRow(this, 'down')" title="아래로">
                    <span class="material-icons">keyboard_arrow_down</span>
                </button>
            </div>
        </td>
        <td class="text-center">
            <button class="btn-delete-ctrl" onclick="deleteRow(this)" title="삭제">
                <span class="material-icons">delete_outline</span>
            </button>
        </td>
    `;
    }

    function deleteRow(btn) {
        const row = btn.parentNode.parentNode;
        row.parentNode.removeChild(row);
        reorderSteps();
    }

    function moveRow(btn, direction) {
        const row = btn.closest('tr');
        if (direction === 'up') {
            const prev = row.previousElementSibling;
            if (prev && !prev.classList.contains('table-secondary')) {
                row.parentNode.insertBefore(row, prev);
            }
        } else {
            const next = row.nextElementSibling;
            if (next) {
                row.parentNode.insertBefore(next, row);
            }
        }
        reorderSteps();
    }

    function reorderSteps() {
        const table = document.getElementById('approvalTable').getElementsByTagName('tbody')[0];
        for (let i = 0; i < table.rows.length; i++) {
            table.rows[i].cells[0].innerText = i + 1;
        }
    }
    //////////// 결재선 설정 끝////////////

    //첨부파일///////////////////////////
    document.querySelector('#input_file').addEventListener('change', function(e) {
        const files = e.target.files;
        const fileArea = document.querySelector('#file_list_area');
        fileArea.innerHTML = "";

        if (files.length === 0) return;

        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const fileName = file.name;
            const fileExt = fileName.split('.').pop().toLowerCase();

            let iconClass = "fa-file";
            let iconColor = "#666";

            if (fileExt === 'pdf') { iconClass = "fa-file-pdf"; iconColor = "#e74c3c"; }
            else if (['png', 'jpg', 'jpeg'].includes(fileExt)) { iconClass = "fa-file-image"; iconColor = "#27ae60"; }
            else if (['hwp', 'hwpx'].includes(fileExt)) { iconClass = "fa-file-word"; iconColor = "#2980b9"; }
            else if (fileExt === 'zip') { iconClass = "fa-file-archive"; iconColor = "#f39c12"; }

            let html = `
            <li style="margin: 10px; width: 120px; text-align: center; list-style: none;">
                <div class="mb-2" style="font-size: 40px; color: \${iconColor};">
                    <i class="fas \${iconClass}"></i>
                </div>
                <div style="font-size: 11px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="\${fileName}">
                    \${fileName}
                </div>
            </li>
        `;
            fileArea.insertAdjacentHTML('beforeend', html);
        }
    });

    ///////////////////// 조직도 모달이 열릴 때 js tree /////////////////////
    document.getElementById('approverModal').addEventListener('shown.bs.modal', function () {
        initApproverJsTree();
    });

    function initApproverJsTree() {
        if($('#jstree_div').jstree(true)) return;
        const rankPriority = { '대표': 1, '팀장': 2, '대리': 3, '주임': 4, '사원': 5 };
        axios.get("/indivList").then(res => {
            let treeData = [];

            res.data.forEach(dept => {
                treeData.push({ id: "D" + dept.deptCd, parent: "#", text: dept.deptNm, type: "dept" });

                if (dept.teamLeaders) {
                    dept.teamLeaders.forEach(leader => {
                        treeData.push({
                            id: leader.empId,
                            parent: "D" + dept.deptCd,
                            text: `\${leader.empNm} (\${leader.empJbgd})`,
                            type: "leader",
                            data: { name: leader.empNm, rank: leader.empJbgd, dept: dept.deptNm }
                        });

                        if (leader.teamEmployee && leader.teamEmployee.length > 0) {
                            let sortedMembers = [...leader.teamEmployee].sort((a, b) => {
                                const priorityA = rankPriority[a.empJbgd] || 99;
                                const priorityB = rankPriority[b.empJbgd] || 99;
                                if (priorityA !== priorityB) return priorityA - priorityB;
                                return a.empNm.localeCompare(b.empNm);
                            });
                            sortedMembers.forEach(member => {
                                treeData.push({
                                    id: member.empId,
                                    parent: "D" + dept.deptCd,
                                    text: `\${member.empNm} (\${member.empJbgd})`,
                                    type: "default",
                                    data: { name: member.empNm, rank: member.empJbgd, dept: dept.deptNm }
                                });
                            });
                        }
                    });
                }
            });

            $('#jstree_div').jstree({
                core: { data: treeData, check_callback: true },
                types: {
                    "default": { "icon": "fas fa-user text-secondary" },
                    "dept": { "icon": "fas fa-building text-primary" },
                    "leader": { "icon": "fas fa-user-tie text-warning" }
                },
                plugins: ['types', 'search']
            })
                .bind("ready.jstree", () => $('#jstree_div').jstree("open_all"))
                .bind("select_node.jstree", function(e, data) {
                    const nodeData = data.node.data;
                    if (nodeData) {
                        addApprover(data.node.id, nodeData.name, nodeData.rank, nodeData.dept);
                        $('#jstree_div').jstree("deselect_node", data.node);
                    }
                });
        }).catch(err => { console.error("조직도 데이터 로딩 실패:", err); });
    }

    document.getElementById('orgSearchBtn').addEventListener('click', function() {
        const keyword = document.getElementById('orgSearchInput').value;
        $('#jstree_div').jstree(true).search(keyword);
    });
    document.getElementById('orgSearchInput').addEventListener('keyup', function(e) {
        if (e.key === 'Enter') {
            const keyword = e.target.value;
            $('#jstree_div').jstree(true).search(keyword);
        }
    });
    ///////////////////// 조직도 모달이 열릴 때 js tree 끝 /////////////////////

    ///////////////////// 결재선 반영하기 /////////////////////
    let selectedApprovalLine = [];
    document.getElementById('applyApprovalLineBtn').addEventListener('click', function() {
        const table = document.getElementById('approvalTable').getElementsByTagName('tbody')[0];
        const rows = table.rows;

        selectedApprovalLine = [];

        for(let i = 0; i < rows.length; i++) {
            const cellText = rows[i].cells[2].innerText;
            const name = cellText.split('(')[0].trim();
            const rank = cellText.split('(')[1].replace(')', '').trim();
            const dept = rows[i].cells[3].innerText.trim();
            const empId = rows[i].getAttribute('data-emp-id');

            selectedApprovalLine.push({
                aprvLnLvl: i, empId: empId, name: name, rank: rank, dept: dept
            });
        }

        for(let i = 2; i <= 5; i++) {
            document.getElementById('posNm' + i).innerText = '-';
            document.getElementById('aprvLine' + i).innerText = '';
        }

        for(let i = 1; i < selectedApprovalLine.length; i++) {
            document.getElementById('posNm' + (i + 1)).innerText = selectedApprovalLine[i].rank;
            document.getElementById('aprvLine' + (i + 1)).innerText = '';
        }

        const infoList = document.getElementById('approvalLineInfoList');
        infoList.innerHTML = '';

        const today = new Date().toISOString().split('T')[0];
        selectedApprovalLine.forEach((appr, index) => {
            const isWriter = (index === 0);
            const badgeClass = isWriter ? 'bg-secondary' : 'bg-info';
            const typeText = isWriter ? '기안' : '결재';
            const dateText = isWriter ? today : '대기중';

            const html = `
             <li class="list-group-item d-flex justify-content-between align-items-center">
                <div>
                    <div class="fw-bold">\${appr.name} \${appr.rank} <span class="badge \${badgeClass} ms-1" style="font-size: 0.7rem;">\${typeText}</span></div>
                    <div class="small text-muted">\${appr.dept} | \${dateText}</div>
                </div>
             </li>
        `;
            infoList.insertAdjacentHTML('beforeend', html);
        });

        const modalEl = document.getElementById('approverModal');
        const modalInstance = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
        modalInstance.hide();

        // (알람 리팩토링): 모달 호출을 AppAlert 한 줄로 변경!
        AppAlert.autoClose('결재선 적용 완료', '결재선이 문서에 성공적으로 적용되었습니다.');
    });
    ///////////////////// 결재선 반영하기 끝/////////////////////

    ///////////////////////// 상신하기!!!! /////////////////////////
    document.getElementById('submitAprvBtn').addEventListener('click', function() {
        const docTitle = document.getElementById('docTitle').value;
        const aprvWorkTag = document.getElementById('workTagSelect').value;

        // 공통 유효성 검사
        if(!aprvWorkTag) {
            AppAlert.warning('업무 태그 미선택', '결재 문서를 분류할 업무 태그를 선택해 주세요.', 'workTagSelect', 'local_offer');
            return;
        }
        if(!docTitle) {
            AppAlert.warning('제목 입력 확인', '문서의 제목을 입력해 주세요.', 'docTitle', 'edit_note');
            return;
        }


        //혹시몰라 넣어두기
        if(docTitle.length > 50) {
            AppAlert.warning('제목 길이 초과', '문서 제목은 최대 50자까지만 입력할 수 있습니다.', 'docTitle', 'text_fields');
            return;
        }


        if(selectedApprovalLine.length <= 1) {
            AppAlert.warning('결재선 미설정', '결재를 진행할 결재선 정보를 설정해 주세요.', null, 'groups');
            return;
        }

        // 지출 내역 데이터 수집 및 잔액 검증
        const rows = document.querySelectorAll('.budget-row');
        const expenseDataList = []; // 지출 금액이 입력된 항목만 담을 배열
        let isValidationError = false;

        rows.forEach((row) => {
            const bgtCd = row.querySelector('.bgtCd').value;
            const bgtMCd = row.querySelector('.bgtMCd').value; // 💡 마스터 코드 가져오기!
            const bgtBalance = parseInt(row.querySelector('.bgtBalance').value || 0);

            // 입력된 지출 금액에서 콤마(,)를 모두 제거하고 순수 숫자로 변환
            const bgtChgAmtVal = row.querySelector('.bgtChgAmt').value.replace(/,/g, '');
            const bgtChgAmt = parseInt(bgtChgAmtVal || 0);
            const bgtChgRsn = row.querySelector('.bgtChgRsn').value.trim();

            // 지출 금액이 0보다 큰 경우만 배열에 담기
            if (bgtChgAmt > 0) {
                // 1. 잔액 초과 검사
                if (bgtChgAmt > bgtBalance) {
                    AppAlert.warning('예산 초과', '지출 금액이 예산 잔액을 초과할 수 없습니다.<br>(비목: ' + row.innerText.split('\n')[0].trim() + ')');
                    isValidationError = true;
                    return;
                }
                // 2. 사유 입력 검사
                if (!bgtChgRsn) {
                    AppAlert.warning('사유 누락', '지출 금액을 입력한 항목은 반드시 적요(사유)를 입력해야 합니다.');
                    isValidationError = true;
                    return;
                }

                // 검증 통과 시 배열에 추가 (마스터 코드 포함)
                expenseDataList.push({
                    bgtCd: bgtCd,
                    bgtMCd: bgtMCd,
                    expndAmt: bgtChgAmt, // 이름을 VO와 동일하게 변경
                    expndRsn: bgtChgRsn  // 이름을 VO와 동일하게 변경
                });
            }
        });

        if (isValidationError) return; // 에러 발생 시 상신 중단

        // 지출 금액을 한 군데도 입력하지 않은 경우
        if (expenseDataList.length === 0) {
            AppAlert.warning('지출 내역 없음', '최소 1개 이상의 예산 비목에 지출 금액을 입력해 주세요.', null, 'payments');
            return;
        }

        AppAlert.confirm('지출 품의 상신', '상신 후에는 기안 내용을 수정할 수 없습니다.<br>진행하시겠습니까?', '상신하기', '취소', 'send', 'primary')
            .then((result) => {
                if (result.isConfirmed) {
                    const formData = new FormData();

                    // 1. 기본 정보 세팅
                    formData.append("aprvTtl", docTitle);
                    formData.append("aprvEmrgYn", document.getElementById('urgentCheck').checked ? 'Y' : 'N');
                    formData.append("aprvRlsYn", document.getElementById('openY').checked ? 'Y' : 'N');
                    formData.append("aprvSe", "APRV01001"); // 지출품의서 양식 코드
                    formData.append("aprvWorkTag", aprvWorkTag);

                    // 2. 수집된 지출 리스트 데이터를 FormData에 담기 (Spring Boot List 바인딩 형태)
                    expenseDataList.forEach((expense, index) => {
                        formData.append(`expndDocList[\${index}].bgtCd`, expense.bgtCd);
                        formData.append(`expndDocList[\${index}].bgtMCd`, expense.bgtMCd); // 예산 마스터 코드(부서 예산 코드) 전송!
                        formData.append(`expndDocList[\${index}].expndAmt`, expense.expndAmt);
                        formData.append(`expndDocList[\${index}].expndRsn`, expense.expndRsn);
                    });

                    // 3. 결재선 정보
                    const realApprovers = selectedApprovalLine.slice(1);
                    realApprovers.forEach((approver, index) => {
                        formData.append(`aprvLineVOList[\${index}].aprvLnLvl`, approver.aprvLnLvl);
                        formData.append(`aprvLineVOList[\${index}].empId`, approver.empId);
                        formData.append(`aprvLineVOList[\${index}].name`, approver.name);
                        formData.append(`aprvLineVOList[\${index}].rank`, approver.rank);
                        formData.append(`aprvLineVOList[\${index}].dept`, approver.dept);
                    });

                    // 4. 첨부파일
                    const files = document.getElementById('input_file').files;
                    for (let i = 0; i < files.length; i++) {
                        formData.append("multipartFiles", files[i]);
                    }

                    // 5. Axios 전송
                    axios.post("/approval/submit", formData, {
                        headers: { "Content-Type": "multipart/form-data" }
                    })
                        .then(response => {
                            if(response.data === "SUCCESS") {
                                AppAlert.autoClose('상신 완료!', '지출 품의서가 성공적으로 상신되었습니다.', 'check_circle', 'success', 1500)
                                    .then(() => { window.location.href = "/approval/myAprvBoard"; });
                            } else {
                                AppAlert.error('상신 실패', '서버에서 오류를 반환했습니다.');
                            }
                        })
                        .catch(error => {
                            console.error("상신 에러:", error);
                            AppAlert.error('오류 발생', '상신 처리 중 네트워크 또는 서버 오류가 발생했습니다.');
                        });
                }
            });
    });


    // ==========================================
    // 💡 Driver.js 지출품의서 튜토리얼
    // ==========================================
    function startVctTutorial() { // 💡 함수명은 기존에 사용하신 버튼 onClick과 동일하게 유지했습니다.
        const driver = window.driver.js.driver;
        const driverObj = driver({
            showProgress: true, animate: true, allowClose: true,
            doneBtnText: '완료', closeBtnText: '건너뛰기', nextBtnText: '다음 ❯', prevBtnText: '❮ 이전',
            steps: [
                {
                    element: '#expenseTable', // 지출 내역 테이블 영역
                    popover: {
                        title: '지출 금액 및 사유 입력',
                        description: '부서 예산 비목을 확인하고 <span style="color: #696cff; font-weight: bold;">지출 금액과 사유를 입력</span>해 주세요.<br><br>' +
                            '<div style="background-color: #f8f9ff; padding: 10px; border-radius: 6px; font-size: 0.85rem; color: #566a7f; border: 1px solid rgba(105, 108, 255, 0.2); line-height: 1.4;">' +
                            '<b>💡 주의사항</b><br><span style="color: #ff3e1d; font-weight: bold;">예산 잔액을 초과</span>하여 지출할 수 없으며, <br />금액을 입력한 항목은 <span style="color: #696cff; font-weight: bold;">반드시 사유를 적어야</span> 합니다.</div>',
                        side: "top", align: 'center'
                    }
                },
                {
                    element: '.btn-aprv-line', // 결재선 지정 버튼
                    popover: {
                        title: '결재선 지정',
                        description: '지출 내역 작성이 완료되면 이 버튼을 눌러 <br /><span style="color: #696cff; font-weight: bold;">결재선(승인권자)</span>을 지정해야 합니다.<br><br>조직도에서 클릭하여 최대 4명까지 지정할 수 있습니다.',
                        side: "bottom", align: 'end'
                    }
                },
                {
                    element: '#workTagSelect', // 업무 태그 선택 영역
                    popover: {
                        title: '업무 태그 선택',
                        description: '이 지출이 어떤 업무와 관련된 것인지 <span style="color: #ff3e1d; font-weight: bold;">반드시 업무 태그를 선택</span>해야 상신할 수 있습니다.<br><br>[예산] 탭이나 관련된 프로젝트를 골라주세요!',
                        side: "left", align: 'start'
                    }
                },
                {
                    element: '#docTitle', // 제목 및 설정 영역 (우측 패널)
                    popover: {
                        title: '문서 제목 및 설정',
                        description: '우측 패널에서 <span style="color: #696cff; font-weight: bold;">문서의 제목</span>을 입력하고, 영수증 등 증빙 자료를 첨부파일로 추가할 수 있습니다.',
                        side: "left", align: 'start'
                    }
                },
                {
                    element: '#submitAprvBtn', // 상신 버튼
                    popover: {
                        title: '지출품의 상신',
                        description: '총 지출 합계와 결재선을 한 번 더 확인하신 후, <span style="color: #28a745; font-weight: bold;">상신 버튼</span>을 눌러 결재를 올립니다.',
                        side: "bottom", align: 'end'
                    }
                },
                {
                    element: '#menuWrapper', // Gemini
                    popover: {
                        title: 'AI 검토 (말 다듬)',
                        description: '상신 전 문서에 혹시 오류나 오타가 없는지 <span style="color: #0dcaf0; font-weight: bold;">AI(말 다듬)에게 검토</span>를 맡길 수도 있습니다!',
                        side: "top", align: 'end'
                    }
                }
            ]
        });
        driverObj.drive();
    }// 튜토리얼 함수 끝



    //DOM 시작
    document.addEventListener('DOMContentLoaded', function() {

        // ==========================================
        // 지출 금액 입력 시 실시간 '지출 후 예산 잔액' 계산
        // ==========================================
        const calcInputs = document.querySelectorAll('.calc-input'); //숫자 입력칸 받기
        const totalExpenseSpan = document.getElementById('totalExpenseAmt'); //총액 입력 칸..

        // 총합 계산 함수
        function updateTotalSum() {
            let total = 0;
            document.querySelectorAll('.calc-input').forEach(input => {
                // 콤마를 제거한 순수 숫자만 가져와서 더하기
                const val = parseInt(input.value.replace(/,/g, '') || 0);
                total += val;
            });
            // 계산된 총합에 콤마 찍어서 화면에 표시(toLocaleString 사용함! 그럼 한국, 미국같은곳은 얘가 알아서 천단위 찍어줌!)
            totalExpenseSpan.textContent = total.toLocaleString();
        }

        //숫자 입력값 반복하면서 천단위로 바꾸기
        calcInputs.forEach(input => {
            input.addEventListener('input', function() {
                // 1. 입력된 값에서 숫자 이외의 문자(콤마 등) 모두 제거
                let rawValue = this.value.replace(/[^0-9]/g, '');

                // 2. 숫자가 있으면 1,000 단위 콤마 찍어서 다시 입력칸에 텍스트로 세팅
                if (rawValue === '') {
                    this.value = '';
                } else {
                    //숫자를 toLocaleString로 1000단위 컴마찍어줌(자바스크립트가 알아서..!)
                    this.value = parseInt(rawValue).toLocaleString();
                }

                // 3. 현재 입력 중인 행(Row/즉 예산비목..) 찾기
                const row = this.closest('tr');

                // 내가 입력하는 행(예산 비목)의 기존 예산 잔액
                const balance = parseInt(row.querySelector('.bgtBalance').value || 0);
                // 방금 입력한 지출 금액 (계산을 위해 콤마가 제거된 rawValue 사용)
                const expense = parseInt(rawValue || 0);

                // 4. 지출 후 잔액 계산
                const afterBalance = balance - expense;
                const afterBalanceSpan = row.querySelector('.afterBalance');

                // 5. 상태에 따른 화면 UI 실시간 업데이트
                if (expense === 0 || rawValue === '') { //금액없을때
                    afterBalanceSpan.textContent = '-';
                    afterBalanceSpan.className = 'afterBalance text-muted';
                    this.classList.remove('is-invalid');
                } else if (afterBalance < 0) { //잔액이 음수일때
                    afterBalanceSpan.textContent = '예산 초과';
                    afterBalanceSpan.className = 'afterBalance text-danger fw-bold';
                    this.classList.add('is-invalid');
                } else { //평범한 사용일때..
                    afterBalanceSpan.textContent = afterBalance.toLocaleString();
                    afterBalanceSpan.className = 'afterBalance text-primary fw-bold';
                    this.classList.remove('is-invalid');
                }

                // 6. 하나의 행 계산이 끝날 때마다 전체 총합 업데이트 실행
                updateTotalSum();
            });
        });


    });//DOM 끝



    // ==========================================
    // 💡 개발/테스트용 지출품의서 자동완성 함수
    // ==========================================
    function fillDummyData() {
        // 1. 문서 제목 자동 입력
        const titleInput = document.getElementById('docTitle');
        if(titleInput) {
            titleInput.value = "[지출품의] 2026년 상반기 개발1팀 워크샵 비용 지출";
        }

        // 2. 동적으로 생성된 예산 행(Row) 찾아서 값 넣기
        const budgetRows = document.querySelectorAll('.budget-row');

        if (budgetRows.length > 0) {
            // 첫 번째 행에 데이터 넣기 (회식비 명목)
            const firstRowAmt = budgetRows[0].querySelector('.bgtChgAmt');
            const firstRowRsn = budgetRows[0].querySelector('.bgtChgRsn');

            if (firstRowAmt && firstRowRsn) {
                firstRowAmt.value = "150000"; // 15만원
                firstRowRsn.value = "프로젝트 목표 달성 워크샵 운영";

                // 🌟 핵심: JS로 값을 바꾼 후 'input' 이벤트를 강제로 발생시켜야 잔액/총합계가 자동 계산됨!
                firstRowAmt.dispatchEvent(new Event('input'));
            }

            // 만약 두 번째 행도 있다면 데이터 넣기 (비품 명목)
            if (budgetRows.length > 1) {
                const secondRowAmt = budgetRows[1].querySelector('.bgtChgAmt');
                const secondRowRsn = budgetRows[1].querySelector('.bgtChgRsn');

                if (secondRowAmt && secondRowRsn) {
                    secondRowAmt.value = "50000"; // 5만원
                    secondRowRsn.value = "프로젝트 목표 달성 워크샵 식비";

                    // 두 번째 행도 계산 트리거!
                    secondRowAmt.dispatchEvent(new Event('input'));
                }
            }
        }

        // 3. 업무 태그도 센스있게 자동 선택 (예산 관련이므로 C03 선택)
        /*
        const workTagSelect = document.getElementById('workTagSelect');
        if(workTagSelect) {
            workTagSelect.value = "C03";
        }

         */
    }



</script>