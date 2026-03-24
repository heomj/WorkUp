<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="./commonAI.jsp" %>

<!doctype html>
<html lang="ko" data-bs-theme="light">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <title>WORK UP 그룹웨어 - 전문가 모드</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/main.css">
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

	<!--  임시 파비콘 -->
	<link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/images/test.png">


</head>
<body>

    <jsp:include page="/WEB-INF/common/sidebar.jsp" />

    <div class="main-wrapper" id="main-wrapper">
        
        <jsp:include page="/WEB-INF/common/header.jsp" />

        <main class="page-content">
            <div id="content-area">
                <jsp:include page="/WEB-INF/views/${contentPage}.jsp" />
            </div>
        </main>

    </div>
    <input type="hidden" id="currentLoginEmpId" value="<sec:authentication property='principal.username'/>">

<div id="chatMainWrapper" style="display:none; position:fixed; bottom:30px; right:30px; width:450px; height:600px; z-index:9999; background:#fff; border-radius:15px; box-shadow: 0 5px 25px rgba(0,0,0,0.2); border:1px solid #ddd; flex-direction: row; min-width:350px; min-height:400px; overflow:hidden;">
    
    <div class="resizer resizer-t" style="position:absolute; top:0; left:0; width:100%; height:7px; cursor:ns-resize; z-index:10010;"></div>
    <div class="resizer resizer-b" style="position:absolute; bottom:0; left:0; width:100%; height:7px; cursor:ns-resize; z-index:10010;"></div>
    <div class="resizer resizer-l" style="position:absolute; top:0; left:0; width:7px; height:100%; cursor:ew-resize; z-index:10010;"></div>
    <div class="resizer resizer-r" style="position:absolute; top:0; right:0; width:7px; height:100%; cursor:ew-resize; z-index:10010;"></div>
    <div class="resizer resizer-tl" style="position:absolute; top:0; left:0; width:12px; height:12px; cursor:nwse-resize; z-index:10011;"></div>
    <div class="resizer resizer-tr" style="position:absolute; top:0; right:0; width:12px; height:12px; cursor:nesw-resize; z-index:10011;"></div>
    <div class="resizer resizer-bl" style="position:absolute; bottom:0; left:0; width:12px; height:12px; cursor:nesw-resize; z-index:10011;"></div>
    <div class="resizer resizer-br" style="position:absolute; bottom:0; right:0; width:15px; height:15px; cursor:nwse-resize; z-index:10011; background: linear-gradient(135deg, transparent 50%, #696cff 50%); border-radius: 0 0 15px 0;"></div>

    <div id="chatSideNav" style="width:60px; background:#f2f2f2; display:flex; flex-direction:column; align-items:center; padding-top:20px; border-right:1px solid #e5e5e5; flex-shrink: 0;">
        <div onclick="switchChatTab('emp')" id="tabEmp" style="margin-bottom:25px; cursor:pointer; color:#696cff; text-align:center;">
            <span class="material-icons" style="font-size:26px;">person</span>
            <div style="font-size:10px;">사원</div>
        </div>
        <div onclick="switchChatTab('room')" id="tabRoom" style="cursor:pointer; color:#888; text-align:center;">
            <span class="material-icons" style="font-size:26px;">chat</span>
            <div style="font-size:10px;">채팅</div>
        </div>
    </div>

    <div style="flex:1; display:flex; flex-direction:column; position:relative; overflow:hidden;">
        <div id="chatMainHeader" style="cursor:move; background:#696cff; color:#fff; padding:12px 15px; display:flex; justify-content:space-between; align-items:center; flex-shrink: 0;">
            <span style="font-weight:600; font-size:13px;">WORK UP 메신저</span>
            <div style="cursor:pointer;" onclick="closeChatMain()">
                <span class="material-icons" style="font-size:18px;">close</span>
            </div>
        </div>

        <div id="chatSearchWrapper" style="padding: 10px; background: #fff; flex-shrink: 0;">
            <div style="position: relative; display: flex; align-items: center;">
                <i class='bx bx-search' style="position: absolute; left: 10px; color: #696cff;"></i>
                <input type="text" id="modalEmpSearch" style="width: 100%; padding: 6px 10px 6px 30px; border-radius: 5px; border: 1px solid #eee; background:#f5f5f5; font-size: 13px; outline: none;" placeholder="이름 또는 부서 검색..." oninput="filterModalEmpList()">
            </div>
        </div>

        <div id="chatMainContent" style="flex:1; overflow-y:auto; background:#fff; padding-bottom:10px;"></div>

        <div id="chatRoomArea" style="display:none; flex-direction:column; position:absolute; top:0; left:0; width:100%; height:100%; background:#fff; z-index:10005;">
            
            <input type="file" id="chatFileIdx" style="display:none;" multiple onchange="handleFileSelect(this)">
            <div id="dropZoneOverlay" style="display:none; position:absolute; top:0; left:0; width:100%; height:100%; background:rgba(105, 108, 255, 0.2); border:2px dashed #696cff; z-index:10030; align-items:center; justify-content:center; border-radius:15px;">
                <div style="background:#fff; padding:20px; border-radius:10px; box-shadow:0 4px 15px rgba(0,0,0,0.1); display:flex; flex-direction:column; align-items:center; gap:10px;">
                    <i class='bx bxs-cloud-upload' style="font-size: 40px; color:#696cff;"></i>
                    <span style="color:#696cff; font-weight:bold; font-size:14px;">파일을 여기에 놓으세요</span>
                </div>
            </div>

            <div style="padding:10px 15px; border-bottom:1px solid #eee; display:flex; align-items:center; justify-content:space-between; background:#696cff; color:#fff; flex-shrink:0; min-height:50px;">
                <div style="display:flex; align-items:center; flex:1; overflow:hidden;">
                    <div onclick="backToLastTab()" style="cursor:pointer; margin-right:10px; display:flex; align-items:center;">
                        <i class='bx bx-chevron-left' style="font-size:24px; color:#fff !important;"></i>
                    </div>
                    <div id="chatRoomTitle" style="font-weight:bold; font-size:14px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; color:#fff !important;">채팅방 이름</div>
                </div>
                <div onclick="backToLastTab()" style="cursor:pointer; display:flex; align-items:center; justify-content:center;">
                    <i class='bx bx-x' style="font-size:24px; color:#fff !important;"></i>
                </div>
            </div>

            <div id="chatContentWrapper" style="flex:1; position:relative; overflow:hidden; display:flex;">
                <div id="chatRoomSideBar" style="width: 60px; background: #f2f2f2; display:flex; flex-direction:column; justify-content:space-between; align-items:center; padding: 20px 0; border-right:1px solid #e5e5e5; flex-shrink: 0; z-index: 10010;">
                    <div onclick="openInviteModalInMessenger()" title="초대하기" style="cursor:pointer; color:#696cff; text-align:center;">
                        <i class='bx bx-user-plus' style="font-size: 26px;"></i>
                        <div style="font-size:10px; font-weight:bold; margin-top:2px;">초대</div>
                    </div>
                    <div onclick="leaveChatRoom()" title="채팅방 나가기" style="cursor:pointer; color:#888; text-align:center;">
                        <i class='bx bx-log-out' style="font-size: 24px;"></i>
                        <div style="font-size:10px; margin-top:2px;">나가기</div>
                    </div>
                </div>

                <div id="chatMsgArea" style="flex:1; overflow-y:auto; padding:15px; display:flex; flex-direction:column; gap:12px; background:#fdfdfd; width:100%;"></div>

                <div id="miniParticipantSidebar" 
				     style="display:none; position:absolute; top:0; right:0; width:180px; height:100%; background:#fff; border-left:1px solid #eee; z-index:10050; box-shadow:-3px 0 10px rgba(0,0,0,0.1); flex-direction: column;">
				    
				    <div style="padding:12px; font-size:12px; font-weight:bold; border-bottom:1px solid #f5f5f5; display:flex; justify-content:space-between; align-items:center; background:#f8f9ff; color:#333; height:45px; flex-shrink:0;">
				        참여자 (<span id="miniParticipantCount">0</span>)
				        <i class='bx bx-x' style="cursor:pointer; font-size:20px; color:#666;" onclick="toggleParticipantSidebar()"></i>
				    </div>
				    
				    <div id="miniParticipantList" style="flex: 1; overflow-y: auto; background: #fff; display: block !important;">
				        </div>
				</div>
            </div>

            <div id="filePreviewContainer" style="background: #fff; max-height: 120px; overflow-y: auto; padding: 0 15px; display:none; border-top:1px solid #f8f8f8;">
                <div id="filePreviewArea" style="padding: 10px 0; display:flex; flex-direction:column; gap:8px;"></div>
            </div>

            <form id="chatMessageForm" style="padding:10px 15px; border-top:1px solid #eee; display:flex; align-items:center; gap:8px; background:#fff; flex-shrink:0;">
                <div id="chatMessageInput" 
                     contenteditable="true" 
                     placeholder="메시지를 입력하세요..." 
                     style="flex:1; border:1px solid #eee; border-radius:20px; padding:8px 15px; font-size:13px; outline:none; background:#f9f9f9; min-height:36px; max-height:100px; overflow-y:auto; word-break:break-all;">
                </div>
                
                <div onclick="document.getElementById('chatFileIdx').click()" title="파일 첨부" style="cursor:pointer; display:flex; align-items:center; justify-content:center; width:32px; height:32px;">
                    <i class='bx bx-paperclip' style="font-size: 22px; color: #696cff;"></i>
                </div>

                <button type="submit" style="background:#696cff; color:#fff; border:none; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; cursor:pointer;">
                    <i class='bx bxs-send' style="font-size:16px; color:#fff;"></i>
                </button>
            </form>
        </div>

        <div id="chatActionMenu" style="display:none; position:absolute; bottom:0; left:0; width:100%; background:#fff; border-top:1px solid #696cff; box-shadow:0 -3px 10px rgba(0,0,0,0.1); z-index:10002;">
            <div style="padding:12px; display:flex; flex-direction:column; gap:8px;">
                <div id="selectedEmpInfo" style="font-size:11px; font-weight:bold; color:#666; text-align:center;"></div>
                <div class="d-flex gap-2">
                    <button onclick="startDirectChat()" style="flex:1; border:1px solid #696cff; background:#fff; color:#696cff; border-radius:4px; padding:6px; font-size:12px; display:flex; align-items:center; justify-content:center; gap:4px; cursor:pointer;">
                        <i class='bx bx-message-rounded-dots'></i> 1:1 채팅
                    </button>
                    <button onclick="startGroupChat()" style="flex:1; border:1px solid #8592a3; background:#fff; color:#8592a3; border-radius:4px; padding:6px; font-size:12px; display:flex; align-items:center; justify-content:center; gap:4px; cursor:pointer;">
                        <i class='bx bx-user-plus'></i> 그룹 채팅
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="groupChatModal" class="modal fade" tabindex="-1" aria-hidden="true" style="z-index: 10050;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" style="font-weight:bold;">그룹 채팅방 생성</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label" style="font-size:13px; font-weight:bold;">채팅방 이름</label>
                    <input type="text" id="groupChatTitle" class="form-control" placeholder="채팅방 이름을 입력하세요">
                </div>
                <div id="selectedEmployees" class="d-flex flex-wrap gap-2 mb-3" style="min-height: 40px; border-bottom: 1px solid #eee; padding-bottom: 10px;"></div>
                <div class="mb-3">
                    <input type="text" id="empSearchInput" class="form-control" placeholder="사원 이름 검색..." onkeyup="filterGroupEmployeeList()">
                </div>
                <div id="modalEmpListForGroup" style="max-height: 250px; overflow-y: auto; border: 1px solid #f1f1f1; border-radius: 4px;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" onclick="createNewGroupChat()">방 생성</button>
            </div>
        </div>
    </div>
