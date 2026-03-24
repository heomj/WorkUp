<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link href="https://cdn.jsdelivr.net/npm/gridstack@10.3.1/dist/gridstack.min.css" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet" />
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
        background-color: #fff;
        /*background-color: #696cff;*/
        color:#7F85FF;
        border: #A8ABFF solid 1px;
        border-radius: 5px;
        padding: 8px 16px;
        font-size: 0.875rem;
        font-weight: 500;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 6px;
        /*box-shadow: 0 2px 4px rgba(105, 108, 255, 0.4);*/
    }
    .btn-reset-layout:hover {
        background-color: #fff;
        color: #5f61e6;
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(105, 108, 255, 0.4);
    }
    .btn-reset-layout:active {

        transform: translateY(0);
    }
    /* 긴급공지 모달 전체 배경 */
	#urgentModal {
	    display: none;
	    position: fixed;
	    z-index: 9999;
	    /* 초기 위치 설정 */
	    left: 50px; 
	    top: 50px;
	    width: auto;
	    height: auto;
	    background: none; /* 배경 투명하게 */
	    backdrop-filter: none; /* 블러 제거 */
	}
	
	/* 전체 팝업 컨테이너 (그림자 및 테두리 선명하게) */
	.urgent-modal-content {
	    background-color: #fff;
	    width: 380px; /* 약간 넓게 */
	    border-radius: 12px;
	    /* 💡 더 깊고 선명한 그림자 효과 */
	    box-shadow: 0 15px 35px rgba(0,0,0,0.3); 
	    overflow: hidden;
	    /* 💡 빨강 테두리 대신 회색 테두리로 깔끔하게 */
	    border: 1px solid #d1d5db; 
	    cursor: move;
	    animation: fadeInSlide 0.4s ease-out; /* 등장 애니메이션 */
	}
	
	/* 💡 헤더 색감 변경: 강렬한 빨강 -> 페이지 헤더와 맞춘 다크 그레이 */
	.urgent-header {
	    background: #1e293b; /* 대덕인재개발원 상단 검은 바 느낌 */
	    padding: 15px;
	    text-align: center;
	    color: white;
	    border-bottom: 3px solid #f97316; /* 💡 주황색 포인트 라인 추가 */
	}
	
	/* URGENT 뱃지 스타일 */
	.urgent-badge {
	    background: rgba(249, 115, 22, 0.2); /* 주황색 반투명 배경 */
	    color: #fb923c; /* 연한 주황색 글씨 */
	    border: 1px solid rgba(249, 115, 22, 0.5);
	    padding: 3px 10px;
	    border-radius: 20px;
	    font-size: 0.75rem;
	    font-weight: 700;
	    display: inline-block;
	    letter-spacing: 1px;
	}
	
	/* 타이틀 스타일 (선명하게) */
	#urgentTitle {
	    margin: 8px 0 0;
	    font-weight: 800;
	    font-size: 1.2rem;
	    letter-spacing: -0.5px;
	    color: #fff;
	}
	
	/* 💡 본문 색감: 쌩까만색(#000) 대신 짙은 회색(#334155)으로 부드럽게 */
	.urgent-body {
	    padding: 30px 25px;
	    text-align: center;
	    color: #334155;
	    font-size: 1rem;
	    line-height: 1.7;
	}
	
	/* 하단 블랙 바 (이미지 스타일 유지하되 텍스트 가독성 높임) */
	.urgent-footer-bar {
	    background-color: #111; /* 아주 짙은 회색 */
	    color: #a1a1aa; /* 💡 글씨를 약간 회색조로 낮춰 부드럽게 */
	    padding: 10px 15px;
	    display: flex;
	    justify-content: space-between;
	    align-items: center;
	    font-size: 0.8rem;
	    font-weight: 500;
	    border-top: 1px solid #27272a;
	}
	
	/* 하단 버튼 스타일 */
	.footer-close-btn {
	    background: #3f3f46; /* 조금 더 밝은 회색 */
	    border: none;
	    color: white;
	    padding: 4px 12px;
	    border-radius: 6px;
	    cursor: pointer;
	    font-size: 0.75rem;
	    font-weight: 600;
	    transition: background 0.2s;
	}
	.footer-close-btn:hover {
	    background: #f97316; /* 💡 호버 시 주황색으로 변경 */
	}
	
	/* 등장 애니메이션 */
	@keyframes fadeInSlide {
	    from { opacity: 0; transform: translateY(-20px); }
	    to { opacity: 1; transform: translateY(0); }
	}
    /* 영롱한 그라데이션 메인 카드 */
    .main-attendance-card {
        background: linear-gradient(135deg, #696cff 0%, #8592ff 100%);
        color: #fff;
        padding:  12px 15px 5px 15px;
        border-radius: 15px;
        min-height: 360px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        box-shadow: 0 10px 20px rgba(105, 108, 255, 0.25);
        width: 100%;
        position: relative;
        overflow: hidden;
        border: none;
    }

    /* 카드 우측 상단 은은한 빛 효과 */
    .main-attendance-card::after {
        content: '';
        position: absolute;
        top: -20%;
        right: -10%;
        width: 150px;
        height: 150px;
        background: rgba(255, 255, 255, 0.15);
        border-radius: 50%;
        filter: blur(30px);
        pointer-events: none;
    }

    /* 내부 요소들 정밀 조정 */
    .main-attendance-card .time-display {
        font-size: 2.1rem;
        font-weight: 800;
        color: #fff;
        line-height: 1.1;
        letter-spacing: -0.5px;
    }

    .main-attendance-card .weather-temp {
        font-size: 1.6rem;
        font-weight: 800;
        letter-spacing: -0.5px;
    }

    /* 버튼 공통 스타일 (유리 질감 살짝 추가) */
    .btn-commute-custom {
        padding: 10px;
        font-size: 1rem;
        border-radius: 8px;
        font-weight: 700;
        transition: all 0.2s ease;
    }

    .btn-commute-custom:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
</style>


<div class="d-flex gap-4" style="align-items: flex-start; min-height: calc(100vh - 150px);">

    <div class="side-menu-container" style="width: 270px; min-width: 270px; flex-shrink: 0;">
        <div style="display:flex; justify-content: space-between; font-size: 1.6rem; font-weight: 800; color: var(--text-dark); display: flex; align-items: center; gap: 10px; margin-bottom: 10px;">
            </sapn><span class="material-icons" style="color: #7579FF; font-size: 32px;">grid_view</span>
            <span>Home</span>
            <button type="button" class="btn-reset-layout" onclick="resetLayout()">
                <span class="material-icons" style="font-size: 18px;">restart_alt</span>
                홈화면 초기화
            </button>
        </div>

            <%--    <h4 class="mb-0" style="font-weight: 700; font-size: xx-large; color: #566a7f;">
                    <span class="material-icons">grid_view</span>
                    Home
                </h4>--%>
        <div class="d-flex flex-column gap-3">
            <div class="dashboard-card main-attendance-card">
                <div>
                    today
                    <hr style="margin-top: 1px; margin-bottom: 15px;">
                    <div class="d-flex align-items-center gap-3" style=" margin-bottom: 15px; margin-left: 10px;">
                        <div class="icon-box bg-white bg-opacity-25 d-flex align-items-center justify-content-center" style="width: 55px; height: 55px; border-radius: 12px;">
                            <span class="material-icons" style="font-size: 32px;"><span id="skyicon"></span></span>
                        </div>
                        <div class="summary-info">
                            <p class="text-white-50 mb-0" style="font-size: 0.9rem; font-weight: 500;">대전광역시 날씨</p>
                            <h3 class="text-white mb-0 weather-temp">
                                <span id="temp"></span>°C <small class="fs-6 fw-normal" style="margin-left: 3px; opacity: 0.9;"><span id="skytext"></span></small>
                            </h3>
                        </div>
                    </div>

                    <div class="attendance-section" style="margin-top: 5px; padding: 20px 10px ;  border: #A9ABFF solid 1px; border-radius: 5%;">
                        <div class="mb-3">
                            <div class="text-white-50 small mb-1 fw-bold" style="font-size: 0.9rem; letter-spacing: 0.5px; padding-bottom: 5px;">PRESENT TIME</div>
                            <div id="real-time-clock" class="time-display" style="padding-bottom: 10px;  font-variant-numeric: tabular-nums;">12:00:00 PM</div>

                            <div class="d-flex align-items-center gap-2 mt-2" style="padding-bottom: 5px;">
                                <div id="work-status" class="badge bg-white text-primary fw-bold" style="font-size: 0.8rem; padding: 5px 10px; border-radius: 15px;">미출근 상태</div>
                                <div id="attendance-status" class="fw-bold text-white-50" style="font-size: 0.85rem;">상태 로딩 중...</div>
                            </div>
                        </div>

                        <div class="commute-btns d-grid" style="grid-template-columns: 1fr 1fr; gap: 10px;">
                            <button id="btn-checkin" class="btn btn-white text-primary btn-commute-custom" onclick="handleCommute('in')" style="background: #fff; border: none;">
                                <span class="material-icons" style="font-size: 1.1rem; vertical-align: middle; margin-right: 2px;">login</span> 출근
                            </button>
                            <button id="btn-checkout" class="btn btn-outline-white text-white btn-commute-custom" onclick="handleCommute('out')" style="border: 1.5px solid rgba(255,255,255,0.6);">
                                <span class="material-icons" style="font-size: 1.1rem; vertical-align: middle; margin-right: 2px;">logout</span> 퇴근
                            </button>

                        </div>
                    </div>
                </div>
            </div>

            <style>
                /* 1. 전체를 감싸는 영역 */
                .nav-card-wrapper {
                    display: flex;
                    flex-direction: column;
                    gap: 15px;
                    width: 100%;
                }

                /* 2. 결재/메일 버튼을 담는 한 줄 (Grid 활용) */
                .nav-card-row {
                    display: grid;
                    grid-template-columns: 1fr 1fr; /* 정확히 반반 */
                    gap: 15px; /* 버튼 사이 간격 */
                }
                /* 3. 버튼형 카드 스타일 */
                .nav-card.small-btn {
                    background: #fff;
                    padding: 10px 10px;
                    border-radius: 12px;
                    border: 1px solid #eef0f2;
                    cursor: pointer;
                    transition: 0.2s;

                    display: flex;
                    flex-direction: column;
                    align-items: center;      /* 가로축 중앙 정렬 */
                    justify-content: center;  /* 세로축 중앙 정렬 */
                    text-align: center;       /* 텍스트 자체 중앙 정렬 */
                    gap: 5px;                /* 아이콘과 글자 사이 간격 살짝 줄임 (취향껏 조절!) */
                    width: 100%;             /* 부모 너비에 꽉 차게 */
                }

                /* 텍스트 영역도 확실하게 중앙 정렬 */
                .nav-card.small-btn .summary-info {
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    width: 100%;
                }

                .nav-card.small-btn .summary-info p,
                .nav-card.small-btn .summary-info h3 {
                    margin: 0;
                    width: 100%;
                }

                .nav-card.small-btn:hover {
                    transform: translateY(-3px);
                    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
                }

                .nav-card.small-btn .summary-info p {
                    margin: 0;
                    font-size: 0.8rem;
                    color: #a1acb8;
                    font-weight: 600;
                }

                .nav-card.small-btn .summary-info h3 {
                    margin: 0;
                    font-size: 1.2rem;
                    font-weight: 800;
                    color: #566a7f;
                }

                /* 1. 기본 상태: 모든 애니메이션 설정을 여기서 한 번에 관리 🦾 */
                .nav-card.tall-card {
                    background: #fff;
                    padding: 20px;
                    border-radius: 12px;
                    border: 1px solid #eef0f2;
                    display: flex;
                    flex-direction: column;
                    min-height: 200px;
                    cursor: pointer;

                    /* 🎯 핵심: 속도를 0.3s 정도로 맞추고 cubic-bezier로 탄력을 줍니다 */
                    transition: transform 0.3s cubic-bezier(0.25, 1, 0.5, 1),
                    box-shadow 0.3s ease,
                    background-color 0.3s ease;
                    will-change: transform; /* 브라우저 하드웨어 가속 활성화 */
                }

                /* 2. 호버 효과: 불필요한 transition 중복 제거 🚀 */
                .nav-card.tall-card:hover {
                    transform: translateY(-2px) scale(1.02); /* 살짝 더 높이 띄워봤어! */
                    box-shadow: 0 12px 20px rgba(105, 108, 255, 0.15);
                }

                /* 3. 클릭 효과: 아주 짧은 찰나의 피드백만 전달 ⚡ */
                .nav-card.tall-card:active {
                    transform: translateY(-2px) scale(0.98);
                    /* active에는 긴 시간을 주지 않습니다. 0.1초면 충분! */
                    transition: transform 0.1s ease;
                }

            </style>

            <div class="nav-card-wrapper">
                <div class="nav-card-row">
                    <div class="nav-card small-btn" onclick="location.href='/approval/receiveAprvBoard'">
                        <div style="justify-content: center;  ">
                        <div class="icon-box" style=" margin-right:0;background-color: #fff2d6; color: #ffab00; width: 45px; height: 45px; border-radius: 10px; display: flex; align-items: center; justify-content: center;">
                            <span class="material-icons">pending_actions</span>
                        </div>
                        </div>
                        <div class="summary-info">
                            <p>결재 대기</p>
                            <h3 id="pendingAprv">${pendingTotal}건</h3>
                        </div>
                    </div>

                    <div class="nav-card small-btn" onclick="location.href='/email'">
                        <div class="icon-box" style="margin-right:0;background-color: #ffe0e0; color: #ff3e1d; width: 45px; height: 45px; border-radius: 10px; display: flex; align-items: center; justify-content: center;">
                            <span class="material-icons">mail</span>
                        </div>
                        <div class="summary-info">
                            <p>안읽은 메일</p>
                            <h3><span id="mailCntdash"></span>건</h3>
                        </div>
                    </div>
                </div>

                <div class="nav-card tall-card" onclick="location.href='/calendar/main'">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="icon-box" style="background-color: #d7f5fc; color: #03c3ec; width: 45px; height: 45px; border-radius: 10px; display: flex; align-items: center; justify-content: center;">
                            <span class="material-icons">calendar_today</span>
                        </div>
                        <div class="summary-info">
                            <p style="margin:0; font-size: 0.85rem; color: #a1acb8;">오늘의 일정</p>
                            <h3 id="todayScheduleCount" style="margin:0; font-size: 1.25rem; font-weight: 700; color: #566a7f;">0건</h3>
                        </div>
                    </div>

                    <div id="todayScheduleList" class="schedule-list mt-2" style="max-height: 180px; overflow-y: auto;">
                        <p style="font-size: 0.85rem; color: #ccc; text-align: center; margin-top: 20px;">일정을 불러오는 중...</p>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <div style="flex-grow: 1; min-width: 0;">
        <div class="grid-stack" id="main-grid">
            <div class="grid-stack-item" gs-id="attendance" gs-w="3" gs-h="4" gs-x="0"gs-y="0">
                <div class="grid-stack-item-content">
                    <div class="drag-header d-flex justify-content-between align-items-center">⠿ 팀 근태 현황
                    </div>
                    <div class="card-body-content">근태 현황을 불러오는 중입니다.</div>
                </div>
            </div>
            <div class="grid-stack-item" gs-id="project" gs-w="4" gs-h="4" gs-x="3"gs-y="0">
                <div class="grid-stack-item-content">
                    <div class="drag-header d-flex justify-content-between align-items-center">⠿ 진행중인 프로젝트
<sec:authentication property="principal.empVO.empRole" var="empRole" />
<c:if test="${empRole == '팀장'}">
                        <a href="/projectmanage" style="color: #8C8EFF; font-size: 0.1rem; text-decoration: none; background-color: #FFFFFF; border-radius: 3px; padding:1px 1px 0 3px; margin-right: 10px;">
                            <span class="material-symbols-outlined">send</span>
                        </a>
</c:if>
<c:if test="${empRole == '사원'}">
                            <a href="/myproject/list" style="color: #8C8EFF; font-size: 0.1rem; text-decoration: none; background-color: #FFFFFF; border-radius: 3px; padding:1px 1px 0 3px; margin-right: 10px;">
                                <span class="material-symbols-outlined">send</span>
                            </a>
</c:if>
                    </div>
                    <div class="card-body-content"></div>
                </div>
            </div>
            <div class="grid-stack-item" gs-id="task" gs-w="5" gs-h="4" gs-x="7"gs-y="0">
                <div class="grid-stack-item-content">
                    <div class="drag-header d-flex justify-content-between align-items-center">⠿ 내 일감
                        <a href="/myWork" style="color: #8C8EFF; font-size: 0.1rem; text-decoration: none; background-color: #FFFFFF; border-radius: 3px; padding:1px 1px 0 3px; margin-right: 10px;">
                            <span class="material-symbols-outlined">send</span>
                        </a>
                    </div>
                    <div class="card-body-content">일감 목록을 불러오는 중입니다.</div>
                </div>
            </div>
            <div class="grid-stack-item" gs-id="survey" gs-w="6" gs-h="3" gs-x="0"gs-y="4">
                <div class="grid-stack-item-content">
                    <div class="drag-header d-flex justify-content-between align-items-center">⠿ 설문
                        <a href="/survey/survey" style="color: #8C8EFF; font-size: 0.1rem; text-decoration: none; background-color: #FFFFFF; border-radius: 3px; padding:1px 1px 0 3px; margin-right: 10px;">
                            <span class="material-symbols-outlined">send</span>
                        </a>
                    </div>
                    <div class="card-body-content">최근설문을 불러오는 중입니다.</div>
                </div>
            </div>
            <div class="grid-stack-item" gs-id="notice" gs-w="6" gs-h="3" gs-x="6" gs-y="4">
			    <div class="grid-stack-item-content">
			        <div class="drag-header d-flex justify-content-between align-items-center" >
			            <span>⠿ 공지사항</span>
			            <a href="/notice/list" style="color: #8C8EFF; font-size: 0.1rem; text-decoration: none; background-color: #FFFFFF; border-radius: 3px; padding:1px 1px 0 3px; margin-right: 10px;">
                            <span class="material-symbols-outlined">send</span>
                        </a>
			        </div>
			        
			        <div class="card-body-content" style="padding: 10px; background: #fff; height: calc(100% - 41px); overflow-y: auto;">
			            <ul id="dashboardNoticeList" style="list-style: none; padding: 0; margin: 0;">
			                <li class="text-center py-3 text-muted">공지사항을 불러오는 중입니다...</li>
			            </ul>
			        </div>
			    </div>
			</div>
            <div class="grid-stack-item" gs-id="budget" gs-w="4" gs-h="4" gs-x="0"gs-y="8">
                <div class="grid-stack-item-content">
                    <div class="drag-header d-flex justify-content-between align-items-center">⠿ 부서 예산 소진율
                    </div>
                    <div class="card-body-content">예산 정보를 불러오는 중입니다.</div>
                </div>
            </div>
            <div class="grid-stack-item" gs-id="club" gs-w="8" gs-h="4" gs-x="4"gs-y="8">
                <div class="grid-stack-item-content">
                    <div class="drag-header d-flex justify-content-between align-items-center">⠿ 동호회 포토갤러리
                    </div>
                    <div class="card-body-content">사진을 불러오는 중입니다.</div>
                </div>
            </div>
        </div>
    </div>

</div>

<div id="urgentModal">
    <div class="urgent-modal-content" id="draggableContent">
        <div class="urgent-header">
            <div class="urgent-badge">🚨 URGENT</div>
            <h5 id="urgentTitle" style="margin: 5px 0 0; font-weight: 700; font-size: 1.1rem;"></h5>
        </div>
        
        <div class="urgent-body" style="padding: 20px; text-align: center; min-height: 100px;">
            <p id="urgentContent" style="color: #333; font-size: 0.95rem; margin: 0;"></p>
        </div>
        
        <div class="urgent-footer-bar">
            <div style="cursor: pointer;" onclick="hideUrgentToday()">
                <span>오늘 하루 다시 열람하지 않습니다.</span>
            </div>
            <button class="footer-close-btn" onclick="closeUrgentModal()">닫기</button>
        </div>
    </div>
</div>
<div class="modal fade" id="qrModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="width: 300px;">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.2);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold w-100 text-center" style="color: #566a7f;">출근 QR 인증</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center pt-4 pb-5">
                <div id="qrcode" class="d-inline-block p-3 bg-white shadow-sm rounded-3"></div>
                <p class="mt-4 mb-0 small text-muted fw-medium">카카오톡으로 QR을 스캔하여<br>본인 인증을 진행해 주세요.</p>
            </div>
        </div>
    </div>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gridstack@10.3.1/dist/gridstack-all.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

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
    
// --- 🚨 긴급공지사항 팝업 (플로팅 & 드래그 스타일) ---
    
    function getLoginUserId() {
        return document.getElementById('loginEmpId')?.value || 'guest';
    }
    
    function checkUrgentNotice() {
        const userId = getLoginUserId();
        const isHidden = localStorage.getItem('hideUrgentNotice_' + userId);
        const today = new Date().toISOString().split('T')[0];
    
        if (isHidden === today) return;
    
        axios.get('/notice/urgent') 
            .then(function (res) {
                if (res.data && res.data.ntcNo) {
                    document.getElementById('urgentTitle').innerText = res.data.ntcTtl;
                    document.getElementById('urgentContent').innerText = res.data.ntcCn;
                    
                    const modal = document.getElementById('urgentModal');
                    modal.style.display = 'block';
                    
                    // 팝업이 나타난 후 드래그 기능 활성화
                    initDraggablePopup();
                }
            })
            .catch(function (error) {
                console.error("긴급 공지 확인 실패:", error);
            });
    }
    
    function closeUrgentModal() {
        document.getElementById('urgentModal').style.display = 'none';
    }
    
    function hideUrgentToday() {
        const userId = getLoginUserId();
        const today = new Date().toISOString().split('T')[0];
        localStorage.setItem('hideUrgentNotice_' + userId, today);
        closeUrgentModal();
    }

    // 🖱️ 팝업 드래그 기능 구현
    function initDraggablePopup() {
        const modal = document.getElementById("urgentModal");
        const content = document.querySelector(".urgent-modal-content");
        
        let isDragging = false;
        let offset = { x: 0, y: 0 };

        // 헤더나 컨텐츠 클릭 시 드래그 시작
        content.addEventListener('mousedown', (e) => {
            // 버튼 클릭 시에는 드래그 되지 않도록 방지
            if (e.target.tagName === 'BUTTON') return;
            
            isDragging = true;
            offset.x = e.clientX - modal.offsetLeft;
            offset.y = e.clientY - modal.offsetTop;
            content.style.cursor = 'grabbing';
        });

        document.addEventListener('mousemove', (e) => {
            if (!isDragging) return;
            
            // 화면 밖으로 나가지 않도록 위치 계산
            modal.style.left = (e.clientX - offset.x) + 'px';
            modal.style.top = (e.clientY - offset.y) + 'px';
            modal.style.margin = '0'; // 초기 중앙 정렬 해제
        });

        document.addEventListener('mouseup', () => {
            isDragging = false;
            if(content) content.style.cursor = 'move';
        });
    }

    // 페이지 로드 시 실행
    document.addEventListener('DOMContentLoaded', checkUrgentNotice);
    // ------------------------------------------------
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
             
           /* if (confirm("대시보드 배치를 초기 상태로 되돌리시겠습니까?")) {*/
                // 모든 위젯을 지우고 백업된 데이터로 다시 로드
                grid.load(initialLayout);
                // 만약 차트(Chart.js)가 로드 후에 깨진다면 다시 그려주는 로직이 필요할 수 있습니다.
                // 위에서 만든 budgetDonutChart가 있다면 여기서 다시 초기화 함수를 호출하세요.
                console.log("레이아웃이 초기화되었습니다.");
                location.reload();
           /* }*/
        };
    });


    document.addEventListener("DOMContentLoaded", async function(){

        ///////////////////////////////////////////////////////////////////////////////////안읽은 메일
        axios.get("/email/mailAlarm").then(res => {
                console.log("메일알람 - 안읽은 메일(헤더알람) 정보 :",res.data)
                mails=res.data; //메일 알람 정보
            let guns =mails.length;
            console.log("메일 건수",guns);
                const mailCntdash=document.getElementById("mailCntdash")
            mailCntdash.innerHTML=guns;
            }
        ).catch(e=> console.error("에러난 경우", e))
        ///////////////////////////////////////////////////////////////////////////////////안읽은 메일 끝
        ///////////////////////////////////////////////////////////////////////////////////날씨정보 가져오기
        // 1시간 전 데이터부터 탐색
        let hourOffset = 1;

        while (hourOffset <= 12) { // 최대 12시간 전까지 탐색

            const now = new Date();
            now.setHours(now.getHours() - hourOffset);
            // 1. YYYYMMDD 형식 생성
            const year = now.getFullYear();
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const day = String(now.getDate()).padStart(2, '0');
            const baseDate = `\${year}\${month}\${day}`;

            // 2. HHMM 형식 생성
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const baseTime = `\${hours}\${minutes}`;

            const data = {
                //발급받은 API키
                "serviceKey" : "",
                "dataType" : "JSON",
                "base_date" :baseDate,
                "base_time" :baseTime,
                //오류동 위도 경도
                "nx": "68",
                "ny": "100"
            }

            // 기온, 날씨데이터 가져오기
            try {
                const [res1, res2] = await Promise.all([
                    axios.get("http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst", {params: data}),
                    axios.get("http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst", {params: data})
                ]);

                // 데이터가 있는지 확인 (resultCode가 '00'일 때만)
                if (res1.data.response.header.resultCode === '00'&&res2.data.response.header.resultCode === '00') {
                    console.log("성공! 데이터를 찾았습니다:", hourOffset, "시간 전 데이터");

                    // 데이터 처리 로직 (기온, 날씨 정보 탐색)
                    processData(res1.data.response.body.items, res2.data.response.body.items);

                    return; // 데이터를 찾았으면 루프 종료
                }
            } catch (err) {
                console.error(hourOffset + "시간 전 시도 실패:", err.message);
            }

            hourOffset++; // 실패 시 1시간 더 과거로 이동
        }

    })// end DOMContentLoaded

    // 데이터 처리 로직 (기온, 날씨 정보 탐색)
    function processData(temperature, sky){
        //console.log("temperature 왔나요?", temperature);
        //console.log("sky 왔나요?", sky);
        //배열을 객체를 unwrap
        const temperatureList = Array.isArray(temperature) ? temperature : [temperature];
        const skyList = Array.isArray(sky) ? sky : [sky];

        //console.log("temperatureList 왔나요?", temperatureList[0].item);
        //console.log("skyList 왔나요?", skyList[0].item);

        const temperatureInfo = temperatureList[0].item.find(item => item.category === 'T1H');
        const skyInfo = skyList[0].item.find(item => item.category === 'SKY');
        const skyInfo2 = skyList[0].item.find(item => item.category === 'PTY');

        console.log("기온", temperatureInfo.obsrValue);//기온
        console.log("1맑음 3구름많음 4흐림 :", skyInfo.fcstValue);//1맑음 3구름많음 4흐림
        console.log("0강수없음 1비 3눈 :", skyInfo2.fcstValue);//0강수없음 1비 3눈

        document.getElementById("temp").innerHTML = temperatureInfo.obsrValue;

        if(skyInfo2.fcstValue==0){
            if(skyInfo.fcstValue==1) {
                document.getElementById("skyicon").innerHTML = "wb_sunny";
                document.getElementById("skytext").innerHTML = "맑음";
            }else if(skyInfo.fcstValue==3){
                document.getElementById("skyicon").className = "material-symbols-outlined";
                document.getElementById("skyicon").innerHTML = "partly_cloudy_day";
                document.getElementById("skytext").innerHTML = "구름많음";
            }else if(skyInfo.fcstValue==4){
                document.getElementById("skyicon").innerHTML = "cloud";
                document.getElementById("skytext").innerHTML = "흐림";
            }
        }else if(skyInfo2.fcstValue==1){
            document.getElementById("skyicon").innerHTML = "grain";
            document.getElementById("skytext").innerHTML = "비";
        }else if(skyInfo2.fcstValue==2){
            document.getElementById("skyicon").innerHTML = "ac_unit";
            document.getElementById("skytext").innerHTML = "눈";
        }
    }// end 데이터 처리 로직 (기온, 날씨 정보 탐색)
    ///////////////////////////////////////////////////////////////////////////////////날씨정보 가져오기 끝

    ///////////////////////////////////////////////////////////////////////////////////출퇴근 위젯로직 시작
    let qrModalInstance;
    let checkInterval;

    document.addEventListener('DOMContentLoaded', function() {
        const btnCheckIn = document.getElementById('btn-checkin');
        const btnCheckOut = document.getElementById('btn-checkout');

        // 1. 실시간 시계 작동 🦾
        function updateClock() {
            const now = new Date();
            const options = { 
                hour: '2-digit', 
                minute: '2-digit', 
                second: '2-digit', 
                hour12: true 
            };
            document.getElementById('real-time-clock').textContent = now.toLocaleTimeString('en-US', options);
        }
        setInterval(updateClock, 1000);
        updateClock();

        // 2. 모달 초기화
        const qrModalEl = document.getElementById('qrModal');
        if (qrModalEl) qrModalInstance = new bootstrap.Modal(qrModalEl);

        // 3. 상태 새로고침 (페이지 로드 시)
        refreshAttendanceStatus();

        // 4. QR 모달 이벤트 (Attendance.jsp 로직 그대로 이식)
        if (qrModalEl) {
            qrModalEl.addEventListener('show.bs.modal', function () {
                const qrContainer = document.getElementById("qrcode");
                qrContainer.innerHTML = ""; 
                
                const restApiKey = '';
                const redirectUri = '';
                const kakaoAuthUrl = `https://kauth.kakao.com/oauth/authorize?client_id=\${restApiKey}&redirect_uri=\${redirectUri}&response_type=code`;
                
                new QRCode(qrContainer, { text: kakaoAuthUrl, width: 180, height: 180 });

                if (checkInterval) clearInterval(checkInterval);
                checkInterval = setInterval(() => {
                    axios.get("/attendance/checkStatus")
                        .then(res => {
                            if (res.data.status === "SUCCESS") {
                                // 1. 반복 중단 (가장 중요!)
                                clearInterval(checkInterval);
                                
                                // 2. QR 모달 닫기
                                qrModalInstance.hide();
                                
                                // 3. 출근 성공 알람 (AppAlert 적용)
                                // 아이콘 추천: 'rocket_launch' (활기찬 시작)
                                AppAlert.autoClose(
                                    '출근 완료!',
                                    `<b style="color:#696CFF">인증 성공!</b> 오늘 하루도 힘내봅시다!`,
                                    'rocket_launch', 
                                    'success',
                                    2000
                                ).then(() => { // (알람 리팩토링)
                                    // 4. 알람이 닫힌 후 상태 갱신
                                    refreshAttendanceStatus(); 
                                });
                            }
                        })
                        .catch(err => {
                            console.error("QR Check Error:", err);
                            // 에러가 너무 많이 나면 인터벌을 멈춰주는 로직을 추가할 수도 있어 형!
                        });
                }, 2000);
            });

            qrModalEl.addEventListener('hidden.bs.modal', () => {
                if (checkInterval) clearInterval(checkInterval);
            });
        }
    });
    // 마일리지계산
    function getMileageInfo(inTimeStr) {
        if (!inTimeStr) return { mileage: 0, workTime: "0.0" };

        const now = new Date();
        // 버튼에서 긁어온 "09:00:00"에 오늘 날짜를 붙여서 날짜 객체 생성
        const today = new Date().toISOString().split('T')[0]; 
        const inTime = new Date(`\${today} \${inTimeStr.replace(/-/g, '/')}`);
        
        const diffHrs = (now - inTime) / (1000 * 60 * 60); // 차이(시간 단위)

        let mileage = 0;
        if (diffHrs >= 8) {
            // 8시간 만근 시 100점 + 초과 시간당 10점
            mileage = 100 + Math.floor((diffHrs - 8) * 10);
        } else {
            // 8시간 미만은 시간당 10점 (예: 7.8시간 = 78점)
            mileage = Math.floor(diffHrs * 10);
        }

        return {
            mileage: mileage,
            workTime: diffHrs.toFixed(1)
        };
    }
    // 출퇴근 버튼 핸들러
    async function handleCommute(type) {
        if (type === 'in') {
            qrModalInstance.show();
        } else {
            const attendBtn = document.getElementById('btn-checkin'); 
            const inTimeStr = attendBtn ? attendBtn.innerText.replace(/[^0-9:]/g, '').trim() : "";


            // 2. 마일리지 계산 (위에서 만든 함수 호출하거나 로직 그대로 쓰기)
            const info = getMileageInfo(inTimeStr); 

            // 1. 퇴근 확인 컨펌창
            const result = await AppAlert.confirm(
                '퇴근하시겠습니까?',
                `오늘 하루도 정말 고생 많으셨습니다!<br>` +
                `적립 예정 마일리지: <b style="color:#696CFF;">\${info.mileage} M</b>`,
                '퇴근 완료',
                '취소',
                'door_back', // 아이콘 추천: 퇴근 느낌의 문 아이콘
                'primary'    // 테마: 보라색 포인트
            ); // (알람 리팩토링)

            if (result.isConfirmed) {
                try {
                    // 4. 퇴근 API 호출
                    const res = await axios.post('/attendance/end');
                    
                    if (res.data.status === 'SUCCESS') {
                        // 2. 퇴근 성공 자동 닫힘 알람 (1.2초)
                        await AppAlert.autoClose(
                            '퇴근 완료!',
                            res.data.message,
                            'task_alt',   // 아이콘 추천: 완료 체크 아이콘
                            'success',    // 테마: 초록색 성공
                            1200          // 시간: 1.2초
                        ); // (알람 리팩토링)

                        // 6. [Giga-Combo] 바로 로그아웃 물어보기 🥊 (AppAlert 커스텀 버전)
                        AppAlert.confirm(
                            '로그아웃 하시겠습니까?',          // title
                            '떠나기 전 오늘 업무를 모두 마무리하셨나요?',     // text (동료분의 디테일!)
                            '로그아웃',                       // confirmButtonText
                            '취소',                           // cancelButtonText
                            'logout',                         // iconName (추천값)
                            'warning'                         // theme
                        ).then(async (result) => {
                            if (result.isConfirmed) {
                                try {
                                    // 1. 실제 로그아웃 진행
                                    await axios.post('/logout');

                                    // 2. 로그아웃 완료 알람 (Auto Close)
                                    await AppAlert.autoClose(
                                        '로그아웃 완료',
                                        '정상적으로 로그아웃 되었습니다.',
                                        'check_circle',
                                        'success',
                                        1500
                                    );

                                    // 3. 메인으로 이동
                                    location.href = "/";
                                    
                                } catch (err) {
                                    console.error("로그아웃 실패:", err);
                                    // 에러 발생 시 처리
                                    AppAlert.error(
                                        '오류',
                                        '로그아웃 처리 중 문제가 발생했습니다.',
                                        null,
                                        'error_outline'
                                    );
                                }
                            } else {
                                // 취소 눌러서 남아있을 경우 상태만 갱신 🦾
                                refreshAttendanceStatus(); 
                            }
                        });
                    }
                } catch (err) {
                    console.error("퇴근 처리 중 에러:", err);
                    Swal.fire('에러', '처리 중 오류가 발생했습니다.', 'error');
                }
            }
        }
    }   

    // 서버에서 데이터 끌어와서 UI 업데이트
    function refreshAttendanceStatus() {
        axios.get('/attendance/getTodayDetail')
            .then(res => {
                const data = res.data;
                const att = data.attendance;

                if (att) {
                    // 출근 버튼 업데이트
                    updateBtnToTime('btn-checkin', att.attCheckIn2, '출근', 'login');
                    if (att.attCheckIn2) document.getElementById('btn-checkin').disabled = true;

                    // 퇴근 버튼 업데이트
                    updateBtnToTime('btn-checkout', att.attCheckOut2, '퇴근', 'logout');
                    if (att.attCheckOut2) document.getElementById('btn-checkout').disabled = true;

                    // 상태 텍스트 & 배지 업데이트 
                    const workStatus = document.getElementById('work-status');
                    const attStatus = document.getElementById('attendance-status');
                    
                    if (att.attCheckOut2) {
                        workStatus.textContent = "업무 종료";
                        workStatus.className = "badge bg-secondary text-white fw-bold";
                        attStatus.textContent = "퇴근 완료";
                    } else if (att.attCheckIn2) {
                        workStatus.textContent = "업무 중";
                        workStatus.className = "badge bg-info text-white fw-bold";
                        attStatus.textContent = "정상 출근";
                    }
                } else {
                    document.getElementById('attendance-status').textContent = "미출근 상태";
                }
            })
            .catch(err => console.error("기록 로드 실패", err));
    }

    function updateBtnToTime(id, time, defaultText, icon) {
        const target = document.getElementById(id);
        if (target) {
            target.innerHTML = `<span class="material-icons" style="font-size: 1.1rem; vertical-align: middle; margin-right: 2px;">\${icon}</span> \${time ? time : defaultText}`;
        }
    }
