<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    /* 1. 전체 카드 배경 및 테두리 강제 흰색 지정 */
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

    /* 2. 헤더 및 메타 정보 스타일 */
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

    /* 3. 본문 영역 배경 고정 */
    .content-area { 
        min-height: 300px; 
        line-height: 1.6; 
        color: #3e3e3e; 
        font-size: 1.05rem; 
        background-color: #ffffff !important;
    }

    /* 4. 중요/긴급 뱃지 */
    .badge-urgent { 
        background-color: #ffe0db !important; 
        color: #e67e00 !important; 
        font-weight: 600; 
        font-size: 0.85rem; 
        padding: 0.4em 0.8em; 
        border-radius: 0.375rem; 
    }

    /* 5. 첨부파일 박스 */
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
    /* 레이아웃 위치 조정 (전체 페이지 통일) */
    .container-fluid {
        padding-top: 5px !important; 
        padding-bottom: 10px !important;
        padding-left: 5px !important; 
        margin-bottom: 10px !important;
    }
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
    
    <div class="card shadow-sm">
        <div class="card-body p-4 p-lg-5">
            
            <div class="view-header">
                <div class="mb-3 d-flex align-items-center gap-2"> 
                    <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2">공지사항</span>
                    <c:if test="${noticeVO.ntcStts == '중요' || noticeVO.ntcStts == '긴급'}">
                        <span class="badge badge-urgent">${noticeVO.ntcStts}</span>
                    </c:if>
                </div>
                <h1 class="view-title">${noticeVO.ntcTtl}</h1>
                <div class="meta-info">
                    <div class="item"><span class="material-icons">person_outline</span>작성자: <b>${noticeVO.empNm}</b></div>
                    <div class="item"><span class="material-icons">schedule</span>등록일: <fmt:formatDate value="${noticeVO.ntcDt}" pattern="yyyy-MM-dd HH:mm"/></div>
                    <div class="item"><span class="material-icons">visibility</span>조회수: ${noticeVO.ntcCnt}</div>
                </div>
            </div>

            <div class="content-area">${noticeVO.ntcCn}</div>

            <c:if test="${noticeVO.fileId > 0}">
                <div class="attachment-box">
                    <div class="fw-bold mb-3">
                        <span class="material-icons align-middle" style="font-size: 1.2rem;">attach_file</span> 
                        첨부파일 (${noticeVO.fileCount})
                    </div>
                    <div class="d-flex flex-wrap gap-2">
                        <c:choose>
                            <c:when test="${not empty noticeVO.fileTbVO.fileDetailVOList}">
                                <c:forEach var="fileDtl" items="${noticeVO.fileTbVO.fileDetailVOList}">
								    <a href="/download?fileDtlId=${fileDtl.fileDtlId}" class="attachment-item" title="${fileDtl.fileDtlONm}">
								        <span class="material-icons me-1" style="font-size: 1rem;">insert_drive_file</span> 
								        ${fileDtl.fileDtlONm}
								        <%-- <small class="ms-1 text-muted">(${fileDtl.fileDtlExt})</small> 이 부분을 지웠습니다 --%>
								    </a>
								</c:forEach>
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted small">첨부파일 정보를 불러올 수 없습니다.</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>

            <div class="prev-next-nav">
                <div class="nav-row">
                    <div class="nav-label">이전글</div>
                    <c:choose>
                        <c:when test="${not empty noticeVO.prevNo && noticeVO.prevNo != 0}">
                            <a href="/notice/detail?ntcNo=${noticeVO.prevNo}" class="text-decoration-none text-dark">${noticeVO.prevTtl}</a>
                        </c:when>
                        <c:otherwise><span class="text-muted small">이전 글이 없습니다.</span></c:otherwise>
                    </c:choose>
                </div>
                <div class="nav-row">
                    <div class="nav-label">다음글</div>
                    <c:choose>
                        <c:when test="${not empty noticeVO.nextNo && noticeVO.nextNo != 0}">
                            <a href="/notice/detail?ntcNo=${noticeVO.nextNo}" class="text-decoration-none text-dark">${noticeVO.nextTtl}</a>
                        </c:when>
                        <c:otherwise><span class="text-muted small">다음 글이 없습니다.</span></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="mt-5 d-flex justify-content-between">
                <a href="/notice" class="btn btn-outline-primary px-4">목록으로</a>
            </div>
        </div>
    </div>
</div>