<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>


<style>
    /* [1] 변수 설정 - 동료의 컬러 시스템과 준삣삐의 규격 결합 */
    :root {
        --point-color: #7579ff;
        --bg-body: #F4F7FE;      /* 동료의 배경색 */
        --text-main: #1B2559;    /* 준삣삐의 메인 텍스트 컬러 */
        --text-sub: #A3AED0;
        --drawer-width: 450px;   
        --header-actual-height: 70px;
        --star-color: #ffb800; 
    }

    /* [2] Base Layout - 동료의 .pjt-wrapper 구조와 일치시킴 */
    .task-wrapper {
        position: relative;
        width: 100%;
        min-height: calc(100vh - var(--header-actual-height));
        background-color: var(--bg-body);
        font-family: 'Pretendard', sans-serif;
        overflow-x: hidden;
    }

    .task-container {
        
        /* 🚨 준삣삐의 전매특허: aside가 나올 때 밀려나는 부드러운 움직임 보존 */
        transition: margin-right 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        max-width: 1600px; /* 넓은 화면 대응 */
        margin: 0;        /* 동료 코드처럼 왼쪽 정렬 유지 */
    }
    .task-container.shrunk { margin-right: var(--drawer-width); }
    /* 타이틀과 아이콘을 한 줄로 정렬 */
    .page-title-wrapper {
        display: flex;
        align-items: center;
        gap: 10px; /* 아이콘과 글자 사이 간격 */
        margin-bottom: 5px;
    }

    /* 아이콘 스타일 - 동료의 포인트 컬러 적용 */
    .title-icon {
        color: #7579ff; /* 준삣삐의 primary 컬러 */
        font-size: 2rem !important; /* 32px 정도로 큼직하게 */
        /* 살짝 그라데이션 느낌 내고 싶으면 아래 주석 해제! */
        /* background: linear-gradient(45deg, #7579ff, #7579ff);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent; */
    }
    /* 타이틀 크기를 동료의 .pjt-header h1과 맞춤 */
    .page-title { 
        font-size: 1.6rem;
        font-weight: 900;
        color: var(--text-main);
        margin: 0; /* wrapper에서 간격을 조절하니까 0으로! */
    }

    /* [3] Project Box - 동료의 .project-item 스타일 이식 */
    .proj-box { 
        background: #fff; 
        border-radius: 12px; 
        margin-bottom: 20px; 
        border: 1px solid #E2E8F0; 
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05); /* 동료 스타일 그림자 */
    }
    .proj-header { 
        padding: 20px 25px; 
        display: flex; 
        align-items: center; 
        cursor: pointer; 
        transition: 0.2s; 
        background: #fff; 
    }
    .proj-header:hover { background: #F9FBFF; }
    .proj-title { flex: 1; font-weight: 800; color: var(--text-main); font-size: 1.05rem; }

    /* [4] 🚨 ULTRA SMOOTH ANIMATION: 준삣삐의 자부심! 슬라이딩 로직 (보존 완료) */
    .sub-task-list {
        max-height: 0;
        opacity: 0;
        transform: translateY(-10px);
        overflow: hidden;
        background: #FBFCFE;
        border-top: 0px solid #F1F5F9;
        transition:
            max-height 0.5s cubic-bezier(0.4, 0, 0.2, 1),
            opacity 0.4s ease,
            transform 0.4s cubic-bezier(0.4, 0, 0.2, 1),
            border-top 0.3s;
    }

    .sub-task-list.expanded {
        max-height: 1500px; 
        opacity: 1;
        transform: translateY(0);
        border-top: 1px solid #F1F5F9;
    }

    /* [5] Task Items & Tags */
    .task-item {
        padding: 16px 25px 16px 60px; 
        display: flex; 
        align-items: center;
        cursor: pointer; 
        border-bottom: 1px solid #F1F5F9; 
        transition: 0.2s;
    }
    .task-item:hover { background: #F0F4FF; }
    .task-name { flex: 1; font-size: 0.95rem; font-weight: 600; color: #4A5568; }
    
    .status-tag { font-size: 0.75rem; padding: 4px 12px; border-radius: 20px; font-weight: 700; }
    .st-ing { background: #EBF4FF; color: #2B6CB0; }
    .st-done { background: #E6FFFA; color: #047481; }
    .st-wait { background: #F7FAFC; color: #718096; }

    /* [6] Side Drawer (aside) - 준삣삐의 '부드러운 등장' 로직 100% 보존 */
    .side-drawer {
        position: fixed; 
        top: var(--header-actual-height);
        /* 동료가 누른 것처럼 깔끔하게 튀어나오는 베지에 곡선 유지 */
        right: calc(var(--drawer-width) * -1.1);
        width: var(--drawer-width); 
        height: calc(100vh - var(--header-actual-height));
        background: #fff; 
        border-left: 1px solid #E2E8F0; 
        box-shadow: -10px 0 30px rgba(0,0,0,0.05);
        z-index: 999; 
        transition: right 0.4s cubic-bezier(0.19, 1, 0.22, 1);
        display: flex; 
        flex-direction: column;
    }
    .side-drawer.open { right: 0; }
    
    .drawer-header { padding: 25px; border-bottom: 1px solid #F1F5F9; display: flex; justify-content: space-between; align-items: center; }
    .drawer-body { flex: 1; padding: 30px; overflow-y: auto; }

    /* [7] Form UI & Range - 준삣삐의 디테일 설정 그대로 */
    .prog-wrap { background: #F8FAFF; padding: 20px; border-radius: 12px; margin: 20px 0; border: 1px solid #EBF1FF; }
    .custom-range { width: 100%; -webkit-appearance: none; height: 8px; border-radius: 5px; background: #E2E8F0; outline: none; }
    .custom-range::-webkit-slider-thumb {
        -webkit-appearance: none; width: 22px; height: 22px; border-radius: 50%;
        background: var(--point-color); border: 4px solid #fff; box-shadow: 0 2px 5px rgba(0,0,0,0.1); cursor: pointer;
    }
    .f-label { display: block; font-size: 0.85rem; font-weight: 700; color: var(--text-sub); margin-bottom: 8px; }
    .f-input { width: 100%; border: 1.5px solid #E2E8F0; border-radius: 10px; padding: 12px; font-size: 0.9rem; box-sizing: border-box; }
    /* 상단 헤더 컨테이너 구조화 */
    .header-content-v2 {
        display: flex;
        justify-content: space-between;
        align-items: flex-end; /* 아래쪽 라인 맞춤 */
        margin-bottom: 35px;
        border-bottom: 2px solid #E2E8F0;
        padding-bottom: 20px;
    }

    /* [1] 배지 컨테이너: 간격과 위아래 여백을 더 줘서 숨통을 틔움 */
    .task-summary-badges {
        display: flex;
        gap: 15px;      /* 간격 넓힘 */
        margin-top: 15px;
    }

    /* [2] 배지 공통 스타일: 크기 키우고 쉐도우 살짝 추가 */
    .summary-badge {
        padding: 8px 18px;    /* 안쪽 여백 대폭 확대 */
        border-radius: 12px;  /* 좀 더 둥글둥글하게 */
        font-size: 0.95rem;   /* 글자 크기 UP */
        font-weight: 700;     /* 폰트 두께 강조 */
        background: #fff;
        border: 1px solid #E2E8F0;
        color: #4A5568;
        display: flex;
        align-items: center;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04); /* 살짝 띄워주는 느낌 */
        transition: transform 0.2s ease;
    }

    .summary-badge:hover {
        transform: translateY(-2px); /* 마우스 올리면 살짝 들리는 센스 */
    }

    /* [3] 숫자 강조: 숫자를 더 크고 굵게! */
    .summary-badge strong {
        font-size: 1.1rem;
        margin-left: 8px;
        padding-left: 8px;
        border-left: 2px solid #E2E8F0; /* 숫자 앞에 구분선 추가 */
    }

    /* [4] 상태별 컬러 포인트 (동료 코드와 톤앤매너 일치) */
    .summary-badge.todo strong { color: #A3AED0; }     /* 할 일: 차분한 그레이 */
    .summary-badge.doing strong { color: #7579ff; }    /* 진행: 시원한 블루 */
    .summary-badge.done strong { color: #047481; }     /* 완료: 신뢰의 청록 */

    /* 현대적인 스위치 토글 디자인 */
    .control-panel-v2 {
        display: flex;
        align-items: center;
        gap: 20px;
    }

    .toggle-wrapper {
        display: flex;
        align-items: center;
        gap: 12px;
        background: #fff;
        padding: 8px 18px;
        border-radius: 50px;
        border: 1px solid #E2E8F0;
        box-shadow: 0 2px 5px rgba(0,0,0,0.02);
    }

    .switch {
        position: relative;
        display: inline-block;
        width: 38px;
        height: 20px;
    }

    .switch input { opacity: 0; width: 0; height: 0; }

    .slider {
        position: absolute;
        cursor: pointer;
        top: 0; left: 0; right: 0; bottom: 0;
        background-color: #CBD5E0;
        transition: .4s;
    }

    .slider:before {
        position: absolute;
        content: "";
        height: 14px; width: 14px;
        left: 3px; bottom: 3px;
        background-color: white;
        transition: .4s;
    }

    input:checked + .slider { background-color: var(--point-color); }
    input:checked + .slider:before { transform: translateX(18px); }
    .slider.round { border-radius: 34px; }
    .slider.round:before { border-radius: 50%; }

    .icon-btn {
        background: #fff;
        border: 1px solid #E2E8F0;
        border-radius: 10px;
        width: 38px;
        height: 38px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--text-sub);
        cursor: pointer;
        transition: 0.2s;
    }

    .icon-btn:hover {
        color: var(--point-color);
        border-color: var(--point-color);
    }

    /* 위로 가기 버튼 스타일 */
    .scroll-top-btn {
        position: fixed;
        bottom: 30px;
        right: 30px;
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background-color: var(--point-color); /* 준삣삐의 블루 컬러 */
        color: white;
        border: none;
        cursor: pointer;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
        opacity: 0;           /* 처음엔 투명하게 */
        visibility: hidden;    /* 처음엔 안 보이게 */
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); /* 쫀득한 등장 애니메이션 */
        transform: translateY(20px); /* 살짝 아래에서 시작 */
    }

    .scroll-top-btn.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0); /* 자기 위치로 올라옴 */
    }

    .scroll-top-btn:hover {
        background-color: #3577ef; /* 살짝 진한 블루 */
        transform: scale(1.1);      /* 커지는 효과 */
    }

    .scroll-top-btn .material-icons {
        font-size: 24px;
        font-weight: bold;
    }
    .btn-star { cursor: pointer; border: none; background: none; padding: 0; display: flex; align-items: center; }
    .btn-star .material-icons { font-size: 24px; color: #e0e5f2; transition: 0.2s; }
    .btn-star.active .material-icons { color: var(--star-color); }

    /* 🚀 완료된 프로젝트 하위 일감(disable-click) 기강 잡기 */
    .task-item.disable-click {
        cursor: not-allowed !important; /* 🚫 금지 표시 커서 슛! */
        opacity: 1.2 !important;        /* 🌫️ 흐릿하게 만들어서 비활성 느낌 팍팍! */
        filter: grayscale(0.2);          /* 🎨 색감도 살짝 빼서 '과거의 일'로 만들기 */
        pointer-events: none !important; /* 🛑 사실 이게 있으면 JS 로직 없어도 클릭 자체가 안 됨! */
        background-color: #f8fafc !important; /* 🏠 배경색도 살짝 죽여주기 */
    }

    /* 🚀 혹시 모를 호버 효과까지 박멸! */
    .task-item.disable-click:hover {
        transform: none !important;      /* 커지는 효과 금지 */
        box-shadow: none !important;     /* 그림자 효과 금지 */
        background-color: #f8fafc !important; 
    }
</style>

<div class="task-wrapper">
    <main class="task-container" id="mainSection">
        <%-- 1. 카운트 변수 초기화 --%>
        <c:set var="todoCount" value="0" />
        <c:set var="doingCount" value="0" />
        <c:set var="doneCount" value="0" />

        <%-- 2. 이중 루프 + 프로젝트 상태 체크 --%>
        <c:forEach items="${projectList}" var="pj">
            
            <%-- 프로젝트 상태가 '완료'가 아닐 때만 내부 업무를 카운트함 --%>
            <c:if test="${pj.projStts != '완료'}">
                <c:forEach items="${pj.taskVOList}" var="tk">
                    <c:choose>
                        <c:when test="${tk.taskStts == '대기'}">
                            <c:set var="todoCount" value="${todoCount + 1}" />
                        </c:when>
                        <c:when test="${tk.taskStts == '진행'}">
                            <c:set var="doingCount" value="${doingCount + 1}" />
                        </c:when>
                        <c:when test="${tk.taskStts == '완료'}">
                            <c:set var="doneCount" value="${doneCount + 1}" />
                        </c:when>
                    </c:choose>
                </c:forEach>
            </c:if>
        </c:forEach>
        <div class="header-content-v2">
            <div class="title-section">
                <div>
                    <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                        <span class="material-icons" style="color: #696cff; font-size: 32px;">layers</span>

                        <div style="display: flex; align-items: baseline; gap: 8px;">
                            <span style="font-size: x-large; font-weight: 800;">프로젝트</span>
                            <span style="font-weight: normal; color: #717171; font-size: 15px;">| 나의 일감</span>
                        </div>
                    </div>

                    <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400; margin-bottom: 30px;">
                        배정된 업무의 상세 내용을 확인하고 실시간으로 관리합니다.
                    </div>
                </div>
                <div class="task-summary-badges">
                    <span class="summary-badge todo">대기 중 <strong>${todoCount}</strong></span>
                    <span class="summary-badge doing">진행 중 <strong>${doingCount}</strong></span>
                    <span class="summary-badge done">완료 <strong>${doneCount}</strong></span>
                </div>
            </div>

            <div class="control-panel-v2">
                <div class="toggle-wrapper" style="display: flex; align-items: center; gap: 20px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span class="check-label" style="font-size: 0.85rem; font-weight: 600; color: #4A5568;">모든 업무 리스트 펼치기</span>
                        <label class="switch">
                            <input type="checkbox" id="expandAllCheck" onchange="handleExpandAll(this)">
                            <span class="slider round"></span>
                        </label>
                    </div>

                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span class="check-label" style="font-size: 0.85rem; font-weight: 600; color: #4A5568;">완료된 프로젝트 표시</span>
                        <label class="switch">
                            <input type="checkbox" id="showCompletedCheck" onchange="handleShowCompleted(this)">
                            <span class="slider round"></span>
                        </label>
                    </div>
                </div>
                <div class="header-actions">
                    <button class="icon-btn" title="새로고침" onclick="location.reload()">
                        <span class="material-icons">refresh</span>
                    </button>
                </div>
            </div>
        </div>
        <div class="legend-container" style="display: flex; align-items: center; justify-content: flex-end; padding: 0 24px 12px 0; gap: 16px; margin-top: -10px;">
            <div style="font-size: 0.75rem; color: #94A3B8; font-weight: 700; letter-spacing: -0.02em;">업무 중요도 :</div>
    
            <div style="display: flex; align-items: center; gap: 5px;">
                <div style="width: 8px; height: 8px; border-radius: 50%; background-color: #FEB2B2; border: 2px solid #F87171;"></div>
                <span style="font-size: 0.75rem; color: #64748B; font-weight: 600;">높음</span>
            </div>

            <div style="display: flex; align-items: center; gap: 5px;">
                <div style="width: 8px; height: 8px; border-radius: 50%; background-color: #FDE68A; border: 2px solid #FBBF24;"></div>
                <span style="font-size: 0.75rem; color: #64748B; font-weight: 600;">보통</span>
            </div>

            <div style="display: flex; align-items: center; gap: 5px;">
                <div style="width: 8px; height: 8px; border-radius: 50%; background-color: #BAE6FD; border: 2px solid #7DD3FC;"></div>
                <span style="font-size: 0.75rem; color: #64748B; font-weight: 600;">낮음</span>
            </div>
        </div>
        
        <c:forEach var="project" items="${projectList}" varStatus="stat">
                <div class="proj-box ${project.projStts == '완료' ? 'project-done' : ''}" 
                    style="${project.projStts == '완료' ? 'display: none;' : ''}">
                    <div class="proj-header" onclick="toggleTasks(this)" 
                        style="display: flex; align-items: center; padding: 22px 30px; gap: 25px; background: #fff; border-bottom: 1px solid #f1f5f9; 
                                border-left: 6px solid ${empty project.projColor ? '#7579ff' : project.projColor};">
            
                        <div style="flex: 1; min-width: 0; display: flex; align-items: center;">
                            <button class="btn-star ${project.projIpt == 'Y' ? 'active' : ''}">
                                <span class="material-icons">${project.projIpt == 'Y'? 'star&nbsp;' : ''}</span>
                            </button>
                            <span class="proj-title" style="font-size: 1.05rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-weight: 800; color: #1B2559;">
                                ${project.projTtl} 
                                <small style="color:var(--text-sub); font-weight: 500;">
                                    (${ (not empty project.taskVOList and project.taskVOList[0].taskNo gt 0) ? fn:length(project.taskVOList) : 0 }건)
                                </small>
                            </span>
                        </div>

                        <div style="display: flex; align-items: center; gap: 30px; flex-shrink: 0;">
                            
                            <div style="display: flex; align-items: center; gap: 12px; width: 260px; justify-content: center; border-left: 1px solid #F1F5F9; border-right: 1px solid #F1F5F9; padding: 0 15px;">
                                <div style="text-align: center;">
                                    <div style="font-size: 0.65rem; color: var(--text-sub); font-weight: 700; text-transform: uppercase;">시작일</div>
                                    <div style="font-size: 0.9rem; font-weight: 800; color: #2D3748;">
                                        <fmt:formatDate value="${project.projBgngDt}" pattern="yyyy-MM-dd"/>
                                    </div>
                                </div>
                                <div style="width: 1px; height: 20px; background: #E2E8F0;"></div>
                                <div style="text-align: center;">
                                    <div style="font-size: 0.65rem; color: var(--text-sub); font-weight: 700; text-transform: uppercase;">종료일</div>
                                    <div style="font-size: 0.9rem; font-weight: 800; color: #2D3748;">
                                        <fmt:formatDate value="${project.projEndDt}" pattern="yyyy-MM-dd"/>
                                    </div>
                                </div>
                            </div>

                            <div style="display: flex; justify-content: center; align-items: center; width: 150px; font-size: 0.85rem; font-weight: 700; white-space: nowrap;">
                                <div style="display: flex; gap: 8px;">
                                    <span style="color: var(--text-sub);">담당자</span>
                                    <span style="color: #4A5568;">${project.projNm}</span>
                                </div>
                            </div>

                            <div style="display: flex; align-items: center; gap: 10px; width: 140px;">
                                <div style="flex: 1; height: 8px; background: #EDF2F7; border-radius: 10px; overflow: hidden; position: relative;">
                                    <div style="position: absolute; top: 0; left: 0; height: 100%; 
                                                width: ${empty project.projPrgrt ? 0 : project.projPrgrt}%; 
                                                background: var(--point-color); border-radius: 10px;
                                                transition: width 0.5s ease-in-out;">
                                    </div>
                                </div>
                                <span style="font-size: 0.9rem; font-weight: 900; color: var(--point-color);">${project.projPrgrt}%</span>
                            </div>

                            <div style="display: flex; align-items: center; gap: 10px; width: 130px; justify-content: flex-end;">

                                <c:choose>
                                    <c:when test="${project.projStts == '진행'}">
                                        <span class="status-tag st-ing" style="padding: 5px 14px; font-size: 0.8rem; border-radius: 20px; font-weight: 800;">진행</span>
                                    </c:when>
                                    <c:when test="${project.projStts == '완료'}">
                                        <span class="status-tag st-done" style="padding: 5px 14px; font-size: 0.8rem; border-radius: 20px; font-weight: 800; background: #E2E8F0; color: #4A5568;">완료</span>
                                    </c:when>
                                    <c:when test="${project.projStts == '지연'}">
                                        <span class="status-tag st-wait" style="padding: 5px 14px; font-size: 0.8rem; border-radius: 20px; font-weight: 800; background: #EDF2F7; color: #718096;">지연</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-tag st-wait" style="padding: 5px 14px; font-size: 0.8rem; border-radius: 20px; font-weight: 800; background: #EDF2F7; color: #718096;">대기</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <span class="material-icons arrow-icon" style="color: var(--text-sub); flex-shrink: 0;">expand_more</span>
                    </div>

                    <div class="sub-task-list">

                
                <c:forEach var="task" items="${project.taskVOList}">
                <c:if test="${not empty task.taskNo and task.taskNo gt 0}">    
                    <div class="task-item ${project.projStts == '완료' ? 'disable-click' : ''}" 
                                onclick="openDrawer(this)" 
                                data-p-start="<fmt:formatDate value='${project.projBgngDt}' pattern='yyyy-MM-dd'/>"
                                data-p-end="<fmt:formatDate value='${project.projEndDt}' pattern='yyyy-MM-dd'/>"
                                style="cursor:pointer; padding: 12px 16px; border-radius: 10px; margin-bottom: 8px; display: flex; align-items: center; gap: 12px;">
                    <input type="hidden" class="task-no" value="${task.taskNo}">
                    <input type="hidden" class="task-ttl" value="${task.taskTtl}">
                    <input type="hidden" class="task-nm" value="${task.taskNm}">
                    <input type="hidden" class="task-bgng" value="<fmt:formatDate value='${task.taskBgngDt}' pattern='yyyy-MM-dd'/>">
                    <input type="hidden" class="task-end" value="<fmt:formatDate value='${task.taskEndDt}' pattern='yyyy-MM-dd'/>">
                    <input type="hidden" class="task-crt" value="<fmt:formatDate value='${task.taskCrtDt}' pattern='yyyy-MM-dd'/>">
                    <input type="hidden" class="task-prg" value="${task.taskPrgrt}">
                    <input type="hidden" class="task-stts" value="${task.taskStts}">
                    <input type="hidden" class="task-impt" value="${task.taskImpt}">
                    <textarea class="task-cn" style="display:none;">${task.taskCn}</textarea>
                        <div style="width: 12px; height: 12px; border-radius: 50%; flex-shrink: 0;
                                    background-color: <c:choose>
                                        <c:when test='${task.taskImpt == "높음"}'>#FEB2B2</c:when>
                                        <c:when test='${task.taskImpt == "보통"}'>#FDE68A</c:when>
                                        <c:otherwise>#BAE6FD</c:otherwise> </c:choose>;
                                    border: 2px solid <c:choose>
                                        <c:when test='${task.taskImpt == "높음"}'>#F87171</c:when>
                                        <c:when test='${task.taskImpt == "보통"}'>#FBBF24</c:when>
                                        <c:otherwise>#7DD3FC</c:otherwise> </c:choose>;">
                        </div>

                        <span class="task-name" style="font-size: 0.95rem; font-weight: 600; color: #4A5568; 
                                    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            ${task.taskTtl}
                        </span>
                        <div style="display: flex; align-items: center; gap: 30px; flex-shrink: 0;">
                            <div style="display: flex; align-items: center; gap: 12px; width: 210px; justify-content: center; border-right: 1px solid #F1F5F9; padding: 0 15px 0 0;">
                                <div style="text-align: center; flex: 1;">
                                    <div style="font-size: 0.65rem; color: var(--text-sub); font-weight: 700; text-transform: uppercase;">시작일</div>
                                    <div style="font-size: 0.85rem; font-weight: 800; color: #2D3748;">
                                        <fmt:formatDate value="${task.taskBgngDt}" pattern="yyyy-MM-dd"/>
                                    </div>
                                </div>
                                <div style="width: 1px; height: 20px; background: #E2E8F0;"></div>
                                <div style="text-align: center; flex: 1;">
                                    <div style="font-size: 0.65rem; color: var(--text-sub); font-weight: 700; text-transform: uppercase;">종료일</div>
                                    <div style="font-size: 0.85rem; font-weight: 800; color: #2D3748;">
                                        <fmt:formatDate value="${task.taskEndDt}" pattern="yyyy-MM-dd"/>
                                    </div>
                                </div>
                            </div>

                            <div style="width: 180px; display: flex; justify-content: center; font-size: 0.85rem; font-weight: 700; color: #4A5568;">
                                <span style="color: var(--text-sub); font-weight: 500; margin-right: 8px;">수정일</span>
                                <span><fmt:formatDate value="${task.taskMdfcnDt}" pattern="yyyy-MM-dd"/></span>
                            </div>

                            <div style="display: flex; align-items: center; gap: 10px; width: 140px;">
                                <div style="flex: 1; height: 6px; background: #EDF2F7; border-radius: 10px; overflow: hidden; position: relative;">
                                    <div style="position: absolute; top: 0; left: 0; height: 100%; 
                                                width: ${empty task.taskPrgrt ? 0 : task.taskPrgrt}%; 
                                                background: #7579ff; border-radius: 10px;
                                                transition: width 0.4s ease-out;">
                                    </div>
                                </div>
                                <span style="font-size: 0.85rem; font-weight: 800; color: #7579ff; min-width: 35px;">${task.taskPrgrt}%</span>
                            </div>

                            <div style="display: flex; align-items: center; gap: 10px; width: 130px; justify-content: flex-end;">

                                <c:choose>
                                    <c:when test="${task.taskStts == '진행'}">
                                        <span class="status-tag st-ing" style="padding: 4px 12px; font-size: 0.75rem; border-radius: 20px; font-weight: 800;">진행</span>
                                    </c:when>

                                    <c:when test="${task.taskStts == '완료'}">
                                        <span class="status-tag st-done" style="padding: 4px 12px; font-size: 0.75rem; border-radius: 20px; font-weight: 800; background: #E2E8F0; color: #4A5568;">완료</span>
                                    </c:when>

                                    <c:when test="${task.taskStts == '지연'}">
                                        <span class="status-tag st-delay" style="padding: 4px 12px; font-size: 0.75rem; border-radius: 20px; font-weight: 800; background: #FFF5F5; color: #E53E3E;">지연</span>
                                    </c:when>

                                    <c:when test="${task.taskStts == '대기'}">
                                        <span class="status-tag st-wait" style="padding: 4px 12px; font-size: 0.75rem; border-radius: 20px; font-weight: 800; background: #EDF2F7; color: #718096;">대기</span>
                                    </c:when>

                                    <c:when test="${task.taskStts == '보류'}">
                                        <span class="status-tag st-hold" style="padding: 4px 12px; font-size: 0.75rem; border-radius: 20px; font-weight: 800; background: #FAF5FF; color: #805AD5;">보류</span>
                                    </c:when>

                                    <c:otherwise>
                                        <span class="status-tag" style="padding: 4px 12px; font-size: 0.75rem; border-radius: 20px; font-weight: 800; background: #F7FAFC; color: #A0AEC0;">-</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div style="width: 24px; flex-shrink: 0;"></div>
                    </div>
                </c:if>    
                </c:forEach>
            <c:if test="${empty project.taskVOList or project.taskVOList[0].taskNo eq 0 or empty project.taskVOList[0].taskNo}">
                <div style="padding: 20px; text-align: center; color: #94a3b8; background: #f8fafc; border-radius: 8px; margin: 10px;">
                    <span class="material-icons" style="vertical-align: middle; font-size: 1.1rem; margin-right: 5px;">info</span>
                    배정된 업무가 없습니다
                </div>
            </c:if>
                </div> 
            </div> 
            
    </c:forEach>

    </main>

    <aside class="side-drawer" id="sideDrawer">
        <div class="drawer-header">
            <div style="display: flex; align-items: center; gap: 8px; white-space: nowrap; overflow: hidden;">
                <h3 style="margin:0; font-weight:800; font-size: 1.1rem; color:var(--text-main); flex-shrink: 0;">업무 상세 정보</h3>
                
                <span style="font-size: 0.7rem; color: var(--text-sub); font-weight: 500; background: #F4F7FE; padding: 2px 6px; border-radius: 4px; flex-shrink: 0;">
                    업무 생성일: <span id="d_create_dt"></span>
                </span>
                
                <span style="font-size: 0.7rem; color: #7579ff; font-weight: 600; background: #EBF2FF; padding: 2px 6px; border-radius: 4px; flex-shrink: 0;">
                    마지막 수정자: <span id="d_writer_nm"></span>
                </span>
            </div>
            <span class="material-icons" style="cursor:pointer; color:var(--text-sub)" onclick="closeDrawer()">close</span>
        </div>
        <div class="drawer-body">
            <input type="hidden" id="d_taskId"/>
            <div style="margin-bottom: 25px;">
                <label class="f-label">업무명</label>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <div id="d_title" style="font-size: 1.1rem; font-weight: 800; color: var(--text-main); line-height: 1.4;"></div>
        
        <input type="text" id="d_title_input" class="f-input" style="display: none; flex: 1; font-size: 1rem; font-weight: 700;">

        <span id="edit_icon" class="material-icons" style="font-size: 1.2rem; color: var(--text-sub); cursor: pointer;" onclick="toggleEditTitle()">edit</span>
        <span id="save_icon" class="material-icons" style="font-size: 1.2rem; color: var(--point-color); cursor: pointer; display: none;" onclick="toggleEditTitle()">check</span>
                </div>
            </div>
            <div class="prog-wrap">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                    <label class="f-label" style="margin:0;">진척도</label>
                    <span id="prog_text" style="color:var(--point-color); font-weight:900; font-size:1.3rem;">%</span>
                </div>
                <input type="range" id="prog_range" min="0" max="100" class="custom-range" oninput="syncProg(this.value)">
            </div>
            <div style="display:flex; gap:15px; margin-bottom:15px;">
                <div style="flex:1;">
                    <label class="f-label">업무 상태</label>
                    <select id="d_status" class="f-input" style="width:100%;">
                        <option value="대기">대기</option>
                        <option value="진행">진행</option>
                        <option value="완료">완료</option>
                        <option value="지연">지연</option>
                        <option value="보류">보류</option>
                    </select>
                </div>
                <div style="flex:1;">
                    <label class="f-label">중요도</label>
                    <select id="d_priority" class="f-input" style="width:100%;">
                        <option value="낮음">낮음</option>
                        <option value="보통">보통</option>
                        <option value="높음">높음</option>
                    </select>
                </div>
            </div>

            <div style="display:flex; gap:15px; margin-bottom:20px;">
                <div style="flex:1;">
                    <label class="f-label">시작일</label>
                    <input type="date" id="d_start" class="f-input" style="width:100%;">
                </div>
                <div style="flex:1;">
                    <label class="f-label">종료일</label>
                    <input type="date" id="d_end" class="f-input" style="width:100%;">
                </div>
            </div>
            <div style="margin-bottom:30px;">
                <label class="f-label">상세 내용</label>
                <textarea id="d_desc" class="f-input" rows="7" style="resize:none;" placeholder="작업 상세 내용을 입력하세요..."></textarea>
            </div>
            <button onclick="saveDone()" style="width:100%; padding:16px; background:#696CFF; color:#fff; border:none; border-radius:12px; font-weight:800; cursor:pointer;">Update & Save</button>
        </div>
    </aside>
</div>

<!-- Top버튼 -->
<button id="scrollTopBtn" class="scroll-top-btn" onclick="scrollToTop()">
    <span class="material-icons">arrow_upward</span>
</button>
<script>

    //현재 수정중인 업무번호 저장용
    let currentTaskNo = null;

    // 🚨 ALL EXPAND / COLLAPSE
    function handleExpandAll(checkbox) {
        const lists = document.querySelectorAll('.sub-task-list');
        const arrows = document.querySelectorAll('.arrow-icon');
        const isChecked = checkbox.checked;

        lists.forEach(list => {
            if (isChecked) list.classList.add('expanded');
            else list.classList.remove('expanded');
        });

        arrows.forEach(arrow => {
            arrow.innerText = isChecked ? "expand_less" : "expand_more";
        });
    }

    // 🚨 INDIVIDUAL TOGGLE
    function toggleTasks(el) {
        const list = el.nextElementSibling;
        const arrow = el.querySelector('.arrow-icon');
        const isExpanded = list.classList.contains('expanded');

        if (isExpanded) {
            list.classList.remove('expanded');
            arrow.innerText = "expand_more";
        } else {
            list.classList.add('expanded');
            arrow.innerText = "expand_less";
        }
    }

    // DRAWER LOGIC
    function openDrawer(el) {
        
        // 1. el이 존재하는지, 클래스가 있는지 꼼꼼하게 체크 슛!
        if (el && el.classList && el.classList.contains('disable-click')) {
            return; 
        }
        // 클릭한 태그(el) 안에서 hidden 값들 쏙쏙 뽑기
        const no = el.querySelector('.task-no').value;
        const ttl = el.querySelector('.task-ttl').value;
        const nm = el.querySelector('.task-nm').value;
        const bgng = el.querySelector('.task-bgng').value;
        const end = el.querySelector('.task-end').value;
        const crt = el.querySelector('.task-crt').value;
        const prg = el.querySelector('.task-prg').value;
        const stts = el.querySelector('.task-stts').value;
        const impt = el.querySelector('.task-impt').value;
        const cn = el.querySelector('.task-cn').value; // 엔터가 몇 개든 완벽하게 가져옴!

        // 전역 변수에 번호 저장 (수정용)
        currentTaskNo = no;

        // 🔥 여기서 HTML에 심어둔 포맷팅된 날짜를 쏙!
        const pStart = el.dataset.pStart; 
        const pEnd = el.dataset.pEnd;

        const bgngInput = document.getElementById('d_start');
        const endInput = document.getElementById('d_end');

        // 🔥 달력에 제약 걸기
        if (pStart) {
            bgngInput.min = pStart;
            endInput.min = pStart;
        }
        if (pEnd) {
            bgngInput.max = pEnd;
            endInput.max = pEnd;
        }


        // 드로어 UI에 데이터 박기
        document.getElementById('d_title').innerText = ttl;
        document.getElementById('d_title_input').value = ttl;
        document.getElementById('d_writer_nm').innerText = nm;
        document.getElementById('d_start').value = bgng;
        document.getElementById('d_end').value = end;
        document.getElementById('d_create_dt').innerText = crt;
        document.getElementById('prog_range').value = prg;
        document.getElementById('d_status').value = stts;
        document.getElementById('d_priority').value = impt;
        document.getElementById('d_desc').value = cn;

        // 게이지 업데이트 및 드로어 열기
        syncProg(prg);
        document.getElementById('sideDrawer').classList.add('open');
        document.getElementById('mainSection').classList.add('shrunk');
    }
    // [B] 제목 수정 토글: 화면 전환만 담당
    function toggleEditTitle() {
        const titleDiv = document.getElementById('d_title');
        const titleInput = document.getElementById('d_title_input');
        const editIcon = document.getElementById('edit_icon');
        const saveIcon = document.getElementById('save_icon');

        if (titleInput.style.display === 'none') {
            // 수정 모드 ON
            titleDiv.style.display = 'none';
            titleInput.style.display = 'block';
            editIcon.style.display = 'none';
            saveIcon.style.display = 'inline-block';
            titleInput.focus();
        } else {
            // 수정 모드 OFF (input 값을 다시 div에 반영)
            titleDiv.innerText = titleInput.value;
            titleDiv.style.display = 'block';
            titleInput.style.display = 'none';
            editIcon.style.display = 'inline-block';
            saveIcon.style.display = 'none';
        }
    }

    function closeDrawer() {
        document.getElementById('sideDrawer').classList.remove('open');
        document.getElementById('mainSection').classList.remove('shrunk');
    }

    function syncProg(v) {
        document.getElementById('prog_text').innerText = v + '%';
        const r = document.getElementById('prog_range');
        const p = (v - r.min) / (r.max - r.min) * 100;
        r.style.background = `linear-gradient(to right, #7579ff 0%, #7579ff \${p}%, #E2E8F0 \${p}%, #E2E8F0 100%)`;
    }

    function saveDone() {
        if(!currentTaskNo) return; // 식별자 없으면 back!

        const updateData = {
            taskNo: currentTaskNo,
            taskTtl: document.getElementById('d_title_input').value,
            taskPrgrt: document.getElementById('prog_range').value,
            taskStts: document.getElementById('d_status').value,
            taskImpt: document.getElementById('d_priority').value,
            taskBgngDt: document.getElementById('d_start').value,
            taskEndDt: document.getElementById('d_end').value,
            taskCn: document.getElementById('d_desc').value
        };

        // 서버로 전송 (Axios 예시)
        axios.post('/mywork/update', updateData)
            .then((res) => {
                if(res.data.result === 'success'){
                    Swal.fire({
                    title: 'Success!',
                    text: '일감 수정이 완료되었습니다.',
                    icon: 'success',
                    confirmButtonColor: '#7579ff'
                }).then((result) => {
                    // 2. [중요] 사용자가 확인 버튼을 눌렀을 때만 새로고침!
                    if (result.value) {
                        closeDrawer();
                        setTimeout(() => {
                            window.location.reload();
                        }, 300);
                    }
                });
                }
            }).catch((err) => {
                Swal.fire('Error', '서버 통신 중 에러 발생!', 'error');
            });
        
    }
    // 스크롤 감지 이벤트
    window.addEventListener('scroll', function() {
        const scrollBtn = document.getElementById('scrollTopBtn');
        if (window.scrollY > 300) { // 300px 이상 내려오면
            scrollBtn.classList.add('show');
        } else {
            scrollBtn.classList.remove('show');
        }
    });

    // 위로 부드럽게 올리기
    function scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth' // 이게 있어야 부드럽게 올라감!
        });
    }
    // 완료항목 숨김
    function handleShowCompleted(checkbox) {
        const completedProjects = document.querySelectorAll('.project-done');

        completedProjects.forEach(proj => {
            if (checkbox.checked) {
                proj.style.display = 'block'; // 🦾 체크하면 등장!
                proj.style.opacity = '0.45';   // 💡 완료된 건 살짝 흐리게 하면 더 센스 있음!
            } else {
                proj.style.display = 'none';  // 🦾 해제하면 다시 숨김!
            }
        });
    }
document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const targetTaskNo = urlParams.get('taskNo');

    if (targetTaskNo) {
        // 1초 뒤에 실행 (데이터 로딩 시간 확보)
        setTimeout(function() {
            let foundInput = null;
            const allInputs = document.querySelectorAll('.task-no');
            
            // 깐깐하게 번호 대조
            for (let i = 0; i < allInputs.length; i++) {
                if (String(allInputs[i].value).trim() === String(targetTaskNo).trim()) {
                    foundInput = allInputs[i];
                    break;
                }
            }
            
            if (foundInput) {
                const taskItem = foundInput.closest('.task-item');
                const projBox = foundInput.closest('.proj-box');
                const subTaskList = projBox ? projBox.querySelector('.sub-task-list') : null;
                const arrowIcon = projBox ? projBox.querySelector('.arrow-icon') : null;

                // 1. 숨겨진 프로젝트 박스 해제
                if (projBox && projBox.style.display === 'none') {
                    projBox.style.display = 'block';
                    projBox.style.opacity = '0.7'; 
                }

                // 2. 일감 리스트 펼치기
                if (subTaskList) {
                    subTaskList.classList.add('expanded');
                    if (arrowIcon) {
                        arrowIcon.innerText = 'expand_less';
                    }
                }

                // 3. 일감 클릭 및 스크롤 이동
                if (taskItem) {
                    taskItem.click(); 
                    taskItem.scrollIntoView({ behavior: 'smooth', block: 'center' });

                    // 강조 포인트 (노란색 반짝)
                    taskItem.style.backgroundColor = "#fff9db"; 
                    setTimeout(function() {
                        taskItem.style.backgroundColor = "";
                    }, 2000);
                }
            } else {
                console.log("준삣삐! 화면에 해당 일감이 없네? 번호를 확인해봐!");
            }

            // 주소창 파라미터 제거
            window.history.replaceState({}, document.title, window.location.pathname);
        }, 200); 
    }
});
</script>