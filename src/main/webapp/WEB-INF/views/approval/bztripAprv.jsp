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

<script src="/js/common-alert.js"></script>

<!-- 튜토리얼 -->
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
        height: 40px; /* 로고 이미지 크기 조절 */
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
        height: 25px; /* 직급 행 높이 */
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

    /* 💡 버튼 공통 애니메이션 및 둥글기 (모든 버튼이 이 규칙을 따릅니다) */
    .btn-custom {
        transition: all 0.2s ease-in-out;
        border-radius: 6px;
    }
    /* 마우스 올렸을 때 살짝 떠오르는 쫀득한 효과! */
    .btn-custom:hover {
        transform: translateY(-2px);
    }

    /* 1. 취소 버튼 (위험/되돌리기 느낌의 은은한 빨간색) */
    .btn-cancel {
        background-color: #fff;
        color: #ff3e1d; /* 세련된 톤다운 레드 */
        border: 1px solid #ff3e1d;
        box-shadow: 0 2px 4px rgba(255, 62, 29, 0.15);
    }
    .btn-cancel:hover {
        background-color: #fff2f0; /* 아주 연한 빨간 배경 */
        color: #ff3e1d;
        box-shadow: 0 4px 8px rgba(255, 62, 29, 0.3);
    }


    /* 3. 결재선 지정 버튼 (메인 컬러 기반의 아웃라인) */
    .btn-aprv-line {
        background-color: #fff;
        color: #696cff;
        border: 1px solid #696cff;
        box-shadow: 0 2px 4px rgba(105, 108, 255, 0.15);
    }
    .btn-aprv-line:hover {
        background-color: #f8f9ff; /* 아주 연한 보라색 배경 */
        color: #696cff;
        box-shadow: 0 4px 8px rgba(105, 108, 255, 0.3);
    }

    /* 4. 상신 버튼 (가장 중요한 액션! 꽉 찬 메인 컬러) */
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


    /*결재선 모달*/
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




