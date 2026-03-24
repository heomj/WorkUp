<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<script src="/js/common-alert.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
    :root {
        --point-color: #7579ff;
        --bg-light: #f4f7fe;
        --text-dark: #1b2559;
        --text-muted: #a3aed0;
        --st-ongoing: #696cff;
        --st-delayed: #ff3e1d;
        --st-completed: #71dd37;
        --star-color: #ffb800;
    }

    body { background-color: var(--bg-light);
    /*
         font-family: 'Pretendard', sans-serif; color: var(--text-dark);
     */
    }
    .shop-container { width: 100%; display: flex; flex-direction: column; }

    /* 📊 상단 요약 카드 */
    .status-summary-container { display: flex; gap: 20px; padding: 20px 0 30px 0; }
    .status-card {
        flex: 1; background: #fff; padding: 22px 25px; border-radius: 22px;
        display: flex; align-items: center; gap: 15px; box-shadow: 0 10px 20px rgba(0,0,0,0.02);
        border: 1px solid #f0f3ff;
    }
    .status-icon-circle { width: 48px; height: 48px; border-radius: 14px; display: flex; align-items: center; justify-content: center; }
    .st-info { display: flex; align-items: center; gap: 6px; }
    .st-label { font-size: 0.85rem; color: var(--text-muted); font-weight: 600; }
    .st-count { font-size: 1.3rem; font-weight: 800; color: var(--text-dark); letter-spacing: -0.5px; }

    /* 📁 카테고리 탭 & 검색바 영역 */
    .filter-wrapper { display: flex; justify-content: space-between; align-items: flex-end;  }
    .tab-container { display: flex; gap: 5px; align-items: flex-end; }
    .category-tab {
        border: none; background: #e0e5f2; color: #707eae; padding: 10px 25px;
        font-size: 0.95rem; font-weight: 700; border-radius: 12px 12px 0 0;
        transition: 0.3s; cursor: pointer; height: 40px;
    }
    .category-tab.active {
        background: #fff; color: var(--point-color); height: 48px;
        box-shadow: 0 -5px 10px rgba(0,0,0,0.02);
    }

    /* 🔍 프로젝트명 검색창 스타일 */
    .prj-search-box {
        background: #fff; border-radius: 15px; padding: 5px 15px;
        display: flex; align-items: center; border: 1.5px solid #f0f3ff;
        margin-bottom: 10px; width: 300px; transition: 0.3s;
    }
    .prj-search-box:focus-within { border-color: var(--point-color); box-shadow: 0 5px 15px rgba(117,121,255,0.1); }
    .prj-search-box input { border: none; outline: none; font-size: 0.9rem; padding: 8px; width: 100%; color: var(--text-dark); }
    .prj-search-box .material-icons { color: var(--text-muted); }

    /* 🗂️ 프로젝트 카드 레이아웃 */
    .shop-content-box { background: #ffffff; padding: 35px; border-radius: 0 25px 25px 25px; min-height: 400px; }

    /* 그리드 정렬 핵심 수정 */
    #projectGrid { display: flex; flex-wrap: wrap; }
    .project-item { display: flex; } /* 내부 카드가 높이 100%를 가질 수 있게 함 */

    .project-card {
        width: 100%;
        min-height: 300px;
        background: #fff;
        border-radius: 20px;
        border: 2px solid #f0f3ff;
        display: flex;
        flex-direction: column;
        transition: all 0.3s ease;
        position: relative;
    }

    .prj-ttl-text {
        display: block;
        width: 100%;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 1.2rem;
        font-weight: 700;
        margin-bottom: 8px;
    }

    .project-card:hover {transform: translateY(-5px); box-shadow: 0 12px 30px rgba(117,121,255,0.1); }
    .project-card.important { border: 2px solid #ffedb8; background: #fffdf7; }

    .card-top-header { display: flex; align-items: center; gap: 8px; margin-bottom: 15px; }
    .btn-star { cursor: pointer; border: none; background: none; padding: 0; display: flex; align-items: center; }
    .btn-star .material-icons { font-size: 24px; color: #e0e5f2; transition: 0.2s; }
    .btn-star.active .material-icons { color: var(--star-color); }
    .status-badge { padding: 5px 12px; font-size: 11px; font-weight: 700; border-radius: 20px; line-height: 1.2; }

    /* 상세 설명 2줄 제한 */
    .prj-dtl-text {
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        text-overflow: ellipsis;
        height: 40px;
        margin-bottom: 20px !important;
        line-height: 1.5;
    }

    .progress { height: 8px; background-color: #f0f3ff; border-radius: 10px; }
    .progress-bar { border-radius: 10px; background: var(--point-color); }

    /* 아바타 그룹 */
    .avatar-sm { width: 32px; height: 32px; border-radius: 50%; border: 2px solid #fff; margin-left: -10px; background: #e0e5f2; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: bold; }

    .avatar-group-wrapper { position: relative; cursor: pointer; display: flex; align-items: center; }
    .avatar-group-wrapper:hover::after {
        content: attr(data-names);
        position: absolute; bottom: 130%; right: 0;
        background: rgba(33, 37, 41, 0.95); color: #fff;
        padding: 10px 14px; border-radius: 10px; font-size: 0.8rem;
        width: max-content; max-width: 220px; white-space: normal;
        word-break: keep-all; z-index: 9999; box-shadow: 0 5px 15px rgba(0,0,0,0.2);
    }

    /* 🔍 팀원 검색 UI */
    .search-result-list {
        position: absolute; width: 100%; z-index: 1050; background: white;
        border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        max-height: 200px; overflow-y: auto; border: 1px solid #f0f3ff; display: none;
    }
    .search-item { padding: 10px 15px; cursor: pointer; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid #f8f9fa; }
    .member-tag {
        display: inline-flex; align-items: center; background: #f1f4ff; color: var(--point-color);
        padding: 4px 10px; margin: 2px; border-radius: 6px; font-size: 12px; font-weight: 600;
        border: 1px solid #ddecff; max-width: 150px; white-space: nowrap;
    }
</style>

<!-- 카운터 할 변수를 초기화! -->
<c:set var="doingCount" value="0" />
<c:set var="delayedCount" value="0" />
<c:set var="completedCount" value="0" />

<!-- 여기서 값 계산 -->
<c:forEach items="${projectList}" var="prj">
    <c:choose>
        <c:when test="${prj.projStts == '진행'}">
            <c:set var="doingCount" value="${doingCount + 1}" />
        </c:when>
        <c:when test="${prj.projStts == '지연'}">
            <c:set var="delayedCount" value="${delayedCount + 1}" />
        </c:when>
        <c:when test="${prj.projStts == '완료'}">
            <c:set var="completedCount" value="${completedCount + 1}" />
        </c:when>
    </c:choose>
</c:forEach>



<div class="shop-container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                <span class="material-icons" style="color: #696cff; font-size: 32px;">layers</span>

                <div style="display: flex; align-items: baseline; gap: 8px;">
                    <span style="font-size: x-large; font-weight: 800;">프로젝트</span>
                    <span style="font-weight: normal; color: #717171; font-size: 15px;">| 프로젝트 관리</span>
                </div>
            </div>

            <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                새 프로젝트를 생성하거나 기존 프로젝트의 진행 상태를 관리합니다.
            </div>
        </div>
        <button class="btn btn-primary shadow-sm" style="background: var(--point-color); border:none; border-radius:15px; padding: 12px 25px; font-weight:700;" data-bs-toggle="modal" data-bs-target="#createProjectModal">
            + 새 프로젝트 생성
        </button>
    </div>

        <div class="status-summary-container">
            <div class="status-card">
                <div class="status-icon-circle" style="background: #efefff; color: var(--st-ongoing);"><span class="material-icons">sync</span></div>
                <div class="st-info">
                    <span class="st-label">진행중</span>
                    <span class="st-count">${doingCount < 10 && doingCount != 0  ? '0' : ''}${doingCount}</span>
                    <span class="st-unit">건</span>
                </div>
            </div>

            <div class="status-card">
                <div class="status-icon-circle" style="background: #fff0f0; color: var(--st-delayed);"><span class="material-icons">priority_high</span></div>
                <div class="st-info">
                    <span class="st-label">지연됨</span>
                    <span class="st-count">${delayedCount < 10 && delayedCount != 0  ? '0' : ''}${delayedCount}</span>
                    <span class="st-unit">건</span>
                </div>
            </div>

            <div class="status-card">
                <div class="status-icon-circle" style="background: #f0fdf4; color: var(--st-completed);"><span class="material-icons">done_all</span></div>
                <div class="st-info">
                    <span class="st-label">완료</span>
                    <span class="st-count">${completedCount < 10 && completedCount != 0  ? '0' : ''}${completedCount}</span>
                    <span class="st-unit">건</span>
                </div>
            </div>
        </div>


    <div class="filter-wrapper">
        <div class="tab-container">
            <button class="category-tab active" onclick="updateFilter('전체', this)">전체보기</button>
            <button class="category-tab" onclick="updateFilter('진행', this)">진행중</button>
            <button class="category-tab" onclick="updateFilter('지연', this)">지연됨</button>
            <button class="category-tab" onclick="updateFilter('완료', this)">완료</button>
        </div>
        <div class="prj-search-box">
            <span class="material-icons">search</span>
            <input type="text" id="prjNameSearch" oninput="updateFilter()" placeholder="프로젝트명 검색...">
        </div>
    </div>

    <div class="shop-content-box">
        <div class="row g-4" id="projectGrid">
          <c:forEach items="${projectList}" var="prj">
            <div class="col-sm-12 col-md-6 col-lg-4 project-item ${prj.projIpt == 'Y' ? 'order-first' : ''}"
                data-id="${prj.projNo}" data-status="${prj.projStts}" data-title="${prj.projTtl}">

                <div style="border-left: 6px solid ${prj.projColor};" class="project-card shadow-sm p-4 ${prj.projIpt == 'Y' ? 'important' : ''}">
                    
                    <div class="card-top-header d-flex align-items-center mb-3">
                        <button class="btn-star ${prj.projIpt == 'Y' ? 'active' : ''}" onclick="toggleStar(this, ${prj.projNo}, '${prj.projIpt}')">
                            <span class="material-icons">${prj.projIpt == 'Y'? 'star' : 'star_outline'}</span>
                        </button>
                        <span class="status-badge ms-2" style="background: ${prj.projStts == '지연' ? '#fff0f0' : (prj.projStts == '완료' ? '#f0fdf4' : '#efefff')}; color: ${prj.projStts == '지연' ? 'var(--st-delayed)' : (prj.projStts == '완료' ? 'var(--st-completed)' : 'var(--st-ongoing)')};">
                            ${prj.projStts == '진행' ? '진행 중' : prj.projStts}
                        </span>
                        
                        <div class="ms-auto d-flex gap-2">
                            <c:choose>
                      
                                <c:when test="${prj.projStts == '완료'}">
                                    <span class="badge shadow-sm" 
                                        style="background-color: #e9ecef; color: #6c757d; border-radius: 8px; padding: 6px 12px; font-size: 11px; font-weight: bold;">
                                        종료됨
                                    </span>
                                </c:when>

                                <c:when test="${prj.projPrgrt == 100 && prj.projStts == '진행'}">
                                    <button class="btn btn-sm shadow-sm fw-bold"
                                            style="background-color: var(--st-completed); color: white; border-radius: 8px; padding: 4px 10px; font-size: 11px;"
                                            onclick="completeProject(${prj.projNo}, '${prj.projTtl}')">
                                        완료
                                    </button>
                                </c:when>     

                                <c:otherwise>
                                    <button class="btn btn-sm btn-outline-secondary shadow-sm"
                                            style="border-radius: 8px; display: flex; align-items: center;"
                                            onclick="manageParticipants(${prj.projNo}, '${prj.projTtl}', [
                                                <c:forEach var='m' items='${prj.prtpntVOList}' varStatus='s'>
                                                    {'empId': '${m.empId}', 'prtpntNm': '${m.prtpntNm}'}${!s.last ? ',' : ''}
                                                </c:forEach>
                                            ])">
                                        <span class="material-icons" style="font-size: 14px; margin-right: 2px;">group_add</span>
                                    </button>
                                </c:otherwise>                       
                            </c:choose>                    
                        </div>
                    </div>

                    <div onclick="location.href='/myproject/detail/${prj.projNo}'" style="cursor:pointer; flex-grow: 1;">
                        <h5 class="prj-ttl-text mb-1">${prj.projTtl}</h5>
                        
                        <!-- <div class="text-muted mb-2" style="font-size: 11px; display: flex; align-items: center;">
                            <span class="material-icons" style="font-size: 13px; margin-right: 4px;">calendar_today</span>
                           
                            <%-- 연도(24~28글자) + 월일(4~10글자) --%>
                            ${fn:substring(prj.projBgngDt, 24, 28)}-${fn:substring(prj.projBgngDt, 4, 10)} 
                            ~ 
                            ${fn:substring(prj.projEndDt, 24, 28)}-${fn:substring(prj.projEndDt, 4, 10)}
                        </div> -->
                        <p class="text-muted small prj-dtl-text">${prj.projDtl}</p>

                        <div class="mb-4">
                            <div class="d-flex justify-content-between mb-2">
                                <span class="small fw-bold text-muted">Progress</span>
                                <span class="small fw-bold text-primary">${prj.projPrgrt}%</span>
                            </div>
                            <div class="progress mb-3" style="height: 6px;">
                                <div class="progress-bar" style="width: ${prj.projPrgrt}%"></div>
                            </div>

                            <div class="d-flex justify-content-between mb-2">
                                <span class="small fw-bold text-muted">Time Elapsed</span>
                                <span class="small fw-bold text-danger">${prj.timePrgrt}%</span>
                            </div>
                            <div class="progress" style="height: 6px;">
                                <div class="progress-bar" style="width: ${prj.timePrgrt}%; background-color:#E06161;"></div>
                            </div>
                        </div>
                    </div>

                        <div class="d-flex justify-content-between align-items-center pt-3 border-top" style="border-color: #f8f9fa !important;">
                            <c:set var="cardNames" value="" />
                            <c:forEach var="emp" items="${prj.prtpntVOList}" varStatus="status">
                                <c:set var="cardNames" value="${cardNames}${emp.prtpntNm}${!status.last ? ', ' : ''}" />
                            </c:forEach>

                            <div class="avatar-group-wrapper ms-auto" data-names="${cardNames}">
                                <c:forEach var="emp" items="${prj.prtpntVOList}" varStatus="status">
                                    <c:if test="${status.index < 3}">
                                        <div class="avatar-sm"
                                            style="background: var(--point-color); color: #fff; margin-left: ${status.first ? '0' : '-10px'}; z-index: ${10 - status.index};">
                                            ${fn:substring(emp.prtpntNm, 0, 1)}
                                        </div>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${fn:length(prj.prtpntVOList) > 3}">
                                    <div class="avatar-sm" style="background:#f4f7fe; color:var(--point-color); margin-left: -10px; z-index: 1;">
                                        +${fn:length(prj.prtpntVOList) - 3}
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<!-- 프로젝트 생성 모달 시작 -->
<div class="modal fade" id="createProjectModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content shadow-lg">
            <div class="modal-header border-0 p-4 pb-0">
                <div class="d-flex justify-content-between align-items-center w-100">
                    <h5 class="fw-bold mb-0">
                        <span class="material-icons align-middle me-2" style="color:var(--point-color)">add_circle</span>
                        새 프로젝트 생성
                    </h5>
                    <div class="d-flex align-items-center bg-light px-3 py-2 rounded-3" style="border: 1px solid var(--border-default);">
                        <label for="prjColor" class="small fw-bold text-muted me-2 mb-0">테마</label>
                        <input type="color" name="projColor" id="prjColor" class="form-control form-control-color border-0 bg-transparent p-0"
                               value="#4e73df" title="프로젝트 색상 선택" style="width: 28px; height: 28px; cursor: pointer;">
                    </div>
                </div>
                <button type="button" class="btn-close ms-2" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row g-3">
                    <div class="col-12">
                        <label class="small fw-bold text-muted mb-1">프로젝트 제목</label>
                        <input type="text" name="projTtl" class="form-control" placeholder="제목을 입력하세요">
                    </div>
                    <div class="col-6">
                        <label class="small fw-bold text-muted mb-1">시작일</label>
                        <input type="date" name="projBgngDt" class="form-control">
                    </div>

                    <div class="col-6">
                        <label class="small fw-bold text-muted mb-1">종료 예정일</label>
                        <input type="date" name="projEndDt" class="form-control">
                    </div>
                    <div class="col-12 position-relative">
                        <label class="small fw-bold text-muted mb-1">팀원 검색 (이름 또는 사번)</label>
                        <div class="input-group">
                            <span class="input-group-text bg-transparent border-end-0">
                                <span class="material-icons text-muted" style="font-size:20px;">search</span>
                            </span>
                            <input type="text" id="memberSearchInput" class="form-control border-start-0" placeholder="예: 김철수 또는 2024001">
                        </div>
                        <div id="searchResultList" class="search-result-list"></div>
                    </div>
                    <div class="col-12">
                        <label class="small fw-bold text-muted mb-1">참여 팀원 목록</label>
                        <div id="selectedMembers" class="selected-members-box">
                            <span class="text-muted small">팀원을 검색하여 추가해 주세요.</span>
                        </div>
                    </div>
                    <div class="col-12">
                        <label class="small fw-bold text-muted mb-1">프로젝트 상세 설명</label>
                        <textarea name="projDtl" class="form-control" rows="3" placeholder="내용을 입력하세요"></textarea>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 p-4 pt-0">
                <button class="btn btn-primary w-100 py-3 fw-bold rounded-pill" style="background:var(--point-color); border:none;" onclick="submitProject()">
                    프로젝트 생성하기
                </button>
            </div>
        </div>
    </div>
</div>
<!-- 프로젝트 생성 모달 끝 -->

<!-- 참여자 관리하는 모달 시작 -->
<div class="modal fade" id="manageParticipantsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-md modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header bg-light p-4">
                <h5 class="fw-bold mb-0">
                    <span class="material-icons align-middle me-2 text-primary">group</span>
                    참여자 관리
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="mb-4 position-relative">
                    <label class="small fw-bold text-muted mb-2">신규 팀원 추가</label>
                    <div class="input-group mb-2">
                        <span class="input-group-text bg-white border-end-0"><span class="material-icons" style="font-size:18px;">person_search</span></span>
                        <input type="text" id="memberSearchManage" class="form-control border-start-0" placeholder="이름 또는 사번 검색...">
                    </div>
                    <div id="manageSearchResult" class="search-result-list" style="top: 70px;"></div>
                </div>

                <hr class="my-4" style="border-style: dashed;">

                <label class="small fw-bold text-muted mb-3">현재 참여 중인 팀원</label>
                <div id="currentParticipantList" class="d-flex flex-column gap-2" style="max-height: 300px; overflow-y: auto;">
                    </div>
            </div>
        </div>
    </div>
</div>
<!-- 참여자 관리하는 모달 끝 -->


<script>
document.addEventListener('DOMContentLoaded', () => {
    searchemployeeDb();
});
    
    // 전역 변수로 현재 선택된 프로젝트 번호 저장
    let currentManageProjNo = null;

    function manageParticipants(projNo, projTtl, participantList) {
        console.log(projNo, projTtl, participantList);
        currentManageProjNo = projNo; // 나중에 추가/삭제 통신할 때 사용
        
        // 1. 모달 제목 업데이트
        const modalTitle = document.querySelector('#manageParticipantsModal .fw-bold');
        if(modalTitle) {
            modalTitle.innerHTML = `<span class="material-icons align-middle me-2 text-primary">group</span> [\${projTtl}] 참여자 관리`;
        }

        // 2. 현재 참여자 목록 렌더링
        renderParticipantList(participantList);

        // 3. 모달 띄우기
        const myModal = new bootstrap.Modal(document.getElementById('manageParticipantsModal'));
        myModal.show();
    }

    function renderParticipantList(list) {
        const listDiv = document.getElementById('currentParticipantList');
        if(!listDiv) return;

        if (!list || list.length === 0) {
            listDiv.innerHTML = '<p class="text-muted small text-center py-3">참여 중인 팀원이 없습니다.</p>';
            return;
        }

        // list 내부의 데이터를 순회하며 HTML 생성
        listDiv.innerHTML = list.map(m => `
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3 border mb-2 bg-white">
                <div class="d-flex align-items-center gap-3">
                    <div class="avatar-sm" style="background:var(--point-color); color:#fff; width:32px; height:32px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-weight:bold;">
                        \${m.prtpntNm.substring(0,1)}
                    </div>
                    <div>
                        <div class="fw-bold" style="font-size:14px; color:var(--text-dark);">\${m.prtpntNm}</div>
                        <div class="text-muted" style="font-size:12px;">사번 : \${m.empId}</div>
                    </div>
                </div>
                <button class="btn btn-link text-danger p-0" onclick="removeParticipant('\${m.empId}', '\${m.prtpntNm}')">
                    <span class="material-icons">person_remove</span>
                </button>
            </div>
        `).join('');
    }

    // 팀원 검색 이벤트 (모달 내 전용)
    document.getElementById('memberSearchManage').addEventListener('input', function(e) {
        const v = e.target.value.trim();
        const resDiv = document.getElementById('manageSearchResult');
        
        if (!v) { resDiv.style.display = 'none'; return; }

        // 1. 현재 참여자 목록에서 사번만 정확히 추출
        const currentIds = Array.from(document.querySelectorAll('#currentParticipantList .text-muted'))
                                .map(el => {         
                                    const text = el.innerText.trim();
                                    return text.replace(/[^0-9]/g, ""); // 숫자만 남김 (사번이 숫자인 경우)
                                });

        // 2. 필터링 로직
        const filtered = employeeDb.filter(emp => {
            const empIdStr = String(emp.empId);
            const isMatch = emp.empNm.includes(v) || empIdStr.includes(v);
            // 사번이 포함되어 있는지 확인
            const isAlreadyIn = currentIds.some(id => id === empIdStr); 

            return isMatch && !isAlreadyIn;
        });

        if (filtered.length === 0) {
            resDiv.innerHTML = '<div class="p-3 text-muted small text-center">검색 결과가 없습니다.</div>';
        } else {
            resDiv.innerHTML = filtered.map(e => `
                <div class="search-item" onclick="addParticipant('\${e.empId}','\${e.empNm}')" style="padding: 10px; border-bottom: 1px solid #eee;">
                    <div>
                        <strong>\${e.empNm}</strong> <small>\${e.empJbgd}</small>
                    </div>
                    <div style="font-size: 0.85em; color: #666; margin-top: 4px;">
                        \${e.deptNm} (\${e.empId}) | 참여 프로젝트: <b style="color: #e84118;">\${e.projectCount}</b>
                    </div>
                </div>
            `).join('');
        }
        resDiv.style.display = 'block';
    });

    // 팀원 추가 실행
    function addParticipant(empId, empNm) { 
        if (!currentManageProjNo) {
            AppAlert.error('오류', '프로젝트 정보를 찾을 수 없습니다.');
            return;
        }

        // 1. 추가 확인창 띄우기
        AppAlert.confirm(
            '팀원 추가', 
            `[\${empNm}] 님을 프로젝트 <br>팀원으로 추가하시겠습니까?`, 
            '추가하기', 
            '취소', 
            'person_add', // 상황에 맞는 아이콘
            'primary'      // 추가 작업이므로 긍정적인 primary/success 테마 적용
        ).then((result) => {
            // 2. 사용자가 '추가하기'를 눌렀을 때만 실행
            if (result.isConfirmed) {
                axios.post("/adpjt/addParticipant", {
                    projNo: currentManageProjNo, 
                    empId: empId,
                    prtpntNm: empNm
                }).then(res => {
                    if (res.data === "success") {
                        // 성공 알림
                        AppAlert.autoClose('추가 완료', `[\${empNm}] 님이 추가되었습니다.`, 'check_circle', 'success');

                        // UI 초기화
                        document.getElementById('memberSearchManage').value = '';
                        document.getElementById('manageSearchResult').style.display = 'none';

                        // 목록 새로고침
                        setTimeout(() => {
                            if (typeof loadCurrentParticipants === 'function') {
                                loadCurrentParticipants(currentManageProjNo);
                            } else {
                                location.reload();
                            }
                        }, 1500); // 1.5초 정도 대기
                    } else {
                        AppAlert.error('추가 실패', '데이터 처리 중 오류가 발생했습니다.');
                    }
                }).catch(err => {
                    console.error(err);
                    AppAlert.error('오류 발생', '서버 통신에 실패했습니다.');
                });
            }
        });
    }

    // 팀원 삭제 실행
    function removeParticipant(empId, empNm) {
        // (알람 리팩토링) 기존 Swal.fire를 AppAlert.confirm으로 변경하여 디자인 통일
        AppAlert.confirm(
            '팀원 제외', 
            `[\${empNm}] 님을 프로젝트에서 제외하시겠습니까?`, 
            '제외하기', 
            '취소', 
            'person_remove', // (알람 리팩토링) 상황에 맞는 아이콘 추천
            'danger'         // (알람 리팩토링) 삭제/제외 작업이므로 danger 테마 적용
        ).then((result) => {
            if (result.isConfirmed) {
                axios.post("/adpjt/removeParticipant", {
                    projNo: currentManageProjNo,
                    empId: empId
                }).then(res => {
                    if (res.data === "success") {
                        AppAlert.autoClose('제외 완료', `[\${empNm}] 님이 제외되었습니다.`, 'check_circle', 'success');

                        setTimeout(() => {
                            if (typeof loadCurrentParticipants === 'function') {
                                loadCurrentParticipants(currentManageProjNo);
                            } else {
                                location.reload();
                            }
                        }, 1500); // 1.5초 정도 대기
                    } else if (res.data === "isTask"){
                         AppAlert.autoClose(
                                '제외 불가', 
                                `[\${empNm}] 님은 혼자 담당하시는 일감이 있어 <br> 제외할 수 없습니다.`, 
                                'error_outline', 
                                'danger', 
                                2000
                            );
                    } else if (res.data == "no") {
                        AppAlert.autoClose(
                                '제외 불가', 
                                `본인은 제외할 수 없습니다.`, 
                                'error_outline', 
                                'danger', 
                                2000
                            );
                    } 
                    
                    else {
                        AppAlert.autoClose('제외 실패', 'check_circle', 'error');
                    }
                }).catch(err => {
                    AppAlert.error('오류 발생', '처리 중 에러가 발생했습니다.'); // (알람 리팩토링)
                });
            }
        });
    }


    // 전체 팀장빼고 ! 사원들 조회
    // 사번, 이름, 부서코드, 프로필   ==> 클릭 시에는 이름(사번) 만?
    let employeeDb = [];
    const sInput = document.getElementById('memberSearchInput');  // 프로젝트 생성 시 사원 검색
    const rList = document.getElementById('searchResultList');  // 사원 검색시 보이는 div
    const selBox = document.getElementById('selectedMembers'); // 추가된 사원 보이는 div
    let selIds = new Map();

    // 프로젝트 생성 시 "사원들 조회하기(팀장빼고)"
    function searchemployeeDb () {
        axios.get("/adpjt/emplist")
        .then(res => {
            employeeDb = res.data;
        })
        .catch(err => {
            console.error(err);
        })
    }

    // 프로젝트 생성 시 사원 검색 후
    sInput.addEventListener('input', function() {
        let v = sInput.value.trim();  // 공백 제거
        if (!v) {   // 만약에 없으면
            rList.style.display = 'none'; // 안 보이기
            return;
        }
        console.log("v는 머니 ? :",v);

        // include는 문자만 가능 ! 숫자 타입은 String으로 바꾸기
        const filtered = employeeDb.filter(e => {
            const name = e.empNm ? e.empNm : "";
            const id = e.empId ? String(e.empId) : "";

            const isMatch = name.includes(v) || id.includes(v);  // 이름, 사번 (조건 1)

            const isAlreadySelected = selIds.has(id); //  이미 추가된 사람 (조건 2)

            return isMatch && !isAlreadySelected;
        });

        renderSearchResult(filtered);
    });

    function renderSearchResult(filtered) {
        if (filtered.length === 0) {
            rList.innerHTML = '<div class="p-3 text-muted small text-center">검색 결과가 없거나 이미 추가된 팀원입니다.</div>';
        } else {
            rList.innerHTML = filtered.map(e => `
                <div class="search-item" data-id="\${e.empId}" data-name="\${e.empNm}" onclick="addMemberTag('\${e.empId}','\${e.empNm}')" style="padding: 10px; border-bottom: 1px solid #eee;">
                    <div>
                        <strong>\${e.empNm}</strong> <small>\${e.empJbgd}</small>
                    </div>
                    <div style="font-size: 0.85em; color: #666; margin-top: 4px;">
                        \${e.deptNm} (\${e.empId}) | 참여 프로젝트: <b style="color: #e84118;">\${e.projectCount}</b>
                    </div>
                </div>
            `).join('');
        }
        rList.style.display = 'block';
    }



    // 여기가 팀원 검색 후 참여하기 !
    function addMemberTag(id, name) {
        if (selIds.has(id)) return;
        if (selIds.size === 0) selBox.innerHTML = '';

        console.log("아이디 : ", id);

        selIds.set(id,name);

        // 추가하는 곳
        const tag = document.createElement('div');
        tag.className = 'member-tag shadow-sm';
        tag.innerHTML = `
            <span>\${name} (\${id})</span>
            <i class="material-icons tag-close" style="font-size:16px;" onclick="removeMemberTag(this, '\${id}')">cancel</i>
        `;
        selBox.appendChild(tag);
        // 없으면 안 보이게
        sInput.value = ''; rList.style.display = 'none';
    }

    // 팀원 태그 삭제 함수
    function removeMemberTag(obj, id) {
        selIds.delete(id); // Map에서 제거 !

        const tag = obj.closest('.member-tag');
        if (tag) {
            tag.remove();  // 부모 요소 제거 !
        }

        // 남은 팀원이 없다면 !
        if (selIds.size === 0) {
            selBox.innerHTML = '<span class="text-muted small">팀원을 검색하여 추가해 주세요.</span>';
        }

        console.log("MAP확인 :", selIds);
    }


    // 프로젝트 생성 함수
    function submitProject() {
        // 프로젝트 생성할 때 필요한 값들 찾기
        const empId = '<sec:authentication property="principal.empVO.empId" />';
        const projNm = '<sec:authentication property="principal.empVO.empNm" htmlEscape="false"/>';  // String 이면 htmlEscape="false" 추가해야 보임!

        console.log("ㅣㄹ더 :", empId);
        console.log("리더명 :", empId);

        const projectData = {
            "empId" : empId,
            "projTtl" : document.querySelector("[name=projTtl]").value,
            "projDtl" : document.querySelector("[name=projDtl]").value,
            "projBgngDt" : document.querySelector("[name=projBgngDt]").value,
            "projEndDt" : document.querySelector("[name=projEndDt]").value,
            "projColor" : document.querySelector("[name=projColor]").value,
            "projNm" : projNm,
            "prtpntVOList": Array.from(selIds).map(([id, name]) => ({
                "empId": id,
                "prtpntNm": name
            }))
        }

        console.log("보내기 전 데이터 :", projectData);

        axios.post("/adpjt/create", projectData)
        .then(res => {
            if(res.data === "success") {
                // 모달 닫기
                const modalElement = document.getElementById('createProjectModal');
                const modal = bootstrap.Modal.getInstance(modalElement);
                modal.hide();

                // 모달 초기화
                resetProjectModal();

                Swal.fire({
                    icon: 'success',
                    title: '완료',
                    text: '프로젝트가 생성되었습니다.',
                    showConfirmButton: false,
                    timer: 1000
                }).then(() => {
                    location.reload();
                });                
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: '생성 실패',
                    text: '데이터 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
                    confirmButtonColor: '#d33',
                    confirmButtonText: '확인'
                });
            }
        })
    }

    // 프로젝트 생성 이후에 모달 값 초기화 하는 ..
    function resetProjectModal() {
        const modal = document.getElementById('createProjectModal');

        // 일반 input 및 textarea 초기화
        const inputs = modal.querySelectorAll('input:not([type="color"]), textarea');
        inputs.forEach(input => input.value = '');

        // 컬러 피커 기본값으로 복구
        document.getElementById('prjColor').value = '#4e73df';

        // 선택된 팀원 목록 박스 비우기 (기존 안내 문구로 복구)
        const selectedMembersBox = document.getElementById('selectedMembers');
        selectedMembersBox.innerHTML = '<span class="text-muted small">팀원을 검색하여 추가해 주세요.</span>';

        // 검색 결과창 비우기 (열려있을 경우)
        document.getElementById('searchResultList').innerHTML = '';
    }

    // 진행률(100%일 때) => "프로젝트 완료 처리"
    function completeProject(projNo,projTtl) {
        console.log(projNo);
            Swal.fire({
            title: '프로젝트를 완료하시겠습니까?',
            html: `<b>[\${projTtl}]</b> 프로젝트를 완료 상태로 변경합니다.<br>이 작업은 되돌릴 수 없습니다.`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#71dd37',
            cancelButtonColor: '#a3aed0',
            confirmButtonText: '네, 완료합니다!',
            cancelButtonText: '취소',
            reverseButtons: false
        }).then((result) => {
            if (result.isConfirmed) {
                axios.post("/adpjt/finishpjt", {
                    projNo: projNo,
                    projStts: '완료'
                })
                .then(res => {
                    if(res.data === "success") {
                        Swal.fire({
                            title: '완료되었습니다!',
                            text: '프로젝트가 성공적으로 종료되었습니다.',
                            icon: 'success',
                            timer: 1500,
                            showConfirmButton: false
                        }).then(() => {
                            location.reload();
                        });
                    } else {
                        Swal.fire('오류 발생', '상태 변경 중 문제가 생겼습니다.', 'error');
                    }
                })
                .catch(err => {
                    console.error(err);
                    Swal.fire('실패', '서버 통신에 실패했습니다.', 'error');
                });
            }
        });

    }

    /* 필터 상태 관리 변수 */
    let currentCategory = '전체';

    /* 통합 필터링 함수 (탭 + 검색) */
    function updateFilter(status, btn) {
        if (status) {
            currentCategory = status;
            document.querySelectorAll('.category-tab').forEach(tab => tab.classList.remove('active'));
            btn.classList.add('active');
        }

        const searchTerm = document.getElementById('prjNameSearch').value.toLowerCase();
        const items = document.querySelectorAll('.project-item');

        items.forEach(item => {
            const itemStatus = item.getAttribute('data-status');
            const itemTitle = item.getAttribute('data-title').toLowerCase();

            const matchesStatus = (currentCategory === '전체' || itemStatus === currentCategory);
            const matchesSearch = itemTitle.includes(searchTerm);

            if (matchesStatus && matchesSearch) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    }

    // 별 토글 기능
    function toggleStar(btn, prjNo,projIpt) {
        const item = btn.closest('.project-item');
        const icon = btn.querySelector('.material-icons');
        btn.classList.toggle('active');

        const data = {
            "projNo" : prjNo,
            "projIpt" : projIpt
        }

        if (btn.classList.contains('active')) {
            icon.innerText = 'star';
            item.classList.add('order-first');
            btn.closest('.project-card').classList.add('important');

        } else {
            icon.innerText = 'star_outline';
            item.classList.remove('order-first');
            btn.closest('.project-card').classList.remove('important');
        }

        // 중요도 update

        axios.patch("/adpjt/staript", data)
        .then(res => {
            if(res.data == "success") {

            }
        })
        .catch(err => {
            console.error(err);
        })
    }

</script>