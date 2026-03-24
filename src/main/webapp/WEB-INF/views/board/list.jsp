<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<style>
    /* 1. 카드와 바디 배경 고정 (통일감 유지) */
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

    /* 3. 테이블 배경 스타일 */
    .table { background-color: #ffffff !important; }
    #boardTbody tr td { background-color: #ffffff !important; vertical-align: middle; }
    .cursor-pointer { cursor: pointer; }
    
    /* 부서공지 전용 연한 배경색 (공지사항 row-important 스타일 차용) */
    .row-dept-notice, .row-dept-notice td { 
        background-color: #fffaf0 !important; 
    }

    /* 4. 부서 게시판용 둥근 캡슐 뱃지 스타일 */
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
    }
    .bg-dept-notice { background-color: #696cff !important; } /* 부서공지 */
    .bg-dept-free { background-color: #8592a3 !important; }   /* 자유글 */
    .bg-dept-info { background-color: #03c3ec !important; }   /* 정보공유 */

    /* 5. 첨부파일 스타일 */
    .file-icon-wrapper { display: inline-flex; align-items: center; margin-left: 8px; color: #8592a3; vertical-align: middle; cursor: pointer; }
    .file-count { font-size: 11px; font-weight: 700; margin-left: 2px; background: #696cff; padding: 1px 5px; border-radius: 10px; color: #fff; line-height: 1; }
    
    /* 페이징 및 검색 버튼 */
    #pagingArea { display: flex; justify-content: center; margin-top: 2rem; }
    .btn-search { background-color: #696cff !important; border: 1.5px solid #696cff !important; color: #ffffff !important; }

    .container-fluid {
        padding-top: 5px !important; 
        padding-bottom: 10px !important;
        padding-left: 5px !important; 
        margin-bottom: 10px !important;
    }

    /* 🚩 [추가] 헤더 행 정렬 클래스 */
    .header-main-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px; /* data/list.jsp 설정과 통일 */
    }

    .header-desc {
        font-size: 0.92rem; 
        color: #6c757d; 
        margin: 0 !important; 
        padding: 0 !important; 
        font-family: sans-serif; 
        line-height: 1.2;
    }
</style>

<div class="container-fluid">
    <div class="page-header" style="margin: 0; display: flex; justify-content: space-between; align-items: flex-end; padding-bottom: 15px;">
        
        <div class="d-flex flex-column">
            <div class="header-main-row">
                <span class="material-icons" style="font-size: 26px !important; color: #696cff !important; vertical-align: middle;">
                    forum
                </span>
                <span style="font-size: x-large; font-weight: 800; line-height: 1;">게시판</span>
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 부서별 게시판</span>
            </div>
            
            <div class="header-sub-content">
                <p class="header-desc">
                    구성원들이 자유롭게 소통하고 의견을 나누는 커뮤니티 공간입니다.
                </p>
            </div>
        </div>

        <a href="/board/create" class="btn btn-primary d-flex align-items-center px-3 shadow-sm" style="background-color: #696cff; border-color: #696cff; margin-bottom: 2px;">
            <span class="material-icons me-1" style="font-size: 18px;">add</span> 게시글 등록
        </a>
    </div>
    
    </div>

    <div class="card dashboard-card">
        <div class="card-body">
            <div class="d-flex flex-wrap justify-content-between gap-3 mb-4">
                <select id="boardSttsFilter" class="form-select form-select-sm filter-select" style="width: 150px;" onchange="getList(1)">
                    <option value="">전체 게시글</option>
                    <option value="부서공지">📌 부서공지</option>
                    <option value="자유글">💬 자유글</option>
                    <option value="정보공유">💡 정보공유</option>
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
                    <tbody id="boardTbody">
                        <tr><td colspan="6" class="text-center py-5 text-muted">데이터를 불러오는 중입니다...</td></tr>
                    </tbody>
                </table>
            </div>
            <div id="pagingArea"></div>
        </div>
    </div>
</div>

<script>
    let isNavigating = false;

    // CSRF 설정
    const header = $("meta[name='_csrf_header']").attr("content");
    const token = $("meta[name='_csrf']").attr("content");
    if (header && token) { axios.defaults.headers.common[header] = token; }

    function listFn(keyword, p, mode, size) { getList(p ? parseInt(p) : 1); }

    document.addEventListener('DOMContentLoaded', function() {
        getList(1);
        const keywordInput = document.getElementById('keyword');
        if(keywordInput) {
            keywordInput.onkeyup = (e) => { if(e.key === 'Enter') getList(1); };
        }
    });

    function getList(page) {
        const boardStts = document.getElementById('boardSttsFilter').value;
        const keyword = document.getElementById('keyword').value;

        // Controller의 파라미터명과 맞춰주세요 (예: bbsType 등)
        const data = { currentPage: page, bbsType: boardStts, keyword: keyword };

        axios.post('/board/listAxios', data)
            .then(res => {
                const articlePage = res.data;
                renderTable(articlePage.content);
                document.getElementById('pagingArea').innerHTML = articlePage.pagingArea || "";
            })
            .catch(err => {
                console.error("데이터 로드 실패:", err);
                document.getElementById('boardTbody').innerHTML = '<tr><td colspan="6" class="text-center py-5 text-danger">데이터를 로드할 수 없습니다.</td></tr>';
            });
    }

    function renderTable(list) {
        let html = "";
        const tbody = document.getElementById('boardTbody');
        
        if (!list || list.length === 0) {
            html = '<tr><td colspan="6" class="text-center py-5 text-muted">게시글이 없습니다. 🔍</td></tr>';
        } else {
            list.forEach(function(b) {
                // --- [기존 날짜 변환 로직 유지] ---
                let dateDisplay = '-';
                if (b.bbsDt) {
                    const d = new Date(b.bbsDt);
                    dateDisplay = `\${d.getFullYear()}-\${String(d.getMonth()+1).padStart(2,'0')}-\${String(d.getDate()).padStart(2,'0')} \${String(d.getHours()).padStart(2,'0')}:\${String(d.getMinutes()).padStart(2,'0')}`;
                }

                // --- [1. 뱃지 및 행 스타일 유지] ---
                let badgeHtml = "";
                let rowClass = "";
                let titleStyle = "text-dark";
                const type = b.bbsType ? String(b.bbsType).trim() : "";
                
                if (type.includes('공지')) {
                    badgeHtml = '<span class="badge-capsule bg-dept-notice">부서공지</span>';
                    rowClass = "row-dept-notice"; 
                    titleStyle = "fw-bold text-primary";
                } else if (type.includes('자유')) {
                    badgeHtml = '<span class="badge-capsule bg-dept-free">자유글</span>';
                } else if (type.includes('정보')) {
                    badgeHtml = '<span class="badge-capsule bg-dept-info">정보공유</span>';
                } else {
                    badgeHtml = `<span class="badge-capsule bg-dept-free">\${type || '일반'}</span>`;
                }

                // --- [2. 파일 아이콘 수정] (예제 방식의 객체 구조 활용) ---
                let fileIconHtml = "";
                // b.fileTbVO.fileDetailVOList가 데이터 로드 시 함께 넘어옵니다.
                if (b.fileCount > 0 && b.fileTbVO && b.fileTbVO.fileDetailVOList) {
                    const fileList = b.fileTbVO.fileDetailVOList;
                    
                    // 다운로드용 URL 배열 생성
                    const urlList = fileList.map(f => `/download?fileDtlId=\${f.fileDtlId}`);
                    
                    // 툴팁용 파일명 목록 생성
                    const fileNames = fileList.map(f => f.fileDtlONm).join(', ');
                    
                    // JSON 문자열로 변환하여 onclick에 전달
                    const urlsJson = JSON.stringify(urlList).replace(/"/g, '&quot;');

                    fileIconHtml = `
                        <div class="file-icon-wrapper" 
                             onclick="downloadAllFiles(event, \${urlsJson})" 
                             style="cursor:pointer;"
                             data-bs-toggle="tooltip" 
                             title="\${fileNames}">
                            <span class="material-icons" style="font-size:18px; color:#696cff; vertical-align:middle;">attach_file</span>
                            <span class="file-count" style="font-size: 11px; font-weight: 700; margin-left: 2px; background: #696cff; padding: 1px 5px; border-radius: 10px; color: #fff; line-height: 1;">\${b.fileCount}</span>
                        </div>`;
                }

                // --- [3. 댓글 개수 로직 유지] ---
                let replyHtml = b.replyCount > 0 ? `<span class="text-primary fw-bold ms-1" style="font-size: 0.85rem;">[\${b.replyCount}]</span>` : "";

                // --- [4. HTML 생성] ---
                html += `<tr class="cursor-pointer \${rowClass}" onclick="goToDetail(\${b.bbsNo})">
                        <td class="text-center text-muted">\${b.bbsNo}</td>
                        <td>
                            <div class="d-flex align-items-center">
                                \${badgeHtml} 
                                <span class="fw-semibold \${titleStyle}">\${b.bbsNm || '제목 없음'}</span>
                                \${replyHtml}
                            </div>
                        </td>
                        <td class="text-center">\${fileIconHtml}</td>
                        <td>\${b.employeeVO ? b.employeeVO.empNm : (b.empNm || '작성자')}</td>
                        <td class="text-muted text-nowrap">\${dateDisplay}</td>
                        <td class="text-center text-muted">\${b.bbsCnt || 0}</td>
                    </tr>`;
            });
        }
        tbody.innerHTML = html;
        initTooltips();
    }

    // 파일 일괄 다운로드 실행 함수
    function downloadAllFiles(event, urls) {
        event.stopPropagation();
        let urlList = typeof urls === 'string' ? JSON.parse(urls) : urls;

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

    function goToDetail(bbsNo) {
        if(isNavigating) return;
        isNavigating = true;
        location.href = '/board/detail?bbsNo=' + bbsNo;
    }

    function initTooltips() {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(el => new bootstrap.Tooltip(el, { container: 'body', trigger: 'hover' }));
    }
</script>