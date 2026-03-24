<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* 1. 카드와 바디 배경 고정 (공지사항과 통일) */
    .card.dashboard-card, 
    .card.dashboard-card .card-body { 
        background-color: #ffffff !important; 
    }

    /* 2. 셀렉박스와 입력창 디자인 (보라색 포인트 적용) */
    .filter-select, .search-input {
        border: 1.5px solid #696cff !important; 
        font-weight: 600;
        color: #696cff !important;
        background-color: #ffffff !important;
    }

    /* 3. 테이블 배경 하얗게 고정 및 스타일 */
    .table { background-color: #ffffff !important; }
    #dataTbody tr td { background-color: #ffffff !important; vertical-align: middle; }
    .cursor-pointer { cursor: pointer; }

    /* 4. 자료실용 둥근 캡슐 뱃지 스타일 */
    .badge-capsule {
        display: inline-block;
        padding: 2px 9px;
        font-size: 0.7rem;
        font-weight: 700;
        border-radius: 50px;
        color: #ffffff !important;
        margin-right: 6px;
        vertical-align: middle;
        line-height: 1.4;
        border: none;
    }
    /* 카테고리별 색상 정의 */
    .bg-important-data { background-color: #ff3e1d !important; } /* 중요/긴급 */
    .bg-tech { background-color: #03c3ec !important; }         /* 기술자료 */
    .bg-form { background-color: #71dd37 !important; }         /* 업무양식 */
    .bg-normal-data { background-color: #8592a3 !important; }   /* 일반자료 */

    /* 5. 첨부파일 스타일 (공지사항과 일치) */
    .file-icon-wrapper { display: inline-flex; align-items: center; margin-left: 8px; color: #8592a3; vertical-align: middle; cursor: pointer; }
    .file-count { font-size: 11px; font-weight: 700; margin-left: 2px; background: #696cff; padding: 1px 5px; border-radius: 10px; color: #fff; line-height: 1; }
    
    /* 페이징 및 검색 버튼 */
    #pagingArea { display: flex; justify-content: center; margin-top: 2rem; }
    .btn-search { background-color: #696cff !important; border: 1.5px solid #696cff !important; color: #ffffff !important; }

    /* 레이아웃 위치 조정 */
    .container-fluid {
        padding-top: 5px !important; 
        padding-bottom: 10px !important;
        padding-left: 5px !important; 
        margin-bottom: 10px !important;
    }
    .header-main-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px;
    }
</style>

<div class="container-fluid">
    <div class="page-header" style="margin: 0; display: flex; justify-content: space-between; align-items: flex-end; padding-bottom: 15px;">
        
        <div class="d-flex flex-column">
            <div class="header-main-row" style="display: flex; align-items: center; gap: 8px; margin-bottom: 2px !important;">
                <span class="material-icons" style="font-size: 26px !important; color: #696cff !important; vertical-align: middle;">
                    forum
                </span>
                <span style="font-size: x-large; font-weight: 800; line-height: 1;">게시판</span>
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 자료실</span>
            </div>
            
            <div class="header-sub-content">
                <p class="header-desc" style="font-size: 0.92rem; color: #6c757d; margin: 0 !important; padding: 0 !important; font-family: sans-serif; line-height: 1.2;">
                    업무에 필요한 서식 및 각종 자료를 공유하고 다운로드할 수 있는 페이지입니다.
                </p>
            </div>
        </div>

        <a href="/data/create" class="btn btn-primary d-flex align-items-center px-3 shadow-sm" style="background-color: #696cff; border-color: #696cff; height: fit-content;">
            <span class="material-icons me-1" style="font-size: 18px;">add</span> 자료 등록
        </a>

    </div>
</div>

    <div class="card dashboard-card">
        <div class="card-body">
            <div class="d-flex flex-wrap justify-content-between gap-3 mb-4">
			    <select id="dataType" class="form-select form-select-sm filter-select" style="width: 150px;" onchange="getList(1)">
			        <option value="">전체 카테고리</option>
			        <option value="4">🚨 중요자료</option>
			        <option value="3">📄 기술자료</option>
			        <option value="2">📁 업무양식</option>
			        <option value="1">📄 일반자료</option>
			    </select>
			
			    <div class="input-group" style="max-width: 350px;">
			        <input type="text" id="keyword" class="form-control form-control-sm search-input" 
			               placeholder="제목, 작성자, 날짜 등 검색">
			        <button id="btnSearch" class="btn btn-search btn-sm" onclick="getList(1)">
			            <span class="material-icons" style="font-size: 1.1rem;">search</span>
			        </button>
			    </div>
			</div>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th class="text-center" style="width: 80px;">번호</th>
                            <th>제목</th>
                            <th class="text-center" style="width: 60px;">파일</th> 
                            <th style="width: 150px;">작성자</th>
                            <th style="width: 200px;">날짜</th> 
                            <th class="text-center" style="width: 80px;">조회</th>
                        </tr>
                    </thead>
                    <tbody id="dataTbody"></tbody>
                </table>
            </div>
            <nav id="pagingArea"></nav>
        </div>
    </div>
</div>

<script>
    let isNavigating = false;

    window.addEventListener('pageshow', function(event) {
        isNavigating = false;
    });

    document.addEventListener('DOMContentLoaded', function() {
        getList(1);
        const keywordInput = document.getElementById('keyword');
        if(keywordInput) {
            keywordInput.onkeyup = (e) => { if(e.key === 'Enter') getList(1); };
        }
    });

    function getList(page) {
        const currentPage = page || 1;
        
        // 요소가 있는지 먼저 확인하고 값을 가져오는 안전한 방법
        const dataTypeEl = document.getElementById('dataType');
        const keywordEl = document.getElementById('keyword');

        // 만약 요소가 없으면 빈 값을 기본값으로 세팅
        const dataTypeVal = dataTypeEl ? dataTypeEl.value : "";
        const keywordVal = keywordEl ? keywordEl.value : "";

        const data = { 
            currentPage: currentPage, 
            dataType: dataTypeVal, 
            keyword: keywordVal,
            size: 10
        };

        axios.post('/data/listAxios', data) 
            .then(res => {
                const articlePage = res.data;
                const tbody = document.getElementById('dataTbody');
                
                if (!articlePage || !articlePage.content || articlePage.content.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center py-5">조회된 자료가 없습니다. 🔍</td></tr>';
                    document.getElementById('pagingArea').innerHTML = "";
                    return;
                }

                renderTable(articlePage.content);
                document.getElementById('pagingArea').innerHTML = articlePage.pagingArea || "";
            })
            .catch(err => {
                console.error("데이터 로드 실패:", err);
            });
    }

    function renderTable(list) {
        let html = "";
        const tbody = document.getElementById('dataTbody');
        
        if (!list || list.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center py-5">조회된 자료가 없습니다. 🔍</td></tr>';
            return;
        }

        list.forEach(function(d) {
            // 날짜 포맷팅 (YYYY-MM-DD HH:mm)
            let dateDisplay = '-';
            if (d.dataDt) {
                const dateObj = new Date(d.dataDt);
                const year = dateObj.getFullYear();
                const month = String(dateObj.getMonth() + 1).padStart(2, '0');
                const day = String(dateObj.getDate()).padStart(2, '0');
                const hours = String(dateObj.getHours()).padStart(2, '0');
                const minutes = String(dateObj.getMinutes()).padStart(2, '0');
                dateDisplay = year + '-' + month + '-' + day + ' ' + hours + ':' + minutes;
            }
            
            // 카테고리별 뱃지 처리 (badge-capsule 스타일)
            let badgeHtml = "";
            let titleStyle = "text-dark";
            if (d.dataType == '4') {
                badgeHtml = '<span class="badge-capsule bg-important-data">중요자료</span>';
                titleStyle = 'fw-bold text-danger';
            } else if (d.dataType == '2') {
                badgeHtml = '<span class="badge-capsule bg-form">업무양식</span>';
            } else if (d.dataType == '3') {
                badgeHtml = '<span class="badge-capsule bg-tech">기술자료</span>';
            } else {
                badgeHtml = '<span class="badge-capsule bg-normal-data">일반자료</span>';
            }

            // --- 파일 일괄 다운로드 로직 ---
            let fileIconHtml = "";
            const fileList = (d.fileTbVO && d.fileTbVO.fileDetailVOList) ? d.fileTbVO.fileDetailVOList : [];
            const validFiles = fileList.filter(f => f.fileDtlId != null);
            const fCount = d.fileCount || validFiles.length;

            if (fCount > 0) {
                // 각 파일의 상세 ID를 이용한 URL 생성
                const fileUrls = validFiles.map(f => `/download?fileDtlId=\${f.fileDtlId}`);
                // HTML 속성 충돌 방지를 위한 치환 처리
                const urlsJson = JSON.stringify(fileUrls).replace(/"/g, '&quot;');

                fileIconHtml = `<div class="file-icon-wrapper" 
                                     onclick="downloadAllFiles(event, \${urlsJson})" 
                                     data-bs-toggle="tooltip" 
                                     title="전체 다운로드 (\${fCount}개)">
                                   <span class="material-icons" style="font-size:18px;">attach_file</span>
                                   <span class="file-count">\${fCount}</span>
                                </div>`;
            }

            html += `<tr class="cursor-pointer" onclick="goToDetail(\${d.dataNo})">
                        <td class="text-center text-muted">\${d.dataNo}</td> 
                        <td>
                            \${badgeHtml} 
                            <span class="\${titleStyle}">\${d.dataNm || ''}</span>
                        </td>
                        <td class="text-center">\${fileIconHtml}</td> 
                        <td>\${d.empNm || '관리자'}</td>
                        <td class="text-muted text-nowrap">\${dateDisplay}</td> 
                        <td class="text-center">\${d.dataCnt || 0}</td>
                    </tr>`;
        });
        tbody.innerHTML = html;
        initTooltips();
    }

    /**
     * 일괄 다운로드 처리 함수
     */
    function downloadAllFiles(event, urls) {
        event.stopPropagation(); // 상세 페이지 이동 방지
        
        let urlList = (typeof urls === 'string') ? JSON.parse(urls) : urls;

        if (!urlList || urlList.length === 0) {
            alert("다운로드할 파일 정보를 찾을 수 없습니다.");
            return;
        }

        if (confirm(urlList.length + "개의 파일을 모두 다운로드하시겠습니까?")) {
            urlList.forEach((url, index) => {
                setTimeout(() => {
                    const link = document.createElement('a');
                    link.href = url;
                    link.click();
                }, index * 350); 
            });
        }
    }

    function goToDetail(dataNo) {
        if(isNavigating) return;
        isNavigating = true;
        location.href = '/data/detail?dataNo=' + dataNo;
    }

    function initTooltips() {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(el => new bootstrap.Tooltip(el, { container: 'body', trigger: 'hover' }));
    }

    function listFn(keyword, p, mode, size) {
        getList(p || 1);
    }
</script>