<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    :root {
        --bs-card-box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, 0.08);
        --chat-primary: #696cff;
        --chat-bubble-mine: #696cff;
        --chat-bubble-other: #f1f3f5;
    }

    .chat-wrapper {
        width: 100%; height: calc(100vh - 100px);
        display: flex; justify-content: center; align-items: center;
        padding: 1.5rem; box-sizing: border-box;
    }

    .chat-container {
        width: 100%; max-width: 1600px; height: 100%;
        display: flex; background: #fff; border-radius: 1rem;
        box-shadow: var(--bs-card-box-shadow); overflow: hidden; border: 1px solid #eef0f2;
    }

    .chat-sidebar { width: 300px; background: #f9faff; border-right: 1px solid #eee; display: flex; flex-direction: column; }
    .chat-sidebar-header { padding: 1.5rem; border-bottom: 1px solid #eee; font-weight: 700; background: #fff; }
    .user-list { flex: 1; overflow-y: auto; list-style: none; padding: 0.5rem; margin: 0; }
    .user-item { display: flex; align-items: center; padding: 0.75rem; border-radius: 0.5rem; transition: 0.2s; cursor: pointer; }
    .user-item:hover { background: #eee; }
    
    .user-avatar { width: 35px; height: 35px; border-radius: 50%; object-fit: cover; margin-right: 10px; border: 1px solid #ddd; }
    .user-avatar-sm { width: 28px; height: 28px; border-radius: 50%; object-fit: cover; margin-right: 8px; border: 1px solid #eee; }

    .chat-main { flex: 1; display: flex; flex-direction: column; background: #fff; min-width: 0; }
    .chat-main-header { padding: 1.25rem 2rem; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
    
    .message-area { 
        flex: 1; padding: 2rem; overflow-y: auto; background: #fdfdfd; 
        display: flex; flex-direction: column; gap: 1.25rem; 
    }
    .msg-row { display: flex; flex-direction: column; max-width: 75%; }
    .msg-row.mine { align-self: flex-end; align-items: flex-end; }
    .msg-row.other { align-self: flex-start; align-items: flex-start; }

    .bubble { padding: 0.8rem 1.2rem; border-radius: 1rem; font-size: 0.95rem; line-height: 1.5; }
    .other .bubble { background: var(--chat-bubble-other); color: #333; border-top-left-radius: 0; }
    .mine .bubble { background: var(--chat-bubble-mine); color: white; border-top-right-radius: 0; box-shadow: 0 4px 12px rgba(105, 108, 255, 0.25); }

    .input-area { padding: 1.5rem 2rem; border-top: 1px solid #eee; display: flex; gap: 1rem; background: #fff; }
    .input-area input { flex: 1; border-radius: 2.5rem; padding: 0.8rem 1.5rem; border: 1.5px solid #eef0f2; outline: none; font-size: 1rem; }

    .emp-invite-item { transition: background 0.2s; border-radius: 5px; }
    .emp-invite-item:hover { background: #f0f2ff; }

	.badge-moderator {
	    background: none !important;
	    border: none !important;
	    padding: 0 !important;
	    box-shadow: none !important;
	    display: inline-flex;
	    align-items: center;
	    vertical-align: middle;
	}
	
	.crown-icon {
	    color: #FFD700;
	    font-size: 1.1rem;
	    margin-left: 4px;
	    filter: drop-shadow(1px 1px 1px rgba(0,0,0,0.1));
	    cursor: default;
	}
	.dept-header {
	    background-color: #f8f9ff;
	    padding: 10px 15px;
	    font-size: 0.85rem;
	    font-weight: 700;
	    color: #696cff;
	    border-bottom: 1px solid #eef0f2;
	    display: flex;
	    align-items: center;
	    cursor: pointer;
	    user-select: none;
	}
	.dept-header:hover { background-color: #f0f2ff; }
	.dept-header .toggle-icon {
	    transition: transform 0.3s ease;
	    margin-left: auto;
	}
	.dept-header.collapsed .toggle-icon {
	    transform: rotate(-90deg) !important;
	}
	.chat-main-header { 
        padding: 1rem 2rem; 
        border-bottom: 1px solid #eee; 
        display: flex; 
        justify-content: space-between; 
        align-items: center;
        background-color: #ffffff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.02); /* 헤더에 살짝 입체감 */
        z-index: 10;
    }
    
    /* 방 제목 스타일 */
    #roomTitleDisplay {
        color: #566a7f;
        letter-spacing: -0.5px;
    }

    .bg-label-secondary {
        background-color: #ebeef0 !important;
        color: #8592a3 !important;
    }
</style>

<div class="chat-wrapper">
    <div class="chat-container">
        <aside class="chat-sidebar">
            <div class="chat-sidebar-header">참여자 목록 (<span id="userCount">${memList.size()}</span>)</div>
            <ul class="user-list" id="memberListArea">
			    <c:forEach items="${memList}" var="mem">
				    <li class="user-item" data-emp-id="${mem.empId}">
				        <c:choose>
				            <c:when test="${not empty mem.empProfile}">
				                <c:url var="memProfileUrl" value="/profile/${mem.empProfile}" />
				            </c:when>
				            <c:otherwise>
				                <c:url var="memProfileUrl" value="/resources/img/default-avatar.png" />
				            </c:otherwise>
				        </c:choose>
				        
				        <img src="${memProfileUrl}" 
				             class="user-avatar" 
				             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/resources/img/default-avatar.png'">
				        
				        <div class="d-flex flex-column">
						    <span class="small ${mem.chatUserAuth == '방장' ? 'fw-bold' : ''}">
						        ${mem.empNm} 
						        <span style="font-size: 0.8em; color: #888; font-weight: normal;">${mem.empJbgd}</span>
						        
						        <c:if test="${mem.chatUserAuth == '방장'}">
						            <span style="color: #FFD700; margin-left: 2px;">👑</span>
						        </c:if>
						    </span>
						    <c:if test="${not empty mem.deptNm}">
						        <span class="text-muted" style="font-size: 0.75rem;">${mem.deptNm}</span>
						    </c:if>
						</div>
				    </li>
				</c:forEach>
			</ul>
        </aside>

        <main class="chat-main">
		    <header class="chat-main-header">
			    <div class="d-flex align-items-center flex-grow-1 min-width-0">
			        <h5 class="fw-bold mb-0 text-truncate" id="roomTitleDisplay" style="max-width: 300px;">
			            ${room.chatRmTtl}
			        </h5>
			        <span class="badge bg-label-secondary ms-2 rounded-pill" style="font-size: 0.75rem;">
			            <i class="bx bx-user me-1"></i>${memList.size()}
			        </span>
			    </div>
			
			    <div class="d-flex gap-2 ms-3">
			        <button class="btn btn-primary btn-sm fw-bold d-flex align-items-center" onclick="openInviteModal()">
			            <i class="bx bx-user-plus me-1"></i>초대
			        </button>
			        
			        <c:if test="${not empty room.empId and room.empId != 0 and room.empId eq loginId}">
			            <button class="btn btn-outline-primary btn-sm fw-bold d-flex align-items-center" onclick="editTitle()">
			                <i class="bx bx-edit-alt me-1"></i>수정
			            </button>
			        </c:if>
			        
			        <div class="vr mx-1" style="height: 24px; align-self: center;"></div>
			
			        <a href="<c:url value='/chat/list'/>" class="btn btn-outline-secondary btn-sm fw-bold">목록</a>
			        <button class="btn btn-outline-danger btn-sm fw-bold" onclick="leaveRoom()">
			            나가기
			        </button>
			    </div>
			</header>

            <div class="message-area" id="msgArea">
			    <c:forEach items="${chatList}" var="chat">
			        <div class="msg-row ${chat.empId == loginId ? 'mine' : 'other'}">
			            <c:if test="${chat.empId != loginId}">
			                <div class="d-flex align-items-center mb-1">
			                    <c:choose>
			                        <c:when test="${not empty chat.empProfile}">
			                            <c:set var="chatImgPath" value="${pageContext.request.contextPath}/profile/${chat.empProfile}" />
			                        </c:when>
			                        <c:otherwise>
			                            <c:set var="chatImgPath" value="${pageContext.request.contextPath}/resources/img/default-avatar.png" />
			                        </c:otherwise>
			                    </c:choose>
			                    <img src="${chatImgPath}" 
			                         class="user-avatar-sm" 
			                         onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/resources/img/default-avatar.png'">
			                    <span class="small text-muted ms-2">${chat.empNm}</span>
			                </div>
			            </c:if>
			            <div class="bubble">${chat.chatCn}</div>
			            <span class="small text-muted mt-1" style="font-size: 0.7rem;">
			                <fmt:formatDate value="${chat.chatDt}" pattern="a h:mm"/>
			            </span>
			        </div>
			    </c:forEach>
			</div>

            <form class="input-area" id="chatForm">
                <input type="text" id="chatInput" placeholder="메시지를 입력하세요..." required autocomplete="off">
                <button type="submit" class="btn btn-primary px-4 rounded-pill fw-bold">전송</button>
            </form>
        </main>
    </div>
</div>

<div class="modal fade" id="inviteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-md"> 
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">대화 상대 초대</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="selectedInviteContainer" class="d-flex flex-wrap gap-2 p-2 mb-3 border rounded" 
                     style="min-height: 50px; background-color: #fcfcfc; border: 1px solid #eee !important;">
                    <span class="text-muted small my-auto ps-2">초대할 인원을 선택하세요.</span>
                </div>

                <div class="search-wrapper mb-3" style="position: relative;">
				    <input type="text" id="empSearchInput" class="form-control" placeholder="이름 또는 부서 검색...">
				</div>

                <div id="empListArea" class="border rounded" style="max-height: 350px; overflow-y: auto;">
                    </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary fw-bold" onclick="submitInvite()">초대하기</button>
            </div>
        </div>
    </div>
</div>

<script>
    /* CP 정의 시 JSP EL이 문자열로 먼저 렌더링되게 처리 */
	const CP = "${pageContext.request.contextPath}";
	const host = window.location.origin;
    const chatRmNo = "${room.chatRmNo}";
    const loginUserId = "${loginId}"; 
    const loginUserNm = "${loginNm}"; 
    const loginUserImg = "${loginProfile}" || "default-avatar.png";
    const roomOwnerId = String("${room.empId}").trim(); 
    const currentLoginId = String("${loginId}").trim();
    
    const msgArea = document.getElementById('msgArea');
    let inviteModalObj;

    function connectSocket() {
        if (window.chatSocket && window.chatSocket.readyState <= 1) return;
        const socketUrl = window.location.origin + CP + "/chat";
        window.chatSocket = new SockJS(socketUrl);
        window.chatSocket.onmessage = (event) => {
            try {
                const chat = JSON.parse(event.data);
                if (chat && String(chat.chatRmNo) === String(chatRmNo)) {
                    if (chat.chatCn) appendMessage(chat);
                }
            } catch (e) { console.error("❌ 데이터 수신 에러:", e); }
        };
        window.chatSocket.onclose = () => setTimeout(connectSocket, 3000);
    }
    connectSocket();

    document.getElementById('chatForm').addEventListener('submit', function(e) {
	    e.preventDefault();
	    const input = document.getElementById('chatInput');
	    const message = input.value.trim();
	    
	    if (!message || !window.chatSocket || window.chatSocket.readyState !== 1) return;
	
	    let profileValue = (loginUserImg && loginUserImg !== "null") ? loginUserImg : "default-avatar.png";
	
	    const sendData = {
	        chatRmNo: parseInt(chatRmNo), 
	        empId: String(loginUserId), 
	        chatCn: message, 
	        empNm: loginUserNm,
	        empProfile: profileValue 
	    };
	
	    window.chatSocket.send(JSON.stringify(sendData));
	    input.value = '';
	    input.focus();
	});

    function appendMessage(chat) {
	    const msgText = chat.chatCn || ""; 
	    const senderId = String(chat.empId || "");
	    const senderNm = chat.empNm || "알 수 없음";
	    let senderImg = chat.empProfile; 
	    
	    if (!msgText.trim()) return;
	
	    const isMine = (senderId === String(loginUserId));
	    const d = chat.chatDt ? new Date(chat.chatDt) : new Date();
	    const displayTime = d.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });
	
	    const host = window.location.origin;
	    const safeCP = (CP && CP !== '/') ? (CP.startsWith('/') ? CP : '/' + CP) : '';
	    const baseUrl = host + safeCP;
	    
	    const defaultImg = baseUrl + '/resources/img/default-avatar.png';
	    let profileImg = defaultImg;
	
	    if (senderImg && String(senderImg).trim() !== '' && senderImg !== 'null' && senderImg !== 'undefined') {
	        if (senderImg.includes('fileName=')) {
	            senderImg = senderImg.split('fileName=')[1].split('&')[0];
	        }
	        if (senderImg.startsWith('http')) {
	            profileImg = senderImg;
	        } else {
	            profileImg = baseUrl + '/profile/' + senderImg;
	        }
	    } else {
	        profileImg = defaultImg;
	    }
	    
	    const bgColor = isMine ? '#696cff' : '#f1f3f5';
	    const textColor = isMine ? '#ffffff' : '#333333';
	    const alignSide = isMine ? 'flex-end' : 'flex-start';
	
	    let msgHtml = "";
	    msgHtml += '<div class="msg-row ' + (isMine ? 'mine' : 'other') + '" style="display: flex; flex-direction: column; align-items: ' + alignSide + '; margin-bottom: 15px; width: 100%;">';
	    
	    if (!isMine) {
	        msgHtml += '  <div class="d-flex align-items-center mb-1">';
	        msgHtml += '    <img src="' + profileImg + '" class="user-avatar-sm" style="width:28px; height:28px; border-radius:50%; object-fit: cover; margin-right: 8px;" onerror="this.onerror=null; this.src=\'' + defaultImg + '\'">';
	        msgHtml += '    <span class="small text-muted">' + senderNm + '</span>';
	        msgHtml += '  </div>';
	    }
	    
	    msgHtml += '  <div class="bubble" style="display: block; width: fit-content; max-width: 75%; padding: 0.8rem 1.2rem; border-radius: 1rem; word-break: break-all; white-space: pre-wrap; background-color: ' + bgColor + '; color: ' + textColor + '; text-align: left; ' + (isMine ? 'border-top-right-radius: 0;' : 'border-top-left-radius: 0;') + '">';
	    msgHtml +=      msgText; 
	    msgHtml += '  </div>';
	    msgHtml += '  <span class="small text-muted mt-1" style="font-size: 0.7rem;">' + displayTime + '</span>';
	    msgHtml += '</div>';
	    
	    if (msgArea) {
	        msgArea.insertAdjacentHTML('beforeend', msgHtml);
	        msgArea.scrollTop = msgArea.scrollHeight; 
	    }
	}

    let selectedEmps = new Set(); 

 	// 1. 모달 열기 함수 (이벤트 연결 로직 추가)
    function openInviteModal() {
        selectedEmps.clear();
        updateInviteChips(); 
        
        const searchInput = document.getElementById('empSearchInput');
        if(searchInput) searchInput.value = ''; // 모달 열 때 검색어 초기화
        
        inviteModalObj = new bootstrap.Modal(document.getElementById('inviteModal'));
        
        fetch(CP + '/chat-api/inviteList?chatRmNo=' + chatRmNo)
            .then(res => res.json())
            .then(data => {
                renderEmpList(data);
                inviteModalObj.show();
                
                // [중요] 모달이 화면에 나타난 후(shown.bs.modal) 이벤트를 강제로 연결
                const modalEl = document.getElementById('inviteModal');
                modalEl.addEventListener('shown.bs.modal', function () {
                    const input = document.getElementById('empSearchInput');
                    input.focus();
                    
                    // 기존 리스너 제거 후 다시 등록하여 중복 방지
                    input.removeEventListener('input', filterEmpList);
                    input.addEventListener('input', filterEmpList);
                }, { once: true }); // 딱 한 번만 실행
            });
    }

    function renderEmpList(list) {
        const area = document.getElementById('empListArea');
        area.innerHTML = '';
        
        // 현재 채팅방에 이미 있는 사람들의 ID 목록 (공백 제거 필수)
        const currentMemberIds = Array.from(document.querySelectorAll('#memberListArea .user-item'))
                                      .map(li => String(li.getAttribute('data-emp-id')).trim());

        if(!list || list.length === 0) {
            area.innerHTML = '<div class="text-center py-4 text-muted">초대할 수 있는 사원이 없습니다.</div>';
            return;
        }

        let lastDeptName = "";

        list.forEach(emp => {
            const empIdStr = String(emp.empId).trim();
            const deptName = (emp.deptNm || '소속 없음').trim(); 
            const position = (emp.empJbgd || '사원').trim();
            const empName = (emp.empNm || '').trim();

            // 1. 부서 헤더 생성
            if (lastDeptName !== deptName) {
                const header = document.createElement('div');
                header.className = 'dept-header'; 
                header.setAttribute('data-dept', deptName);
                header.innerHTML = '<i class="bx bx-group" style="margin-right:5px;"></i>' +
                                   '<span>' + deptName + '</span>' +
                                   '<span class="material-icons toggle-icon" style="margin-left: auto; font-size: 1.2rem; transition: transform 0.3s;">expand_more</span>';
                
                header.onclick = function() {
                    this.classList.toggle('collapsed');
                    const isCollapsed = this.classList.contains('collapsed');
                    const icon = this.querySelector('.toggle-icon');
                    if (icon) icon.style.transform = isCollapsed ? 'rotate(-90deg)' : 'rotate(0deg)';
                    
                    // 현재 부서 그룹 아이템들 토글
                    const targetItems = document.querySelectorAll('.emp-invite-item[data-dept-group="' + deptName + '"]');
                    const keyword = document.getElementById('empSearchInput').value.toLowerCase().trim();

                    targetItems.forEach(item => {
                        if (isCollapsed) {
                            item.style.setProperty('display', 'none', 'important');
                        } else {
                            // 펼칠 때 검색어와 매칭되는지 확인 후 표시
                            const text = item.innerText.toLowerCase();
                            item.style.display = text.indexOf(keyword) !== -1 ? 'flex' : 'none';
                        }
                    });
                };
                area.appendChild(header);
                lastDeptName = deptName;
            }

            // 2. 사원 아이템 생성
            const isJoinedValue = String(emp.isJoined || '').toUpperCase();
            const isAlreadyJoined = (isJoinedValue === 'Y' || isJoinedValue === 'TRUE' || currentMemberIds.includes(empIdStr)); 

            const item = document.createElement('div');
            item.className = 'd-flex align-items-center p-3 mb-0 emp-invite-item border-bottom';
            item.setAttribute('data-dept-group', deptName); 
            
            // 검색을 위해 이름과 부서를 텍스트로 포함
            let itemInner = '';
            itemInner += '<div class="me-3">';
            itemInner += '  <input type="checkbox" class="form-check-input" value="' + empIdStr + '" data-nm="' + empName + '" ' + (isAlreadyJoined ? 'checked disabled' : '') + '>';
            itemInner += '</div>';
            
            const defaultImg = CP + '/resources/img/default-avatar.png';
            const profileImg = emp.empProfile ? (CP + '/profile/' + emp.empProfile) : defaultImg;
            itemInner += '<img src="' + profileImg + '" class="user-avatar" style="width:35px; height:35px; border-radius:50%; margin-right:10px;" onerror="this.onerror=null; this.src=\'' + defaultImg + '\'">';

            itemInner += '<div class="flex-grow-1">';
            itemInner += '  <span class="fw-bold search-name">' + empName + '</span>';
            itemInner += '  <span class="badge bg-light text-dark ms-2 search-dept" style="font-size: 0.75rem;">' + deptName + '</span>';
            itemInner += '  <div class="small text-muted">사번: ' + empIdStr + '</div>';
            itemInner += '</div>';
            
            item.innerHTML = itemInner;

            if(!isAlreadyJoined) {
                item.onclick = (e) => {
                    const ck = item.querySelector('input');
                    if(e.target !== ck) ck.checked = !ck.checked;
                    if(ck.checked) {
                        selectedEmps.add(ck.value);
                        item.style.backgroundColor = '#f0f2ff';
                    } else {
                        selectedEmps.delete(ck.value);
                        item.style.backgroundColor = 'transparent';
                    }
                    updateInviteChips();
                };
            } else {
                item.style.opacity = '0.6';
                item.style.backgroundColor = '#f9f9f9';
            }
            area.appendChild(item);
        });
    }

    function updateInviteChips() {
        const container = document.getElementById('selectedInviteContainer');
        if(!container) return;

        container.innerHTML = '';
        if(selectedEmps.size === 0) {
            container.innerHTML = '<span class="text-muted small my-auto ps-2">선택된 인원이 없습니다.</span>';
            return;
        }

        selectedEmps.forEach(empId => {
            const ck = document.querySelector('.emp-invite-item input[value="' + empId + '"]');
            const empNm = ck ? ck.getAttribute('data-nm') : "사용자";

            const chip = document.createElement('div');
            chip.style.cssText = "display:inline-flex; align-items:center; background:#e7e7ff; color:#696cff; padding:4px 10px; border-radius:50px; font-size:0.8rem; font-weight:600; margin:2px;";
            // 여기도 백틱 대신 결합 사용
            chip.innerHTML = empNm + ' <span class="material-icons ms-1" style="font-size:1rem; cursor:pointer; color:#ff3e1d;" onclick="removeChip(\'' + empId + '\')">cancel</span>';
            container.appendChild(chip);
        });
    }

    window.removeChip = function(empId) {
        selectedEmps.delete(empId);
        const ck = document.querySelector('.emp-invite-item input[value="' + empId + '"]');
        if(ck) ck.checked = false;
        updateInviteChips();
    };

 // 2. 검색 필터링 함수 (innerText 방식)
    function filterEmpList() {
        // 이벤트 객체에서 가져오거나 직접 가져오기
        const input = document.getElementById('empSearchInput');
        const keyword = input.value.toLowerCase().trim();
        const items = document.querySelectorAll('.emp-invite-item');
        const headers = document.querySelectorAll('.dept-header');

        console.log("필터링 시작: ", keyword); // 브라우저 F12 콘솔에서 찍히는지 확인 필수!

        items.forEach(item => {
            // 이름, 부서, 사번이 들어있는 전체 텍스트를 가져와서 비교
            const fullText = item.innerText.toLowerCase();
            
            if (fullText.includes(keyword)) {
                item.style.setProperty('display', 'flex', 'important');
            } else {
                item.style.setProperty('display', 'none', 'important');
            }
        });

        // 부서 헤더 처리
        headers.forEach(header => {
            const dName = header.getAttribute('data-dept');
            const deptEmps = document.querySelectorAll('.emp-invite-item[data-dept-group="' + dName + '"]');
            const hasVisible = Array.from(deptEmps).some(el => el.style.display !== 'none');

            header.style.display = hasVisible ? 'flex' : 'none';

            if (keyword !== "" && hasVisible) {
                header.classList.remove('collapsed');
                const icon = header.querySelector('.toggle-icon');
                if (icon) icon.style.transform = 'rotate(0deg)';
            }
        });
    }

    function submitInvite() {
        if(selectedEmps.size === 0) { alert("초대할 사원을 선택해주세요."); return; }

        fetch(CP + '/chat-api/invite', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                chatRmNo: parseInt(chatRmNo),
                inviteIdList: Array.from(selectedEmps).map(Number)
            })
        }).then(res => {
            if(res.ok) {
                alert("초대되었습니다.");
                location.reload(); 
            }
        });
    }

    function editTitle() {
        if (currentLoginId !== roomOwnerId) { alert("방장만 수정 권한이 있습니다."); return; }
        const currentTitle = "${room.chatRmTtl}";
        const newTitle = prompt("변경할 방 제목을 입력하세요", currentTitle);
        if (newTitle && newTitle.trim() !== "" && newTitle !== currentTitle) {
            fetch(CP + '/chat/updateTitle', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ chatRmNo: parseInt(chatRmNo), chatRmTtl: newTitle.trim() })
            }).then(res => { if (res.ok) location.reload(); });
        }
    }

    function leaveRoom() {
        // 메시지 통일: 방장이라고 해서 방이 삭제된다는 겁을 주지 않습니다.
        const msg = "채팅방에서 나가시겠습니까?\n(나간 후에는 이전 대화 내용을 볼 수 없습니다.)";
        
        if(confirm(msg)) {
            // 경로를 /chat/delete(방삭제)가 아닌 /chat/leave(나가기) 같은 전용 엔드포인트로 보냅니다.
            // 만약 서버에 leave가 없다면, 기존 delete 로직이 '참여자 테이블'에서만 삭제하는지 확인해야 합니다.
            fetch(CP + '/chat/leave', { 
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ 
                    chatRmNo: parseInt(chatRmNo),
                    empId: loginUserId // 누가 나가는지 명확히 전달
                })
            }).then(res => { 
                if (res.ok) {
                    alert("퇴장하였습니다.");
                    location.href = CP + "/chat/list"; 
                } else {
                    alert("나가기 처리 중 오류가 발생했습니다.");
                }
            });
        }
    }
	
    $(document).ready(function() {
        const contextPath = "${pageContext.request.contextPath}" === "/" ? "" : "${pageContext.request.contextPath}";
        const urlParams = new URLSearchParams(window.location.search);
        const currentRmNo = urlParams.get('chatRmNo'); 
        const myEmpId = "${loginId}"; 

        if (currentRmNo && myEmpId) {
            axios.post(contextPath + "/alarm/updateChatStts", { 
                chatRmNo: currentRmNo,
                almRcvrNo: myEmpId,
                updateStts: "readChatAlarm"
            })
            .then(res => {
                console.log("✅ 채팅방 입장 - 알람 읽음 처리 성공");
                if (typeof loadInitialAlarms === 'function') {
                    loadInitialAlarms();
                } else if (parent && typeof parent.loadInitialAlarms === 'function') {
                    parent.loadInitialAlarms();
                }
            })
            .catch(err => {
                console.error("❌ 알람 업데이트 실패:", err);
            });
        }
    });
    
    window.onload = () => {
        if (msgArea) msgArea.scrollTop = msgArea.scrollHeight;
        const input = document.getElementById('chatInput');
        if (input) input.focus();
    };
</script>