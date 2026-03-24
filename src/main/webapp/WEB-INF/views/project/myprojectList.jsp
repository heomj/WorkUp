<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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

    body { background-color: var(--bg-light);}
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
                    <span style="font-weight: normal; color: #717171; font-size: 15px;">| 나의 프로젝트</span>
                </div>
            </div>

            <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                참여 중인 프로젝트 현황을 한눈에 파악합니다.
            </div>
        </div>
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
                            <button class="btn-star ${prj.projIpt == 'Y' ? 'active' : ''}" >
                                <span class="material-icons">${prj.projIpt == 'Y'? 'star' : 'star_outline'}</span>
                            </button>
                            <span class="status-badge  ms-2" style="background: ${prj.projStts == '지연' ? '#fff0f0' : (prj.projStts == '완료' ? '#f0fdf4' : '#efefff')}; color: ${prj.projStts == '지연' ? 'var(--st-delayed)' : (prj.projStts == '완료' ? 'var(--st-completed)' : 'var(--st-ongoing)')};">
                                    ${prj.projStts == '진행' ? '진행 중' : prj.projStts}
                            </span>
                            <div class="ms-auto d-flex gap-2">
                                <c:if test="${prj.projPrgrt == 100 && prj.projStts == '진행'}">
                                    <button class="btn btn-sm shadow-sm fw-bold"
                                            style="background-color: var(--st-completed); color: white; border-radius: 10px; padding: 5px 12px; font-size: 12px;"
                                            onclick="completeProject(${prj.projNo}, '${prj.projTtl}')">
                                        <span class="material-icons align-middle" style="font-size: 16px; margin-right: 2px;">check_circle</span>
                                        완료
                                    </button>
                                </c:if>
                            </div>
                        </div>

                        <div onclick="location.href='/myproject/detail/${prj.projNo}'" style="cursor:pointer; flex-grow: 1;">
                            <h5 class="prj-ttl-text">${prj.projTtl}</h5>
                            <p class="text-muted small prj-dtl-text">${prj.projDtl}</p>

                            <div class="mb-4">
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="small fw-bold text-muted">Progress</span>
                                    <span class="small fw-bold text-primary">${prj.projPrgrt}%</span>
                                </div>
                                <div class="progress mb-3">
                                    <div class="progress-bar" style="width: ${prj.projPrgrt}%"></div>
                                </div>

                                <div class="d-flex justify-content-between mb-2">
                                    <span class="small fw-bold text-muted">Time Elapsed</span>
                                    <span class="small fw-bold text-danger">${prj.timePrgrt}%</span>
                                </div>
                                <div class="progress"> <div class="progress-bar"  style="width: ${prj.timePrgrt}%; background-color:#E06161;"></div>
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



<script>
    document.addEventListener('DOMContentLoaded', () => {
        searchemployeeDb();
    });
    // 전체 팀장빼고 ! 사원들 조회
    // 사번, 이름, 부서코드, 프로필   ==> 클릭 시에는 이름(사번) 만?
    let employeeDb = [];
    //const sInput = document.getElementById('memberSearchInput');  // 프로젝트 생성 시 사원 검색
    const rList = document.getElementById('searchResultList');  // 사원 추가시 넣을 div
    const selBox = document.getElementById('selectedMembers');
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

/*      // 프로젝트 생성 시 사원 검색 후
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

            const isAlreadySelected = selIds.has(id); // Set의 has 메서드 활용 / 이미 추가된 사람 (조건 2)

            return isMatch && !isAlreadySelected;
        });

        renderSearchResult(filtered);
    });*/

/*
    function renderSearchResult(filtered) {
        if (filtered.length === 0) {
            rList.innerHTML = '<div class="p-3 text-muted small text-center">검색 결과가 없거나 이미 추가된 팀원입니다.</div>';
        } else {
            rList.innerHTML = filtered.map(e => `
                <div class="search-item" data-id="\${e.empId}" data-name="\${e.empNm}" onclick="addMemberTag('\${e.empId}','\${e.empNm}')">
                    \${e.empNm} \${e.empJbgd} (\${e.empId} / \${e.deptNm})
                </div>
            `).join('');
        }
        rList.style.display = 'block';
    }
*/


/*

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

    // 참여 팀원 추가 후 삭제하는 함수 ~_~
    function removeMemberTag(element, id) {  // element : i태그 , id : 사번 !
        const tagElement = element.parentElement; // 부모 찾아서 삭제(<div class=member-tag shadow-sm></div>)
        if (tagElement) {
            tagElement.remove();
        }

        // 관리 중인 Set(selIds)에서 해당 사번 삭제 (다시 추가할 수 있게)
        selIds.delete(id);

        // 만약 다 지워졌으면 안내 문구 다시 띄우기
        if (selIds.size === 0) {
            document.getElementById('selectedMembers').innerHTML =
                '<span class="text-muted small">팀원을 검색하여 추가해 주세요.</span>';
        }
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
                    Swal.fire({
                        icon: 'success',
                        title: '완료',
                        text: '프로젝트가 생성되었습니다.',
                        showConfirmButton: false,
                        timer: 1000
                    }).then(() => {
                        location.reload();
                    });

                    // 모달 닫기
                    const modalElement = document.getElementById('createProjectModal');
                    const modal = bootstrap.Modal.getInstance(modalElement);
                    modal.hide();

                    // 모달 초기화
                    resetProjectModal();
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
*/


    function openTeamModal(t) {
        document.getElementById('teamModalTitle').innerText = t + ' 팀원 관리';
        new bootstrap.Modal(document.getElementById('teamModal')).show();
    }

    document.querySelectorAll('.dropdown').forEach(d => {
        // 메뉴가 열릴 때
        d.addEventListener('show.bs.dropdown', function () {
            // .project-card가 없다면 .project-item 등 실제 부모 클래스명으로 수정하세요
            const card = this.closest('.project-card') || this.closest('.project-item');
            if (card) {
                card.style.zIndex = '2000';
            }
        });

        // 메뉴가 닫힐 때
        d.addEventListener('hide.bs.dropdown', function () {
            const card = this.closest('.project-card') || this.closest('.project-item');
            if (card) {
                card.style.zIndex = '1';
            }
        });
    });


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

    /* 별 토글 기능 */
    function toggleStar(btn, prjNo) {
        const item = btn.closest('.project-item');
        const icon = btn.querySelector('.material-icons');
        btn.classList.toggle('active');
        if (btn.classList.contains('active')) {
            icon.innerText = 'star';
            item.classList.add('order-first');
            btn.closest('.project-card').classList.add('important');
        } else {
            icon.innerText = 'star_outline';
            item.classList.remove('order-first');
            btn.closest('.project-card').classList.remove('important');
        }
    }

</script>