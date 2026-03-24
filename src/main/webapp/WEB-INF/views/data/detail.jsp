<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

<style>
    /* 1. 전체 카드 및 배경 - 공지사항 스타일 복제 */
    .card.shadow-sm {
        background-color: #ffffff !important;
        border: 1px solid #e7e9ed !important;
        box-shadow: 0 2px 6px 0 rgba(67, 89, 113, 0.12) !important;
        border-radius: 0.5rem !important;
    }

    .card-body {
        background-color: #ffffff !important;
        border-radius: 0.5rem !important;
    }

    /* 2. 헤더 및 메타 정보 */
    .view-header { 
        border-bottom: 1px solid #f0f2f4; 
        padding-bottom: 1.5rem; 
        margin-bottom: 1.5rem;
        background-color: #ffffff !important; 
    }
    
    .view-title { font-size: 1.5rem; font-weight: 700; color: #566a7f; margin-bottom: 0.75rem; }
    .meta-info { font-size: 0.9rem; color: #a1acb8; display: flex; flex-wrap: wrap; gap: 1.5rem; }
    .meta-info .item { display: flex; align-items: center; }
    .meta-info .material-icons { font-size: 1.1rem; margin-right: 4px; }

    /* 3. 본문 영역 */
    .content-area { 
        min-height: 300px; 
        line-height: 1.6; 
        color: #3e3e3e; 
        font-size: 1.05rem; 
        background-color: #ffffff !important;
    }

    /* 4. 자료실 뱃지 스타일 (공지사항의 중요/긴급 뱃지 느낌 유지) */
    .badge-data-type { font-weight: 600; font-size: 0.85rem; padding: 0.4em 0.8em; border-radius: 0.375rem; }
    .badge-important { background-color: #ffe0db !important; color: #ff3e1d !important; } /* 중요 */
    .badge-form { background-color: #e1f0ff !important; color: #03c3ec !important; }      /* 업무양식 */
    .badge-tech { background-color: #e8fad7 !important; color: #71dd37 !important; }      /* 기술자료 */
    .badge-normal { background-color: #ebedef !important; color: #8592a3 !important; }    /* 일반자료 */

    /* 5. 첨부파일 박스 (점선 테두리) */
    .attachment-box { 
        background-color: #f8f9fa !important; 
        border-radius: 8px; 
        padding: 1.25rem; 
        margin-top: 2rem; 
        border: 1px dashed #d9dee3 !important; 
    }
    
    .attachment-item { 
        display: inline-flex; 
        align-items: center; 
        background: #fff !important; 
        border: 1px solid #d9dee3; 
        padding: 5px 12px; 
        border-radius: 20px; 
        font-size: 0.85rem; 
        text-decoration: none !important; 
        color: #696cff; 
        transition: 0.2s; 
    }
    .attachment-item:hover { background-color: #696cff !important; color: #fff !important; }

    /* 6. 이전글/다음글 네비게이션 */
    .prev-next-nav { 
        border-top: 1px solid #f0f2f4; 
        margin-top: 2rem; 
        padding-top: 0.5rem; 
        background-color: #ffffff !important;
    }
    .nav-row { display: flex; padding: 12px 0; font-size: 0.9rem; border-bottom: 1px solid #f8f9fa; align-items: center; }
    .nav-label { width: 80px; color: #a1acb8; font-weight: 600; flex-shrink: 0; }
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
    /* 3. 본문 영역 배경 고정 */
	.content-area { 
	    min-height: 300px; 
	    line-height: 1.6; 
	    color: #3e3e3e; 
	    font-size: 1.05rem; 
	    background-color: #ffffff !important;
	    white-space: pre-wrap; /* 👈 이 한 줄을 추가해 주세요! */
	    word-break: break-all; /* 👈 너무 긴 영문 텍스트가 밖으로 튀어나가는 것을 방지합니다. */
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
    </div>
</div>
    
    <div class="card shadow-sm">
        <div class="card-body p-4 p-lg-5">
            
            <div class="view-header">
                <div class="mb-3 d-flex align-items-center gap-2"> 
                    <c:choose>
                        <c:when test="${dataVO.dataType == '4'}">
                            <span class="badge badge-data-type badge-important">중요</span>
                        </c:when>
                        <c:when test="${dataVO.dataType == '2'}">
                            <span class="badge badge-data-type badge-form">업무양식</span>
                        </c:when>
                        <c:when test="${dataVO.dataType == '3'}">
                            <span class="badge badge-data-type badge-tech">기술자료</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-data-type badge-normal">일반자료</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <h1 class="view-title">${dataVO.dataNm}</h1>
                <div class="meta-info">
                    <div class="item"><span class="material-icons">person_outline</span>작성자: <b>${dataVO.empNm}</b></div>
                    <div class="item">
                        <span class="material-icons">schedule</span>등록일: 
                        <c:choose>
                            <c:when test="${not empty dataVO.dataDt}">
                                <fmt:parseDate value="${dataVO.dataDt}" var="parsedDataDt" pattern="yyyy-MM-dd HH:mm:ss" />
                                <fmt:formatDate value="${parsedDataDt}" pattern="yyyy-MM-dd HH:mm"/>
                            </c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="item"><span class="material-icons">visibility</span>조회수: ${dataVO.dataCnt}</div>
                </div>
            </div>

            <div class="content-area">${dataVO.dataCn}</div>

            <c:if test="${not empty dataVO.fileTbVO and not empty dataVO.fileTbVO.fileDetailVOList}">
                <div class="attachment-box">
                    <div class="fw-bold mb-3"><span class="material-icons align-middle" style="font-size: 1.2rem;">attach_file</span> 첨부파일</div>
                    <div class="d-flex flex-wrap gap-2">
                        <c:forEach var="fileDtl" items="${dataVO.fileTbVO.fileDetailVOList}">
                            <a href="/download?fileDtlId=${fileDtl.fileDtlId}" class="attachment-item">
                                <span class="material-icons me-1" style="font-size: 1rem;">description</span> 
                                ${fileDtl.fileDtlONm}
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <div class="prev-next-nav">
                <div class="nav-row">
                    <div class="nav-label">이전글</div>
                    <c:choose>
                        <c:when test="${not empty dataVO.prevNo && dataVO.prevNo != 0}">
                            <a href="/data/detail?dataNo=${dataVO.prevNo}" class="text-decoration-none text-dark">${dataVO.prevTtl}</a>
                        </c:when>
                        <c:otherwise><span class="text-muted small">이전 글이 없습니다.</span></c:otherwise>
                    </c:choose>
                </div>
                <div class="nav-row">
                    <div class="nav-label">다음글</div>
                    <c:choose>
                        <c:when test="${not empty dataVO.nextNo && dataVO.nextNo != 0}">
                            <a href="/data/detail?dataNo=${dataVO.nextNo}" class="text-decoration-none text-dark">${dataVO.nextTtl}</a>
                        </c:when>
                        <c:otherwise><span class="text-muted small">다음 글이 없습니다.</span></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="mt-5 d-flex justify-content-between">
                <a href="/data" class="btn btn-outline-primary px-4">목록으로</a>
                
                <div class="d-flex gap-2">
                    <sec:authorize access="isAuthenticated()">
                        <c:set var="loginEmpId" value="${pageContext.request.userPrincipal.name}" scope="page" />
                        <c:if test="${(not empty loginEmpId and loginEmpId == dataVO.empId) || pageContext.request.isUserInRole('ROLE_ADMIN')}">
                            <button type="button" class="btn btn-outline-primary px-4" onclick="fn_update()">수정</button>
                            <button type="button" class="btn btn-outline-danger px-4" onclick="fn_delete()">삭제</button>
                        </c:if>
                    </sec:authorize>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function fn_update() {
    const dataNo = "${dataVO.dataNo}";
    if(dataNo) location.href = "/data/update?dataNo=" + dataNo;
}

function fn_delete() {
    if(confirm("이 게시글을 정말 삭제하시겠습니까?")) {
        location.href = "/data/delete?dataNo=${dataVO.dataNo}";
    }
}
</script>