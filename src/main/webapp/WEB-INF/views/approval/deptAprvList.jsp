<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.Date"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

    /* 레이아웃 충돌 방지
       main.jsp 내부 컨텐츠로 삽입되므로 body의 flex 설정을 해제하고
       배경색을 명시적으로 다시 잡아줍니다. */
    body {
        background-color: var(--bs-body-bg) !important;
        display: block !important;
        font-family: "Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
    }

    /* 여백 제거 핵심
       main-content 영역이 중복 마진을 가지지 않도록 0으로 초기화합니다. */
    .main-content {
        width: 100% !important;
        margin-left: 0 !important;
        display: block !important;
        background-color: transparent !important;
    }

    .page-wrapper {
        padding: 1.5rem;
        width: 100%;
        box-sizing: border-box;
    }

    /* --- 여기서부터는 기존 스타일 유지 --- */
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

    /* 검색 영역 커스텀 (필요 시) */
    .search-area .form-select,
    .search-area .form-control {
        border-color: #e4e6e8;
    }
    .search-area .form-select:focus,
    .search-area .form-control:focus {
        border-color: #696cff;
        box-shadow: 0 0 0 0.25rem rgba(105, 108, 255, 0.1);
    }



    /* ///// 🤍 부서 문서함 전용 화이트톤 결재 정보 스타일 ///// */

    /* 🚨 Bootstrap Offcanvas 헤더 가림 방지 */
    :root {
        --header-actual-height: 70px; /* 실제 헤더 높이에 맞춰 조정 */
    }

    .custom-offcanvas {
        top: var(--header-actual-height) !important;
        height: calc(100vh - var(--header-actual-height)) !important;
        border-top-left-radius: 12px;
        transition: transform 0.4s cubic-bezier(0.19, 1, 0.22, 1) !important;
    }

    /* 타임라인 전용 스타일 */
    .timeline-container {
        position: relative;
        padding-left: 3.5rem;
        margin-top: 1.5rem;
    }

    /* 타임라인 세로 연결선 */
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
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    }

    .timeline-icon img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    /* 🟣 기안자 및 결재 완료 (완료 문서함이므로 모두 보라색) */
    .timeline-icon.approved {
        border: 2px solid #696cff;
    }

    /* 의견 말풍선 박스 */
    .comment-box {
        background-color: #ffffff;
        border-radius: 12px;
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

    /* 🏷️ 상태 뱃지 및 업무 태그 뱃지 */
    .status-badge-clean {
        padding: 4px 12px;
        font-size: 0.75rem;
        border-radius: 20px;
        font-weight: 800;
        display: inline-block;
        letter-spacing: -0.3px;
    }

    .bg-clean-primary { background: #EBF2FF; color: #696cff; } /* 승인 */

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


    /* --- 리스트/테이블 스타일 --- */

    /* 1. 표 바탕 및 모든 셀을 완벽한 흰색으로 강제 코팅 (투명도 방어) */
    #aprvTb,
    #aprvTb tbody tr,
    #aprvTb tbody td {
        background-color: #ffffff !important;
        border-bottom: 1px solid #f0f2f5 !important;
        transition: background-color 0.15s ease-in-out;
        cursor: pointer;
    }

    /* 2. 마우스 호버 시 은은하고 고급스러운 회색으로 변경! */
    #aprvTb tbody tr:hover td {
        background-color: #f4f5f7 !important;
    }

    /* 3. 표 흔들림 방지 절대 고정 CSS */
    #aprvTb {
        table-layout: fixed !important;
        width: 100%;
    }

    /* 각 열별 고유 클래스로 너비 강제 고정 */
    .th-aprv-no     { width: 15% !important; }
    .th-aprv-title  { width: auto !important; } /* 남는 공간은 제목이 흡수 */
    .th-aprv-attach { width: 50px !important; } /* 첨부파일 클립은 50px 고정 */
    .th-aprv-writer { width: 15% !important; }
    .th-aprv-date   { width: 15% !important; }
    .th-aprv-history{ width: 12% !important; }

    /* 글자가 길어져서 표를 밀어내는 현상 방지 */
    #aprvTb td {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* 페이징 블럭 디자인 통일 */
    #tdPagingArea {
        text-align: center;
        padding: 0.5rem 0 !important; /* 내부 패딩도 축소 */
        background-color: #ffffff !important;
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
        background-color: #e2e6ea;
    }
    #tdPagingArea .pagination .page-item.active .page-link {
        background-color: #696cff;
        color: #fff;
    }

    /* 리스트 제목 강조 스타일 */
    .board-main-title {
        font-size: 1.3rem !important;
        font-weight: 600 !important;
        color: #2c3e50 !important;
        letter-spacing: -0.5px !important;
    }

    .card-footer.bg-white.py-4 {
        padding-top: 0.5rem !important;  /* 기존 py-4(1.5rem)에서 대폭 축소 */
        padding-bottom: 0.5rem !important;
    }

    /* 🚨 쫀득한 밀어내기 애니메이션 (본문 영역) */
    .aprv-main-container {
        /* 동료 코드의 베지에 곡선을 그대로 살려서 쫀득하게! */
        transition: padding-right 0.4s cubic-bezier(0.19, 1, 0.22, 1);
        width: 100%;
    }

    /* 오프캔버스가 열렸을 때 추가될 클래스 */
    .aprv-main-container.shrunk {
        padding-right: 450px; /* 오프캔버스 너비만큼 여백 주기 */
    }








