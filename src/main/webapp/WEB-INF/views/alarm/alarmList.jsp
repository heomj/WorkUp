<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<title>WORK UP 그룹웨어 - 알림 센터</title>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="ko_KR"/>
<style>
    :root {
        --bs-body-bg: #f5f5f9;
        --primary-color: #696CFF; /* 테마 색상 적용 */
        --primary-light: #e7e7ff;
        --unread-bg: #f4f4ff;
        --border-color: #d9dee3;
        --text-main: #566a7f;
        --text-dark: #32475c;
        --text-muted: #a1acb8;
        --white: #ffffff;
        /* 배경색 */
        --point-color: #7579ff;
        --bg-light: #f4f7fe;
        --text-dark: #1b2559;
        --text-muted: #a3aed0;
        --st-ongoing: #696cff;
        --st-delayed: #ff3e1d;
        --st-completed: #71dd37;
        --star-color: #ffb800;

    }
    body { background-color: var(--bg-light);  }
/*    body {
        font-family: 'Public Sans', sans-serif;
        background-color: var(--bs-body-bg);
        color: var(--text-main);
        margin: 0;
        padding: 0;
    }*/

    /* 알림 리스트 컨테이너 */
    .alarm-feed-container {
        /*max-width: 850px;
        margin: 3rem auto;*/
        margin: auto;
        min-width: 600px;
        max-width: 1200px;
        padding: 0 1.5rem;
    }

    .feed-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
/*        margin-bottom: 1.5rem;*/
    }

/*    .feed-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--text-dark);
        margin: 0;
    }*/

    /* 알림 카드 아이템 */
    .alarm-feed-item {
        position: relative;
        background: var(--white);
        border: 1px solid var(--border-color);
        border-radius: 0.5rem;
        padding: 1.25rem;
        margin-bottom: 1rem;
        transition: all 0.2s ease;
        display: flex;
        gap: 1.25rem;
        cursor: pointer;
        box-shadow: 0 2px 4px rgba(0,0,0,0.03);
    }

    .alarm-feed-item:hover {
        box-shadow: 0 4px 12px rgba(105, 108, 255, 0.15);
        border-color: var(--primary-color);
        transform: translateY(-1px);
    }

    .alarm-feed-item.is-hovered {
        box-shadow: 0 4px 12px rgba(105, 108, 255, 0.15);
        border-color: var(--primary-color);
        transform: translateY(-1px);
    }

    /* 읽지 않음 스타일 */
    .alarm-feed-item.unread {
        background-color: var(--white);
        border-left: 4px solid var(--primary-color);
    }

    .unread-dot {
        width: 8px;
        height: 8px;
        background: var(--primary-color);
        border-radius: 50%;
        position: absolute;
        top: 1.25rem;
        right: 1.25rem;
        box-shadow: 0 0 0 3px var(--primary-light);
    }

    /* 아바타 섹션 */
    .avatar-wrapper {
        position: relative;
        flex-shrink: 0;
    }

    /* 텍스트 영역 */
    .alarm-content {
        flex-grow: 1;
        overflow: hidden;
    }

    /* almMsg를 제목으로 사용 */
    .alarm-title {
        font-size: 1rem;
        font-weight: 700;
        color: var(--text-dark);
        margin-bottom: 0.35rem;
        display: block;
    }

    .alarm-detail {
        font-size: 0.9rem;
        color: var(--text-main);
        line-height: 1.5;
        margin-bottom: 0.5rem;
    }

    .alarm-time {
        font-size: 0.75rem;
        color: var(--text-muted);
        display: flex;
        align-items: center;
        gap: 0.25rem;
    }

    /* 액션 버튼 */
    .action-buttons {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: flex-end;
    }

    .btn-action {
        border: 1px solid var(--primary-color);
        background: transparent;
        padding: 4px 10px;
        border-radius: 4px;
        font-size: 0.75rem;
        font-weight: 600;
        color: var(--primary-color);
        transition: 0.2s;
        white-space: nowrap;
    }

    .btn-action:hover {
        background: var(--primary-color);
        color: #fff;
    }

    .btn-close-custom {
        background: transparent;
        border: none;
        color: var(--text-muted);
        cursor: pointer;
        padding: 4px;
        border-radius: 4px;
    }

    .btn-close-custom:hover {
        width: 26px;
        height: 26px;
        background-color: #fff0f0;
        color: #ff3e1d;
        border-radius: 100%;
    }