// 팀 근태 위젯 업데이트 함수
function updateTeamAttendance() {
    axios.get('/attendance/teamStatus') 
        .then(res => {
            const teamData = res.data;
            
            // (우리개발팀 근태 현황)
            const header = document.querySelector('[gs-id="attendance"] .drag-header');
            if (header && teamData.length > 0) {
                header.innerText = `⠿ \${teamData[0].deptNm} 근태 현황`;
            }

            //  리스트 컨테이너 선택
            const contentBody = document.querySelector('[gs-id="attendance"] .card-body-content');
            if (!contentBody) return;

            let html = "";

            teamData.forEach(member => {
				let battery = ""; 
				let displayStatus = member.attWorkStts || '결근';


				if (displayStatus === '출근') {
					battery = `<span class="material-symbols-outlined" style="color:#696cff;">battery_android_frame_6</span>`;
				} else if (displayStatus.includes('반차')) {
					battery = `<span class="material-symbols-outlined" style="color:#03c3ec;">battery_android_frame_bolt</span>`; 
				} else if (displayStatus === '외출') {
					battery = `<span class="material-symbols-outlined" style="color:#ffab00;">logout</span>`;
				} else if (displayStatus === '출장') {
					battery = `<span class="material-symbols-outlined" style="color:#696cff;">battery_android_frame_share</span>`;
				} else if (displayStatus === '일반') {
					battery = `<span class="material-symbols-outlined" style="color:#03c3ec;">battery_android_frame_plus</span>`; 
					displayStatus = "휴가"; 
				} else if (displayStatus === '병가') {
					battery = `<span class="material-symbols-outlined" style="color:#ff3e1d;">battery_android_frame_1</span>`;
				} else if (displayStatus === '공가') {
					battery = `<span class="material-symbols-outlined" style="color:#EA3323;">battery_android_frame_shield</span>`;
				} else if (displayStatus === '퇴근') {
					battery = `<span class="material-symbols-outlined" style="color:#ffab00;">battery_android_frame_1</span>`;
				} else {
				
					battery = `<span class="material-symbols-outlined" style="color:#ff3e1d;">battery_android_frame_3</span>`;
				}


				html += `
					<div style="display: flex; justify-content: space-between; padding: 10px; border-bottom: 1px solid #ccc;">
						<div>
							<strong style="color: #566a7f;">\${member.empNm}</strong> 
							<span style="color: #a1acb8; margin-left: 5px;">\${member.empJbgd}</span>
						</div>
						
						<div style="display: flex; align-items: center; gap: 5px;">
							\${battery}
							<strong style="color: #566a7f; font-size: 11px;">\${displayStatus}</strong>
						</div>
					</div>
				`;
			});
            contentBody.innerHTML = html;
            // 리스트가 길어질 수 있으니 부모에 스크롤만 살짝 부여
            contentBody.style.overflowY = "auto";
            contentBody.style.height = "calc(100% - 45px)";
        })
        .catch(err => console.error("Team Status Error", err));
}

