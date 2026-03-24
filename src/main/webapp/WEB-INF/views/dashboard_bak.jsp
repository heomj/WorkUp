<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<link href="https://cdn.jsdelivr.net/npm/gridstack@10.3.1/dist/gridstack.min.css" rel="stylesheet"/>
<style>
    .grid-stack { background: #f4f7f9; min-height: calc(100vh - 200px); padding: 10px; border-radius: 12px; }
    .grid-stack-item-content { background: #fff !important; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); display: flex; flex-direction: column; }

    /* 드래그 핸들 전용 스타일 */
    .drag-header {
        cursor: move !important; background: #8C8EFF; color: #fff; padding: 10px;
        font-weight: 600; border-radius: 8px 8px 0 0; display: flex; align-items: center; gap: 8px;
    }
    .card-body-content { padding: 15px; flex: 1; overflow-y: auto; }
    #calendar-view { height: 100%; min-height: 250px; font-size: 0.85rem; }

    /* 요약 카드 (고정) */
    .summary-box { background: #fff; padding: 20px; border-radius: 8px; border: 1px solid #eee; height: 100%; }


    /* 리셋 버튼 커스텀 디자인 */
    .btn-reset-layout {
        background-color: #696cff;
        color: #fff;
        border: none;
        border-radius: 5px;
        padding: 8px 16px;
        font-size: 0.875rem;
        font-weight: 500;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 6px;
        box-shadow: 0 2px 4px rgba(105, 108, 255, 0.4);
    }
    .btn-reset-layout:hover {
        background-color: #5f61e6;
        color: #fff;
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(105, 108, 255, 0.4);
    }
    .btn-reset-layout:active {
        transform: translateY(0);
    }
</style>

<div class="d-flex justify-content-between align-items-center mb-3 px-2">
    <h4 class="mb-0" style="font-weight: 700; font-size: xx-large; color: #566a7f;">
        Dashboard
    </h4>

    <button type="button" class="btn-reset-layout" onclick="resetLayout()">
        <span class="material-icons" style="font-size: 18px;">restart_alt</span>
        레이아웃 초기화
    </button>
</div>

<div class="row g-4 mb-4">
    <div class="col-md-3">
        <div class="dashboard-card summary-card" style="background: linear-gradient(45deg, #696cff, #8592ff); color: #fff;">
            <div class="icon-box bg-white bg-opacity-25"><span class="material-icons">wb_sunny</span></div>
            <div class="summary-info">
                <p class="text-white-50">대전광역시 날씨</p>
                <h3 class="text-white">6°C <small class="fs-6 fw-normal">맑음</small></h3>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="dashboard-card summary-card">
            <div class="icon-box bg-label-danger" style="background-color: #ffe0e0; color: #ff3e1d;"><span class="material-icons">mail</span></div>
            <div class="summary-info">
                <p>안읽은 메일</p>
                <h3>12건</h3>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="dashboard-card summary-card">
            <div class="icon-box bg-label-warning" style="background-color: #fff2d6; color: #ffab00;"><span class="material-icons">pending_actions</span></div>
            <div class="summary-info">
                <p>결재대기 문서</p>
                <h3 id="pendingAprv">${pendingTotal}건</h3>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="dashboard-card summary-card">
            <div class="icon-box bg-label-info" style="background-color: #d7f5fc; color: #03c3ec;"><span class="material-icons">calendar_today</span></div>
            <div class="summary-info">
                <p>오늘의 회의</p>
                <h3>2건</h3>
            </div>
        </div>
    </div>
</div>

<div class="grid-stack" id="main-grid">
    <div class="grid-stack-item" gs-id="attendance" gs-w="3" gs-h="4" gs-x="0" gs-y="0">
        <div class="grid-stack-item-content">
            <div class="drag-header">⠿ 팀 근태 현황</div>
            <div class="card-body-content">이정우 대리 - 업무중</div>
        </div>
    </div>

    <div class="grid-stack-item" gs-id="todo" gs-w="4" gs-h="4" gs-x="3" gs-y="0">
        <div class="grid-stack-item-content">
            <div class="drag-header">⠿ To-Do List</div>
            <div class="card-body-content">
                <div class="form-check"><input class="form-check-input" type="checkbox" id="t1"><label class="form-check-label" for="t1">주간 보고</label></div>
            </div>
        </div>
    </div>

    <div class="grid-stack-item" gs-id="chat" gs-w="5" gs-h="4" gs-x="7" gs-y="0" >
        <div class="grid-stack-item-content">
            <div class="drag-header">⠿ 공지 사항</div>
            <div class="card-body-content" style="background: #f9f9f9;"> [중요] 사내 메일망 구축 완료 안내 </div>
        </div>
    </div>

    <div class="grid-stack-item" gs-id="budget" gs-w="4" gs-h="6" gs-x="0"gs-y="4" >
        <div class="grid-stack-item-content">
            <div class="drag-header">
                <span class="material-icons" style="font-size: 16px; vertical-align: middle;">pie_chart</span>
                팀 예산 소진율 (Q1)
            </div>

            <div class="card-body-content" style="background: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px;">
                <div style="width: 100%; max-width: 200px; position: relative;">
                    <canvas id="budgetDonutChart"></canvas>
                    <div id="chart-percent" style="position: absolute; top: 55%; left: 50%; transform: translate(-50%, -50%); font-size: 1.5rem; font-weight: bold; color: #4e73df;">
                        68%
                    </div>
                </div>

                <div class="mt-3 text-center">
                    <div style="font-size: 0.85rem; color: #666; font-weight: 500;">
                        소진: <span style="color: #e74a3b;">₩10,240,000</span>
                    </div>
                    <div style="font-size: 0.75rem; color: #999;">
                        총 예산: ₩15,000,000
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="grid-stack-item" gs-id="calendar" gs-w="8" gs-h="10"  gs-x="4"gs-y="4">
        <div class="grid-stack-item-content">
            <div class="drag-header">⠿ 일정 관리 (FullCalendar)</div>
            <div class="card-body-content"><div id="calendar-view"></div></div>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/gridstack@10.3.1/dist/gridstack-all.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const ctx = document.getElementById('budgetDonutChart').getContext('2d');

        // 데이터 설정
        const totalBudget = 15000000;
        const spentBudget = 10240000;
        const remainingBudget = totalBudget - spentBudget;
        const spentPercentage = Math.round((spentBudget / totalBudget) * 100);

        // 중앙 텍스트 업데이트
        document.getElementById('chart-percent').innerText = spentPercentage + "%";

        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['소진', '잔여'],
                datasets: [{
                    data: [spentBudget, remainingBudget],
                    backgroundColor: ['#4e73df', '#eaecf4'],
                    hoverBackgroundColor: ['#2e59d9', '#e2e6ea'],
                    hoverBorderColor: "rgba(234, 236, 244, 1)",
                    borderWidth: 2,
                    cutout: '75%' // 도넛 두께 조절
                }]
            },
            options: {
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false // 범례 숨김 (깔끔하게)
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.label + ': ₩' + context.raw.toLocaleString();
                            }
                        }
                    }
                },
                interaction: {
                    intersect: true
                }
            }
        });


    });
