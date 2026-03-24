<%@ page language="java" contentType="text/html; charset=UTF-8"%>

<div class="survey-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
        <div class="tab-wrapper">
            <button id="btn-ongoing" class="tab-btn active" onclick="showTab('ongoing')">진행 중인 설문</button>
            <button id="btn-mine" class="tab-btn" onclick="showTab('mine')">내가 만든 설문</button>
        </div>
        <button class="create-btn" onclick="toggleModal(true)">
            <span style="font-size: 20px;">+</span> 새 설문 만들기
        </button>
    </div>

    <div id="view-ongoing" class="survey-grid">
        <div class="survey-card">
            <div style="display: flex; justify-content: space-between; margin-bottom: 20px;">
                <span class="status-badge">In Progress</span>
                <span class="d-day">D-5</span>
            </div>
            <h3 style="font-size: 20px; font-weight: 800; margin: 0 0 12px 0;">2026 상반기 워크숍 장소 투표</h3>
            <p style="font-size: 14px; color: #64748b; line-height: 1.6; margin-bottom: 24px;">
                사내 구성원들의 의견을 수렴하여 최적의 워크숍 장소를 선정하고자 합니다.
            </p>
            <div style="font-size: 12px; color: #94a3b8; margin-bottom: 24px;">
                <div style="margin-bottom: 6px;">👤 작성자: 유아름 팀장</div>
                <div>📅 기간: ~ 2026.03.01</div>
            </div>
            <div style="display: flex; gap: 10px;">
                <button style="flex: 2; padding: 14px; background: #1e293b; color: white; border: none; border-radius: 12px; font-weight: 700; cursor: pointer;">참여하기</button>
                <button style="flex: 1; padding: 14px; background: white; border: 1px solid #e2e8f0; border-radius: 12px; cursor: pointer; color: #64748b;">📊 통계</button>
            </div>
        </div>
    </div>

    <div id="view-mine" class="survey-grid" style="display: none;">
        <div class="survey-card" style="border-left: 5px solid #2563eb;">
            <div style="display: flex; justify-content: space-between; margin-bottom: 20px;">
                <span class="status-badge" style="background:#f1f5f9; color: #475569;">My Survey</span>
                <span style="font-size: 12px; color: #94a3b8;">참여인원: 12명 (SRVY_NOPE)</span>
            </div>
            <h3 style="font-size: 20px; font-weight: 800; margin: 0 0 12px 0;">IT 장비 선호도 조사</h3>
            <p style="font-size: 14px; color: #64748b; line-height: 1.6; margin-bottom: 24px;">
                부서 내 장비 교체를 위한 선호도 조사입니다.
            </p>
            <div style="display: flex; gap: 10px;">
                <button style="flex: 1; padding: 12px; background: white; border: 1px solid #e2e8f0; border-radius: 10px; font-weight: 700; cursor: pointer;">수정</button>
                <button style="flex: 1; padding: 12px; background: white; border: 1px solid #fee2e2; color: #ef4444; border-radius: 10px; font-weight: 700; cursor: pointer;">삭제</button>
                <button style="flex: 2; padding: 12px; background: #2563eb; color: white; border: none; border-radius: 10px; font-weight: 700; cursor: pointer;">상세 통계 보기</button>
            </div>
        </div>
    </div>
</div>

<div id="createModal">
    </div>

<script>
    // 탭 전환 함수
    function showTab(tabName) {
        const ongoingView = document.getElementById('view-ongoing');
        const mineView = document.getElementById('view-mine');
        const btnOngoing = document.getElementById('btn-ongoing');
        const btnMine = document.getElementById('btn-mine');

        if (tabName === 'ongoing') {
            // 진행 중인 설문 노출
            ongoingView.style.display = 'grid';
            mineView.style.display = 'none';
            // 버튼 스타일 제어
            btnOngoing.classList.add('active');
            btnMine.classList.remove('active');
        } else {
            // 내가 만든 설문 노출
            ongoingView.style.display = 'none';
            mineView.style.display = 'grid';
            // 버튼 스타일 제어
            btnMine.classList.add('active');
            btnOngoing.classList.remove('active');
        }
    }

    // 모달 제어 함수
    function toggleModal(show) {
        document.getElementById('createModal').style.display = show ? 'flex' : 'none';
    }
</script>