</style>


<div id="mainSection" class="aprv-main-container">


<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
            <span class="material-icons" style="color: #696cff; font-size: 32px;">description</span>

            <div style="display: flex; align-items: baseline; gap: 8px;">
                <span style="font-size: x-large; font-weight: 800;">전자결재</span>
                <span style="font-weight: normal; color: #717171; font-size: 15px;">| 부서 문서함</span>
            </div>
        </div>

        <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
            본인이 소속한 부서의 전자결재 문서를 확인할 수 있습니다.
        </div>
    </div>

</div>

<div class="row g-4 mb-4">
    <div class="col-12">
        <div class="card shadow-sm border-0">
            <div class="card-header bg-white d-flex justify-content-between align-items-center border-bottom pb-3 pt-4">
                <h4 class="board-main-title mb-0" id="myList">부서 문서함</h4>

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
                    <tr>
                        <th class="ps-4 text-start th-aprv-no">문서번호</th>
                        <th class="text-start th-aprv-title">제목</th>
                        <th class="text-center th-aprv-attach"></th>
                        <th class="text-start th-aprv-writer">문서작성자</th>
                        <th class="text-start th-aprv-date">결재완료일</th>
                        <th class="text-center th-aprv-history">문서 정보</th>
                    </tr>
                    </thead>
                    <tbody id="aprvTbody">
                    </tbody>
                </table>
            </div>

            <div class="card-footer bg-white border-0 py-4">
                <div id="tdPagingArea" class="d-flex justify-content-center w-100">
                </div>
            </div>

        </div>
    </div>
</div>



<!-- 결재 정보란 시작 -->
    <div class="offcanvas offcanvas-end custom-offcanvas" data-bs-scroll="true" data-bs-backdrop="false" tabindex="-1" id="approvalTimelineOffcanvas"
         aria-labelledby="approvalTimelineLabel" style="width: 450px; border-left: none; box-shadow: -5px 0 15px rgba(0,0,0,0.05);">
    <!-- bg-light를 bg-white로 변경 & X버튼 헤더로 이동! -->
    <div class="offcanvas-header border-bottom bg-white d-flex justify-content-between align-items-center">
        <h5 class="offcanvas-title fw-bold d-flex align-items-center mb-0" id="approvalTimelineLabel">
            문서 요약 정보
        </h5>
        <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>

    <div class="offcanvas-body">
        <div class="mb-4 pb-3 border-bottom">
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


</div>