</script>

<script>
    (function() {
        let grid = null;

        async function initDashboard() {
            if (typeof GridStack === 'undefined') return setTimeout(initDashboard, 100);

            // 1. 그리드 초기화 옵션
            grid = GridStack.init({
                column: 12,
                cellHeight: 70,
                margin: 10,
                draggable: { handle: '.drag-header' },
                resizable: { handles: 'se' },
                float: true, // true로 설정해야 카드들이 겹치지 않고 빈 공간을 유지함
                alwaysShowResizeHandle: true
            });

            // 2. 저장된 레이아웃 불러오기
            loadLayout();

            // 3. 변경 발생 시 자동 저장 (이동/사이즈 조절 완료 시)
            grid.on('change', function() {
                saveLayout();
            });

            // 4. FullCalendar 실행
            if (typeof FullCalendar !== 'undefined') {
                new FullCalendar.Calendar(document.getElementById('calendar-view'), {
                    initialView: 'dayGridMonth',
                    height: 'parent',
                    locale: 'ko'
                }).render();
            }
        }

        // 레이아웃 저장 함수
        function saveLayout() {
            const res = grid.save(false); // 가짜 데이터 제외하고 실제 위치 정보만 추출
            localStorage.setItem('dashboard-layout', JSON.stringify(res));
            console.log("레이아웃이 저장되었습니다.");
        }

        // 레이아웃 복원 함수
        function loadLayout() {
            const data = localStorage.getItem('dashboard-layout');
            if (data) {
                const json = JSON.parse(data);
                grid.load(json);
                console.log("대시보드 - 저장된 레이아웃을 불러왔습니다.");
            }
        }

        window.addEventListener('load', initDashboard);
    })();
    // 1. 초기 레이아웃 상태를 저장할 변수
    let initialLayout = [];

    document.addEventListener('DOMContentLoaded', function() {
        // 그리드 객체 생성 (기존 선언 코드 활용)
        const grid = GridStack.init({
            cellHeight: 80,
            margin: 10
        });

        // 2. 페이지 로드 직후 현재의 레이아웃(위치, 크기, ID 등)을 백업
        initialLayout = grid.save();

        // 3. 레이아웃 리셋 함수
        window.resetLayout = function() {
            if (confirm("대시보드 배치를 초기 상태로 되돌리시겠습니까?")) {
                // 모든 위젯을 지우고 백업된 데이터로 다시 로드
                grid.load(initialLayout);

                // 만약 차트(Chart.js)가 로드 후에 깨진다면 다시 그려주는 로직이 필요할 수 있습니다.
                // 위에서 만든 budgetDonutChart가 있다면 여기서 다시 초기화 함수를 호출하세요.
                console.log("레이아웃이 초기화되었습니다.");
            }
        };
    });
</script>