document.addEventListener('DOMContentLoaded', () => {
    updateTeamAttendance();
    updateTeamProject();
});

///////////////////////////////////////////////////////////////////////////////////출퇴근 위젯로직 끝


// 진행중인 프로젝트 List 불러오기
function updateTeamProject () {

    //  리스트 컨테이너 선택
    const projectBody = document.querySelector('[gs-id="project"] .card-body-content');
    if (!projectBody) return;

    let html = "";

    axios.get("/adpjt/dashboardProject")
    .then(res => {
        console.log(res.data);

        const projectList = res.data;

        if (projectList && projectList.length > 0) {
        

        projectList.forEach(project => {
            html += `
                <div onclick="location.href='/myproject/detail/\${project.projNo}'" 
                    style="padding: 8px 12px; margin-bottom: 4px; border-radius: 6px; 
                            background: #f9fafb; display: flex; flex-direction: column; gap: 2px;
                            cursor: pointer; transition: background 0.2s;"
                    onmouseover="this.style.background='#f0f2f5'" 
                    onmouseout="this.style.background='#f9fafb'">       
                    <div style="display: flex; justify-content: space-between; align-items: baseline;">
                        <strong style="color: #44546a; font-size: 14px;">
                            \${project.projTtl}
                        </strong>
                        <span style="color: #696cff; font-size: 12px; font-weight: 600;">
                            \${project.projPrgrt}%
                        </span>
                    </div>

                    <div style="display: flex; color: #a1acb8; font-size: 11px; gap: 8px;">
                        <span>
                           기간: \${project.projBgngDt ? project.projBgngDt.split('T')[0] : ''} 
                            ~ \${project.projEndDt ? project.projEndDt.split('T')[0] : ''}
                        </span>
                    </div>
                </div>`;
        })}
        else {
            html = `
                <div style="padding: 10px; text-align: center; color: #a1acb8; font-size: 15px; background: #f9fafb; border-radius: 6px;">
                    진행 중인 프로젝트가 없습니다.
                </div>`;
        }

        projectBody.innerHTML = html;

    })
    .catch(err => {
        console.error(err);
    })

}



