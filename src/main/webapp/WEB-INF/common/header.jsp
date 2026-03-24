<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/themes/default/style.min.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/jstree.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

<!-- 커스텀 알람 -->
<script src="/js/common-alert.js"></script>


<!-- 튜토리얼 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.css"/>
<script src="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.js.iife.js"></script>
<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal.EmpVO" var="userId"/>
</sec:authorize>


<style>
/* 조직도 스타일 */
.jstree-anchor > .material-icons { font-size: 18px !important; vertical-align: middle !important; margin-right: 5px; display: inline-flex !important; align-items: center; justify-content: center; }
.jstree-anchor {  display: inline-flex !important; align-items: center; height: 24px; }
.jstree-default .jstree-anchor.jstree-hovered { background: transparent !important; box-shadow: none !important; border: none !important; }
.jstree-default .jstree-anchor.jstree-clicked { background: transparent !important; box-shadow: none !important; }
.jstree-default .jstree-anchor.jstree-hovered, .jstree-default .jstree-anchor.jstree-clicked { color: inherit !important; }

/* 모달 디자인 커스텀 */
#passwordCheckModal .modal-content {
    border-radius: 15px; /* 모서리를 부드럽게 */
    overflow: hidden;
}

#passwordCheckModal .custom-input {
    border: 1px solid #eceef1;
    border-radius: 10px;
    transition: all 0.2s;
}

#passwordCheckModal .custom-input:focus {
    border-color: #696cff; /* 프로젝트 메인 컬러 */
    box-shadow: 0 0 0 0.25rem rgba(105, 108, 255, 0.1);
}

#passwordCheckModal .btn-primary {
    background-color: #696cff;
    border-color: #696cff;
}

#passwordCheckModal .btn-primary:hover {
    background-color: #5f61e6;
    box-shadow: 0 4px 8px rgba(105, 108, 255, 0.4);
}

/* 에러 메시지 애니메이션 */
#passwordError {
    animation: shake 0.3s;
}

@keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-5px); }
    75% { transform: translateX(5px); }
}

/* 기본 상태 (사이드바 있음) */
.main-wrapper {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    margin-left: 260px;
    width: calc(100% - 280px);
    transition: all 0.3s ease-in-out;
}

/* 사이드바가 접혔을 때 */
#sidebar.collapsed ~ .main-wrapper {
    margin-left: 0 !important;
    width: 100% !important;
}

/* 헤더 스타일 */
.header {
    width: 100% !important;
    height: 70px;
    background: #fff;
    display: flex;
    align-items: center;
    padding: 0 1.5rem;
    border-bottom: 1px solid #eceef1;
    position: sticky;
    top: 0;
    z-index: 1000;
}
/* 채팅 배지 위치 조정 */
.header-icon-btn {
    position: relative;
}
.badge-count {
    position: absolute;
    top: -5px;
    right: -5px;
    font-size: 10px;
    padding: 2px 5px;
    border-radius: 50%;
    color: white;
}

</style>

<header class="header">
    <button class="btn btn-link text-dark p-0" id="sidebarToggle" style="transition: all 0.3s ease;">
        <span class="material-icons">menu_open</span>
    </button>
    &nbsp; &nbsp; &nbsp; &nbsp;
    <button onclick="AiTutorial()" style="display: flex; align-items: center; gap: 5px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 5px 5px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.2s;" onmouseover="this.style.backgroundColor='#f8f9fa'" onmouseout="this.style.backgroundColor='#fff'">
        <span class="material-icons" style="font-size: 1.1rem;">help_outline</span> AI튜토리얼
    </button>
    <div class="ms-auto d-flex align-items-center">
        <div class="d-flex me-3 border-end pe-3">
            <!-- 식단표 -->
            <div class="dropdown">
                <a href="#" class="header-icon-btn" onclick="openDietModal()">
                    <span class="material-icons">restaurant</span>
                </a>
            </div>
            <div class="modal fade" id="mealModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog" style="width: 250px; max-width: 90%; margin-left:1050px; margin-top:50px;">
                    <div class="modal-content border-0 shadow">
                        <div class="modal-header bg-primary text-white" style="padding-left:45px;">
                            <h5 class="modal-title fw-bold d-flex align-items-center"  style="color: #ffffff !important;">
                                <span class="material-icons me-2" style="color: #ffffff !important;">restaurant</span> 주간 식단표
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body p-3" id="mealModalBody" style="max-height: 400px; overflow-y: auto;">
                            <div class="text-center py-5">
                                <div class="spinner-border text-primary" role="status"></div>
                                <p class="mt-2 text-muted">데이터 로드 중...</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- 채팅 -->
            <div class="dropdown">
			    <a href="javascript:void(0);" class="header-icon-btn" onclick="openChatMain()">
			        <span class="material-icons">chat_bubble_outline</span>
			        <span class="badge-count bg-success" id="chatAlmCnt" style="display:none;">0</span>
			    </a>
			    
			    <ul class="dropdown-menu dropdown-menu-end" id="chatDropdown">
			        <li class="dropdown-header-custom" id="chatDropdownHeader" style="padding: 10px 15px; font-weight: bold; border-bottom: 1px solid #eee;">
			            최근 채팅
			        </li>
			        <li id="noChatMsg">
			            <a class="dropdown-item py-2 text-muted" href="javascript:void(0);">새로운 채팅이 없습니다.</a>
			        </li>
			    </ul>
			</div>
			            <!--메일 -->
            <div class="dropdown">
                <a href="#" class="header-icon-btn" data-bs-toggle="dropdown">
                    <span class="material-icons">mail_outline</span>
                    <span class="badge-count bg-danger" id="mailCnt"></span>
                </a>
                <ul class="dropdown-menu dropdown-menu-end" id="mailAlarmDropdown">
                   <%-- <div style="display: flex; justify-content: space-evenly">
                        <span class="badge bg-warning" id="mailbadge" style="background-color: #7579FF !important; cursor: pointer;" onclick="location.href='/email/write'">메일쓰기</span>
                        <span class="badge bg-warning" id="mailbadge" style="background-color: #7579FF !important; cursor: pointer;" onclick="location.href='/email'">목록</span>
                    </div>--%>
                    <li class="dropdown-header-custom" id="mailAlarmDropdownHeader" style="text-align: center; border-bottom:1px solid #adb5bd;">새로운 메일이 없습니다.
                    </li>

                </ul>
            </div>
            <!--알람 -->
            <div class="dropdown">
                <a href="#" class="header-icon-btn" data-bs-toggle="dropdown" >
                    <span class="material-icons">notifications_none</span>
                    <span class="badge-count bg-warning" id="almCnt" ></span>
                </a>
                <ul class="dropdown-menu dropdown-mendashboardu-end" id="almDropdown">
                    <li class="dropdown-header-custom"id="almDropdownHeader" style="cursor: pointer; text-align: center; border-bottom:1px solid #adb5bd;"
                        onclick="location.href='/alarm/list'">새로운 알람이 없습니다.</li>
                </ul>
            </div>
            <!--  조직도  -->
         <div class="dropdown">
             <a href="#" class="header-icon-btn" data-bs-toggle="dropdown" id="orgChartBtn">
                 <span class="material-icons">account_tree</span>
             </a>
             <ul class="dropdown-menu dropdown-menu-end p-0 border-0 shadow" style="width: 280px;">
                 <li class="dropdown-header-custom border-bottom p-3">
                     <span class="fw-bold">전체 사원</span>
                 </li>
                 <li class="p-2">
                     <div id="mini-org-chart-wrapper" style="max-height: 400px; overflow-y: auto;">
                         <div id="header_jstree_div"></div>
                     </div>
                 </li>
             </ul>
         </div>
            <!-- // -->
        </div>
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none" data-bs-toggle="dropdown">
                <div class="text-end me-2 d-none d-sm-block">
                    <div class="fw-bold text-dark small">
                        <sec:authentication property="principal.empVO.empNm" />
                    </div>
                    <div class="text-muted" style="font-size: 0.7rem;">
                        <sec:authentication property="principal.empVO.empJbgd" />
                        / <sec:authentication property="principal.empVO.deptNm" />
                    </div>
                </div>
                  <sec:authentication property="principal.empVO.empProfile" var="userProfile" />
                    <c:choose>
                        <c:when test="${not empty userProfile and userProfile != ''}">
                            <img src="/displayPrf?fileName=${userProfile}"
                                id="previewProfile"
                                class="header-profile-img"
                                alt="Profile">
                        </c:when>
                        <c:otherwise>
                            <img src="/images/defaultProf.png" id="empProfile" class="mp-avatar" alt="Default Profile" 
     style="width: 45px; height: 45px; object-fit: cover; border-radius: 8px; border: 1px solid #ddd;">
                        </c:otherwise>
                    </c:choose>
                     
            </a>
            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-3">
                <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#passwordCheckModal">
                    <span class="material-icons me-2 v-align-middle">person_outline</span>프로필</a>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="logout dropdown-item py-2 text-danger"><span class="material-icons me-2 v-align-middle">logout</span>로그아웃</a></li>
            </ul>
        </div>
    </div>