<!-- Page Content -->
<div class="row g-4 mb-4">
    <div class="d-flex justify-content-between align-items-center mb-4 bg-white p-3 rounded shadow-sm">

        <!-- 왼쪽 영역 -->
        <div class="d-flex gap-2">
            <button class="btn btn-custom btn-cancel d-flex align-items-center fw-bold px-3" onclick="location.href='/approval/myAprvBoard'">
                <span class="material-icons me-1">close</span> 취소
            </button>
        </div>

        <!-- 오른쪽 영역 -->
        <div class="d-flex gap-2">
            <button onclick="startBztripTutorial()" style="display: flex; align-items: center; gap: 5px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 10px 15px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.2s;" onmouseover="this.style.backgroundColor='#f8f9fa'" onmouseout="this.style.backgroundColor='#fff'">
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
                        <div class="doc-info mt-auto">
                        </div>

                        <div class="approval-section">
                            <table class="approval-table">
                                <tr>
                                    <td rowspan="2" class="aprv-side-title">결<br>재</td>
                                    <td id="posNm1" class="bg-light">${empJbgd}</td><!-- 본인 직급 넣기-->
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

                    <div class="doc-title">
                        출 장 신 청 서
                    </div>
                    <hr class="section-divider">

                    <div class="mb-4 p-2 bg-light rounded border border-dashed text-center">
                        <select class="form-select form-select-sm border-primary-subtle d-inline-block w-75" id="prevRequestSelect" onchange="autoFillForm()">
                            <option value="">-- 출장 신청 내역 불러오기 (선택 시 자동 완성) --</option>
                            <c:forEach var="tripDocumentVO" items="${tripDocumentVOList}">

                                <fmt:formatDate value="${tripDocumentVO.bztrpStart}" pattern="yyyy-MM-dd (E)" var="fmtBgng" />
                                <fmt:formatDate value="${tripDocumentVO.bztrpEnd}" pattern="yyyy-MM-dd (E)" var="fmtEnd" />

                                <option value="${tripDocumentVO.attTypeId}"
                                        data-bgng="${fmtBgng}"
                                        data-end="${fmtEnd}"
                                        data-res="${tripDocumentVO.bztrpRsn}"
                                        data-type="${tripDocumentVO.bztrpPlc}"
                                    ${param.attTypeId == tripDocumentVO.attTypeId ? 'selected' : ''}>
                                    [${tripDocumentVO.bztrpPlc}] ${fmtBgng} ~ ${fmtEnd}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div id="docBody">
                        <p class="mb-2 fw-bold">다음과 같이 출장을 신청하오니 재가하여 주시기 바랍니다.</p>
                        <input type="hidden" id="selectedAttTypeId" name="attTypeId" value="">
                        <table class="main-content-table">
                            <tr>
                                <th class="bg-label" style="width: 15%;">소속부서</th>
                                <td id="deptNm" style="width: 18%; text-align: center;" class="align-middle">${deptNm}</td>
                                <th class="bg-label" style="width: 15%;">직급</th>
                                <td id="posNm" style="width: 18%; text-align: center;" class="align-middle">${empJbgd}</td>
                                <th class="bg-label" style="width: 15%;">성명</th>
                                <td id="writerNm" style="width: 19%; text-align: center;" class="align-middle">${empNm}</td>
                            </tr>

                            <tr>
                                <th class="bg-label py-2">출장지</th>
                                <td colspan="5" class="p-0">
                                    <input type="text" id="bztrpPlc" class="form-control border-0 text-center w-100 h-100 align-middle" placeholder="출장 신청 내역을 선택하면 자동으로 입력됩니다." readonly style="background-color: #fff;">
                                </td>
                            </tr>

                            <tr>
                                <th class="bg-label py-2">시작일자</th>
                                <td colspan="2" class="p-0">
                                    <div id="startDate" class="form-control border-0 text-center w-100 h-100 d-flex flex-column justify-content-center" style="background-color: #fff; line-height: 1.4; min-height: 55px;">
                                        <span class="text-muted small">YYYY-MM-DD</span>
                                    </div>
                                </td>

                                <th class="bg-label py-2">종료일자</th>
                                <td colspan="2" class="p-0">
                                    <div id="endDate" class="form-control border-0 text-center w-100 h-100 d-flex flex-column justify-content-center" style="background-color: #fff; line-height: 1.4; min-height: 55px;">
                                        <span class="text-muted small">YYYY-MM-DD</span>
                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <th class="bg-label py-4">신청 사유</th>
                                <td colspan="5" class="p-0 align-top">
                                    <textarea id="reason" class="form-control border-0 text-start w-100" placeholder="출장 사유는 목록 선택 시 자동 입력 됩니다." readonly style="resize: none; background-color: #fff; padding: 15px; white-space: pre-wrap; height: 160px; line-height: 1.6;"></textarea>
                                </td>
                            </tr>
                        </table>
                        <div class="mt-4 fw-bold text-start ps-2">끝.</div>
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

            <!-- 문서 정보 -->
            <div class="card shadow-sm border-top border-primary border-3">
                <div class="card-header bg-light d-flex justify-content-between align-items-center">
                    <h6 class="card-title mb-0 fw-bold">문서 정보</h6>
                </div>
                <div class="card-body">

                    <!-- 업무 태그 추가 -->
                    <div class="mb-3">
                        <label class="form-label small fw-bold">업무 태그</label>
                        <select class="form-select form-select-sm" id="workTagSelect" name="workTag">
                            <option value="" selected disabled>-- 업무 태그를 선택해 주세요 --</option>

                            <!--  1. 공통 업무 그룹 -->
                            <optgroup label="[공통 / 일반 업무]">
                                <option value="C01">일반 행정/서무</option>
                                <option value="C02">근태</option>
                                <option value="C03">예산</option>
                            </optgroup>

                            <!-- 2. 진행 중인 프로젝트 -->
                            <optgroup label="[현재 진행 중인 프로젝트]">
                                <c:forEach var="project" items="${ingProjectList}">
                                    <option value="${project.projNo}">${project.projTtl}</option>
                                </c:forEach>
                                <c:if test="${empty ingProjectList}">
                                    <option value="" disabled>진행 중인 프로젝트가 없습니다.</option>
                                </c:if>
                            </optgroup>

                            <!-- 3. 최근 종료된 프로젝트 (정산/보고용) -->
                            <!-- 만약 종료된 프로젝트가 아예 없다면 이 그룹 자체를 안보여줌 -->
                            <c:if test="${not empty doneProjectList}">
                                <optgroup label="[최근 종료된 프로젝트 (정산/보고용)]">
                                    <c:forEach var="donePrj" items="${doneProjectList}">
                                        <option value="${donePrj.projNo}">${donePrj.projTtl}</option>
                                    </c:forEach>
                                </optgroup>
                            </c:if>

                        </select>
                    </div>
                    <!-- 새로 추가된 업무 태그 (Work Tag) 영역 끝 -->



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
                                <input
                                        type="file"
                                        class="form-control"
                                        id="multipartFiles"
                                        name="multipartFiles"
                                        multiple
                                />
                            </div>
                        </div>

                        <div class="mt-3" style="border:1px solid #ddd; padding:10px; min-height:100px;">
                            <p>선택된 파일 목록:</p>
                            <ul id="file_list_area" style="display: flex; flex-wrap: wrap; list-style: none; padding: 0;">
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!--문서 정보 끝-->
        </div>
    </div>