// ----------------------------------------------------------------------------------------------------
// [설문] 참여 가능한 설문 리스트 로드
function updateSurveyList() {
    const surveyBody = document.querySelector('[gs-id="survey"] .card-body-content');
    if (!surveyBody) return;

    axios.get("/survey/dashboardList")
        .then(res => {
            const list = res.data;
            let html = "";

            if (!list || list.length === 0) {
                html = `
                    <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: #a1acb8;">
                        <span class="material-icons" style="font-size: 3rem; margin-bottom: 10px; opacity: 0.3;">assignment_turned_in</span>
                        <p style="font-size: 0.9rem;">참여할 설문이 없습니다.</p>
                    </div>
                    `;
            } else {
                list.forEach(item => {
                    const displayTitle = item.srvyCn || "제목 없는 설문";

                    // 익명 여부 배지
                    const anonTag = item.srvyAnon === 'Y' ?
                        `<span style="background: #f1f5f9; color: #64748b; font-size: 10px; padding: 2px 6px; border-radius: 4px; margin-left: 6px;">익명</span>` : "";

                    const startDt = item.srvyBgngDt ? item.srvyBgngDt.split('T')[0] : '';
                    const endDt = item.srvyEndDt ? item.srvyEndDt.split('T')[0] : '';

                            // onmouseover: 마우스를 올렸을 때 실행
                            // onmouseout: 마우스를 뗐을 때 실행
                    html += `
                        <div style="padding: 12px; margin-bottom: 8px; border-radius: 12px; border: 1px solid #f0f2f4;
                                    background: #fff; display: flex; align-items: center; justify-content: space-between;
                                    transition: transform 0.2s, box-shadow 0.2s;"
                             onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 8px rgba(0,0,0,0.05)';"
                             onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='none';">

                            <div style="flex: 1; min-width: 0; cursor: pointer;" onclick="location.href='/survey/survey'">
                                <div style="display: flex; align-items: center; margin-bottom: 4px;">
                                    <strong style="color: #566a7f; font-size: 14px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                        \${displayTitle}
                                    </strong>
                                    \${anonTag}
                                </div>
                                <div style="font-size: 11px; color: #a1acb8; display: flex; align-items: center; gap: 10px;">
                                    <span style="display: flex; align-items: center; gap: 2px;">
                                        <span class="material-icons" style="font-size: 13px; color: #fcc419;">monetization_on</span>
                                        \${item.srvyMlg} P
                                    </span>
                                    <span style="display: flex; align-items: center; gap: 2px;">
                                        <span class="material-icons" style="font-size: 13px;">calendar_today</span>
                                        \${startDt} ~ \${endDt}
                                    </span>
                                </div>
                            </div>

                            <button onclick="location.href='/survey/survey'"
                                    style="margin-left: 10px; padding: 6px 12px; background: #696cff; color: #fff; border: none;
                                           border-radius: 6px; font-size: 12px; font-weight: 700; cursor: pointer; flex-shrink: 0;">
                                참여
                            </button>
                        </div>`;
                });
            }
            surveyBody.innerHTML = html;
            surveyBody.style.padding = "10px";
            surveyBody.style.overflowY = "auto";
            surveyBody.style.height = "calc(100% - 45px)";
        })
        .catch(err => console.error("Survey Widget Error:", err));
}

