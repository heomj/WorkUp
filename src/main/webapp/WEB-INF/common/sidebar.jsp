<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    /*  화살표 회전 애니메이션 */
    .nav-link .material-icons:last-child {
        transition: transform 0.3s ease;
    }
    /* collapsed 클래스가 없을 때(열렸을 때) 회전 */
    .nav-link:not(.collapsed) .material-icons:last-child {
        transform: rotate(180deg);
    }

    /* 서브메뉴 표시 제어 */
    .collapse {
        display: none; /* 기본 숨김 */
    }
    .collapse.show {
        display: block; /* 열림 상태 */
    }

    /* 서브메뉴 내부 여백 */
    .submenu {
        list-style: none;
        padding: 0;
        margin: 0;
        background-color: rgba(0,0,0,0.02);
    }
    .submenu .nav-link {
        padding-left: 3.5rem !important;
        font-size: 0.9rem;
    }

    /* --- 스크롤 및 레이아웃 고정 추가 --- */
    .sidebar {
        height: 100vh !important;
        position: fixed !important;
        top: 0;
        left: 0;
        display: flex !important;
        flex-direction: column !important;
        overflow: hidden !important; /* 사이드바 본체는 고정 */
    }

    .nav-container {
        flex: 1 1 auto !important;
        overflow-y: auto !important;
        overflow-x: hidden !important;
        padding-bottom: 100px !important;

        /* IE, Edge, Firefox에서 스크롤바 숨기기 */
        -ms-overflow-style: none;  /* IE and Edge */
        scrollbar-width: none;  /* Firefox */
    }

    .nav-container::-webkit-scrollbar {
        display: none;
    }
    .nav-container::-webkit-scrollbar-thumb {
        background: rgba(0, 0, 0, 0.1);
        border-radius: 10px;
    }
    .nav-container::-webkit-scrollbar-track {
        background: transparent;
    }
    #mailbadge{
        background-color:#7579FF !important;
        z-index: auto;
    }

    #mailbadge:hover{
        background-color: white !important;
    }

</style>