</div>
	
	
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <style>
            body.dragging {
                user-select: none;
                -webkit-user-select: none; /* Safari용 */
                -moz-user-select: none;    /* Firefox용 */
            }

            /* AI 메뉴 자체도 텍스트 선택이 안 되게 하면 깔끔합니다 */
            #menuWrapper {
                user-select: none;
                -webkit-user-select: none;
            }

            /* 기본 상태: 손가락 모양 (클릭 가능하다는 신호) */
            #menuWrapper, .main-btn {
                cursor: pointer;
            }

            /* 마우스를 꾹 눌렀을 때: 잡는 모양 (움직일 수 있다는 신호) */
            #menuWrapper:active {
                cursor: grabbing !important;
            }

            /* 특정 버튼(아이콘) 위에 올렸을 때만 강조하고 싶다면 */
            .main-btn:hover {
                filter: brightness(1.1); /* 살짝 밝게 */
                transform: scale(1.05);  /* 살짝 크게 */
                transition: all 0.2s;

            }
            /* 채팅창 전체를 감싸는 모달 컨텐츠 또는 div */
			#chatMainContainer { 
			    width: 350px;  /* 초기 너비 */
			    height: 600px; /* 초기 높이 */
			    min-width: 300px; /* 최소 너비 제한 */
			    min-height: 400px; /* 최소 높이 제한 */
			    max-width: 90vw;  /* 최대 너비 제한 */
			    
			    /* 핵심 속성 */
			    overflow: hidden; /* 내부 요소가 넘치지 않게 */
			    //resize: both;    /* 가로, 세로 모두 조절 가능 (horizontal 또는 vertical만 가능) */
			}
			/* 채팅창 전체 컨테이너에 적용 */
			.chat-window-popup {
			    min-width: 300px;
			    min-height: 400px;
			    max-width: 800px;
			    max-height: 900px;
			    position: fixed;
			    display: flex;
			    flex-direction: column;
			    overflow: hidden; /* 핸들이 튀어나가지 않게 */
			}
			
			/* 크기 조절용 핸들 스타일 */
			.resizer {
			    width: 15px;
			    height: 15px;
			    background: transparent;
			    position: absolute;
			    right: 0;
			    bottom: 0;
			    cursor: nwse-resize; /* 대각선 커서 */
			    z-index: 10001;
			}
			#chatSideNav {
			    width: 60px;
			    flex-shrink: 0; /* 창이 작아져도 이 60px은 절대 줄어들지 않음 */
			    height: 100%;
			    background: #f2f2f2;
			}
			#chatMainContent {
			    flex: 1; /* 남은 모든 공간을 꽉 채움 */
			    overflow-y: auto; /* 내용이 많아지면 스크롤 생성 */
			}
			/* 이미 참여 중인 사원 아이템 스타일 */
			.emp-invite-item.already-joined {
			    opacity: 0.6; /* 흐릿하게 */
			    background-color: #f9f9f9 !important;
			    cursor: not-allowed !important;
			}
			
			/* 이미 참여 중인 사원의 프로필 이미지를 흑백으로 */
			.emp-invite-item.already-joined img {
			    filter: grayscale(100%);
			}
			
			/* 참여 중 텍스트 배지 스타일 */
			.badge-joined {
			    font-size: 0.7rem;
			    background-color: #ebeef0;
			    color: #8592a3;
			    padding: 2px 6px;
			    border-radius: 4px;
			    margin-left: 5px;
			}
			.chat-badge-1to1 {
			    background-color: #e3f2fd;
			    color: #0d47a1;
			    border: 1px solid #bbdefb;
			    padding: 2px 6px;
			    border-radius: 10px;
			    font-size: 11px;
			    font-weight: bold;
			}
			
			.chat-badge-group {
			    background-color: #f3e5f5;
			    color: #4a148c;
			    border: 1px solid #e1bee7;
			    padding: 2px 6px;
			    border-radius: 10px;
			    font-size: 11px;
			    font-weight: bold;
			}
			#chatMessageInput:empty:before {
		        content: attr(placeholder);
		        color: #999;
		        display: inline-block;
		        cursor: text;
		    }
		    /* 이미지가 들어있을 때는 placeholder를 숨김 */
			#chatMessageInput:focus:before {
			    content: "";
			}
		    .pasted-image {
		        max-width: 100px;
		        max-height: 100px;
		        border-radius: 8px;
		        margin: 5px;
		        border: 1px solid #ddd;
		    }
		    .chat-img-render {
			    max-width: 250px;
			    height: auto;
			    border-radius: 10px;
			    margin-top: 5px;
			    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
			}
        </style>
        
        
        <script type="text/javascript">
	        document.addEventListener("DOMContentLoaded", function() {
	            const menuWrapper = document.getElementById('menuWrapper');
	            if (!menuWrapper) return;
	
	            let isDragging = false;
	            let isActuallyDragged = false; // 실제로 움직였는지 체크하는 변수
	            let offset = { x: 0, y: 0 };
	
	            // 1. 위치 불러오기 (기존 코드 동일)
	            const savedX = sessionStorage.getItem('aiPosX');
	            const savedY = sessionStorage.getItem('aiPosY');
	            if (savedX && savedY) {
	                menuWrapper.style.left = savedX + 'px';
	                menuWrapper.style.top = savedY + 'px';
	            }
	
	            menuWrapper.addEventListener('mousedown', function(e) {
	                isDragging = true;
	                isActuallyDragged = false; // 누를 때는 일단 false
	                document.body.classList.add('dragging');
	
	                offset.x = e.clientX - menuWrapper.getBoundingClientRect().left;
	                offset.y = e.clientY - menuWrapper.getBoundingClientRect().top;
	                // 마우스 커서를 '잡기' 모양으로 변경
	                menuWrapper.style.cursor = 'grabbing';
	            });
	
	            document.addEventListener('mousemove', function(e) {
	                if (!isDragging) return;
	
	                    isActuallyDragged = true;
	
	                    // 계산된 좌표
	                    let x = e.clientX - offset.x;
	                    let y = e.clientY - offset.y;
	
	                    // 화면 범위 제한 로직 추가
	                    const minX = 0;
	                    const minY = 0;
	                    const maxX = window.innerWidth - menuWrapper.offsetWidth;
	                    const maxY = window.innerHeight - menuWrapper.offsetHeight;
	
	                    // 범위를 벗어나지 않게 보정
	                    if (x < minX) x = minX;
	                    if (x > maxX) x = maxX;
	                    if (y < minY) y = minY;
	                    if (y > maxY) y = maxY;
	
	                    menuWrapper.style.left = x + 'px';
	                    menuWrapper.style.top = y + 'px';
	            });
	
	            document.addEventListener('mouseup', function(e) {
	                if (isDragging) {
	                	sessionStorage.setItem('aiPosX', parseInt(menuWrapper.style.left));
	                	sessionStorage.setItem('aiPosY', parseInt(menuWrapper.style.top));
	
	                    // 만약 드래그를 했다면, 클릭 이벤트가 발생하는 것을 막기 위해 캡처링 단계에서 제어
	                    if (isActuallyDragged) {
	                        // 이 부분이 핵심: 드래그가 끝날 때 클릭 이벤트가 전파되는 걸 한 번 차단합니다.
	                        window.addEventListener('click', captureClick, true);
	                    }
	
	                    isDragging = false;
	                    document.body.classList.remove('dragging');
	                }
	            });
	
	            // 드래그 후 발생하는 클릭을 무시하는 함수
	            function captureClick(e) {
	                e.stopPropagation(); // 이벤트 전파 막기
	                e.preventDefault();  // 기본 동작 막기
	                window.removeEventListener('click', captureClick, true); // 한 번만 막고 바로 제거
	            }
	        });
        </script>
        
        
        
		
		<script type="text/javascript">
		console.log("🚀 채팅 스크립트 로드 시도 중...");
		window.lastProcessedMsgId = null;
		/**
         * 11. 메시지 렌더링 (최종본)
		 * 메시지를 받았을 때 화면에 그려주는 함수
         */
         window.appendMessengerMessage = function(chat, targetAreaId) {
        	    // 1. 타겟 영역 확인
        	    var msgArea = document.getElementById(targetAreaId);
        	    if (!msgArea) return; 

        	    // 데이터 파싱
        	    var data = (typeof chat === 'string') ? JSON.parse(chat) : chat;
        	    
        	    // 데이터 정보 추출 (대소문자 모두 대응)
        	    var msgNo = data.chatLogNo || data.CHAT_LOG_NO;
        	    var content = data.chatCn || data.CHAT_CN || "";
        	    var chatType = (data.chatType || data.CHAT_TYPE || "TEXT").toUpperCase(); 
        	    var senderId = String(data.empId || data.EMP_ID || "");
        	    
        	    // 🌟 [핵심 수정: 우선순위 변경] 🌟
        	    // 현재 자바 백엔드가 상세 PK(FILE_DTL_ID)를 원하므로, DETAIL ID가 있다면 이를 최우선으로 가져옵니다.
        	    var fileDtlId = data.fileDtlId || data.FILE_DTL_ID || data.fileId || data.FILE_ID;
        	    var fileName = data.fileName || data.FILE_NAME || data.fileDtlONm || data.FILE_DTL_O_NM || "";
        	    
        	    if (chatType === 'IMAGE') {
        	        fileName = "이미지.png"; 
        	    } else if (!fileName || fileName.trim() === "") {
        	        fileName = (fileDtlId) ? ("첨부파일_" + fileDtlId) : "첨부파일";
        	    }

        	    if (msgNo && msgArea.querySelector('[data-msg-no="' + msgNo + '"]')) return;

        	    // 2. [시스템 메시지 처리] - 기존 동일
        	    if (content && (content.includes("님이") || content.includes("초대") || content.includes("참여"))) {
        	        var systemHtml = '<div data-msg-no="' + msgNo + '" style="width: 100%; display: flex; justify-content: center; margin: 20px 0; clear: both;">' +
        	                         '<div style="background-color: #f1f2f6; color: #666; padding: 6px 16px; border-radius: 20px; font-size: 12px; border: 1px solid #e0e0e0;">' + content + '</div></div>';
        	        msgArea.insertAdjacentHTML('beforeend', systemHtml);
        	        msgArea.scrollTop = msgArea.scrollHeight;
        	        return; 
        	    }

        	    // 3. 프로필 및 경로 설정
        	    var host = window.location.origin;
        	    var currentCP = (window.CP && window.CP !== "/" && window.CP.length < 50) ? window.CP : "";
        	    var baseUrl = host + currentCP;

        	    var defaultImg = baseUrl + '/resources/img/default-avatar.png'; 
        	    var senderImg = data.empProfile || data.EMP_PROFILE;
        	    var profileImg = defaultImg;

        	    if (senderImg && String(senderImg).trim() !== '' && senderImg !== 'null') {
        	        if (String(senderImg).includes('fileName=')) senderImg = senderImg.split('fileName=')[1].split('&')[0];
        	        profileImg = String(senderImg).startsWith('http') ? senderImg : (baseUrl + '/profile/' + senderImg);
        	    }

        	    var senderNm = data.empNm || data.EMP_NM || "사용자";
        	    var myId = String(window.loginUserId); 
        	    var isMe = (senderId === myId && myId !== "guest" && myId !== "");

        	    // 4. HTML 생성 시작
        	    var html = '<div data-msg-no="' + (msgNo || '') + '" style="width: 100%; display: flex; flex-direction: column; align-items: ' + (isMe ? 'flex-end' : 'flex-start') + '; margin-bottom: 15px; clear: both;">';
        	    
        	    if (!isMe) {
        	        html += '<div style="display: flex; align-items: center; margin-bottom: 4px;">' +
        	                '<img src="' + profileImg + '" style="width: 26px; height: 26px; border-radius: 50%; margin-right: 7px; object-fit: cover; border: 1px solid #eee;" ' +
        	                'onerror="this.onerror=null; this.src=\'' + defaultImg + '\';">' +
        	                '<span style="font-size: 11px; font-weight: bold; color: #555;">' + senderNm + '</span></div>';
        	    }

        	    html += '<div style="display: flex; flex-direction: ' + (isMe ? 'row-reverse' : 'row') + '; align-items: flex-end; max-width: 80%;">';
        	    
        	    // --- [파일 판별 로직] ---
        	    if (chatType === 'IMAGE' || content.startsWith('data:image/')) {
        	        html += '<div style="background-color: transparent; padding: 0; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.1); border: 1px solid #eee;">' +
        	                '<a href="' + content + '" download="' + fileName + '">' + 
        	                '<img src="' + content + '" style="max-width: 250px; max-height: 350px; display: block; cursor: pointer; border-radius: 10px;" onerror="this.onerror=null; this.style.display=\'none\';">' +
        	                '</a></div>';
        	    } 
        	    else if (chatType === 'FILE' || (fileDtlId && fileDtlId !== 'null' && fileDtlId !== 0)) {
        	        var extension = fileName.includes('.') ? fileName.split('.').pop().toLowerCase() : "";
        	        var iconClass = 'bxs-file'; var iconColor = '#696cff';
        	        if (['xlsx', 'xls', 'csv'].includes(extension)) { iconClass = 'bxs-file-export'; iconColor = '#2d8c3c'; }
        	        else if (['pdf'].includes(extension)) { iconClass = 'bxs-file-pdf'; iconColor = '#e53935'; }

        	        // 🌟 [수정 포인트] 자바 컨트롤러 규격에 정확히 맞춘 주소와 파라미터 매칭
        	        // 자바: (@RequestParam("fileDtlId") Long fileDtlId)
        	        var downUrl = baseUrl + '/download?fileDtlId=' + fileDtlId;
        	        
        	        html += '<div onclick="location.href=\'' + downUrl + '\'" style="cursor:pointer; background-color: #ffffff; border: 2px solid ' + iconColor + '; padding: 12px 16px; border-radius: 12px; display: flex; align-items: center; min-width: 220px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">' +
        	                '<i class="bx ' + iconClass + '" style="font-size: 34px; color: ' + iconColor + '; margin-right: 12px;"></i>' +
        	                '<div style="flex:1; overflow:hidden;">' +
        	                '<div style="font-size: 13.5px; font-weight: bold; color: #333; text-overflow:ellipsis; white-space:nowrap; overflow:hidden;">' + fileName + '</div>' +
        	                '<div style="font-size: 11px; color: #8e94a9; margin-top:2px;">클릭하여 다운로드</div></div></div>';
        	    }
        	    else {
        	        html += '<div style="background-color: ' + (isMe ? '#696cff' : '#f1f2f6') + ' !important; color: ' + (isMe ? '#ffffff' : '#333333') + ' !important; padding: 10px 14px; border-radius: ' + (isMe ? '15px 15px 0 15px' : '0 15px 15px 15px') + '; font-size: 14px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); word-break: break-all; white-space: pre-wrap;">' + content + '</div>';
        	    }

        	    html += '</div></div>';
        	    msgArea.insertAdjacentHTML('beforeend', html);
        	    
        	    var images = msgArea.lastElementChild.querySelectorAll('img');
        	    images.forEach(function(img) {
        	        if (img.complete) msgArea.scrollTop = msgArea.scrollHeight;
        	        else img.onload = function() { msgArea.scrollTop = msgArea.scrollHeight; };
        	    });
        	    msgArea.scrollTop = msgArea.scrollHeight;
        	};

		</script>
		
        <script>
        window.handleImgError = function(img) {
            img.onerror = null; // 무한 루프 방지
            img.src = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='35' height='35' viewBox='0 0 35 35'%3E%3Crect width='35' height='35' fill='%23eeeeee'/%3E%3Ctext x='50%25' y='50%25' dominant-baseline='middle' text-anchor='middle' font-size='10' fill='%23999'%3EEmpty%3C/text%3E%3C/svg%3E";
        };
        
        // [1] 전역 변수 선언
        let currentChatRmNo = null;
        let openChatWindows = {};    
        let isChatDragging = false;  
        let isChatResizing = false;  
        let chatOffset = { x: 0, y: 0 };
        let currentResizer = null;
        window.chatSocket = null;

        // 리사이징 초기 정보
        let startX, startY, startWidth, startHeight, startLeft, startTop;

        /* ==========================================================
           [2] 사번(UserId) 확보 로직 (중복 제거 및 최적화)
           ========================================================== */
        // 즉시 실행 함수로 loginUserId를 최대한 빨리 확보합니다.
        window.getRealUserId = function() {
		    // 1. 방금 추가한 hidden input에서 값을 가져옵니다.
		    const hiddenInput = document.getElementById('currentLoginEmpId');
		    if (hiddenInput && hiddenInput.value && hiddenInput.value !== "guest") {
		        return String(hiddenInput.value).trim();
		    }
		
		    // 2. 만약 실패했다면, 알람 로직 등에서 사용하는 전역 변수 userId를 체크합니다.
		    if (typeof userId !== 'undefined' && userId) {
		        return String(userId).trim();
		    }
		
		    return "guest"; 
		};
				
		// 위 함수를 정의한 '직후'에 바로 호출해서 값을 할당해둡니다.
		window.loginUserId = window.getRealUserId();

        // [추가 보강] 0.5초 뒤에 한 번 더 체크해서 guest라면 다시 할당  --- 세션으로 변경해보기
        $(document).ready(function() {
		    setTimeout(function() {
		        // 1. [기존 유지] 사번 인식 로직
		        if (window.loginUserId === "guest") {
		            var detectedId = (typeof userId !== 'undefined' && userId && userId !== "guest") ? String(userId) : 
		                             ("${loginMember.empId}" !== "" ? "${loginMember.empId}" : window.loginUserId);
		            if (detectedId && detectedId !== "guest") {
		                window.loginUserId = detectedId;
		                window.myAppLoginId = detectedId;
		                console.log("🚀 [인식완료] 지연 로딩 사번 확보:", window.loginUserId);
		            }
		        }
		
		        // 2. [기존 유지] 열려있던 '개별 채팅방' 복구
		        var savedRooms = JSON.parse(sessionStorage.getItem('openChatRooms') || "[]");
		        if (savedRooms.length > 0) {
		            savedRooms.forEach(function(room) {
		                if (typeof window.enterChatRoom === 'function') {
		                    window.enterChatRoom(room.rmNo, room.title);
		                }
		            });
		        }
		
		        // 3. [기존 유지] 메인 채팅창 상태 복구
		        var isChatOpen = sessionStorage.getItem('isChatOpen');
		        var mainWrapper = document.getElementById('chatMainWrapper');
		        if (isChatOpen === 'true') {
		            if (typeof window.openChatMain === 'function') {
		                window.openChatMain(); 
		                console.log("✅ [복구] 메신저 상태 복구 완료");
		            }
		        } else if (isChatOpen === null) {
		            if (mainWrapper) mainWrapper.style.display = 'none';
		            sessionStorage.setItem('isChatOpen', 'false');
		        }
		
		        // [기존 유지/수정] 이미지 미리보기 삭제 함수 (전역)
		        window.pendingImages = window.pendingImages || {};
		        window.clearImagePreview = function(rmNo) {
		            var roomNo = rmNo || 'main';
		            var previewArea = document.getElementById('pastedImagePreview_' + roomNo) || document.getElementById('pastedImagePreview');
		            var previewImg = document.getElementById('previewImg_' + roomNo) || document.getElementById('previewImg');
		            
		            if (previewArea && previewImg) {
		                previewArea.style.display = 'none';
		                previewImg.src = '';
		                delete window.pendingImages[roomNo];
		                
		                // 🌟 이미지 전송 취소 시 해당 방의 파일 대기열도 초기화
		                if (window.pendingFiles && window.pendingFiles[roomNo]) {
		                    window.pendingFiles[roomNo] = [];
		                }
		            }
		        };
		
		        // 🌟 [수정] 이미지 붙여넣기 처리 (Ctrl+V) - chatType 판별의 시작점
		        $(document).off('paste', '[contenteditable="true"]').on('paste', '[contenteditable="true"]', function(e) {
		            var targetId = this.id;
		            var rmNo = targetId.includes('_') ? targetId.split('_')[1] : 'main';
		            var orgEvent = e.originalEvent || e;
		            var items = orgEvent.clipboardData?.items;
		            if (!items) return;
		
		            for (var i = 0; i < items.length; i++) {
		                if (items[i].type.indexOf('image') !== -1) {
		                    var blob = items[i].getAsFile();
		                    if (!blob) continue;
		
		                    // 🚀 이미지를 붙여넣으면 기존 파일 대기열을 비우고 이 이미지만 담습니다.
		                    window.pendingFiles = window.pendingFiles || {};
		                    window.pendingFiles[rmNo] = [];
		
		                    // 이미지 파일 객체 생성 (확장자 명시)
		                    var tempFileName = "pasted_image_" + new Date().getTime() + ".png";
		                    var fileObj = new File([blob], tempFileName, { type: blob.type });
		
		                    // 1. 전송 대기열(pendingFiles)에 추가
		                    window.pendingFiles[rmNo].push(fileObj);
		
		                    // 2. 화면 표시용 미리보기 로직
		                    var reader = new FileReader();
		                    reader.onload = function(event) {
		                        var base64Data = event.target.result;
		                        var previewArea = document.getElementById('pastedImagePreview_' + rmNo) || document.getElementById('pastedImagePreview');
		                        var previewImg = document.getElementById('previewImg_' + rmNo) || document.getElementById('previewImg');
		                        
		                        if (previewArea && previewImg) {
		                            previewImg.src = base64Data;
		                            previewArea.style.display = 'block';
		                            // 🌟 전송 함수에서 참조할 수 있도록 전역 객체에 저장
		                            window.pendingImages[rmNo] = base64Data;
		                        }
		                    };
		                    reader.readAsDataURL(blob);
		                    
		                    e.preventDefault(); // 텍스트 중복 삽입 방지
		                }
		            }
		        });
		
		        // [기존 유지] B. 엔터키 전송 처리
		        $(document).off('keydown', '[contenteditable="true"]').on('keydown', '[contenteditable="true"]', function(e) {
		            if (e.keyCode === 13 && !e.shiftKey) {
		                e.preventDefault();
		                var targetId = this.id;
		                if (targetId.startsWith('chatInput_')) {
		                    var rmNo = targetId.split('_')[1];
		                    // 🌟 수정된 sendSpecificMessage가 이 rmNo를 받아 chatType을 결정합니다.
		                    window.sendSpecificMessage(null, rmNo);
		                } else if (targetId === 'chatMessageInput') {
		                    $('#chatMessageForm').submit();
		                }
		            }
		        });
		
		        console.log("✅ [완료] 이미지/파일 타입 판별을 위한 ready 로직 업데이트 완료");
		
		    }, 1200);
		});
        /* ==========================================================
           [3] 부가 정보 및 경로 설정
           ========================================================== */
        // 1. 경로 설정
           window.CP = "${pageContext.request.contextPath}";
           // JSP가 값을 제대로 못 뿌렸을 경우(글자수가 너무 길거나 빈값 처리
           if (window.CP === "/" || window.CP.length > 50) {
               window.CP = "";
           }

           // 2. 사용자 이름 설정
           window.loginUserNm = "${loginNm}" || "${sessionScope.loginUser.empNm}" || "사용자";
           if (window.loginUserNm.length > 50) window.loginUserNm = "사용자";

           // 3. 사용자 이미지 설정
           window.loginUserImg = "${loginProfile}" || "${sessionScope.loginMember.empProfile}" || "default-avatar.png";
           if (window.loginUserImg.length > 100) window.loginUserImg = "default-avatar.png";

           // 4. 사번 설정 (이게 되어야 무한 루프가 멈춤)
           var rawId = "${loginId}" || "${sessionScope.loginUser.empId}" || "${sessionScope.loginMember.empId}";
           // 사번이 정상적인 숫자나 짧은 문자열일 때만 등록
           if (rawId && rawId.length < 20) {
               window.loginUserId = String(rawId);
           }

           // DOM 로드 완료 시 확인 로그 (기존 로직 유지)
           document.addEventListener("DOMContentLoaded", function() {
               if (!window.loginUserId || window.loginUserId === "guest") {
                   const backupId = document.getElementById('sessionEmpId')?.value;
                   if (backupId) {
                       window.loginUserId = backupId;
                   } else if (typeof userId !== 'undefined' && userId) {
                       window.loginUserId = String(userId);
                   }
               }
               console.log("🚩 [최종확인] 사번:", window.loginUserId, " | 경로:", window.CP);
           });

           // 세션 체크 로그
           console.log("세션 체크1:", '${loginId}');
           console.log("세션 체크2(empId):", '${sessionScope.loginUser.empId}');
           console.log("세션 체크3(loginMember):", '${sessionScope.loginMember.empId}');
        
        let activeWin = null; // 현재 드래그/리사이즈 중인 대상 창

        document.addEventListener("DOMContentLoaded", function() {
            const menuWrapper = document.getElementById('menuWrapper');
            if (!menuWrapper) return;

            let isAiDragging = false; 
            let isActuallyDragged = false;
            let offset = { x: 0, y: 0 };

            const savedX = sessionStorage.getItem('aiPosX');
            const savedY = sessionStorage.getItem('aiPosY');
            if (savedX && savedY) {
                menuWrapper.style.left = savedX + 'px';
                menuWrapper.style.top = savedY + 'px';
            }

            document.addEventListener('mousedown', function(e) {
                // [드래그 체크] 메인 헤더 또는 개별 팝업 헤더 클릭 시
                const header = e.target.closest('#chatMainHeader, .chat-win-header');
                
                if (header) {
                    // 아이콘, 버튼, 입력창 클릭 시에는 드래그 방지
                    if (e.target.closest('button, .material-icons, i, .bx, input')) return;

                    isChatDragging = true;
                    // [핵심] 클릭한 헤더가 아니라, 그 헤더를 포함한 가장 바깥쪽 전체 박스(Wrapper)를 타겟으로 잡음
                    activeWin = header.closest('#chatMainWrapper, .chat-window-popup');
                    
                    if (activeWin) {
                        const rect = activeWin.getBoundingClientRect();
                        // 현재 마우스 위치와 창의 좌상단 지점 사이의 거리(오프셋) 계산
                        chatOffset.x = e.clientX - rect.left;
                        chatOffset.y = e.clientY - rect.top;
                        
                        // 선택된 창을 맨 앞으로 가져오기
                        document.querySelectorAll('#chatMainWrapper, .chat-window-popup').forEach(w => w.style.zIndex = "9998");
                        activeWin.style.zIndex = "10000";
                        
                        // 드래그 중 텍스트 선택 및 브라우저 기본 동작 방지
                        e.preventDefault(); 
                    }
                }

                // [리사이즈 체크] 리사이저 핸들 클릭 시
                const resizer = e.target.closest('.resizer');
                if (resizer) {
                    isChatResizing = true;
                    currentResizer = resizer;
                    activeWin = resizer.parentElement; // 리사이저가 포함된 부모 창을 타겟으로 설정
                    
                    startX = e.clientX;
                    startY = e.clientY;
                    const rect = activeWin.getBoundingClientRect();
                    startWidth = rect.width;
                    startHeight = rect.height;
                    startLeft = rect.left;
                    startTop = rect.top;
                    
                    document.body.style.cursor = window.getComputedStyle(currentResizer).cursor;
                    e.preventDefault();
                    e.stopPropagation();
                }
            });

            document.addEventListener('mousemove', function(e) {
                if (!activeWin) return;

                // --- A. 드래그 실행: 전체 창이 덩어리로 이동 ---
                if (isChatDragging) {
                    let x = e.clientX - chatOffset.x;
                    let y = e.clientY - chatOffset.y;
                    
                    // 화면 경계 밖으로 나가지 않도록 제한
                    const maxX = window.innerWidth - activeWin.offsetWidth;
                    const maxY = window.innerHeight - activeWin.offsetHeight;
                    
                    x = Math.max(0, Math.min(x, maxX));
                    y = Math.max(0, Math.min(y, maxY));

                    // 헤더가 아닌 'activeWin(전체 박스)'의 스타일을 변경함
                    activeWin.style.left = x + 'px';
                    activeWin.style.top = y + 'px';
                    activeWin.style.bottom = 'auto';
                    activeWin.style.right = 'auto';
                    activeWin.style.position = 'fixed';
                }

                // --- B. 리사이즈 실행: 전체 창의 크기 조절 ---
                if (isChatResizing && currentResizer) {
			    const dx = e.clientX - startX; // 마우스 이동 거리 (가로)
			    const dy = e.clientY - startY; // 마우스 이동 거리 (세로)
			    
			    let nw = startWidth, nh = startHeight, nl = startLeft, nt = startTop;
			    const cl = currentResizer.classList;
			
			    // 1. 오른쪽/아래쪽은 크기만 변경
			    if (cl.contains('resizer-r')) nw = startWidth + dx;
			    if (cl.contains('resizer-b')) nh = startHeight + dy;
			
			    // 2. 왼쪽(l)을 당기면: 너비는 늘리고, 위치(left)는 왼쪽으로 이동
			    if (cl.contains('resizer-l')) { 
			        nw = startWidth - dx; 
			        nl = startLeft + dx; 
			    }
			    // 3. 위쪽(t)을 당기면: 높이는 늘리고, 위치(top)는 위쪽으로 이동
			    if (cl.contains('resizer-t')) { 
			        nh = startHeight - dy; 
			        nt = startTop + dy; 
			    }
			
			    // 4. 좌상단 모서리(tl)를 당길 때 (위의 l과 t 로직이 합쳐진 결과)
			    if (cl.contains('resizer-tl')) {
			        nw = startWidth - dx;
			        nl = startLeft + dx;
			        nh = startHeight - dy;
			        nt = startTop + dy;
			    }
			    
			    // 기타 모서리 조합 (필요 시 추가)
			    if (cl.contains('resizer-tr')) { nw = startWidth + dx; nh = startHeight - dy; nt = startTop + dy; }
			    if (cl.contains('resizer-bl')) { nw = startWidth - dx; nl = startLeft + dx; nh = startHeight + dy; }
			    if (cl.contains('resizer-br')) { nw = startWidth + dx; nh = startHeight + dy; }
			
			    // 최소 크기 제한 (너무 작아지지 않게)
			    if (nw > 300) { 
			        activeWin.style.width = nw + 'px'; 
			        activeWin.style.left = nl + 'px'; 
			    }
			    if (nh > 400) { 
			        activeWin.style.height = nh + 'px'; 
			        activeWin.style.top = nt + 'px'; 
			    }
			}
            });

            document.addEventListener('mouseup', function() {
                // 🌟 [추가] 마우스를 떼기 직전, 조작 중인 창(activeWin)이 있었다면 위치/크기 저장
                if (activeWin) {
                    const winId = activeWin.id;

                    // 1. 개별 채팅창(chatWin_숫자)인 경우
                    if (winId && winId.startsWith('chatWin_')) {
                        const rmNo = winId.replace('chatWin_', '');
                        
                        // 현재 스타일 값을 객체로 저장
                        const posData = {
                            width: activeWin.style.width,
                            height: activeWin.style.height,
                            left: activeWin.style.left,
                            top: activeWin.style.top
                        };
                        
                        sessionStorage.setItem('chatPos_' + rmNo, JSON.stringify(posData));
                        console.log("📍 [저장] 채팅방 " + rmNo + " 위치/크기 기록 완료");

                    } 
                    // 2. 메인 메신저 창(chatMainWrapper)인 경우
                    else if (winId === 'chatMainWrapper') {
                        const mainPosData = {
                            width: activeWin.style.width,
                            height: activeWin.style.height,
                            left: activeWin.style.left,
                            top: activeWin.style.top
                        };
                        
                        sessionStorage.setItem('mainChatPos', JSON.stringify(mainPosData));
                        console.log("📍 [저장] 메인 목록창 위치/크기 기록 완료");
                    }
                }

                // --- 기존 로직 유지 ---
                isChatDragging = false;
                isChatResizing = false;
                activeWin = null;
                currentResizer = null;
                document.body.style.cursor = 'default';
            });
        });
        
        // [4] 기본 UI 제어 함수 - [수정] 전역 스코프 등록
        window.openChatMain = function(chatRmNo) { 
		    // 1. 방 번호 확보
		    const finalChatRmNo = chatRmNo || window.currentChatRmNo || sessionStorage.getItem('lastChatRmNo');
		    console.log("🖱️ [채팅 열기] 방번호:", finalChatRmNo); 
		    
		    const chatWrapper = document.getElementById('chatMainWrapper');
		    if (!chatWrapper) return;
		
		    // 🚩 [수정] contextPath가 빈값일 경우를 대비해 확실히 처리
		    let cp = "${pageContext.request.contextPath}";
		    if (cp === "/" || cp.startsWith("$")) cp = ""; 
		    const contextPath = cp;
		    
		    const sessionEmpId = "${userId.empId}";
		    const myEmpId = (sessionEmpId && sessionEmpId !== "guest" && !sessionEmpId.startsWith("$")) ? sessionEmpId : window.loginUserId;
		
		    // [기존 유지] 위치/크기 복구
		    try {
		        const savedMainPos = JSON.parse(sessionStorage.getItem('mainChatPos') || "{}");
		        if (savedMainPos.left && savedMainPos.top) {
		            chatWrapper.style.left = savedMainPos.left;
		            chatWrapper.style.top = savedMainPos.top;
		            chatWrapper.style.position = 'fixed';
		            chatWrapper.style.bottom = 'auto';
		            chatWrapper.style.right = 'auto';
		        }
		        if (savedMainPos.width) chatWrapper.style.width = savedMainPos.width;
		        if (savedMainPos.height) chatWrapper.style.height = savedMainPos.height;
		    } catch(e) { console.error("위치 복구 에러:", e); }
		
		    chatWrapper.style.display = 'flex';
		    sessionStorage.setItem('isChatOpen', 'true');
		
		    // 2. 사번 체크 및 후속 작업
		    const checkIdTimer = setInterval(function() {
		        const currentId = (typeof window.getRealUserId === 'function') ? window.getRealUserId() : myEmpId;
		        
		        if (currentId && currentId !== "guest" && currentId !== "null" && currentId !== "") {
		            console.log("🚀 [인식된 사번]:", currentId);
		            window.loginUserId = currentId;
		            clearInterval(checkIdTimer);
		
		            if (typeof window.connectMessengerSocket === 'function') {
		                window.connectMessengerSocket(); 
		            }
		
		            if (finalChatRmNo) {
		                window.currentChatRmNo = finalChatRmNo;
		                sessionStorage.setItem('lastChatRmNo', finalChatRmNo);
		                
		                console.log("📡 [읽음 요청 전송] 방:", finalChatRmNo, "사번:", currentId);
		
		                // 🚩 [수정] URL 경로를 더 안전하게 생성 (슬래시 중복 방지)
		                const targetUrl = (contextPath + "/alarm/updateChatStts").replace(/\/+/g, '/');
		
		                axios.post(targetUrl, {
		                    chatRmNo: String(finalChatRmNo), 
		                    empId: String(currentId),
		                    updateStts: 'readChatAlarm'      
		                })
		                .then(function(res) {
		                    console.log("✅ [서버 응답] 반영 건수:", res.data);
		                    
		                    // 🚩 [보강] 반영 건수가 0이어도 UI상에서는 숫자를 즉시 갱신하도록 유도
		                    if (typeof window.updateAlarmCount === 'function') {
		                        setTimeout(() => { 
		                            window.updateAlarmCount(); 
		                            console.log("🔔 [배지 갱신 시도]");
		                            
		                            // 만약 여전히 숫자가 안줄어들면 강제로 0 처리 시도 (채팅 중일 때만)
		                            const badge = document.querySelector('.alarm-badge'); 
		                            if(badge && window.currentChatRmNo == finalChatRmNo) {
		                                // 필요한 경우 여기서 배지 DOM을 직접 조작할 수 있습니다.
		                            }
		                        }, 500); 
		                    }
		                })
		                .catch(function(err) {
		                    console.error("❌ 요청 경로 확인 필요 (" + targetUrl + "):", err);
		                });
		
		                // [기존 유지] 탭 전환 및 메시지 로드
		                setTimeout(() => {
		                    if (typeof window.switchChatTab === 'function') window.switchChatTab('chat');
		                    if (typeof window.loadChatMessages === 'function') window.loadChatMessages(finalChatRmNo, 'chatMsgArea');
		                    else if (typeof window.getMessages === 'function') window.getMessages(finalChatRmNo);
		                }, 100);
		
		            } else {
		                const lastTab = sessionStorage.getItem('lastChatTab') || 'emp';
		                if (typeof window.switchChatTab === 'function') window.switchChatTab(lastTab);
		                window.currentChatRmNo = null;
		            }
		        }
		    }, 500);
		};
		
		// [기존 유지] 채팅창 닫기 함수
		window.closeChatMain = function() {
		    const chatWrapper = document.getElementById('chatMainWrapper');
		    if (chatWrapper) chatWrapper.style.display = 'none';
		    
		    window.currentChatRmNo = null;
		    sessionStorage.setItem('isChatOpen', 'false');
		    console.log("🔒 [채팅 종료] 현재 방 번호 초기화");
		    
		    if (typeof window.updateAlarmCount === 'function') {
		        window.updateAlarmCount();
		    }
		};

        window.switchChatTab = function(type) {
            console.log("탭 전환 호출됨:", type);
            
            // 🌟 [추가] 현재 어떤 탭을 눌렀는지 세션에 저장 (페이지 이동 시 복구용)
            sessionStorage.setItem('lastChatTab', type);
            
            const tabEmp = document.getElementById('tabEmp');
            const tabRoom = document.getElementById('tabRoom');
            const contentArea = document.getElementById('chatMainContent');
            const searchWrapper = document.getElementById('chatSearchWrapper');
            const roomArea = document.getElementById('chatRoomArea');

            if (!contentArea) return;

            // 🌟 [추가/수정] 탭 전환 시 채팅방 영역을 무조건 숨김
            if (roomArea) {
                roomArea.style.display = 'none';
            }
            
            // 🌟 [추가] 방 번호 초기화 (탭 전환 시 현재 보고 있는 방 상태를 해제)
            window.currentChatRmNo = null;

            contentArea.scrollTop = 0;

            if (type === 'emp') {
                // 사원 목록 탭 활성화
                if(tabEmp) tabEmp.style.cssText = "margin-bottom:25px; cursor:pointer; color:#696cff; text-align:center; font-weight:bold;";
                if(tabRoom) tabRoom.style.cssText = "cursor:pointer; color:#888; text-align:center; font-weight:normal;";
                
                // 사원 목록일 때는 검색창을 보여줌
                if(searchWrapper) searchWrapper.style.display = 'block';
                
                if (typeof window.loadChatEmployeeList === 'function') window.loadChatEmployeeList();
            } else {
                // 채팅방 목록 탭 활성화
                if(tabRoom) tabRoom.style.cssText = "cursor:pointer; color:#696cff; text-align:center; font-weight:bold;";
                if(tabEmp) tabEmp.style.cssText = "margin-bottom:25px; cursor:pointer; color:#888; text-align:center; font-weight:normal;";
                
                // 채팅방 목록일 때 검색창 노출 여부는 기획에 따라 결정 (여기서는 일단 숨김 유지)
                if(searchWrapper) searchWrapper.style.display = 'none';
                
                if (typeof window.loadChatRoomList === 'function') window.loadChatRoomList();
            }
        };

        // [5] 사원 목록 로드 함수 - [수정] 불필요한 중복 변수 제거 및 전역 등록
        window.loadChatEmployeeList = function() {
		    const searchWrapper = document.getElementById('chatSearchWrapper');
		    const contentArea = document.getElementById('chatMainContent');
		    const searchInput = document.getElementById('modalEmpSearch');
		    
		    if (searchWrapper) searchWrapper.style.display = 'block'; 
		    if (searchInput) searchInput.value = ''; 
		    if (!contentArea) return;
		
		    contentArea.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"></div></div>';
		
		    axios.get(CP + '/chat-api/inviteList?chatRmNo=0')
		        .then(res => {
		            const list = res.data;
		            if (!list || list.length === 0) {
		                contentArea.innerHTML = '<p class="text-center py-5">표시할 사원이 없습니다.</p>';
		                return;
		            }
		
		            let html = ''; 
		            let lastDeptName = ""; 
		            let deptIdx = 0; 
		
		            // [보정] 기본 이미지 경로를 더 안전하게 설정
		            const defaultImg = CP + '/resources/img/default-avatar.png'; 
		
		            list.forEach((emp) => {
		                const empId = String(emp.empNo || emp.empId || emp.EMP_ID || "");
		                const myId = String(window.loginUserId || "");
		
		                // 🌟 [추가] 본인 제외 로직: 내 사번과 목록의 사번이 같으면 그리지 않고 넘어감
		                if (empId === myId && myId !== "") {
		                    return; 
		                }
		
		                const empName = (emp.empNm || emp.EMP_NM || '이름 없음').replace(/'/g, "\\'");
		                const empJbgd = emp.empJbgd || emp.EMP_JBGD || '사원';
		                const deptNm = (emp.deptNm || emp.DEPT_NM || '소속 없음').trim();
		                
		                if (lastDeptName !== deptNm) {
		                    if (lastDeptName !== "") html += `</div>`; 
		                    deptIdx++;
		                    html += `
		                        <div class="dept-header" data-dept="\${deptNm}" 
		                             onclick="toggleDept('deptGroup\${deptIdx}', this)"
		                             style="background-color: #f8f9ff; padding: 10px 15px; font-size: 0.8rem; font-weight: 700; color: #696cff; border-bottom: 1px solid #eef0f2; cursor: pointer; display: flex; align-items: center;">
		                            <i class='bx bx-group me-2'></i> \${deptNm}
		                            <i class='bx bx-chevron-down toggle-icon ms-auto' style="transition: 0.3s;"></i>
		                        </div>
		                        <div id="deptGroup\${deptIdx}" class="dept-body-container">`; 
		                    lastDeptName = deptNm;
		                }
		
		                const fileName = emp.empProfile || emp.EMP_PROFILE;
		                let profileImg = defaultImg;
		                if (fileName && fileName !== 'null' && fileName !== '(null)' && fileName !== 'undefined') {
		                    profileImg = CP + '/profile/' + encodeURIComponent(fileName);
		                }
		
		                html += `
		                    <div class="emp-item-wrapper" style="border-bottom: 1px solid #f1f1f1;">
		                        <div class="list-group-item list-group-item-action d-flex align-items-center py-3 modal-emp-item" 
		                             style="cursor:pointer; border:none; transition: background 0.2s;" 
		                             onclick="toggleEmpActionMenu(this)">
		                            <div class="position-relative">
		                                <img src="\${profileImg}" class="rounded-circle border" width="40" height="40" 
		                                     style="object-fit: cover;" 
		                                     onerror="this.onerror=null; this.src='\${defaultImg}';">
		                            </div>
		                            <div class="ms-3 flex-grow-1">
		                                <div class="fw-bold text-dark" style="font-size:14px;">
		                                    \${empName} <span class="badge bg-label-primary ms-1" style="font-size:10px; font-weight:normal;">\${empJbgd}</span>
		                                </div>
		                                <div class="text-muted" style="font-size:12px;">\${deptNm}</div>
		                            </div>
		                            <i class="bx bx-chevron-down text-muted menu-arrow" style="font-size: 1.2rem; transition: 0.3s;"></i>
		                        </div>
		                        
		                        <div class="emp-action-buttons" style="display:none; background:#fcfcff; padding: 12px; border-top: 1px dashed #eee;">
		                            <div class="d-flex gap-2">
		                                <button onclick="startDirectChat('\${empId}', '\${empName}')" 
		                                        style="flex:1; border:1px solid #696cff; background:#fff; color:#696cff; border-radius:6px; padding:8px 6px; font-size:12px; display:flex; align-items:center; justify-content:center; gap:6px; cursor:pointer; font-weight:600;">
		                                    <i class='bx bx-message-rounded-dots' style="font-size:1.1rem;"></i> 1:1 채팅
		                                </button>
		                                <button onclick="startGroupChat('\${empId}', '\${empName}')" 
		                                        style="flex:1; border:1px solid #8592a3; background:#fff; color:#8592a3; border-radius:6px; padding:8px 6px; font-size:12px; display:flex; align-items:center; justify-content:center; gap:6px; cursor:pointer; font-weight:600;">
		                                    <i class='bx bx-user-plus' style="font-size:1.1rem;"></i> 그룹 채팅
		                                </button>
		                            </div>
		                        </div>
		                    </div>`;
		            });
		            
		            if (html !== "") html += `</div>`; 
		            contentArea.innerHTML = html;
		        })
		        .catch(err => {
		            console.error("사원 목록 로딩 실패:", err);
		            contentArea.innerHTML = '<p class="text-center py-5 text-danger">데이터를 불러오는 데 실패했습니다.</p>';
		        });
		};
            
        /**
         * 1. 방 목록 로드 (loadChatRooms) - 기존 로직 유지 및 경로 최적화
         */
        function loadChatRooms() {
            // [수정] 이미 정의된 전역 변수 CP 사용
            axios.get(CP + "/chat-api/roomList")
                .then(res => {
                    const roomList = res.data;
                    if(typeof renderRoomList === 'function') renderRoomList(roomList); 
                })
                .catch(err => {
                    console.error("방 목록 로딩 실패:", err);
                });
        }

        /**
         * 2. 사원 클릭 시 아래로 메뉴 펼치기
         */
        window.toggleEmpActionMenu = function(element) {
            const wrapper = element.closest('.emp-item-wrapper');
            const menu = wrapper.querySelector('.emp-action-buttons');
            const arrow = element.querySelector('.menu-arrow');
            
            // 다른 열려있는 사원 메뉴 닫기
            document.querySelectorAll('.emp-action-buttons').forEach(m => {
                if(m !== menu) {
                    m.style.display = 'none';
                    const otherWrapper = m.closest('.emp-item-wrapper');
                    if(otherWrapper) {
                        const otherArrow = otherWrapper.querySelector('.menu-arrow');
                        if(otherArrow) otherArrow.style.transform = 'rotate(0deg)';
                    }
                }
            });

            // 현재 메뉴 토글
            if (menu.style.display === 'none' || menu.style.display === '') {
                menu.style.display = 'block';
                if(arrow) arrow.style.transform = 'rotate(180deg)';
            } else {
                menu.style.display = 'none';
                if(arrow) arrow.style.transform = 'rotate(0deg)';
            }
        };

        /**
         * 3. 1:1 채팅 시작 함수
         */
         window.startDirectChat = function(id, name) {
        	    const e = window.event;
        	    if (e) e.stopPropagation();

        	    const targetId = id || (typeof selectedEmployee !== 'undefined' ? selectedEmployee.id : null);
        	    const targetNm = name || (typeof selectedEmployee !== 'undefined' ? selectedEmployee.name : "상대방");

        	    // 1. 본인 채팅 차단 로직
        	    const myId = String(window.loginUserId || "");
        	    if (String(targetId) === myId && myId !== "") {
        	        alert("자기 자신과는 1:1 채팅을 할 수 없습니다.");
        	        return;
        	    }

        	    if (!targetId) {
        	        alert("사원 정보가 올바르지 않습니다.");
        	        return;
        	    }

        	    const url = CP + "/chat-api/getOrCreateDirect"; 
        	    const formData = new URLSearchParams();
        	    formData.append('targetId', targetId);
        	    formData.append('targetNm', targetNm);
        	    
        	    // 🚩 [추가 수정] 서버에 이 채팅방이 1:1 타입('1')임을 명시해서 보냅니다.
        	    formData.append('chatRmType', '1'); 

        	    const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
        	    const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;

        	    const headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
        	    if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;

        	    fetch(url, {
        	        method: 'POST', 
        	        headers: headers,
        	        body: formData
        	    })
        	    .then(res => res.json())
        	    .then(data => {
        	        const roomNo = data.chatRmNo || data.CHAT_RM_NO;
        	        if (roomNo) {
        	            // 🌟 [핵심 수정] 리스트 내부를 바꾸는 대신, 00 님의 '새 팝업창 열기' 함수를 실행합니다.
        	            if (typeof window.enterChatRoom === 'function') {
        	                window.enterChatRoom(roomNo, targetNm);
        	            } else {
        	                console.error("enterChatRoom 함수를 찾을 수 없습니다.");
        	                // 예외 상황 대비 기존 로직 백업 (필요 시)
        	                const chatRoomArea = document.getElementById('chatRoomArea');
        	                if (chatRoomArea) chatRoomArea.style.display = 'flex';
        	            }

        	            // 하단에 떠 있던 사원 클릭 액션 메뉴는 닫아줍니다.
        	            const actionMenu = document.getElementById('chatActionMenu');
        	            if (actionMenu) actionMenu.style.display = 'none';
        	            
        	            console.log("✅ 팝업 채팅방 생성 호출 완료 - 방번호:", roomNo);
        	        } else {
        	            alert("채팅방 정보를 가져올 수 없습니다.");
        	        }
        	    })
        	    .catch(err => {
        	        console.error("채팅방 요청 실패:", err);
        	    });
        	};

        

        /**
         * 5. 채팅방 목록에 대한 그리기 로드 함수
         */
         window.loadChatRoomList = function(isSilent = false) {
        	    const searchWrapper = document.getElementById('chatSearchWrapper');
        	    const contentArea = document.getElementById('chatMainContent');
        	    
        	    if (searchWrapper) searchWrapper.style.display = 'none'; 
        	    if (!contentArea) return;

        	    if (!isSilent) {
        	        contentArea.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"></div></div>';
        	    }

        	    axios.get(CP + '/chat-api/roomList') 
        	        .then(res => {
        	            const list = res.data;
        	            
        	            // 🌟 [수정: 하드코딩 없이 동적 탐색] 화면 우측 상단 UI에서 현재 로그인한 내 이름을 긁어옵니다.
        	            const topUserEl = document.querySelector('.dropdown-user .fw-semibold') || 
        	                              document.querySelector('.nav-link .fw-semibold') ||
        	                              document.querySelector('.user-name'); // 프로젝트 헤더 클래스 탐색
        	            
        	            const myName = topUserEl ? topUserEl.innerText.trim() : (window.loginUserNm || ""); 

        	            let html = '<div class="list-group list-group-flush">';
        	            
        	            if(!list || list.length === 0) {
        	                html += '<p class="text-center py-5 text-muted">참여 중인 대화가 없습니다.</p>';
        	            } else {
        	                list.forEach(room => {
        	                    const roomNo = room.chatRmNo || room.CHAT_RM_NO;
        	                    
        	                    // --- 🌟 [수정 구간: 이름 필터링] 🌟 ---
        	                    let rawTitle = room.chatRmTtl || room.CHAT_RM_TTL || '채팅방';
        	                    const typeRaw = room.chatRmType || room.CHAT_RM_TYPE || "";
        	                    const rmType = String(typeRaw).toUpperCase().trim();

        	                    // 1:1 채팅인 경우에만 본인 이름을 제거합니다.
        	                    if ((rmType === '1' || rmType === 'PERSONAL') && myName !== "") {
        	                        let names = rawTitle.split(',').map(n => n.trim());
        	                        
        	                        if (names.length > 1) {
        	                            // 내 이름과 일치하지 않는 이름만 남깁니다 
        	                            let filteredNames = names.filter(name => name !== myName);
        	                            rawTitle = filteredNames.length > 0 ? filteredNames.join(', ') : rawTitle;
        	                        }
        	                    }
        	                    // ---------------------------------------

        	                    const roomTitle = rawTitle.replace(/'/g, "\\'"); 
        	                    const lastDate = room.chatRmLastDt || room.CHAT_RM_LAST_DT || '';
        	                    
        	                    let lastMsg = room.chatRmLastMsg || room.CHAT_RM_LAST_MSG;
        	                    if (!lastMsg || lastMsg.trim() === "") {
        	                        lastMsg = '대화를 시작해보세요.';
        	                    }
        	                    if (lastMsg.includes("data:image/") || lastMsg.includes("<img")) {
        	                        lastMsg = "📷 사진을 보냈습니다.";
        	                    }

        	                    let badgeHtml = '';
        	                    if (rmType === '1' || rmType === 'PERSONAL') {
        	                        badgeHtml = `<span class="badge rounded-pill me-1" style="background-color: #e3f2fd; color: #0d47a1; font-size: 9px; border: 1px solid #bbdefb; vertical-align: middle;">1:1</span>`;
        	                    } else if (rmType === '2' || rmType === 'GROUP') {
        	                        badgeHtml = `<span class="badge rounded-pill me-1" style="background-color: #f3e5f5; color: #4a148c; font-size: 9px; border: 1px solid #e1bee7; vertical-align: middle;">그룹</span>`;
        	                    } else {
        	                        badgeHtml = `<span class="badge rounded-pill me-1 bg-light text-muted" style="font-size: 9px; border: 1px solid #ddd; vertical-align: middle;">-</span>`;
        	                    }

        	                    html += `
        	                        <div class="list-group-item list-group-item-action py-3 position-relative" 
        	                             style="cursor:pointer; border-bottom: 1px solid #f1f1f1;" 
        	                             onclick="window.enterChatRoom('\${roomNo}', '\${roomTitle}')">
        	                            <div class="d-flex justify-content-between align-items-start mb-1">
        	                                <div>
        	                                    \${badgeHtml}
        	                                    <span class="fw-bold text-dark" style="font-size:13px; vertical-align: middle;">\${rawTitle}</span>
        	                                </div>
        	                                
        	                                <div class="delete-btn-area" style="z-index: 10;">
        	                                    <button class="btn btn-link text-danger p-0 border-0" 
        	                                            onclick="window.deleteChatRoom(event, '\${roomNo}')">
        	                                        <i class="bi bi-trash" style="font-size: 14px;"></i>
        	                                    </button>
        	                                </div>
        	                            </div>
        	                            
        	                            <div class="d-flex justify-content-between align-items-center">
        	                                <div class="text-truncate text-muted" style="font-size:11px; max-width: 180px;">\${lastMsg}</div>
        	                                <span class="text-muted" style="font-size:10px;">\${lastDate}</span>
        	                            </div>
        	                        </div>`;
        	                });
        	            }
        	            html += '</div>';
        	            contentArea.innerHTML = html;
        	        })
        	        .catch(err => console.error("목록 갱신 실패:", err));
        	};

        	// 🚩 [추가] 실제 삭제 기능을 수행하는 함수
        	window.deleteChatRoom = function(event, roomNo) {
        	    if (event) event.stopPropagation(); // 채팅방 입장 이벤트 방지

        	    if (!confirm("이 채팅방에서 나가시겠습니까?\n대화 내용이 모두 삭제됩니다.")) {
        	        return;
        	    }

        	    const url = CP + "/chat-api/deleteRoom"; // 서버 API 주소
        	    const formData = new URLSearchParams();
        	    formData.append('chatRmNo', roomNo);

        	    const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
        	    const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;

        	    const headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
        	    if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;

        	    fetch(url, {
        	        method: 'POST',
        	        headers: headers,
        	        body: formData
        	    })
        	    .then(res => res.json())
        	    .then(data => {
        	        // 서버 응답 처리는 프로젝트 환경에 맞게 조정하세요 (예: data.status === "success")
        	        alert("채팅방을 나갔습니다.");
        	        window.loadChatRoomList(true); // 목록 새로고침
        	    })
        	    .catch(err => {
        	        console.error("삭제 실패:", err);
        	        alert("삭제 중 오류가 발생했습니다.");
        	    });
        	};

        /**
         * 6. 새 채팅방 입장 및 팝업 제어
         */
         window.enterChatRoom = function(rmNo, title) {
        	    // 1. Context Path 설정 (기존 유지)
        	    if (!window.CP) {
        	        window.CP = "${pageContext.request.contextPath}" === "/" ? "" : "${pageContext.request.contextPath}";
        	    }

        	    // 🌟 [보강] 서버에 현재 방 입장 사실을 알리는 함수
        	    const notifyServerEntry = function(targetRmNo) {
        	        window.currentChatRmNo = parseInt(targetRmNo);
        	        const activeSocket = window.chatSocket || window.socket || window.ws;
        	        const myEmpId = window.loginId || window.loginUserId || document.getElementById('sessionEmpId')?.value;

        	        if (activeSocket && activeSocket.readyState === 1) { 
        	            const enterData = {
        	                type: "ENTER",
        	                chatRmNo: parseInt(targetRmNo),
        	                empId: parseInt(myEmpId)
        	            };
        	            activeSocket.send(JSON.stringify(enterData));
        	            console.log("🚀 [서버 통지] " + targetRmNo + "번 방 입장 신호 발송 완료 (사번: " + myEmpId + ")");
        	        } else {
        	            console.warn("⚠️ 소켓이 아직 연결되지 않았습니다. 상태값: " + (activeSocket ? activeSocket.readyState : "없음"));
        	        }
        	    };

        	    // 2. 기존 열린 창 체크
        	    if (openChatWindows[rmNo]) {
        	        openChatWindows[rmNo].style.zIndex = "20000";
        	        var input = document.getElementById('chatInput_' + rmNo);
        	        notifyServerEntry(rmNo);
        	        if(input) input.focus();
        	        return;
        	    }

        	    // 🌟 [수정: 이름 도려내기 로직 보강] 🌟
        	    let displayTitle = title;
        	    const topUserEl = document.querySelector('.dropdown-user .fw-semibold') || 
        	                      document.querySelector('.nav-link .fw-semibold') ||
        	                      document.querySelector('.user-name');
        	    const myName = topUserEl ? topUserEl.innerText.trim() : (window.loginUserNm || "");

        	    if (myName !== "" && displayTitle.includes(myName)) {
        	        // 쉼표가 있든 없든 쪼개서 공백을 제거한 뒤 배열화
        	        const nameList = displayTitle.split(',').map(name => name.trim());
        	        const filteredNames = nameList.filter(name => name !== myName && name !== "");
        	        
        	        if (filteredNames.length > 0) {
        	            displayTitle = filteredNames.join(', ');
        	        }
        	    }
        	    // --------------------------------------------------

        	    // 3. ID 및 위치 설정 (기존 로직 동일)
        	    var winId = 'chatWin_' + rmNo;
        	    var msgAreaId = 'chatMsgArea_' + rmNo;
        	    var inputId = 'chatInput_' + rmNo;
        	    var titleId = 'chatRoomTitle_' + rmNo;
        	    var headerId = 'chatHeader_' + rmNo; 
        	    var previewAreaId = 'pastedImagePreview_' + rmNo; 
        	    var previewImgId = 'previewImg_' + rmNo;       
        	    var fileInputId = 'chatFileIdx_' + rmNo; 
        	    var filePreviewContainerId = 'filePreviewContainer_' + rmNo;
        	    var filePreviewAreaId = 'filePreviewArea_' + rmNo;
        	    
        	    var savedPos = JSON.parse(sessionStorage.getItem('chatPos_' + rmNo) || "{}");
        	    var windowCount = Object.keys(openChatWindows).length;
        	    var defaultRight = 20 + (windowCount * 40);
        	    var finalWidth = savedPos.width || "420px"; 
        	    var finalHeight = savedPos.height || "600px";
        	    
        	    var posStyle = (savedPos.left && savedPos.top) ? 
        	        'top:' + savedPos.top + '; left:' + savedPos.left + ';' : 
        	        'bottom:20px; right:' + defaultRight + 'px;';

        	    // 4. HTML 생성
        	    var chatWinHtml = 
        	        '<div id="' + winId + '" class="chat-window-popup" ' +
        	             'style="position:fixed; ' + posStyle + ' width:' + finalWidth + '; height:' + finalHeight + '; ' +
        	                    'background:#fff; border-radius:12px; box-shadow:0 10px 30px rgba(0,0,0,0.15); ' +
        	                    'display:flex !important; flex-direction:row !important; z-index:10000; border: 1px solid #eee; overflow:hidden;">' +
        	            '<div class="resizer resizer-t" style="position:absolute; top:0; left:0; width:100%; height:7px; cursor:ns-resize; z-index:10010;"></div>' +
        	            '<div class="resizer resizer-b" style="position:absolute; bottom:0; left:0; width:100%; height:7px; cursor:ns-resize; z-index:10010;"></div>' +
        	            '<div class="resizer resizer-l" style="position:absolute; top:0; left:0; width:7px; height:100%; cursor:ew-resize; z-index:10010;"></div>' +
        	            '<div class="resizer resizer-r" style="position:absolute; top:0; right:0; width:7px; height:100%; cursor:ew-resize; z-index:10010;"></div>' +
        	            '<div class="resizer resizer-tl" style="position:absolute; top:0; left:0; width:12px; height:12px; cursor:nwse-resize; z-index:10011;"></div>' +
        	            '<div class="resizer resizer-tr" style="position:absolute; top:0; right:0; width:12px; height:12px; cursor:nesw-resize; z-index:10011;"></div>' +
        	            '<div class="resizer resizer-bl" style="position:absolute; bottom:0; left:0; width:12px; height:12px; cursor:nesw-resize; z-index:10011;"></div>' +
        	            '<div class="resizer resizer-br" style="position:absolute; bottom:0; right:0; width:12px; height:12px; cursor:nwse-resize; z-index:10011;"></div>' +
        	            '<div class="chat-win-sidenav" style="width:65px; background:#f2f2f2; display:flex; flex-direction:column; align-items:center; padding:20px 0; border-right:1px solid #e5e5e5; flex-shrink:0;">' +
        	                '<div onclick="window.openInviteModalInMessenger(\'' + rmNo + '\')" style="cursor:pointer; color:#696cff; text-align:center; margin-bottom:20px;">' +
        	                    '<i class="bx bx-user-plus" style="font-size:26px;"></i><div style="font-size:10px; font-weight:bold;">초대</div>' +
        	                '</div>' +
        	                '<div onclick="window.toggleParticipantList(\'' + rmNo + '\')" style="cursor:pointer; color:#566a7f; text-align:center;">' +
        	                    '<i class="bx bx-group" style="font-size:26px;"></i><div style="font-size:10px; font-weight:bold;">참여자</div>' +
        	                '</div>' +
        	                '<div style="flex:1;"></div>' +
        	                '<div onclick="window.leaveChatRoom(\'' + rmNo + '\')" style="cursor:pointer; color:#888; text-align:center;">' +
        	                    '<i class="bx bx-log-out" style="font-size:24px;"></i><div style="font-size:10px;">나가기</div>' +
        	                '</div>' +
        	            '</div>' +
        	            '<div style="flex:1; display:flex; flex-direction:column; overflow:hidden; position:relative;">' +
        	                '<div id="participantOverlay_' + rmNo + '" style="position:absolute; top:0; right:-100%; width:100%; height:100%; background:#fff; z-index:10100; transition:0.3s ease; display:flex; flex-direction:column; border-left:1px solid #eee;">' +
        	                    '<div style="padding:12px; background:#f8f9fa; border-bottom:1px solid #eee; display:flex; justify-content:space-between;"><span style="font-weight:bold;">참여자 목록</span><button onclick="window.toggleParticipantList(\'' + rmNo + '\')" style="border:none; background:none; cursor:pointer;">&times;</button></div>' +
        	                    '<div id="participantList_' + rmNo + '" style="flex:1; overflow-y:auto; padding:10px;"></div>' +
        	                '</div>' +
        	                '<div id="' + headerId + '" class="chat-win-header" style="padding:12px 15px; background:#696cff; color:#fff; display:flex; justify-content:space-between; align-items:center; cursor:move;">' +
        	                    '<span id="' + titleId + '" style="font-weight:bold;">' + displayTitle + '</span>' +
        	                    '<button onclick="window.closeSpecificChat(\'' + rmNo + '\')" style="background:none; border:none; color:#fff; cursor:pointer; font-size:1.5rem;">&times;</button>' +
        	                '</div>' + 
        	                '<div id="' + msgAreaId + '" class="chat-msg-container" style="flex:1; overflow-y:auto; padding:15px; background:#f8f9fa; display:flex; flex-direction:column; gap:10px;"></div>' +
        	                '<input type="file" id="' + fileInputId + '" style="display:none;" multiple onchange="window.handleFileSelect(this, \'' + rmNo + '\')">' +
        	                '<div id="' + filePreviewContainerId + '" style="display:none; padding:10px; background:#fff; border-top:1px solid #eee; max-height:120px; overflow-y:auto; flex-shrink:0;">' +
        	                    '<div id="' + filePreviewAreaId + '"></div>' +
        	                '</div>' +
        	                '<div id="' + previewAreaId + '" style="display:none; padding:10px; background:#fff; border-top:1px solid #eee; text-align:right; flex-shrink:0;">' +
        	                    '<div style="position:relative; display:inline-block; border:2px solid #696cff; border-radius:8px; padding:3px; background:#f0f0ff;">' +
        	                        '<img id="' + previewImgId + '" src="" style="max-width:100px; max-height:100px; border-radius:5px; display:block;">' +
        	                        '<div onclick="window.clearImagePreview(\'' + rmNo + '\')" style="position:absolute; top:-10px; right:-10px; background:#000; color:#fff; border-radius:50%; width:22px; height:22px; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:14px; font-weight:bold; border:2px solid #fff;">&times;</div>' +
        	                    '</div>' +
        	                '</div>' +
        	                '<div style="padding:10px; border-top:1px solid #eee; background:#fff; flex-shrink:0;">' +
        	                    '<div style="display:flex; gap:8px; align-items:end;">' +
        	                        '<div id="' + inputId + '" contenteditable="true" style="flex:1; border:1px solid #eee; border-radius:15px; padding:8px 15px; font-size:13px; outline:none; background:#f9f9f9; min-height:36px; max-height:100px; overflow-y:auto; word-break:break-all; white-space: pre-wrap;" placeholder="메시지를 입력하세요..."></div>' +
        	                        '<div onclick="window.fileUploadPrompt(\'' + rmNo + '\')" style="cursor:pointer; margin-bottom:8px;">' +
        	                        '<i class="bx bx-paperclip" style="font-size:20px; color:#696cff;"></i>' +
        	                        '</div>' +
        	                        '<button type="button" onclick="window.sendSpecificMessage(event, \'' + rmNo + '\')" style="background:#696cff; color:#fff; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; margin-bottom:5px;"><i class="bx bxs-send" style="font-size:16px;"></i></button>' +
        	                    '</div>' +
        	                '</div>' +
        	            '</div>' +
        	        '</div>';

        	    document.body.insertAdjacentHTML('beforeend', chatWinHtml);
        	    openChatWindows[rmNo] = document.getElementById(winId);

        	    setTimeout(function() {
        	        notifyServerEntry(rmNo);
        	    }, 100);

        	    // 6. sessionStorage 및 메시지 로드 (기존 유지)
        	    var savedRooms = JSON.parse(sessionStorage.getItem('openChatRooms') || "[]");
        	    if (!savedRooms.find(r => r.rmNo == rmNo)) {
        	        savedRooms.push({ rmNo: rmNo, title: displayTitle });
        	        sessionStorage.setItem('openChatRooms', JSON.stringify(savedRooms));
        	    }
        	    
        	    if (typeof window.loadChatMessages === 'function') { 
        	        window.loadChatMessages(rmNo, msgAreaId); 
        	    }
        	    
        	    if (typeof window.initDragAndResize === 'function') {
        	        window.initDragAndResize(winId, headerId, rmNo);
        	    }
        	};
        /**
         * 8. 대화 내역 서버 로드
         */
         window.loadChatMessages = function(rmNo, targetAreaId) {
        	    if (!rmNo) return;
        	    
        	    // 🌟 [확인/유지] 현재 활성화된 방 번호를 전역 변수에 확실히 저장
        	    window.currentChatRmNo = parseInt(rmNo); 
        	    console.log("📍 [방 활성화] 현재 보고 있는 방 번호:", window.currentChatRmNo);

        	    // --- [변수 보정 로직 유지] ---
        	    if (!window.CP || window.CP === "undefined") {
        	        window.CP = "${pageContext.request.contextPath}" === "/" ? "" : "${pageContext.request.contextPath}";
        	    }
        	    const contextPath = window.CP;

        	    // 사번 정보 확인 로직 (기존 유지)
        	    if (!window.loginUserId || window.loginUserId === "guest") {
        	        const sessionCheckId = "${loginId}"; 
        	        if (sessionCheckId && sessionCheckId !== "") {
        	            window.loginUserId = sessionCheckId;
        	        } else {
        	            console.warn("⏳ 사번 로딩 대기 중... (재시도)");
        	            setTimeout(function() { window.loadChatMessages(rmNo, targetAreaId); }, 300);
        	            return; 
        	        }
        	    }

        	    // 드래그 앤 드롭 초기화 (기존 유지)
        	    if (typeof window.initDragAndDropForRoom === 'function') {
        	        window.initDragAndDropForRoom(rmNo);
        	    }

        	    const msgArea = document.getElementById(targetAreaId) || document.getElementById('chatMsgArea');
        	    if (!msgArea) return;

        	    var safeCP = (window.CP && window.CP !== '/') ? (window.CP.startsWith('/') ? window.CP : '/' + window.CP) : '';
        	    var apiUrl = safeCP + "/chat-api/getMessages";

        	    // ---------------------------------------------------------
        	    // 🚀 [수정] 단일 API 호출로 최적화 + 실시간 UI 반영 보강
        	    // ---------------------------------------------------------
        	    axios.get(apiUrl, { params: { chatRmNo: rmNo } })
        	        .then(function(res) {
        	            console.log("✅ 메시지 로드 및 알람 자동 읽음 처리 완료");

        	            // 1️⃣ [중요] 상단 알림 카운트 즉시 재갱신
        	            // 🌟 추가 수정: DB 반영 속도가 느릴 것을 대비해 즉시 0으로 보정 시도 후 서버 값을 다시 가져옵니다.
        	            const chatBadge = document.getElementById('chatAlmCnt');
        	            if (chatBadge && chatBadge.innerText === '1') {
        	                // 현재 방에 들어왔으므로 '1'인 경우 일단 숨겨서 사용자에게 즉각적인 피드백을 줍니다.
        	                chatBadge.style.display = 'none';
        	                chatBadge.innerText = '0';
        	            }

        	            if (typeof window.updateAlarmCount === 'function') {
        	                setTimeout(function() {
        	                    window.updateAlarmCount(); 
        	                }, 400); // 안정성을 위해 지연 시간을 400ms로 소폭 상향
        	            }
        	            
        	            // 2️⃣ [채팅방 리스트 배지] 즉시 0으로 변경 (실시간성 보강)
        	            const roomBadge = document.querySelector(`.room-unread-count[data-rmno="${rmNo}"]`);
        	            if (roomBadge) {
        	                roomBadge.innerText = '0';
        	                roomBadge.style.display = 'none';
        	            }

        	            msgArea.innerHTML = ''; 
        	            var messages = res.data;
        	            
        	            if (Array.isArray(messages) && messages.length > 0) {
        	                if (typeof window.appendMessengerMessage !== 'function') {
        	                    console.error("🚨 appendMessengerMessage 함수가 정의되지 않았습니다!");
        	                    return;
        	                }
        	                messages.forEach(function(msg) {
        	                    try {
        	                        window.appendMessengerMessage(msg, targetAreaId);
        	                    } catch(e) {
        	                        console.error("❌ 메시지 그리기 실패:", e);
        	                    }
        	                });
        	                
        	                // 메시지 렌더링 후 스크롤 하단 이동
        	                setTimeout(function() { 
        	                    msgArea.scrollTop = msgArea.scrollHeight; 
        	                }, 150);
        	            } else {
        	                msgArea.innerHTML = '<div style="text-align:center; color:#ccc; font-size:12px; margin-top:20px;">대화 내용이 없습니다.</div>';
        	            }
        	        })
        	        .catch(function(err) {
        	            console.error("❌ 통신 에러:", err);
        	        });
        	};

        /**
         * 9. 부서 및 검색 필터 로직
         */
        window.toggleDept = function(contentId, headerElem) {
            const content = document.getElementById(contentId);
            const icon = headerElem.querySelector('.toggle-icon');
            if (content.style.display === "none") {
                content.style.display = "block";
                if (icon) icon.style.transform = "rotate(0deg)";
            } else {
                content.style.display = "none";
                if (icon) icon.style.transform = "rotate(-90deg)";
            }
        };

        window.filterModalEmpList = function() {
            const searchInput = document.getElementById('modalEmpSearch');
            if (!searchInput) return;
            const keyword = searchInput.value.toLowerCase().trim();
            const items = document.querySelectorAll('.modal-emp-item');
            const headers = document.querySelectorAll('.dept-header');

            items.forEach(item => {
                const text = item.innerText.toLowerCase();
                item.style.setProperty('display', text.includes(keyword) ? 'flex' : 'none', 'important');
            });

            headers.forEach(header => {
                const deptName = header.getAttribute('data-dept');
                const hasVisibleMember = Array.from(items).some(item => 
                    item.closest('.dept-body-container').id.includes(header.onclick.toString().match(/deptGroup\d+/)) && item.style.display !== 'none'
                );
                header.style.display = hasVisibleMember ? 'flex' : 'none';
            });
        };

        /**
         * 10. 메인 전송 이벤트 (전역 변수 활용)
         */
         const mainChatForm = document.getElementById('chatMessageForm');
         if (mainChatForm) {
             // 🌟 await를 쓰기 위해 async 함수로 변경합니다.
             mainChatForm.addEventListener('submit', async function(e) { 
                 e.preventDefault();
                 
                 const input = document.getElementById('chatMessageInput');
                 
                 // 1. 이미지 태그와 텍스트 내용 분리 추출 (기존 로직 유지)
                 const pastedImages = input.querySelectorAll('img.pasted-image');
                 let textContent = "";
                 input.childNodes.forEach(node => {
                     if (node.nodeType === Node.TEXT_NODE) {
                         textContent += node.textContent;
                     } else if (node.nodeType === Node.ELEMENT_NODE && node.tagName !== 'IMG') {
                         textContent += node.innerText;
                     }
                 });
                 const message = textContent.trim();
                 
                 // [체크] 메시지도 없고 이미지/파일도 없으면 중단
                 const hasPendingFiles = window.pendingFiles && window.pendingFiles[currentChatRmNo] && window.pendingFiles[currentChatRmNo].length > 0;
                 if ((!message && pastedImages.length === 0 && !hasPendingFiles) || !currentChatRmNo) return;

                 // 사번 정보 확인 (기존 유지)
                 let finalEmpId = window.loginUserId;
                 if (!finalEmpId || finalEmpId === "guest" || finalEmpId === "") {
                     console.error("❌ 사번 정보가 없습니다.");
                     alert("사용자 정보를 확인 중입니다.");
                     return; 
                 }

                 const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
                 const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;

                 try {
                     /* ==========================================================
                        🚀 [핵심 수정] 이미지/파일이 있다면 먼저 업로드하여 fileId 확보
                        ========================================================== */
                     let finalFileId = null;

                     // 1. 붙여넣은 이미지가 있다면 pendingFiles에 먼저 넣어줍니다.
                     if (pastedImages.length > 0) {
                         const blob = base64ToBlob(pastedImages[0].src);
                         // processFiles를 호출하여 대기열에 추가 (이미 있으면 중복 방지 로직 필요할 수 있음)
                         window.processFiles([blob], currentChatRmNo);
                     }

                     // 2. 통합 업로드 함수 호출 (📎버튼으로 올린 파일 + 붙여넣은 이미지 모두 처리)
                     if (window.pendingFiles && window.pendingFiles[currentChatRmNo] && window.pendingFiles[currentChatRmNo].length > 0) {
                         finalFileId = await window.uploadFilesToServer(currentChatRmNo);
                     }

                     // 3. 최종 메시지 전송 (JSON 방식 하나로 통일)
                     const sendData = {
                         chatRmNo: parseInt(currentChatRmNo),
                         empId: finalEmpId,
                         chatCn: message,
                         fileId: finalFileId // 업로드 성공 시 생성된 fileGroupNo (또는 null)
                     };

                     const headers = { 'Content-Type': 'application/json' };
                     if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;

                     // 이제 이미지 전용 URL(/sendMsgWithImage) 대신 공용 /insertLog를 사용합니다.
                     axios.post(CP + "/chat-api/insertLog", sendData, { headers: headers })
                         .then(res => {
                             handleChatResponse(res, input);
                             // 전송 후 미리보기 영역 초기화
                             if (window.pendingFiles) window.pendingFiles[currentChatRmNo] = [];
                             const container = document.getElementById('filePreviewContainer_' + currentChatRmNo);
                             if(container) container.style.display = 'none';
                         })
                         .catch(err => console.error("❌ 메시지 전송 실패:", err));

                 } catch (error) {
                     console.error("❌ 전송 과정 중 에러 발생:", error);
                 }
             });
         }

         /**
          * 전송 후 공통 결과 처리 (기존 .then 내부 로직을 함수로 분리)
          */
         function handleChatResponse(res, input) {
             if (res.status === 200 || res.status === 201) {
                 // 소켓 전송
                 if (window.chatSocket && window.chatSocket.readyState === 1) {
                     window.chatSocket.send(JSON.stringify(res.data));
                 }
                 
                 // 화면에 메시지 추가
                 if (typeof window.appendMessengerMessage === 'function') {
                     window.appendMessengerMessage(res.data, 'chatMsgArea');
                 }
                 
                 // 입력창 초기화 (div이므로 innerHTML 비우기)
                 input.innerHTML = '';
                 input.focus();
                 
                 // 스크롤 하단 이동
                 const chatArea = document.getElementById('chatMsgArea');
                 if (chatArea) chatArea.scrollTop = chatArea.scrollHeight;
             }
         }

         /**
          * Base64 데이터를 Blob으로 변환 (이미지 전송 필수 함수)
          */
         function base64ToBlob(base64) {
             const parts = base64.split(';base64,');
             const contentType = parts[0].split(':')[1];
             const raw = window.atob(parts[1]);
             const uInt8Array = new Uint8Array(raw.length);
             for (let i = 0; i < raw.length; ++i) {
                 uInt8Array[i] = raw.charCodeAt(i);
             }
             return new Blob([uInt8Array], { type: contentType });
         }

        
         
        /**
         * 1. 특정 채팅창(메인 또는 팝업)에서 메시지 전송 함수(채팅창 관련)
         */
      	// 전역 변수로 전송 상태 관리 (함수 바깥에 선언)
        window.isChatSending = window.isChatSending || {};

        window.sendSpecificMessage = async function(e, rmNo) { 
            if (e) { e.preventDefault(); e.stopPropagation(); }
            
            const targetRmNo = rmNo || window.currentChatRmNo;
            if (!targetRmNo) return;

            // 🌟 [추가] 현재 보내는 방을 '내가 보고 있는 방'으로 다시 한번 확정
            window.currentChatRmNo = targetRmNo;

            window.isChatSending = window.isChatSending || {};
            window.pendingFiles = window.pendingFiles || {};
            window.pendingImages = window.pendingImages || {};
            
            if (window.isChatSending[targetRmNo]) {
                console.warn("📍 [" + targetRmNo + "] 이전 메시지가 아직 처리 중입니다...");
                return;
            }

            const input = document.getElementById("chatInput_" + targetRmNo) || document.getElementById('chatMessageInput');
            if (!input) return;

            let chatContent = input.innerHTML.replace(/&nbsp;/g, ' ').trim();
            const imgKey = targetRmNo;
            
            const currentFiles = window.pendingFiles[targetRmNo] || [];
            const hasFiles = currentFiles.length > 0;
            
            if ((!chatContent || chatContent === '<br>' || chatContent === '<div><br></div>' || chatContent === '') && !hasFiles) {
                return;
            }

            let myId = window.loginUserId; 
            if (myId === "guest" || !myId) {
                alert("로그인 정보가 유효하지 않습니다.");
                return;
            }

            window.isChatSending[targetRmNo] = true;

            try {
                let fileId = null;
                let finalChatContent = chatContent;
                let finalChatType = 'TEXT';

                if (hasFiles) {
                    const firstFile = currentFiles[0];
                    const fileName = firstFile?.name || "";
                    const extension = fileName.includes('.') ? fileName.split('.').pop().toLowerCase() : "";
                    const isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].includes(extension);

                    if (isImage) {
                        const base64Data = await new Promise((resolve) => {
                            const reader = new FileReader();
                            reader.onload = (e) => resolve(e.target.result);
                            reader.readAsDataURL(firstFile);
                        });
                        finalChatContent = base64Data; 
                        finalChatType = 'IMAGE';
                        fileId = null; 
                    } else {
                        fileId = await window.uploadFilesToServer(targetRmNo); 
                        if (fileId) {
                            finalChatType = 'FILE';
                        } else {
                            throw new Error("파일 업로드 실패");
                        }
                    }
                }

                const sendData = {
                    chatRmNo: parseInt(targetRmNo),
                    empId: myId,
                    chatCn: finalChatContent, 
                    fileId: (fileId && fileId !== 'null') ? parseInt(fileId) : null,
                    chatType: finalChatType 
                };

                const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
                const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
                const headers = { 'Content-Type': 'application/json' };
                if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;

                // DB 저장
                const res = await axios.post((window.CP || "") + "/chat-api/insertLog", sendData, { headers: headers });

                // 소켓 전송
                if (window.chatSocket && window.chatSocket.readyState === 1) {
                    window.chatSocket.send(JSON.stringify(res.data)); 
                    
                    // 🌟 [핵심 추가] 메시지 전송 성공 직후, 내 상단 알림 배지를 즉시 0으로 갱신
                    if (typeof window.updateAlarmCount === 'function') {
                        window.updateAlarmCount(); 
                    }
                }
                
                // --- 🌟 [수정 포인트: 파일 업로드 시에만 0.5초 딜레이 실행] 🌟 ---
                const clearUIAndInput = () => {
                    if (window.pendingImages[imgKey]) delete window.pendingImages[imgKey];
                    input.innerHTML = ''; 
                    
                    if (typeof window.clearImagePreview === 'function') window.clearImagePreview(targetRmNo);
                    
                    window.pendingFiles[targetRmNo] = []; 
                    const fileArea = document.getElementById('filePreviewArea_' + targetRmNo);
                    const fileCont = document.getElementById('filePreviewContainer_' + targetRmNo);
                    if(fileArea) fileArea.innerHTML = '';
                    if(fileCont) fileCont.style.display = 'none';

                    input.focus();
                    console.log("✅ [" + targetRmNo + "] 채팅창 UI 및 입력 초기화 완료");
                };

                if (finalChatType === 'FILE') {
                    // 파일을 보냈을 때만 500ms(0.5초) 후에 UI를 비워줍니다.
                    // (서버가 DB 트랜잭션 커밋 및 물리 I/O 작업을 마칠 시간을 벌어줍니다.)
                    setTimeout(clearUIAndInput, 500);
                    console.log("⏱️ 파일 트랜잭션을 위해 0.5초 지연 초기화합니다.");
                } else {
                    // 일반 텍스트 및 이미지는 지연 없이 즉시 초기화
                    clearUIAndInput();
                }
                // -----------------------------------------------------------------

            } catch (err) {
                console.error("❌ [" + targetRmNo + "] 전송 실패:", err);
                alert("메시지 전송 중 오류가 발생했습니다.");
            } finally {
                setTimeout(() => {
                    window.isChatSending[targetRmNo] = false;
                }, 300);
            }
        };

        	/**
        	 * 2. 새 창(팝업) 전용 닫기 함수
        	 */
        	 window.closeSpecificChat = function(rmNo) {
        		    const winId = "chatWin_" + rmNo; 
        		    const winElem = document.getElementById(winId);
        		    
        		    console.log("🚀 창 닫기 시도 - 방번호:", rmNo);

        		    if (winElem) {
        		        // 🌟 [추가] 서버에 이 방을 더 이상 보고 있지 않음을 통지 (LEAVE)
        		        const activeSocket = window.chatSocket || window.socket;
        		        if (activeSocket && activeSocket.readyState === 1) { // 1 = OPEN
        		            activeSocket.send(JSON.stringify({
        		                type: "LEAVE",
        		                chatRmNo: parseInt(rmNo),
        		                empId: window.loginId || window.loginUserId // 사용하는 사번 변수명 확인
        		            }));
        		            console.log("📤 [서버 통지] " + rmNo + "번 방 이탈(LEAVE) 신호 발송");
        		        }

        		        // 1. 화면에서 요소 삭제
        		        winElem.remove();
        		        
        		        // 2. 관리 객체에서 삭제
        		        if (typeof openChatWindows !== 'undefined' && openChatWindows[rmNo]) {
        		            delete openChatWindows[rmNo];
        		        }

        		        // 🌟 [기존 유지] sessionStorage에서 해당 방 정보 제거
        		        var savedRooms = JSON.parse(sessionStorage.getItem('openChatRooms') || "[]");
        		        var updatedRooms = savedRooms.filter(function(room) {
        		            return String(room.rmNo) !== String(rmNo);
        		        });
        		        sessionStorage.setItem('openChatRooms', JSON.stringify(updatedRooms));

        		        // 3. [기존 유지] 창 위치 재정렬
        		        if (typeof openChatWindows !== 'undefined') {
        		            const activeIds = Object.keys(openChatWindows);
        		            activeIds.forEach((id, idx) => {
        		                const el = openChatWindows[id];
        		                if (el && document.getElementById("chatWin_" + id)) {
        		                    el.style.right = (20 + (idx * 360)) + "px";
        		                } else {
        		                    delete openChatWindows[id];
        		                }
        		            });
        		        }
        		        
        		        // 4. [기존 유지] 현재 활성 방 번호 전역 변수 초기화
        		        if (window.currentChatRmNo && String(window.currentChatRmNo) === String(rmNo)) {
        		            window.currentChatRmNo = null;
        		            console.log("🚫 [상태 해제] 현재 활성 방 번호가 초기화되었습니다.");
        		        }
        		        
        		        console.log("✅ 창 닫기, 정렬 및 상태 저장 완료");
        		    } else {
        		        console.warn("⚠️ 닫으려는 창 요소를 찾을 수 없습니다:", winId);
        		    }
        		};

        		// 초기화 로직 (DOMContentLoaded)
        		document.addEventListener("DOMContentLoaded", function() {
        		    // 🌟 [기존 유지 및 보강] 사번 가져오기
        		    const currentId = (typeof window.getRealUserId === 'function') ? window.getRealUserId() : window.loginUserId;
        		    
        		    if (currentId && currentId !== "guest" && !currentId.startsWith("$")) {
        		        window.loginUserId = currentId;
        		        // 서버 통신용 전역 변수 loginId도 함께 맞춤 (필요시)
        		        window.loginId = currentId; 
        		    }

        		    console.log("🚩 [설정확인] 최종 확정 사번:", window.loginUserId, " | 경로:", (typeof CP !== 'undefined' ? CP : ''));

        		    // 소켓 연결
        		    if (typeof window.connectMessengerSocket === 'function') {
        		        window.connectMessengerSocket();
        		    }

        		    // 메인 폼 전송 바인딩
        		    const mainForm = document.getElementById('chatMessageForm');
        		    if (mainForm) {
        		        mainForm.onsubmit = function(e) { 
        		            e.preventDefault();
        		            if(typeof window.sendSpecificMessage === 'function') {
        		                window.sendSpecificMessage(e); 
        		            }
        		        };
        		    }
        		});

        	/**
        	 * 4. 소켓 및 기타 리스너 (기존 로직 유지)
        	 */
        	 window.connectMessengerSocket = function() {
        		    // 1. 중복 연결 방지
        		    if (window.chatSocket && window.chatSocket.readyState <= 1) {
        		        console.log("⚠️ 소켓이 이미 연결되어 있어 재연결하지 않습니다.");
        		        return;
        		    }

        		    const socketUrl = window.location.origin + (typeof CP !== 'undefined' ? CP : '') + "/chat"; 
        		    window.chatSocket = new SockJS(socketUrl);

        		    window.chatSocket.onmessage = null; 

        		    window.chatSocket.onmessage = (event) => {
        		        try {
        		            const chat = JSON.parse(event.data);

        		            // 🌟 [추가: 이미지 무한루프 방지] 프로필 데이터가 없으면 기본 이미지 경로 강제 지정
        		            if (!chat.empProfile || chat.empProfile === 'null' || chat.empProfile === '') {
        		                chat.empProfile = (typeof CP !== 'undefined' ? CP : '') + "/resources/images/default_profile.png"; 
        		            }

        		            // 🌟 [입장 시 신호 처리] 서버에서 보낸 알림 카운트 갱신 신호 처리
        		            if (chat.type === "REFRESH_ALARM_COUNT") {
        		                console.log("🔔 [UI 즉시 갱신] 서버 요청에 의해 배지 숫자를 초기화합니다.");
        		                
        		                const badge = document.getElementById('chatAlmCnt');
        		                if (badge) {
        		                    badge.innerText = '0';
        		                    badge.style.display = 'none';
        		                }

        		                if (typeof window.updateAlarmCount === 'function') {
        		                    window.updateAlarmCount(); 
        		                }
        		                if (typeof window.loadChatRoomList === 'function') {
        		                    window.loadChatRoomList(true); 
        		                }
        		                return; 
        		            }

        		            // --- 기존 메시지 출력 로직 시작 ---
        		            const msgRmNo = parseInt(chat.chatRmNo || chat.CHAT_RM_NO);
        		            const msgId = chat.chatLogNo || chat.CHAT_LOG_NO;
        		            
        		            if (msgId && document.querySelector(`[data-chat-no="${msgId}"]`)) {
        		                return;
        		            }

        		            const isWatchingNow = (window.currentChatRmNo && parseInt(window.currentChatRmNo) === msgRmNo);
        		            const popupAreaId = "chatMsgArea_" + msgRmNo;
        		            const popupElement = document.getElementById(popupAreaId);

        		            if (popupElement) {
        		                window.appendMessengerMessage(chat, popupAreaId);
        		                // 🌟 [추가]: 방금 추가된 메시지 내 이미지 태그의 onerror 무한루프 차단
        		                if (typeof fixProfileImageError === 'function') fixProfileImageError(popupElement);
        		                setTimeout(() => { popupElement.scrollTop = popupElement.scrollHeight; }, 150);
        		            } 
        		            else if (isWatchingNow) {
        		                const mainArea = document.getElementById('chatMsgArea');
        		                if (mainArea) {
        		                    window.appendMessengerMessage(chat, 'chatMsgArea');
        		                    if (typeof fixProfileImageError === 'function') fixProfileImageError(mainArea);
        		                    setTimeout(() => { mainArea.scrollTop = mainArea.scrollHeight; }, 150);
        		                }
        		            }

        		            // --- 🌟 [수정 포인트: 실시간 채팅 목록 갱신 통합] ---
        		            // 보고 있는 방이든 아니든, 새로운 메시지가 오면 무조건 목록의 최신 메시지와 시간을 갱신합니다.
        		            if (typeof window.loadChatRoomList === 'function') {
        		                window.loadChatRoomList(true); 
        		                console.log("🔄 새로운 메시지 수신으로 인해 채팅 목록을 실시간 갱신합니다.");
        		            }

        		            // 배지 및 알람 카운트 처리
        		            if (!isWatchingNow) {
        		                console.log("🔔 방이 닫혀있어 알림 리스트를 갱신합니다.");
        		            } else {
        		                console.log("🚀 채팅 중인 방이므로 배지 숫자를 강제로 0으로 유지합니다.");
        		                
        		                const badge = document.getElementById('chatAlmCnt');
        		                if (badge) {
        		                    badge.innerText = '0';
        		                    badge.style.display = 'none';
        		                }

        		                if (typeof window.updateAlarmCount === 'function') {
        		                    window.updateAlarmCount();
        		                }
        		            }

        		        } catch (e) {
        		            console.error("❌ 수신 처리 에러:", e);
        		        }
        		    };

        		    window.chatSocket.onopen = () => {
        		        console.log("🚀 채팅 소켓 연결 성공!");
        		    };

        		    window.chatSocket.onclose = () => {
        		        setTimeout(window.connectMessengerSocket, 3000);
        		    };
        		};
        		
///////////////////////////////////////////////////// 그룹 채팅 시작 ////////////////////////////////////////////////////
        		if (typeof selectedEmps === 'undefined') {
			        var selectedEmps = new Set(); 
			    }
        		/**
                 * 1. 그룹 채팅 초대
                 */
                 window.startGroupChat = function(id, name) {
               	    const e = window.event;
               	    if (e) e.stopPropagation();

               	    // 1. 모달 초기화
               	    selectedEmps.clear(); 
               	    document.getElementById('selectedEmployees').innerHTML = '';
               	    document.getElementById('groupChatTitle').value = '';
               	    
               	    // 2. 만약 특정 사원(id)을 선택해서 시작한 경우, 그 사람을 바로 뱃지에 추가
               	    if (id && name) {
               	        // 본인이 아니라면 추가
               	        if (String(id) !== String(window.loginUserId)) {
               	            toggleEmployeeInGroup(String(id), name);
               	        }
               	    }

               	    // 3. 부트스트랩 모달 띄우기 (HTML에 선언한 id와 일치해야 함)
               	    const modalEl = document.getElementById('groupChatModal');
               	    if (modalEl) {
               	        const groupModal = new bootstrap.Modal(modalEl);
               	        groupModal.show();
               	    } else {
               	        console.error("groupChatModal 요소를 찾을 수 없습니다.");
               	    }
               	    
               	    // 4. 사원 목록 로드
               	    loadGroupEmployeeList();
               	};
                
               	
               	// 2. 모달용 사원 목록 로드 함수
               	window.loadGroupEmployeeList = function() {
				    const listArea = document.getElementById('modalEmpListForGroup');
				    if (!listArea) return;
				
				    listArea.innerHTML = '<div class="text-center p-3"><div class="spinner-border spinner-border-sm text-primary"></div></div>';
				
				    axios.get(CP + '/chat-api/allEmployees')
				        .then(res => {
				            const list = res.data;
				            let html = '';
				            let lastDept = '';
				            let deptIdx = 0;
				            
				            // 기본 이미지 경로 설정
				            const defaultImg = CP + '/resources/img/default-avatar.png'; 
				
				            list.forEach(emp => {
				                // VO 필드명에 맞게 데이터 추출 (ChatUserVO 기반)
				                const empId = String(emp.empId || "");
				                if (empId === String(window.loginUserId)) return; // 본인 제외
				
				                const empNm = emp.empNm || "이름없음";
				                const empJbgd = emp.empJbgd || "사원"; // undefined 방지
				                const deptNm = emp.deptNm || "소속없음";
				                
				                // 프로필 이미지 경로 처리
				                let profileImg = defaultImg;
				                if (emp.empProfile && emp.empProfile !== 'null' && emp.empProfile !== '') {
				                    // 서버의 실제 파일 매핑 경로가 /profile/ 인지 확인 필요
				                    profileImg = CP + '/profile/' + encodeURIComponent(emp.empProfile);
				                }
				
				                // 부서별 그룹핑 헤더
				                if (lastDept !== deptNm) {
				                    if (lastDept !== "") html += `</div></div>`;
				                    deptIdx++;
				                    html += `
				                        <div class="dept-group-wrapper">
				                            <div class="dept-header p-2 bg-light d-flex justify-content-between align-items-center" 
				                                 style="cursor:pointer; font-size:12px; font-weight:bold; color:#696cff; border-bottom:1px solid #eee;" 
				                                 onclick="toggleDept('modalDept\${deptIdx}', this)">
				                                <span><i class='bx bx-chevron-down toggle-icon'></i> \${deptNm}</span>
				                            </div>
				                            <div id="modalDept\${deptIdx}" class="dept-body">`;
				                    lastDept = deptNm;
				                }
				
				                const isChecked = selectedEmps.has(empId) ? 'checked' : '';
				                
				                html += `
				                    <div class="group-emp-item d-flex align-items-center p-2 border-bottom" 
				                         style="cursor:pointer;" onclick="toggleEmployeeInGroup('\${empId}', '\${empNm}')">
				                        <input type="checkbox" class="form-check-input me-3" id="chk-g-\${empId}" \${isChecked} 
				                               onclick="event.stopPropagation(); toggleEmployeeInGroup('\${empId}', '\${empNm}')">
				                        
				                        <img src="\${profileImg}" 
				                             style="width:35px; height:35px; border-radius:50%; margin-right:12px; object-fit:cover; border:1px solid #eee;"
				                             onerror="this.onerror=null; this.src='\${defaultImg}';">
				                        
				                        <div style="font-size:13px;">
				                            <strong>\${empNm}</strong> 
				                            <span class="text-muted ms-1" style="font-size:11px;">\${empJbgd}</span>
				                        </div>
				                    </div>`;
				            });
				            
				            listArea.innerHTML = html + (html !== '' ? "</div></div>" : '<div class="p-3 text-center">사원이 없습니다.</div>');
				        })
				        .catch(err => {
				            console.error("목록 로드 실패:", err);
				            listArea.innerHTML = '<div class="p-3 text-center text-danger">목록을 불러오지 못했습니다.</div>';
				        });
				};
               	
             	// 3. [뱃지 및 체크박스 제어]
               	window.toggleEmployeeInGroup = function(id, name) {
               	    const chk = document.getElementById('chk-g-' + id);
               	    const container = document.getElementById('selectedEmployees');

               	    if (selectedEmps.has(id)) {
               	        selectedEmps.delete(id);
               	        if(chk) chk.checked = false;
               	        const badge = document.getElementById('badge-g-' + id);
               	        if (badge) badge.remove();
               	    } else {
               	        selectedEmps.add(id);
               	        if(chk) chk.checked = true;

               	        // 🌟 뱃지에 X 아이콘 추가 (클릭 시 제거 기능 연동)
               	        const badgeHtml = `
               	            <span id="badge-g-\${id}" class="badge bg-primary d-flex align-items-center gap-1" 
               	                  style="padding:6px 10px; border-radius:20px; font-weight:normal; background-color:#696cff !important;">
               	                \${name}
               	                <i class='bx bx-x' style="cursor:pointer; font-size:16px; margin-left:2px;" 
               	                   onclick="event.stopPropagation(); toggleEmployeeInGroup('\${id}', '\${name}')"></i>
               	            </span>`;
               	        container.insertAdjacentHTML('beforeend', badgeHtml);
               	    }
               	};
               	
             	// 4. [실제 방 생성 실행]
               	window.createNewGroupChat = function() {
               	    const title = document.getElementById('groupChatTitle').value.trim();
               	    if (!title) return alert("채팅방 이름을 입력해주세요.");
               	    if (selectedEmps.size === 0) return alert("최소 1명 이상의 상대를 선택하세요.");

               	    const members = Array.from(selectedEmps);
               	    members.push(window.loginUserId); // 나 포함

               	    axios.post(CP + '/chat-api/createGroupRoom', {
               	        roomTitle: title,
               	        memberList: members
               	    }).then(res => {
               	        // 모달 닫기
               	        const modal = bootstrap.Modal.getInstance(document.getElementById('groupChatModal'));
               	        if(modal) modal.hide();
               	        
               	        // 🌟 분리된 채팅창 띄우기 (기존 함수 재활용)
               	        if (typeof window.enterChatRoom === 'function') {
               	            window.enterChatRoom(res.data.chatRmNo, title);
               	        }
               	    }).catch(err => {
               	        console.error("방 생성 실패:", err);
               	    });
               	};
               	
             	// 5. 사원 목록 필터링 및 리스트 그리기
               	window.filterGroupEmployeeList = function() {
				    const searchInput = document.getElementById('empSearchInput'); // 모달 검색창 ID
				    if (!searchInput) return;
				    
				    const keyword = searchInput.value.toLowerCase().trim();
				    // 모달 내의 사원 아이템과 부서 헤더들만 선택
				    const items = document.querySelectorAll('#modalEmpListForGroup .group-emp-item');
				    const headers = document.querySelectorAll('#modalEmpListForGroup .dept-header');
				
				    // 1. 각 사원별 필터링 및 체크박스 상태 동기화
				    items.forEach(item => {
				        const text = item.innerText.toLowerCase();
				        const checkbox = item.querySelector('input[type="checkbox"]');
				        
				        if (checkbox) {
				            const empId = checkbox.id.replace('chk_', ''); // 'chk_123' -> '123'
				            
				            // 🌟 [추가된 로직] 현재 채팅방 참여자인지 확인
				            const isParticipant = currentChatParticipants.some(id => String(id) === String(empId));
				            
				            if (isParticipant) {
				                // 기존 참여자라면: 체크박스 비활성화 및 스타일 처리
				                checkbox.checked = true; // 참여 중이므로 체크된 상태로 고정 (또는 기획에 따라 해제)
				                checkbox.disabled = true;
				                item.style.opacity = '0.5'; // 블랭크(흐리게) 처리
				                item.style.cursor = 'not-allowed';
				                item.onclick = null; // 클릭 이벤트 제거
				            } else {
				                // 일반 사원이라면: 선택 배열(selectedForInvite)에 있는지 확인하여 체크 상태 유지
				                checkbox.checked = selectedForInvite.some(emp => String(emp.id) === String(empId));
				                checkbox.disabled = false;
				                item.style.opacity = '1';
				                item.style.cursor = 'pointer';
				            }
				        }
				
				        // 키워드 필터링 (기존 로직 유지)
				        if (text.includes(keyword)) {
				            item.style.setProperty('display', 'flex', 'important');
				        } else {
				            item.style.setProperty('display', 'none', 'important');
				        }
				    });
				
				    // 2. 부서별 필터링 (기존 로직 유지)
				    headers.forEach(header => {
				        const deptBody = header.nextElementSibling;
				        if (deptBody && deptBody.classList.contains('dept-body')) {
				            const hasVisibleMember = Array.from(deptBody.querySelectorAll('.group-emp-item'))
				                                          .some(item => item.style.display !== 'none');
				            
				            header.style.display = hasVisibleMember ? 'flex' : 'none';
				        }
				    });
				};
               	
             	// 6. 참여자 목록 사이드바 토글
               	window.toggleParticipantList = function(rmNo) {
				    // enterChatRoom에서 만든 오버레이 ID를 정확히 찾습니다.
				    const sidebar = document.getElementById('participantOverlay_' + rmNo);
				    
				    if (!sidebar) {
				        console.error("❌ 해당 방의 참여자 오버레이를 찾을 수 없습니다:", rmNo);
				        return;
				    }
				
				    // 현재 열려있는지 확인 (right 값이 0이면 열린 상태)
				    const isClosed = (sidebar.style.right === '-100%' || sidebar.style.right === '');
				
				    if (isClosed) {
				        // [열기] 슬라이드 인
				        sidebar.style.right = '0';
				        console.log("🚀 [" + rmNo + "] 참여자 목록 요청 중...");
				
				        // 데이터 가져오기
				        const url = (window.CP || "") + "/chat-api/roomParticipants";
				        axios.get(url, { params: { chatRmNo: rmNo } })
				            .then(res => {
				                console.log("✅ 데이터 수신:", res.data);
				                window.renderMiniParticipantList(res.data, rmNo);
				            })
				            .catch(err => {
				                console.error("❌ 로드 에러:", err);
				                const listArea = document.getElementById('participantList_' + rmNo);
				                if(listArea) listArea.innerHTML = '<div style="padding:10px; color:red;">로드 실패</div>';
				            });
				    } else {
				        // [닫기] 다시 밖으로 밀기
				        sidebar.style.right = '-100%';
				    }
				};
				
				// 2. 렌더링 함수 (채팅창 내부 전용)
				window.renderMiniParticipantList = function(userList, rmNo) {
				    const listArea = document.getElementById('participantList_' + rmNo);
				    if (!listArea) return;
				
				    const actualList = Array.isArray(userList) ? userList : (userList.data || []);
				    const cpPath = window.CP || "";
				    // 기본 이미지 경로 (프로젝트 상황에 맞게 확인 필요)
				    const defaultImg = cpPath + '/resources/img/default-avatar.png'; 
				
				    let html = '';
				    actualList.forEach(user => {
				        const name = user.chatUserNm || '이름없음';
				        const job = user.chatUserAuth || '';
				        const profile = user.empProfile;
				        
				        // 1. 프로필이 있으면 해당 경로, 없으면 기본 이미지
				        let profileImg = (profile && profile !== 'null' && profile !== '') 
				                         ? (cpPath + '/profile/' + encodeURIComponent(profile)) 
				                         : defaultImg;
				
				        html += '<div style="display:flex; align-items:center; padding:10px; border-bottom:1px solid #f0f0f0;">';
				        
				        // 🌟 onerror="this.onerror=null; ..." 이 부분이 무한 루프를 막는 핵심입니다!
				        html += '  <img src="' + profileImg + '" ' +
				                '       onerror="this.onerror=null; this.src=\'' + defaultImg + '\';" ' + 
				                '       style="width:30px; height:30px; border-radius:50%; margin-right:10px; object-fit:cover; border:1px solid #eee;">';
				        
				        html += '  <div style="display:flex; flex-direction:column; line-height:1.2;">' +
				                '    <div style="font-size:13px; font-weight:bold; color:#333;">' + name + '</div>' +
				                '    <div style="font-size:11px; color:#888;">' + job + '</div>' +
				                '  </div>' +
				                '</div>';
				    });
				
				    listArea.innerHTML = html || '<div style="padding:20px; text-align:center; color:#999; font-size:12px;">참여자가 없습니다.</div>';
				    console.log("✅ [" + rmNo + "] 참여자 목록 출력 완료 (무한루프 방지 적용)");
				};
				
				window.toggleParticipantSidebar = window.toggleParticipantList;
               	
             	// 1. 선택된 사원들을 담을 배열 (전역 변수)
               	let selectedForInvite = [];
				let allEmployeeList = []; // 🌟 실제 프로젝트의 사원 데이터 배열로 채워야 합니다!
				let currentChatParticipants = []; // 🌟 현재 방의 참여자 ID 배열로 채워야 합니다!

               	// 2. 초대 모달 열기 함수 (추가)
				// 1. 초대 모달 열기 (리스트 새로 그리기 및 초기화)
				
				window.openInviteModalInMessenger = function(rmNo) {
				    // 1. 초기화 및 UI 설정
				    window.selectedForInvite = []; 
				    const selectedContainer = document.getElementById('selectedEmployees');
				    if (selectedContainer) selectedContainer.innerHTML = '';
				    
				    window.currentlyJoinedIds = []; 
				    window.currentlyJoinedNames = [];

				    // UI 요소 제어
				    const modalTitle = document.querySelector('#groupChatModal .modal-title');
				    if (modalTitle) modalTitle.innerText = "초대하기";
				    const titleArea = document.getElementById('groupChatTitle');
				    if (titleArea) titleArea.parentElement.style.display = 'none';
				    const searchInput = document.getElementById('empSearchInput');
				    if (searchInput) searchInput.value = '';

				    // 🌟 [수정 포인트] 참여자 데이터를 가져오는 "진짜" 주소를 입력해야 합니다.
				    // 기존에 참여자 리스트 아이콘 눌렀을 때 작동하던 API 주소를 확인해 보세요.
				    const participantApiUrl = window.CP + '/chat-api/roomParticipants'; // 혹은 '/chat-api/getParticipants' 등

				    const getParticipants = axios.get(participantApiUrl, { params: { chatRmNo: rmNo } });
				    const getInviteList = axios.get(window.CP + '/chat-api/inviteList', { params: { chatRmNo: rmNo } });

				    // 2. 두 가지 데이터를 동시에 가져오기
				    axios.all([getParticipants, getInviteList])
				       .then(axios.spread((partRes, inviteRes) => {
				           // 참여자 사번 추출
				           window.currentlyJoinedIds = (partRes.data || []).map(p => String(p.empId || p.participantId).trim());
				           console.log("✅ 참여자 확인 완료:", window.currentlyJoinedIds);

				           // 전체 사원 명단 저장
				           window.allEmployeeList = inviteRes.data; 
				           window.currentInviteRmNo = rmNo;

				           if (typeof window.renderInviteModalEmployeeList === 'function') {
				               window.renderInviteModalEmployeeList();
				           }
				            
				            var modalEl = document.getElementById('groupChatModal');
				            if (modalEl) {
				                bootstrap.Modal.getOrCreateInstance(modalEl).show();
				            }
				        }))
				       .catch(err => {
				           // 🌟 만약 여기서 또 404가 난다면, 참여자 리스트 API 주소가 틀린 것입니다.
				           console.error("데이터 로드 실패 (주소 확인 필요):", err);
				           
				           // [플랜 B] 만약 주소를 모른다면, 일단 초대 리스트만이라도 띄웁니다.
				           axios.get(window.CP + '/chat-api/inviteList', { params: { chatRmNo: rmNo } })
				                .then(res => {
				                    window.allEmployeeList = res.data;
				                    window.renderInviteModalEmployeeList();
				                    bootstrap.Modal.getOrCreateInstance(document.getElementById('groupChatModal')).show();
				                });
				       });
				    
				    // 버튼 처리
				    const footerBtn = document.querySelector('#groupChatModal .btn-primary');
				    if (footerBtn) {
				        footerBtn.innerText = "초대하기";
				        footerBtn.onclick = function() { window.executeInvite(rmNo); };
				    }
				};
				
				// 2. 🌟 [핵심 추가] 모달 내 사원 리스트를 실제로 그리는 함수 (체크박스 비활성화 포함)
				window.renderInviteModalEmployeeList = function() {
				    const listContainer = document.getElementById('modalEmpListForGroup');
				    if (!listContainer) return;
				    
				    const targetData = window.allEmployeeList || [];
				    if (targetData.length === 0) {
				        listContainer.innerHTML = '<div style="text-align:center; padding:20px; font-size:12px; color:#888;">사원 목록 로드 중...</div>';
				        return;
				    }
				
				    listContainer.innerHTML = ''; 
				    const joinedIds = (window.currentlyJoinedIds || []).map(id => String(id).trim());
				    const currentLoginId = String(window.loginUserId || "").trim();
				    
				    const defaultSvg = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='35' height='35' viewBox='0 0 35 35'%3E%3Crect width='35' height='35' fill='%23eeeeee'/%3E%3C/svg%3E";
				
				    let html = '';
				    let lastDept = '';
				    let deptIdx = 0;
				
				    targetData.forEach(function(emp) {
				        const empId = String(emp.empId || "").trim();
				        const originalNm = String(emp.empNm || "이름없음").trim();
				        const safeNm = originalNm.replace(/'/g, ""); 
				        
				        if (empId === currentLoginId) return; 
				
				        const isParticipant = (
				            joinedIds.includes(empId) || 
				            String(emp.isJoined) === "1" || String(emp.isJoined).toUpperCase() === "Y" ||
				            String(emp.joinedYn) === "1" || String(emp.joinedYn).toUpperCase() === "Y" ||
				            String(emp.isParticipant) === "1" || String(emp.isParticipant).toUpperCase() === "Y"
				        );
				
				        const deptNm = emp.deptNm || "소속없음";
				
				        if (lastDept !== deptNm) {
				            if (lastDept !== "") html += '</div></div>';
				            deptIdx++;
				            html += '<div class="dept-group-wrapper">' +
				                    '<div class="dept-header p-2 bg-light" style="font-size:12px; font-weight:bold; color:#696cff; border-bottom:1px solid #eee;">' +
				                    '<span><i class="bx bx-group"></i> ' + deptNm + '</span>' +
				                    '</div>' +
				                    '<div id="modalInviteDept' + deptIdx + '" class="dept-body">';
				            lastDept = deptNm;
				        }
				
				        let profileImg = (emp.empProfile && emp.empProfile !== 'null') 
				            ? (window.CP || '') + '/profile/' + encodeURIComponent(emp.empProfile)
				            : defaultSvg;
				
				        const isSelected = window.selectedForInvite && window.selectedForInvite.some(item => {
				            const selectedId = (typeof item === 'object') ? item.id : item;
				            return String(selectedId).trim() === empId;
				        });
				
				        const rowClass = isParticipant ? 'group-emp-item participant-locked' : 'group-emp-item clickable';
				        const itemStyle = isParticipant 
				            ? 'background-color:#f0f2f5 !important; opacity:0.7; pointer-events:none !important; cursor:not-allowed;' 
				            : 'cursor:pointer;';
				
				        html += '<div class="' + rowClass + ' d-flex align-items-center p-3 border-bottom" style="' + itemStyle + '" ' +
				                'data-id="' + empId + '" data-name="' + safeNm + '" data-participant="' + isParticipant + '">' +
				                '<div class="me-3">' +
				                // 🌟 [핵심 수정] input 태그에 id="chk_' + empId + '" 를 추가했습니다.
				                // 이 ID가 있어야 toggleEmployeeSelection 함수가 체크박스를 찾아낼 수 있습니다.
				                '<input type="checkbox" id="chk_' + empId + '" class="form-check-input" ' + 
				                (isParticipant ? 'checked disabled' : (isSelected ? 'checked' : '')) + 
				                (isParticipant ? ' style="background-color:#696cff !important; border-color:#696cff !important; opacity:1 !important;"' : '') +
				                '></div>' +
				                '<img src="' + profileImg + '" class="emp-profile-img" style="width:35px; height:35px; border-radius:50%; margin-right:12px; object-fit:cover; ' + (isParticipant ? 'filter:grayscale(1);' : '') + '">' +
				                '<div class="flex-grow-1" style="font-size:13px;">' +
				                '<strong style="font-weight:bold; color:' + (isParticipant ? '#aaa' : '#333') + ';">' + originalNm + '</strong> ' +
				                '<span style="color:#bbb; font-size:11px; margin-left:5px;">' + (emp.empJbgd || '사원') + '</span>' +
				                (isParticipant ? '<span class="badge bg-label-secondary ms-2" style="font-size:10px;">참여 중</span>' : '') +
				                '<div class="small text-muted" style="font-size:11px;">사번: ' + empId + '</div>' +
				                '</div></div>';
				    });
				
				    listContainer.innerHTML = html + (html !== '' ? '</div></div>' : '');
				
				    listContainer.querySelectorAll('.group-emp-item').forEach(item => {
				        const img = item.querySelector('.emp-profile-img');
				        if (img) { img.onerror = function() { this.onerror = null; this.src = defaultSvg; }; }
				
				        if (item.dataset.participant !== 'true') {
				            item.onclick = function() {
				                window.toggleEmployeeSelection(this.dataset.id, this.dataset.name);
				            };
				        }
				    });
				};

				// 3. 사원 선택/해제 및 뱃지 연동 (유지)
				window.toggleEmployeeSelection = function(empId, empNm) {
				    // 1. [기존 유지] 서버에서 가져온 전체 목록에서 해당 사원의 참여 여부를 확인
				    // allEmployeeList가 상단에 선언된 let 변수를 참조하도록 합니다.
				    const targetEmp = (window.allEmployeeList || allEmployeeList).find(function(e) {
				        return String(e.empId).trim() === String(empId).trim();
				    });
				
				    // 🌟 참여 중인 사원은 클릭 이벤트 자체를 무시 (이미 참여 중인 경우 종료)
				    if (targetEmp && (Number(targetEmp.isJoined) > 0 || String(targetEmp.isJoined).toUpperCase() === 'Y')) {
				        console.log("이미 참여 중인 사원은 선택할 수 없습니다.");
				        return; 
				    }
				
				    // 2. [데이터 타입 통일] 선택 배열(selectedForInvite)에서 중복 확인
				    // String().trim()을 사용하여 공백이나 타입 차이로 인한 미인식 방지
				    const targetId = String(empId).trim();
				    const index = selectedForInvite.findIndex(function(emp) {
				        return String(emp.id).trim() === targetId;
				    });
				    
				    const checkbox = document.getElementById('chk_' + targetId);
				
				    if (index > -1) {
				        // 이미 선택된 경우 -> 제거 (선택 취소)
				        selectedForInvite.splice(index, 1);
				        if (checkbox) checkbox.checked = false;
				        console.log("➖ 선택 해제:", empNm, "(현재 선택 인원:", selectedForInvite.length, "명)");
				    } else {
				        // 새로 선택하는 경우 -> 객체 형태로 추가
				        // 🌟 여기서 데이터가 제대로 들어가야 나중에 '초대하기' 버튼을 눌렀을 때 인식이 됩니다.
				        selectedForInvite.push({ id: targetId, name: empNm });
				        if (checkbox) checkbox.checked = true;
				        console.log("➕ 선택 추가:", empNm, "(현재 선택 인원:", selectedForInvite.length, "명)");
				    }
				
				    // 3. [기존 유지] 상단 뱃지 영역 다시 그리기
				    if (typeof renderSelectedBadges === 'function') {
				        renderSelectedBadges(); 
				    } else {
				        console.warn("renderSelectedBadges 함수를 찾을 수 없습니다.");
				    }
				};

				// 4. 선택된 사원 뱃지 그리기 (유지)
				function renderSelectedBadges() {
				    const container = document.getElementById('selectedEmployees');
				    if (!container) return;
				    
				    container.innerHTML = ''; // 기존 뱃지 초기화
				
				    selectedForInvite.forEach(function(emp) {
				        // 🌟 예제 스타일의 뱃지 HTML 생성
				        const badge = document.createElement('span');
				        
				        // ID 설정 (나중에 삭제 시 참조용)
				        badge.id = 'badge-invite-' + emp.id;
				        
				        // 예제와 동일한 클래스 및 스타일 적용
				        badge.className = 'badge bg-primary d-flex align-items-center gap-1';
				        badge.style.padding = '6px 10px';
				        badge.style.borderRadius = '20px';
				        badge.style.fontSize = '12px';
				        badge.style.margin = '2px';
				        badge.style.fontWeight = 'normal';
				        badge.style.backgroundColor = '#696cff !important'; // 보라색 포인트 컬러
				        
				        // 뱃지 내부 내용 (이름 + X 아이콘)
				        badge.innerHTML = 
				            '<span>' + emp.name + '</span>' + 
				            '<i class="bx bx-x" style="cursor:pointer; font-size:16px; margin-left:2px;" ' +
				            'onclick="event.stopPropagation(); window.toggleEmployeeSelection(\'' + emp.id + '\', \'' + emp.name + '\')"></i>';
				        
				        container.appendChild(badge);
				    });
				}
               	
				window.executeInvite = function(rmNo) {
				    // 1. [데이터 확보] 전역 변수와 일반 변수 모두 체크 (안전 장치)
				    // 🌟 이 부분이 비어 있으면 "초대할 사원을 선택해주세요" 경고가 뜹니다.
				    const targetList = (window.selectedForInvite && window.selectedForInvite.length > 0) 
				                       ? window.selectedForInvite 
				                       : (typeof selectedForInvite !== 'undefined' ? selectedForInvite : []);
				    
				    // 데이터 유효성 검사
				    if (!targetList || targetList.length === 0) {
				        alert("초대할 사원을 선택해주세요.");
				        return;
				    }

				    // 2. [사번 추출] 객체 형태({id: '...', name: '...'})에서 ID만 쏙 뽑기
				    const finalEmpIds = targetList.map(function(item) {
				        if (typeof item === 'object' && item !== null) {
				            return String(item.id || item.empId || "").trim();
				        }
				        return String(item).trim(); 
				    }).filter(function(id) {
				        return id !== "" && id !== "undefined" && id !== "null";
				    });

				    if (finalEmpIds.length === 0) {
				        alert("선택된 사원의 정보가 올바르지 않습니다.");
				        return;
				    }

				    if (!confirm(finalEmpIds.length + "명의 사원을 초대하시겠습니까?")) return;

				    // 3. 서버 전송 데이터 구성 (서버 API 명세에 맞춤)
				    const inviteData = {
				        chatRmNo: rmNo,         
				        inviteIdList: finalEmpIds 
				    };

				    console.log("🚀 서버로 쏘는 최종 데이터:", inviteData);

				    // 4. 서버 요청 (fetch 사용)
				    fetch((window.CP || '') + '/chat-api/invite', {
				        method: 'POST',
				        headers: { 'Content-Type': 'application/json' },
				        body: JSON.stringify(inviteData)
				    })
				    .then(function(res) { return res.text(); })
				    .then(function(data) {
				        // 서버 응답이 success를 포함하고 있다면 성공 처리
				        if(data === "success" || data.indexOf("success") !== -1) {
				            alert("사원들을 성공적으로 초대했습니다.");
				            
				            // 🌟 [동기화] 새로 초대된 사번들을 '현재 참여자 목록'에 추가하여 다시 초대 못 하게 막음
				            const newIds = finalEmpIds.map(function(id) { return String(id).trim(); });
				            window.currentlyJoinedIds = [...new Set([...(window.currentlyJoinedIds || []), ...newIds])];

				            // 5. 후속 작업 (UI 정리)
				            // 모달 닫기
				            const modalElement = document.getElementById('groupChatModal');
				            if (modalElement) {
				                const modalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
				                modalInstance.hide();
				            }
				            
				            // 참여자 목록 즉시 갱신 (사이드바 등)
				            if (typeof window.toggleParticipantList === 'function') {
				                window.toggleParticipantList(rmNo);
				            }
				            
				            // 🌟 [중요] 선택 목록 완전 초기화 (전역/지역 변수 모두)
				            window.selectedForInvite = [];
				            if (typeof selectedForInvite !== 'undefined') selectedForInvite = [];
				            
				            const selectedContainer = document.getElementById('selectedEmployees');
				            if (selectedContainer) selectedContainer.innerHTML = '';
				            
				            // 초대창 목록 다시 그리기 (방금 추가된 참여자들은 이제 비활성화됨)
				            if (typeof renderInviteModalEmployeeList === 'function') {
				                renderInviteModalEmployeeList();
				            }
				            
				        } else {
				            alert("초대 실패: " + data);
				        }
				    })
				    .catch(function(err) {
				        console.error("🔥 초대 중 오류 발생:", err);
				        alert("서버와 통신 중 오류가 발생했습니다.");
				    });
				};
				
				window.leaveChatRoom = function() {
				    // 1. 사용자 확인
				    if (!confirm("채팅방을 나가시겠습니까?\n나간 채팅방의 대화 내용은 복구할 수 없습니다.")) {
				        console.log("퇴장 취소됨");
				        return;
				    }

				    // 2. 현재 방 번호 확인
				    const rmNo = window.currentChatRmNo; 
				    if (!rmNo) {
				        alert("나갈 채팅방 정보를 찾을 수 없습니다.");
				        return;
				    }

				    // 3. 서버에 퇴장 요청 전송 (AJAX)
				    $.ajax({
				        url: '/chat-api/leaveRoom', 
				        method: 'POST',
				        contentType: 'application/json', 
				        data: JSON.stringify({ chatRmNo: rmNo }), 
				        success: function(response) {
				            if (response === "success") {
				                
				                // 🚩 [수정] 직접 소켓을 보내던 window.chatSocket.send 부분을 삭제했습니다.
				                // 이제 서버(Java)에서 "000님이..." 라고 한 번만 쏴줄 것입니다.

				                alert("채팅방에서 나갔습니다.");
				                
				                // 5. 화면 정리 (기존 로직 유지)
				                const chatWin = document.getElementById('chatWin_' + rmNo);
				                if (chatWin) chatWin.remove();
				                
				                let savedRooms = JSON.parse(sessionStorage.getItem('openChatRooms') || "[]");
				                savedRooms = savedRooms.filter(r => r.rmNo != rmNo);
				                sessionStorage.setItem('openChatRooms', JSON.stringify(savedRooms));

				                if (typeof window.loadChatRoomList === 'function') {
				                    window.loadChatRoomList();
				                }
				                
				                window.currentChatRmNo = null;

				            } else {
				                alert("퇴장 처리에 실패했습니다.");
				            }
				        },
				        error: function(xhr) {
				            console.error("퇴장 에러:", xhr);
				            alert("퇴장 처리 중 서버 오류가 발생했습니다.");
				        }
				    });
				};
				
				window.inviteUsers = function(chatRmNo, inviteIdList, invitedNames) {
				    // 1. 초대할 데이터 준비
				    const sendData = {
				        chatRmNo: chatRmNo,
				        inviteIdList: inviteIdList // 초대할 사원 번호 리스트 [1, 2, 3]
				    };

				    // 2. 서버에 초대 요청 전송 (AJAX)
				    $.ajax({
				        url: '/chat-api/invite', 
				        method: 'POST',
				        contentType: 'application/json',
				        data: JSON.stringify(sendData),
				        success: function(res) {
				            // 서버 응답이 "success"인 경우
				            if (res === "success" || res.status === "success") {
				                
				                // 🚩 [실시간 소켓 알림 추가] 
				                // 초대된 사람들과 현재 방에 있는 사람들에게 실시간 문구 전송
				                if (window.chatSocket && window.chatSocket.readyState === 1) {
				                    window.chatSocket.send(JSON.stringify({
				                        chatRmNo: chatRmNo,
				                        // 🚩 시스템 메시지 문구 (참여하였습니다 문구 포함)
				                        chatCn: invitedNames + "님이 채팅방에 참여하였습니다.",
				                        empId: window.loginUserId // 보낸 사람(나)
				                    }));
				                }

				                console.log("초대 성공 및 실시간 메시지 발송 완료");

				                // 3. (옵션) 초대 창 닫기나 리스트 갱신 등 추가 로직
				                if (typeof window.loadChatRoomList === 'function') {
				                    window.loadChatRoomList();
				                }
				                
				                // 성공 알림 (필요 시)
				                // alert("사원들을 성공적으로 초대했습니다.");

				            } else {
				                alert("사원 초대에 실패했습니다.");
				            }
				        },
				        error: function(xhr) {
				            console.error("초대 에러:", xhr);
				            alert("초대 처리 중 오류가 발생했습니다.");
				        }
				    });
				};
				const chatInput = document.getElementById('chatMessageInput');

				if (chatInput) {
				    chatInput.addEventListener('paste', function(e) {
				        // 클립보드 데이터 확인
				        const items = (e.clipboardData || e.originalEvent.clipboardData).items;
				        
				        for (let i = 0; i < items.length; i++) {
				            if (items[i].type.indexOf('image') !== -1) {
				                // 1. 이미지 파일 추출
				                const blob = items[i].getAsFile();
				                const reader = new FileReader();
				                
				                reader.onload = function(event) {
				                    // 2. 입력창 안에 이미지 미리보기 태그 삽입
				                    const img = document.createElement('img');
				                    img.src = event.target.result;
				                    img.className = 'pasted-image'; // 스타일 적용용 클래스
				                    
				                    // 기존 텍스트 뒤에 이미지 추가
				                    chatInput.appendChild(img);
				                    
				                    // 포커스를 마지막으로 이동
				                    chatInput.focus();
				                    const range = document.createRange();
				                    range.selectNodeContents(chatInput);
				                    range.collapse(false);
				                    const sel = window.getSelection();
				                    sel.removeAllRanges();
				                    sel.addRange(range);
				                };
				                
				                reader.readAsDataURL(blob);
				                
				                // 3. 텍스트로 경로가 들어가는 기본 동작 방지
				                e.preventDefault(); 
				            }
				        }
				    });
				}
				
				/* =================================================================
				   [1] 파일 선택창 호출 (방별 고유 ID 대응)
				   ================================================================= */
				window.fileUploadPrompt = function(rmNo) {
				    const fileInput = document.getElementById('chatFileIdx_' + rmNo);
				    if (fileInput) {
				        fileInput.click();
				    } else {
				        console.error("방번호 [" + rmNo + "] 의 파일 입력창을 찾을 수 없습니다.");
				    }
				};

				// [2] 파일 데이터를 담을 객체 (전역 유지)
				window.pendingFiles = window.pendingFiles || {};

				/* =================================================================
				   [3] 파일 선택 시 처리 (handleFileSelect)
				   ================================================================= */
				window.handleFileSelect = function(input, rmNo) {
				    if (input.files && input.files.length > 0) {
				        const files = Array.from(input.files);
				        processFiles(files, rmNo); // 방 번호를 같이 넘겨줌
				        input.value = ''; // 동일 파일 재선택 가능하게 초기화
				    }
				};

				/* =================================================================
				   [4] 파일 처리 및 미리보기 생성 (processFiles)
				   ================================================================= */
				   function processFiles(files, rmNo) {
					    // 🔍 [디버깅] 콘솔 확인용
					    console.log("🚩 [STEP 4] 파일 처리 시작 (방번호: " + rmNo + ")", files);

					    if (!rmNo) rmNo = 'temp'; 
					    
					    // 🌟 [추가] 객체가 없으면 에러가 나므로 반드시 초기화 확인
					    window.pendingFiles = window.pendingFiles || {};
					    if (!window.pendingFiles[rmNo]) window.pendingFiles[rmNo] = [];

					    // HTML ID 참조
					    const previewContainer = document.getElementById('filePreviewContainer_' + rmNo);
    					const previewArea = document.getElementById('filePreviewArea_' + rmNo);

					    if (!previewArea || !previewContainer) {
					        console.error("🚨 에러: 미리보기 영역을 찾을 수 없습니다. (ID 확인 필수: filePreviewContainer, filePreviewArea)");
					        return;
					    }

					    files.forEach(file => {
					        const fileId = 'file_' + Date.now() + '_' + Math.floor(Math.random() * 1000);
					        
					        // 데이터 저장
					        window.pendingFiles[rmNo].push({ id: fileId, file: file });
					        
					        // 파일 사이즈 계산
					        const fileSize = (file.size < 1024 * 1024) 
					                         ? (file.size / 1024).toFixed(1) + " KB" 
					                         : (file.size / (1024 * 1024)).toFixed(1) + " MB";

					        // [기존 유지] UI 생성 HTML (문자열 결합 방식 유지)
					        const html = 
					            '<div id="' + fileId + '" class="file-preview-item" style="display:flex !important; align-items:center !important; background:#f4f5ff; border:1px solid #d2d6ff; border-radius:8px; padding:10px; margin-bottom:5px; width:100%; box-sizing:border-box;">' +
					                '<div style="flex-shrink:0; margin-right:12px;">' +
					                    '<i class="bx bxs-file" style="font-size:24px; color:#696cff; display:block;"></i>' +
					                '</div>' +
					                '<div style="flex:1; min-width:0; overflow:hidden;">' +
					                    '<div title="' + file.name + '" style="font-weight:600; font-size:14px; color:#333 !important; text-overflow:ellipsis; white-space:nowrap; overflow:hidden; display:block !important; text-align:left;">' +
					                        file.name + 
					                    '</div>' +
					                    '<div style="font-size:11px; color:#8e94a9 !important; display:block !important; text-align:left; margin-top:2px;">' +
					                        fileSize + 
					                    '</div>' +
					                '</div>' +
					                '<div style="flex-shrink:0; margin-left:10px;">' +
					                    '<button type="button" onclick="window.removeFile(\'' + rmNo + '\', \'' + fileId + '\')" style="background:none; border:none; color:#ff3e1d; cursor:pointer; padding:0; display:flex; align-items:center;">' +
					                        '<i class="bx bx-x-circle" style="font-size:20px;"></i>' +
					                    '</button>' +
					                '</div>' +
					            '</div>';

					        // 영역 하단에 추가
					        previewArea.insertAdjacentHTML('beforeend', html);
					    });

					    // 🌟 [수정] 미리보기 영역을 확실하게 노출시키고 스크롤 이동
					    if (window.pendingFiles[rmNo].length > 0) {
					        // 스타일 강제 부여 (display: none을 뚫기 위해)
					        previewContainer.style.setProperty('display', 'block', 'important');
					        previewArea.style.setProperty('display', 'block', 'important'); 
					        
					        // 스크롤을 최하단으로 내려서 방금 넣은 파일이 보이게 함
					        previewContainer.scrollTop = previewContainer.scrollHeight;
					        
					        console.log("✅ [성공] 미리보기 창 활성화 완료");
					    }
					}

				/* =================================================================
				   [5] 서버로 파일 전송 (uploadFilesToServer)
				   ================================================================= */
				   window.uploadFilesToServer = function(rmNo) {
					    const filesToUpload = window.pendingFiles[rmNo];

					    // 1. 올릴 파일이 없으면 즉시 null을 담은 Promise 반환
					    if (!filesToUpload || filesToUpload.length === 0) {
					        return Promise.resolve(null); 
					    }

					    const formData = new FormData();
					    filesToUpload.forEach((fileObj) => {
					        // 백엔드 @RequestParam("multipartFiles")와 매칭
					        formData.append("multipartFiles", fileObj.file); 
					    });
					    // 백엔드 @RequestParam("chatRmNo")와 매칭
					    formData.append("chatRmNo", rmNo);

					    // 2. AJAX 요청 자체를 리턴 (이게 있어야 호출부에서 await가 작동함)
					    return $.ajax({
					        url: (window.CP || "") + "/chat-api/upload", // ContextPath 대응
					        type: "POST",
					        data: formData,
					        processData: false,
					        contentType: false,
					        beforeSend: function(xhr) {
					            // CSRF 토큰이 필요한 경우 여기서 세팅
					            const header = $("meta[name='_csrf_header']").attr("content");
					            const token = $("meta[name='_csrf']").attr("content");
					            if(header && token) xhr.setRequestHeader(header, token); 
					        }
					    }).then(function(response) {
					        // 🌟 [핵심 수정] 서버(Controller)에서 Map으로 리턴하므로 response.fileId를 꺼내야 합니다.
					        console.log("✅ 서버 응답 전체 데이터:", response);
					        
					        // 컨트롤러의 result.put("fileId", fileGroupNo)와 매칭
					        let actualFileId = null;
								if (response && typeof response === 'object' && response.fileId) {
								    actualFileId = response.fileId; // Map으로 올 때
								} else {
								    actualFileId = response; // 값만 바로 올 때
								}
								
								console.log("✅ 최종 추출된 fileId:", actualFileId);
								return actualFileId;

					    }).catch(function(xhr) {
					        // 실패 시 에러 처리
					        console.error("❌ 파일 전송 실패:", xhr);
					        alert("파일 전송 중 오류가 발생했습니다.");
					        throw xhr; 
					    });
					};

				/* =================================================================
				   [6] 파일 삭제 (removeFile)
				   ================================================================= */
				window.removeFile = function(rmNo, fileId) {
				    const element = document.getElementById(fileId);
				    if (element) element.remove();

				    if (window.pendingFiles[rmNo]) {
				        window.pendingFiles[rmNo] = window.pendingFiles[rmNo].filter(item => item.id !== fileId);
				        
				        if (window.pendingFiles[rmNo].length === 0) {
				            const container = document.getElementById('filePreviewContainer_' + rmNo);
				            if(container) container.style.display = 'none';
				        }
				    }
				};
				
				/* 🌟 알림 카운트를 새로고침하는 함수 */
				function refreshAlarmCount() {
				    // 프로젝트에 기존에 구현된 알림 개수 조회 API가 있다면 그 URL을 사용하세요.
				    // 보통 /alarm/count 또는 /alarm/list 등의 경로를 사용합니다.
				    $.ajax({
				        url: '/alarm/count', // 실제 프로젝트의 알림 카운트 조회 경로로 수정 필요
				        type: 'GET',
				        success: function(count) {
				            // 알림 배지(Badge)의 ID를 찾아야 합니다. 
				            // 보통 header.jsp 등에 id="alarmCountBadge" 같은 식으로 되어있습니다.
				            let badge = $("#alarmCountBadge"); 
				            
				            if (count > 0) {
				                badge.text(count > 9 ? "9+" : count);
				                badge.show();
				            } else {
				                badge.hide();
				            }
				        },
				        error: function() {
				            console.log("알림 카운트 조회 실패");
				        }
				    });
				}
				
				// --------------------------------------------------------------------------------------------------------------------
	            // [alert] ------------------------------------------------------------
                window.showAlert = function(message, type = 'success') {
                    const iconMap = {
                        'success': 'check_circle',
                        'danger': 'error_outline',
                        'error': 'error_outline',
                        'warning': 'warning_amber',
                        'info': 'info'
                    };
                    const icon = iconMap[type] || 'notifications';
                    const theme = (type === 'danger' || type === 'error') ? 'error' : type;

                    AppAlert.autoClose('알림', message, icon, theme, 2000);
                };

	            // 프로젝트 구성원 전용 1:1 채팅 연결
                window.openProjectMemberChat = function(targetId, targetNm) {
                    const myId = String(window.loginUserId || "");
                    if (String(targetId) === myId) {
                        showAlert("자기 자신과는 대화할 수 없습니다.", "warning");
                        return;
                    }

                    const url = CP + "/chat-api/projectChatCreate";
                    const params = new URLSearchParams();
                    params.append('targetId', targetId);
                    params.append('targetNm', targetNm);

                    const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
                    const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
                    const headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
                    if (csrfHeader && csrfToken) headers[csrfHeader] = csrfToken;

                    fetch(url, { method: 'POST', headers: headers, body: params })
                        .then(res => res.json())
                        .then(data => {
                            const roomNo = data.chatRmNo || data.CHAT_RM_NO;
                            const roomTitle = data.chatRmTtl || data.CHAT_RM_TTL || targetNm;

                            if (roomNo) {
                                window.enterChatRoom(roomNo, roomTitle);
                            }
                        })
                        .catch(err => console.error("채팅 연결 실패:", err));
                };

	             	// 🔔 실시간 알림 숫자 배지 갱신 함수
	                window.updateAlarmCount = function() {
					    const cp = window.CP || "";

					    // 서버에서 '채팅 전용' 안 읽은 개수를 가져오는 경로라고 가정합니다.
					    axios.get(cp + "/alarm/getUnreadCount")
					        .then(res => {
					            // 1. 서버에서 가져온 실제 미읽음 개수 (숫자형 변환)
					            let count = parseInt(res.data) || 0;

					            // 🌟 [핵심 보강: 실시간 잔상 방지]
					            // 현재 사용자가 특정 채팅방(window.currentChatRmNo)을 보고 있다면
					            // 서버 DB 반영 속도와 상관없이 사용자의 눈에는 배지가 보이지 않아야 합니다.
					            if (window.currentChatRmNo && parseInt(window.currentChatRmNo) > 0) {
					                console.log("🛠️ [배지 강제 제어] 채팅 중인 방(" + window.currentChatRmNo + ") 감지 -> 숫자를 0으로 보정합니다.");
					                count = 0;
					            }

					            const chatBadge = document.getElementById('chatAlmCnt');

					            if (chatBadge) {
					                // 2. 최종 UI 출력 제어
					                if (count > 0) {
					                    // 실제 읽어야 할 '다른 방'의 알림이 있을 때만 표시
					                    chatBadge.innerText = count > 9 ? '9+' : count;
					                    chatBadge.style.display = 'flex';
					                    console.log("🔔 [배지 업데이트] 표시 개수: " + count);
					                } else {
					                    // count가 0이거나 현재 채팅 중인 경우 배지를 즉시 숨김
					                    chatBadge.innerText = '0';
					                    chatBadge.style.display = 'none';
					                    console.log("✅ [배지 업데이트] 알림 없음 또는 채팅 중으로 숨김 처리");
					                }
					            }

					            // 🌟 [추가 보강] 전체 알람 배지(almCnt)도 연동이 필요하다면 여기서 함께 제어 가능
					            // (필요 시 주석 해제하여 사용하세요)
					            /*
					            const totalBadge = document.getElementById('almCnt');
					            if (totalBadge && count === 0 && (!window.generalAlmCount || window.generalAlmCount === 0)) {
					                totalBadge.style.display = 'none';
					            }
					            */
					        })
					        .catch(err => {
					            console.error("❌ 알림 개수 조회 실패:", err);
					        });
					};

					// 전역 범위(window)에 함수를 정의해야 어디서든 호출 가능합니다.
					window.fixProfileImageError = function(container) {
					    if (!container) return;
					    const imgs = container.querySelectorAll('img');
					    imgs.forEach(img => {
					        if (!img.getAttribute('onerror_bound')) {
					            img.setAttribute('onerror_bound', 'true');
					            img.onerror = function() {
					                this.onerror = null; // 무한 루프 차단
					                // 서버에 실제 존재하는 기본 이미지 경로로 교체
					                this.src = (window.CP || "") + "/resources/img/default-avatar.png";
					                console.warn("⚠️ 프로필 로드 실패 -> 기본 이미지로 교체됨");
					            };
					        }
					    });
					};

        </script>

</body>
</html>