/* 전체 삭제 버튼 호버시 활성화할 호버 스타일 따로 지정*/
    .btn-close-custom.is-hovered {
        width: 26px;
        height: 26px;
        background-color: #fff0f0;
        color: red;
        border-radius: 100%;
        border : 1px solid ;
    }

    /* 유틸리티 클래스 */


    .btn-group-sm > .btn, .btn-sm {
        padding: 0.4375rem 0.75rem;
        font-size: 0.8125rem;
        border-radius: 0.375rem;
        background: #fff;
        border: 1px solid var(--border-color);
        color: var(--text-main);
        cursor: pointer;
    }
    .btn-group-sm > .btn, .btn-sm:hover {
        box-shadow: 0 4px 12px rgba(105, 108, 255, 0.15);
        border-color: var(--primary-color);
        transform: translateY(-1px);
        padding: 0.4375rem 0.75rem;
        font-size: 0.8125rem;
        border-radius: 0.375rem;
        background: #fff;
        border: 1px solid var(--border-color);
        color: var(--primary-color);
        cursor: pointer;
    }
/*프로필은 사진 사이즈가 제각기이므로 따로 설정*/
    .profile-box {
        width: 90px;        /* 원하는 크기로 고정 */
        height: 90px;       /* width와 똑같이 맞춰서 정사각형으로 만듦 */
        object-fit: cover;   /* 이게 핵심: 영역을 꽉 채우고 넘치는 건 자름 */
        object-position: top;/* 상단 기준 자르기 (center, bottom 등으로 조절 가능) */
        border-radius: 50%;  /* 원형으로 만들기 */
    }
</style>

<div id="alarm-list-view">
    <div class="feed-header">
<%--
        <div>
            <h3 class="feed-title">알람 센터</h3>
            <p style="color: var(--text-muted); font-size: 0.85rem; margin-top: 4px;">중요한 소식을 놓치지 마세요.</p>
        </div>
