<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
    .page-wrapper { padding: 0.5rem 1.5rem; }
    /* 식단표 컨테이너 스타일 */
    .meal-container {
      	width: 780px;
        max-width: 100%;
        margin: 0 auto;
        height: 850px;
        border-radius: 0.625rem;
        overflow: hidden;
        border: 1px solid #eceef1;
        display: flex;
        justify-content: center; 
        background-color: #fff;
        overflow: hidden;
        margin-top:-30px;
    }
    .meal-iframe { 
        width: 780px;
        height: 120%;
        border: none;
        transform: scale(0.9);
        transform-origin: top center; 
        margin-top: -35px;
    }
    
    /* 탭 버튼 */
    .nav-pills .nav-link {
        color: #697a8d;
        background: #fff;
        margin-right: 8px;
        border: 1px solid #eceef1;
        margin-bottom: 10px;
    }
    .nav-pills .nav-link.active { background-color: #696cff !important; color: #fff; margin-bottom: 1rem !important; }
    
    /* 카드 너비 조정 */
    .meal-card-custom { width: 1000px; margin: 0 auto; }
    .page-header { text-align: center; margin-bottom: 1rem !important; }
    #pills-tab { justify-content: center; }
    .card-body {  padding: 1rem !important; }
</style>

<div class="page-wrapper">
    <div class="d-flex justify-content-between align-items-center mb-4" style="margin-left:-22px; margin-top:-6px;">
        <div>
            <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                <span class="material-icons" style="color: #696cff; font-size: 32px;">restaurant</span>
                <div style="display: flex; align-items: baseline; gap: 8px;">
                    <span style="font-size: x-large; font-weight: 800;">오늘의 메뉴</span>
                </div>
            </div>
            <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                구내식당의 건강하고 맛있는 주간 메뉴 안내를 위한 페이지입니다.
            </div>
        </div>
    </div>
</div>

    <div class="container-fluid">
        <div class="page-header mb-4">
            <h1 class="page-title h3 fw-bold">📅 월간 식단표</h1> 
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card shadow-sm meal-card-custom">
                    <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                        <h5 class="mb-0 fw-semibold">식단 일정 조회</h5>
                        <span class="badge bg-light text-primary border">
                            <i class="material-icons align-middle" style="font-size:16px;">info</i> 
                            Google Spread Sheet 실시간 연동
                        </span>
                    </div>
                    <div class="card-body">
                        <ul class="nav nav-pills mb-4" id="pills-tab">
                            <%
                                int currentMonth = 3;
                                for(int i=2; i<=5; i++) {
                            %>
                            <li class="nav-item">
                                <button class="nav-link <%= (i == currentMonth) ? "active" : "" %>" 
                                        onclick="loadMeal('<%= i %>월')">
                                    <%= i %>월
                                </button>
                            </li>
                            <% } %>
                        </ul>

                        <div class="meal-container">
                            <iframe id="mealFrame" class="meal-iframe" 
                                    src="">
                            </iframe>
                        <%--
                            4월

                        --%>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const mealRanges = {
        '2월': 'A1:G18', '3월': 'G1:M18', '4월': 'M1:S18', '5월': 'S1:Y18',
    };
    const baseUrl = "";

    function loadMeal(month) {
        const range = mealRanges[month];
        document.getElementById('mealFrame').src = baseUrl + "&range=" + range;
        const buttons = document.querySelectorAll('.nav-link');
        buttons.forEach(btn => {
            if(btn.innerText.trim() === month) btn.classList.add('active');
            else btn.classList.remove('active');
        });
    }

    window.onload = function() {
                loadMeal('3월');
            };
</script>