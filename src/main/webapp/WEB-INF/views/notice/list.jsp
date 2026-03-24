<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
    #noticeTbody tr td { background-color: #ffffff !important; vertical-align: middle; }
    
    /* 중요/긴급 공지 전용 연한 배경색 */
    .row-important, .row-important td { 
        background-color: #fffaf0 !important; 
    }

    /* 4. 공지사항 전용 둥근 캡슐 뱃지 스타일 */
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
    .bg-urgent { background-color: #ff3e1d !important; }    /* 긴급 */
    .bg-important { background-color: #ff8c00 !important; } /* 중요 */
    .bg-normal { background-color: #8592a3 !important; }    /* 일반 */

    /* 5. 첨부파일 스타일 */
    .file-icon-wrapper { display: inline-flex; align-items: center; margin-left: 8px; color: #8592a3; vertical-align: middle; }
    .file-count { font-size: 11px; font-weight: 700; margin-left: 2px; background: #696cff; padding: 1px 5px; border-radius: 10px; color: #fff; line-height: 1; }
    
    /* 페이징 및 검색 버튼 */
    #pagingArea { display: flex; justify-content: center; margin-top: 2rem; }
    .btn-search { background-color: #696cff !important; border: 1.5px solid #696cff !important; color: #ffffff !important; }
    .cursor-pointer { cursor: pointer; }

    /* 레이아웃 위치 조정 (전체 페이지 통일) */
    .container-fluid {
        padding-top: 5px !important; 
        padding-bottom: 10px !important;
        padding-left: 5px !important; 
        margin-bottom: 10px !important;
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
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 공지사항</span>
            </div>
            
            <div class="header-sub-content">
                <p class="header-desc" style="font-size: 0.92rem; color: #6c757d; margin: 0 !important; padding: 0 !important; font-family: sans-serif; line-height: 1.2;">
                   사내 주요 소식 및 공지사항을 확인하고 관리할 수 있는 공간입니다.
                </p>
            </div>
        </div>

    </div>
</div>

    <div class="card dashboard-card">
        <div class="card-body">
            <div class="d-flex flex-wrap justify-content-between gap-3 mb-4">
			    <select id="ntcSttsFilter" class="form-select form-select-sm filter-select" style="width: 150px;" onchange="getList(1)">
				    <option value="">전체 공지</option>
				    <option value="긴급">🚨 긴급</option>
				    <option value="중요">⭐ 중요</option>
				    <option value="일반">📄 일반</option>
				</select>
			
			    <div class="input-group" style="max-width: 350px;">
			        <input type="text" id="keyword" class="form-control form-control-sm search-input" 
			               placeholder="제목, 작성자, 날짜 등으로 검색"
			               style="background-color: #ffffff !important;">
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
                    <tbody id="noticeTbody"></tbody>
                </table>
            </div>
            <nav id="pagingArea"></nav>
        </div>
    </div>
</div>

<script>
    let isNavigating = false;

    function listFn(keyword, p, mode, size) {
        const pageNum = p ? parseInt(p) : 1;
        getList(pageNum);
    }

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
        const ntcSttsVal = document.getElementById('ntcSttsFilter').value;
        const keywordVal = document.getElementById('keyword').value;

        const data = { 
            currentPage: currentPage, 
            ntcStts: ntcSttsVal, 
            keyword: keywordVal,
            size: 10 
        };

        axios.post('/notice/listAxios', data) 
            .then(res => {
                const articlePage = res.data;
                const tbody = document.getElementById('noticeTbody');
                
                if (!articlePage || !articlePage.content || articlePage.content.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center py-5">조회된 공지사항이 없습니다. 🔍</td></tr>';
                    document.getElementById('pagingArea').innerHTML = "";
                    return;
                }

                renderTable(articlePage.content);
                document.getElementById('pagingArea').innerHTML = articlePage.pagingArea || "";
                if(typeof renderCount === 'function') renderCount(articlePage);
            })
            .catch(err => {
                console.error("데이터 로드 실패:", err);
            });
    }

    function renderTable(list) {
        let html = "";
        const tbody = document.getElementById('noticeTbody');
        
        if (!list || list.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center py-5">조회된 자료가 없습니다. 🔍</td></tr>';
            return;
        }
        
        list.forEach(function(n) {
            // [기존 로직] 날짜 처리
            let dateDisplay = '-';
            if (n.ntcDt) {
                const d = new Date(n.ntcDt);
                const year = d.getFullYear();
                const month = String(d.getMonth() + 1).padStart(2, '0');
                const day = String(d.getDate()).padStart(2, '0');
                const hours = String(d.getHours()).padStart(2, '0');
                const minutes = String(d.getMinutes()).padStart(2, '0');
                dateDisplay = year + '-' + month + '-' + day + ' ' + hours + ':' + minutes;
            }
            
            // [기존 로직] 뱃지 및 스타일 처리
            const displayNum = n.ntcNo;
            let badgeHtml = "", titleStyle = "", rowClass = "";
            if (n.ntcStts === '긴급') {
                badgeHtml = '<span class="badge-capsule bg-urgent">긴급</span>';
                titleStyle = 'fw-bold text-danger';
                rowClass = 'row-important';
            } else if (n.ntcStts === '중요') {
                badgeHtml = '<span class="badge-capsule bg-important">중요</span>';
                titleStyle = 'fw-bold text-deep-orange';
                rowClass = 'row-important';
            } else {
                badgeHtml = '<span class="badge-capsule bg-normal">일반</span>';
                titleStyle = 'text-dark';
            }

            // --- [수정 및 추가 영역] 파일 처리 ---
            let fileIconHtml = "";
            
            // 1. MyBatis ResultMap 구조에 따른 파일 리스트 추출 (noticeMap -> fileTbMap -> fileDetailVOList)
            const fileList = (n.fileTbVO && n.fileTbVO.fileDetailVOList) ? n.fileTbVO.fileDetailVOList : [];
            
            // 2. 실제 데이터가 있는 파일만 필터링 및 URL 생성
            const validFiles = fileList.filter(f => f.fileDtlId != null);
            const fCount = n.fileCount || validFiles.length; 
            
            // 3. 다운로드 URL 생성 (공통 다운로드 핸들러 경로로 설정)
            const fileUrls = validFiles.map(f => `/download?fileDtlId=\${f.fileDtlId}`);
            const urlsJson = JSON.stringify(fileUrls).replace(/"/g, '&quot;');

            if (fCount > 0) {
                fileIconHtml = `<div class="file-icon-wrapper" 
                                     onclick="downloadAllFiles(event, \${urlsJson})" 
                                     data-bs-toggle="tooltip" 
                                     title="전체 다운로드 (\${fCount}개)">
                                   <span class="material-icons" style="font-size:18px;">attach_file</span>
                                   <span class="file-count">\${fCount}</span>
                                </div>`;
            }
            // --------------------------------------

            html += `<tr class="cursor-pointer \${rowClass}" onclick="goToDetail(\${n.ntcNo})">
                        <td class="text-center text-muted">\${displayNum}</td> 
                        <td>
                            \${badgeHtml} 
                            <span class="\${titleStyle}">\${n.ntcTtl || ''}</span>
                        </td>
                        <td class="text-center">\${fileIconHtml}</td> 
                        <td>\${n.empNm || '관리자'}</td>
                        <td class="text-muted text-nowrap">\${dateDisplay}</td> 
                        <td class="text-center">\${n.ntcCnt || 0}</td>
                    </tr>`;
        });
        tbody.innerHTML = html;
        initTooltips();
    }

    /**
     * ✅ 일괄 다운로드 로직 (기존 유지하되 확인 메시지만 수정)
     */
    function downloadAllFiles(event, urls) {
        event.stopPropagation();
        
        // 만약 전달받은 urls가 문자열(JSON)이라면 파싱
        let urlList = urls;
        if (typeof urls === 'string') {
            try {
                urlList = JSON.parse(urls);
            } catch (e) {
                urlList = [];
            }
        }

        if (!urlList || urlList.length === 0) {
            alert("다운로드할 파일 정보를 찾을 수 없습니다.");
            return;
        }

        if (confirm(urlList.length + "개의 파일을 모두 다운로드하시겠습니까?")) {
            urlList.forEach((url, index) => {
                setTimeout(() => {
                    const link = document.createElement('a');
                    link.href = url;
                    // 파일명 추출이 어려울 경우 브라우저 기본값 사용
                    link.click();
                }, index * 350); 
            });
        }
    }

    function goToDetail(ntcNo) {
        if(isNavigating) return;
        isNavigating = true;
        location.href = '/notice/detail?ntcNo=' + ntcNo;
    }

    function initTooltips() {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(el => new bootstrap.Tooltip(el, { container: 'body', trigger: 'hover' }));
    }
</script>