--%>


        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                    <span class="material-icons" style="color: #696cff; font-size: 32px;">notifications_none</span>

                    <div style="display: flex; align-items: baseline; gap: 8px;">
                        <span style="font-size: x-large; font-weight: 800;">알람 센터</span>
                        <span style="font-weight: normal; color: #717171; font-size: 15px;">| 최근 알람</span>
                    </div>
                </div>

                <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                    수신한 알람을 확인할 수 있는 페이지입니다.
                </div>
            </div>

        </div>
        <div style="display: flex; gap: 8px;">
            <button class="btn-sm" id="readAllbtn" onclick="updateAllStts('readAllAlarm')">
                <span
                        class="material-icons fs-6 v-align-middle" >mark_email_read</span> 모두 읽음
            </button>
            <button class="btn-sm" id="deleteAllBtn" onclick="updateAllStts('deleteAllAlarm')">
                <span
                        class="material-icons fs-6 v-align-middle">delete_outline</span> 전체 삭제
            </button>
        </div>
    </div>


    <div class="alarm-feed-container" id="mailListContainer">

        <%-- DB 데이터 반복문 --%>
        <c:if test="${empty alarmVOList}">
            <h3 class="feed-title " style="text-align: center;">새로운 소식이 없습니다.</h3>
            <br>
            <div  style="display: flex; justify-content: center;">

            <img src="/displayPrf?fileName=noalarmimg.png"  alt="NoAlarmImg" style="width:250px; height: auto; ">
            </div>
        </c:if>
        <c:forEach var="alarm" items="${alarmVOList}">
            <div class="alarm-feed-item ${alarm.almYn=='N'? 'unread':''}"
                 onclick="updateStts('readAlarm',${alarm.almRcvrNo}, '${alarm.almUrl}${alarm.almUrlVar}')">

                <c:if test="${alarm.almYn=='N'}"><div class="unread-dot"></div></c:if>

                <div class="avatar-wrapper">
                    <c:choose>
                        <%-- 1. 내 아바타 케이스 --%>
                        <c:when test="${alarm.almSndrIcon == 'myAva'}">
                            <img src="/avatar/displayAvt?fileName=${alarm.avtSaveNm}" class="rounded-circle" style="width:80px; height:auto;">
                        </c:when>

                        <%-- 2. 기본 아바타 케이스 --%>
                        <c:when test="${alarm.almSndrIcon == 'defaultAva'}">
                            <img src="/displayPrf?fileName=defaultimg.png"  class="rounded-circle" style="width:80px; height:auto;">
                        </c:when>

                        <%-- 3. 내 프로필 케이스 --%>
                        <c:when test="${alarm.almSndrIcon == 'myProfile'}">
                            <img src="/displayPrf?fileName=${alarm.empProfile}"class="profile-box" style=" border: #696CFF solid;">
                        </c:when>

                        <%-- 4. 기본 아이콘(확성기) 케이스 --%>
                        <c:when test="${alarm.almSndrIcon == 'defaultIcon'}">
                            <img src="/displayPrf?fileName=alarmdefault.png"  class="rounded-circle" style="width:80px; height:auto;">
                        </c:when>

                        <%-- 5. 마일리지(코인) 케이스 --%>
                        <c:when test="${alarm.almSndrIcon == 'mileage'}">
                            <img src="/displayPrf?fileName=coin.png"  class="rounded-circle" style="width:80px; height:auto;">
                        </c:when>

                        <%-- 6. 기타 예외 처리 --%>
                        <c:otherwise>
                            <img src="/displayPrf?fileName=alarmdefault.png"  class="rounded-circle" style="width:80px; height:auto;">
                        </c:otherwise>
                    </c:choose>


<%--                    <img src="/displayPrf?fileName=defaultimg.png"  class="rounded-circle" style="border-radius: 50%; width:100px; height:auto;">
                    <span class="category-icon"><span class="material-icons" style="font-size: 11px;">notifications</span></span>--%>
                </div>

                <div class="alarm-content">
                        <%-- almMsg를 제목으로 배치 --%>
                    <strong class="alarm-title">${alarm.almMsg}</strong>
                    <div class="alarm-detail">
                            ${alarm.almDtl}
                    </div>
                    <div class="alarm-time">
                        <span class="material-icons" style="font-size: 14px;">schedule</span>
                        <fmt:formatDate value="${alarm.almSndrTm}" pattern="yyyy.MM.dd HH:mm" />
                    </div>
                </div>

                <div class="action-buttons">
                    <button class="btn-close-custom" onclick="event.stopPropagation(); updateStts('deleteAlarm',${alarm.almRcvrNo})">
                        <span class="material-icons" style="font-size: 18px;">close</span>
                    </button>
                    <c:if test="${alarm.almYn=='N'}">
                        <button class="btn-action" onclick="event.stopPropagation(); updateStts('readAlarm',${alarm.almRcvrNo});">읽음</button>
                    </c:if>
                </div>
            </div>
        </c:forEach>

        <%-- 샘플: 결재 알림 --%>