</div>



<!--결재선 모달-->
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
    //셀렉트 박스 값 넣기
    function autoFillForm() {
        const select = document.getElementById('prevRequestSelect');
        const selectedOption = select.options[select.selectedIndex];

        // 선택안되면 전부 초기화
        if (!selectedOption.value) {
            document.getElementById('selectedAttTypeId').value = "";
            document.getElementById('bztrpPlc').value = ""; // 출장지 초기화
            document.getElementById('reason').value = "";
            // div 태그이므로 innerHTML로 텍스트를 초기화....
            document.getElementById('startDate').innerHTML = "<span class='text-muted small'>YYYY-MM-DD<br>HH:mm</span>";
            document.getElementById('endDate').innerHTML = "<span class='text-muted small'>YYYY-MM-DD<br>HH:mm</span>";
            return;
        }

        const attTypeId = selectedOption.value;
        const bgng = selectedOption.dataset.bgng;  // "YYYY-MM-DD HH:mm" 형태
        const end = selectedOption.dataset.end;
        const res = selectedOption.dataset.res;
        const bztrpPlc = selectedOption.dataset.type; // 출장지로 사용할 데이터 (vctType 대신)

        // 값 세팅
        document.getElementById('selectedAttTypeId').value = attTypeId;
        document.getElementById('bztrpPlc').value = bztrpPlc;
        document.getElementById('reason').value = res;

        // 날짜, 시간 줄바꿈 처리
        const bgngHtml = bgng
        const endHtml = end

        // 화면에 날짜 출력
        document.getElementById('startDate').innerHTML = bgngHtml;
        document.getElementById('endDate').innerHTML = endHtml;

        console.log("선택된 출장 신청 번호(attTypeId):", attTypeId);
    }
    //셀렉트 박스 끝

    //////////// 결재선 설정 ////////////
    // !!파라미터에 empId 추가함!!
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

    // 행 삭제 기능
    function deleteRow(btn) {
        const row = btn.parentNode.parentNode;
        row.parentNode.removeChild(row);
        reorderSteps();
    }

    // 순서 변경 기능
    function moveRow(btn, direction) {
        const row = btn.closest('tr');
        if (direction === 'up') {
            const prev = row.previousElementSibling;
            if (prev && !prev.classList.contains('table-secondary')) { // 기안자 행 위로는 못 올라감
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

    // 순서 번호 재정렬
    function reorderSteps() {
        const table = document.getElementById('approvalTable').getElementsByTagName('tbody')[0];
        for (let i = 0; i < table.rows.length; i++) {
            table.rows[i].cells[0].innerText = i + 1;
        }
    }
    //////////// 결재선 설정 끝////////////

    //첨부파일///////////////////////////
    // 첨부파일 영역 수정 버전
    document.querySelector('#multipartFiles').addEventListener('change', function(e) {
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

            // 확장자 판별 로직 [cite: 86, 87, 88]
            if (fileExt === 'pdf') { iconClass = "fa-file-pdf"; iconColor = "#e74c3c"; }
            else if (['png', 'jpg', 'jpeg'].includes(fileExt)) { iconClass = "fa-file-image"; iconColor = "#27ae60"; }
            else if (['hwp', 'hwpx'].includes(fileExt)) { iconClass = "fa-file-word"; iconColor = "#2980b9"; }
            else if (fileExt === 'zip') { iconClass = "fa-file-archive"; iconColor = "#f39c12"; }

            // HTML 생성 (mb-2를 style 밖으로 뺐습니다)
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
    /////////////////////////////////////////////////////////////

    ///////////////////// 조직도 모달이 열릴 때 js tree /////////////////////
    document.getElementById('approverModal').addEventListener('shown.bs.modal', function () {
        initApproverJsTree();
    });

    // jsTree 초기화 및 데이터 로드
    function initApproverJsTree() {
        // 이미 트리가 생성되어 있다면 다시 그리지 않음
        if($('#jstree_div').jstree(true)) return;
        // 직급 순서 정의
        const rankPriority = { '대표': 1, '팀장': 2, '대리': 3, '주임': 4, '사원': 5 };

        axios.get("/indivList").then(res => {
            let treeData = [];

            res.data.forEach(dept =>{
                // 부서
                treeData.push({
                    id: "D" + dept.deptCd,
                    parent: "#",
                    text: dept.deptNm,
                    type: "dept"
                });

                if (dept.teamLeaders) {
                    // 팀장
                    dept.teamLeaders.forEach(leader => {
                        treeData.push({
                            id: leader.empId,
                            parent: "D" + dept.deptCd,
                            text: `\${leader.empNm} (\${leader.empJbgd})`,
                            type: "leader",
                            data: {
                                name: leader.empNm,
                                rank: leader.empJbgd,
                                dept: dept.deptNm
                            }
                        });

                        // 팀원 정렬
                        if (leader.teamEmployee && leader.teamEmployee.length > 0) {
                            let sortedMembers = [...leader.teamEmployee].sort((a, b) => {
                                const priorityA = rankPriority[a.empJbgd] || 99;
                                const priorityB = rankPriority[b.empJbgd] || 99;

                                if (priorityA !== priorityB) return priorityA - priorityB;
                                return a.empNm.localeCompare(b.empNm); // 직급 같으면 이름순
                            });

                            sortedMembers.forEach(member => {
                                treeData.push({
                                    id: member.empId,
                                    parent: "D" + dept.deptCd,
                                    text: `\${member.empNm} (\${member.empJbgd})`,
                                    type: "default",
                                    data: {
                                        name: member.empNm,
                                        rank: member.empJbgd,
                                        dept: dept.deptNm
                                    }
                                });
                            });
                        }
                    });
                }
            });

            // jsTree 설정 및 렌더링
            $('#jstree_div').jstree({
                core: { data: treeData, check_callback: true },
                types: {
                    "default": { "icon": "fas fa-user text-secondary" },
                    "dept": { "icon": "fas fa-building text-primary" },
                    "leader": { "icon": "fas fa-user-tie text-warning" }
                },
                plugins: ['types', 'search'] // 검색 기능 활성화
            })
                .bind("ready.jstree", () => $('#jstree_div').jstree("open_all")) // 처음엔 모두 열어두기
                .bind("select_node.jstree", function(e, data) {
                    // 트리의 노드를 클릭했을 때 실행되는 이벤트
                    const nodeData = data.node.data;

                    // nodeData가 있다는 건 부서가 아니라 '사람'을 클릭했다는 뜻
                    if (nodeData) {
                        // !!addApprover의 첫 번째 파라미터로 사번(data.node.id)을 추가!!
                        addApprover(data.node.id, nodeData.name, nodeData.rank, nodeData.dept);
                        $('#jstree_div').jstree("deselect_node", data.node);
                    }
                });
        }).catch(err => {
            console.error("조직도 데이터 로딩 실패:", err);
        });
    }

    // 조직도 검색 기능 연동
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
    // 나중에 '상신(저장)' 버튼 누를 때 DB로 보낼 결재선 배열 (전역 변수)
    let selectedApprovalLine = [];
    document.getElementById('applyApprovalLineBtn').addEventListener('click', function() {
        const table = document.getElementById('approvalTable').getElementsByTagName('tbody')[0];
        const rows = table.rows;

        //배열 초기화
        selectedApprovalLine = [];

        //모달 테이블에서 결재선 데이터 가져오기
        for(let i = 0; i < rows.length; i++) {
            // 이름 직급 분리..(괄호 기준)
            const cellText = rows[i].cells[2].innerText;
            const name = cellText.split('(')[0].trim();
            const rank = cellText.split('(')[1].replace(')', '').trim();
            const dept = rows[i].cells[3].innerText.trim();
            const empId = rows[i].getAttribute('data-emp-id');

            // DB넣기 용 객체화
            selectedApprovalLine.push({
                aprvLnLvl: i,
                empId: empId, //js tree에서 받아올 값
                name: name,
                rank: rank,
                dept: dept
            });
        }

        // 문서 본문 결재 박스에 반영 (2번 칸부터 5번 칸까지)
        // 기존 결재선 초기화
        for(let i = 2; i <= 5; i++) {
            document.getElementById('posNm' + i).innerText = '-';
            document.getElementById('aprvLine' + i).innerText = ''; // 이름란은 비워둠(결재시 이름 넣기)
        }

        // 기안자 제외 결재선 넣기
        for(let i = 1; i < selectedApprovalLine.length; i++) {
            // 2번 칸(posNm2)에는 배열의 1번 인덱스 값으로
            document.getElementById('posNm' + (i + 1)).innerText = selectedApprovalLine[i].rank;
            document.getElementById('aprvLine' + (i + 1)).innerText = ''; // 아직 결재 안 했으니 빈칸!
        }

        // 오른쪽 결재선 박스 업뎃
        const infoList = document.getElementById('approvalLineInfoList');
        infoList.innerHTML = ''; // 기존 목록 비우고 적용

        // 오늘 날짜 구하기 (기안자용)
        const today = new Date().toISOString().split('T')[0];
        selectedApprovalLine.forEach((appr, index) => {
            const isWriter = (index === 0); // 기안 작성자인가용?
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

        // 모달 닫기
        const modalEl = document.getElementById('approverModal');
        const modalInstance = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
        modalInstance.hide();

        // 💡 리팩토링: 결재선 적용 완료 (자동 닫힘 모달)
        AppAlert.autoClose('결재선 적용 완료', '결재선이 문서에 성공적으로 적용되었습니다.');
    });
    ///////////////////// 결재선 반영하기 끝/////////////////////


    ///////////////////////// 상신하기!!!! /////////////////////////
    // 상신 버튼 이벤트
    document.getElementById('submitAprvBtn').addEventListener('click', function() {
        //필수 값 체크
        const attTypeId = document.getElementById('selectedAttTypeId').value;
        const docTitle = document.getElementById('docTitle').value;
        // 업무 태그 값 가져오기
        const aprvWorkTag = document.getElementById('workTagSelect').value;

        //필수값 입력확인 시작
        // 💡 리팩토링: 입력/선택 누락 시 포커스와 함께 경고창 띄우기
        if(!aprvWorkTag) {
            AppAlert.warning('선택 확인', '업무 태그를 선택해 주세요.', 'workTagSelect', 'local_offer');
            return;
        }
        if(!attTypeId) {
            AppAlert.warning('입력 확인', '출장 신청 내역을 먼저 선택해 주세요.', 'prevRequestSelect', 'content_paste');
            return;
        }
        if(!docTitle) {
            AppAlert.warning('입력 확인', '문서 제목을 입력해 주세요.', 'docTitle', 'edit_note');
            return;
        }

        // 문서 제목 길이 유효성 검사 (50자 제한)
        if(docTitle.length > 50) {
            AppAlert.warning('제목 길이 초과', '문서 제목은 최대 50자까지만 입력할 수 있습니다.', 'docTitle', 'text_fields');
            return;
        }


        if(selectedApprovalLine.length <= 1) {
            AppAlert.warning('설정 확인', '결재선을 설정해 주세요.', null, 'groups');
            return;
        }

        // 💡 리팩토링: 상신 컨펌창 (확인/취소)
        AppAlert.confirm('상신하시겠습니까?', '상신 후에는 내용 수정이 불가능할 수 있습니다.', '상신하기', '취소', 'send', 'primary')
            .then((result) => {
                if (result.isConfirmed) {
                    const isUrgent = document.getElementById('urgentCheck').checked ? 'Y' : 'N';
                    const isOpen = document.getElementById('openY').checked ? 'Y' : 'N';
                    const realApprovers = selectedApprovalLine.slice(1);

                    const formData = new FormData();
                    formData.append("aprvDocNo", attTypeId);
                    formData.append("attTypeId", attTypeId);
                    formData.append("aprvTtl", docTitle);
                    formData.append("aprvEmrgYn", isUrgent);
                    formData.append("aprvRlsYn", isOpen);
                    formData.append("aprvSe", "APRV01003");
                    formData.append("aprvWorkTag", aprvWorkTag); // 업무 태그 추가

                    realApprovers.forEach((approver, index) => {
                        formData.append(`aprvLineVOList[\${index}].aprvLnLvl`, approver.aprvLnLvl);
                        formData.append(`aprvLineVOList[\${index}].empId`, approver.empId);
                        formData.append(`aprvLineVOList[\${index}].name`, approver.name);
                        formData.append(`aprvLineVOList[\${index}].rank`, approver.rank);
                        formData.append(`aprvLineVOList[\${index}].dept`, approver.dept);
                    });

                    const fileInput = document.getElementById('multipartFiles');
                    const files = fileInput.files;
                    for (let i = 0; i < files.length; i++) {
                        formData.append("multipartFiles", files[i]);
                    }

                    axios.post("/approval/submit", formData, {
                        headers: { "Content-Type": "multipart/form-data" }
                    })
                        .then(response => {
                            if(response.data === "SUCCESS") {
                                // 💡 리팩토링: 상신 성공 시 자동 닫힘 모달 후 페이지 이동
                                AppAlert.autoClose('상신 완료!', '출장 신청이 성공적으로 상신되었습니다.')
                                    .then(() => {
                                        window.location.href = "/approval/myAprvBoard";
                                    });
                            } else {
                                // 💡 리팩토링: 서버 에러 모달
                                AppAlert.error('상신 실패', '서버에서 오류를 반환했습니다. 관리자에게 문의하세요.');
                            }
                        })
                        .catch(error => {
                            console.error("상신 에러:", error);
                            // 💡 리팩토링: 통신 에러 모달
                            AppAlert.error('오류 발생', '상신 처리 중 네트워크 또는 서버 오류가 발생했습니다.');
                        });
                }
            }); // end AppAlert.then
    });
    //DOM///
    document.addEventListener("DOMContentLoaded", function() {
        const selectBox = document.getElementById('prevRequestSelect');
        // 근태에서 바로와서 파라미터 값이 있다면..
        if (selectBox.value) {
            autoFillForm(); //표 채우기
        }
    })

    // ==========================================
    // 💡 Driver.js 출장 신청 페이지 튜토리얼
    // ==========================================
    function startBztripTutorial() {
        const driver = window.driver.js.driver;

        const driverObj = driver({
            showProgress: true,
            animate: true,
            allowClose: true,
            doneBtnText: '완료',
            closeBtnText: '건너뛰기',
            nextBtnText: '다음 ❯',
            prevBtnText: '❮ 이전',

            steps: [
                {
                    element: '#prevRequestSelect', // 출장 내역 불러오기 셀렉트 박스
                    popover: {
                        title: '출장 내역 불러오기',
                        description: '가장 먼저 이곳을 클릭하여 <span style="color: #696cff; font-weight: bold;">근태에서 신청한<br /> 출장 내역</span>을 선택해 주세요.<br><br>선택하면 아래 문서 내용이 자동으로 입력<br />됩니다.' +
                            '<div style="background-color: #fff2f0; padding: 10px; border-radius: 6px; margin-top: 12px; font-size: 0.85rem; color: #ff3e1d; border: 1px solid rgba(255, 62, 29, 0.2); line-height: 1.4;"><b>주의사항</b><br>새로운 출장은 [근태] 메뉴에서 먼저 신청 후 불러올 수 있습니다. (직접 작성 불가)</div>',
                        side: "bottom", align: 'center'
                    }
                },
                {
                    element: '.btn-aprv-line', // 결재선 지정 버튼
                    popover: {
                        title: '결재선 지정',
                        description: '문서가 작성되면 이 버튼을 눌러 <span style="color: #696cff; font-weight: bold;">결재할 사람(결재선)</span>을 지정해야 합니다.<br><br>조직도에서 클릭하여 추가할 수 있습니다.',
                        side: "bottom", align: 'end'
                    }
                },
                {
                    element: '#docTitle', // 문서 제목 입력칸
                    popover: {
                        title: '문서 제목 및 설정',
                        description: '우측 패널에서 <span style="color: #696cff; font-weight: bold;">문서의 제목</span>을 입력하고, 긴급 여부나 공개 여부, 첨부파일을 설정할 수 있습니다.',
                        side: "left", align: 'start'
                    }
                },
                {
                    element: '#submitAprvBtn', // 상신 버튼
                    popover: {
                        title: '결재 상신',
                        description: '모든 내용과 결재선이 확인되었다면, 마지막으로 <span style="color: #28a745; font-weight: bold;">상신 버튼</span>을 눌러 결재를 올립니다.',
                        side: "bottom", align: 'end'
                    }
                },
                {
                    element: '#menuWrapper',
                    popover: {
                        title: 'AI 검토 (말 다듬)',
                        description: '상신 전 문서에 혹시 오류나 오타가 없는지 <span style="color: #0dcaf0; font-weight: bold;">AI(말 다듬)에게 검토</span>를 맡길 수도 있습니다!',
                        side: "top", align: 'end'
                    }
                }
            ]
        });

        driverObj.drive();
    }
</script>