// 초기화 리스트에 추가
document.addEventListener('DOMContentLoaded', () => {
    if (typeof updateTeamAttendance === 'function') updateTeamAttendance();
    if (typeof updateTeamProject === 'function') updateTeamProject();
    updateSurveyList();
});


// ---------------------------------------------------------------------------------------------------
// [일정]
function updateTodaySchedule() {
    const scheduleContainer = document.getElementById('todayScheduleList');
    const countBadge = document.getElementById('todayScheduleCount');
    if (!scheduleContainer) return;

    axios.get("/calendar/todayList")
        .then(res => {
            const list = res.data;
            let html = "";

            countBadge.innerText = `\${list.length}건`;      // 오늘의 일정 건수

            if (!list || list.length === 0) {
                html = `
                    <div style="text-align: center; color: #adb5bd; padding: 20px 0;">
                        <p style="font-size: 0.8rem; margin: 0;">오늘 예정된 일정이 없습니다.</p>
                    </div>`;
            } else {
                list.forEach(item => {
                    let typeColor = "#03c3ec";      // 일정 종류별 색상
                    const timeDisp = (item.calAllday === 'Y') ? "종일" : `\${item.calBgngTm || ''}`;  // 종일 여부에 따른 시간 표시

                    html += `
                        <div style="padding: 10px; border-left: 3px solid \${typeColor}; background: #f8f9fa; margin-bottom: 8px; font-size: 0.85rem; border-radius: 0 4px 4px 0;">
                            <span style="font-weight: 700; color: #566a7f; margin-right: 5px;">\${timeDisp}</span>
                            <span style="color: #444; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: inline-block; max-width: 140px; vertical-align: bottom;">
                                \${item.calTtl}
                            </span>
                        </div>`;
                });
            }
            scheduleContainer.innerHTML = html;
        })
        .catch(err => {
            console.error("Today Schedule Error:", err);
            scheduleContainer.innerHTML = '<p style="font-size: 0.8rem; color: #ff3e1d; text-align: center;">로딩 실패</p>';
        });
}