<aside class="sidebar" id="sidebar">
    <div class="d-flex align-items-center justify-content-center p-3" style="display: flex; cursor: pointer; margin-right: 12px;" onclick="location.href='/main';">
        <img src="${pageContext.request.contextPath}/images/icon2.png" alt="logo" style="width: 35px; height: 30px; margin-right: 5px;">
        <strong class="fs-5 fw-bold" style="letter-spacing: -0.5px; color: var(--nav-text-color);">WORK UP</strong>
    </div>

    <div class="profile-card">
        <div class="avatar-wrapper" id="avatarWrapper">
            <sec:authentication property="principal.empVO.avtSaveNm" var="userAvt" />
            <c:choose>
                <c:when test="${not empty userAvt}">
                    <img src="/avatar/displayAvt?fileName=${userAvt}" alt="Avatar" class="avatar-character" onclick="toggleAvatarMenu(event)">
                </c:when>
                <c:otherwise>
                    <img src="/images/defaultAvt.png" alt="Default Avatar" class="avatar-character" onclick="toggleAvatarMenu(event)">
                </c:otherwise>
            </c:choose>

            <!-- 아바타 -->
            <div class="avatar-menu" id="avatarMenu">
                <button type="button" class="btn-shop" onclick="location.href='/shop'"><i class="fas fa-shopping-bag"></i> 아바타 샵</button>
                <button type="button" class="btn-edit" onclick="location.href='/myavatar'"><i class="fas fa-pen"></i> 내 아바타</button>
            </div>
        </div>

        <div class="profile-info">
            <h6><sec:authentication property="principal.empVO.empNm" /> <sec:authentication property="principal.empVO.empJbgd" /></h6>
            <p class="text-muted mb-0" style="font-size: 0.75rem;"><sec:authentication property="principal.empVO.deptNm" /></p>
        </div>
    </div>

    <div class="nav-container">
        <nav id="sidebarNav">
            <!-- 홈 화면 -->
            <a class="nav-link" href="/main"><div class="link-content"><span class="material-icons">grid_view</span><span>홈 화면</span></div></a>

            <sec:authentication property="principal.empVO.empRole" var="empRole" />

            <!-- 근태 -->
            <a class="nav-link" href="/attendance-view"><div class="link-content"><span class="material-icons">timer</span><span>근태</span></div></a>

            <!-- 프로젝트 -->
            <div class="nav-item" id="projSidebar">
                <a class="nav-link collapsed" href="#project">
                    <div class="link-content"><span class="material-icons">layers</span><span>프로젝트</span></div>
                    <span class="material-icons" style="font-size: 1.1rem; margin: 0;">expand_more</span>
                </a>
                <div class="collapse" id="project">
                    <ul class="submenu">
                        <c:if test="${empRole == '사원'}">
                            <li><a class="nav-link" href="/myproject/list">나의 프로젝트</a></li>
                        </c:if>
                        <c:if test="${empRole == '팀장'}">
                            <li><a class="nav-link" href="/projectmanage">프로젝트 관리</a></li>
                        </c:if>
                        <li><a class="nav-link" id="projMyWorkSidebar" href="/myWork">나의 일감</a></li>
                    </ul>
                </div>
            </div>

            <!-- 전자결재 -->
            <div class="nav-item" id="aprvSidebar">
                <a class="nav-link collapsed" href="#appSub">
                    <div class="link-content"><span class="material-icons">description</span><span>전자결재</span></div>
                    <span class="material-icons" style="font-size: 1.1rem; margin: 0;">expand_more</span>
                </a>
                <div class="collapse" id="appSub">
                    <ul class="submenu">
                        <li><a class="nav-link" href="/approval/myAprvBoard">결재 상신함</a></li>
                        <li><a class="nav-link" href="/approval/receiveAprvBoard">결재 수신함</a></li>
                        <li><a class="nav-link" href="/approval/deptAprvList">부서 문서함</a></li>
                    </ul>
                </div>
            </div>

            <!-- 일정 / 식단표 -->
            <div class="nav-item">
                <a class="nav-link collapsed" href="#calendarSub">
                    <div class="link-content"><span class="material-icons">event_available</span><span>일정</span></div>
                    <span class="material-icons" style="font-size: 1.1rem; margin: 0;">expand_more</span>
                </a>
                <div class="collapse" id="calendarSub">
                    <ul class="submenu">
                        <li><a class="nav-link" href="/calendar/main">일정</a></li>
                        <li><a class="nav-link" href="/calendar/mealSchedule">식단표</a></li>
                    </ul>
                </div>
            </div>

             <!-- 회의실 / 비품 -->
         <div class="nav-item">
                <a class="nav-link collapsed" href="#reserveSub">
                    <div class="link-content"><span class="material-icons">meeting_room</span><span>예약 관리</span></div>
                    <span class="material-icons" style="font-size: 1.1rem; margin: 0;">expand_more</span>
                </a>
                <div class="collapse" id="reserveSub">
                    <ul class="submenu">
                        <li><a class="nav-link" href="/reserveMain">예약 현황 및 신청</a></li>
                        <li><a class="nav-link" href="/reserveList">나의 예약 내역</a></li>
                        <c:if test="${empRole == '팀장' || empRole == '관리자'}">
                            <li><a class="nav-link" href="/reserve/approval">예약 승인 관리</a></li>
                        </c:if>
                    </ul>
                </div>
            </div>

            <!-- 화상회의 -->
            <a class="nav-link" href="/gooroomee/list"><div class="link-content"><span class="material-icons">videocam</span><span>화상회의</span></div></a>

            <!-- 메일 -->
            <div class="nav-item">
                <a class="nav-link collapsed" href="#mailSub">
                    <div class="link-content"><span class="material-icons">mail_outline</span><span>메일</span></div>
                    <span class="material-icons" style="font-size: 1.1rem; margin: 0;">expand_more</span>
                </a>
                <div class="collapse" id="mailSub">
                    <ul class="submenu">
                        <li><a class="nav-link" href="/email/write">메일쓰기</a></li>
                        <li><a class="nav-link" href="/email">받은 메일함
                            <span class="badge bg-warning" id="mailbadge" style="background-color: #7579FF !important;">2</span>
                        </a></li>
                        <li><a class="nav-link" href="/email/send">보낸 메일함</a></li>
                        <li><a class="nav-link" href="/email/trashCan">휴지통</a></li>
                    </ul>
                </div>
            </div>

            <!-- 게시판 -->
            <div class="nav-item">
                <a class="nav-link collapsed" href="#noticeSub">
                    <div class="link-content"><span class="material-icons">forum</span><span>게시판</span></div>
                    <span class="material-icons" style="font-size: 1.1rem; margin: 0;">expand_more</span>
                </a>
                <div class="collapse" id="noticeSub">
                    <ul class="submenu">
                        <li><a class="nav-link" href="/notice">공지사항</a></li>
                        <li><a class="nav-link" href="/data">자료실</a></li>
                        <li><a class="nav-link" href="/board">부서별 게시판</a></li>
                    </ul>
                </div>
            </div>

            <!-- 설문 -->
            <a class="nav-link" href="/survey/survey"><div class="link-content"><span class="material-icons">poll</span><span>설문</span></div></a>
            <!-- 채팅 -->
            <a class="nav-link" href="/chat/list"><div class="link-content"><span class="material-icons">chat</span><span>실시간 채팅</span></div></a>

            <!-- 동호회 -->
            <div class="nav-item">
                <a class="nav-link collapsed" href="#clubSub">
                    <div class="link-content"><span class="material-icons">diversity_3</span><span>사내동호회</span></div>
                    <span class="material-icons" style="font-size: 1.1rem; margin: 0;">expand_more</span>
                </a>
                <div class="collapse" id="clubSub">
                    <ul class="submenu">
                        <li><a class="nav-link" href="/club/1">천문 동호회</a></li>
                        <li><a class="nav-link" href="/club/2">독서 동호회</a></li>
                        <li><a class="nav-link" href="/club/3">등산 동호회</a></li>
                    </ul>
                </div>
            </div>

            <!-- 조직도 -->
            <a class="nav-link" href="/deptStructure"><div class="link-content"><span class="material-icons">account_tree</span><span>조직도</span></div></a>
        </nav>
    </div>
