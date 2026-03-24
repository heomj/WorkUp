<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <title>NexFlow | 혁신적인 업무 협업 플랫폼</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>

    <link rel="stylesheet" href="/css/home.css">

    <!--  임시 파비콘 -->
    <link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/images/test.png">

</head>
<body>

    <div class="hero-wrapper">
        <div class="bg-circle circle-1"></div>
        <div class="bg-circle circle-2"></div>

        <a href="#" style="position: absolute; top: 30px; left: 40px; z-index: 1000;">
            <img src="images/icon.png" alt="로고" style="width: 80px;">
        </a>

        <div class="container">

            <div class="row align-items-center py-5">
                <div class="col-lg-6 hero-text animate__animated animate__fadeInUp">
                    <h1>업무의 <span>완벽한 흐름</span><br>결정의 시간까지.</h1>
                    <p>
                        복잡함은 덜어내고 본질에만 집중하는 가장 스마트한 방법.<br>
                        WORKUP은 당신의 팀이 더 직관적으로 소통하고 결정할 수 있도록 <br>설계된 차세대 협업 플랫폼입니다.
                    </p>
                    <button class="btn-start" onclick="location.href='${pageContext.request.contextPath}/login'">시작하기</button>
                </div>

                <div class="col-lg-6">
                    <div class="hero-visual">

                        <div class="layer layer-stats">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <i class="material-icons text-primary">trending_up</i>
                                <small class="fw-bold">업무 효율성</small>
                            </div>
                            <h4 class="mb-0 text-primary">+24.8%</h4>
                            <small class="text-muted">지난달 대비 증가</small>
                        </div>

                     <div class="layer layer-main text-center">
                        <div class="mb-3 d-flex justify-content-between align-items-center">
                            <span class="badge rounded-pill bg-light text-dark px-3">System Online</span>
                            <i class="material-icons text-muted">more_horiz</i>
                        </div>

                        <div style="height: 180px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px;">
                            <svg width="200" height="150" viewBox="0 0 200 150" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M40 110H160" stroke="#666CFF" stroke-width="2" stroke-opacity="0.1"/>
                                <path d="M40 85H160" stroke="#666CFF" stroke-width="2" stroke-opacity="0.1"/>
                                <path d="M40 60H160" stroke="#666CFF" stroke-width="2" stroke-opacity="0.1"/>
                                
                                <path d="M50 110C70 110 80 40 110 50C140 60 140 30 155 25" stroke="#FF9F43" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                                
                                <circle cx="110" cy="50" r="6" fill="#666CFF"/>
                                <circle cx="155" cy="25" r="6" fill="#9B9EFE"/>
                                
                                <rect x="60" y="90" width="12" height="20" rx="2" fill="#666CFF" fill-opacity="0.4"/>
                                <rect x="85" y="75" width="12" height="35" rx="2" fill="#666CFF" fill-opacity="0.6"/>
                                <rect x="135" y="80" width="12" height="30" rx="2" fill="#FF9F43" fill-opacity="0.8"/>
                            </svg>
                        </div>




                        <div class="mt-2 row">
                            <div class="col-4 border-end"><h5 class="mb-0 fw-bold">15</h5><small class="text-muted">Pending</small></div>
                            <div class="col-4 border-end"><h5 class="mb-0 fw-bold">08</h5><small class="text-muted">Completed</small></div>
                            <div class="col-4"><h5 class="mb-0 fw-bold">12</h5><small class="text-muted">Messages</small></div>
                        </div>
                    </div>

                        <div class="layer layer-users">
                            <div class="d-flex align-items-center gap-3">
                                <div class="rounded-circle bg-secondary p-2"><i class="material-icons text-white">notifications_active</i></div>
                                <div>
                                    <div class="fw-bold" style="font-size: 0.9rem;">신규 결재 요청</div>
                                    <small class="text-muted">개발팀 - 주간 보고서</small>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <section class="py-5 bg-white">
        <div class="container py-5">
    <div class="row g-5">
        <div class="col-md-4">
            <div class="icon-box"><i class="material-icons">flash_on</i></div>
            <h3>압도적 효율</h3>
            <p class="text-muted">클릭 단 두 번으로 완성되는 결재 라인과 실시간 알림 시스템으로 의사결정의 병목 현상을 해소합니다.</p>
        </div>

        <div class="col-md-4">
            <div class="icon-box" style="background: #FF9F43;"><i class="material-icons">groups</i></div>
            <h3>스마트 협업 공간</h3>
            <p class="text-muted">회의실 예약부터 화상회의, 실시간 설문까지 모든 협업 도구를 하나의 플랫폼에서 자유롭게 활용하세요.</p>
        </div>

        <div class="col-md-4">
            <div class="icon-box" style="background: #28C76F;"><i class="material-icons">devices</i></div>
            <h3>유연한 업무 환경</h3>
            <p class="text-muted">장소와 장치의 제약 없이 사무실의 모든 기능을 그대로. <br>언제 어디서나 팀원들과 긴밀하게 연결됩니다.</p>
        </div>
    </div>
</div>
    </section>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>