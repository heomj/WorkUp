<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/themes/default/style.min.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/jstree.min.js"></script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">



<style>
    /* 조직도 스타일 */
    /* jsTree 내 Material Icon 위치 및 크기 조정 */
    .jstree-anchor > .material-icons {
        font-size: 18px !important;
        vertical-align: middle !important;
        margin-right: 5px;
        display: inline-flex !important;
        align-items: center;
        justify-content: center;
    }

    /* 텍스트와 아이콘 수직 정렬 */
    .jstree-anchor {
        display: inline-flex !important;
        align-items: center;
        height: 24px;
    }

    /* 1. 앵커(글자+아이콘 영역) 호버 시 배경색 및 효과 제거 */
    .jstree-default .jstree-anchor.jstree-hovered {
        background: transparent !important;
        box-shadow: none !important;
        border: none !important;
    }

    /* 2. 클릭(선택) 시 앵커 배경색 및 효과 제거 */
    .jstree-default .jstree-anchor.jstree-clicked {
        background: transparent !important;
        box-shadow: none !important;
    }

    /* 3. 호버/클릭 시 글자색이 변하는 것을 방지 (원래 색 유지) */
    .jstree-default .jstree-anchor.jstree-hovered,
    .jstree-default .jstree-anchor.jstree-clicked {
        color: inherit !important;
    }

</style>

<header class="header">
    <button class="btn btn-link text-dark p-0 me-3" id="sidebarToggle">
        <span class="material-icons">menu_open</span>
    </button>
    <div class="ms-auto d-flex align-items-center">
        <div class="d-flex me-3 border-end pe-3">
            <div class="dropdown">
                <a href="#" class="header-icon-btn" data-bs-toggle="dropdown">
                    <span class="material-icons">chat_bubble_outline</span>
                    <span class="badge-count bg-success">3</span>
                </a>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li class="dropdown-header-custom">최근 채팅</li>
                    <li><a class="dropdown-item py-2" href="#">이대리: 프로젝트 확인 부탁드려요</a></li>
                </ul>
            </div>
            <div class="dropdown">
                <a href="#" class="header-icon-btn" data-bs-toggle="dropdown">
                    <span class="material-icons">mail_outline</span>
                    <span class="badge-count bg-danger" id="mailCnt"></span>
                </a>
                <ul class="dropdown-menu dropdown-menu-end" id="mailAlarmDropdown">
                    <li class="dropdown-header-custom" id="mailAlarmDropdownHeader">새로운 메일이 없습니다.</li>
                </ul>
            </div>
            <div class="dropdown">
                <a href="#" class="header-icon-btn" data-bs-toggle="dropdown">
                    <span class="material-icons">notifications_none</span>
                    <span class="badge-count bg-warning">2</span>
                </a>
                <ul class="dropdown-menu dropdown-mendashboardu-end">
                    <li class="dropdown-header-custom">새로운 알림</li>
                    <li><a class="dropdown-item py-2" href="#">결재 승인 알림</a></li>
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
                        <img src="https://i.pravatar.cc/150?u=a042581f4e29026704d" alt="Profile" class="header-profile-img">
                    </c:otherwise>
                </c:choose>
            </a>
            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-3">
                <li><a class="dropdown-item py-2" href="/mypage"><span class="material-icons me-2 v-align-middle">person_outline</span>프로필</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="logout dropdown-item py-2 text-danger"><span class="material-icons me-2 v-align-middle">logout</span>로그아웃</a></li>
            </ul>
        </div>
    </div>
</header>


<script>
    // 1. 사이드바 토글 스크립트
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.getElementById('sidebar');
    const mainWrapper = document.getElementById('main-wrapper');

    sidebarToggle.addEventListener('click', () => {
        sidebar.classList.toggle('collapsed');
        mainWrapper.classList.toggle('expanded');
        const icon = sidebarToggle.querySelector('.material-icons');
        icon.innerText = sidebar.classList.contains('collapsed') ? 'menu' : 'menu_open';
    });

    // 2. 로그아웃 스크립트 (사용자 요청대로 메인에 유지)
    const logout = document.querySelector(".logout");
    logout.addEventListener("click", () => {
        Swal.fire({
            title: '로그아웃 하시겠습니까?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#666CFF',
            cancelButtonColor: '#d33',
            confirmButtonText: '로그아웃',
            cancelButtonText: '취소'
        }).then((result) => {
            if (result.isConfirmed) {
                axios.post('/logout')
                    .then((res) => {
                        Swal.fire({
                            icon: 'success',
                            title: '로그아웃 완료',
                            confirmButtonColor: '#666CFF',
                            timer: 1500,
                            showConfirmButton: false
                        }).then(() => {
                            location.href = "/";
                        });
                    })
                    .catch((err) => {
                        console.error("로그아웃 실패:", err);
                        Swal.fire('오류', '로그아웃 처리 중 문제가 발생했습니다.', 'error');
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

        axios.get("/indivList").then(res => {
            let treeData = [];
            res.data.forEach(dept => {
                treeData.push({
                    id: "D" + dept.deptCd,
                    parent: "#",
                    text: dept.deptNm,
                    type: "dept"
                });

                if (dept.teamLeaders) {
                    dept.teamLeaders.forEach(leader => {
                        treeData.push({
                            id: String(leader.empId),
                            parent: "D" + dept.deptCd,
                            text: `\${leader.empNm} (\${leader.empJbgd})`,
                            type: "leader"
                        });

                        if (leader.teamEmployee) {
                            leader.teamEmployee.forEach(member => {
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
    });

    // 메일 알람 가져오기
    document.addEventListener("DOMContentLoaded",async function mailAlarm(){
        axios.get("/email/mailAlarm").then(res => {
                console.log(res.data)
                mails=res.data; //메일 요약 정보
                let str='';
                let cnt=0;

                const mailCnt=document.getElementById("mailCnt")
                const mailAlarmDropdown=document.getElementById("mailAlarmDropdown");
                const mailAlarmDropdownHeader=document.getElementById("mailAlarmDropdownHeader");
                cnt = mails.length>9? '9+':mails.length; //안읽은 메일 9개 이상이면 9+로 표시
                if(cnt==0){     //안읽은 메일이 없으면 배지 삭제
                    mailCnt.remove();
                }else {
                    mailCnt.innerHTML=cnt; //배지 입력
                    mailAlarmDropdownHeader.innerHTML='안 읽은 메일'
                    mails.forEach(mail=>{
                        // <li> 요소 생성
                        const li = document.createElement('li');

                        // <a> 요소 생성 및 속성 설정
                        const a = document.createElement('a');
                        a.className = "dropdown-item py-2";
                        a.href = `/email/detail/\${mail.emlRcvrId}`; // 실제 상세페이지 경로로 연결
                        a.className = "dropdown-item py-2 text-truncate";
                        a.style.maxWidth = "300px"; // 반드시 최대 너비가 있어야 어디서 줄일지 결정됩니다!
                        // 💡 백틱(`)을 사용하면 제목과 내용을 섞기 편해요
                        a.innerHTML = `<span style="font-weight: bold;">[\${mail.deptNm}]</span>
                    <span style="\${mail.emlEmrgYn==='Y'? 'color:red; font-weight: bold;':''}">\${mail.emlTtl}</span>`;

                        // 조립
                        li.appendChild(a);
                        mailAlarmDropdown.appendChild(li); // 목록의 끝에 추가 (최신순이면 prepend 추천!)
                    })

                }

            }
        ).catch(e=> console.error("에러난 경우", e))


    })



</script>