document.addEventListener('DOMContentLoaded', function() {
    updateTodaySchedule(); // 오늘의 일정 호출
    GetTeamBudget(); //예산도 불러와주세요..!
    GetPhotoGallery(); //동호회도요 불러와주세요..!
});

// ---------------------------------------------------------------------------------------------------


// 부서 예산 소진율!!!💵💵💵💵💵💵💵💵💵💵💵💵💵💵💵--------------------------------------------------

    function GetTeamBudget() {
        // 1. 예산 컨테이너 선택
        const budgetBody = document.querySelector('[gs-id="budget"] .card-body-content');
        if (!budgetBody) return;

        let budgetHtml = "";

        // 예산 데이터 가져오기(예산 사용자 컨트롤러 없어서 동호회에서 가져왔어요)
        axios.get("/club/dashboardBudget")
            .then(res => {
                console.log("부서 예산 데이터:", res.data);

                const data = res.data;

                // 데이터가 없거나 배정액이 0원인 경우 방어 로직
                if (!data || data.bgtAmt === 0) {
                    budgetHtml = `
                    <div style="padding: 20px; text-align: center; color: #a1acb8; font-size: 14px; background: #f9fafb; border-radius: 6px;">
                        배정된 부서 예산이 없습니다.
                    </div>`;

                    // 만들어진 HTML을 화면에 꽂아넣기
                    budgetBody.innerHTML = budgetHtml;
                    return;
                }

                // 3. 금액 및 소진율 계산
                const totalAmt = data.bgtAmt || 0;
                const usedAmt = data.bgtExcn || 0;
                const remainAmt = totalAmt - usedAmt;
                const burnRate = ((usedAmt / totalAmt) * 100).toFixed(1);

                // 값담기
                budgetHtml = `
                <div style="display: flex; flex-direction: row; align-items: center; justify-content: center; height: 100%; padding: 10px;">

                    <div style="position: relative; width: 156px; height: 156px;"> <canvas id="budgetDonutChart"></canvas>
                        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center;">
                            <span style="font-size: 1.5rem; font-weight: 800; color: ${burnRate >= 90 ? '#ef4444' : '#566a7f'};"> \${burnRate}%
                            </span>
                        </div>
                    </div>

                    <div style="flex: 1; max-width: 200px; font-size: 0.9rem; color: #566a7f; margin-left: 25px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 8px; padding-bottom: 8px; border-bottom: 1px dashed #eee;">
                            <span style="color: #a1acb8; font-weight: 600;">총 예산</span>
                            <strong style="font-size: 0.95rem;">\${totalAmt.toLocaleString()} 원</strong>
                        </div>
                        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                            <span style="color: #ef4444; font-weight: 600;">사용액</span>
                            <strong style="color: #ef4444;">\${usedAmt.toLocaleString()} 원</strong>
                        </div>
                        <div style="display: flex; justify-content: space-between;">
                            <span style="color: #10b981; font-weight: 600;">잔여액</span>
                            <strong style="color: #10b981;">\${remainAmt.toLocaleString()} 원</strong>
                        </div>
                    </div>




                </div>
            `;

                budgetBody.innerHTML = budgetHtml;

                // Chart.js를 이용해 도넛 차트 렌더링
                const ctx = document.getElementById('budgetDonutChart').getContext('2d');
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['사용액', '잔여액'],
                        datasets: [{
                            data: [usedAmt, remainAmt],
                            backgroundColor: ['#fc735a', '#f1f5f9'],
                            borderWidth: 0,
                            hoverOffset: 5
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '75%',
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return ' ' + context.label + ': ' + context.raw.toLocaleString() + '원';
                                    }
                                }
                            }
                        }
                    }
                });
            })
            .catch(err => {
                console.error("대시보드 예산 로딩 에러:", err);
                // 에러 시에도 빈 변수 활용
                budgetHtml = '<p style="text-align: center; color: #ff3e1d; margin-top: 20px;">예산 정보를 불러오지 못했습니다.</p>';
                budgetBody.innerHTML = budgetHtml;
            });
    }// 함수 끝


