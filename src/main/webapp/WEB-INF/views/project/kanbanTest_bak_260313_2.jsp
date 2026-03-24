<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<!-- 💙💙💙💙💙💙칸반 드래그앤드롭 외부 라이브러리💙💙💙💙💙💙-->
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<!-- 💙💙💙💙💙💙멘션💙💙💙💙💙💙 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.css">

<!-- 튜토리얼 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.css"/>
<script src="https://cdn.jsdelivr.net/npm/driver.js@1.0.1/dist/driver.js.iife.js"></script>

<!-- SweetAlert2 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>


<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal.EmpVO" var="userIdTest"/>
</sec:authorize>
<c:set var="userRole" value="${userIdTest.empRole}" />


<script>
    //너 팀장이니!?!?
    const isTeamjang="${userIdTest.empRole}" ; //JSTL변수 -> J/S변수
    console.log("프로젝트로 들어왓을때?!! 너 팀장이니? : ", isTeamjang);
</script>


<style>
#tab-kanban {
    padding-top: 10px; /* 헤더 바로 아래에 붙도록 조정 */
}

.kb-container {
    background-color: #FFFFFF !important;
    padding: 1.5rem;
    min-height: calc(100vh - 60px);
    font-family: 'Public Sans', sans-serif;
}



    /* --------------------------------------
       상단 탭 전용 스타일 (폴더형 디자인 적용)
    -------------------------------------- */
    .project-tabs-container { background-color: #F4F7FF; padding: 1.5rem 1.5rem 0 1.5rem; }
    .project-tabs { display: flex; gap: 5px; align-items: flex-end; height: 48px; }

    .project-tab-btn {
        border: none; background: #e0e5f2; color: #707eae; padding: 10px 25px;
        font-size: 0.95rem; font-weight: 700; border-radius: 12px 12px 0 0;
        cursor: pointer; height: 40px; font-family: 'Pretendard', sans-serif;
    }
    .project-tab-btn.active { background: #fff; color: #696CFF; height: 48px; box-shadow: 0 -5px 10px rgba(0,0,0,0.02); }

    .tab-content { display: none; /* 왼쪽 위(0), 오른쪽 위(25px), 오른쪽 아래(25px), 왼쪽 아래(25px) */
        border-radius: 0 25px 25px 25px;
        /* 탭이랑 자연스럽게 이어지도록 여백 조절 */
        margin: 0 1.5rem 1.5rem 1.5rem;
        box-shadow: 0 10px 30px rgba(0,0,0,0.02);

    }
    .tab-content.active { display: block; background: #fff; }

    /* --------------------------------------
       💙💙💙💙💙💙칸반 스타일 시작💙💙💙💙💙💙
    -------------------------------------- */

    /* 멘션 및 Tribute.js (기존 유지) */
    .mention-btn, .mention-btnCc {
        display: inline-flex; align-items: center; background-color: rgba(105, 108, 255, 0.1);
        color: #696CFF; border: 1px solid rgba(105, 108, 255, 0.2); border-radius: 20px;
        padding: 2px 8px; margin: 0 4px; font-weight: 600; font-size: 14px; transition: all 0.2s ease;
    }
    .mention-btn:hover, .mention-btnCc:hover { background-color: rgba(105, 108, 255, 0.2); }

    .del-mention, .del-mentionCc {
        color: inherit; text-decoration: none; display: inline-flex; align-items: center;
        justify-content: center; width: 16px; height: 16px; margin-left: 6px;
        border-radius: 50%; font-size: 12px; line-height: 1; cursor: pointer; transition: background 0.2s;
    }
    .del-mention:hover, .del-mentionCc:hover { background-color: #696CFF; color: #fff; }

    .tribute-container {
        position: absolute; top: 0; left: 0; height: auto; max-height: 300px; max-width: 500px;
        overflow: auto; display: block; z-index: 999999; background-color: #fff;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1); border-radius: 8px; border: 1px solid #eaeaec; padding: 5px 0;
    }
    .tribute-container ul { margin: 0; padding: 0; list-style: none; }
    .tribute-container li { padding: 10px 15px; cursor: pointer; font-size: 14px; color: #566a7f; transition: background 0.15s; }
    .tribute-container li.highlight, .tribute-container li:hover { background-color: rgba(105, 108, 255, 0.08); color: #696CFF; }
    .tribute-container li span { font-weight: bold; }

    /* 칸반보드 레이아웃 */
    .kb-container { background-color: #fff; padding: 1.5rem; min-height: 100vh; font-family: 'Public Sans', sans-serif; }
    .kb-board-wrapper { display: flex; gap: 1.25rem; overflow-x: auto; padding-bottom: 1rem; }

    .kb-col {
        flex: 1; min-width: 200px; display: flex; flex-direction: column; gap: 1rem;
        background-color: #f4f5f8; border: 1px solid #e4e6ef; border-radius: 12px;
        padding: 12px 6px 12px 12px; height: 550px;
    }
    .kb-col-title {
        display: flex; align-items: center; justify-content: space-between;
        padding: 0.5rem 0.25rem; font-weight: 700; color: #566a7f; text-transform: uppercase; font-size: 0.85rem;
    }
    .kb-col[data-status="대기"] .kb-col-title { border-bottom: 3px solid #8592a3; }
    .kb-col[data-status="진행"] .kb-col-title { border-bottom: 3px solid #696CFF; }
    .kb-col[data-status="완료"] .kb-col-title { border-bottom: 3px solid #57c11d; }
    .kb-col[data-status="보류"] .kb-col-title { border-bottom: 3px solid #df9600; }
    .kb-col[data-status="지연"] .kb-col-title { border-bottom: 3px solid #ff3e1d; }

    .kb-task-list { flex: 1; overflow-y: auto; overflow-x: hidden; padding-right: 6px; min-height: 10px; }

    /* 일감 카드 */
    .kb-card {
        background: #fff; border-radius: 0.5rem; padding: 0.8rem 1rem; margin-bottom: 0.8rem;
        box-shadow: 0 2px 4px 0 rgba(67, 89, 113, 0.1); border: 1px solid #d9dee3;
        transition: all 0.2s; cursor: pointer; position: relative;
    }
    .kb-card:hover { transform: translateY(-3px); box-shadow: 0 4px 12px 0 rgba(67, 89, 113, 0.2); }

    .kb-card-body { margin-bottom: 0.5rem !important; }

    .kb-task-name {
        font-weight: 700; color: #566a7f; font-size: 0.88rem;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 0.2rem;
    }

    .kb-progress-container { margin-top: 0.5rem; }
    .kb-card-footer {
        margin-top: 0.6rem; padding-top: 0.6rem; border-top: 1px dashed #e4e6ef;
        display: flex; justify-content: space-between; align-items: center;
    }

    .kb-ghost { opacity: 0.3; border: 2px dashed #696CFF !important; transform: scale(0.95); }

    /* 상세 모달용 뱃지 (남겨둠) */
    .kb-badge { font-size: 0.7rem; padding: 0.2rem 0.5rem; border-radius: 0.25rem; font-weight: 600; }
    .badge-delay { background: #ffe5e0; color: #ff3e1d; }
    .badge-progress { background: #e7e7ff; color: #696CFF; }
    .badge-done { background: #e8fadf; color: #71dd37; }

    /* 진행률 슬라이더 UI */
    .kb-progress-slider {
        -webkit-appearance: none; width: 100%; height: 6px; border-radius: 4px;
        outline: none; margin-top: 5px; transition: background 0.1s;
    }
    .kb-progress-slider::-webkit-slider-thumb {
        -webkit-appearance: none; appearance: none; width: 16px; height: 16px;
        border-radius: 50%; background: #fff; border: 3px solid #696CFF;
        cursor: grab; box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    .kb-progress-slider::-webkit-slider-thumb:active { cursor: grabbing; transform: scale(1.2); }

    .kb-col-badge {
        background-color: #ffffff !important; color: #566a7f !important;
        border: 1px solid #d9dee3; box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    }

    /* 카드 내 높이 통일 및 뱃지 UI */
    .kb-title-wrapper { display: flex; flex-direction: column; flex: 1; min-width: 0; min-height: 38px; justify-content: center; }
    .my-task-dot { font-size: 0.65rem; font-weight: 800; color: #696CFF; display: flex; align-items: center; gap: 3px; height: 15px; }

    .kb-progress-labels { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
    .kb-progress-label-text { font-size: 0.75rem; font-weight: 700; color: #566a7f; }
    .kb-progress-percent { font-size: 0.8rem; font-weight: 800; color: #696CFF; }

    /* 커스텀 스크롤바 */
    .kb-task-list::-webkit-scrollbar { width: 6px; }
    .kb-task-list::-webkit-scrollbar-track { background: transparent; }
    .kb-task-list::-webkit-scrollbar-thumb { background-color: #cdd4df; border-radius: 10px; }
    .kb-task-list::-webkit-scrollbar-thumb:hover { background-color: #a1acb8; }
    /* --------------------------------------
   💙💙💙💙💙💙칸반 스타일 끝💙💙💙💙💙💙
    -------------------------------------- */




    /* 💕💕💕💕💕💕 구성원 스타일 💕💕💕💕💕💕 ---------------------------------------------- */
    .member-main-wrapper { display: flex; gap: 24px; align-items: flex-start; padding: 20px 0; }
    .m-card {
        background: #fff; border-radius: 12px; padding: 25px;
        border: 1px solid #e6e9ed; box-shadow: 0 4px 15px rgba(0,0,0,0.04);
    }
    .m-left-chart { flex: 1; }
    .m-right-list { flex: 1.3; }

    .chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
    .chart-title { font-size: 1.1rem; font-weight: 800; color: #444; }
    .custom-legend { display: flex; gap: 12px; }
    .legend-item { display: flex; align-items: center; font-size: 0.8rem; font-weight: 600; color: #666; }
    .legend-color { width: 10px; height: 10px; border-radius: 2px; margin-right: 5px; }

    .m-filter-row { display: flex; gap: 6px; margin-bottom: 20px; align-items: center; }
    .m-search-group { display: flex; width: 320px; border: 1px solid #d9dee3; border-radius: 8px; overflow: hidden; background: #fff; transition: 0.2s; }
    .m-search-group:focus-within { border-color: #696CFF; }
    .m-search-group input { border: none; padding: 10px 15px; width: 100%; outline: none; }

    .m-btn-search { background: #696CFF; color: #fff; border: none; padding: 10px 22px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; }
    .m-btn-reset { background: #fff; color: #696CFF; border: 1.5px solid #696CFF; padding: 9px 18px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; }

    .m-table { width: 100%; border-collapse: collapse; }
    .m-table th { border-bottom: 2px solid #f0f2f5; padding: 12px; text-align: left; color: #8592a3; font-size: 0.8rem; }
    .m-table td { border-bottom: 1px solid #f4f6f9; padding: 14px 12px; font-size: 0.9rem; color: #566a7f; }
    .m-btn-chat { background: #ffffff; border: 1px solid #696CFF; border-radius: 6px; padding: 7px; color: #696CFF; cursor: pointer; transition: 0.2s; display: inline-flex; }
    .m-btn-chat:hover { background: #696CFF; color: #fff; }
    .m-btn-chat span { pointer-events: none; }

    /* 스크롤바 */
    #tab-member { height: calc(100vh - 150px); overflow-y: auto; overflow-x: hidden; }
    #tab-member::-webkit-scrollbar { width: 8px; }
    #tab-member::-webkit-scrollbar-thumb { background: #d9dee3; border-radius: 10px; }
    #tab-member::-webkit-scrollbar-track { background: transparent; }
    .tab-member-header { position: sticky; top: 0; background: #f5f5f9; z-index: 10; padding: 2rem 2rem 1rem 2rem; margin: -2rem -2rem 0 -2rem; }
    /* 💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕 ---------------------------------------------- */

</style>

<div class="project-tabs-container">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                <span class="material-icons" style="color: #696cff; font-size: 32px;">layers</span>

                <div style="display: flex; align-items: baseline; gap: 8px;">
                    <span style="font-size: x-large; font-weight: 800;">프로젝트</span>
                    <!-- 만약 내가 팀장이라면? 프로젝트 관리, 아니라면? 나의 프로젝트 -->
                    <span style="font-weight: normal; color: #717171; font-size: 15px;">
                    | ${userRole == '팀장' ? '프로젝트 관리' : '나의 프로젝트'}
                </span>
                </div>
            </div>

            <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                ${userRole == '팀장' ? '우리 팀의 프로젝트 현황을 한눈에 관리하세요.' : '내가 참여 중인 프로젝트를 확인하세요.'}
            </div>
        </div>

    </div>





    <div class="project-tabs">
        <button class="project-tab-btn active" onclick="switchTab(event, 'tab-summary');chartLoadfn(${projNo})">요약</button>
        <button class="project-tab-btn" onclick="switchTab(event, 'tab-kanban')" id="toKanban">일감</button>
        <button class="project-tab-btn" onclick="switchTab(event, 'tab-schedule')">일정</button>
        <button class="project-tab-btn" onclick="switchTab(event, 'tab-member')">구성원</button>
        <button class="project-tab-btn" onclick="switchTab(event, 'tab-gantt'); getTasksforGantt();">간트차트</button>
    </div>
</div>
<!-- ❤️❤️❤️❤️❤️❤️❤️❤️ 요약 (summary) 시작❤️❤️❤️❤️❤️❤️❤️❤️ -->
<jsp:include page="projectSummary.jsp"></jsp:include>
<!-- ❤️❤️❤️❤️❤️❤️❤️❤️ 요약 (summary) 끝❤️❤️❤️❤️❤️❤️❤️❤️ -->
<!-- 💙💙💙💙💙💙칸반 영역 시작💙💙💙💙💙💙 -->
<div id="tab-kanban" class="tab-content">

    <div class="kb-container">

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 2px solid #f0f2f4;">

            <h3 id="kb-proj-title" style="margin: 0; color: #435971; font-weight: 800; font-size: 1.6rem; display: flex; align-items: center;">
                <span class="material-icons" style="font-size: 2rem; margin-right: 10px; color: #696CFF;">view_kanban</span>로딩중...
            </h3>

            <div style="display: flex; gap: 10px; align-items: center;">
                <button onclick="startKanbanTutorial()" style="display: flex; align-items: center; gap: 5px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 10px 15px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.2s;">
                    <span class="material-icons" style="font-size: 1.1rem;">help_outline</span> 튜토리얼
                </button>
                <button id="tutorial-add-btn" onclick="openTaskModal()" style="background: #696CFF; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: bold; cursor: pointer; box-shadow: 0 2px 6px rgba(105, 108, 255, 0.4);">
                    + 새 일감 추가
                </button>
            </div>
        </div>

        <div style="display: flex; justify-content: flex-start; gap: 14px; font-size: 0.75rem; color: #a1acb8; font-weight: 600; margin-bottom: 1rem; margin-left: 4px;">
            <span style="display: flex; align-items: center; gap: 5px;">
                <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background-color: #ff3e1d;"></span> 중요도 높음
            </span>
            <span style="display: flex; align-items: center; gap: 5px;">
                <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background-color: #3282F6;"></span> 보통
            </span>
            <span style="display: flex; align-items: center; gap: 5px;">
                <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background-color: #8592a3;"></span> 낮음
            </span>
        </div>

        <div class="kb-board-wrapper">
            <div class="kb-col" data-status="대기">
                <div class="kb-col-title">TO DO <span class="badge rounded-pill kb-col-badge">2</span></div>
                <div class="kb-task-list" id="todo"></div>
            </div>

            <div class="kb-col" data-status="진행">
                <div class="kb-col-title">IN PROGRESS <span class="badge rounded-pill kb-col-badge">1</span></div>
                <div class="kb-task-list" id="inprogress"></div>
            </div>

            <div class="kb-col" data-status="완료">
                <div class="kb-col-title">DONE <span class="badge rounded-pill kb-col-badge">1</span></div>
                <div class="kb-task-list" id="done"></div>
            </div>

            <div class="kb-col" data-status="보류">
                <div class="kb-col-title">ON HOLD <span class="badge rounded-pill kb-col-badge">0</span></div>
                <div class="kb-task-list" id="hold"></div>
            </div>

            <div class="kb-col" data-status="지연">
                <div class="kb-col-title">DELAYED <span class="badge rounded-pill kb-col-badge">1</span></div>
                <div class="kb-task-list" id="delay"></div>
            </div>

            </div>
        </div>
    </div>


</div>
<!-- 💙💙💙💙💙💙칸반 영역 끝💙💙💙💙💙💙 -->

<div id="tab-schedule" class="tab-content">
    <div style="padding: 2rem; min-height: 80vh;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 2px solid #f0f2f4;">
            <h3 id="proj-title-schedule" style="margin: 0; color: #435971; font-weight: 800; font-size: 1.6rem; display: flex; align-items: center;">
                <span class="material-icons" style="font-size: 2rem; margin-right: 10px; color: #696CFF;">fact_check</span>
                ${project.projTtl}
            </h3>
        </div>

        <!-- ✅ projNo를 명시적으로 전달 -->
        <jsp:include page="/WEB-INF/views/project/schedule.jsp">
            <jsp:param name="projNo" value="${projNo}"/>
        </jsp:include>
    </div>
</div>



<!-- 💕💕💕💕💕💕 구성원 💕💕💕💕💕💕 ---------------------------------------------- -->
<div id="tab-member" class="tab-content">
    <div style="padding: 2rem; min-height: 80vh;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 2px solid #f0f2f4;">
            <h3 id="proj-title" style="margin: 0; color: #435971; font-weight: 800; font-size: 1.6rem; display: flex; align-items: center;">
                <span class="material-icons" style="font-size: 2rem; margin-right: 10px; color: #696CFF;">fact_check</span>
                <span id="proj-title-text"></span>
            </h3>
            <!-- 튜토리얼 버튼 -->
            <button onclick="startMemberTutorial()" style="display: flex; align-items: center; gap: 5px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 10px 15px; border-radius: 8px; font-weight: bold; cursor: pointer; transition: 0.2s;">
                <span class="material-icons" style="font-size: 1.1rem;">help_outline</span> 튜토리얼
            </button>
        </div>

        <div class="member-main-wrapper">
            <div class="m-left-chart m-card">
                <div class="chart-header">
                    <span class="chart-title" style="white-space: nowrap; padding-top: 5px;">구성원별 업무 현황</span>
                    <!--
                    <div class="custom-legend">
                        <div class="legend-item"><div class="legend-color" style="background: #512DA8;"></div>총업무</div>
                        <div class="legend-item"><div class="legend-color" style="background: #9575CD;"></div>진행중</div>
                        <div class="legend-item"><div class="legend-color" style="background: #D1C4E9;"></div>완료</div>
                        <div class="legend-item"><div class="legend-color" style="background: #A8A8A8;"></div>대기</div>
                        #9575CD;"></div>높음
                        #D1C4E9;"></div>보통
                        #CFD8DC;"></div>낮음
                        #FF8A80;"></div>진행중
                        #81D4FA;"></div>완료
                        #A8A8A8;"></div>대기
                    -->
                    <div class="custom-legend-container" style="width: 100%; margin-top: 10px;">
                        <!-- 첫 번째 줄: 중요도 (총업무 구성 요소) -->
                        <div class="custom-legend-row" style="display: flex; gap: 15px; margin-bottom: 5px; justify-content: flex-end;">
                            <span style="font-size: 12px; font-weight: bold; color: #666; margin-right: 5px;">총업무 구성 |</span>
                            <div class="legend-item"><div class="legend-color" style="background: #FF6A55;"></div>높음</div>
                            <div class="legend-item"><div class="legend-color" style="background: #82B5FF;"></div>보통</div>
                            <div class="legend-item"><div class="legend-color" style="background: #D5D9DE;"></div>낮음</div>
                        </div>
                        <!-- 두 번째 줄: 상태 -->
                        <div class="custom-legend-row" style="display: flex; gap: 15px; justify-content: flex-end;">
                            <div class="legend-item"><div class="legend-color" style="background: #A8AAFF;"></div>진행중</div>
                            <div class="legend-item"><div class="legend-color" style="background: #A5E086;"></div>완료</div>
                            <div class="legend-item"><div class="legend-color" style="background: #E2E5E9;"></div>대기</div>
                        </div>
                    </div>
                </div>
                <div style="height: 600px;"><canvas id="memberHorizontalChart"></canvas></div>
            </div>

            <div class="m-right-list m-card">
                <div class="chart-header">
                    <span class="chart-title">구성원 목록 (<span id="m-member-count">${memberStList.size()}</span>)</span>
                </div>
                <div class="m-filter-row">
                    <div class="m-search-group">
                        <input type="text" id="m-search-input" placeholder="이름 또는 부서 입력">
                    </div>
                    <button class="m-btn-search" id="m-btn-search">검색</button>
                    <button class="m-btn-reset" id="m-btn-reset">초기화</button>
                </div>
                <table class="m-table">
                    <thead>
                    <tr><th>No</th><th>이름</th><th>부서</th><th>직급</th><th>총업무</th><th>채팅</th></tr>
                    </thead>
                    <tbody id="memberTableBody">
                    <c:forEach var="member" items="${memberStList}" varStatus="stat">
                        <tr>
                            <td>${stat.count}</td>
                            <td style="font-weight: 700; color: #333;">${member.prtpntNm}</td>
                            <td>${member.deptNm}</td>
                            <td>${member.jbgdNm}</td>
                            <td><b style="color:#696CFF">${member.totalTasks}</b> 건</td>
                            <td>
                                <button class="m-btn-chat" onclick="goToCreateChat('${member.empId}', '${member.prtpntNm}')">
                                    <span class="material-icons" style="font-size: 18px;">chat_bubble_outline</span>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<form id="directChatForm" action="/chat/createDirect" method="post" style="display:none;">
    <input type="hidden" name="chatRmTtl" id="directChatTitle">
    <input type="hidden" name="targetId" id="directTargetId">
    <input type="hidden" name="chatRmType" value="GROUP">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>
<!-- 💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕 ---------------------------------------------- -->



<!-- 💙💙💙💙💙💙칸반에서 새일감 추가하는 모달💙💙💙💙💙💙 -->
<div id="taskModal" onclick="closeTaskModal(event)" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.4); z-index: 9999; justify-content: center; align-items: center; backdrop-filter: blur(2px);">

    <div style="background: #fff; padding: 2rem; border-radius: 12px; width: 500px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">

        <h5 style="margin-bottom: 1.5rem; color: #566a7f; font-weight: 700;">
            새 일감 추가
        </h5>

        <div style="margin-bottom: 1rem;">
            <label style="display: block; font-size: 0.85rem; margin-bottom: 0.5rem; color: #566a7f; font-weight: 600;">
                프로젝트 명 : <span id="modalProjNm" style="color: #696CFF;"></span>
            </label>
        </div>

        <div style="margin-bottom: 1rem;">
            <label style="display: block; font-size: 0.85rem; margin-bottom: 0.5rem; color: #566a7f; font-weight: 600;">일감 제목</span></label>
            <input type="text" id="newTaskTtl" style="width: 100%; padding: 10px; border: 1px solid #d9dee3; border-radius: 6px; outline: none;" placeholder="예: 메인 페이지 UI 디자인">
        </div>

        <div style="margin-bottom: 1rem;">
            <label style="display: block; font-size: 0.85rem; margin-bottom: 0.5rem; color: #566a7f; font-weight: 600;">일감 설명</label>
            <textarea id="newTaskCn" rows="3" style="width: 100%; padding: 10px; border: 1px solid #d9dee3; border-radius: 6px; outline: none; resize: none;" placeholder="상세 내용을 입력하세요"></textarea>
        </div>

        <div style="margin-bottom: 1rem;">
            <label style="display: block; font-size: 0.85rem; margin-bottom: 0.5rem; color: #566a7f; font-weight: 600;">중요도</label>
            <select id="newTaskImpt" style="width: 100%; padding: 10px; border: 1px solid #d9dee3; border-radius: 6px; outline: none;">
                <option value="높음"> 높음</option>
                <option value="보통" selected>보통</option>
                <option value="낮음">낮음</option>
            </select>
        </div>

        <div style="margin-bottom: 1rem;">
            <label style="display: block; font-size: 0.85rem; margin-bottom: 0.5rem; color: #566a7f; font-weight: 600;">일감 담당자</label>
            <div class="form-control" id="receiver" contenteditable="true"></div>
        </div>

        <div style="margin-bottom: 1.5rem; display: flex; gap: 1rem;">
            <div style="flex: 1;">
                <label style="display: block; font-size: 0.85rem; margin-bottom: 0.5rem; color: #566a7f; font-weight: 600;">예상 시작일</label>
                <input type="date" id="newTaskBgngDt" style="width: 100%; padding: 10px; border: 1px solid #d9dee3; border-radius: 6px; outline: none;">
            </div>
            <div style="flex: 1;">
                <label style="display: block; font-size: 0.85rem; margin-bottom: 0.5rem; color: #566a7f; font-weight: 600;">예상 마감일</label>
                <input type="date" id="newTaskEndDt" style="width: 100%; padding: 10px; border: 1px solid #d9dee3; border-radius: 6px; outline: none;">
            </div>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 10px;">
            <button onclick="closeTaskModal()" style="padding: 10px 20px; border: none; border-radius: 6px; background: #f4f7fe; color: #566a7f; font-weight: bold; cursor: pointer;">취소</button>
            <button onclick="insertNewTask()" style="padding: 10px 20px; border: none; border-radius: 6px; background: #696CFF; color: white; font-weight: bold; cursor: pointer;">저장하기</button>
        </div>

    </div> </div>
<!-- 💙💙💙💙💙💙칸반에서 새일감 추가하는 모달 끝💙💙💙💙💙💙 -->

<!-- 💙💙💙💙💙💙칸반에서 상세 일감 보는 모달 시작💙💙💙💙💙💙 -->
<div id="detailModal" onclick="closeDetailModal(event)" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.4); z-index: 10000; justify-content: center; align-items: center; backdrop-filter: blur(2px);">
    <div style="background: #fff; padding: 2rem; border-radius: 12px; width: 500px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <h4 id="detailTtl" style="margin: 0; color: #566a7f; font-weight: 800;">일감 상세 정보</h4>
            <span id="detailImptBadge" class="kb-badge"></span>
        </div>

        <div style="margin-bottom: 1.5rem;">
            <label style="display: block; font-size: 0.85rem; color: #a1acb8; margin-bottom: 0.5rem;">상세 내용</label>
            <div id="detailCn" style="background: #f8f9fa; padding: 1rem; border-radius: 8px; min-height: 100px; color: #566a7f; line-height: 1.6; white-space: pre-wrap;"></div>
        </div>

        <div style="display: flex; gap: 1.5rem; margin-bottom: 1.5rem; border-bottom: 1px solid #f0f2f4; padding-bottom: 1.5rem;">
            <div style="flex: 1;">
                <label style="display: block; font-size: 0.85rem; color: #a1acb8; margin-bottom: 0.3rem;">담당자</label>
                <div id="detailMembers" style="display: flex; flex-wrap: wrap; gap: 5px;"></div>
            </div>
            <div style="flex: 1;">
                <label style="display: block; font-size: 0.85rem; color: #a1acb8; margin-bottom: 0.3rem;">진행 상태</label>
                <div id="detailStts" style="font-weight: 700; color: #696CFF;"></div>
            </div>
        </div>

        <div style="display: flex; gap: 1.5rem; margin-bottom: 1.5rem;">
            <div style="flex: 1;">
                <label style="display: block; font-size: 0.85rem; color: #a1acb8; margin-bottom: 0.3rem;">예상 일감 기간</label>
                <div id="detailDate" style="font-size: 0.9rem; color: #566a7f;"></div>
            </div>
            <div style="flex: 1;">
                <label style="display: block; font-size: 0.85rem; color: #a1acb8; margin-bottom: 0.3rem;">진행률</label>
                <div id="detailProgress" style="font-weight: 700; color: #696CFF;"></div>
            </div>
        </div>

        <div style="display: flex; justify-content: flex-end;">
            <button onclick="document.getElementById('detailModal').style.display='none'" style="padding: 10px 25px; border: none; border-radius: 6px; background: #696CFF; color: white; font-weight: bold; cursor: pointer;">닫기</button>
        </div>
    </div>
</div>
<!-- 💙💙💙💙💙💙칸반에서 상세 일감 보는 모달 끝💙💙💙💙💙💙 -->

<div id="tab-gantt" class="tab-content">
    <jsp:include page="../test/alarmTest.jsp"></jsp:include>
</div>

<script>


    // 간트차트를 위한 전역변수 설정
    window.projBgngDtRaw = "${project.projBgngDt}";
    window.projEndDtRaw = "${project.projEndDt}";

    console.log("면PL님이 간트를 위해 서버에서 받은 원본 시작일:", window.projBgngDtRaw);


    /* 💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕 구성원 💕💕💕💕💕💕💕💕💕💕💕💕💕💕 */
    // 채팅 개설 함수
    function goToCreateChat(empId, empNm) {
        const projectNm = document.getElementById('proj-title-text').innerText || "프로젝트";
        Swal.fire({
            title: '채팅방 연결',
            html: `<b>\${empNm}</b>님과의 채팅방으로 이동하시겠습니까?`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#696CFF',
            cancelButtonColor: '#D5D9DE',
            confirmButtonText: '대화하기',
            cancelButtonText: '취소',
            reverseButtons: true
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('directChatTitle').value = "[" + projectNm + "] " + empNm + "님과의 대화";
                document.getElementById('directTargetId').value = empId;
                document.getElementById('directChatForm').submit();
            }
        });
    }

    let memberChart = null;
    let originalMemberData = [];
    let chartData = [];          // 차트용 데이터
    /* 💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕 */


    //전역변수로 프로젝트 번호가 선택되면 넣어주기...
    const projNo = ${projNo}

    //💙💙💙💙💙💙칸반보드 확인용 임시 프로젝트 번호 305305 넣어둿씁니다
    //const projNo = 305305;

    // 탭 전환 함수..
    function switchTab(event, tabId) {
        document.querySelectorAll('.project-tab-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

        event.currentTarget.classList.add('active');
        document.getElementById(tabId).classList.add('active');

        //칸반보드 탭이 열릴 때만 비동기로 데이터 로드 ==> 각자의 탭에 함수 걸면될거같아염
        if (tabId === 'tab-kanban') {
            loadKanbanData(projNo); //칸반보드 데이터 가져오는 함수 호출
        }
        
     	
        // 구성원 탭
        if (tabId === 'tab-member') {
            Promise.all([
                axios.get('/proMem/title?projNo=' + projNo),
                axios.get('/proMem/members?projNo=' + projNo)
            ])
            .then(([titleRes, memberRes]) => {
                const pTitle = titleRes.data.projTtl;
                const titleTextSpan = document.getElementById('proj-title-text');
                if (titleTextSpan) titleTextSpan.innerText = pTitle;

                originalMemberData = memberRes.data.memberList; // 중요: .memberList 추출
                const chartDataArray = memberRes.data.chartData;

                updateMemberUI(originalMemberData);
                updateChart(chartDataArray || originalMemberData);
            })
            .catch(err => {
                console.error("구성원 데이터 로드 실패:", err);
            });
        }

     	// 4. 일정(스케줄) 탭 처리 💙 (새로 추가된 부분)
	    else if (tabId === 'tab-schedule') {
        if (typeof initScheduleCalendar === 'function') {
            // 캘린더 객체(scheduleCalendar)가 이미 존재한다면?
            if (window.scheduleCalendar) { 
                // 새로 만들지 말고, 사이즈만 재계산해서 깔끔하게 보여줌 (찌그러짐 방지)
                setTimeout(function() {
                    window.scheduleCalendar.updateSize();
                    // 필요하다면 여기서 최신 데이터를 다시 불러오기만 함
                    // loadScheduleData(projNo); 
                }, 100);
            } else {
                // 캘린더가 처음이라면 초기화 함수 호출
                initScheduleCalendar(); 
            }
        }
    }

    }

    /////💙💙💙💙💙💙💙💙💙💙----------- 칸반보드 부분 스크립트 함수 시작 -----------💙💙💙💙💙💙💙💙💙💙/////

    let currentTaskData = []; //일감 전역 변수 선언
    let projTtlKanban = ""; //일단 프로젝트 명 전역변수로 선언해둠..


    // 스프링 시큐리티에서 가져온 객체의 사번(empId)을 자바스크립트 변수에 저장
    const userIdKanban="${userIdTest.empId}" ; //JSTL변수 -> J/S변수
    //const isTeamjang="${userIdTest.empRole}" ; 맨위에 선언함..
    console.log("칸반.. - DOMContentLoaded->userId : ", userIdKanban);
    console.log("칸반.. - isTeamjang : ", isTeamjang);

    //새일감 추가 모달 열기
    function openTaskModal() {
        document.getElementById('taskModal').style.display = 'flex';
    }

    // 새 일감 추가 모달 닫기 + 입력값 초기화 (배경 클릭까지 같이)
    function closeTaskModal(event) {

        // 만약 event(마우스 정보)가 넘어왔다면? (배경 껍데기를 클릭했을 때만 실행됨)
        if (event) {
            const modal = document.getElementById('taskModal');
            // 마우스가 클릭한 곳이 모달창(까만 배경)이 아니라 그 안의 하얀색 입력창이라면?
            if (event.target !== modal) {
                return; // 닫지 말고 그냥 함수 종료
            }
        }

        // 여기까지 무사히 내려왔다면? (취소 버튼을 눌렀거나, 진짜 까만 배경을 찔렀을 때)
        document.getElementById('taskModal').style.display = 'none';

        // 값 지우기(진짜 닫을거임)
        document.getElementById('newTaskTtl').value = '';
        document.getElementById('newTaskCn').value = '';
        document.getElementById('newTaskEndDt').value = '';
        document.getElementById('receiver').innerHTML = '';

    }


    //kb-task-list 안의 내용물이 드래그앤드롭이 가능하게 하는 부분(new Sortable)
    document.querySelectorAll('.kb-task-list').forEach(el => {
        new Sortable(el, {
            group: 'kanban-group', // 그룹이동이 가능하게(없으면 자기 그룹에서만 이동됨)
            animation: 250,
            ghostClass: 'kb-ghost', //옮겨질 부분에 반투명으로 보여지게
            dragClass: 'kb-drag',

            // 슬라이더 만질때에는 카드 드래그 안되게
            filter: '.kb-progress-slider',
            preventOnFilter: false,        // 카드 드래그는 무시하되, 슬라이더 본연의 기능(게이지 조절)은 살려둠

            onEnd: function(event) { //마우스 놓았을때 실행되는 함수
                const itemEl = event.item; // 방금 마우스로 옮긴 카드 HTML 자체
                const taskNo = itemEl.dataset.id; // 일감 번호
                const currentProgress = parseInt(itemEl.dataset.progress, 10); // 현재 진행률

                const newStatus = event.to.parentElement.dataset.status; // 도착한 기둥 상태
                const oldStatus = event.from.parentElement.dataset.status; // 원래 있던 기둥 상태

                // 제자리에서 순서만 바꾼 거면 아무 일도 안 함
                if (newStatus === oldStatus) return;

                // 기존 로직: 도착지가 '완료'인데 진행률이 100이 아닐 때
                if (newStatus === '완료' && currentProgress < 100) {
                    Swal.fire({
                        title: '진행률 업데이트',
                        html: '진행률이 100%가 아닙니다.<br/>진행률도 100%로 함께 변경하시겠습니까?',
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#696CFF',
                        cancelButtonColor: '#d33',
                        confirmButtonText: '예 (100%로 변경)',
                        cancelButtonText: '아니오 (변경 취소)'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            updateTaskStatus(taskNo, newStatus, 100);
                        } else {
                            event.from.appendChild(itemEl);
                        }
                    });
                }
                // 출발지가 '완료'인데 다른 기둥으로 옮길때
                else if (oldStatus === '완료' && newStatus !== '완료') {
                    Swal.fire({
                        title: '상태 변경',
                        html: '완료된 일감을 다른 상태로 이동하면<br>진행률이 <b>99%</b>로 변경됩니다.<br>이동하시겠습니까?',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#696CFF',
                        cancelButtonColor: '#d33',
                        confirmButtonText: '예 (이동 및 99%로 변경)',
                        cancelButtonText: '아니오 (변경 취소)'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            // '예' 누르면 도착지 상태로 바꾸면서 진행률은 강제로 99
                            updateTaskStatus(taskNo, newStatus, 99);
                        } else {
                            // '아니오' 누르면 원래 '완료' 기둥으로
                            event.from.appendChild(itemEl);
                        }
                    });
                }
                // 그 외 평범한 이동일 때 그냥 바꿈
                else {
                    updateTaskStatus(taskNo, newStatus, currentProgress);
                }
            }//드래그앤드롭 함수 끝
        });//기둥생성끝
    }); //드래그앤 드롭 끝

    //드래그앤 드롭으로 바뀐 상태 DB에 업데이트 하는 함수
    function updateTaskStatus(taskNo, taskStts, progress) {
        console.log(`(상태변경) 일감 번호: \${taskNo}, 변경될 상태: \${taskStts}, 변경될 진행률 : \${progress}`);

        const UpdateSttsData = {
            "taskNo" : taskNo,
            "taskStts" : taskStts,
            "taskPrgrt": progress,
            "projNo" : projNo
        }

        //상태 업데이트..
        axios.post("/kanban/updateTaskStts", UpdateSttsData, {
            headers: { "Content-Type": "application/json;utf-8" }
        })
            .then(response => {
                console.log("일감 상태 DB 업데이트 성공");
                loadKanbanData(projNo);
            })
            .catch(error => {
                console.error("DB 업데이트 실패:", error);
                Swal.fire('오류', '상태 변경에 실패했습니다. 화면을 새로고침합니다.', 'error');

                // 실패시.. 카드를 원래 위치로 되돌리기 위해 화면 다시 그리기
                loadKanbanData(projNo);
            });

    }// 상태 업데이트 끝

    // 마우스로 드래그하는 중에 화면에만 보여주기.. (화면의 숫자와 게이지 색상을 실시간으로 변경)
    function updateProgressVisual(slider, taskNo) {
        const newProgress = slider.value;
        // % 텍스트 업데이트
        document.getElementById(`progress-text-\${taskNo}`).innerText = newProgress + '%';
        // 슬라이더 배경색 실시간 변경
        slider.style.background = `linear-gradient(to right, #696CFF \${newProgress}%, #eeeeef \${newProgress}%)`;
        // 데이터 속성 업데이트
        slider.closest('.kb-card').dataset.progress = newProgress;
    }

    // 마우스 드래그 멈췄을때 진행률 업데이트..
    function updateProgressDB(taskNo, taskStts, newProgress) {
        const parsedProgress = parseInt(newProgress, 10);

        console.log(`게이지 진행률 수정 - 일감번호: \${taskNo}, 바꿀 진행률: \${parsedProgress}%`);

        // 현재 상태가 '완료'가 아닌데, 게이지를 100%로 당겼을 때
        if (taskStts !== '완료' && parsedProgress === 100) {
            Swal.fire({
                title: '일감 완료',
                html: '진행률이 100%에 도달했습니다.<br>일감을 완료 상태로 변경하시겠습니까?<br>(완료가 아닌 일감의 진행률은 0~99%까지만 가능합니다.)',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#696CFF',
                cancelButtonColor: '#d33',
                confirmButtonText: '예 (완료로 이동)',
                cancelButtonText: '아니오 (변경 취소)'
            }).then((result) => {
                if (result.isConfirmed) {
                    updateTaskStatus(taskNo, '완료', 100);
                } else {
                    loadKanbanData(projNo);
                }
            });
        }
        // 이미 '완료' 기둥에 있는 카드인데, 게이지(진행률)를 99% 이하로 변경
        else if (taskStts === '완료' && parsedProgress < 100) {
            Swal.fire({
                title: '진행 상태 변경',
                html: '완료된 일감의 진행률을 낮추면<br>상태가 <b>[진행 (IN PROGRESS)]</b> 상태로 자동 변경됩니다.<br>계속하시겠습니까?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ffab00',
                cancelButtonColor: '#d33',
                confirmButtonText: '예 (진행으로 변경)',
                cancelButtonText: '아니오 (변경 취소)'
            }).then((result) => {
                if (result.isConfirmed) {
                    updateTaskStatus(taskNo, '진행', parsedProgress);
                } else {
                    loadKanbanData(projNo);
                }
            });
        }
        // 그 외 평범하게 게이지 조절할 때 그냥 업뎃
        else {
            updateTaskStatus(taskNo, taskStts, parsedProgress);
        }
    }

    //칸반보드 데이터 가져오는 함수 호출
    function loadKanbanData(projNo) {
        console.log(`\${projNo}번 프로젝트의 칸반보드+프로젝트명.. 로딩....`);


        // 프로젝트 명 로딩하기
        axios.get(`/kanban/getProject?projNo=\${projNo}`)
            .then(response => {

                const pName = response.data.projTtl; // 백엔드에서 받아온 이름
                // 칸반보드 메인 화면 타이틀 변경
                document.getElementById('kb-proj-title').innerHTML = `
                    <span class="material-icons" style="font-size: 2rem; margin-right: 10px; color: #696CFF;">fact_check</span>
                    \${pName}
                `;

                // 일감등록 모달창 위에도 프로젝트 명 넣자..
                document.getElementById('modalProjNm').innerText = '[' + pName + ']';
            })
            .catch(error => {
                console.error("프로젝트명 로드 실패:", error);
                document.getElementById('kb-proj-title').innerText = '프로젝트 정보 없음';
                document.getElementById('modalProjNm').innerText = '[정보 없음]';
            });
        //프로젝트명 로딩 끝



        axios.get(`/kanban/tasklist?projNo=\${projNo}`) // 프로젝트 번호에 맞는 일감 목록 조회
            .then(response => {
                currentTaskData = response.data; // 전역변수에 불러온 데이터 넣기..
                renderKanbanBoard(currentTaskData); //불러온데이터 상태 기둥에 넣는 함수 호출
            })
            .catch(error => {
                console.error("데이터 로드 실패:", error);
                Swal.fire('오류', '일감 목록을 불러오지 못했습니다.', 'error');
            });
    }

    // 받아온 데이터를 5개의 기둥(상태)에 맞춰서 화면에 그려주기
    function renderKanbanBoard(taskVOList) {
        // 기존에 남아있던 카드들 삭제 (중복 방지)
        document.getElementById('todo').innerHTML = '';
        document.getElementById('inprogress').innerHTML = '';
        document.getElementById('done').innerHTML = '';
        document.getElementById('hold').innerHTML = '';
        document.getElementById('delay').innerHTML = '';

        // 각 상태별 카드 개수를 셀 변수들
        let counts = { '대기': 0, '진행': 0, '보류': 0, '지연': 0, '완료': 0 };

        // 서버에서 받아온 일감 배열(tasks) 생성(forEach)
        taskVOList.forEach(task => {
            counts[task.taskStts]++; // 해당 상태의 개수 +1

            // 담당자 추가 하기
            let avatarHtml = '';

            //최대 1명까지만 이름 보이게..
            if (task.taskParticipantVOList && task.taskParticipantVOList.length > 0) {
                const maxShow = 1;

                //  최대 1명까지만 담당자 캡슐 생성
                task.taskParticipantVOList.slice(0, maxShow).forEach(p => {
                    avatarHtml += `
                        <div style="display: flex; align-items: center; gap: 4px; background: #f4f7fe; padding: 0 8px; border-radius: 12px; height: 26px;">
                            <span style="font-size: 0.8rem;">👤</span>
                            <span style="font-size: 0.75rem; color: #566a7f; font-weight: 600;">\${p.empNm}</span>
                        </div>`;
                });

                // 2명 이상일 때 +N 처리 (숨겨진 이름 툴팁!)
                if (task.taskParticipantVOList.length > maxShow) {
                    // 화면에 안 보이는 나머지 멤버들 잘라내기
                    const hiddenMembers = task.taskParticipantVOList.slice(maxShow);
                    // 컴마 기준으로 보여주기
                    const hiddenNames = hiddenMembers.map(m => m.empNm).join(', ');
                    const moreCount = hiddenMembers.length; //잘라낸 길이만큼 n

                    // 마우스 커서를 물음표 모양(help)으로 바꾸기(뭔가있음을 알려주기..)
                    avatarHtml += `
                        <div title="\${hiddenNames}" style="display: flex; align-items: center; background:#e7e7ff; color:#696CFF; padding: 0 8px; border-radius: 12px; font-size:0.75rem; font-weight: bold; height: 26px; cursor: help;">
                            +\${moreCount}
                        </div>`;
                }
            } else { //사람없으면 미지정..
                avatarHtml = `
                    <div style="display: flex; align-items: center; height: 26px;">
                        <span style="font-size: 0.75rem; color: #a1acb8;">담당자 미지정</span>
                    </div>`;
            }


            //중요도(높음, 보통, 낮음)
            let imptBorderStyle = '';
            switch(task.taskImpt) {
                case '높음':
                    imptBorderStyle = 'border-left: 5px solid #ff3e1d;'; //높음 빨강
                    break;
                case '보통':
                    imptBorderStyle = 'border-left: 5px solid #3282F6;'; // 보통은 파랑
                    break;
                case '낮음':
                    imptBorderStyle = 'border-left: 5px solid #8592a3;'; // 낮음은 회색..
                    break;
                default:
                    imptBorderStyle = 'border-left: 5px solid #d9dee3;'; // 혹시 값이 없을 때의 기본 테두리,,
            }


            // 내 업무인지 체크..
            let myTaskTag = '<div style="height: 15px;"></div>';
            if (task.taskParticipantVOList && task.taskParticipantVOList.some(p => p.empId == userIdKanban)) {
                myTaskTag = `<div class="my-task-dot">내 업무</div>`;
            }

            // 카드 HTML 조립
            const cardHtml = `
            <div class="kb-card" data-id="\${task.taskNo}" data-progress="\${task.taskPrgrt}" style="\${imptBorderStyle}">

                <div class="kb-card-body" style="display: flex; justify-content: space-between; align-items: flex-start;">

                    <div style="display: flex; flex-direction: column; flex: 1; min-width: 0;">
                        <div class="kb-task-name" style="margin-bottom: 0;">\${task.taskTtl}</div>
                        \${myTaskTag}
                    </div>

                    <button onclick="openDetailModal(\${task.taskNo})" style="border: 1px solid #e4e6ef; background: #f8f9fa; color: #566a7f; border-radius: 4px; padding: 2px 6px; font-size: 0.7rem; font-weight: bold; cursor: pointer; flex-shrink: 0; margin-left: 8px;">
                        상세
                    </button>
                </div>

                <div class="kb-progress-container">
                    <div class="kb-progress-labels">
                        <span class="kb-progress-label-text">Progress</span>
                        <span id="progress-text-\${task.taskNo}" class="kb-progress-percent">\${task.taskPrgrt}%</span>
                    </div>

                    <input type="range" min="0" max="100" value="\${task.taskPrgrt}"
                           class="kb-progress-slider"
                           style="background: linear-gradient(to right, #696CFF \${task.taskPrgrt}%, #eeeeef \${task.taskPrgrt}%);"
                           oninput="updateProgressVisual(this, \${task.taskNo})"
                           onchange="updateProgressDB(\${task.taskNo}, '\${task.taskStts}', this.value)">
                </div>

                <div class="kb-card-footer" style="margin-top: 0.4rem; padding-top: 0.4rem;">
                    <div style="display: flex; gap: 4px; align-items: center; flex: 1; min-width: 0; overflow: hidden; white-space: nowrap;">
                        \${avatarHtml}
                    </div>

                    <div style="font-size: 0.65rem; color: #a1acb8; display: flex; align-items: center; gap: 4px; white-space: nowrap; flex-shrink: 0;">
                        <span style="font-weight: 700; color: #566a7f;">마감일</span>
                        <span>\${task.taskEndDt ? task.taskEndDt.substring(5, 10) : '미정'}</span>
                    </div>
                </div>
            </div>
            `;

            // 일감의 상태(taskStts)에 따라 들어갈 기둥(DOM) 위치 찾기
            let targetListId;
            switch(task.taskStts) {
                case '대기': targetListId = 'todo'; break;
                case '진행': targetListId = 'inprogress'; break;
                case '완료': targetListId = 'done'; break;
                case '보류': targetListId = 'hold'; break;
                case '지연': targetListId = 'delay'; break;

                default: targetListId = 'todo';
            }

            // 찾은 위치의 맨 끝에 만들어둔 카드를 끼워 넣기...
            document.getElementById(targetListId).insertAdjacentHTML('beforeend', cardHtml);
        });// 일감 반복(forEach) 종료

        // 헤더에 있는 '개수 뱃지' 숫자 업데이트
        document.querySelector('.kb-col[data-status="대기"] .badge').innerText = counts['대기'] || 0;
        document.querySelector('.kb-col[data-status="진행"] .badge').innerText = counts['진행'] || 0;
        document.querySelector('.kb-col[data-status="보류"] .badge').innerText = counts['보류'] || 0;
        document.querySelector('.kb-col[data-status="지연"] .badge').innerText = counts['지연'] || 0;
        document.querySelector('.kb-col[data-status="완료"] .badge').innerText = counts['완료'] || 0;
    }

    //일감 생성 저장하기 버튼 눌렀을때....
    function insertNewTask() {
        const taskTtl = document.getElementById('newTaskTtl').value; //일감 제목
        const taskCn = document.getElementById('newTaskCn').value; //일감 내용
        const taskImpt = document.getElementById('newTaskImpt').value; // 중요도
        const bgngDt = document.getElementById('newTaskBgngDt').value; // 예상 시작일
        const endDt = document.getElementById('newTaskEndDt').value;   // 예상 마감(종료)일


        if (!taskTtl.trim()) {
            Swal.fire('알림', '일감 제목을 꼭 입력해주세요!', 'warning');
            return;
        }

        const participantList = []; //담당자 담을 빈 배열
        const mentionSpans = document.querySelectorAll('#receiver .mention-btn');

        //배열에 push!!
        mentionSpans.forEach(span => {
            const empNo = span.getAttribute('data-no'); // 사원번호 추출
            if (empNo) {
                // 백엔드의 TaskVO > taskParticipantVOList 구조에 맞게 객체 형태로 밀어넣기(push)
                participantList.push({ empId: empNo });
            }
        });

        //배열 통째로 넣기..
        const newTaskData = {
            "projNo": projNo,
            "taskTtl": taskTtl,
            "taskCn": taskCn,
            "taskImpt": taskImpt,
            "taskBgngDt": bgngDt,
            "taskEndDt": endDt,
            "taskStts": '대기',
            "taskPrgrt": 0,
            "taskParticipantVOList": participantList
        };

        axios.post('/kanban/insertTask', newTaskData)
            .then(response => {
                Swal.fire('성공', '새 일감이 추가되었습니다!', 'success');
                closeTaskModal();
                loadKanbanData(projNo);
            })
            .catch(error => {
                console.error("일감 추가 실패:", error);
                Swal.fire('오류', '일감 추가에 실패했습니다.', 'error');
            });
    }//일감 생성 끝


//DOM..시작
document.addEventListener("DOMContentLoaded", function(){

    //멘션 기능 (수신자)
    const tribute = new Tribute({
        trigger: '@',
        lookup: (item) => item.empId + "("+item.empNm+")",  // 검색할 필드
        fillAttr: (item) => item.empId + "("+item.empNm+")", // 선택 시 입력창에 들어갈 기본값
        requireAnyChar: true,
        values: function (text, cb) { //프로젝트 참여자만 조회
            fetch(`/kanban/search?query=\${text}&projNo=\${projNo}`)
                .then(res => res.json())
                .then(data => {
                    // 받는 사람(#receiver)과 참조자(#cC) 영역에서 이미 선택된 사원번호들 수집
                    const selectedInReceiver = Array.from(document.querySelectorAll('#receiver .mention-btn'))
                        .map(span => span.getAttribute('data-no'));

                    // 서버에서 가져온 데이터(data) 중 이미 선택된 ID를 제외한 나머지만 리스트에 표시
                    const filteredData = data.filter(item => !selectedInReceiver.includes(String(item.empId)));

                    cb(filteredData);
                }) // 여기서 오는 데이터가 {empId: '...', empNm: '...'} 형태여야 함
                .catch(err => cb([]));
        },
        selectTemplate: function (item) {
            if (typeof item === 'undefined') return null;
            return '<span class="mention-btn" data-no="' + item.original.empId + '" contenteditable="false">'
                + '@' + item.original.empNm
                + '<a class="del-mention">X</a>' // x 버튼 추가
                + '</span>&nbsp; <input type=hidden name="emlRcvrId" value="'+item.original.empId+'">';
        },
        // 검색 결과가 없을 때 보여줄 템플릿 (디버깅용)
        noMatchTemplate: function () {
            return '<li>결과가 없습니다</li>';
        }
    });
    tribute.attach(document.getElementById('receiver'));

    //멘션 x(삭제)
    document.getElementById('receiver').addEventListener('click', function(e) {
        // 클릭된 요소가 삭제 버튼(x)인지 확인
        if (e.target && e.target.classList.contains('del-mention')) {
            // 부모 요소인 .mention-btn을 찾아서 삭제
            const mentionBtn = e.target.closest('.mention-btn');
            if (mentionBtn) {
                mentionBtn.remove();
            }
        }
    });
})//DOM 끝..

    // 일감 상세 모달 열기
    function openDetailModal(taskNo) {
        // 현재 화면에 로드된 taskVOList에서 데이터를 찾기..
        // (단, taskVOList가 전역 변수로 관리되어야 합니다. loadKanbanData 함수를 확인해주세요!)
        const task = currentTaskData.find(t => t.taskNo == taskNo);

        if(!task) return;

        // 2. 모달에 데이터 채우기
        document.getElementById('detailTtl').innerText = task.taskTtl;
        document.getElementById('detailCn').innerText = task.taskCn || '내용이 없습니다.';
        document.getElementById('detailStts').innerText = task.taskStts;
        document.getElementById('detailProgress').innerText = task.taskPrgrt + '%';
        document.getElementById('detailDate').innerText = ` \${task.taskBgngDt?.substring(0,10)} ~ \${task.taskEndDt?.substring(0,10)}`;

        // 중요도 배지 색상 처리
        const imptBadge = document.getElementById('detailImptBadge');
        imptBadge.innerText = task.taskImpt;
        imptBadge.className = 'kb-badge ' + (task.taskImpt === '높음' ? 'badge-delay' : (task.taskImpt === '보통' ? 'badge-progress' : 'bg-secondary text-white'));

        // 담당자 목록 뿌리기
        const memberDiv = document.getElementById('detailMembers');
        memberDiv.innerHTML = '';
        if(task.taskParticipantVOList && task.taskParticipantVOList.length > 0) {
            task.taskParticipantVOList.forEach(m => {
                memberDiv.innerHTML += `<span style="background:#f4f7fe; padding:2px 8px; border-radius:10px; font-size:0.8rem;">👤 \${m.empNm}</span>`;
            });
        } else {
            memberDiv.innerHTML = '<span style="color:#a1acb8; font-size:0.8rem;">미지정</span>';
        }

        // 3. 모달 보여주기
        document.getElementById('detailModal').style.display = 'flex';
    }

    // 모달 배경 클릭 시 닫기
    function closeDetailModal(event) {
        if (event.target === document.getElementById('detailModal')) {
            document.getElementById('detailModal').style.display = 'none';
        }
    }



    // 도움말 튜토리얼 실행 함수
    function startKanbanTutorial() {
        const driver = window.driver.js.driver;
        const driverObj = driver({
            showProgress: true, // 상단에 1/4 진행률 표시
            doneBtnText: '시작하기',
            nextBtnText: '다음 &rarr;',
            prevBtnText: '&larr; 이전',
            allowClose: true, // 바탕화면 누르면 꺼지게 할건지 여부

            steps: [
                {
                    element: '#kb-proj-title',
                    popover: {
                        title: '1. 현재 프로젝트',
                        description: '현재 작업 중인 프로젝트의 이름입니다.',
                        side: "bottom", align: 'start'
                    }
                },
                {
                    element: '#tutorial-add-btn',
                    popover: {
                        title: '2. 일감 등록',
                        description: '이 버튼을 눌러 새로운 업무를 등록하고 담당자를 배정하세요.',
                        side: "bottom", align: 'end'
                    }
                },
                {
                    element: '.kb-board-wrapper',
                    popover: {
                        title: '3. 칸반보드 드래그 앤 드롭',
                        description: '등록된 일감 카드를 마우스로 꾹 눌러 다른 기둥(상태)으로 자유롭게 이동시킬 수 있습니다!',
                        side: "top", align: 'center'
                    }
                },
                {
                    element: '.kb-card:first-child', // 첫 번째 일감 카드 가리키기
                    popover: {
                        title: '4. 일감 상세 및 진행률',
                        description: '카드의 [상세] 버튼을 누르거나, 아래쪽 게이지 바를 밀어서 진행률(%)을 조절해 보세요.',
                        side: "right", align: 'center'
                    }
                }
            ]
        });

        // 튜토리얼 시작~!
        driverObj.drive();
    }
    /////💙💙💙💙💙💙💙💙💙💙----------- 칸반보드 부분 스크립트 함수 끝 -----------💙💙💙💙💙💙💙💙💙💙/////


    /* 💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕 구성원 💕💕💕💕💕💕💕💕💕💕💕💕💕💕 */
    function loadMemberData(projNo) {
        axios.get('/proMem/members?projNo=' + projNo)
            .then(res => {
                originalMemberData = res.data.memberList;
                chartData = res.data.chartData;
                // 목록
                updateMemberUI(originalMemberData);
                // 차트
                updateChart(chartData);
            })
            .catch(err => console.error("데이터 로드 에러:", err));
    }

    function updateMemberUI(data) {
        const tbody = document.getElementById('memberTableBody');
        const memberCountSpan = document.getElementById('m-member-count');

        if (!tbody) return;

        const list = Array.isArray(data) ? data : (data.memberList || []);

        // 인원수 갱신
        if (memberCountSpan) memberCountSpan.innerText = data.length;

        // 목록 테이블 갱신
        tbody.innerHTML = "";
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:50px; color:#999;">검색 결과가 없습니다.</td></tr>';
        } else {
            data.forEach((member, index) => {
                const row = `
            <tr>
                <td>\${index + 1}</td>
                <td style="font-weight: 700; color: #333;">\${member.prtpntNm}</td>
                <td>\${member.deptNm}</td>
                <td>\${member.jbgdNm || '미지정'}</td>
                <td><b style="color:#696CFF">\${member.totalTasks || 0}</b> 건</td>
                <td>
                    <button class="m-btn-chat" onclick="goToCreateChat('\${member.empId}', '\${member.prtpntNm}')">
                        <span class="material-icons" style="font-size: 18px;">chat_bubble_outline</span>
                    </button>
                </td>
            </tr>`;
                tbody.insertAdjacentHTML('beforeend', row);
            });
        }

        // 차트 갱신 호출
        updateChart(data);
    }

    /* 검색 */
    function performSearch() {
        const keyword = document.getElementById('m-search-input').value.toLowerCase().trim();

        // 원본 데이터(originalMemberData)에서 필터링
        const filteredData = originalMemberData.filter(item => {
            const name = (item.prtpntNm || "").toLowerCase();
            const dept = (item.deptNm || "").toLowerCase();
            return name.includes(keyword) || dept.includes(keyword);
        });

        // 필터링된 결과로 UI 업데이트
        updateMemberUI(filteredData);
    }


    function updateChart(data) {
        const canvas = document.getElementById('memberHorizontalChart');
        if (!canvas) return;

        const ctx = canvas.getContext('2d');

        if (memberChart) memberChart.destroy();
        if (data.length === 0) return;

        memberChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(item => item.prtpntNm),
                datasets: [
                    {
                        label: '높음',
                        data: data.map(item => item.imptHigh),
                        backgroundColor: '#FF6A55',
                        stack: 'totalGroup', // 중요도끼리만 합침
                        barThickness: 15
                    },
                    {
                        label: '보통',
                        data: data.map(item => item.imptNormal),
                        backgroundColor: '#82B5FF',
                        stack: 'totalGroup', // 중요도끼리만 합침
                        barThickness: 15
                    },
                    {
                        label: '낮음',
                        data: data.map(item => item.imptLow),
                        backgroundColor: '#D5D9DE',
                        stack: 'totalGroup', // 중요도끼리만 합침
                        barThickness: 15
                    },

                    {
                        label: '진행중',
                        data: data.map(item => item.progTasks),
                        backgroundColor: '#A8AAFF',
                        stack: 'progGroup',
                        barThickness: 15
                    },
                    {
                        label: '완료',
                        data: data.map(item => item.compTasks),
                        backgroundColor: '#A5E086',
                        stack: 'compGroup',
                        barThickness: 15
                    },
                    {
                        label: '대기',
                        data: data.map(item => item.waitTasks),
                        backgroundColor: '#E2E5E9',
                        stack: 'waitGroup',
                        barThickness: 15
                    }
                ]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                // 호버 정확도를 위한 설정
                interaction: {
                    mode: 'index',
                    axis: 'y',
                    intersect: false
                },
                scales: {
                    x: {
                        stacked: true, // ★ 가로축 데이터를 쌓아서 합침 (중요!)
                        beginAtZero: true
                    },
                    y: {
                        stacked: true, // ★ 세로축 항목 내에서 데이터셋을 쌓음 (중요!)
                        grid: { display: false },
                        ticks: { font: { size: 12, weight: '700' } }
                    }
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(255, 255, 255, 0.9)',
                        titleColor: '#333',
                        bodyColor: '#666',
                        borderColor: '#ddd',
                        borderWidth: 1,
                        callbacks: {
                            label: function(context) {
                                if (context.parsed.x === 0) return null;
                                return context.dataset.label + ': ' + context.parsed.x + '건';
                            }
                        }
                    },
                    datalabels: { display: false }
                }
            },
            plugins: [ChartDataLabels]
        });
    }

    document.addEventListener('DOMContentLoaded', function() {
        const btnSearch = document.getElementById('m-btn-search');
        const btnReset = document.getElementById('m-btn-reset');
        const searchInput = document.getElementById('m-search-input');

        if(btnSearch) btnSearch.addEventListener('click', performSearch);

        if(searchInput) {
            searchInput.addEventListener('keyup', (e) => {
                if (e.key === 'Enter') performSearch();
            });
        }

        if(btnReset) {
            btnReset.addEventListener('click', function() {
                if(searchInput) searchInput.value = "";
                updateMemberUI(originalMemberData);
            });
        }
    });


    // [튜토리얼]
    function startMemberTutorial() {
        const driver = window.driver.js.driver;
        const driverObj = driver({
            showProgress: true,
            doneBtnText: '확인완료',
            nextBtnText: '다음 &rarr;',
            prevBtnText: '&larr; 이전',
            allowClose: true,
            steps: [
                {
                    element: '.m-left-chart',
                    popover: {
                        title: '📊 업무 통계 차트',
                        description: '구성원별 <b>업무 중요도(높음/보통/낮음)</b>와 진행 상태를 한눈에 비교할 수 있습니다. 붉은색 막대로 강조된 고순위 업무를 확인하세요!',
                        side: "right", align: 'start'
                    }
                },
                {
                    element: '.m-filter-row',
                    popover: {
                        title: '🔍 구성원 검색',
                        description: '이름이나 부서명을 입력하여 특정 팀원을 빠르게 찾을 수 있습니다.',
                        side: "bottom", align: 'start'
                    }
                },
                {
                    element: '.m-table',
                    popover: {
                        title: '📋 구성원 상세 목록',
                        description: '참여 중인 모든 팀원의 정보와 현재 담당하고 있는 업무 건수를 확인하세요.',
                        side: "top", align: 'center'
                    }
                },
                {
                    element: '.m-btn-chat:first-of-type',
                    popover: {
                        title: '💬 1:1 채팅하기',
                        description: '협업이 필요한 팀원에게 즉시 채팅을 요청하여 실시간으로 소통할 수 있습니다.',
                        side: "left", align: 'center'
                    }
                }
            ]
        });

        driverObj.drive();
    }

    /* 💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕💕 */


</script>