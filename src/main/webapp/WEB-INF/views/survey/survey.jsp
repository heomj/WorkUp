<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="/js/common-alert.js"></script>

<style>
    .survey-container { font-family: 'Pretendard', sans-serif; padding: 30px; min-height: 100vh; }
    .tab-nav-wrapper { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
    .tab-nav { display: flex; background: #fff; padding: 6px; border-radius: 12px; border: 1px solid #e2e8f0; width: fit-content; }
    .tab-item { padding: 10px 24px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; border: none; background: none; color: #64748b; transition: 0.3s; }
    .tab-item.active { background: #696cff; color: #fff; box-shadow: 0 4px 10px rgba(37, 99, 235, 0.2); }

    .survey-grid { display: none; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 30px; animation: fadeIn 0.4s ease; }
    .survey-grid.active { display: grid; }

    .survey-card { background: white; padding: 30px; border-radius: 24px; border: 1px solid #f1f5f9; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03); transition: all 0.3s ease; display: flex; flex-direction: column; justify-content: space-between; position: relative;}
    .survey-card:hover { transform: translateY(-8px); box-shadow: 0 15px 30px rgba(0, 0, 0, 0.08); border-color: #dbeafe; }

    .status-badge { background: #eff6ff; color: #696cff; padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; text-transform: uppercase; }
    .anon-badge { background: #f1f5f9; color: #64748b; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; margin-left: 8px;}

    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

/* 기본 참여하기 버튼 스타일 */
.survey-card button[onclick^="goParticipate"] {
    flex: 2;
    padding: 14px;
    background: #1e293b;
    color: white;
    border: none;
    border-radius: 12px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.survey-card button[onclick^="goParticipate"]:hover {
    background: #334155;
    transform: translateY(-3px);
    box-shadow: 0 10px 15px -3px rgba(30, 41, 59, 0.3);
}

.survey-card button[onclick^="goParticipate"]:active {
    transform: translateY(-1px);
    box-shadow: 0 5px 10px -2px rgba(30, 41, 59, 0.2);
}

.survey-card button[onclick^="viewStats"]:hover {
    background: #f8fafc !important;
    border-color: #cbd5e1 !important;
    color: #1e293b !important;
    transform: translateY(-2px);
}

/* 설문 모달 창 디자인 고도화 */
    .modal-overlay {
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(15, 23, 42, 0.6); z-index: 1000; backdrop-filter: blur(8px);
        justify-content: center; align-items: center;
    }
    .modal-content {
        background: #ffffff; width: 95%; max-width: 720px; max-height: 85vh;
        border-radius: 32px; overflow: hidden; position: relative;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.3); animation: modalUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        display: flex; flex-direction: column;
    }
    @keyframes modalUp { from { opacity: 0; transform: translateY(40px) scale(0.95); } to { opacity: 1; transform: translateY(0) scale(1); } }

    .modal-header {
        padding: 32px 40px; background: #fff; border-bottom: 1px solid #f1f5f9;
        position: relative; z-index: 10;
    }


    /* --- 설문 모달 창 디자인 고도화 (애플 스타일) --- */
    .modal-overlay {
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0, 0, 0, 0.4); z-index: 1000; backdrop-filter: blur(12px); /* 더 깊은 블러 효과 */
        justify-content: center; align-items: center;
    }

    .modal-content {
        background: #ffffff; width: 90%; max-width: 850px; height: 90vh; /* 높이를 키워 시원하게 */
        border-radius: 40px; overflow: hidden; position: relative;
        box-shadow: 0 40px 100px -20px rgba(0, 0, 0, 0.25);
        animation: modalSlideUp 0.5s cubic-bezier(0.16, 1, 0.3, 1);
        display: flex; flex-direction: column; border: 1px solid rgba(255,255,255,0.7);
    }

    @keyframes modalSlideUp {
        from { opacity: 0; transform: translateY(60px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .modal-header {
        padding: 40px 50px 20px; background: #fff;
        position: relative; z-index: 10;
    }

    #modalTitle {
        font-size: 28px; font-weight: 800; color: #111827;
        letter-spacing: -0.5px; line-height: 1.3;
    }

    .close-modal-btn {
        position: absolute; top: 40px; right: 40px; width: 44px; height: 44px;
        border: none; border-radius: 20%; color: #ffffff; font-size: 20px;
        cursor: pointer; display: flex; align-items: center; background-color:black;
        justify-content: center; transition: all 0.2s;
    }
    .close-modal-btn:hover { box-shadow: 0 15px 30px rgba(0, 0, 0, 0.08); transform: translateY(-4px); }
    .close-modal-btn:active { transform: scale(0.85); }

    .modal-body {
        padding: 20px 50px 40px; overflow-y: auto; background: #fff;
    }

    /* 질문 카드 스타일 */
    .question-card {
        background: #f9fafb;
        padding: 32px 40px;
        border-radius: 32px;
        margin-bottom: 24px;
        border: 1px solid #f1f5f9;
    }

    .q-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 24px;
    }

    .q-num {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: #111827;
        color: #fff;
        min-width: 26px; /* 고정 너비 */
        height: 26px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 700;
        flex-shrink: 0; /* 번호 크기 유지 */
    }

    .q-title {
        font-size: 20px;
        font-weight: 700;
        color: #111827;
        line-height: 1.4;
        margin: 0; /* 기존 마진 제거 */
    }

    /* 선택지 */
    .opt-label {
        display: flex; align-items: center; padding: 18px 24px; border: 2px solid #fff;
        border-radius: 20px; margin-bottom: 12px; cursor: pointer; transition: all 0.2s ease;
        background: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.02);
    }
    .opt-label:hover { border-color: #e2e8f0; transform: translateX(5px); }

    .opt-label:has(input:checked) {
        background: #fff;
        border-color: #696cff;
        box-shadow: 0 10px 20px -5px rgba(37, 99, 235, 0.15);
    }

    .opt-label input[type="radio"] {
        width: 22px; height: 22px; margin-right: 18px; accent-color: #696cff;
    }

    .q-textarea {
        width: 100%; border: 2px solid #fff; border-radius: 20px; padding: 24px;
        min-height: 150px; font-size: 16px; background: #fff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.02); transition: all 0.3s;
    }
    .q-textarea:focus { border-color: #696cff; outline: none; box-shadow: 0 10px 20px -5px rgba(37, 99, 235, 0.1); }

    .modal-footer {
        padding: 30px 50px 50px; background: #fff;
    }

    .submit-btn {
        width: 100%; padding: 20px; background: #111827; color: white; border: none;
        border-radius: 24px; font-weight: 700; font-size: 18px; cursor: pointer;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .submit-btn:hover { background: #1f2937; transform: translateY(-4px); box-shadow: 0 20px 30px -10px rgba(0, 0, 0, 0.2); }
    .submit-btn:active { transform: translateY(-1px); }

    /* 설문 설명(srvyTtl) 스타일 */
    .modal-description {
        font-size: 14px;
        color: #64748b;
        line-height: 1.6;
        margin-top: 12px;
        font-weight: 400;
        max-width: 85%;
        word-break: keep-all;
        white-space: pre-wrap;
    }



    /* 통계 */
    .stats-container {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .stats-item {
        background: #fff;
        padding: 16px 20px;
        border-radius: 18px;
        border: 1px solid #f1f5f9;
    }

    .stats-info {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
        font-size: 14px;
        font-weight: 600;
    }

    .stats-label { color: #475569; }
    .stats-pct { color: #696cff; font-size: 16px; font-weight: 800; }

    /* 프로그레스 바 배경 */
    .progress-bar-bg {
        width: 100%;
        height: 10px;
        background: #f1f5f9;
        border-radius: 10px;
        overflow: hidden;
    }

    /* 실제 진행도 바 (애니메이션 포함) */
    .progress-bar-fill {
        height: 100%;
        background: linear-gradient(90deg, #696cff, #60a5fa);
        border-radius: 10px;
        width: 0%; /* 초기값 */
        transition: width 1s cubic-bezier(0.34, 1.56, 0.64, 1); /* 튕기는 듯한 부드러운 애니메이션 */
    }

    .stats-count {
        font-size: 12px;
        color: #94a3b8;
        margin-top: 6px;
        text-align: right;
    }

    /* 주관식 답변 리스트 스타일 */
    .essay-answer-list {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    .essay-item {
        padding: 12px 16px;
        background: #fff;
        border-left: 4px solid #e2e8f0;
        border-radius: 8px;
        font-size: 14px;
        color: #475569;
        line-height: 1.5;
    }
</style>

<div class="survey-container">
    <div class="d-flex justify-content-between align-items-center mb-4" style="margin-top:-30px; margin-left:-30px;">
        <div>
            <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                <span class="material-icons" style="color: #696cff; font-size: 32px;">poll</span>
                <div style="display: flex; align-items: baseline; gap: 8px;">
                    <span style="font-size: x-large; font-weight: 800;">설문</span>
                </div>
            </div>
            <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                현재 참여 가능한 설문 및 종료된 투표 현황을 확인할 수 있는 페이지입니다.
            </div>
        </div>
    </div>

    <!-- 탭 -->
    <div class="tab-nav-wrapper">
        <div class="tab-nav">
            <button id="tab-new" class="tab-item active" onclick="showTab('new')">설문</button>
            <button id="tab-mine" class="tab-item" onclick="showTab('mine')">참여한 설문</button>
            <button id="tab-closed" class="tab-item" onclick="showTab('closed')">종료된 설문</button>
        </div>
    </div>

    <!-- 새로운 설문 -->
    <div id="view-new" class="survey-grid active">
        <c:choose>
            <c:when test="${not empty newList}">
                <c:forEach items="${newList}" var="vo">
                    <div class="survey-card">
                        <!--
                        <div style="display: flex; justify-content: flex-end; width: 100%;">
                            <div style="display: inline-flex; align-items: center; gap: 4px; background: #fff9db; margin-bottom: 10px; padding: 4px 10px; border-radius: 8px; border: 1px solid #ffec99;">
                                <span class="material-icons" style="font-size: 16px; color: #fcc419;">monetization_on</span>
                                <span style="font-size: 13px; font-weight: 700; color: #927b1b;">${vo.srvyMlg} P</span>
                            </div>
                        </div>
                        -->
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                            <div>
                                <span class="status-badge">In Progress</span>
                                <c:if test="${vo.srvyAnon eq 'Y'}"><span class="anon-badge">익명</span></c:if>
                            </div>
                            <!--
                            <span style="font-size: 12px; color: #696cff; font-weight: 700;">진행 중</span>
                            -->
                            <div style="display: flex; align-items: center; gap: 4px; background: rgba(255, 193, 7, 0.1); padding: 4px 10px; border-radius: 6px; width: fit-content; margin-bottom: 12px;">
                                <span class="material-icons" style="font-size: 14px; color: #ffc107;">monetization_on</span>
                                <span style="font-size: 13px; font-weight: 700; color: #856404;">${vo.srvyMlg} P</span>
                            </div>
                        </div>
                        <!--
                        <div style="display: flex; align-items: center; gap: 4px; background: rgba(255, 193, 7, 0.1); padding: 4px 10px; border-radius: 6px; width: fit-content; margin-bottom: 12px;">
                            <span class="material-icons" style="font-size: 14px; color: #ffc107;">monetization_on</span>
                            <span style="font-size: 13px; font-weight: 700; color: #856404;">${vo.srvyMlg} P</span>
                        </div>
                        -->
                        <h3 style="font-size: 20px; font-weight: 800; margin: 0 0 12px 0;">${vo.srvyCn}</h3>
                        <p style="font-size: 14px; color: #6c757d; line-height: 1.5; margin-bottom: 20px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                ${vo.srvyTtl}
                        </p>
                        <div style="font-size: 12px; color: #94a3b8; margin-bottom: 24px;">
                            <div>📅 기간: <fmt:formatDate value="${vo.srvyBgngDt}" pattern="yyyy.MM.dd"/> ~ <fmt:formatDate value="${vo.srvyEndDt}" pattern="yyyy.MM.dd"/></div>
                        </div>
                        <div style="display: flex; gap: 10px;">
                            <button onclick="goParticipate(${vo.srvyNo})" style="flex: 2; padding: 14px; background: #1e293b; color: white; border: none; border-radius: 12px; font-weight: 700; cursor: pointer;">참여하기</button>
                            <button onclick="viewStats(${vo.srvyNo})" style="flex: 1; padding: 14px; background: white; border: 1px solid #e2e8f0; border-radius: 12px; color: #64748b; cursor: pointer;">📊 통계</button>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="text-center p-5" style="grid-column: 1/-1; color: #94a3b8;">참여 가능한 설문이 없습니다.</div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- 참여한 설문 -->
    <div id="view-mine" class="survey-grid">
        <c:choose>
            <c:when test="${not empty mineList}">
                <c:forEach items="${mineList}" var="vo">
                    <div class="survey-card">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 20px;">
                            <span class="status-badge" style="background:#eff6ff; color: #696cff;">참여 완료</span>
                            <div style="display: flex; align-items: center; gap: 4px; background: rgba(255, 193, 7, 0.1); padding: 4px 10px; border-radius: 6px; width: fit-content;">
                                <span class="material-icons" style="font-size: 14px; color: #ffc107;">monetization_on</span>
                                <span style="font-size: 13px; font-weight: 700; color: #856404;">${vo.srvyMlg} P</span>
                            </div>
                        </div>
                        <h3 style="font-size: 20px; font-weight: 800; margin: 0 0 12px 0;">${vo.srvyCn}</h3>
                        <span style="font-size: 12px; color: #94a3b8; margin-bottom:10px">참여일: <fmt:formatDate value="${vo.srvyDt}" pattern="yyyy.MM.dd"/></span>
                        <p style="font-size: 14px; color: #64748b; line-height: 1.6; margin-bottom: 24px;">이미 참여하신 설문입니다. 실시간 결과를 확인해 보세요.</p>
                        <button onclick="viewStats(${vo.srvyNo})" style="width: 100%; padding: 14px; background: #f1f5f9; border: none; color: #1e293b; border-radius: 12px; font-weight: 700; cursor: pointer;">결과 보기</button>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="text-center p-5" style="grid-column: 1/-1; color: #94a3b8;">아직 참여한 설문이 없습니다.</div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- 종료된 설문 -->
    <div id="view-closed" class="survey-grid">
        <c:choose>
            <c:when test="${not empty closedList}">
                <c:forEach items="${closedList}" var="vo">
                    <div class="survey-card" style="background: #fafafa; opacity: 0.85;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                            <div>
                                <span class="status-badge" style="background: #e2e8f0; color: #64748b;">Closed</span>
                                <c:if test="${vo.srvyAnon eq 'Y'}"><span class="anon-badge">익명</span></c:if>
                            </div>
                            <!--
                            <span style="font-size: 12px; color: #64748b; font-weight: 700;">마감됨</span>
                            -->
                            <div style="display: flex; align-items: center; gap: 4px; background: #f1f5f9; padding: 4px 10px; border-radius: 6px; width: fit-content; margin-bottom: 12px; border: 1px solid #e2e8f0;">
                                <span class="material-icons" style="font-size: 14px; color: #94a3b8;">monetization_on</span>
                                <span style="font-size: 13px; font-weight: 700; color: #64748b;">${vo.srvyMlg} P</span>
                            </div>
                        </div>
                        <h3 style="font-size: 20px; font-weight: 800; margin: 0 0 12px 0; color: #475569;">${vo.srvyCn}</h3>
                        <div style="font-size: 12px; color: #94a3b8; margin-bottom: 24px;">
                            <div>📅 기간: <fmt:formatDate value="${vo.srvyBgngDt}" pattern="yyyy.MM.dd"/> ~ <fmt:formatDate value="${vo.srvyEndDt}" pattern="yyyy.MM.dd"/></div>
                            <div style="margin-top: 6px;">👥 최종 참여 인원: ${vo.srvyNope}명</div>
                        </div>
                        <button onclick="viewStats(${vo.srvyNo})" style="width: 100%; padding: 14px; background: white; border: 1px solid #696cff; color: #696cff; border-radius: 12px; font-weight: 700; cursor: pointer;">
                            📊 최종 결과 확인하기
                        </button>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="text-center p-5" style="grid-column: 1/-1; color: #94a3b8;">종료된 설문이 없습니다.</div>
            </c:otherwise>
        </c:choose>
    </div>
</div>


<!-- 설문 참여 모달 -->
<div id="surveyModal" class="modal-overlay" onclick="closeModal(event)">
    <div class="modal-content" onclick="event.stopPropagation()">
        <div class="modal-header" style="display: flex; flex-direction: column; align-items: flex-start; gap: 10px;">
            <span id="modalAnonBadge" class="anon-badge" style="margin-left:0; display:none;">익명</span>
            <h2 id="modalTitle" style="font-size: 28px; font-weight: 800; color: #111827; margin: 0; line-height: 1.3; width: 100%;"></h2>
            <div id="modalDescription" class="modal-description" style="max-width: 80%; margin-top: 5px;"></div>
            <button class="close-modal-btn" onclick="closeModal()">&times;</button>
        </div>

        <form id="surveyForm" style="display: flex; flex-direction: column; overflow: hidden;">
            <input type="hidden" name="srvyNo" id="modalSrvyNo">
            <div class="modal-body" id="modalQuestionList">
                <!-- 질문 리스트가 Ajax로 여기에 생성됨 -->
            </div>

            <div class="modal-footer">
                <button type="button" onclick="submitSurvey()" class="submit-btn">
                    설문 응답 제출하기
                </button>
            </div>
        </form>
    </div>
</div>


<!-- 통계 확인 모달 -->
<div id="statsModal" class="modal-overlay" onclick="closeStatsModal(event)">
    <div class="modal-content" onclick="event.stopPropagation()">
        <div class="modal-header">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div id="statsTotalBadge" class="status-badge" style="margin-bottom:0;">총 0명 참여</div>
                <h2 id="statsTitle" style="font-size: 26px; font-weight: 800; color: #111827; margin: 0;">설문 결과 통계</h2>
            </div>
            <button class="close-modal-btn" onclick="closeStatsModal()">&times;</button>
        </div>

        <div class="modal-body" id="statsList">
            <!-- 통계 내용이 Ajax로 생성됨 -->
        </div>

        <div class="modal-footer">
            <button type="button" onclick="closeStatsModal()" class="submit-btn">
                닫기
            </button>
        </div>
    </div>
</div>

<!-- 주관식 전체 답변 상세 모달 -->
<div id="essayDetailModal" class="modal-overlay" style="z-index: 1100;" onclick="closeEssayModal()">
    <div class="modal-content" style="max-width: 500px; height: 70vh;" onclick="event.stopPropagation()">
        <div class="modal-header">
            <h3 style="font-size: 20px; font-weight: 800; margin: 0;">전체 주관식 답변</h3>
            <button class="close-modal-btn" onclick="closeEssayModal()">&times;</button>
        </div>
        <div class="modal-body" id="essayDetailList">
            <!-- 모든 답변이 여기에 들어감 -->
        </div>
        <div class="modal-footer">
            <button type="button" onclick="closeEssayModal()" class="submit-btn">닫기</button>
        </div>
    </div>
</div>



<script>
    // [Alert] -------------------------------------------------------------------------
    window.showAlert = function(title, icon) {
        const iconMap = {
            'success': 'check_circle',
            'error': 'error_outline',
            'warning': 'warning_amber',
            'info': 'info'
        };
        const materialIcon = iconMap[icon] || 'notifications';

        if (icon === 'success') {
            AppAlert.success(title, '', null, materialIcon); // (알람 리팩토링)
        } else if (icon === 'error') {
            AppAlert.error(title, '', null, materialIcon);
        } else if (icon === 'warning') {
            AppAlert.warning(title, '', null, materialIcon);
        } else {
            AppAlert.info(title, '', null, materialIcon);
        }
    };



    window.addEventListener('DOMContentLoaded', (event) => {
        const urlParams = new URLSearchParams(window.location.search);
        const tab = urlParams.get('tab');
        if (tab && document.getElementById('tab-' + tab)) {
            showTab(tab, false);
        }
    });

    function showTab(tabName, shouldPushState = true) {
        document.querySelectorAll('.survey-grid').forEach(view => view.classList.remove('active'));
        document.querySelectorAll('.tab-item').forEach(tab => tab.classList.remove('active'));

        const targetView = document.getElementById('view-' + tabName);
        const targetTab = document.getElementById('tab-' + tabName);

        if (targetView && targetTab) {
            targetView.classList.add('active');
            targetTab.classList.add('active');
            if (shouldPushState) {
                const newUrl = window.location.protocol + "//" + window.location.host + window.location.pathname + '?tab=' + tabName;
                window.history.pushState({ path: newUrl }, '', newUrl);
            }
        }
    }

    function viewStats(srvyNo) {
        location.href = "/survey/stats?srvyNo=" + srvyNo;
    }

    function goParticipate(srvyNo) {
        fetch(`/survey/detail?srvyNo=\${srvyNo}`)
            .then(response => response.json())
            .then(data => {
                renderSurvey(data);

                // 모달을 표시하기 전/후에 스크롤을 최상단으로 강제 이동
                const modal = document.getElementById('surveyModal');
                if (modal) {
                    modal.style.display = 'flex';
                    document.body.style.overflow = 'hidden';

                    // 스크롤 초기화
                    setTimeout(() => {
                        const modalBody = modal.querySelector('.modal-body');
                        if (modalBody) modalBody.scrollTop = 0;
                    }, 10);
                }
            })
            .catch(err => AppAlert.error('데이터 로드 실패', '설문 데이터를 불러오는데 실패했습니다.', null, 'cloud_off')); // (알람 리팩토링)
    }

    function closeModal(e) {
        document.getElementById('surveyModal').style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    // [설문 참여] ------------------------------------------------------------------------
    function renderSurvey(data) {
        const modalTitle = document.getElementById('modalTitle');
        const modalSrvyNo = document.getElementById('modalSrvyNo');
        const modalAnonBadge = document.getElementById('modalAnonBadge');
        const listContainer = document.getElementById('modalQuestionList');
        const modalDescription = document.getElementById('modalDescription');

        modalTitle.innerText = data.srvyCn;
        modalDescription.innerText = data.srvyTtl || "";
        modalSrvyNo.value = data.srvyNo;
        modalAnonBadge.style.display = data.srvyAnon === 'Y' ? 'inline-block' : 'none';

        let html = '';
        data.questions.forEach((q, index) => {
            html += `
                <div class="question-card">
                    <div class="q-header">
                        <span class="q-num">\${index + 1}</span>
                        <h4 class="q-title">\${q.srvyQuestCn}</h4>
                    </div>
                <div class="q-answer-area">
            `;

            if(q.srvyQuestType === 1) {
                q.items.forEach(opt => {
                    html += `
                        <label class="opt-label">
                            <input type="radio" name="q_\${q.srvyQuestNo}" value="\${opt.srvyQuestItemNo}" required>
                            <span>\${opt.srvyQuestItemCn}</span>
                        </label>
                    `;
                });
            } else {
                html += `<textarea name="q_\${q.srvyQuestNo}" class="q-textarea" placeholder="답변을 입력해주세요." required></textarea>`;
            }
            html += `</div></div>`;
        });
        listContainer.innerHTML = html;
        const modalBody = document.querySelector('.modal-body');
        if (modalBody) {
            modalBody.scrollTo(0, 0);
        }
    }

    // [설문 응답 제출] -----------------------------------------------------------
    function submitSurvey() {
        const form = document.getElementById('surveyForm');
        const modalBody = document.querySelector('.modal-body');
        const questionCards = document.querySelectorAll('.question-card');

        let firstUnanswered = null;
        const answers = [];

        questionCards.forEach((card) => {
            const radio = card.querySelector('input[type="radio"]:checked');
            const textarea = card.querySelector('textarea');
            const inputElement = card.querySelector('[name^="q_"]');

            if(!inputElement) return;

            const questionNo = inputElement.name.split('_')[1];
            let val = radio ? radio.value : (textarea ? textarea.value.trim() : "");

            // 미응답 항목
            if (!val) {
                if (!firstUnanswered) firstUnanswered = card;
                card.style.border = "2px solid #ff3e1d";
                card.style.backgroundColor = "#fff5f5";
            } else {
                card.style.border = "1px solid #f1f5f9";
                card.style.backgroundColor = "#f9fafb";
                answers.push({
                    srvyQuestNo: parseInt(questionNo),
                    srvyAnsCn: val
                });
            }
        });

        if (firstUnanswered) {
            AppAlert.warning('미입력 항목 확인', '모든 필수 문항에 답변해 주세요.', null, 'assignment_late') // (알람 리팩토링)
            .then(() => {
                firstUnanswered.scrollIntoView({
                    behavior: 'smooth',
                    block: 'center'
                });

                firstUnanswered.style.transition = "background-color 0.5s, border-color 0.5s";
                firstUnanswered.style.backgroundColor = "#fff5f5";
                firstUnanswered.style.borderColor = "#ff3e1d";
            });
            return;
        }

        const srvyNo = document.getElementById('modalSrvyNo').value;
        const submitData = {
            srvyNo: parseInt(srvyNo),
            questions: answers
        };

        AppAlert.confirm('설문 제출', '작성하신 응답을 제출하시겠습니까?', '제출하기', '취소', 'send', 'primary')
            .then((confirmResult) => { // AppAlert.confirm의 결과 (버튼 클릭 여부)
                if (confirmResult.isConfirmed) {
                    Swal.fire({
                        title: '제출 중...',
                        didOpen: () => { Swal.showLoading(); },
                        allowOutsideClick: false
                    });

                    fetch('/survey/submit', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(submitData)
                    })
                    .then(response => response.json())
                    .then(serverData => {
                        if (serverData.status === "success") {
                            const currentSrvyTitle = document.getElementById('modalTitle').innerText;

                            const alarmData = {
                                title: '마일리지 적립 완료',
                                message: `[\${currentSrvyTitle}] 설문 참여로 마일리지가 지급되었습니다.`,
                                icon: 'monetization_on',
                                type: 'success'
                            };

                            sessionStorage.setItem('pendingAlarm', JSON.stringify(alarmData));
                            closeModal();
                            location.href = "/survey/survey?tab=mine";
                        } else {
                            AppAlert.error('실패', serverData.message || '제출 중 오류 발생', null, 'error');
                        }
                    })
                    .catch(err => {
                        console.error("Error:", err);
                        AppAlert.error('통신 오류', '서버와 연결할 수 없습니다.', null, 'wifi_off');
                    });
                }
            });
        }


    // [통계 모달] -----------------------------------------------------------------
    function viewStats(srvyNo) {
        fetch(`/survey/statsData?srvyNo=\${srvyNo}`)
            .then(response => {
                if (!response.ok) throw new Error('데이터 로드 실패');
                return response.json();
            })
            .then(data => {
                if (!data) {
                    AppAlert.info('알림', '통계 데이터가 존재하지 않습니다.', null, 'bar_chart');
                    return;
                }

                renderStats(data);

                document.getElementById('statsModal').style.display = 'flex';
                document.body.style.overflow = 'hidden';

                setTimeout(() => {
                    const fills = document.querySelectorAll('.progress-bar-fill');
                    fills.forEach(fill => {
                        const targetWidth = fill.getAttribute('data-width');
                        fill.style.width = targetWidth + '%';
                    });
                }, 150);
            })
            .catch(err => {
                console.error("Error:", err);
                AppAlert.error('에러', '통계 데이터를 불러오는데 실패했습니다.', null, 'error_outline'); // (알람 리팩토링)
            });
    }

    // [통계 데이터 렌더링] ---------------------------------------------------------------
    function renderStats(data) {
        document.getElementById('statsTitle').innerText = data.srvyCn;

        // 총 참여 인원수
        const total = data.srvyNope || 0;
        document.getElementById('statsTotalBadge').innerText = `총 \${total}명 참여`;

        const listContainer = document.getElementById('statsList');
        let html = '';

        if (data.questions && data.questions.length > 0) {
            data.questions.forEach((q, index) => {
                html += `
                    <div class="question-card">
                        <div class="q-header">
                            <span class="q-num">\${index + 1}</span>
                            <h4 class="q-title">\${q.srvyQuestCn}</h4>
                        </div>
                        <div class="stats-container">
                `;

                if(q.srvyQuestType === 1) { // 객관식
                    if(q.items && q.items.length > 0) {
                        q.items.forEach(item => {
                            // 퍼센트 계산 (참여자가 0명일 때 대비)
                            const choiceCount = item.itemCount || 0;
                            const pct = total > 0 ? Math.round((choiceCount / total) * 100) : 0;

                            html += `
                                <div class="stats-item">
                                    <div class="stats-info">
                                        <span class="stats-label">\${item.srvyQuestItemCn}</span>
                                        <span class="stats-pct">\${pct}%</span>
                                    </div>
                                    <div class="progress-bar-bg">
                                        <div class="progress-bar-fill" data-width="\${pct}"></div>
                                    </div>
                                    <div class="stats-count">\${choiceCount}명 선택</div>
                                </div>
                            `;
                        });
                    }
                } else {
                    // 주관식
                    html += `<div class="essay-answer-list">`;
                    if(q.answers && q.answers.length > 0) {
                        const limit = 5; // ✨ 보여주고 싶은 답변 개수 설정
                        const displayAnswers = q.answers.slice(0, limit); // 0번부터 limit개만 자르기
                        const remainingCount = q.answers.length - limit;

                        displayAnswers.forEach(ans => {
                            html += `<div class="essay-item">\${ans}</div>`;
                        });

                        if (remainingCount > 0) {
                                html += `
                                    <div style="text-align: center; padding: 10px; color: #94a3b8; font-size: 13px; font-weight: 500;">
                                        ... 외 \${remainingCount}개의 답변이 더 있습니다.
                                    </div>
                                `;
                            }
                    } else {
                        html += `<div class="essay-answer-list">`;
                        if(q.answers && q.answers.length > 0) {
                            const limit = 3;
                            const displayAnswers = q.answers.slice(0, limit);
                            const remaining = q.answers.length - limit;

                            displayAnswers.forEach(ans => {
                                html += `<div class="essay-item">${ans}</div>`;
                            });

                            if (remaining > 0) {
                                // 답변 배열을 문자열로 변환하여 함수에 전달
                                const allAnswersJson = encodeURIComponent(JSON.stringify(q.answers));
                                html += `
                                    <button type="button" onclick="openEssayDetail('\${allAnswersJson}')"
                                            style="width: 100%; padding: 12px; margin-top: 8px; background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 12px; color: #64748b; font-size: 13px; font-weight: 600; cursor: pointer; transition: 0.2s;">
                                        + \${remaining}개의 답변 더보기
                                    </button>
                                `;
                            }
                        } else {
                            html += `<div class="text-muted" style="font-size:14px; padding: 10px;">제출된 답변이 없습니다.</div>`;
                        }
                        html += `</div>`;
                    }
                }
                html += `</div></div>`;
            });
        }
        listContainer.innerHTML = html;
    }


    // 통계 모달 닫기
    function closeStatsModal() {
        document.getElementById('statsModal').style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    // 주관식 더보기 팝업 열기
    function openEssayDetail(encodedData) {
        const answers = JSON.parse(decodeURIComponent(encodedData));
        const listContainer = document.getElementById('essayDetailList');

        let html = '';
        answers.forEach(ans => {
            html += `<div class="essay-item" style="margin-bottom:10px; border-left: 4px solid #696cff;">\${ans}</div>`;
        });

        listContainer.innerHTML = html;
        document.getElementById('essayDetailModal').style.display = 'flex';
    }

    // 주관식 더보기 팝업 닫기
    function closeEssayModal() {
        document.getElementById('essayDetailModal').style.display = 'none';
    }



</script>