</aside>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const navContainer = document.getElementById('sidebarNav');

    const currentPath = window.location.pathname;

    // 세션 스토리지 기반
    let activeMenuId = sessionStorage.getItem('activeMenuId');

    if (!activeMenuId) {
        const activeLink = document.querySelector(`.submenu a[href="\${currentPath}"]`);
        if (activeLink) {
            const parentMenu = activeLink.closest('.collapse');
            if (parentMenu) {
                activeMenuId = parentMenu.id;

            }
        }
    }

    // 최종적으로 결정된 activeMenuId를 화면에 반영
    if (activeMenuId) {
        const targetMenu = document.getElementById(activeMenuId);
        const targetLink = document.querySelector(`a[href="#\${activeMenuId}"]`);
        if (targetMenu && targetLink) {
            targetMenu.classList.add('show');
            targetLink.classList.remove('collapsed');
        }
    }

    // 클릭 이벤트 (부트스트랩 없이 직접 제어)
    navContainer.addEventListener('click', function(e) {
        // 클릭된 요소가 서브메뉴가 있는 링크인지 확인
        const link = e.target.closest('a[href^="#"]');
        if (!link) return;

        e.preventDefault(); // 이동 방지
        const targetId = link.getAttribute('href').substring(1);
        const targetMenu = document.getElementById(targetId);

        if (targetMenu) {
            const isOpen = targetMenu.classList.contains('show');

            if (isOpen) {
                // 닫기
                targetMenu.classList.remove('show');
                link.classList.add('collapsed');
                sessionStorage.removeItem('activeMenuId');
            } else {
                targetMenu.classList.add('show');
                link.classList.remove('collapsed');
                sessionStorage.setItem('activeMenuId', targetId);
            }
        }
    });

    // 아바타 메뉴 토글
    window.toggleAvatarMenu = function(event) {
        event.stopPropagation();
        const wrapper = document.getElementById('avatarWrapper');
        wrapper.classList.toggle('active');
    };

    // 바깥 클릭 시 아ㅏ타 메뉴 토글 닫기
    document.addEventListener('click', function(event) {
        const wrapper = document.getElementById('avatarWrapper');
        if (wrapper && !wrapper.contains(event.target)) {
            wrapper.classList.remove('active');
        }
    });
});
</script>