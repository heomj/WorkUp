<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- ❤️❤️❤️❤️❤️❤️❤️❤️ 요약 (summary) 시작❤️❤️❤️❤️❤️❤️❤️❤️ -->
<div id="tab-summary" class="tab-content active" style="padding: 2rem; min-height: 100vh;">
    <div style="background: #fff; padding: 2rem; border-radius: 12px; box-shadow: 0 2px 6px rgba(67, 89, 113, 0.12); margin-bottom: 2rem; border: 1px solid #dce1e6;">
        <h3 style="margin: 0 0 1rem 0; color: #435971; font-weight: 800; font-size: 1.4rem; display: flex; align-items: center;">
            <span class="material-icons" style="font-size: 1.8rem; margin-right: 10px; color: #696CFF;">description</span>
            ${project.projTtl}
        </h3>
        <p style="color: #697a8d; line-height: 1.8; font-size: 0.95rem; margin: 0; word-break: keep-all;">
            ${project.projDtl}
        </p>
    </div>

    <div style="display: flex; gap: 1.5rem; margin-bottom: 2rem;">

        <div style="flex: 1; background: #fff; padding: 1.5rem; border-radius: 12px; box-shadow: 0 2px 6px rgba(67, 89, 113, 0.12); border: 1px solid #dce1e6; display: flex; flex-direction: column; justify-content: space-between;">
            <div style="font-size: 0.9rem; font-weight: 600; color: #8592a3; margin-bottom: 1rem;">총 업무</div>
            <div style="display: flex; align-items: baseline; justify-content: space-between;">
                <span id="totalcnt" style="font-size: 2.2rem; font-weight: 800; color: #435971;">26</span>
                <span style="font-size: 1rem; color: #8592a3;">건</span>
            </div>
            <div style="margin-top: 1rem; text-align: right; color: #696CFF; font-size: 0.8rem; font-weight: 600; cursor: pointer;" id="clickoftotalcnt">
                진행 <sapn id="onprogress"></sapn> / 총 <sapn id="totalcnt2"></sapn> >
            </div>
        </div>

        <div style="flex: 1.5; background: #fff; padding: 1.5rem; border-radius: 12px; box-shadow: 0 2px 6px rgba(67, 89, 113, 0.12); border: 1px solid #dce1e6;">
            <div style="font-size: 0.9rem; font-weight: 600; color: #8592a3; margin-bottom: 1rem;">전체 업무 진행률</div>
            <div  style="font-size: 2.2rem; font-weight: 800; color: #696CFF; margin-bottom: 0.8rem;"><span id="percent">79.3</span><span style="font-size: 1.5rem;">%</span></div>
            <div style="width: 100%; height: 12px; background-color: #e7e7ff; border-radius: 10px; overflow: hidden; position: relative;">
                <div id="percent2" style="position: absolute; top: 0; left: 0; height: 100%; width: 79.3%;
                background: linear-gradient(90deg, #696CFF 0%, #8587ff 100%);
                 border-radius: 10px; transition: width 0.5s ease-in-out; box-shadow: 0 2px 4px rgba(105, 108, 255, 0.4);"></div>
            </div>
            <div style="width: 100%; height: 12px; background-color: #e7e7ff; border-radius: 10px; overflow: hidden; position: relative;">
                <div id="percent3" style="position: absolute; top: 0; left: 0; height: 100%; width: 79.3%;
                background: linear-gradient(90deg, #696CFF  0%, red 100%);
                 border-radius: 10px; transition: width 0.5s ease-in-out; box-shadow: 0 2px 4px rgba(105, 108, 255, 0.4);"></div>
            </div>
            <div style="font-size: 0.9rem; font-weight: 600; color: #8592a3; margin-bottom: 1rem;">남은 기간 비율</div>
        </div>

        <div style="flex: 1; background: #fff; padding: 1.5rem; border-radius: 12px; box-shadow: 0 2px 6px rgba(67, 89, 113, 0.12); border: 1px solid #dce1e6; display: flex; flex-direction: column; justify-content: space-between;">
            <div style="font-size: 0.9rem; font-weight: 600; color: #8592a3; margin-bottom: 1rem;">지연 업무</div>
            <div style="display: flex; align-items: baseline; justify-content: space-between;">
                <span id="delayedcnt" style="font-size: 2.2rem; font-weight: 800; color: #ff3e1d;">3</span>
                <span style="font-size: 1rem; color: #8592a3;">건</span>
            </div>
            <div style="margin-top: 1rem; color: #ff3e1d; font-size: 0.85rem; font-weight: 600; display: flex; align-items: center; justify-content: flex-end;">
                <span class="material-icons" style="font-size: 1.1rem; margin-right: 4px;">warning</span>
                마감일 경과 업무
            </div>
        </div>

        <div style="flex: 1; background: #fff; padding: 1.5rem; border-radius: 12px; box-shadow: 0 2px 6px rgba(67, 89, 113, 0.12); border: 1px solid #dce1e6; display: flex; flex-direction: column; justify-content: space-between;">
            <div style="font-size: 0.9rem; font-weight: 600; color: #8592a3; margin-bottom: 1rem;">프로젝트 일정</div>
            <div style="text-align: center; margin: auto 0;">
                <span style="font-size: 2.2rem; font-weight: 800; color: #435971; letter-spacing: -1px;">D<span id="dDay"></span></span>
            </div>
            <div style="margin-top: 1rem; text-align: center; color: #8592a3; font-size: 0.8rem;">
                시작일: <span id="bgngdt">2024.12.31</span><br>
                종료일: <span id="enddt">2024.12.31</span>
            </div>
        </div>
    </div>

    <div style="display: flex; gap: 1.5rem;">

        <div style="flex: 1; background: #fff; padding: 2rem; border-radius: 12px; box-shadow: 0 2px 6px rgba(67, 89, 113, 0.12); border: 1px solid #dce1e6; max-width: 400px;">
            <h4 style="margin: 0 0 1.5rem 0; color: #435971; font-weight: 700; font-size: 1.1rem;">업무 상태 분포</h4>

            <div style="position: relative; width: 200px; height: 200px; margin: 0 auto 2rem;">
                <canvas id="dnChart"></canvas>

                <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; pointer-events: none;">
                    <div style="font-size: 1.8rem; font-weight: 800; color: #435971;"><span id="homi"></span>건</div>
                    <div style="font-size: 0.8rem; color: #8592a3;">전체 업무</div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; font-size: 0.85rem; color: #697a8d;">
                <div style="display: flex; align-items: center;"><span style="width: 10px; height: 10px; background-color: #dce1e6; border-radius: 2px; margin-right: 8px;"></span>대기 <span id="todocnt"></span>건</div>
                <div style="display: flex; align-items: center;"><span style="width: 10px; height: 10px; background-color: #696CFF; border-radius: 2px; margin-right: 8px;"></span>진행 <span id="progresscnt"></span>건</div>
                <div style="display: flex; align-items: center;"><span style="width: 10px; height: 10px; background-color: #71dd37; border-radius: 2px; margin-right: 8px;"></span>완료 <span id="donecnt"></span>건</div>
                <div style="display: flex; align-items: center;"><span style="width: 10px; height: 10px; background-color: #8592A3; border-radius: 2px; margin-right: 8px;"></span>보류 <span id="onholdcnt"></span>건</div>
                <div style="display: flex; align-items: center;"><span style="width: 10px; height: 10px; background-color: #ff3e1d; border-radius: 2px; margin-right: 8px;"></span>지연 <span id="dlydcnt"></span>건</div>
            </div>
        </div>


        <div style="flex: 1.5; background: #fff; padding: 2rem; border-radius: 12px; box-shadow: 0 2px 6px rgba(67, 89, 113, 0.12); border: 1px solid #dce1e6;">
            <h4 style="margin: 0; color: #435971; font-weight: 700; font-size: 1.1rem;">중요도별 일감 현황</h4>
            <div style="height: 300px; position: relative;">
            <canvas id="barChart"></canvas>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.0.0"></script>
<script>
    const ctx = document.getElementById('barChart').getContext('2d');
    document.addEventListener("DOMContentLoaded",function (){
        let projNo = ${projNo}
        chartLoadfn(projNo);
    });

    //전역변수//
    let barChart;
    let dnChart;

    document.getElementById("clickoftotalcnt").addEventListener("click",function(){
        //"일감"칸반보드로 넘어가기
        document.getElementById("toKanban").click();

    })


    ///"요약"클릭시 모든 정보를 새로 받아와서 현행화하기 위해 비동기 처리함 ///
    async function chartLoadfn(variable){
        ///////////////////////////////////////값 가져오기!!
        try {
            const response = await axios.get("/myproject/chartLoad/" + variable);
            const data = response.data; // 서버에서 받은 데이터 (예: {lowdone: 2, hightodo: 1, ...})
            console.log("받은 데이터:", data);
        ///////////////////////////////////////상단 카드
        document.getElementById("totalcnt").innerHTML=data.totalTaskCnt;
        document.getElementById("onprogress").innerHTML=data.inProgressCnt;
        document.getElementById("totalcnt2").innerHTML=data.totalTaskCnt;
        document.getElementById("percent").innerHTML=data.percent
        document.getElementById("percent2").style.width=data.percent+"%";
        document.getElementById("percent3").style.width=data.timePrgrt+"%";
        document.getElementById("delayedcnt").innerHTML=data.delayedCnt;
        let dDaynumber = data.dDay
            if(data.dDay>=0){dDaynumber="+";dDaynumber+= data.dDay}
            document.getElementById("dDay").innerHTML=dDaynumber;
        document.getElementById("homi").innerHTML=data.totalTaskCnt;
        document.getElementById("todocnt").innerHTML=data.todoCnt;
        document.getElementById("progresscnt").innerHTML=data.inProgressCnt;
        document.getElementById("donecnt").innerHTML=data.doneCnt;
        document.getElementById("onholdcnt").innerHTML=data.onHoldCnt;
        document.getElementById("dlydcnt").innerHTML=data.delayedCnt;
            const rawDate = String(data.enddt); // "20260306"으로 변환

            if (rawDate && rawDate.length === 8) {
                const yyyy = rawDate.substring(0, 4);
                const mm = rawDate.substring(4, 6);
                const dd = rawDate.substring(6, 8);

                document.getElementById("enddt").innerHTML = `\${yyyy}.\${mm}.\${dd}`;
            } else {
                document.getElementById("enddt").innerHTML = rawDate; // 데이터가 이상할 경우 대비
            }

            const rawDatebgng = String(data.bgngdt); // "20260306"으로 변환

            if (rawDatebgng && rawDatebgng.length === 8) {
                const yyyy = rawDatebgng.substring(0, 4);
                const mm = rawDatebgng.substring(4, 6);
                const dd = rawDatebgng.substring(6, 8);

                document.getElementById("bgngdt").innerHTML = `\${yyyy}.\${mm}.\${dd}`;
            } else {
                document.getElementById("bgngdt").innerHTML = rawDatebgng; // 데이터가 이상할 경우 대비
            }



            ///////////////////////////////////////차트 시작

        ////도넛 차트/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            const cnCtx = document.getElementById('dnChart').getContext('2d');

            // 기존에 생성된 차트가 있으면 삭제 (오류 방지 핵심)
            if (dnChart) {
                dnChart.destroy();
            }

            // 차트 생성
            dnChart = new Chart(cnCtx, {
                type: 'doughnut',
                // 라이브러리 로드 후 전역 변수로 존재하는 ChartDataLabels를 플러그인 배열에 주입
                plugins: [ChartDataLabels],
                data: {
                    labels: ['대기', '진행', '완료', '보류', '지연'],
                    datasets: [{
                        data: [data.todoCnt, data.inProgressCnt, data.doneCnt, data.onHoldCnt, data.delayedCnt],
                        backgroundColor: [
                            '#dce1e6', // 대기 (라이트 블루)#03c3ec
                            '#696CFF', // 진행 (메인 블루)
                            '#71dd37', // 완료 #71dd37
                            '#8592A3', // 보류
                            '#ff3e1d'  // 지연
                        ],
                        borderWidth: 0,
                        hoverOffset: 8,
                        cutout: '70%'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false // 범례는 커스텀 HTML로 대체
                        },
                        tooltip: {
                            enabled: true
                        },
                        // datalabels 설정 (chartjs-plugin-datalabels 2.0.0 버전용)
                        datalabels: {
                            color: '#fff',
                            font: {
                                weight: 'bold',
                                size: 11
                            },
                            formatter: function(value) {
                                return value > 0 ? value : ''; // 0이면 표시 안함
                            }
                        }
                    }
                }
            });

            ////막대 차트/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            /* 같은 자료 씀
                    try {
                        const response = await axios.get("/myproject/chartLoad/" + variable);
                        const data = response.data; // 서버에서 받은 데이터 (예: {lowdone: 2, hightodo: 1, ...})
                        console.log("받은 데이터:", data);
            */
            // 2. 기존 차트가 있다면 파괴(destroy) - 이거 안 하면 차트 겹쳐서 나옵니다.
            if (barChart) {
                barChart.destroy();
            }

            // 3. 서버에서 받은 데이터를 차트 데이터 형식에 맞춰 매핑
            // ※ 키값이 없으면 0을 반환하도록 || 0 처리 필수
            const delayedData = [data.highdlyd || 0, data.middlyd || 0, data.lowdlyd || 0];
            const todoData    = [data.hightodo || 0, data.midtodo || 0, data.lowtodo || 0];
            const doneData    = [data.highdone || 0, data.middone || 0, data.lowdone || 0];

            // 4. 차트 생성
            const ctx = document.getElementById('barChart').getContext('2d');
            Chart.register(ChartDataLabels);

            barChart = new Chart(ctx, { // 1번에서 선언한 변수에 할당
                type: 'bar',
                data: {
                    labels: ['높음', '보통', '낮음'],
                    datasets: [
                        { label: '지연', data: delayedData, backgroundColor: '#ff3e1d', maxBarThickness: 30 },
                        { label: '진행', data: todoData, backgroundColor: '#696CFF', maxBarThickness: 30 },
                        { label: '완료', data: doneData, backgroundColor: '#71dd37', maxBarThickness: 30 }
                    ]
                },
                options: {
                    aspectRatio: 3,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    responsive: true,
                    scales: {
                        x: { stacked: true, beginAtZero: true,
                        },
                        y: {
                            stacked: true,
                            barPercentage: 0.3,
                            categoryPercentage: 0.7,
                        }
                    },
                    plugins: {
                        legend: { position: 'top' },
                        datalabels: {
                            color: '#fff', // 글자색
                            anchor: 'center', // 막대 안에서의 기준점
                            align: 'center', // 정렬
                            formatter: (value) => {
                                return value > 0 ? value : ''; // 0이면 표시 안함
                            },
                            font: {
                                weight: 'bold' // 글자 굵기
                            }
                        }
                    }
                },

            });
        } catch (err) {
            console.error("에러입니다", err);
        }
        ///////////////////////////////////////차트 끝//
    }



</script>