<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="/js/common-alert.js"></script>


<style>
    :root {
        --point-color: #7579ff;
        --bg-light: #f4f7fe;
        --text-dark: #1b2559;
        --text-muted: #a3aed0;
        --st-ongoing: #696cff;
        --st-delayed: #ff3e1d;
        --st-completed: #71dd37;
        --star-color: #ffb800;
    }

    body { background-color: var(--bg-light);
        /*  
     font-family: 'Pretendard', sans-serif; color: var(--text-dark);
 */}
    .shop-container { width: 100%; display: flex; flex-direction: column; }

    /* 📊 상단 요약 카드 */
    /*.status-summary-container { display: flex; gap: 20px; padding: 20px 60px 30px 60px; }*/
    .status-card {
        flex: 1; background: #fff; padding: 22px 25px; border-radius: 22px;
        display: flex; align-items: center; gap: 15px; box-shadow: 0 10px 20px rgba(0,0,0,0.02);
        border: 1px solid #f0f3ff;
    }
    .status-icon-circle { width: 48px; height: 48px; border-radius: 14px; display: flex; align-items: center; justify-content: center; }
    .st-info { display: flex; align-items: center; gap: 6px; }
    .st-label { font-size: 0.85rem; color: var(--text-muted); font-weight: 600; }
    .st-count { font-size: 1.3rem; font-weight: 800; color: var(--text-dark); letter-spacing: -0.5px; }

    /* 📁 카테고리 탭 & 검색바 영역 */
    .filter-wrapper { display: flex; justify-content: space-between; align-items: flex-end; padding: 0 60px; }
    .tab-container { display: flex; gap: 5px; align-items: flex-end; }
    .category-tab {
        border: none; background: #e0e5f2; color: #707eae; padding: 10px 25px;
        font-size: 0.95rem; font-weight: 700; border-radius: 12px 12px 0 0;
        transition: 0.3s; cursor: pointer; height: 40px;
    }
    .category-tab.active {
        background: #fff; color: var(--point-color); height: 48px;
        box-shadow: 0 -5px 10px rgba(0,0,0,0.02);
    }

    /* 🔍 프로젝트명 검색창 스타일 */
    .prj-search-box {
        background: #fff; border-radius: 15px; padding: 5px 15px;
        display: flex; align-items: center; border: 1.5px solid #f0f3ff;
        margin-bottom: 10px; width: 300px; transition: 0.3s;
    }
    .prj-search-box:focus-within { border-color: var(--point-color); box-shadow: 0 5px 15px rgba(117,121,255,0.1); }
    .prj-search-box input { border: none; outline: none; font-size: 0.9rem; padding: 8px; width: 100%; color: var(--text-dark); }
    .prj-search-box .material-icons { color: var(--text-muted); }

    /* 🗂️ 프로젝트 카드 레이아웃 */
    .shop-content-box { background: #ffffff; margin: 0 60px 60px 60px; padding: 35px; border-radius: 0 25px 25px 25px; min-height: 400px; }
    .project-card {
        background: #fff; border: 1px solid #f0f3ff; border-radius: 25px;
        position: relative; transition: 0.3s; overflow: visible !important;
    }
    .project-card:hover { border-color: var(--point-color); transform: translateY(-5px); box-shadow: 0 12px 30px rgba(117,121,255,0.1); }
    .project-card.important { border: 2px solid #ffedb8; background: #fffdf7; }

    .card-top-header { display: flex; align-items: center; gap: 8px; margin-bottom: 15px; }
    .btn-star { cursor: pointer; border: none; background: none; padding: 0; display: flex; align-items: center; }
    .btn-star .material-icons { font-size: 24px; color: #e0e5f2; transition: 0.2s; }
    .btn-star.active .material-icons { color: var(--star-color); }
    .status-badge { padding: 5px 12px; font-size: 11px; font-weight: 700; border-radius: 20px; line-height: 1.2; }

    /* 🔍 팀원 검색 및 태그 UI */
    .search-result-list {
        position: absolute; width: 100%; z-index: 1050; background: white;
        border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        max-height: 200px; overflow-y: auto; border: 1px solid #f0f3ff; display: none;
    }
    .search-item { padding: 10px 15px; cursor: pointer; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid #f8f9fa; }
    .member-tag {
        background: var(--point-color); color: white; padding: 4px 12px;
        border-radius: 20px; font-size: 13px; display: flex; align-items: center; gap: 8px;
    }

    .progress { height: 8px; background-color: #f0f3ff; border-radius: 10px; }
    .progress-bar { border-radius: 10px; background: var(--point-color); }
    .avatar-sm { width: 32px; height: 32px; border-radius: 50%; border: 2px solid #fff; margin-left: -10px; background: #e0e5f2; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: bold; }
    .form-control { border-radius: 12px; border: 1.5px solid #f0f3ff; padding: 12px; background: #f8faff; }
</style>

<div class="shop-container">
    <div class="inventory-header" style="display: flex; justify-content: space-between; align-items: center ">
        <div class="header-left">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                        <span class="material-icons" style="color: #696cff; font-size: 32px;">videocam</span>

                        <div style="display: flex; align-items: baseline; gap: 8px;">
                            <span style="font-size: x-large; font-weight: 800;">화상회의</span>
                        </div>
                    </div>

                    <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                        실시간 화상회의에 참여할 수 있는 페이지 입니다. 회의 개설과 삭제는 팀장님만 할 수 있습니다.
                    </div>
                </div>

            </div>

<%--            <div style="font-size: 1.6rem; font-weight: 800; color: var(--text-dark); display: flex; align-items: center; gap: 10px;">
                <span class="material-icons" style="color: var(--point-color); font-size: 32px;">videocam</span> 화상회의
            </div>--%>
        </div>
        <sec:authentication property="principal.empVO.empRole" var="empRole" />
        <c:if test="${empRole == '팀장'}">
            <button class="btn btn-primary shadow-sm" style="background: var(--point-color); border:none; border-radius:15px; padding: 12px 25px; font-weight:700;" data-bs-toggle="modal" data-bs-target="#createProjectModal">
                + 새 회의 생성
            </button>
        </c:if>

    </div>
    <div class="status-summary-container" id="roomList">
    <c:if test="${empty roomList}">


        <h3 class="feed-title " style="text-align: center;">현재 진행 중인 화상회의가 없습니다.</h3>
        <br>
        <div  style="display: flex; justify-content: center;">

            <img src="/displayPrf?fileName=noalarmimg.png"  alt="NoAlarmImg" style="width:250px; height: auto; ">
        </div>


<%--
        <h4 class="feed-title">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;현재 진행 중인 화상회의가 없습니다.</h4>
        <br>
        <div style="display: flex; width: 70%; justify-content: flex-start;">

            <img src="/displayPrf?fileName=noalarmimg.png"  alt="NoAlarmImg" style="width:250px; height: auto; margin-left: 50%; margin-top: 10%">
        </div>
--%>

    </c:if>
    <c:forEach items="${roomList}" var="prj">


            <div class="status-card">
                <div class="status-icon-circle" style="background: #efefff; color: var(--st-ongoing);"><span class="material-icons">check_circle</span></div>
                <div class="st-info"><span class="st-count">${prj.roomTitle}</span><span class="st-label">${prj.startDate}</span><span class="st-unit"></span></div>
                <button type="button" class="btn btn-primary shadow-sm" style="background: var(--point-color); border-color:var(--point-color);  font-weight:700;" data-bs-toggle="modal" data-bs-target="#showRoomModal"
                        data-bs-url="${prj.roomId}"> 회의실 입장 </button>
                <c:if test="${empRole == '팀장'}">
                <button type="button" class="btn btn-secondary shadow-sm"
                        style="background:white; border-color: var(--point-color); color : var(--point-color); font-weight:700;"
                        onclick="deleteOnlineMeeting('${prj.roomId}')"> 회의실 삭제 </button>
                </c:if>
            </div>
    </div>
    </c:forEach>
</div>
</div>

<div class="modal fade" id="createProjectModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content shadow-lg">
            <div class="modal-header border-0 p-4 pb-0">
                <h5 class="fw-bold">
                    <span class="material-icons align-middle me-2" style="color:var(--point-color)">add_circle</span>화상회의 생성</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row g-3">
                    <div class="col-12">
                        <label class="small fw-bold text-muted mb-1">방 제목</label>
                        <input type="text" class="form-control" id="roomTitleValue" placeholder="제목을 입력하세요">
                    </div>
                    <div class="col-12">
                        <label class="small fw-bold text-muted mb-1">방 접속 url설정</label>
                        <input type="text" class="form-control" id="roomUrlId" placeholder="url을 설정하세요">
                    </div>
                    <%--<div class="col-6">
                        <label class="small fw-bold text-muted mb-1">시작일</label>
                        <input type="date" class="form-control"></div>--%>
                    <%--<div class="col-6">
                        <label class="small fw-bold text-muted mb-1">종료 예정일</label>
                        <input type="date" class="form-control"></div>--%>
                    <%--<div class="col-12 position-relative">
                    <label class="small fw-bold text-muted mb-1">팀원 검색 (이름 또는 사번)</label>
                    <div class="input-group"><span class="input-group-text bg-transparent border-end-0">
                        <span class="material-icons text-muted" style="font-size:20px;">search</span>
                    </span>
                        <input type="text" id="memberSearchInput" class="form-control border-start-0" placeholder="예: 김철수 또는 2024001">
                    </div><div id="searchResultList" class="search-result-list">
                </div></div>--%>
<%--                    <div class="col-12">
                    <label class="small fw-bold text-muted mb-1">참여 팀원 목록</label>
                    <div id="selectedMembers" class="selected-members-box">
                        <span class="text-muted small">팀원을 검색하여 추가해 주세요.</span>
                    </div></div>--%>

                    <div class="col-12">
                    <label class="small fw-bold text-muted mb-1">프로젝트 상세 설명</label>
                    <textarea class="form-control" rows="3" placeholder="내용을 입력하세요"></textarea>
                </div></div></div><div class="modal-footer border-0 p-4 pt-0">
            <button class="btn btn-primary w-100 py-3 fw-bold rounded-pill" style="background:var(--point-color); border:none;" onclick="submitProject()">프로젝트 생성하기</button>
        </div>
        </div>
    </div>
</div>
<div class="modal fade" id="showRoomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="fw-bold">
                    <span class="material-icons align-middle me-2" style="color:var(--point-color)">check_circle</span>
                    입장을 위한 정보를 입력해주세요.
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body p-4">
                <div class="row g-3">
                    <div class="col-12">
                        <label class="small fw-bold text-muted mb-1">이름</label>
                        <input type="text" class="form-control" id="username" placeholder="이름을 입력하세요">
                    </div>
                    <div class="col-12">
                        <label class="small fw-bold text-muted mb-1">방 접속 url설정</label>
                        <input type="text" class="form-control" id="roomId" placeholder="url을 설정하세요" readonly="readonly">

                    </div>

                    <button type="button" class="btn btn-primary shadow-sm" style="background: var(--point-color); border-color:var(--point-color);  font-weight:700;" onclick="viewOnlineMeeting()"> 입장하기 </button>
                </div>
            </div>

        </div>
    </div>
</div>

<script>

    function submitProject(){

               let roomTitle= document.getElementById("roomTitleValue").value;
               let roomUrlId= document.getElementById("roomUrlId").value;
        data = {
        "roomTitle":roomTitle,
        "roomUrlId":roomUrlId
        }

        axios.post("/gooroomee/create",data).then(res=>{
            console.log("결과",res.data);
            AppAlert.success('새 회의실', '회의실이 생성되었습니다.', null, 'meeting_room').then(res =>
                location.reload()
            ); // (알람 리팩토링)
            /*Swal.fire('생성 성공', '회의실이 생성되었습니다.', 'success').then(res=>
                location.reload()
            );*/

        }).catch(err=>{console.error("에러",err)})

    }

    function deleteOnlineMeeting(roomId){
        console.log("결과",roomId);
        //<button type="button" class="btn btn-secondary shadow-sm"
        // style="background:white; border-color: var(--point-color); color : var(--point-color); font-weight:700;"
        //data-bs-url="${prj.roomId}"> 회의실 삭제 </button>
        axios.delete("/gooroomee/delete/"+roomId).then(res=>{
            console.log("결과",res.data);
            AppAlert.confirm('회의실 삭제', '정말 이 회의실을 삭제하시겠습니까?', '삭제하기', '취소', 'delete_forever', 'danger')
                .then((result) => {
                    if (result.isConfirmed) {
                        // (이곳에 실제 삭제를 수행하는 Ajax 또는 로직을 넣으세요)

                        // 삭제 성공 시 알림 및 페이지 새로고침
                        AppAlert.warning('삭제 완료', '회의실이 정상적으로 삭제되었습니다.', null, 'delete_sweep').then(res => {
                            location.reload();
                        }); // (알람 리팩토링)
                    }
                }); // (알람 리팩토링) // (알람 리팩토링)
            /*Swal.fire('회의실 삭제 성공', '회의실이 삭제되었습니다.', 'success').then(res=>
                location.reload()
            );*/
        }).catch(err=>{console.error("에러",err)})

    }

    //화상 회의 참가
    function viewOnlineMeeting(){
        const roomId = showRoomModal.querySelector('#roomId').value;
        const username = showRoomModal.querySelector('#username').value;


        let win="/gooroomee/join/"+roomId+"/"+username;

        window.open(win,"화상회의참여","width=1500,height=1000");
    }

    const showRoomModal = document.getElementById('showRoomModal');

    showRoomModal.addEventListener('show.bs.modal', function (event) {
        // 1. 모달을 연 버튼(trigger button)을 찾습니다.
        const button = event.relatedTarget;

        // 2. 버튼에서 데이터를 가져옵니다.
        const url = button.getAttribute('data-bs-url');

        // 3. 모달 내부의 input 요소에 값을 할당합니다.
        const modalUrlInput = showRoomModal.querySelector('#roomId');

        modalUrlInput.value = url;
    });




</script>