<%--        <div class="alarm-feed-item unread">
            <div class="unread-dot"></div>
            <div class="avatar-wrapper">
                <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Chulsoo" width="48" height="48" style="border-radius: 50%;">
                <span class="category-icon" style="background-color: #71dd37;"><span class="material-icons" style="font-size: 11px;">check_circle</span></span>
            </div>
            <div class="alarm-content">
                <strong class="alarm-title">결재 승인 완료</strong>
                <div class="alarm-detail">
                    <span class="fw-bold" style="color:var(--text-dark)">김철수 팀장</span>님이 요청하신 <span class="text-primary fw-bold">'2026년 1분기 기획안'</span> 문서를 최종 승인하였습니다.
                </div>
                <div class="alarm-time"><span class="material-icons" style="font-size: 14px;">schedule</span> 12분 전</div>
            </div>
            <div class="action-buttons">
                <button class="btn-close-custom"><span class="material-icons" style="font-size: 18px;">close</span></button>
                <button class="btn-action">확인</button>
            </div>
        </div>--%>

        <%-- 샘플: 공지 알림 --%>
        <%--<div class="alarm-feed-item">
            <div class="avatar-wrapper">
                <div class="system-avatar bg-label-warning">
                    <span class="material-icons">campaign</span>
                </div>
            </div>
            <div class="alarm-content">
                <strong class="alarm-title">시스템 정기 점검 안내</strong>
                <div class="alarm-detail">
                    안정적인 서비스 제공을 위해 <span class="fw-bold">오늘 오후 6시부터 1시간 동안</span> 서버 점검이 진행될 예정입니다.
                </div>
                <div class="alarm-time"><span class="material-icons" style="font-size: 14px;">schedule</span> 2시간 전</div>
            </div>
            <div class="action-buttons">
                <button class="btn-close-custom"><span class="material-icons" style="font-size: 18px;">close</span></button>
            </div>
        </div>--%>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script>
    /*
    const updateStts = (updateStts, almRcvrNo) => {
        const data = {
            "updateStts": updateStts,
            "almRcvrNo": almRcvrNo
        };

        axios.post('/alarm/updateStts', data)
            .then(res => {
                if (res.data > 0) {
                    location.reload();
                }
            })
            .catch(err => console.error("에러 발생:", err));
    };
     */
    //개별요소 읽음 또는 삭제
    const updateStts = (updateStts, almRcvrNo, almUrl) => {

        const data = {
            "updateStts": updateStts,
            "almRcvrNo": almRcvrNo
        };

        axios.post('/alarm/updateStts', data)
            .then(res => {
                if(res.data > 0&& almUrl==null){
                    //삭제, 읽음했으면 새로고침
                    location.reload();
                } else if (res.data > 0&& almUrl!=null) {
                    location.href=almUrl;
                }
            })
            .catch(err => console.error("에러 발생:", err));
    };

    // 모두 읽음 또는 전체 삭제
    const updateAllStts=(updateStts)=>{

        console.log("변수 타입:", typeof updateStts);
        console.log("변수 내용:", updateStts);
        data = {
            "updateStts" : updateStts
        }


            axios.post('/alarm/updateAllStts', data, {
                headers : {"Content-Type": "application/json"}
            })
                .then(res => {
                    console.log("처리완료!", res.data);

                            location.reload()

                })
                .catch(err => console.error("에러 발생:", err));

    }

    /////////////////전체 처리 호버시 개별요소 모두 호버 ////////////////////
    //.btn-close-custom.is-hovered
    const allBtn = document.getElementById('deleteAllBtn');
    const subBtns = document.querySelectorAll('.btn-close-custom');

    allBtn.addEventListener('mouseenter', () => {
        subBtns.forEach(btn => btn.classList.add('is-hovered'));
    });

    allBtn.addEventListener('mouseleave', () => {
        subBtns.forEach(btn => btn.classList.remove('is-hovered'));
    });
    //.alarm-feed-item.is-hovered
    const readallBtn = document.getElementById('readAllbtn');
    const readsubBtns = document.querySelectorAll('.alarm-feed-item.unread');

    readallBtn.addEventListener('mouseenter', () => {
        readsubBtns.forEach(btn => btn.classList.add('is-hovered'));
    });

    readallBtn.addEventListener('mouseleave', () => {
        readsubBtns.forEach(btn => btn.classList.remove('is-hovered'));
    });


</script>