<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<style>
    /* 기존 스타일 유지 */
    .view-header { border-bottom: 1px solid #f0f2f4; padding-bottom: 1.5rem; margin-bottom: 1.5rem; }
    .view-title { font-size: 1.5rem; font-weight: 700; color: #566a7f; margin-bottom: 0.75rem; }
    .meta-info { font-size: 0.9rem; color: #a1acb8; display: flex; align-items: center; flex-wrap: wrap; gap: 1rem; }
    .meta-info .item { display: flex; align-items: center; }
    .meta-info .material-icons { font-size: 1.1rem; margin-right: 4px; }
    .content-area { min-height: 250px; line-height: 1.8; color: #3e3e3e; font-size: 1.05rem; }
    
    .comment-section { border-top: 1px solid #f0f2f4; padding-top: 2rem; margin-top: 2rem; }
    .comment-input-wrap { border: 1px solid #d9dee3; border-radius: 8px; padding: 1rem; margin-bottom: 2rem; background: #f8f9fa; }
    .comment-input-wrap textarea { border: none; width: 100%; resize: none; outline: none; background: transparent; }
    
    .comment-item { display: flex; gap: 1rem; padding: 1.25rem 0; border-bottom: 1px solid #f0f2f4; position: relative; }
    /* 아바타 이미지 스타일 수정 */
    .comment-avatar { width: 38px; height: 38px; border-radius: 50%; object-fit: cover; flex-shrink: 0; background: #eee; }
    
    .comment-item.reply { margin-left: 3rem; background-color: #fafbfc; padding: 1rem; border-radius: 8px; border-bottom: none; margin-top: 0.5rem; }
    .comment-item.reply::before { content: '└'; position: absolute; left: -1.2rem; top: 1.2rem; color: #ccc; }

    .comment-actions { display: flex; align-items: center; gap: 12px; margin-top: 8px; }
    .comment-actions a { font-size: 0.75rem; color: #8592a3; text-decoration: none; cursor: pointer; display: flex; align-items: center; }
    .comment-actions a:hover { color: #696cff; }
    .action-sep { color: #d9dee3; font-size: 0.7rem; }
    .attachment-box { background-color: #f8f9fa !important; border-radius: 8px; padding: 1.25rem; margin-top: 2rem; border: 1px dashed #d9dee3 !important; }
	.attachment-item { display: inline-flex; align-items: center; background: #fff !important; border: 1px solid #d9dee3; padding: 5px 12px; border-radius: 20px; font-size: 0.85rem; text-decoration: none !important; color: #696cff; transition: 0.2s; }
	.attachment-item:hover { background-color: #696cff !important; color: #fff !important; }
    .prev-next-nav { border-top: 1px solid #f0f2f4; margin-top: 2rem; padding-top: 0.5rem; background-color: #ffffff !important; }
    .nav-row { display: flex; padding: 12px 15px; font-size: 0.9rem; border-bottom: 1px solid #f8f9fa; align-items: center; transition: background-color 0.2s; }
    .nav-row:hover { background-color: #fcfcfe; }
    .nav-label { width: 80px; color: #a1acb8; font-weight: 600; flex-shrink: 0; display: flex; align-items: center; }
    .nav-content { flex-grow: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .author-info-wrap {
	    display: flex;
	    align-items: center;
	    gap: 12px; /* 이미지와 이름 사이 간격 */
	}
	/* 본문 작성자 프로필 이미지 스타일 추가 */
	.author-avatar { 
	    width: 45px; 
	    height: 45px; 
	    border-radius: 50%; 
	    object-fit: cover; 
	    flex-shrink: 0; 
	    background: #eee; 
	    border: 2px solid #fff;
	    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
	}
	.reply {
	    margin-left: 40px; /* 답글 들여쓰기 간격 */
	    background-color: #f9f9f9; /* 답글 배경색 (선택사항) */
	}
	/* 레이아웃 위치 조정 및 헤더 스타일 */
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

    .header-desc {
        font-size: 0.92rem; 
        color: #6c757d; 
        margin: 0 !important; 
        padding: 0 !important; 
        font-family: sans-serif; 
        line-height: 1.2;
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

<sec:authentication property="principal" var="pinfo" />

<div class="page-wrapper">
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
        </div>
    </div>

    <div class="container-fluid">
        <div class="card shadow-sm" style="background-color: #ffffff !important;">
            <div class="card-body p-4 p-lg-5" style="background-color: #ffffff !important;">
                <div class="view-header">
				    <div class="mb-3">
				        <span class="badge bg-label-primary px-3 py-2">${boardVO.departmentVO.deptNm}</span>
				    </div>
				    <h1 class="view-title">${boardVO.bbsNm}</h1>
				    
				    <div class="meta-info">
				        <div class="author-info-wrap">
				            <c:choose>
							    <c:when test="${not empty boardVO.employeeVO.empProfile}">
							        <img src="/board/display?fileName=${boardVO.employeeVO.empProfile}" 
							             class="author-avatar" alt="author profile"
							             onerror="this.src='/resources/images/default-profile.png'">
							    </c:when>
							    <c:otherwise>
							        <img src="/resources/images/default-profile.png" class="author-avatar" alt="default profile">
							    </c:otherwise>
							</c:choose>
				            <div class="d-flex flex-column">
				                <span class="fw-bold text-dark" style="font-size: 1rem;">${boardVO.employeeVO.empNm}</span>
				                <span style="font-size: 0.8rem;"><fmt:formatDate value="${boardVO.bbsDt}" pattern="yyyy-MM-dd HH:mm"/></span>
				            </div>
				        </div>
				        
				        <div class="item ms-auto"> 
					        <span class="badge bg-label-danger px-3 py-2" style="font-size: 0.85rem; color: #a1acb8; background-color: transparent !important;">
					            <span class="material-icons align-middle me-1" style="font-size: 1rem; color: #a1acb8;">report_problem</span>
					            누적 신고 <span id="reportCntDisplay">${not empty boardVO.bbsReportCnt ? boardVO.bbsReportCnt : 0}</span>회
					        </span>
					    </div>
					
					    <div class="item ms-3">
					        <span class="material-icons align-middle" style="font-size: 1.1rem; color: #a1acb8;">visibility</span>
					        조회수 ${boardVO.bbsCnt}
					    </div>

				    </div>
				</div>

                <div class="content-area py-3">${boardVO.bbsCn}</div>
                
                <div class="text-center my-4 d-flex justify-content-center gap-3">
				    <button type="button" id="btnLike" class="btn btn-outline-primary rounded-pill px-4 py-2" onclick="fn_pushLike()">
				        <span class="material-icons align-middle me-1" id="likeIcon">favorite_border</span>
				        좋아요 <span id="likeCountDisplay">${boardVO.bbsLikeCnt}</span>
				    </button>
				    <button type="button" id="btnDislike" class="btn btn-outline-danger rounded-pill px-4 py-2" onclick="fn_pushDislike()">
				        <span class="material-icons align-middle me-1" id="dislikeIcon">thumb_down_off_alt</span>
				        싫어요 <span id="dislikeCountDisplay">${boardVO.bbsDislikeCnt}</span>
				    </button>
				    <button type="button" id="btnRecom" class="btn btn-outline-warning rounded-pill px-4 py-2" onclick="fn_pushRecom()">
				        <span class="material-icons align-middle me-1" id="recomIcon">star_border</span>
				        추천 <span id="recomCountDisplay">${boardVO.bbsRecomCnt}</span>
				    </button>
				</div>
				                
                <c:if test="${not empty boardVO.fileTbVO and not empty boardVO.fileTbVO.fileDetailVOList}">
				    <div class="attachment-box">
				        <div class="fw-bold mb-3">
				            <span class="material-icons align-middle" style="font-size: 1.2rem;">attach_file</span> 첨부파일
				        </div>
				        <div class="d-flex flex-wrap gap-2">
				            <c:forEach var="file" items="${boardVO.fileTbVO.fileDetailVOList}">
				                <a href="/download?fileDtlId=${file.fileDtlId}" class="attachment-item">
				                    <span class="material-icons me-1" style="font-size: 1rem;">description</span> 
				                    ${file.fileDtlONm}
				                </a>
				            </c:forEach>
				        </div>
				    </div>
				</c:if>

                <div class="comment-section">
                    <h6 class="fw-bold mb-3">댓글 <span class="text-primary" id="cmntCount">0</span></h6>
                    <div class="comment-input-wrap">
                        <textarea id="cmntInput" rows="3" placeholder="댓글을 남겨보세요."></textarea>
                        <div class="text-end mt-2">
                            <button class="btn btn-primary btn-sm" onclick="fn_registComment()">등록</button>
                        </div>
                    </div>
                    
                    <div id="commentListArea">
                        <c:forEach var="comment" items="${boardVO.commentVOList}">
                            <div class="comment-item ${not empty comment.cmntUpNo ? 'reply' : ''}">
                                <img src="${not empty comment.empProfile ? '/board/display?fileName='.concat(comment.empProfile) : '/resources/images/default-profile.png'}" 
								     class="comment-avatar" alt="profile"
								     onerror="this.src='/resources/images/default-profile.png'">
                                
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="fw-bold" style="font-size: 0.95rem;">${comment.empNm}</span>
                                        <span class="text-muted" style="font-size: 0.8rem;">
                                            <fmt:formatDate value="${comment.cmntDt}" pattern="yyyy-MM-dd HH:mm"/>
                                        </span>
                                    </div>
                                    <div class="mt-1" style="font-size: 0.95rem; color: #4f5d72;">${comment.cmntCn}</div>
                                    <div class="comment-actions">
                                        <a onclick="fn_replyForm(${comment.cmntNo})">답글</a>
                                        <c:if test="${pinfo.username eq comment.empId}">
                                            <span class="action-sep">|</span>
                                            <a onclick="fn_editComment(${comment.cmntNo})">수정</a>
                                            <span class="action-sep">|</span>
                                            <a class="text-danger" onclick="fn_deleteComment(${comment.cmntNo})">삭제</a>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
                
                <div class="prev-next-nav mb-4">
				    <div class="nav-row">
				        <div class="nav-label"><span class="material-icons me-1" style="font-size:18px">expand_less</span>이전글</div>
				        <div class="nav-content">
				            <c:choose>
				                <c:when test="${not empty boardVO.prevNo && boardVO.prevNo != 0}">
								    <a href="/board/detail?bbsNo=${boardVO.prevNo}" class="text-decoration-none text-dark">${boardVO.prevTtl}</a>
								</c:when>
				                <c:otherwise><span class="text-muted small">이전 글이 없습니다.</span></c:otherwise>
				            </c:choose>
				        </div>
				    </div>
				    <div class="nav-row">
				        <div class="nav-label"><span class="material-icons me-1" style="font-size:18px">expand_more</span>다음글</div>
				        <div class="nav-content">
				            <c:choose>
				                <c:when test="${not empty boardVO.nextNo && boardVO.nextNo != 0}">
								    <a href="/board/detail?bbsNo=${boardVO.nextNo}" class="text-decoration-none text-dark">${boardVO.nextTtl}</a>
								</c:when>
				                <c:otherwise><span class="text-muted small">다음 글이 없습니다.</span></c:otherwise>
				            </c:choose>
				        </div>
				    </div>
				</div>

                <div class="mt-5 d-flex justify-content-between">
                    <a href="/board" class="btn btn-outline-primary px-4">목록으로</a>
                    <div class="d-flex gap-2">
                        <button class="btn btn-outline-danger" onclick="fn_openReport()">신고</button>
                        <c:if test="${pinfo.username eq boardVO.empId}">
                            <a href="/board/update?bbsNo=${boardVO.bbsNo}" class="btn btn-primary">수정</a>
                            <button class="btn btn-danger" onclick="fn_deleteBoard()">삭제</button>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="reportModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">신고하기</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <select id="reportReason" class="form-select mb-3">
                    <option value="부적절한 홍보">부적절한 홍보</option>
                    <option value="욕설 및 비방">욕설 및 비방</option>
                    <option value="도배성 게시글">도배성 게시글</option>
                    <option value="기타">기타</option>
                </select>
                <textarea id="reportDetail" class="form-control" rows="3" placeholder="상세 사유를 입력하세요."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary w-100" onclick="fn_submitReport()">신고 접수</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
// 1. 전역 변수 선언
const currentBbsNo = "${boardVO.bbsNo}";
const loginId = "${pinfo.username}";
const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;

/**
 * [핵심 수정] 컨트롤러에서 보낸 boolean 값을 JS 변수에 매핑하네.
 * EL 태그 ${boardVO.userLiked}는 서버에서 true 또는 false 글자로 치환되어 내려오네.
 */
let isLiked = ${boardVO.userLiked}; 
let isDisliked = ${boardVO.userDisliked}; 
let isRecomed = ${boardVO.userRecomed};   

// 새로고침 시 데이터가 잘 왔는지 확인용 로그 (개발 완료 후 삭제하게나)
console.log("초기 상태 확인 - 좋아요:", isLiked, "싫어요:", isDisliked, "추천:", isRecomed);

document.addEventListener('DOMContentLoaded', function() {
    loadComments();      // 댓글 로드
    initAllButtonsUI();  // [중요] 페이지 로드 즉시 버튼 색칠 (새로고침 해결사)
});

/**
 * 모든 버튼 UI 초기 세팅
 * 전역 변수(isLiked 등) 상태에 따라 버튼의 클래스와 아이콘을 결정하네.
 */
function initAllButtonsUI() {
    updateSingleButtonUI('btnLike', 'likeIcon', isLiked, 'favorite', 'favorite_border', 'btn-primary', 'btn-outline-primary');
    updateSingleButtonUI('btnDislike', 'dislikeIcon', isDisliked, 'thumb_down', 'thumb_down_off_alt', 'btn-danger', 'btn-outline-danger');
    updateSingleButtonUI('btnRecom', 'recomIcon', isRecomed, 'star', 'star_border', 'btn-warning', 'btn-outline-warning');
}

/**
 * [UI 업데이트 공통 함수]
 * 아이콘 텍스트와 Bootstrap 클래스를 교체하네.
 */
function updateSingleButtonUI(btnId, iconId, state, activeIcon, inactiveIcon, activeClass, inactiveClass) {
    const btn = document.getElementById(btnId);
    const icon = document.getElementById(iconId);
    if (!btn || !icon) return;

    if (state) {
        // 활성화 상태: 꽉 찬 아이콘 + 배경색 있는 버튼
        icon.innerText = activeIcon;
        btn.classList.add(activeClass);
        btn.classList.remove(inactiveClass);
    } else {
        // 비활성화 상태: 빈 아이콘 + 테두리만 있는 버튼
        icon.innerText = inactiveIcon;
        btn.classList.add(inactiveClass);
        btn.classList.remove(activeClass);
    }
}

/**
 * [통합 처리 함수] 좋아요, 싫어요, 추천 비동기 통신
 */
function fn_sendAction(type) {
    axios.post('/board/processAction', { 
        bbsNo: currentBbsNo, 
        actionType: type 
    }, { 
        headers: { [csrfHeader]: csrfToken } 
    })
    .then(res => {
        const { resultCode, board } = res.data;
        
        if (resultCode === -1) {
            Swal.fire({ icon: 'warning', title: '알림', text: '본인 게시글에는 참여할 수 없습니다.' });
            return;
        }

        const isRegistered = (resultCode === 1); // 1: 등록, 2: 취소
        let msg = "";

        // 클릭 시 실시간 전역 변수 업데이트 및 UI 즉시 반영
        if(type === 'LIKE') {
            isLiked = isRegistered;
            document.getElementById('likeCountDisplay').innerText = board.bbsLikeCnt;
            updateSingleButtonUI('btnLike', 'likeIcon', isLiked, 'favorite', 'favorite_border', 'btn-primary', 'btn-outline-primary');
            msg = isLiked ? '좋아요를 눌렀습니다.' : '좋아요를 취소했습니다.';
        } 
        else if(type === 'DISLIKE') {
            isDisliked = isRegistered;
            document.getElementById('dislikeCountDisplay').innerText = board.bbsDislikeCnt;
            updateSingleButtonUI('btnDislike', 'dislikeIcon', isDisliked, 'thumb_down', 'thumb_down_off_alt', 'btn-danger', 'btn-outline-danger');
            msg = isDisliked ? '싫어요를 눌렀습니다.' : '싫어요를 취소했습니다.';
        } 
        else if(type === 'RECOM') {
            isRecomed = isRegistered;
            document.getElementById('recomCountDisplay').innerText = board.bbsRecomCnt;
            updateSingleButtonUI('btnRecom', 'recomIcon', isRecomed, 'star', 'star_border', 'btn-warning', 'btn-outline-warning');
            msg = isRecomed ? '이 글을 추천했습니다.' : '추천을 취소했습니다.';
        }

        Swal.fire({ icon: 'success', title: '완료', text: msg, timer: 1000, showConfirmButton: false });
        
    }).catch(err => {
        console.error("Action Error:", err);
        Swal.fire({ icon: 'error', title: '오류', text: '처리 중 에러가 발생했습니다.' });
    });
}

// 버튼 클릭 이벤트 연결
function fn_pushLike() { fn_sendAction('LIKE'); }
function fn_pushDislike() { fn_sendAction('DISLIKE'); }
function fn_pushRecom() { fn_sendAction('RECOM'); }

// --- 댓글 및 게시글 관리 로직 ---
/**
 * 댓글 리스트 로드 및 초기화
 */
function loadComments() {
    var initialList = [];
    // JSP 로딩 시에는 VO의 필드명을 정확히 매핑 (대소문자 주의)
    <c:forEach var="cmnt" items="${boardVO.commentVOList}">
        initialList.push({
            cmntNo: "${cmnt.cmntNo}",
            empId: "${cmnt.empId}",
            empNm: "${cmnt.empNm}",
            empProfile: "${cmnt.empProfile}", // 여기서 pikachu.png 등이 담김
            cmntCn: `<c:out value="${cmnt.cmntCn}" />`.replace(/\n/g, " "),
            cmntUpNo: "${cmnt.cmntUpNo}",
            cmntDt: "<fmt:formatDate value='${cmnt.cmntDt}' pattern='yyyy-MM-dd HH:mm'/>"
        });
    </c:forEach>
    renderComments(initialList);
}

/**
 * 댓글 화면 렌더링 함수
 */
function renderComments(list) {
    var area = document.getElementById('commentListArea');
    var cmntCountSpan = document.getElementById('cmntCount');
    
    if(cmntCountSpan) cmntCountSpan.innerText = list ? list.length : 0;
    
    if (!list || list.length === 0) {
        area.innerHTML = '<div class="text-center py-4 text-muted">댓글이 없습니다.</div>';
        return;
    }

    var html = '';
    list.forEach(function(item) {
        // 1. 대댓글 여부 및 본인 여부 판단
        var isReply = (item.cmntUpNo && String(item.cmntUpNo) !== '0') ? ' reply' : '';
        var isMine = (String(item.empId) === String(loginId)); 
        
        // 2. 날짜 포맷팅 로직 (기존 유지)
        var displayDate = "";
        if (item.cmntDt) {
            var d = new Date(item.cmntDt);
            if (!isNaN(d.getTime())) {
                var year = d.getFullYear();
                var month = ('0' + (d.getMonth() + 1)).slice(-2);
                var day = ('0' + d.getDate()).slice(-2);
                var hour = ('0' + d.getHours()).slice(-2);
                var min = ('0' + d.getMinutes()).slice(-2);
                displayDate = year + '-' + month + '-' + day + ' ' + hour + ':' + min;
            } else {
                displayDate = item.cmntDt;
            }
        }

        // 3. [프로필 이미지 경로 결정]
        // MyBatis 설정이나 JSON 변환 방식에 따른 대소문자 필드명 불일치 완벽 방어
        var profileFile = item.empProfile || item.empprofile || item.EMP_PROFILE || item.emp_profile;
        var profileSrc = "/resources/images/default-profile.png"; // 기본 이미지

        if (profileFile && String(profileFile) !== "null" && String(profileFile).trim() !== "") {
            // 파일명에 공백이 있을 경우(예: '000 프로필.jpg')를 위해 encodeURIComponent 사용
            profileSrc = '/board/display?fileName=' + encodeURIComponent(profileFile);
        }

        // 4. HTML 조립 시작
        html += '<div class="comment-item' + isReply + '">';
        
        // [방어 코드] 이미지 로드 실패(404 등) 시 onerror를 통해 즉시 기본 이미지로 교체
        html += '  <img src="' + profileSrc + '" class="comment-avatar" alt="profile" onerror="this.onerror=null; this.src=\'/resources/images/default-profile.png\';">';
        
        html += '  <div class="flex-grow-1">';
        html += '    <div class="d-flex justify-content-between">';
        // 작성자 이름 (대소문자 대응)
        html += '      <span class="fw-bold small">' + (item.empNm || item.empnm || item.EMP_NM || '알 수 없음') + '</span>';
        html += '      <span class="text-muted small">' + displayDate + '</span>';
        html += '    </div>';
        
        // 댓글 내용 (대소문자 대응)
        html += '    <div class="mt-1 small">' + (item.cmntCn || item.cmntcn || item.CMNT_CN || '') + '</div>';
        
        html += '    <div class="comment-actions">';
        
        // 답글 버튼 (부모 댓글인 경우에만 노출)
        if(!item.cmntUpNo || String(item.cmntUpNo) === '0') {
            html += '    <a onclick="fn_reply(' + (item.cmntNo || item.cmntno || item.CMNT_NO) + ')">답글</a>';
        }
        
        // 수정/삭제 버튼 (내 댓글인 경우에만 노출)
        if(isMine) {
            if(!item.cmntUpNo || String(item.cmntUpNo) === '0') html += '<span class="action-sep">|</span>';
            var content = item.cmntCn || item.cmntcn || item.CMNT_CN || "";
            // 작은따옴표와 큰따옴표 이스케이프 처리하여 JS 함수 파라미터 충돌 방지
            var safeCn = content.replace(/'/g, "\\'").replace(/"/g, "&quot;");
            html += '    <a onclick="fn_editCmnt(' + (item.cmntNo || item.cmntno || item.CMNT_NO) + ', \'' + safeCn + '\')">수정</a>';
            html += '    <span class="action-sep">|</span>';
            html += '    <a onclick="fn_deleteCmnt(' + (item.cmntNo || item.cmntno || item.CMNT_NO) + ')" class="text-danger">삭제</a>';
        }
        
        html += '    </div></div></div>';
    });
    
    // 최종 결과물을 영역에 주입
    area.innerHTML = html;
}

function fn_registComment() {
    var content = document.getElementById('cmntInput').value;
    if(!content.trim()) return;
    axios.post('/board/registComment', { cmntBbsNo: currentBbsNo, cmntCn: content, cmntUpNo: 0 }, {
        headers: { [csrfHeader]: csrfToken }
    }).then(res => {
        document.getElementById('cmntInput').value = '';
        renderComments(res.data);
    });
}

function fn_reply(cmntNo) {
    Swal.fire({ title: '답글 달기', input: 'textarea', showCancelButton: true, confirmButtonText: '등록' })
    .then(result => {
        if (result.isConfirmed && result.value) {
            axios.post('/board/registComment', { cmntBbsNo: currentBbsNo, cmntCn: result.value, cmntUpNo: cmntNo }, {
                headers: { [csrfHeader]: csrfToken }
            }).then(res => renderComments(res.data));
        }
    });
}

function fn_editCmnt(cmntNo, oldCn) {
    Swal.fire({ title: '댓글 수정', input: 'textarea', inputValue: oldCn, showCancelButton: true, confirmButtonText: '수정' })
    .then(result => {
        if (result.isConfirmed && result.value) {
            axios.post('/board/updateComment', { cmntNo: cmntNo, cmntCn: result.value, cmntBbsNo: currentBbsNo }, {
                headers: { [csrfHeader]: csrfToken }
            }).then(res => renderComments(res.data));
        }
    });
}

function fn_deleteCmnt(cmntNo) {
    Swal.fire({ title: '정말 삭제하시겠습니까?', icon: 'warning', showCancelButton: true, confirmButtonText: '삭제' })
    .then(result => {
        if (result.isConfirmed) {
            axios.post('/board/deleteComment', { cmntNo: cmntNo, cmntBbsNo: currentBbsNo }, {
                headers: { [csrfHeader]: csrfToken }
            }).then(res => renderComments(res.data));
        }
    });
}

function fn_deleteBoard() {
    Swal.fire({ title: '게시글 삭제', text: '정말 삭제하시겠습니까?', icon: 'error', showCancelButton: true })
    .then(r => { if(r.isConfirmed) location.href = "/board/delete?bbsNo=" + currentBbsNo; });
}

function fn_openReport() {
    new bootstrap.Modal(document.getElementById('reportModal')).show();
}

function fn_submitReport() {
    const reason = document.getElementById('reportReason').value;
    const detail = document.getElementById('reportDetail').value;
    const fullContent = "[" + reason + "] " + detail;
    axios.post('/board/report', { dclBbsNo: currentBbsNo, dclCn: fullContent }, {
        headers: { [csrfHeader]: csrfToken }
    }).then(res => {
        if(res.data > 0) {
            Swal.fire('신고 완료', '정상적으로 접수되었습니다.', 'success');
            bootstrap.Modal.getInstance(document.getElementById('reportModal')).hide();
        }
    });
}
</script>