</header>

<!-- 마이페이지 들어갈 때 비밀번호 확인 모달 시작 -->
<div class="modal fade" id="passwordCheckModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="width: 400px;">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold d-flex align-items-center">
                    <span class="material-icons text-primary me-2">lock_outline</span>
                    마이페이지
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body py-4">
                <p class="text-muted small mb-3">개인정보 보호를 위해 비밀번호를 입력해주세요.</p>

                <div class="form-floating mb-2">
                    <input type="password" id="confirmPassword" class="form-control custom-input" placeholder="비밀번호"
                           onkeyup="if(window.event.keyCode==13){verifyPassword()}">
                    <label for="confirmPassword" class="text-muted">비밀번호 입력</label>
                </div>

                <div id="passwordError" class="text-danger small d-flex align-items-center" style="display:none !important;">
                    <span class="material-icons src-icon me-1" style="font-size:16px;">error_outline</span>
                    비밀번호가 일치하지 않습니다.
                </div>
            </div>

            <div class="modal-footer border-top-0 pt-0 justify-content-center">
                <button type="button" class="btn btn-primary px-5 py-2 fw-bold" onclick="verifyPassword()" style="border-radius: 8px;">확인</button>
                <button type="button" class="btn btn-light px-4 py-2 text-muted" data-bs-dismiss="modal" style="border-radius: 8px;">취소</button>
            </div>
        </div>
    </div>
</div>
<!-- 마이페이지 들어갈 때 비밀번호 확인 모달 끝 -->