// 부서 예산 소진율!!!💵💵💵💵💵💵💵💵💵💵💵💵💵💵💵--------------------------------------------------

// 동호회 포토 갤러리!!!📷📷📷📷📷📷--------------------------------------------------
    function GetPhotoGallery() {
        // 동호회 사진 컨테이너 선택
        const clubBody = document.querySelector('[gs-id="club"] .card-body-content');
        if (!clubBody) return;

        let clubHtml = "";

        // 백엔드에서 최근 올라온 동호회 사진 3~5개 정도를 가져온다고 가정합니다.
        // 백엔드에서 최근 올라온 동호회 사진 리스트(VO)를 가져옵니다.
        axios.get("/club/dashboardPhotos")
            .then(res => {
                const photoList = res.data;

                // 1. 데이터가 없을 때 방어 로직
                if (!photoList || photoList.length === 0) {
                    clubHtml = `
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #a1acb8; background: #f9fafb; border-radius: 12px;">
                        <p>최근 등록된 동호회 활동 사진이 없습니다.</p>
                    </div>`;
                    clubBody.innerHTML = clubHtml;
                    return;
                }

                // 2. 캐러셀 내부 아이템 조립 시작
                let carouselIndicators = "";
                let carouselItems = "";

                photoList.forEach((photo, index) => {
                    const activeClass = index === 0 ? "active" : "";

                    // 🌟 ERD/VO 매핑: 파일 저장명을 이용한 이미지 경로 설정
                    const imageUrl = `\${photo.thumbnailSaveNm}`;
                    const title = photo.clubBbsTtl;
                    const clubName = photo.clubNm;
                    const clubNo = photo.clubNo;

                    // 세로형 원형 점(Dot) 인디케이터 생성
                    carouselIndicators += `
                        <button type="button" data-bs-target="#clubCarousel" data-bs-slide-to="\${index}" class="\${activeClass}" aria-label="Slide \${index + 1}"
                                style="width: 8px !important; height: 8px !important; border-radius: 50%; background-color: #fff; margin: 5px 0 !important; border: none !important; padding: 0 !important;"></button>
                    `;

                    // 개별 슬라이드 아이템 생성
                    carouselItems += `
                    <div class="carousel-item \${activeClass}" style="height: 100%; cursor: pointer;" onclick="location.href='/club/\${clubNo}'">
                        <img src="/upload\${imageUrl}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 12px;" alt="동호회 사진">
                        <div style="position: absolute; bottom: 0; left: 0; width: 100%; padding: 40px 20px 15px; background: linear-gradient(transparent, rgba(0,0,0,0.8)); border-radius: 0 0 12px 12px;">
                            <span class="badge mb-1" style="background-color: #696cff; font-size: 0.8rem; opacity: 0.9;">\${clubName}</span>
                            <h6 class="text-white mb-0 fw-bold" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">\${title}</h6>
                        </div>
                    </div>
                `;
                });

                // 3. 전체 레이아웃 (좌: 캐러셀 / 우: 고정 링크) 조립
                clubHtml = `
                <div style="display: flex; flex-direction: row; gap: 20px; height: 100%; padding: 5px;">

                    <div style="flex: 6; border-radius: 12px; overflow: hidden; position: relative; box-shadow: 0 4px 12px rgba(0,0,0,0.08);"
                         id="clubCarousel" class="carousel slide carousel-fade" data-bs-ride="carousel">

                        <div class="carousel-indicators" style="position: absolute; top: 0; bottom: 0; right: 15px; left: auto; margin: 0; display: flex; flex-direction: column; justify-content: center;">
                            \${carouselIndicators}
                        </div>

                        <div class="carousel-inner" style="height: 100%;">
                            \${carouselItems}
                        </div>
                    </div>

                    <div style="flex: 4; display: flex; flex-direction: column; justify-content: center; gap: 10px;">
                        <h6 style="color: #566a7f; font-weight: 800; margin-bottom: 5px; font-size: 0.95rem;"> 동호회 바로가기</h6>

                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px; background: #f8fafc; border-radius: 10px; cursor: pointer; transition: 0.2s;"
                             onclick="location.href='/club/1'" onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='#f8fafc'">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 35px; height: 35px; background: #e0e7ff; color: #4f46e5; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                                    <span class="material-icons" style="font-size: 18px;">brightness_3</span>
                                </div>
                                <strong style="color: #334155; font-size: 0.85rem;">천문 동호회 <span style="font-size: 0.7rem; color: #4f46e5; background: #e0e7ff; padding: 2px 6px; border-radius: 4px; margin-left: 4px; font-weight: 800;">아스트로</span></strong>
                            </div>
                            <span class="material-icons" style="font-size: 16px; color: #cbd5e1;">chevron_right</span>
                        </div>

                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px; background: #f8fafc; border-radius: 10px; cursor: pointer; transition: 0.2s;"
                             onclick="location.href='/club/2'" onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='#f8fafc'">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 35px; height: 35px; background: #fef3c7; color: #d97706; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                                    <span class="material-icons" style="font-size: 18px;">menu_book</span>
                                </div>
                                <strong style="color: #334155; font-size: 0.85rem;">독서 동호회 <span style="font-size: 0.7rem; color: #d97706; background: #fef3c7; padding: 2px 6px; border-radius: 4px; margin-left: 4px; font-weight: 800;">페이지</span></strong>
                            </div>
                            <span class="material-icons" style="font-size: 16px; color: #cbd5e1;">chevron_right</span>
                        </div>

                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px; background: #f8fafc; border-radius: 10px; cursor: pointer; transition: 0.2s;"
                             onclick="location.href='/club/3'" onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background='#f8fafc'">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <div style="width: 35px; height: 35px; background: #dcfce7; color: #16a34a; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                                    <span class="material-icons" style="font-size: 18px;">landscape</span>
                                </div>
                                <strong style="color: #334155; font-size: 0.85rem;">등산 동호회 <span style="font-size: 0.7rem; color: #16a34a; background: #dcfce7; padding: 2px 6px; border-radius: 4px; margin-left: 4px; font-weight: 800;">피크</span></strong>
                            </div>
                            <span class="material-icons" style="font-size: 16px; color: #cbd5e1;">chevron_right</span>
                        </div>

                    </div>
                </div>
                `;

                // 4. 최종 결과물 화면에 꽂기!
                clubBody.innerHTML = clubHtml;

                // 5. [중요] Bootstrap 캐러셀 엔진 가동
                const carouselElement = document.getElementById('clubCarousel');
                if (carouselElement && typeof bootstrap !== 'undefined') {
                    new bootstrap.Carousel(carouselElement, {
                        interval: 3500, // 3.5초 간격으로 전환
                        ride: 'carousel',
                        pause: 'hover' // 마우스 올리면 잠시 멈춤
                    });
                }
            })
            .catch(err => {
                console.error("동호회 위젯 에러:", err);
                clubBody.innerHTML = '<p style="text-align: center; color: #ff3e1d;">갤러리를 불러오지 못했습니다.</p>';
            });
    }



