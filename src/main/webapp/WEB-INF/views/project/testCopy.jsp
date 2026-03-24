<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Material Icons & Google Fonts -->
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    /* 1. 상단 탭 */
    .project-tabs-container { background-color: #f4f7ff; padding: 1.5rem 1.5rem 0 1.5rem; }
    .project-tabs { display: flex; gap: 5px; align-items: flex-end; height: 48px; }
    .project-tab-btn {
        border: none; background: #e0e5f2; color: #707eae; padding: 10px 25px;
        font-size: 0.95rem; font-weight: 700; border-radius: 12px 12px 0 0;
        cursor: pointer; height: 40px; font-family: 'Pretendard', sans-serif; transition: 0.2s;
    }
    .project-tab-btn.active { background: #fff; color: #696CFF; height: 48px; box-shadow: 0 -5px 10px rgba(0,0,0,0.02); }

    /* 2. 레이아웃 */
    .tab-content { background: #fff; padding: 2rem; }
    .member-main-wrapper { display: flex; gap: 24px; align-items: flex-start; }
    .m-card {
        background: #fff; border-radius: 12px; padding: 25px;
        border: 1px solid #e6e9ed; box-shadow: 0 4px 15px rgba(0,0,0,0.04);
    }
    .m-left-chart { flex: 1; }
    .m-right-list { flex: 1.3; }

    /* 차트 헤더 & 범례 */
    .chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
    .chart-title { font-size: 1.1rem; font-weight: 800; color: #444; }
    .custom-legend { display: flex; gap: 12px; }
    .legend-item { display: flex; align-items: center; font-size: 0.8rem; font-weight: 600; color: #666; }
    .legend-color { width: 10px; height: 10px; border-radius: 2px; margin-right: 5px; }

    /* 필터 및 검색 */
    .m-filter-row { display: flex; gap: 6px; margin-bottom: 20px; align-items: center; }
    .m-search-group { display: flex; width: 320px; border: 1px solid #d9dee3; border-radius: 8px; overflow: hidden; background: #fff; transition: 0.2s; }
    .m-search-group:focus-within { border-color: #696CFF; }
    .m-search-group input { border: none; padding: 10px 15px; width: 100%; outline: none; }

    /* 검색 버튼 */
    .m-btn-search { background: #696CFF; color: #fff; border: none; padding: 10px 22px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; }
    .m-btn-search:hover { background: #5f61e6; box-shadow: 0 4px 10px rgba(105, 108, 255, 0.3); }

    /* 초기화 버튼 */
    .m-btn-reset {
        background: #fff;
        color: #696CFF;
        border: 1.5px solid #696CFF;
        padding: 9px 18px;
        border-radius: 8px;
        font-weight: 700;
        cursor: pointer;
        transition: 0.2s;
    }
    .m-btn-reset:hover {
        background: #5f61e6 !important;
        color: #fff !important;
        border-color: #5f61e6;
        box-shadow: 0 4px 10px rgba(105, 108, 255, 0.3);
    }

    /* 테이블 스타일 */
    .m-table { width: 100%; border-collapse: collapse; }
    .m-table th { border-bottom: 2px solid #f0f2f5; padding: 12px; text-align: left; color: #8592a3; font-size: 0.8rem; }
    .m-table td { border-bottom: 1px solid #f4f6f9; padding: 14px 12px; font-size: 0.9rem; color: #566a7f; }
    .m-table tbody tr:hover td { background-color: #f8f9ff; }

    /* 채팅 버튼 호버 */
    .m-btn-chat { background: #f0f2ff; border: none; border-radius: 6px; padding: 7px; color: #696CFF; cursor: pointer; transition: 0.2s; }
    .m-btn-chat:hover { background: #696CFF; color: #fff; }

    /* 아이콘이 클릭 이벤트를 방해하지 않도록 설정 */
    .m-btn-chat span {
        pointer-events: none;
    }

</style>

<div class="project-tabs-container">
    <div class="project-tabs">
        <button class="project-tab-btn">요약</button>
        <button class="project-tab-btn">일감</button>
        <button class="project-tab-btn">일정</button>
        <button class="project-tab-btn active">구성원</button>
    </div>
</div>

<div class="tab-content">
    <div class="member-main-wrapper">
        <!-- 왼쪽: 차트 영역 -->
        <div class="m-left-chart m-card">
            <div class="chart-header">
                <span class="chart-title">구성원별 업무 현황</span>
                <div class="custom-legend">
                    <div class="legend-item"><div class="legend-color" style="background: #512DA8;"></div>총업무</div>
                    <div class="legend-item"><div class="legend-color" style="background: #9575CD;"></div>진행중</div>
                    <div class="legend-item"><div class="legend-color" style="background: #D1C4E9;"></div>완료</div>
                    <div class="legend-item"><div class="legend-color" style="background: #A8A8A8;"></div>대기</div>
                </div>
            </div>
            <div style="height: 600px;"><canvas id="memberHorizontalChart"></canvas></div>
        </div>

        <!-- 오른쪽: 목록 영역 -->
        <div class="m-right-list m-card">
            <div class="chart-header">
                <span class="chart-title">구성원 목록 (${memberStList.size()})</span>
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
                <tbody>
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

<!-- 숨겨진 전송용 폼 (ChatController의 createFromMember로 전송) -->
<form id="directChatForm" action="<c:url value='/chat/createDirect'/>" method="post" style="display:none;">
    <input type="hidden" name="chatRmTtl" id="directChatTitle">
    <input type="hidden" name="targetId" id="directTargetId">
    <input type="hidden" name="chatRmType" value="GROUP">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
</form>


<script>



    // [채팅]
    function goToCreateChat(empId, empNm) {
        // 프로젝트명이 없을 경우를 대비한 기본값 처리
        const projectNm = "${not empty projectVO.projTtl ? projectVO.projTtl : '프로젝트'}";

        if(!confirm(empNm + "님과 채팅방을 개설하시겠습니까?")) return;

        // ChatRoomVO의 필드와 input name을 매핑
        document.getElementById('directChatTitle').value = "[" + projectNm + "] " + empNm + "님과의 대화";
        document.getElementById('directTargetId').value = empId;
        document.getElementById('directChatForm').submit();
    }


    document.addEventListener('DOMContentLoaded', function() {
        const originalData = ${not empty chartDataJson ? chartDataJson : '[]'};
        let memberChart = null;

        // [검색]
        function performSearch() {
            const keyword = document.getElementById('m-search-input').value.toLowerCase().trim();

            const filteredData = originalData.filter(item => {
                const name = (item.prtpntNm || "").toLowerCase();
                const dept = (item.deptNm || "").toLowerCase();
                return name.includes(keyword) || dept.includes(keyword);
            });

            const tbody = document.querySelector('.m-table tbody');
            tbody.innerHTML = "";

            if (filteredData.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:50px; color:#999;">검색 결과가 없습니다.</td></tr>';
            } else {
                filteredData.forEach((member, index) => {
                    const row = `
                    <tr>
                        <td>\${index + 1}</td>
                        <td style="font-weight: 700; color: #333;">\${member.prtpntNm}</td>
                        <td>\${member.deptNm}</td>
                        <td>\${member.jbgdNm}</td>
                        <td><b style="color:#696CFF">\${member.totalTasks}</b> 건</td>
                        <td>
                            <button class="m-btn-chat" onclick="goToCreateChat('\${member.empId}', '\${member.prtpntNm}')">
                                <span class="material-icons" style="font-size: 18px;">chat_bubble_outline</span>
                            </button>
                        </td>
                    </tr>`;
                    tbody.insertAdjacentHTML('beforeend', row);
                });
            }

            updateChart(filteredData);

            const titleElement = document.querySelector('.m-right-list .chart-title');
            if(titleElement) titleElement.innerText = `구성원 목록 (\${filteredData.length})`;
        }

        // [차트]
        function updateChart(data) {
            const ctx = document.getElementById('memberHorizontalChart').getContext('2d');
            if (memberChart) memberChart.destroy();
            if (data.length === 0) return;

            memberChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.map(item => item.prtpntNm),
                    datasets: [
                        { label: '총업무', data: data.map(item => item.totalTasks), backgroundColor: '#512DA8', barThickness: 15 },
                        { label: '진행중', data: data.map(item => item.progTasks), backgroundColor: '#9575CD', barThickness: 15 },
                        { label: '완료', data: data.map(item => item.compTasks), backgroundColor: '#D1C4E9', barThickness: 15 },
                        { label: '대기', data: data.map(item => item.waitTasks), backgroundColor: '#A8A8A8', barThickness: 15 }
                    ]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { beginAtZero: true, grid: { color: '#f0f2f5' } },
                        y: { grid: { display: false }, ticks: { font: { size: 13, weight: '700' }, color: '#444' } }
                    }
                }
            });
        }


        document.getElementById('m-btn-search').addEventListener('click', performSearch);
        document.getElementById('m-search-input').addEventListener('keyup', (e) => {
            if (e.key === 'Enter') performSearch();
        });

        document.getElementById('m-btn-reset').addEventListener('click', function() {
            document.getElementById('m-search-input').value = "";
            performSearch();
        });

        performSearch();    // 초기 실행
    });
</script>