<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    :root {
        --bs-card-border-radius: 0.625rem;
        --bs-card-box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        --bs-body-bg: #f4f7ff;
        --chat-accent: #696CFF;
        --text-main: #1c1e21;
        --text-sub: #65676b;
    }

    /* 채팅 목록 메인 컨테이너 */
    .chat-list-container {
        width: 100%;
        background: #fff;
        border-radius: var(--bs-card-border-radius);
        box-shadow: var(--bs-card-box-shadow);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        border-top: 4px solid var(--chat-accent);
        min-height: 70vh;
    }

    .list-header { 
        padding: 1.5rem 2rem; 
        border-bottom: 1px solid #f0f2f5; 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
    }
    
    .room-list { flex: 1; overflow-y: auto; list-style: none; margin: 0; padding: 0; }
    
    .room-item { transition: 0.2s; border-bottom: 1px solid #f8f9fa; }
    .room-item:hover { background-color: #f5f5ff; }

    .room-avatar {
        width: 52px; height: 52px; 
        background: linear-gradient(135deg, var(--chat-accent), #a7a7af);
        border-radius: 12px; 
        display: flex; align-items: center; justify-content: center;
        color: white; font-weight: bold; font-size: 1.1rem; flex-shrink: 0;
    }

    .room-title { font-weight: 700; color: var(--text-main); font-size: 1rem; }
    .room-actions { opacity: 0; transition: 0.2s; }
    .room-item:hover .room-actions { opacity: 1; }
    .status-badge { width: 10px; height: 10px; border-radius: 50%; background: #2ed573; }

    .btn-primary-custom {
        background-color: var(--chat-accent);
        color: #fff;
        text-decoration: none;
    }
    .btn-primary-custom:hover { background-color: #5f61e6; color: #fff; }
    /* 채팅 목록의 마지막 메시지를 한 줄로 제한하고 말줄임표(...) 표시 */
	.last-msg {
	    display: block;
	    white-space: nowrap;
	    overflow: hidden;
	    text-overflow: ellipsis;
	    max-width: 200px; /* 상황에 맞게 조절 */
	}
</style>

<div class="row g-4 justify-content-center">
    <div class="col-12 col-xl-10">
        <div class="chat-list-container">
            <header class="list-header">
                <div>
                    <h5 class="mb-0 fw-bold" style="color: var(--chat-accent);">사내 메시지</h5>
                    <small class="text-muted">동료들과 실시간으로 소통하세요.</small>
                </div>
                <a href="<c:url value='/chat/create'/>" class="btn btn-primary-custom d-flex align-items-center fw-bold px-3 border-0">
                    <span class="material-icons me-1" style="font-size: 1.2rem;">add_comment</span> 새 채팅방
                </a>
            </header>

            <div class="search-container p-3 bg-light border-bottom">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0">
                        <span class="material-icons text-muted" style="font-size: 1.2rem;">search</span>
                    </span>
                    <input type="text" id="roomSearch" class="form-control border-start-0 ps-0 shadow-none" placeholder="방 이름 또는 메시지 검색...">
                    <%-- HTML 샘플에 있던 검색 버튼 추가 --%>
                    <button class="btn btn-secondary fw-bold px-4" type="button" id="btnSearch">검색</button>
                </div>
            </div>

            <ul class="room-list" id="roomListUl">
                <c:choose>
                    <c:when test="${not empty roomList}">
                        <c:forEach var="room" items="${roomList}">
                            <li class="room-item p-0 d-flex align-items-center" data-title="${room.chatRmTtl}">
                                <a href="${pageContext.request.contextPath}/chat/room?chatRmNo=${room.chatRmNo}" 
								   class="d-flex align-items-center flex-grow-1 text-decoration-none p-4" 
								   style="color: inherit; min-width: 0;">
                                    <div class="room-avatar me-3">
                                        ${fn:substring(room.chatRmTtl, 0, 1)}
                                    </div>
                                    <div class="room-content flex-grow-1" style="min-width: 0;">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="room-title text-truncate">${room.chatRmTtl}</span>
                                            <span class="room-date ms-2 text-muted flex-shrink-0" style="font-size: 0.8rem;">
                                                <fmt:formatDate value="${room.chatRmBgngDt}" pattern="a h:mm"/>
                                            </span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mt-1">
                                            <span class="last-msg text-muted text-truncate" style="font-size: 0.9rem;">
                                                ${not empty room.chatRmLastMsg ? room.chatRmLastMsg : '새로운 대화를 시작해보세요!'}
                                            </span>
                                            <div class="status-badge ms-2" 
											     style="background-color: ${room.chatRmYn eq 'Y' ? '#2ed573' : '#adb5bd'};">
											</div>
                                        </div>
                                    </div>
                                </a>
                                <%-- 수정 버튼 추가 및 나가기 버튼 유지 --%>
                                <div class="room-actions pe-4 d-flex gap-2">
                                    <button class="btn btn-sm btn-outline-primary fw-bold" 
									        onclick="event.stopPropagation(); editRoom(${room.chatRmNo}, '${room.chatRmTtl}')">수정</button>
									<button class="btn btn-sm btn-outline-danger fw-bold" 
									        onclick="event.stopPropagation(); deleteRoom(${room.chatRmNo})">삭제</button>
                                </div>
                            </li>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <li class="p-5 text-center text-muted">참여 중인 채팅방이 없습니다.</li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // 1. 검색 로직 보강
        const searchInput = document.getElementById('roomSearch');
        const searchBtn = document.getElementById('btnSearch');

        const filterRooms = () => {
            const keyword = searchInput.value.toLowerCase().trim();
            const items = document.querySelectorAll('.room-item');
            
            items.forEach(item => {
                // data-title 속성뿐만 아니라 실제 텍스트 내용에서도 검색
                const title = item.getAttribute('data-title') ? item.getAttribute('data-title').toLowerCase() : "";
                if (title.includes(keyword)) {
                    item.setAttribute('style', 'display: flex !important');
                } else {
                    item.setAttribute('style', 'display: none !important');
                }
            });
        };

        if(searchInput) searchInput.addEventListener('input', filterRooms);
        if(searchBtn) searchBtn.addEventListener('click', filterRooms);
    });

	// 수정 기능 부분
    function editRoom(chatRmNo, currentTitle) {
	    // 1. 이벤트 객체를 명시적으로 처리 (불필요한 preventDefault 제거)
	    const newTitle = prompt("수정할 채팅방 이름을 입력하세요:", currentTitle);
	    
	    if(newTitle && newTitle !== currentTitle) {
	        fetch('${pageContext.request.contextPath}/chat/updateTitle', {
	            method: 'POST',
	            headers: { 'Content-Type': 'application/json' },
	            body: JSON.stringify({ chatRmNo: chatRmNo, chatRmTtl: newTitle })
	        })
	        .then(res => {
	            if(res.ok) { location.reload(); } 
	            else { alert("수정에 실패했습니다."); }
	        });
	    }
	}
	
	function deleteRoom(chatRmNo) {
	    if(!confirm("이 채팅방에서 나가시겠습니까?")) return;
	
	    fetch('${pageContext.request.contextPath}/chat/delete', {
	        method: 'POST',
	        headers: { 'Content-Type': 'application/json' },
	        body: JSON.stringify({ chatRmNo: chatRmNo })
	    })
	    .then(res => {
	        if(res.ok) { alert("삭제되었습니다."); location.reload(); }
	        else { alert("삭제 실패"); }
	    });
	}
</script>