// 동호회 포토 갤러리!!!📷📷📷📷📷📷--------------------------------------------------

// 나의업무!!!🧑‍💼🧑‍💼🧑‍💼🧑‍💼🧑‍💼🧑‍💼🧑‍💼--------------------------------------------------------
// 진행 중인 내 일감 List 불러오기
function updateMyTask() {
    // 1. 내 일감 컨테이너 선택 (gs-id="task" 인 녀석)
    const taskBody = document.querySelector('[gs-id="task"] .card-body-content');
    if (!taskBody) return;

    let html = "";

    // 2. 내 일감 전용 엔드포인트 호출 (컨트롤러에서 만들어둔 URL로 수정!)
    axios.get("/mywork/dashboardMyTask") 
    .then(res => {
        const taskList = res.data;

        if (taskList && taskList.length > 0) {
            taskList.forEach(task => {
            // 동료의 프로젝트 카드 스타일 (padding 8px 12px, radius 6px, 컬러 #44546a 등)을 그대로 적용
            html += `
                <div onclick="location.href='/myWork?taskNo=\${task.taskNo}'" 
                    style="padding: 8px 12px; margin-bottom: 4px; border-radius: 6px; 
                            background: #f9fafb; display: flex; flex-direction: column; gap: 2px;
                            cursor: pointer; transition: background 0.2s;"
                    onmouseover="this.style.background='#f0f2f5'" 
                    onmouseout="this.style.background='#f9fafb'">       
                    
                    <div style="display: flex; justify-content: space-between; align-items: baseline;">
                        <strong style="color: #44546a; font-size: 14px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 75%;">
                            \${task.taskTtl}
                        </strong>
                        <span style="color: #696cff; font-size: 12px; font-weight: 600;">
                            \${task.taskPrgrt}%
                        </span>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <div style="display: flex; color: #a1acb8; font-size: 11px; gap: 8px;">
                            <span>기한: \${task.taskEndDt ? task.taskEndDt.split('T')[0] : '기한 없음'}</span>
                        </div>
                        <span style="font-size: 10px; color: #696cff; font-weight: 700;">
                            \${task.taskStts}
                        </span>
                    </div>
                </div>`;
        });
        } else {
            // 데이터 없을 때의 스타일도 동료의 'padding 10px, radius 6px'에 맞춤
            html = `
                <div style="padding: 10px; text-align: center; color: #a1acb8; font-size: 15px; background: #f9fafb; border-radius: 6px;">
                    현재 진행 중인 일감이 없습니다.
                </div>`;
        }

        taskBody.innerHTML = html;
    })
    .catch(err => {
        console.error("일감 로드 실패!", err);
        taskBody.innerHTML = "<div style='text-align:center; color:red; font-size:12px; padding:10px;'>데이터 로드 중 오류 발생</div>";
    });
}

// 페이지 로드 시 바로 실행!
document.addEventListener('DOMContentLoaded', updateMyTask);
// 나의업무!!!🧑‍💼🧑‍💼🧑‍💼🧑‍💼🧑‍💼🧑‍💼🧑‍💼--------------------------------------------------------


document.addEventListener('DOMContentLoaded', function() {
    getDashboardNotice(); // 대시보드 로드 시 실행
});

function getDashboardNotice() {
    // 최신 공지사항 5개를 가져오기 위해 size를 5로 설정
    const data = { 
        currentPage: 1, 
        size: 5, 
        ntcStts: "", 
        keyword: "" 
    };

    axios.post('/notice/listAxios', data)
        .then(res => {
            const list = res.data.content;
            const noticeUl = document.getElementById('dashboardNoticeList');

            if (!list || list.length === 0) {
                noticeUl.innerHTML = '<li class="text-center py-3 text-muted">등록된 공지사항이 없습니다. 🔍</li>';
                return;
            }

            let html = "";
            list.forEach(n => {
                // 날짜 포맷팅 (YYYY-MM-DD)
                let dateDisplay = "";
                if (n.ntcDt) {
                    const d = new Date(n.ntcDt);
                    dateDisplay = `\${d.getFullYear()}-\${String(d.getMonth() + 1).padStart(2, '0')}-\${String(d.getDate()).padStart(2, '0')}`;
                }

                // 공지 타입별 뱃지 스타일링 (작성하신 스타일과 통일)
                let badgeClass = "bg-secondary";
                if (n.ntcStts === '긴급') badgeClass = "bg-danger";
                else if (n.ntcStts === '중요') badgeClass = "bg-warning";

                html += `
                    <li onclick="location.href='/notice/detail?ntcNo=\${n.ntcNo}'" 
                        style="display: flex; justify-content: space-between; align-items: center; padding: 10px 5px; border-bottom: 1px solid #f2f2f2; cursor: pointer;"
                        onmouseover="this.style.backgroundColor='#f9f9f9'" 
                        onmouseout="this.style.backgroundColor='#fff'">
                        
                        <div style="display: flex; align-items: center; gap: 8px; flex: 1; min-width: 0;">
                            <span class="badge \${badgeClass}" style="font-size: 0.7rem; padding: 3px 7px; color:#fff; border-radius: 4px;">\${n.ntcStts}</span>
                            <span style="font-size: 0.9rem; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #333;">
                                \${n.ntcTtl || ''}
                            </span>
                        </div>
                        
                        <span style="font-size: 0.8rem; color: #999; margin-left: 10px; white-space: nowrap;">
                            \${dateDisplay}
                        </span>
                    </li>
                `;
            });

            noticeUl.innerHTML = html;
        })
        .catch(err => {
            console.error("대시보드 공지사항 로드 실패:", err);
            document.getElementById('dashboardNoticeList').innerHTML = '<li class="text-center py-3 text-danger">데이터 로딩 실패</li>';
        });
}


</script>