<script>
        // 1. 사이드바 토글 스크립트
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebar = document.getElementById('sidebar');
        const mainWrapper = document.getElementById('main-wrapper');

        sidebarToggle.addEventListener('click', () => {
            sidebar.classList.toggle('collapsed');
            const icon = sidebarToggle.querySelector('.material-icons');

            if (sidebar.classList.contains('collapsed')) {
                // sidebarToggle.style.left = "20px";
                icon.innerText = 'menu';
            } else {
                // sidebarToggle.style.left = "280px";
                icon.innerText = 'menu_open';
            }
        });


        // 비밀번호 확인 함수
        function verifyPassword() {
            const password = document.getElementById('confirmPassword').value;
            const errorMsg = document.getElementById('passwordError');

            axios.get('/emp/chkpw', {
                params: {
                    empPw: password
            }})
            .then(res => {
                if (res.data === true) {
                    password.innerText = "";
                    window.location.href = '/mypage';
                } else {
                    errorMsg.style.display = 'block';
                }
            })
            .catch(error => console.error('Error:', error));
        }

        // 로그아웃 스크립트
        const logout = document.querySelector(".logout");
        logout.addEventListener("click", () => {

            // 1. 로그아웃 확인 컨펌창
            // 아이콘 추천: 'logout', 테마: 'warning'
            AppAlert.confirm(
                '로그아웃 하시겠습니까?',
                '떠나기 전 퇴근을 확인하세요!',
                '로그아웃',
                '취소',
                'logout',
                'warning'
            ).then((result) => { // (알람 리팩토링)
                if (result.isConfirmed) {
                    axios.post('/logout')
                        .then((res) => {

                            // 2. 로그아웃 성공 알람 (Auto Close)
                            // 아이콘 추천: 'check_circle', 테마: 'success'
                            AppAlert.autoClose(
                                '로그아웃 완료',
                                '정상적으로 로그아웃 되었습니다.',
                                'check_circle',
                                'success',
                                1500
                            ).then(() => { // (알람 리팩토링)
                                location.href = "/";
                            });

                        })
                        .catch((err) => {
                            console.error("로그아웃 실패:", err);

                            // 3. 로그아웃 실패 에러창
                            // 아이콘 추천: 'error_outline'
                            AppAlert.error(
                                '오류',
                                '로그아웃 처리 중 문제가 발생했습니다.',
                                null,
                                'error_outline'
                            ); // (알람 리팩토링)
                        });
                }
            });
        });


       // 조직도 로드 함수
        function loadOrgChart() {
          const $treeDiv = $('#header_jstree_div');

          if ($treeDiv.jstree(true)) {
              $treeDiv.jstree('destroy');
          }

          // 1. 직급 순서 정의 (숫자가 작을수록 상단 노출)
          const rankPriority = { '대표': 1, '팀장': 2, '대리': 3, '주임': 4, '사원': 5 };

          axios.get("/indivList").then(res => {
              let treeData = [];
              res.data.forEach(dept => {
                  // 부서 노드
                  treeData.push({
                      id: "D" + dept.deptCd,
                      parent: "#",
                      text: dept.deptNm,
                      type: "dept"
                  });

                  if (dept.teamLeaders) {
                      dept.teamLeaders.forEach(leader => {
                          // 2. 팀장 노드 추가
                          treeData.push({
                              id: String(leader.empId),
                              parent: "D" + dept.deptCd,
                              text: `\${leader.empNm} (\${leader.empJbgd})`,
                              type: "leader"
                          });

                          if (leader.teamEmployee) {
                              // 3. 팀원 리스트를 정렬 (원본 보존을 위해 스프레드 연산자 사용)
                              const sortedMembers = [...leader.teamEmployee].sort((a, b) => {
                                  const priorityA = rankPriority[a.empJbgd] || 99;
                                  const priorityB = rankPriority[b.empJbgd] || 99;

                                  if (priorityA !== priorityB) {
                                      return priorityA - priorityB; // 직급 순 정렬
                                  }
                                  return a.empNm.localeCompare(b.empNm); // 같은 직급이면 이름 순
                              });

                              sortedMembers.forEach(member => {
                                  // 팀장과 중복되는 ID가 아닐 경우에만 추가
                                  if (String(member.empId) !== String(leader.empId)) {
                                      treeData.push({
                                          id: String(member.empId),
                                          parent: "D" + dept.deptCd,
                                          text: `\${member.empNm} (\${member.empJbgd})`,
                                          type: "default"
                                      });
                                  }
                              });
                          }
                      });
                  }
              });

              $treeDiv.jstree({
                  core: { data: treeData, check_callback: true, themes: { "dots": false } },
                  types: {
                      "dept": { "icon": "material-icons text-primary" },
                      "leader": { "icon": "material-icons text-warning" },
                      "default": { "icon": "material-icons text-secondary" }
                  },
                  plugins: ['wholerow', 'types']
              })
              // 부서명 클릭 시 하위 메뉴 오픈
              .bind("select_node.jstree", function (e, data) {
                  if(data.node.type === 'dept') {
                      // 이미 열려있으면 닫고, 닫혀있으면 엽니다
                      $(this).jstree('toggle_node', data.node);
                  }
              })

              .bind("ready.jstree open_node.jstree", function (e, data) {
                  const $tree = $(this);
                  $tree.find('.jstree-node').each(function() {
                      const type = $(this).attr('type');
                      const $icon = $(this).find('> .jstree-anchor > .jstree-icon');

                      if ($icon.text().trim() === "") {
                          if (type === 'dept') {
                              $icon.text('corporate_fare');
                          } else if (type === 'leader') {
                              $icon.text('person');
                          } else {
                              $icon.text('person_outline');
                          }
                      }
                  });
              });

              $treeDiv.one("ready.jstree", () => $treeDiv.jstree("close_all"));

          }).catch(err => {
              console.error("조직도 에러:", err);
          });
      }

        // 이벤트 바인딩
        $(document).ready(function() {
            // 드롭다운 내부 클릭 시 닫힘 방지
            $('#mini-org-chart-wrapper').on('click', function (e) {
                e.stopPropagation();
            });

            // 노드 클릭 시 전파 방지
            $(document).on('click', '.jstree-anchor', function (e) {
                e.stopPropagation();
            });

            // 드롭다운 열릴 때 트리 로드
            $('#orgChartBtn').on('show.bs.dropdown', function () {
                loadOrgChart();
            });

            // 조직도 - "전체 사원" 글자가 있는 헤더 영역 클릭 시 닫힘 방지
            $('.dropdown-header-custom').on('click', function (e) {
                e.stopPropagation();
            });

            // 식단표
            $('.dropdown').on('show.bs.dropdown', function () {
                const mealModalEl = document.getElementById('mealModal');
                if (mealModalEl && mealModalEl.classList.contains('show')) {
                    const mealModalInst = bootstrap.Modal.getInstance(mealModalEl);
                    if (mealModalInst) mealModalInst.hide();
                }
            });
        });


        document.addEventListener("DOMContentLoaded",async function mailAlarm(){
            // 메일 알람 가져오기 //
            axios.get("/email/mailAlarm").then(res => {
                    console.log("메일알람 - 안읽은 메일(헤더알람) 정보 :",res.data)
                    mails=res.data; //메일 알람 정보
                    let str='';
                    let cnt=0;

                    const mailCnt=document.getElementById("mailCnt")
                    const mailAlarmDropdown=document.getElementById("mailAlarmDropdown");
                    const mailAlarmDropdownHeader=document.getElementById("mailAlarmDropdownHeader");
                    cnt = mails.length>9? '9+':mails.length; //안읽은 메일 9개 이상이면 9+로 표시
                    document.getElementById("mailbadge").innerHTML=mails.length;
                    if(mails==null||mails.length==0){
                        $('#mailbadge').remove();
                    }
                    if(cnt==0){     //안읽은 메일이 없으면 배지 삭제
                        mailCnt.remove();
                    }else {
                        mailCnt.innerHTML=cnt; //배지 입력
                        mailAlarmDropdownHeader.innerHTML=`안 읽은 메일`;
                        let mailcnt=0;
                        mails.forEach(mail=>{
                            // <li> 요소 생성
                            const li = document.createElement('li');
                            // <a> 요소 생성 및 속성 설정
                            const a = document.createElement('a');
                            a.className = "dropdown-item py-2";
                            a.href = `/email/detail/\${mail.emlRcvrId}`; // 실제 상세페이지 경로로 연결
                            a.className = "dropdown-item py-2 text-truncate";
                            a.style.maxWidth = "300px";
                            a.innerHTML = `<span style="font-weight: bold;">[\${mail.deptNm || '외부'}]</span>
                    <span style="\${mail.emlEmrgYn==='Y'? 'color:red; font-weight: bold;':''}">\${mail.emlTtl}</span>`;
                            // 조립
                            if(mailcnt<9){
                            li.appendChild(a);
                            mailAlarmDropdown.appendChild(li);
                                mailcnt++;
                            }else if(mailCnt==9){
                                // <li> 요소 생성
                                const li3 = document.createElement('li');
                                // <a> 요소 생성 및 속성 설정
                                const a3 = document.createElement('a');
                                a3.className = "dropdown-item py-2";
                                a3.className = "dropdown-item py-2 text-truncate";
                                a3.href = `/email`; // 실제 상세페이지 경로로 연결
                                a3.style.maxWidth = "300px";
                                a3.innerHTML = `
                                    <span style=" font-weight: bold;'" >기타  </span>`;
                                li3.appendChild(a3);
                                mailAlarmDropdown.appendChild(li3);

                                mailcnt++;
                            }
                        })
                        // <li> 요소 생성
                        const li2 = document.createElement('li');
                        // <a> 요소 생성 및 속성 설정
                        const a2 = document.createElement('a');
                        a2.className = "dropdown-item py-2";
                        a2.className = "dropdown-item py-2 text-truncate";
                        a2.href = `/email`; // 실제 상세페이지 경로로 연결
                        a2.style.maxWidth = "300px";
                        a2.style.textAlign = "center";
                        a2.innerHTML = `
                                    <span style=" font-weight: bold;" >전체 메일 보기</span>`;
                        li2.appendChild(a2);
                        mailAlarmDropdown.appendChild(li2);
                    }
                }
            ).catch(e=> console.error("에러난 경우", e))
            // 메일 알람 가져오기 끝 //
            ///////////////////////////// 스프링 웹소켓 시작  ///////////////
            loadInitialAlarms();
            const userId="${userId.empId}" ; //JSTL변수 -> J/S변수
            console.log("알람 - DOMContentLoaded->userId : ", userId);

            //로그인 되어 있을 때만 웹소켓 연결
            if(userId && userId.length > 0){
                connect(userId);  //페이지 로드 시 웹소켓 연결 시도
            }//end if
        })//end DOMContentLoaded

		//전역 변수 설정
		let socket = null;      //클라이언트와 서버 연결고리
		let stompClient = null; //서버가 클라이언트에게 보내줄 메시지를 담고 있음.(규칙이 정해져 있음)
		
		/*////////////////////// 스프링 웹소켓 시작 ///////////////////////////////*/
		function connect(userId) {
		    // SockJS 및 Stomp 설정
		    socket = new SockJS("/alarm");
		    stompClient = Stomp.over(socket);
		    
		    // 디버그 로그가 너무 많을 경우 주석 해제 (콘솔 깨끗하게 유지)
		    // stompClient.debug = null; 
		
		    stompClient.connect({}, function(frame) {
		        console.log("✅ 알람 소켓 연결 성공 (User: " + userId + ")");
		
		        // ---------------------------------------------------------
		        // 🌟 [추가 로직] 소켓 연결 성공 직후 실제 알림 카운트 동기화
		        // ---------------------------------------------------------
		        // JSP가 처음 그려질 때 서버에서 준 '4'라는 숫자를 믿지 않고,
		        // 소켓이 연결되자마자 방금 보여주신 updateAlarmCount()를 실행해서
		        // 서버의 실제 값(9+)으로 즉시 갱신합니다.
		        if (typeof window.updateAlarmCount === 'function') {
		            window.updateAlarmCount();
		        }
		        // ---------------------------------------------------------
		
		        // 공통 알람 처리 로직 (중복 코드 방지를 위해 함수화)
		        const handleIncomingAlarm = (message) => {
		            try {
		                let alarm = JSON.parse(message.body);
		                console.log("🔔 새 알람 수신:", alarm);
		                
		                // 1. 토스트 알림 표시 (기존 유지)
		                if (typeof showToast === 'function') {
		                    showToast(alarm);
		                }
		
		                // 2. 알람 타입에 따른 드롭다운 업데이트
		                if (alarm.almType === '채팅') {
		                    if (typeof updateChatDropdown === 'function') {
		                        updateChatDropdown(alarm);
		                    }
		                } else {
		                    if (typeof updateAlmDropdown === 'function') {
		                        updateAlmDropdown(alarm);
		                    }
		                }
		            } catch (e) {
		                console.error("❌ 알람 데이터 파싱 에러:", e);
		            }
		        };
		
		        // 1. 전체 알람 구독
		        stompClient.subscribe("/sub/alarm/all", handleIncomingAlarm);
		
		        // 2. 개인 알람 구독 (userId가 확실히 포함되도록 구성)
		        if (userId) {
		            stompClient.subscribe("/sub/alarm/" + userId, handleIncomingAlarm);
		        }
		
		    }, function(error) {
		        console.error("🚀 소켓 연결 실패, 5초 후 재시도...", error);
		        setTimeout(() => connect(userId), 5000); 
		    });
		}
		
		function updateChatDropdown(alarm) {
		    // ---------------------------------------------------------
		    // 🚀 [1. 현재 활성화된 채팅방 필터링 로직]
		    // ---------------------------------------------------------
		    let alarmRmNo = null;
		    try {
		        if (alarm.almUrlVar) {
		            // URL 파라미터에서 chatRmNo 추출 (다양한 형식 대응)
		            const paramStr = alarm.almUrlVar.includes('?') ? alarm.almUrlVar.split('?')[1] : alarm.almUrlVar;
		            const urlParams = new URLSearchParams(paramStr);
		            alarmRmNo = urlParams.get('chatRmNo');
		            
		            // 파라미터 형식이 아닐 경우 숫자만 추출하는 백업
		            if(!alarmRmNo) alarmRmNo = alarm.almUrlVar.replace(/[^0-9]/g, "");
		        }
		        
		        // [핵심 비교] window.currentChatRmNo(현재 보고있는방)와 alarmRmNo(알림온방) 비교
		        // 타입을 String으로 통일하여 '67' === 67 상황 방지
		        if (window.currentChatRmNo && alarmRmNo && String(window.currentChatRmNo) === String(alarmRmNo)) {
		            console.log("📍 [실시간 읽음 처리] 현재 열린 방(" + alarmRmNo + ")의 메시지이므로 알림을 무시합니다.");
		            
		            // 배지 강제 제거/유지 (숫자가 올라가는 것을 방지)
		            const chatBadge = document.getElementById('chatAlmCnt');
		            if(chatBadge && (chatBadge.innerText === '0' || chatBadge.innerText === '')) {
		                chatBadge.style.display = 'none';
		            }

		            // 서버 DB 업데이트 및 메시지 영역 갱신 트리거
		            if (typeof window.loadChatMessages === 'function') {
		                // 두 번째 인자는 실제 메시지 영역 ID에 맞게 조절 (예: 'chatMsgArea_' + alarmRmNo)
		                window.loadChatMessages(alarmRmNo, 'chatMsgArea_' + alarmRmNo); 
		            }
		            
		            return; // ◀ 여기서 종료하면 아래의 배지 카운트 및 드롭다운 추가 로직이 실행되지 않음
		        }
		    } catch (e) {
		        console.error("알람 방 번호 분석 중 오류:", e);
		    }

		    // ---------------------------------------------------------
		    // 🚀 [2. 헤더 아이콘 배지 업데이트] - 현재 방이 아닐 때만 실행됨
		    // ---------------------------------------------------------
		    if (typeof window.updateAlarmCount === 'function') {
		        setTimeout(function() {
		            window.updateAlarmCount();
		        }, 300);
		    } else {
		        const badge = document.getElementById('chatAlmCnt');
		        if(badge) { 
		            badge.style.display = 'flex'; 
		            // 텍스트 업데이트 로직이 필요하다면 여기에 추가
		        }
		    }

		    // ---------------------------------------------------------
		    // 🚀 [3. 메신저 리스트 새로고침]
		    // ---------------------------------------------------------
		    const chatWin = document.getElementById('chatMainWrapper');
		    if (chatWin && (chatWin.style.display === 'block' || chatWin.style.display === 'flex')) {
		        if (typeof loadChatRoomList === 'function') {
		            loadChatRoomList(true); 
		        }
		    }

		    // ---------------------------------------------------------
		    // 🚀 [4. 드롭다운 리스트에 새 항목 추가]
		    // ---------------------------------------------------------
		    const chatDropdown = document.getElementById('chatDropdown');
		    if(chatDropdown) {
		        const noMsg = document.getElementById('noChatMsg');
		        if (noMsg) noMsg.remove();

		        let chatRmNoStr = alarmRmNo || ""; 

		        const newItem = `
		            <li>
		                <a class="dropdown-item py-2" href="javascript:void(0);" onclick="openChatMain('${chatRmNoStr}')">
		                    <div class="d-flex align-items-center">
		                        <div class="flex-grow-1">
		                            <h6 class="mb-1" style="font-size:13px; white-space: normal;">${alarm.almDtl || alarm.almMsg}</h6>
		                            <small class="text-muted">${alarm.almSndrTm || '방금 전'}</small>
		                        </div>
		                    </div>
		                </a>
		            </li>
		        `;
		        
		        const header = document.getElementById("chatDropdownHeader");
		        if (header) {
		            const tempDiv = document.createElement('div');
		            tempDiv.innerHTML = newItem;
		            header.after(tempDiv.firstElementChild);
		        } else {
		            chatDropdown.insertAdjacentHTML('afterbegin', newItem);
		        }
		    }
		}
		
		
		// 1. 알람 읽음 처리 및 페이지 이동 함수
		function markAsRead(almNo, url, element) {
		    var contextPath = "${pageContext.request.contextPath}" === "/" ? "" : "${pageContext.request.contextPath}";
		    var myEmpId = "${userId.empId}";
		
		    var chatRmNo = null;
		    try {
		        // 상대경로일 경우 origin을 붙여 URL 객체 생성 (파라미터 추출용)
		        var absoluteUrl = url.indexOf('http') === 0 ? url : window.location.origin + url;
		        var urlObj = new URL(absoluteUrl);
		        chatRmNo = urlObj.searchParams.get('chatRmNo');
		    } catch (e) {
		        console.error("URL 분석 실패:", e);
		    }
		
		    // ---------------------------------------------------------
		    // 🚀 [1. UI 즉시 반영 로직] - 기존 로직 유지 및 보강
		    // ---------------------------------------------------------
		    if (element) {
		        var li = element.closest('li');
		        var badgeId = chatRmNo ? "chatAlmCnt" : "almCnt";
		        var badgeElement = document.getElementById(badgeId);
		
		        if (badgeElement) {
		            var currentText = badgeElement.innerText.trim();
		            var currentCnt = 0;
		            
		            // "9+" 같은 문자열 대응
		            if (currentText.indexOf('+') !== -1) {
		                currentCnt = 10; 
		            } else {
		                currentCnt = parseInt(currentText) || 0;
		            }
		
		            // 카운트 차감 및 UI 업데이트
		            if (currentCnt > 1) {
		                var nextCnt = currentCnt - 1;
		                badgeElement.innerText = nextCnt > 9 ? "9+" : nextCnt;
		            } else {
		                badgeElement.innerText = "0";
		                badgeElement.style.display = 'none'; 
		            }
		        }
		        if (li) li.remove(); // 클릭한 알람 항목 삭제
		    }
		
		    // ---------------------------------------------------------
		    // 🚀 [2. DB 상태 업데이트 및 페이지 이동]
		    // ---------------------------------------------------------
		    if (chatRmNo) {
		        // 채팅 알람 읽음 처리 (updateChatStts)
		        axios.post(contextPath + "/alarm/updateChatStts", {
		            chatRmNo: chatRmNo,        
		            almRcvrNo: myEmpId,        
		            updateStts: 'readChatAlarm'
		        })
		        .then(function(res) {
		            console.log("✅ 채팅 알람 읽음 처리 결과:", res.data);
		            
		            // 전역 변수 동기화 (방금 읽은 방을 현재 방으로 설정)
		            window.currentChatRmNo = parseInt(chatRmNo);
		        })
		        .catch(function(err) {
		            console.error("❌ 채팅 알람 업데이트 실패:", err);
		        })
		        .finally(function() {
		            // 메신저 창이 정의되어 있다면 호출, 아니면 페이지 이동
		            if (typeof window.openChatMain === 'function') {
		                window.openChatMain(chatRmNo);
		            } else if (typeof window.enterChatRoom === 'function') {
		                // 팝업 형태의 메신저일 경우 직접 호출 가능
		                window.enterChatRoom(chatRmNo, '채팅방');
		            } else {
		                var targetUrl = url.startsWith(contextPath) ? url : contextPath + url;
		                location.href = targetUrl;
		            }
		        });
		    } else {
		        // 일반 알람 읽음 처리 (updateStts)
		        axios.post(contextPath + "/alarm/updateStts", {
		            almNo: almNo,
		            updateStts: 'Y',
		            almRcvrNo: myEmpId
		        })
		        .then(function() {
		            console.log("✅ 일반 알람 읽음 처리 완료");
		        })
		        .catch(function(err) {
		            console.error("❌ 일반 알람 업데이트 실패:", err);
		        })
		        .finally(function() {
		            var targetUrl = url.startsWith(contextPath) ? url : contextPath + url;
		            location.href = targetUrl;
		        });
		    }
		}
		
		 // [추가] 채팅방 입장 시 호출할 상단 배지 초기화 함수
		window.resetChatBadge = function() {
		  const chatAlmCnt = document.getElementById("chatAlmCnt");
		  const chatDropdown = document.getElementById("chatDropdown");
		  const noChatMsg = document.getElementById("noChatMsg");
		
		  if (chatAlmCnt) {
		      chatAlmCnt.innerText = "0";
		      chatAlmCnt.style.display = 'none'; // 배지 숨김
		  }
		
		  // 드롭다운 목록도 비우고 싶다면 아래 로직 유지
		  if (chatDropdown) {
		      // 헤더와 '없음' 메시지 제외한 나머지 알람 항목 삭제
		      const items = chatDropdown.querySelectorAll('li:not(#chatDropdownHeader):not(#noChatMsg)');
		      items.forEach(item => item.remove());
		      
		      // '새로운 채팅이 없습니다' 메시지 다시 노출
		      if (noChatMsg) noChatMsg.style.display = 'block';
		  }
		  console.log("✅ 채팅 알람 배지 및 목록 초기화 완료");
		};  
		
		// [추가] 채팅 전용 드롭다운 업데이트 함수
		// 2. 실시간 웹소켓으로 알람 왔을 때 드롭다운 업데이트 함수 수정
		function updateChatDropdown(alarm) {
		    const chatDropdown = document.getElementById("chatDropdown");
		    const chatAlmCnt = document.getElementById("chatAlmCnt");
		    const noChatMsg = document.getElementById("noChatMsg");
		    
		    // ============================================================
		    // 🌟 [확실한 차단 로직] 현재 보고 있는 채팅방 체크
		    // ============================================================
		    let alarmRmNo = null;
		    try {
		        if (alarm.almUrlVar) {
		            // "chatRmNo=128" 또는 "?chatRmNo=128" 형태 모두 대응
		            const paramStr = alarm.almUrlVar.includes('?') ? alarm.almUrlVar.split('?')[1] : alarm.almUrlVar;
		            const urlParams = new URLSearchParams(paramStr);
		            alarmRmNo = urlParams.get('chatRmNo');
		            
		            // 파라미터 형식이 아닐 경우(그냥 숫자만 온 경우) 대비
		            if(!alarmRmNo) alarmRmNo = alarm.almUrlVar.replace(/[^0-9]/g, "");
		        }
		        
		        // [핵심] 현재 활성화된 방 번호(window.currentChatRmNo)와 알람 방 번호 비교
		        // 둘 다 문자열로 변환하여 비교해야 타입 불일치로 인한 통과를 막을 수 있습니다.
		        if (window.currentChatRmNo && alarmRmNo && String(window.currentChatRmNo) === String(alarmRmNo)) {
		            console.log("📍 [알림 차단 성공] 현재 열린 방(" + alarmRmNo + ")의 메시지이므로 배지를 올리지 않습니다.");
		            
		            // 🌟 강제 보정: 이미 '1'이 떠 있다면 0으로 밀어버립니다.
		            if(chatAlmCnt) {
		                chatAlmCnt.innerText = '0';
		                chatAlmCnt.style.display = 'none';
		            }
		            return; // ◀ 여기서 종료되어야 배지 숫자가 안 올라갑니다.
		        }
		    } catch (e) {
		        console.error("알람 방 번호 분석 중 오류:", e);
		    }
		    
		    // 드롭다운 아이템 추가 로직 (기존 유지)
		    if (noChatMsg) noChatMsg.remove();
		    const li = document.createElement('li');
		    const a = document.createElement('a');
		    a.className = "dropdown-item py-2 text-truncate";
		    a.style.maxWidth = "300px";
		    a.style.cursor = "pointer";
		    const targetUrl = alarm.almUrl + (alarm.almUrlVar ? (alarm.almUrlVar.startsWith('?') ? alarm.almUrlVar : '?' + alarm.almUrlVar) : '');
		    a.onclick = function() { markAsRead(alarm.almNo, targetUrl, this); };
		    a.innerHTML = alarm.almDtl;
		    li.appendChild(a);
		    
		    const header = document.getElementById("chatDropdownHeader");
		    if (header) { header.after(li); } else { chatDropdown.prepend(li); }
		    
		    // ============================================================
		    // 🌟 [배지 카운트 실시간 업데이트]
		    // ============================================================
		    if (typeof window.updateAlarmCount === 'function') {
		        setTimeout(function() {
		            window.updateAlarmCount();
		        }, 300);
		    }
		}
		
		function updateAlmDropdown(alarm) {
		    const chatDropdown = document.getElementById("almDropdown");
		    const chatAlmCnt = document.getElementById("almCnt");
		    const noChatMsg = document.getElementById("almDropdownHeader");
		
		    if (noChatMsg) noChatMsg.remove();
		
		    const li = document.createElement('li');
		    const a = document.createElement('a');
		    a.className = "dropdown-item py-2 text-truncate";
		    a.style.maxWidth = "300px";
		    a.style.cursor = "pointer";
		    const targetUrl = alarm.almUrl + (alarm.almUrlVar ? (alarm.almUrlVar.startsWith('?') ? alarm.almUrlVar : '?' + alarm.almUrlVar) : '');
		    a.onclick = function() { markAsRead(alarm.almNo, targetUrl, this); };
		    a.innerHTML = "["+alarm.almType+"] "+ alarm.almDtl;
		    li.appendChild(a);
		    chatDropdown.prepend(li);
		
		    if (typeof window.updateAlarmCount === 'function') {
		        setTimeout(function() {
		            window.updateAlarmCount();
		        }, 300);
		    } else if (chatAlmCnt) {
		        let currentCnt = parseInt(chatAlmCnt.innerText) || 0;
		        chatAlmCnt.innerText = currentCnt + 1;
		        chatAlmCnt.style.display = 'inline-block';
		    }
		}
		
		function showToast(alarm) {
		    // ---------------------------------------------------------
		    // 🚀 [1. 현재 보고 있는 채팅방 필터링 로직] - 기존 로직 동일
		    // ---------------------------------------------------------
		    let alarmRmNo = null;
		    try {
		        if (alarm.almUrlVar) {
		            const paramStr = alarm.almUrlVar.includes('?') ? alarm.almUrlVar.split('?')[1] : alarm.almUrlVar;
		            const urlParams = new URLSearchParams(paramStr);
		            alarmRmNo = urlParams.get('chatRmNo');
		            
		            if(!alarmRmNo) {
		                const match = alarm.almUrlVar.match(/\d+/);
		                alarmRmNo = match ? match[0] : null;
		            }
		        }

		        if (window.currentChatRmNo && alarmRmNo && String(window.currentChatRmNo) === String(alarmRmNo)) {
		            console.log("📍 [토스트 차단] 현재 보고 있는 방(" + alarmRmNo + ")의 메시지이므로 알림창을 생략합니다.");
		            return; 
		        }
		    } catch (e) {
		        console.error("토스트 필터링 중 오류:", e);
		    }

		    // ---------------------------------------------------------
		    // 🚀 [2. 🌟 이름 없이 공통 문구만 설정 🌟]
		    // ---------------------------------------------------------
		    let displayTitle = "새로운 알림이 도착했습니다."; // 기본값
		    let displayDetail = ""; // 상세 텍스트 영역 (비워둠)

		    if (alarm.almType === '채팅') {
		        // 이름이나 원본 메시지 파싱 없이 무조건 고정 문구로 치환합니다.
		        displayTitle = "새 채팅을 보냈습니다.";
		    } else {
		        // 채팅이 아닌 그룹웨어 일반 알림(결재, 공지 등)일 때는 기존대로 출력
		        displayTitle = "[" + alarm.almType + "] " + (alarm.almMsg || "새 알림이 도착했습니다.");
		        displayDetail = alarm.almDtl || "";
		    }

		    // ---------------------------------------------------------
		    // 🚀 [3. SweetAlert2 토스트 실행 로직] - 기존 로직 동일
		    // ---------------------------------------------------------
		    const Toast = Swal.mixin({
		        toast: true,
		        position: 'top',
		        showConfirmButton: false,
		        timer: 4000, 
		        timerProgressBar: true,
		        didOpen: (toast) => {
		            toast.addEventListener('mouseenter', Swal.stopTimer)
		            toast.addEventListener('mouseleave', Swal.resumeTimer)
		        }
		    });

		    Toast.fire({
		        icon: alarm.almIcon || 'info', 
		        title: displayTitle, // 👈 고정된 "새 채팅을 보냈습니다."가 출력됨
		        text: displayDetail  
		    });
		}

        // DB에서 안 읽은 알림 가져오기
        function loadInitialAlarms() {
		    const contextPath = "${pageContext.request.contextPath}" === "/" ? "" : "${pageContext.request.contextPath}";
		    const unreadUrl = contextPath + "/alarm/unread";
		
		    axios.post(unreadUrl, {})
		        .then(res => {
		            console.log("🚀 [알람 초기화] 안 읽은 알람 정보 로드 완료");
		            const alms = res.data;
		
		            // 1. [초기화] 기존 배지 및 드롭다운 리스트 비우기
		            const chatAlmCnt = document.getElementById("chatAlmCnt");
		            const almCnt = document.getElementById("almCnt");
		            const chatHeader = document.getElementById("chatDropdownHeader");
		            const chatDropdown = document.getElementById("chatDropdown");
		            const almAlarmDropdown = document.getElementById("almDropdown");
		            const noChatMsg = document.getElementById("noChatMsg");
		            const almAlarmDropdownHeader = document.getElementById("almDropdownHeader");
		
		            if (chatAlmCnt) chatAlmCnt.style.display = "none";
		            if (almCnt) almCnt.style.display = "none";
		
		            // 🌟 [보강] 기존에 그려진 채팅 알람 리스트 삭제 (중복 방지)
		            if (chatHeader) {
		                let nextLi = chatHeader.nextElementSibling;
		                while (nextLi && nextLi.tagName === 'LI' && nextLi.id !== 'noChatMsg') {
		                    let temp = nextLi.nextElementSibling;
		                    nextLi.remove();
		                    nextLi = temp;
		                }
		            }
		
		            // 🌟 [보강] 일반 알람 리스트 삭제 (Header 제외 전부 삭제)
		            if (almAlarmDropdown) {
		                const items = almAlarmDropdown.querySelectorAll('li:not(#almDropdownHeader)');
		                items.forEach(item => item.remove());
		            }
		
		            let generalCnt = 0;
		            let chatCnt = 0;
		            let almcntcnt = 0; // 일반 알람 출력 개수 제한용
		
		            // 2. [분류 및 렌더링] 알람 리스트 순회
		            alms.forEach(alm => {
		                const li = document.createElement('li');
		                const a = document.createElement('a');
		                a.className = "dropdown-item py-2 text-truncate";
		                a.style.maxWidth = "300px";
		                a.style.cursor = "pointer";
		
		                const targetUrl = alm.almUrl + (alm.almUrlVar ? (alm.almUrlVar.startsWith('?') ? alm.almUrlVar : '?' + alm.almUrlVar) : '');
		
		                if (alm.almType === '채팅') {
		                    // 🌟 [핵심 수정] 현재 보고 있는 방의 알람이라면 카운트와 리스트에서 제외
		                    let alarmRmNo = null;
		                    if (alm.almUrlVar) {
		                        const paramStr = alm.almUrlVar.includes('?') ? alm.almUrlVar.split('?')[1] : alm.almUrlVar;
		                        const urlParams = new URLSearchParams(paramStr);
		                        alarmRmNo = urlParams.get('chatRmNo') || alm.almUrlVar.replace(/[^0-9]/g, "");
		                    }
		
		                    if (window.currentChatRmNo && alarmRmNo && String(window.currentChatRmNo) === String(alarmRmNo)) {
		                        // 현재 보고 있는 방은 카운트하지 않음
		                        return; 
		                    }
		
		                    chatCnt++;
		                    if (noChatMsg) noChatMsg.style.display = 'none';
		
		                    a.onclick = function() { markAsRead(alm.almNo, targetUrl, this); };
		                    a.innerHTML = `\${alm.almDtl}`; // JSP backtick 탈출
		                    li.appendChild(a);
		
		                    if (chatHeader) {
		                        chatHeader.after(li);
		                    } else if (chatDropdown) {
		                        chatDropdown.prepend(li);
		                    }
		                } else {
		                    // 일반 알람 처리
		                    generalCnt++;
		                    a.onclick = function() { markAsRead(alm.almNo, targetUrl, this); };
		                    
		                    if (almcntcnt < 9) { // 최대 9개까지만 표시
		                        a.innerHTML = `<span>[\${alm.almType}] \${alm.almMsg}</span>`;
		                        li.appendChild(a);
		                        if (almAlarmDropdown) almAlarmDropdown.appendChild(li);
		                        almcntcnt++;
		                    }
		                }
		            });
		
		            // 3. [최종 배지 업데이트]
		            // 일반 알람 배지
		            if (generalCnt > 0 && almCnt) {
		                almCnt.innerHTML = generalCnt > 9 ? '9+' : generalCnt;
		                almCnt.style.display = 'flex';
		                if (almAlarmDropdownHeader) almAlarmDropdownHeader.innerHTML = '안 읽은 알람';
		
		                // 전체보기 버튼 추가
		                const viewAllLi = document.createElement('li');
		                viewAllLi.innerHTML = `<a class="dropdown-item py-2 text-truncate text-center" href="\${contextPath}/alarm/list" style="font-weight:bold;">알람 전체 보기</a>`;
		                if (almAlarmDropdown) almAlarmDropdown.appendChild(viewAllLi);
		            }
		
		            // 채팅 알람 배지
		            if (chatAlmCnt) {
		                if (chatCnt > 0) {
		                    chatAlmCnt.innerHTML = chatCnt > 9 ? '9+' : chatCnt;
		                    chatAlmCnt.style.display = 'flex';
		                } else {
		                    chatAlmCnt.style.display = 'none';
		                    if (noChatMsg) noChatMsg.style.display = 'block';
		                }
		            }
		
		        }).catch(err => {
		            console.error("❌ 알람 로드 중 오류 발생:", err);
		        });
		}



      // [식단표] --------------------------------------------------------------------------------
    function openDietModal() {
        const modalTarget = document.getElementById('mealModal');
            if (!modalTarget) return;

            // 모달을 body 바로 아래로 옮기기
            document.body.appendChild(modalTarget);

            let mealModalInst = bootstrap.Modal.getOrCreateInstance(modalTarget, {
                backdrop: false, // 배경 생성 방지
                keyboard: true
            });

            mealModalInst.show();

            // 다른 모달의 동작을 방해하는 부트스트랩 기본 스타일 강제 제거
            setTimeout(() => {
                document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
                document.body.classList.remove('modal-open');
                document.body.style.overflow = '';
                document.body.style.paddingRight = '';
            }, 10);

            loadWeeklyDiet();
    }

    async function loadWeeklyDiet() {
        const sheetUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRoln08wdcyjuYhi729Up8IOcAmB5mGQlUeGtUwhIY0fJpsOV2_aX2oeoQMQTrcuVyp4z0IqlvEpwXQ/pub?gid=0&single=true&output=csv";
        // 모달 본문 비우기
        const $body = $('#mealModalBody').empty();
        // 로딩 스피너
        $body.append('<div class="text-center py-5"><div class="spinner-border text-primary"></div><p class="mt-2 text-muted">식단을 불러오는 중...</p></div>');

        try {
            // URL 데이터 가져오기
            const res = await axios.get(sheetUrl);

            const rows = [];
            // CSV 데이터의 쉼표(,)와 따옴표(""), 줄바꿈을 구분하여 잘라내기
            const pattern = /("([^"]|"")*"|[^",\r\n]*)(,|\r?\n|$)/g;
            let currRow = [];
            let match;

            // match[1] : /("([^"]|"")*"|[^   - 쉼표와 따옴표로 감싸진 전체 내용 가져오기
            // match[2] : ,\r\n]*)            - 따옴표가 없는 텍스트 가져오기
            // match[3] : (,|\r?\n|$)/g       - 데이터 뒤에 붙은 구분자 (, \n(줄바꿈), $(끝) )

            // 정규식을 사용해 CSV 텍스트를 한 칸(Cell)씩 분리하여 2차원 배열(rows)로 만들기
            while ((match = pattern.exec(res.data)) !== null) {
                let val = match[1];
                // "" 큰따옴표 제거 (텍스트만 가져오기 위해서)
                if (val.startsWith('"') && val.endsWith('"')) {
                    val = val.substring(1, val.length - 1).replace(/""/g, '"');
                }
                currRow.push(val.trim());
                if (match[3] !== ',') {     // 쉼표가 아니면 현재행의 데이터를 다음행에 push
                    rows.push(currRow);
                    currRow = [];
                }
                if (match[3] === '') break;
            }

            // 이번 주 날짜 생성
            const weekDates = [];
            const now = new Date();
            const day = now.getDay();
            // 오늘 요일을 기준으로 이번주 월요일이 며칠 전인지 계산
            const mondayDiff = day === 0 ? -6 : 1 - day;

            // 월요일부터 금요일까지 날짜 문자열 생성
            for (let i = 0; i < 5; i++) {
                const date = new Date(now);
                date.setDate(now.getDate() + mondayDiff + i);               // date를 월~금으로 조정
                const mm = String(date.getMonth() + 1).padStart(2, '0');    // 기본 월 설정이 0~11이므로 +1
                const dd = String(date.getDate()).padStart(2, '0');         // padStart : 문자열 길이 고정하고 싶을때 사용 (ex. 2 -> 02로 표시)
                weekDates.push(`\${mm}월 \${dd}일`);                         // 배열 저장 형식
            }

            const weeklyMenu = [];
            // 데이터 추출
            for (let i = 0; i < rows.length; i++) {
                for (let j = 0; j < rows[i].length; j++) {
                    const cellValue = rows[i][j];

                    // 만약 셀의 텍스트가 '이번 주 날짜' 배열에 포함되어 있다면
                    if (weekDates.includes(cellValue)) {
                        const isLeftGroup = (j >= 7 && j <= 11);  // 3월 데이터 가로 영역에 있는지 확인
                        const isRightGroup = (j >= 13 && j <= 17); // 4월 데이터 가로 영역에 있는지 확인

                        // 해당 영역이 맞고, 바로 아래 칸(i+1)에 메뉴 내용이 적혀 있다면
                        if ((isLeftGroup || isRightGroup) && rows[i + 1] && rows[i + 1][j]) {
                            weeklyMenu.push({
                                date: cellValue,        // 날짜 저장
                                menu: rows[i + 1][j],   // 바로 아래 행의 식단 내용 저장
                                sortKey: weekDates.indexOf(cellValue)   // 요일 순서 저장
                            });
                        }
                    }
                }
            }

            // 요일 순서 정렬
            weeklyMenu.sort((a, b) => a.sortKey - b.sortKey);
            $body.empty();  // 로딩 스피너 제거

            // 화면 렌더링
            if (weeklyMenu.length > 0) {
                let html = `<div class="weekly-diet-container p-1">`;
                // 오늘 날짜 문자열 생성
                const todayStr = `\${String(now.getMonth() + 1).padStart(2, '0')}월 \${String(now.getDate()).padStart(2, '0')}일`;

                weeklyMenu.forEach(item => {
                    // 이 카드가 오늘 날짜인지 판별
                    const isToday = item.date === todayStr;

                    html += `
                            <div class="\${isToday ? 'today-diet-card' : ''} diet-card mb-3 p-3"
                                 id="\${isToday ? 'todayDiet' : ''}"
                                 style="border-radius: 12px; border: 1px solid \${isToday ? '#696cff' : '#eee'};
                                        background: \${isToday ? '#f8faff' : '#fff'};">
                                <div class="diet-date-header" style="display: flex; flex-direction: column; align-items: center; justify-content: center; margin-bottom: 10px;">
                                    <div class="date-title-line fw-bold \${isToday ? 'text-primary' : ''}">
                                        <i class="material-icons" style="font-size:18px;">event</i>
                                        <span>\${item.date}</span>
                                    </div>
                                    \${isToday ? '<span class="badge bg-primary mt-1" style="font-size: 0.7rem;">오늘</span>' : ''}
                                </div>
                                <div class="menu-content small" style="text-align: center; white-space: pre-line;">\${item.menu}</div>
                            </div>`;
                });
                $body.append(html + `</div>`);

                setTimeout(() => {
                    const todayElement = document.getElementById('todayDiet');
                    if (todayElement) {
                        todayElement.scrollIntoView({
                            behavior: 'smooth',
                            block: 'center'
                        });
                    }
                }, 100);

            } else {
                // 이번 주 데이터가 시트에 아예 없을 경우
                $body.append('<div class="text-center py-5 text-muted">이번 주 식단 정보가 없습니다.</div>');
            }
        } catch (err) {
            console.error("식단 로드 에러:", err);
            $body.html('<p class="text-danger text-center py-5">데이터 로드 실패 (공유 설정 확인 요망)</p>');
        }
    }


    // 모달 창 닫기
    $(document).on('mousedown', function (e) {
        const mealModalEl = document.getElementById('mealModal');
        if (!mealModalEl) return;

        const $mealModal = $(mealModalEl);

        // 식단표 아이콘 버튼 (아이콘 텍스트가 restaurant인 요소를 포함한 a 태그)
        const $mealBtn = $('.header-icon-btn').filter(function() {
            return $(this).find('.material-icons').text().trim() === 'restaurant';
        });

        // 모달이 열려 있을 때(show 클래스가 있을 때)만 실행
        if ($mealModal.hasClass('show')) {
            // 1. 클릭한 곳이 모달 영역(.modal-content) 내부인지 확인
            const isClickInsideModal = $mealModal.find('.modal-content').is(e.target) ||
                                       $mealModal.find('.modal-content').has(e.target).length > 0;

            // 2. 클릭한 곳이 식단표 실행 버튼인지 확인
            const isClickBtn = $mealBtn.is(e.target) || $mealBtn.has(e.target).length > 0;

            // 모달 내부도 아니고 버튼도 아니라면 닫기 실행
            if (!isClickInsideModal && !isClickBtn) {
                const mealModalInst = bootstrap.Modal.getInstance(mealModalEl);
                if (mealModalInst) {
                    mealModalInst.hide();
                }
            }
        }
    });

        // ==========================================
        // 💡 Driver.js 튜토리얼 가이드
        // ==========================================
        function AiTutorial() {
            // 🌟 추가: 튜토리얼이 시작됨을 전역으로 알림
            window.isTutorialMode = true;

            const driver = window.driver.js.driver;
            const initWrapper = document.getElementById('menuWrapper');
            if (initWrapper) initWrapper.classList.remove('active');
            if (typeof closeChat === 'function') closeChat('trans');

            const driverObj = driver({
                showProgress: true,
                animate: true,
                allowClose: false,
                doneBtnText: '완료',
                closeBtnText: '건너뛰기',
                nextBtnText: '다음 ❯',
                prevBtnText: '❮ 이전',

                onHighlightStarted: (element, step) => {
                    const title = step.popover.title;
                    const wrapper = document.getElementById('menuWrapper');
                    const chatWrapper = document.getElementById('transChatWrapper');

                    // 1. [AI 버튼 단계] (추가) 시작할 때 메뉴는 닫혀있도록 보장
                    if (title === 'AI 버튼') {
                        if (wrapper) wrapper.classList.remove('active');
                    }
                    // 2. [말다듬 AI 단계] 메뉴 열기
                    else if (title === '말다듬 AI') {
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 450);
                    }
                    // 3. [챗봇] (추가) 챗봇열기
                    else if (title === '말다듬 챗봇') {
                        if (typeof openChat === 'function') {
                            openChat('trans');
                        }
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 100);
                    }
                    // 4. [프로젝트 AI 단계]
                    else if (title === '프로젝트 AI') {
                        // 이전 단계의 챗봇 창은 깔끔하게 닫아줌
                        if (typeof closeChat === 'function') {
                            closeChat('trans');
                        }
                        // 메뉴는 계속 열려있도록 유지
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 450);
                    }
                    // 5. [프로젝트] 챗봇 열기
                    else if (title === '프로젝트 챗봇') {
                        if (typeof openChat === 'function') {
                            openChat('project');
                        }
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 100);
                    }

                    // 6. [근태 AI 단계]
                    else if (title === '근태 AI') {
                        // 이전 단계의 챗봇 창은 깔끔하게 닫아줌
                        if (typeof closeChat === 'function') {
                            closeChat('project');
                        }
                        // 메뉴는 계속 열려있도록 유지
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 450);
                    }

                    // 7. [근태 ] 챗봇 열기
                    else if (title === '근태 챗봇') {
                        if (typeof openChat === 'function') {
                            openChat('attendance');
                        }
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 100);
                    }

                    // 8. [일정 AI 단계]
                    else if (title === '일정 AI') {
                        // 이전 단계의 챗봇 창은 깔끔하게 닫아줌
                        if (typeof closeChat === 'function') {
                            closeChat('attendance');
                        }
                        // 메뉴는 계속 열려있도록 유지
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 450);
                    }
                    // 9. [일정 ] 챗봇 열기
                    else if (title === '일정 챗봇') {
                        if (typeof openChat === 'function') {
                            openChat('calendar');
                        }
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 100);
                    }

                    // 10. [전자결재 AI 단계]
                    else if (title === '전자결재 AI') {
                        // 이전 단계의 챗봇 창은 깔끔하게 닫아줌
                        if (typeof closeChat === 'function') {
                            closeChat('calendar');
                        }
                        // 메뉴는 계속 열려있도록 유지
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 450);
                    }
                    // 9. [전재결재 ] 챗봇 열기
                    else if (title === '전자결재 챗봇') {
                        if (typeof openChat === 'function') {
                            openChat('approval');
                        }
                        if (wrapper) wrapper.classList.add('active');

                        setTimeout(() => { driverObj.refresh(); }, 100);
                    }
                    // 마지막 채팅창 끄기
                    else if (title === '🎉 튜토리얼 완료!') {
                        // 이전 단계의 챗봇 창은 깔끔하게 닫아줌
                        if (typeof closeChat === 'function') {
                            closeChat('approval');
                        }
                        setTimeout(() => { driverObj.refresh(); }, 450);
                    }

                    //버튼 안보이게 하는 요소 지워버리기!!!!!!!!!!!!!!
                    setTimeout(() => {
                        if (wrapper && wrapper.firstElementChild) {
                            wrapper.firstElementChild.classList.remove("driver-active-element");
                        }

                        // 모든 메뉴 아이템에서 다 지우기!
                        document.querySelectorAll(".menu-item").forEach(item => item.classList.remove("driver-active-element"));
                    }, 50);

                },


                onDestroyed: () => {
                    // 🌟 추가: 튜토리얼이 끝나면 상태 해제
                    window.isTutorialMode = false;

                    const wrapper = document.getElementById('menuWrapper');
                    if (wrapper) {
                        wrapper.style.zIndex = "9999";
                        wrapper.classList.remove('active');
                    }
                    const chatWrapper = document.getElementById('transChatWrapper');
                    if (chatWrapper) {
                        chatWrapper.style.zIndex = "10000";
                    }
                    if (typeof closeChat === 'function') closeChat('trans');
                },

                steps: [
                    {
                        element: '.main-btn',
                        popover: { title: 'AI 버튼', description: 'WORK UP만의 특별한 AI를 소개합니다!', side: "left" }
                    },
                    {
                        element: '.menu-item.trans',
                        popover: { title: '말다듬 AI', description: '상황에 맞지 않는 말투나 서툰 문장을 자연스럽게 고치고 싶다면 선택하세요!', side: "left", align: 'start' }
                    },
                    {
                        element: '#transChatWrapper',
                        popover: { title: '말다듬 챗봇', description: '원하는 문장을 입력하면 AI가 실시간으로 교정해 드립니다.', side: "left" }
                    },
                    {
                        element: '.menu-item.project',
                        popover: { title: '프로젝트 AI', description: '진행중인 프로젝트 정보를 파악하고 싶다면 선택하세요!', side: "left", align: 'start' }
                    },
                    {
                        element: '#projectChatWrapper',
                        popover: { title: '프로젝트 챗봇', description: '프로젝트 관련 내용을 입력하면 AI가 업무를 도와줍니다.', side: "left", align: 'start' }
                    },
                    {
                        element: '.menu-item.attendance',
                        popover: { title: '근태 AI', description: '본인의 근태 정보를 파악하고 싶다면 선택하세요!', side: "left", align: 'start' }
                    },
                    {
                        element: '#attendanceChatWrapper',
                        popover: { title: '근태 챗봇', description: '근태에 대해 궁금한 내용을 입력하면 AI가 업무를 도와줍니다.', side: "left", align: 'start' }
                    },
                    {
                        element: '.menu-item.calendar',
                        popover: { title: '일정 AI', description: '내 일정을 파악하고 싶다면 선택하세요!', side: "left", align: 'start' }
                    },
                    {
                        element: '#calendarChatWrapper',
                        popover: { title: '일정 챗봇', description: '일정조회 및 새로운 일정을 내용을 입력하면 AI가 업무를 도와줍니다.', side: "left", align: 'start' }
                    },
                    {
                        element: '.menu-item.approval',
                        popover: { title: '전자결재 AI', description: '전자결재 문서 업무를 파악하고 싶다면 선택하세요!', side: "left", align: 'start' }
                    },
                    {
                        element: '#approvalChatWrapper',
                        popover: { title: '전자결재 챗봇', description: '반려 문서 조회 및 일괄 결재 등을 입력하면 AI가 업무를 도와줍니다.', side: "left", align: 'start' }
                    },
                    {
                        popover: {
                            title: '🎉 튜토리얼 완료!',
                            description: '모든 AI 기능 소개가 끝났습니다.<br><br><b>자, 이제 스마트하게 업무를 시작해볼까요?</b>'
                        }
                    }
                ]
            });

            driverObj.drive();
        }
</script>