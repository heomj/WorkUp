<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        /* 간트차트 컨테이너 스타일 개선 */
        #tab-gantt-container {
            padding: 1.5rem;
            background-color: #fff;
            border-radius: 0 0 25px 25px; /* 탭 하단 둥글게 */
        }

        /* 차트 헤더 (범례 & 버튼 영역) */
        .gantt-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #eef0f2;
        }

        /* 차트 본체 카드 스타일 */
        #chart-wrapper {
            width: 100%;
            height: 600px; /* 고정 높이 혹은 calc 사용 */
            overflow: auto;
            background: #ffffff;
            border: 1px solid #d9dee3;
            border-radius: 12px;
            box-shadow: 0 2px 6px rgba(67, 89, 113, 0.08);
        }

        /* 범례 아이템 */
        .gantt-legend {
            display: flex;
            gap: 16px;
            font-size: 0.85rem;
            font-weight: 700;
            color: #566a7f;
        }

        .legend-dot {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 4px;
        }
        /* 차트 디자인 */
        svg.gantt-chart text { font-family: sans-serif; font-size: 12px; }
        svg.gantt-chart .event rect.event { fill-opacity: 0.3; cursor: pointer; }
        svg.gantt-chart .event:hover rect.event { fill-opacity: 0.6; }
        svg.gantt-chart .event line.leader { stroke-width: 2px; }
        svg.gantt-chart .event line.readoff { stroke-width: 1px; stroke-dasharray: 2,2; opacity: 0; transition: opacity 0.15s ease; }
        svg.gantt-chart .event:hover line.readoff { opacity: 1; }
        svg.gantt-chart .grid line { stroke: #ccc; stroke-dasharray: 2,2; stroke-opacity: 1; }
        .now-label { fill: #ffa500; font-weight: bold; font-size: 14px; }
        svg.gantt-chart text.label { pointer-events: none; overflow: hidden; }
        #chart-wrapper { width: 100%; height: 100%; overflow: auto; padding:20px;}
    </style>
</head>
<body>
    <div id="tab-gantt-container">
        <div class="gantt-header">
            <div class="gantt-legend">
                <sapn>중요도</sapn>
                <span><i class="legend-dot" style="background: #e15759;"></i> 높음</span>
                <span><i class="legend-dot" style="background: #f28e2c;"></i> 보통</span>
                <span><i class="legend-dot" style="background: #4e79a7;"></i> 낮음</span>
                <span style="margin-left:10px; font-weight: 400;">|&nbsp;&nbsp; ⦁ 참여 인원 표시</span>
            </div>

            <div style="display: flex; gap: 10px;">
                <button onclick="startGanttTutorial()" style="display: flex; align-items: center; gap: 6px; background: #fff; color: #566a7f; border: 1px solid #d9dee3; padding: 8px 16px; border-radius: 8px; font-weight: 700; cursor: pointer; font-size: 0.85rem;">
                    <span class="material-icons" style="font-size: 1.1rem; color: #a1acb8;">help_outline</span> 차트 도움말
                </button>
            </div>
        </div>

        <div id="chart-wrapper">
            <div id="chart"></div>
        </div>
    </div>

<script>
    let events=[];
    // 4. 차트 생성 함수
    // 차트 영역에서 마우스 휠 이벤트 가로 스크롤로 변환
    document.getElementById('chart-wrapper').addEventListener('wheel', (evt) => {
        // 세로 스크롤이 발생하는 경우(deltaY)를 가로 스크롤(scrollLeft)로 치환
        if (evt.deltaY !== 0) {
            evt.preventDefault(); // 브라우저 기본 세로 스크롤 방지
            document.getElementById('chart-wrapper').scrollLeft += evt.deltaY;
        }
    }, { passive: false });
    async  function getTasksforGantt(){

        axios.get(`/kanban/tasklist?projNo=\${projNo}`) // 프로젝트 번호에 맞는 일감 목록 조회
        //axios.get(`/kanban/tasklist?projNo=9`) // 프로젝트 번호에 맞는 일감 목록 조회
            .then(response => {
                taskVOList = response.data; // 전역변수에 불러온 데이터 넣기..
                console.log("데이터 왔나", taskVOList)
                /* renderKanbanBoard(currentTaskData); //불러온데이터 상태 기둥에 넣는 함수 호출*/
                events = taskVOList.map(task => {
                    // 날짜 0시 초기화 미리 처리 (칼정렬을 위해)
                    const sDate = task.taskBgngDt ? new Date(task.taskBgngDt) : new Date();
                    const eDate = task.taskEndDt ? new Date(task.taskEndDt) : new Date();
                    sDate.setHours(0, 0, 0, 0);
                    eDate.setHours(0, 0, 0, 0);
                    return {
                        start: task.taskBgngDt ? task.taskBgngDt.split('T')[0] : "",
                        end: task.taskEndDt ? task.taskEndDt.split('T')[0] : "",
                        title: task.taskTtl,
                        type: task.taskImpt,
                        // collection은 고민 중이라고 하셨으니,
                        // 우선 기본값을 넣거나 특정 필드를 연결해둘 수 있습니다.
                        collection: task.taskParticipantVOList || []
                    };
                });
                console.log("변환된 events:", events);
                generateTimeline(events);
            })
            .catch(error => {
                console.error("데이터 로드 실패:", error);
                Swal.fire('오류', '일감 목록을 불러오지 못했습니다.', 'error');
            });

        // 1. 기초 설정

    }

    function generateTimeline(events) {
        d3.select("#chart-wrapper").selectAll("svg").remove();
// [1] 프로젝트 시작/종료 날짜 0시 초기화
        const pStart = new Date("${project.projBgngDt}".replace("KST ", ""));
        pStart.setHours(0, 0, 0, 0); // 시간을 00:00:00.000으로 강제 고정

        const pEnd = new Date("${project.projEndDt}".replace("KST ", ""));
        pEnd.setHours(0, 0, 0, 0);

        const startDate = d3.timeMonth.offset(pStart, -1);
        const endDate = d3.timeMonth.offset(pEnd, 1);

        const rowHEIGHT = 30;//열 길이
        const MARGIN = {top: 80, right: 100, bottom: 50, left: 50};
        const eventHeight = 20; // 막대 높이
        const HEIGHT = (events.length * rowHEIGHT) + MARGIN.top + MARGIN.bottom;
        const colors = { 높음: "#e15759", 보통: "#f28e2c", 낮음: "#4e79a7" };



/*        // [3] 기본 너비/높이 설정
        const containerWidth = document.getElementById("chart-wrapper").clientWidth;
        const monthsDiff = d3.timeMonth.count(startDate, endDate) || 1;
        const dynamicWidth = Math.max(containerWidth, monthsDiff * (containerWidth / 3));

        // 3. 확대 로직 (100% 너비에 2년만 보이게)
        const containerWidth = document.getElementById("chart-wrapper").clientWidth;
        const pixelsPerYear = containerWidth * 70; // 1년당 너비
        const totalYears = 1; // 보여줄 전체 범위 (예: 2024~2028)
        const dynamicWidth = totalYears * pixelsPerYear;   ==>>여기까지 합쳐서 다음*/
// [3] 가로 너비 설정
        const containerWidth = document.getElementById("chart-wrapper").clientWidth;

// 프로젝트 전체 기간(일 단위) 계산
        const totalDays = d3.timeDay.count(startDate, endDate) || 1;

// 배율 조정: 화면 하나에 며칠이 보이게 할 것인가?
// 15로 나누면 화면 하나에 약 2주일치 데이터가 보입니다. (스크롤 적당해짐)
// 더 넓게 보고 싶으면 10으로, 더 좁게(스크롤 줄이기) 보고 싶으면 30으로 바꾸세요.
        const pixelsPerDay = containerWidth / 30;

        const dynamicWidth = Math.max(containerWidth, totalDays * pixelsPerDay);

// 나머지 높이 설정

        const timeScale = d3.scaleTime()
            .domain([startDate,endDate])
            .range([0, dynamicWidth - MARGIN.left - MARGIN.right]);



        const getY = (i) => i * 28+20; // 계단식 높이 계산


// generateTimeline 함수 내 svg 생성 부분에 배경색 추가 (선택사항)
        const svg = d3.select("#chart").append("svg")
            .attr("class", "gantt-chart")
            .attr("width", dynamicWidth)
            .attr("height", HEIGHT)
            .style("background-color", "#fff"); // 배경을 흰색으로 고정하여 그리드 가독성 높임

        const chartG = svg.append("g")
            .attr("transform", `translate(\${MARGIN.left}, \${MARGIN.top})`);




        // [중요] 음영 처리 로직 (변수명 통일: parsedStart, parsedEnd)
        const parsedStart = pStart; // 위에서 선언한 pStart를 그대로 사용하거나 이름을 바꾸세요
        const parsedEnd = pEnd;

        const overlayGroup = chartG.append("g").attr("class", "overlays");

        // 시작 전 1개월 음영
        overlayGroup.append("rect")
            .attr("x", timeScale(startDate))
            .attr("y", -MARGIN.top)
            .attr("width", Math.max(0, timeScale(parsedStart) - timeScale(startDate)))
            .attr("height", HEIGHT)
            .attr("fill", "#888")
            .attr("fill-opacity", 0.15);

        // 종료 후 1개월 음영
        overlayGroup.append("rect")
            .attr("x", timeScale(parsedEnd))
            .attr("y", -MARGIN.top)
            .attr("width", Math.max(0, timeScale(endDate) - timeScale(parsedEnd)))
            .attr("height", HEIGHT)
            .attr("fill", "#888")
            .attr("fill-opacity", 0.15);


// [오늘 날짜 음영 처리]
        const today = new Date();
        today.setHours(0, 0, 0, 0); // 오늘 0시

        const tomorrow = new Date(today);
        tomorrow.setDate(today.getDate() + 1); // 내일 0시

// 차트 범위 내에 오늘이 포함될 때만 그리기
            overlayGroup.append("rect")
                .attr("class", "today-highlight")
                .attr("x", timeScale(today))
                .attr("y", -MARGIN.top)
                .attr("width", timeScale(tomorrow) - timeScale(today)) // 정확히 하루치 너비
                .attr("height", HEIGHT)
                .attr("fill", "#4CAF50") // 오렌지색
                .attr("fill-opacity", 0.1); // 아주 은은하게 (0.1 ~ 0.15 추천)

/*        // 축 및 그리드 (월 단위)
        const xAxis = d3.axisTop(timeScale)
            .ticks(d3.timeMonth.every(1)) // 3개월 단위로 표시
            .tickFormat(d3.timeFormat("%y년 %m월"));

                    chartG.append("g").attr("class", "grid").call(grid)
            .call(g => g.select(".domain").remove());
        chartG.append("g").attr("class", "axis").call(xAxis);
            */

        // --- 기존 월 단위 축 (xAxisTop) ---
        const xAxisMonth = d3.axisTop(timeScale)
            .ticks(d3.timeMonth.every(1))
            .tickFormat(d3.timeFormat("%y년 %m월"));

// --- 새로 추가할 일 단위 축 (xAxisDay) ---
        const xAxisDay = d3.axisTop(timeScale)
            .ticks(d3.timeDay.every(1)) // 매일매일 체크
            .tickFormat(d3.timeFormat("%d")); // "01", "02" 처럼 일자만 표시

        const grid = d3.axisTop(timeScale)
            .ticks(d3.timeDay.every(1))
            .tickSize(-HEIGHT)
            .tickFormat("");
// --- 축 그리기 ---

// 1. 월 축 (조금 더 위로 올리기)
        chartG.append("g")
            .attr("class", "axis axis-month")
            .attr("transform", "translate(0, -30)") // 월 표시를 일 표시보다 위로
            .call(xAxisMonth);

// 2. 일 축 (막대 바로 위에 붙이기)
        chartG.append("g")
            .attr("class", "axis axis-day")
            .attr("transform", "translate(0, 0)")
            .call(xAxisDay)
            .call(g => g.selectAll("text") // 글자가 겹칠 수 있으니 폰트 크기 조절
                .style("font-size", "9px")
                .attr("dy", "0.5em"));
//그리드
        chartG.append("g")
            .attr("class", "grid")
            .style("stroke-opacity", 0.5) // 너무 진하면 지저분하니 살짝 흐리게
            .call(grid)
            .call(g => g.select(".domain").remove()); // 바깥 테두리 선 제거
// 월 단위 축 그리기

// 오늘 날짜 표시 (빨간색, 강조)
        const nowX = timeScale(new Date());

        chartG.append("text")
            .attr("class", "now-label")
            .attr("x", nowX)
            .attr("y", -40)
            .attr("text-anchor", "middle") // 화살표가 선 중간에 오도록 정렬
            .style("fill", "#e15759")      // 빨간색 (보통 중요도 색상과 통일감 있게)
            .style("font-size", "14px")    // 글자 크기 키움
            .style("font-weight", "bold")  // 더 잘 보이게 굵게
            .text("⬇ now");

        events.sort((a, b) => new Date(a.start) - new Date(b.start));


        //  이벤트(막대) 및 텍스트 그리기 (최종 통합본)
        const eventGroups = chartG.selectAll(".event-group")
            .data(events).join("g")
            .attr("class", "event")
            // JSP EL 에러 방지를 위해 백틱 대신 문자열 결합 사용
            .attr("transform", function(d, i) {
                return "translate(0, " + getY(i) + ")";
            });

// 1. 가이드 점선 (readoff)
        eventGroups.append("line")
            .attr("class", "readoff")
            .attr("x1", d => {
                const end = new Date(d.end);
                end.setHours(0, 0, 0, 0); // 0시 초기화
                return timeScale(end);
            })
            .attr("x2", d => {
                const end = new Date(d.end);
                end.setHours(0, 0, 0, 0); // 0시 초기화
                return timeScale(end);
            })
            .attr("y1", 0)
            .attr("y2", function(d, i) { return -getY(i) - 20; })
            .attr("stroke", d => colors[d.type])
            .style("stroke-dasharray", "2,2");

// 2. 메인 막대 (rect)
        eventGroups.append("rect")
            .attr("class", "event")
            .attr("x", d => {
                const start = new Date(d.start);
                start.setHours(0, 0, 0, 0); // 개별 이벤트도 0시로 초기화
                return timeScale(start);
            })

            .attr("y", 0)
            .attr("width", d => {
                const start = new Date(d.start);
                const end = new Date(d.end);
                start.setHours(0, 0, 0, 0);
                end.setHours(0, 0, 0, 0);
                return Math.max(0, timeScale(end) - timeScale(start));
            })
            .attr("height", eventHeight)
            .attr("fill", d => colors[d.type]);

// 3. 리더 라인 (leader)
        eventGroups.append("line")
            .attr("class", "leader")
            .attr("x1", d => {
                const end = new Date(d.end);
                end.setHours(0, 0, 0, 0); // 0시 초기화
                return timeScale(end);
            })
            .attr("x2", d => {
                const end = new Date(d.end);
                end.setHours(0, 0, 0, 0); // 0시 초기화
                return timeScale(end);
            })
            .attr("y1", 0).attr("y2", eventHeight)
            .attr("stroke", d => colors[d.type]);
// 3. 참여 인원수만큼 원 그리기 (종료일 기준 왼쪽으로 나열)
        eventGroups.selectAll(".participant-circle")
            .data(d => d.collection || [])
            .join("circle")
            .attr("class", "participant-circle")
            .attr("cx", function(d, i, nodes) {
                // 부모(g)의 데이터를 가져와서 종료 시점(0시) 계산
                const parentData = d3.select(nodes[i].parentNode).datum();
                const end = new Date(parentData.end);
                end.setHours(0, 0, 0, 0);

                const endPos = timeScale(end);
                // 왼쪽으로 나열하려면 값을 빼줘야 합니다 (종료선에서 8px씩 왼쪽으로 이동)
                return endPos - 8 - (i * 8);
            })
            .attr("cy", eventHeight / 2) // 막대 세로 중앙
            .attr("r", 3)
            .attr("fill", function(d, i, nodes) {
                // 부모 막대의 중요도 색상으로 꽉 채우기
                const parentData = d3.select(nodes[i].parentNode).datum();
                return colors[parentData.type] || "#ccc";
            })
            .style("stroke", "#fff") // 원들끼리 구분되게 테두리는 흰색으로 살짝
            .style("stroke-width", 0.5);
// 4. 텍스트 라벨 (Truncate/말줄임표 적용)
        eventGroups.append("text")
            .attr("x", d => {
                const start = new Date(d.start);
                start.setHours(0, 0, 0, 0); // 0시 초기화
                return timeScale(start) + 5; // 여백 5px
            })
            .attr("y", eventHeight / 2 + 4)
            .style("font-size", "11px")
            .style("font-weight", "bold")
            .style("fill", "#333")
            .style("pointer-events", "none")
            .text(function(d) {
                const fullText = d.title;
                const barWidth = timeScale(new Date(d.end)) - timeScale(new Date(d.start));
                const maxChars = Math.floor((barWidth - 10) / 8);
                if (fullText.length > maxChars && maxChars > 0) {
                    return fullText.substring(0, Math.max(0, maxChars - 1)) + "...";
                }
                return fullText;
            });

        // 오늘 날짜로 자동 스크롤
        setTimeout(() => {
            document.getElementById("chart-wrapper").scrollLeft = nowX - (containerWidth / 2);
        }, 100);
    }
    function startGanttTutorial() {
        const driver = window.driver.js.driver;
        const driverObj = driver({
            showProgress: true,
            steps: [
                {
                    element: '#chart-wrapper',
                    popover: {
                        title: '📅 프로젝트 타임라인',
                        description: '프로젝트의 전체 일정을 막대 형태로 확인하세요. 마우스 휠로 가로 스크롤이 가능합니다.',
                        side: "top", align: 'center'
                    }
                },
                {
                    element: '.now-label',
                    popover: {
                        title: '📍 현재 시점',
                        description: '화살표가 가리키는 초록색 영역이 오늘 날짜입니다.',
                        side: "bottom", align: 'center'
                    }
                },
                {
                    element: '.participant-circle',
                    popover: {
                        title: '👥 참여 인원',
                        description: '막대 오른쪽 끝의 점들은 해당 일감에 참여 중인 인원수를 나타냅니다.',
                        side: "left", align: 'center'
                    }
                }
            ]
        });
        driverObj.drive();
    }
</script>
</body>
</html>