<script type="text/javascript">


    // 비동기로 리스트 가져오기
    // [페이징 블록 핸들러 함수]
    function listFn(url, currentPage, mode, keyword){
        let data = {
            "currentPage":currentPage,
            "mode":mode,
            "keyword":keyword,
            "url":url
        };

        console.log("listFn->data : ", data);

        axios.post("/approval/deptAprvListAxios", data, {
            headers :{
                "Content-Type" : "application/json;charset=utf-8"
            }
        })
            .then(response=>{
                console.log("result : ", response.data);
                listShowFn(response.data);
            })
            .catch(err=>{
                console.error("err : ", err);
                // (알람 리팩토링) 통신 에러 발생 시 알림 추가
                AppAlert.error('목록 조회 실패', '데이터를 불러오는 중 문제가 발생했습니다.');
            });
    } // (알람 리팩토링)


    // 전역함수: 목록 출력 및 페이징 처리
    function listShowFn(articlePage){
        let str = `
        <thead class="table-light">
            <tr>
                <th class="ps-4 text-start th-aprv-no">문서번호</th>
                <th class="text-start th-aprv-title">제목</th>
                <th class="text-center th-aprv-attach"></th>
                <th class="text-start th-aprv-writer">문서작성자</th>
                <th class="text-start th-aprv-date">결재완료일</th>
                <th class="text-center th-aprv-history">문서 정보</th>
            </tr>
        </thead>
        <tbody id="aprvTbody">
        `;
        const approvalVOList = articlePage.content;

        // 데이터가 없을 때 처리
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
                   onclick="opendeptAprvDetail('\${approvalVO.aprvNo}')"
                   class="text-decoration-none fw-bold text-dark">
                     \${approvalVO.aprvTtl}
                   </a>
                </td>
                <td class="text-center">
                    \${approvalVO.aprvData ? '<span class="fas fa-paperclip text-muted"></span>' : ''}
                </td>
                <td class="text-start">\${approvalVO.docWriterNm}</td>
                <td class="text-start">\${approvalVO.aprvEndDt ? approvalVO.aprvEndDt.substring(0, 10) : ''}</td>

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

        // 페이징 블록 처리
        document.getElementById("tdPagingArea").innerHTML = articlePage.pagingArea || "";
    } // end listShowFn



    // 상세 창 열기 함수
    function opendeptAprvDetail(aprvNo) {
        const url = `/approval/openAprvDetail?aprvNo=\${aprvNo}`;
        const name = "ApprovalDetail";
        const specs = "width=900,height=1000,scrollbars=yes";
        window.open(url, name, specs);
    }


    /////////////////// DOM 시작 ///////////////////
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

        axios.post("/approval/deptAprvListAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                console.log("result : ", response.data);
                listShowFn(response.data);
            })
            .catch(err => {
                console.error("err : ", err);
                // (알람 리팩토링) 초기 데이터 로딩 실패 알림
                AppAlert.error('데이터 로딩 실패', '부서 문서를 가져오지 못했습니다.');
            });


        ///// 비동기 검색 실행 /////
        const btnSearch = document.getElementById("btnSearch");
        btnSearch.addEventListener("click", ()=>{

            //검색어 길이 유효성 검사 추가(혹시모를...)
            const keywordInput = document.querySelector("input[name='keyword']");
            const keywordVal = keywordInput.value || "";

            if (keywordVal.length > 30) {
                AppAlert.warning('검색어 길이 초과', '검색어는 최대 30자까지만 입력할 수 있습니다.', 'searchKeyword', 'text_fields');
                return;
            }


            const data ={
                "currentPage":1,
                "mode":document.querySelector("select[name='mode']").value||"",
                "keyword":document.querySelector("input[name='keyword']").value||"",
                "url":"/approval/deptAprvList"
            };

            axios.post("/approval/deptAprvListAxios", data, {
                headers : {
                    "Content-Type" : "application/json;charset=utf-8"
                }
            })
                .then(response =>{
                    console.log("result : ", response.data);
                    listShowFn(response.data);
                })
                .catch(err=>{
                    console.error("err : ", err);
                    // (알람 리팩토링) 검색 실패 시 알림
                    AppAlert.error('검색 실패', '검색 결과를 가져오는 중 오류가 발생했습니다.');
                });
        }); // end click

    }); // DOM


    ////////////////// 결재 정보 띄우는 함수 시작
    function openTimeline(aprvNo, aprvTtl, aprvDt) {
        document.getElementById('offcanvasDocNo').innerText = "문서번호: " + aprvNo;
        document.getElementById('offcanvasDocTitle').innerText = aprvTtl;
        document.getElementById('offcanvasDraftDate').innerText = "기안일: " + (aprvDt ? aprvDt.substring(0, 10) : '');

        const offcanvasElement = document.getElementById('approvalTimelineOffcanvas');
        const bsOffcanvas = new bootstrap.Offcanvas(offcanvasElement);
        bsOffcanvas.show();

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
                    let commentHtml = '';
                    const profileImg = line.empProfile ? `/displayPrf?fileName=\${line.empProfile}` : 'https://i.pravatar.cc/150?u=a042581f4e29026704d';

                    const statusBadge = `<span class="status-badge-clean bg-clean-primary ms-2">결재</span>`;
                    const statusClass = 'approved';

                    if (line.aprvLnCn) {
                        commentHtml = `<div class="comment-box approve"><span class="material-icons align-middle me-1" style="font-size: 14px; color: #696cff;">chat</span>\${line.aprvLnCn}</div>`;
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
                // (알람 리팩토링) 타임라인 로딩 실패 시 에러 표시
                AppAlert.error('정보 로드 실패', '결재 히스토리를 불러오는 중 오류가 발생했습니다.');
                timelineArea.innerHTML = `<div class="alert alert-danger">데이터를 불러오는 중 오류가 발생했습니다.</div>`;
            });
    }

    document.addEventListener('DOMContentLoaded', function() {
        const offcanvasElement = document.getElementById('approvalTimelineOffcanvas');
        const mainSection = document.getElementById('mainSection');

        if (offcanvasElement && mainSection) {
            offcanvasElement.addEventListener('show.bs.offcanvas', function () {
                mainSection.classList.add('shrunk');
            });

            offcanvasElement.addEventListener('hidden.bs.offcanvas', function () {
                mainSection.classList.remove('shrunk');
            });
        }
    });
</script>

