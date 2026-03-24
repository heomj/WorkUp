<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<title>WORK UP 그룹웨어 - 전문가 모드</title>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap"
      rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.css">
<link type="text/css" href="/ckeditor5/sample/css/sample.css" rel="stylesheet" media="screen" />
<script type="text/javascript" src="/ckeditor5/ckeditor.js"></script>


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
    /* 1. 컨테이너 내부 여백 제거 (이중 테두리 및 간격 어색함 방지) */
    #contentsTemp {
        padding: 0 !important;
        border: none !important; /* 부모 div의 테두리를 없애고 에디터 테두리만 사용 */
    }

    /* 2. 에디터 높이 및 스타일 조정 */
    .ck-editor__editable {
        min-height: 400px; /* 에디터 최소 높이 */
        border-radius: 0 0 0.375rem 0.375rem !important; /* 하단 둥글기 맞춤 */
    }

    /* 3. 툴바 스타일 조정 */
    .ck.ck-toolbar {
        border-top-left-radius: 0.375rem !important; /* 상단 둥글기 맞춤 */
        border-top-right-radius: 0.375rem !important;
        border-bottom: 1px solid #dee2e6 !important; /* Bootstrap 경계선 색상 */
    }

    /* 4. 포커스 시 Bootstrap 고유의 파란 테두리 효과 재현 */
    .ck.ck-editor__editable:focus,
    .ck.ck-editor__editable.ck-focused {
        border-color: #86b7fe !important;
        outline: 0;
        box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25) !important;
    }
    /* 오버플로우 글자 처리 실험 */
    /* 1. 제목 영역 말줄임표 한 번에 처리 */
    div[class*="flex-grow-1"] {
        min-width: 0;           /* flex 박스 터짐 방지 핵심 */
    }

    div[class*="text-truncate"] {
        display: block;         /* 확실하게 block 선언 */
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    /* 2. 별표 아이콘에 마우스 손가락 모양 한 번에 주기 */
    span[data-impt] {
        cursor: pointer;
        transition: transform 0.2s; /* 살짝 커지는 효과 (선택사항) */
    }

    span[data-impt]:hover {
        transform: scale(1.2);    /* 마우스 올리면 별이 살짝 커짐 */
    }
    /* 오버플로우 글자 처리 실험 */

    /*메일 전송 성공 스타일*/
    /* 기존 스타일에 추가할 보조 스타일 */
    .dashboard-card {
        background: #fff;
        border-radius: 8px;
        border: 1px solid #e1e4e8;
        box-shadow: 0 2px 6px rgba(67, 89, 113, 0.12);
    }

    /* 전송 성공 페이지 전용 애니메이션 (선택사항) */
    #mail-success-view .material-icons {
        animation: scaleIn 0.5s ease-out;
    }

    @keyframes scaleIn {
        0% { transform: scale(0); opacity: 0; }
        70% { transform: scale(1.1); }
        100% { transform: scale(1); opacity: 1; }
    }


    /* 메일 전송 성공 스타일 끝 */

    /* 전체 컨테이너: 배경을 연하게 빼고 테두리를 실선으로 변경 */
    .attachment-box {
        background-color: #f1f2f4;
        border-radius: 6px;
        padding: 1.25rem;
        margin-top: 2rem;
        border: 1px solid #e1e4e8;
    }


    /* 호버 시: 색상 반전 대신 테두리와 그림자로 포인트 */
    .attachment-item:hover {
        border-color: #696cff;
        background-color: #f8f9ff;
        color: #696cff;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(105, 108, 255, 0.15);
    }

    .attachment-item {
        display: inline-flex;
        align-items: center;
        justify-content: center; /* 내부 정렬 중앙 */
        background: #ffffff;
        border: 1px solid #dcdfe6;

        /* 패딩 조절: 위아래(4px), 좌우(12px)로 줄여서 세로폭 축소 */
        padding: 4px 12px;

        border-radius: 4px;
        font-size: 0.85rem;
        color: #444;
        text-decoration: none;

        /* 너비는 글자 길이에 맞게 */
        width: auto;
        min-width: max-content;
        white-space: nowrap;

        /* [핵심] 폰트 높이 때문에 생기는 위아래 빈 공간 제거 */
        line-height: 1.2;

        box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        transition: all 0.2s ease-in-out;
    }

    /* 아이콘 높이도 텍스트랑 딱 맞게 조절 */
    .attachment-item .material-icons {
        font-size: 1.1rem; /* 아이콘 크기 살짝 조정 */
        margin-right: 6px;
        vertical-align: middle;
    }
    /* 멘션 버튼 전체 스타일 */
    .mention-btn, .mention-btnCc {
        display: inline-flex;
        align-items: center;
        background-color: rgba(105, 108, 255, 0.1); /* 테마색 투명도 10% */
        color: #696CFF; /* 테마색 */
        border: 1px solid rgba(105, 108, 255, 0.2);
        border-radius: 20px;
        padding: 2px 8px;
        margin: 0 4px;
        font-weight: 600;
        font-size: 14px;
        transition: all 0.2s ease;
    }

    /* 멘션 버튼 위로 마우스 올렸을 때 */
    .mention-btn,.mention-btnCc:hover {
        background-color: rgba(105, 108, 255, 0.2);
    }

    /* 삭제(x) 버튼 스타일 */
    .del-mention, .del-mentionCc {
        color: inherit; text-decoration: none;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 16px;
        height: 16px;
        margin-left: 6px;
        border-radius: 50%;
        font-size: 12px;
        line-height: 1;
        cursor: pointer;
        transition: background 0.2s;
    }

    .del-mention:hover,.del-mentionCc:hover {
        background-color: #696CFF;
        color: #fff;
    }

    /* Tribute 검색 결과 전체 컨테이너 */
    .tribute-container {
        position: absolute;
        top: 0;
        left: 0;
        height: auto;
        max-height: 300px;
        max-width: 500px;
        overflow: auto;
        display: block;
        z-index: 999999;
        background-color: #fff;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1); /* 부드러운 그림자 */
        border-radius: 8px;
        border: 1px solid #eaeaec;
        padding: 5px 0;
    }

    /* 각 검색 결과 리스트 항목 */
    .tribute-container ul {
        margin: 0;
        padding: 0;
        list-style: none;
    }

    .tribute-container li {
        padding: 10px 15px;
        cursor: pointer;
        font-size: 14px;
        color: #566a7f;
        transition: background 0.15s;
    }

    /* 키보드로 선택하거나 마우스 올렸을 때 (핵심!) */
    .tribute-container li.highlight,
    .tribute-container li:hover {
        background-color: rgba(105, 108, 255, 0.08); /* 테마색 배경 */
        color: #696CFF; /* 테마색 글자 */
    }

    /* 검색 결과 내 강조 텍스트 (사용자가 입력한 부분) */
    .tribute-container li span {
        font-weight: bold;
    }


    :root {
        --bs-body-bg: #f4f7ff;
        --primary-color: #696CFF;
        --sidebar-width: 260px;
        --sidebar-collapsed-width: 85px;
        --header-height: 65px;
        --nav-text-color: #2f353e;
    }

    body {
        font-family: 'Public Sans', sans-serif;
        background-color: var(--bs-body-bg);
        margin: 0;
        display: flex;
        overflow-x: hidden;
    }


    /* --- 리스트 스타일 --- */
    .list-group-item {
        border: none;
        padding: 0.8rem 1.25rem;
        transition: 0.2s;
        border-bottom: 1px solid #f0f2f5 !important;
    }

    .list-group-item:hover {
        background-color: #fcfcff !important;
    }

    .pagination .page-link {
        border: none;
        margin: 0 3px;
        border-radius: 5px !important;
        color: var(--nav-text-color);
    }

    .pagination .page-item.active .page-link {
        background-color: var(--primary-color);
        color: #fff;
    }
    .btn-xs {
        padding: 1px 1px;
        font-size: 15px;
        line-height: 1.2;
        border-radius: 10px;
    }
    #btnSearch:hover{
        background-color: var(--point-color);
        color:white !important;
    }
    .page-content{
        background-color:#F4F7FE;
    }

</style>
<!-- 리스트 -->
<div id="mail-list-view">
    <div class="d-flex align-items-center justify-content-between mb-4">
        <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
            <span class="material-icons" style="color: #696cff; font-size: 32px;">mail_outline</span>

            <div style="display: flex; align-items: baseline; gap: 8px;">
                <span style="font-size: x-large; font-weight: 800;">메일</span>
                <span style="font-weight: normal; color: #717171; font-size: 15px;">| 휴지통</span>
            </div>
        </div>
        <div class="d-flex gap-2">
            <div class="input-group input-group-sm" style="width: 250px;">
                <select class="form-select" name="mode" style="max-width: 80px; padding-right: 20px; background-position: right 5px center; background-size: 10px;">
                    <option value="" selected>전체</option>
                    <option value="emlTtl">제목</option>
                    <option value="emlCn">내용</option>
                    <option value="emlSndrId">사번</option>
                </select>
                <input type="text" class="form-control"  name="keyword" placeholder="메일 검색...">
                <button class="btn btn-outline-primary d-inline-flex align-items-center" style="border-color: var(--point-color); color: var(--point-color);" id="btnSearch"><span class="material-icons fs-6">search</span></button>
            </div>
            <a class="btn btn-primary btn-sm d-flex align-items-center" href="/email/write"  style="background-color:var(--point-color); border-color: var(--point-color);">
                <span class="material-icons fs-6 me-1">edit</span>메일쓰기
            </a>
        </div>
    </div>

    <div class="dashboard-card mb-3">
        <div class="p-2 d-flex align-items-center justify-content-between border-bottom">
            <div class="d-flex align-items-center gap-3 ps-2">
                <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="checkAll" onclick="toggleAllChecks(this)">
                </div>
                <button class="btn btn-sm btn-light border text-secondary d-inline-flex align-items-center" onclick="deletePermanent()"><span
                        class="material-icons fs-6 v-align-middle">delete_outline</span> 영구삭제
                </button>
                <button class="btn btn-sm btn-light border text-secondary d-inline-flex align-items-center" onclick="handleMailAction('retrieve')"><span
                        class="material-icons fs-6 v-align-middle">mark_email_read</span> 메일함 복구
                </button>
                <button class="btn btn-sm btn-light border text-secondary d-inline-flex align-items-center" onclick="handleMailAction('isImpt')"><span
                        class="material-icons fs-6 v-align-middle">star</span> 중요설정
                </button>
                <div class="vr mx-2"></div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-light border dropdown-toggle" data-bs-toggle="dropdown">필터</button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item fw-bold" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'All')">전체 메일</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'isNotRead')">안읽은 메일</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'isImpt')">중요 메일</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'isFile')">첨부 메일</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'isEmrg')">긴급 메일</a>
                        </li>
                    </ul>
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-light border dropdown-toggle" data-bs-toggle="dropdown">목록 개수</button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageNum', 10)">10개</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageNum', 20)">20개</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageNum', 30)">30개</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageNum', 50)">50개</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageNum', 100)">100개</a>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="pe-2 text-muted small" id="count">
            </div>
        </div>
        <div class="mail-list" id="mailListContainer"></div>
        <div class="card-footer bg-white border-top-0 py-4">
            <ul class="pagination justify-content-center mb-0" id="pagination">
            </ul>
        </div>
    </div>
</div>
<!-- 상세보기 -->
<div id="mail-detail-view" style="display: none;">
    <div class="mb-4">
        <button class="btn btn-light border btn-sm d-flex align-items-center" onclick="firstListFn()">
            <span class="material-icons fs-6 me-1">arrow_back</span>목록으로 돌아가기
        </button>
    </div>
    <div class="dashboard-card p-4">
        <div class="border-bottom pb-3 mb-3">
            <h4 id="detail-title" class="fw-bold mb-2"></h4>
            <div class="d-flex align-items-center">
                <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=mail" id="empProfile" class="rounded-circle me-2" width="40">
                <div>
                    <div class="fw-bold" id="detail-sender"></div>
                    <div class="text-muted small" id="detail-time"></div>
                </div>
            </div>
        </div>
        <div id="detail-file" class="pt-0"></div>
        <div id="detail-content" class="py-4" style="min-height: 200px; max-height: 600px; overflow: auto; line-height: 1.6;"></div>
        <div id="detail-btns-footer" style="margin-top:10px;">버튼 만들어보려고요</div>
    </div>
</div>



<script>
    //이메일용 쿠키 삭제
    function clearMailCookies() {
        // 삭제할 쿠키 이름 리스트
        const targetCookies = ['pageNum', 'pageFilter', 'emlBoxNo'];

        targetCookies.forEach(name => {
            // 핵심: 만료일을 과거(1970년)로 설정하고, 생성 시와 동일한 path를 지정합니다.
            document.cookie = name + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/";
        });

        console.log("메일 관련 쿠키 3종이 삭제되었습니다.");

        // 만약 삭제 후 알림을 띄우고 싶다면 (AppAlert 활용)
        // AppAlert.autoClose('설정 초기화', '페이지 설정 쿠키를 삭제했습니다.', 'cookie', 'info', 1000); // (알람 리팩토링)
    }


    //쿠키 추가하기
    function setCookieNum(about, num) {
        const cookieName = about;
        const cookieValue = num;
        // 쿠키 저장 (path=/ 를 설정해야 사이트 전역에서 접근 가능합니다)
        document.cookie = cookieName + "=" + cookieValue + ";path=/";
        const currentPagingItem = document.getElementById('currentPagingItem');
        //alert("쿠키가 저장되었습니다!");
        if (currentPagingItem) {
            currentPage = currentPagingItem.getAttribute('data-no');
        } else {
            currentPage = 1;
        }
        mode=document.querySelector("select[name='mode']").value||"";
        keyword=document.querySelector("input[name='keyword']").value||"";
        listFn(1, currentPage, mode, keyword);

    }

    //모두 숨기기
    function hideAll() {
        document.getElementById('mail-list-view').style.display = 'none'; //리스트
        document.getElementById('mail-detail-view').style.display = 'none';//상세
    }


    document.addEventListener("DOMContentLoaded", function () {
        clearMailCookies()
        firstListFn();

//검색 또는 페이지 이동 listFn
        const btnSearch=document.querySelector("#btnSearch");
        btnSearch.addEventListener("click",()=>{

            const data = {
                "currentPage":1,
                "mode":document.querySelector("select[name='mode']").value||"",
                "keyword":document.querySelector("input[name='keyword']").value||"",
            }
            console.log("btnSearch->data : ",data);
            axios.post("/email/listTrashAxios",data,{
                headers:{
                    "Content-Type":"application/json;charset=utf-8"
                }
            }).then(response=>{
                console.log("result:", response.data);
                listShowFn(response.data)

            }).catch(err=>{console.log("err=>{}",err)});
        })

    })

    function listFn(url, currentPage, mode, keyword) {
        let data = {
            "currentPage": currentPage,
            "mode": mode,
            "keyword": keyword,
        }
        console.log("listFn->data: ", data);
        axios.post("/email/listTrashAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                console.log("result : ", response.data);
                //목록 핸들러 호출 함수
                listShowFn(response.data)
            })
            .catch(err => {
                console.error("err : ", err);
            });
    }//end listFn
    //리스트 뿌리기
    function listShowFn(articlePage) {
        let str = "";
        const container = document.getElementById('mailListContainer');
        container.innerHTML = "";
        const emailVOList = articlePage.content;
        emailVOList.forEach(function (item) {
            let row = document.createElement('div');
            let html = '';

            row.className = 'list-group-item d-flex align-items-center py-3 ' + (item.emlRcvngDt ? 'bg-light bg-opacity-50' : 'bg-white');
            row.style.cursor = 'pointer';
            row.setAttribute('data-id', item.emlRcvrId);
            // 1. 데이터 ID를 요소에 명시적으로 저장
            row.dataset.emlRcvrId = item.emlRcvrId;

            // 2. 이벤트 핸들러 수정
            row.onclick = function (e) {
                // 체크박스 클릭 시에는 상세보기로 넘어가지 않게 방어
                if (e.target.classList.contains('mail-item-check')) return;
                if (e.target.classList.contains('material-icons')) {
                    // 부모 클래스에서 기본키 추출
                    const parentRow = e.target.closest('.list-group-item');
                    const dataId = parentRow.dataset.id;
                    console.log("가져온 ID:", dataId);
                    // 중요 표시 업데이트 'N'or 'Y'를 가져옴
                    // 현재 상태 가져오기 (Y 또는 N)
                    const setImpt = e.target.dataset.impt;

                    console.log("메일ID:", dataId, "현재상태:", setImpt,);

                    axios.post("/email/updateIsImpt", {
                            "dataId" :dataId,
                            "setImpt":setImpt
                        },
                        {
                            headers :{
                                "Content-Type" : "application/json;charset=utf-8"
                            }
                        }).then(response=>{
                        console.log("결과입니당 : ", response.data);
                    }).catch(err=>{
                            console.error("에러났네요 : ", err)
                        }
                    );
                    firstListFn();

                    return}

                // 클릭된 row의 dataset에서 번호를 가져옴
                const id = this.dataset.emlRcvrId;
                viewDetail(id);
            };
// ---  발송자 정보 : 이름 + 직위 + (팀)
            html += '<div class="form-check ms-2"><input class="form-check-input mail-item-check" type="checkbox" value="' + item.emlRcvrId + '"></div>';
            html += '<span class="material-icons ms-3 ' + (item.emlImptYn === 'Y' ? 'text-warning' : 'text-secondary') + '" style="font-size:1.2rem; cursor:pointer;" data-impt="' + item.emlImptYn + '">' + (item.emlImptYn === 'Y' ? 'star' : 'star_border') + '</span>';
            html += '<div class="ms-4 text-truncate ' + (!item.emlRcvngDt ? 'fw-bold' : '') + '" style="width:150px;" title="'+( item.empNm!=null?  item.empNm: "") +' '+ ( item.empJbgd!=null?  item.empJbgd: item.emlOtsdSndrAddr+"&nbsp;")+ '('+( item.deptNm!=null?  item.deptNm: "외부")+')'+'">'
                +( item.empNm!=null?  item.empNm: "") +' '+ ( item.empJbgd!=null?  item.empJbgd: item.emlOtsdSndrAddr+"&nbsp;")+ '('+( item.deptNm!=null?  item.deptNm: "외부")+')'+'</div>';

// ---  CC 전용 그리드 (너비를 40px로 고정하여 제목 시작 위치를 통일) ---
            html += '<div class="text-center" style="width:40px;">';
            if(item.emlRcvrType === '참조자') {
                html += '<span class="badge bg-success" style="font-size: 0.65rem; padding: 2px 4px; vertical-align: middle;">CC</span>';
            }
            if (item.emlOtsdSndrAddr != null && item.emlOtsdSndrAddr !== ""){
                html += '<span class="badge bg-primary" style="font-size: 0.65rem; padding: 2px 4px; vertical-align: middle;">외부</span>';
            }
            html += '</div>';

// 1. 제목 영역
            html += '<div class="flex-grow-1 text-truncate px-2"' + 'style="max-width: 1080px;' + (item.emlEmrgYn==='Y' ? ' color:red;"'  : '"') + '>';
            html +=     '<span class="' + (!item.emlRcvngDt ? 'fw-bold' : '') + '">' + (item.emlEmrgYn==='Y' ? '[긴급]' : '') + item.emlTtl + '</span>';
            html += '</div>';

// 2. 클립 전용 그리드 (세로 줄 유지)
            html += '<div class="text-center" style="width:40px;">';
            html +=     (item.fileId !== 0 ? '<span class="fas fa-paperclip text-muted"></span>' : '');
            html += '</div>';

// 3. 날짜 영역
            html += '<div class="text-end text-muted small pe-2" style="width:200px;">'
                + item.emlSndngDt.substring(0, 10)
                + '&nbsp;&nbsp;&nbsp;' + item.emlSndngDt.substring(11, 16) + '</div>';

            const min = Math.min(...articlePage.content.map(vo => vo.rnum));

            const max = Math.max(...articlePage.content.map(vo => vo.rnum));
            let str ='';

            str+='<b id="page-info">'+min+'-'+max+'</b> of <span id="total-count">'+articlePage.total+'</span>'


            row.innerHTML = html;
            const container = document.getElementById('mailListContainer');
            container.appendChild(row);
            document.getElementById("count").innerHTML = str;
        });

        if(articlePage.content.length===0){ //결과 없을 때 처리
            document.getElementById("count").innerHTML ='<b id="page-info">0</b> of <span id="total-count">0</span>';
            html= ''
            html = '<div class="flex-grow-1 text-truncate px-2 fw-bold text-center" style="color:white"> *   </div>' +
                '<div class="flex-grow-1 text-truncate px-2 fw-bold text-center"> 조회할 메일이 없습니다. </div>'
            let row = document.createElement('div');
            row.innerHTML = html;
            const container1 = document.getElementById('mailListContainer');
            container1.appendChild(row);
        }
        //document.querySelector("#mailListContainer").innerHTML = str;
        //페이징 블록 처리 response.data = ArticlePage
        document.getElementById("pagination").innerHTML = articlePage.pagingArea;

    }//end list shownFn

    //페이지 1
    function firstListFn() {
        hideAll();
        document.getElementById('mail-list-view').style.display = 'block';
        //기존 페이지가 있는 경우... 기억하기
        const currentPagingItem = document.getElementById('currentPagingItem');
        if (currentPagingItem) {
            currentPage = currentPagingItem.getAttribute('data-no');
        } else {
            currentPage = 1;
        }
        let data = {
            "currentPage": currentPage
        }
        axios.post("/email/listTrashAxios", data, {
            headers: {
                "Content-Type": "application/json;charset=utf-8"
            }
        })
            .then(response => {
                console.log("result : ", response.data);
                //목록 핸들러 호출 함수
                let str ='';
                listShowFn(response.data)
                const articlepage=response.data;
                const min = Math.min(...articlepage.content.map(vo => vo.rnum));
                const max = Math.max(...articlepage.content.map(vo => vo.rnum));
                if(articlepage.content.length===0){ //결과 없을 때 처리
                    str='';
                }else {

                    str += '<b id="page-info">' + min + '-' + max + '</b> of <span id="total-count">' + articlepage.total + '</span>'

                }
                document.getElementById("count").innerHTML = str;
            })
            .catch(err => {
                console.error("err : ", err);
            });
    }//end firstListFn




    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //상세보기 비동기
    async function viewDetail(emlRcvrId) {
        //let mail = allMails.find(function(m) { return m.emlNo === emlNo; });
        //클릭 메일의 VO를 가져올 것
        const data = {"emlRcvrId": emlRcvrId}
        axios.post("detailAxios", data, {
            headers: {
                "Content-Type": "application/json"
            }
        }).then(response => {
            console.log("result : ", response.data);
            const mail = response.data
            //상세보기
            let fileHtml = '';
            if (mail.fileTbVO && mail.fileTbVO.fileDetailVOList && mail.fileTbVO.fileDetailVOList.length > 0) {
                const fileList = mail.fileTbVO.fileDetailVOList;

                fileHtml += `
        <div class="attachment-box">
            <div class="fw-bold mb-3 d-flex align-items-center">
                <span class="material-icons me-1" style="font-size: 1.2rem;">attach_file</span>
                첨부파일 (\${fileList.length}개)
            </div>
            <div class="d-flex flex-wrap gap-2">`;
                fileList.forEach(fileDtl => {
                    fileHtml += `
            <a href="/download?fileDtlId=\${fileDtl.fileDtlId}" class="attachment-item">
                <span class="material-icons me-1" style="font-size: 1rem;">description</span>
                \${fileDtl.fileDtlONm} (\${fileDtl.fileDtlExt})
            </a>`;
                });

                fileHtml += `</div></div>`;
            }
            const profileSrc = (mail.empProfile && mail.empProfile !== '')
                ? `/displayPrf?fileName=\${mail.empProfile}`  :  '/displayPrf?fileName=defaultimg.png';
            document.getElementById('detail-title').innerText = mail.emlTtl;
            document.getElementById('empProfile').src= profileSrc;
            document.getElementById('detail-sender').innerText = mail.empNm +' '+ mail.empJbgd;
            /*document.getElementById('detail-time').innerText = '발송 시각 : ' +
                mail.emlSndngDt.substring(0, 10) + `(\${['일','월','화','수','목','금','토'][new Date(mail.emlSndngDt).getDay()]}) ` +
                +'  ' + mail.emlSndngDt.substring(12, 16);*/

            console.log("메일발송시간", mail.emlSndngDt);
            /*document.getElementById('detail-time').innerText = '발송 시각 : ' +
                mail.emlSndngDt.substring(0, 10) + `(\${['일','월','화','수','목','금','토'][new Date(mail.emlSndngDt).getDay()]}) ` +
                +'  ' + mail.emlSndngDt.substring(11, 16);*/

            const dt = mail.emlSndngDt; // "2026-03-20T10:38:26"
            const week = ['일', '월', '화', '수', '목', '금', '토'];
            const dayIndex = new Date(dt).getDay(); // 요일 숫자 (0~6)
            const dayName = week[dayIndex]; // "금"

// substring 인덱스 주의: T 다음은 11번부터
            const datePart = dt.substring(0, 10); // "2026-03-20"
            const timePart = dt.substring(11, 16); // "10:38"

// 최종 출력: 불필요한 + 기호를 모두 제거하고 조합
            document.getElementById('detail-time').innerText =
                '발송 시각 : ' + datePart + '(' + dayName + ') ' + timePart;

            document.getElementById('detail-file').innerHTML = fileHtml;
            document.getElementById('detail-content').innerHTML =
                mail.emlCn
            document.getElementById("detail-btns-footer").innerHTML=
                `<button class="btn btn-success btn-sm"  style="background-color:var(--point-color); border-color: var(--point-color);"onclick="trashcandeletePmntOrRecall('retrieve',\${mail.emlRcvrId})">복구</button>`
            +`&nbsp;&nbsp;<button class="btn btn-secondary btn-sm float-end" onclick="trashcandeletePmntOrRecall('deletePermanent',\${mail.emlRcvrId})">영구 삭제</button>`;
            hideAll();
            document.getElementById('mail-detail-view').style.display = 'block';


            })


            .catch(err => {
                console.error("err : ", err);
            });

        //mail.isRead = true;
        //listFn(0,1);
    }
    //메일 발송
    ///////////////////////////메일 보내기 영역 시작/////////////////////////////////////////////////////////////////////////////////////////////
    //메일발송 창 보이기
    function showWriteView(to, sub) {
        hideAll();
        document.getElementById('mail-write-view').style.display = 'block';
        //document.getElementById('receiver').value = to || "";
        //document.getElementById('write-subject').value = sub ? "Re: " + sub : "";

        //이미지 미리보기//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>확인필요! 공간확보<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        //<input type="file" id="productImage" name="productImage"...
        //1.이벤트 리스너 등록
        const productImage = document.getElementById("productImage");
        //Object가 있을 때에만 실행
        if (productImage) {
            productImage.addEventListener("change", handleImgFileSelect);
        }
        //<button id="productIdChk" class="btn btn-warning btn-sm">중복 확인</button>
        //      Object
        const productIdChk = document.getElementById("productIdChk");
        //멘션 기능 (수신자)
        const tribute = new Tribute({
            autocompleteMode: true,
            lookup: (item) => item.empId + "("+item.empNm+")",  // 검색할 필드
            fillAttr: (item) => item.empId + "("+item.empNm+")", // 선택 시 입력창에 들어갈 기본값
            requireAnyChar: false,
            values: function (text, cb) {
                fetch('/email/search?query=' + text)
                    .then(res => res.json())
                    .then(data => {
                        // 1. 받는 사람(#receiver)과 참조자(#cC) 영역에서 이미 선택된 사원번호들 수집
                        const selectedInReceiver = Array.from(document.querySelectorAll('#receiver .mention-btn'))
                            .map(span => span.getAttribute('data-no'));
                        const selectedInCc = Array.from(document.querySelectorAll('#cC .mention-btnCc'))
                            .map(span => span.getAttribute('data-no'));

                        // 2. 두 영역의 ID를 하나로 합침
                        const allSelectedIds = [...selectedInReceiver, ...selectedInCc];

                        // 3. 서버에서 가져온 데이터(data) 중 이미 선택된 ID를 제외한 나머지만 리스트에 표시
                        const filteredData = data.filter(item => !allSelectedIds.includes(String(item.empId)));

                        cb(filteredData);
                    }) // 여기서 오는 데이터가 {empId: '...', empNm: '...'} 형태여야 함
                    .catch(err => cb([]));
            },
            selectTemplate: function (item) {
                if (typeof item === 'undefined') return null;
                return '<span class="mention-btn" data-no="' + item.original.empId + '" contenteditable="false">'
                    + '@' + item.original.empNm
                    + '<a class="del-mention">X</a>' // x 버튼 추가
                    + '</span>&nbsp; <input type=hidden name="emlRcvrId" value="'+item.original.empId+'">';
            },
            // 검색 결과가 없을 때 보여줄 템플릿 (디버깅용)
            noMatchTemplate: function () {
                return '<li>결과가 없습니다</li>';
            }
        });
        tribute.attach(document.getElementById('receiver'));

        document.getElementById('receiver').addEventListener('click', function(e) {
            // 클릭된 요소가 삭제 버튼(x)인지 확인
            if (e.target && e.target.classList.contains('del-mention')) {
                // 부모 요소인 .mention-btn을 찾아서 삭제
                const mentionBtn = e.target.closest('.mention-btn');
                if (mentionBtn) {
                    mentionBtn.remove();
                }
            }
        });

        //멘션 기능 (참조)
        const tributeCc = new Tribute({
            autocompleteMode: true,
            lookup: (item) => item.empId + "("+item.empNm+")",  // 검색할 필드
            fillAttr: (item) => item.empId + "("+item.empNm+")", // 선택 시 입력창에 들어갈 기본값
            requireAnyChar: false,
            values: function (text, cb) {
                fetch('/email/search?query=' + text)
                    .then(res => res.json())
                    .then(data => {

                        // 1. 받는 사람(#receiver)과 참조자(#cC) 영역에서 이미 선택된 사원번호들 수집
                        const selectedInReceiver = Array.from(document.querySelectorAll('#receiver .mention-btn'))
                            .map(span => span.getAttribute('data-no'));
                        const selectedInCc = Array.from(document.querySelectorAll('#cC .mention-btnCc'))
                            .map(span => span.getAttribute('data-no'));

                        // 2. 두 영역의 ID를 하나로 합침
                        const allSelectedIds = [...selectedInReceiver, ...selectedInCc];

                        // 3. 서버에서 가져온 데이터(data) 중 이미 선택된 ID를 제외한 나머지만 리스트에 표시
                        const filteredData = data.filter(item => !allSelectedIds.includes(String(item.empId)));

                        cb(filteredData);

                        }
                    ) // 여기서 오는 데이터가 {empId: '...', empNm: '...'} 형태여야 함
                    .catch(err => cb([]));
            },
            selectTemplate: function (item) {
                if (typeof item === 'undefined') return null;
                return '<span class="mention-btnCc" data-no="' + item.original.empId + '" contenteditable="false">'
                    + '@' + item.original.empNm
                    + '<a class="del-mentionCc">X</a>' // x 버튼 추가
                    + '</span>&nbsp; <input type=hidden name="emlRcvrIdCc" value="'+item.original.empId+'">';
            },
            // 검색 결과가 없을 때 보여줄 템플릿 (디버깅용)
            noMatchTemplate: function () {
                return '<li>결과가 없습니다</li>';
            }
        });
        tributeCc.attach(document.getElementById('cC'));

        document.getElementById('cC').addEventListener('click', function(e) {
            // 클릭된 요소가 삭제 버튼(x)인지 확인
            if (e.target && e.target.classList.contains('del-mentionCc')) {
                // 부모 요소인 .mention-btn을 찾아서 삭제
                const mentionBtn = e.target.closest('.mention-btnCc');
                if (mentionBtn) {
                    mentionBtn.remove();
                }
            }
        });

    }
    //긴급설정 토글
    function toggleEmrg() {
        const input = document.getElementById('emlEmrgYn');
        const btn = document.getElementById('emrgBtn');

        if (input.value === 'N') {
            input.value = 'Y';
            btn.innerText = '긴급 O';
            // 빨간 바탕 + 흰 글씨로 변경
            btn.className = 'btn btn-danger btn-xs';
        } else {
            input.value = 'N';
            btn.innerText = '긴급 X';
            // 흰 바탕 + 빨간 글씨로 변경
            btn.className = 'btn btn-outline-danger btn-xs';
        }
    }

    /////////전역함수 /////////////////////////////////////////////////////////////////////////////////////////
    // 이미지 미리보기///


    function toggleAllChecks(main) {
        var checks = document.querySelectorAll('.mail-item-check');
        checks.forEach(function(c) { c.checked = main.checked; });
    }
    //체크박스 처리
    const handleMailAction = (readOrDelOrImpt) => {
        // 1. 체크된 체크박스들만 가져오기
        const checkedInputs = document.querySelectorAll('.mail-item-check:checked');

        // 2. 체크박스의 value(emlNo)를 추출해서 배열로 만들기
        const selectedEmlNos = Array.from(checkedInputs).map(input => input.value);

        // 3. 선택된 게 하나도 없을 때 예외 처리
        if (selectedEmlNos.length === 0) {
            Swal.fire({
                title: "선택된 메일이 없습니다.",
                icon: "warning",
                confirmButtonText: '확인',
                /*alert("삭제된 메일은 '휴지통'에서 확인할 수 있습니다.");*/
            })
            return;
        }

        // 4. 전송 (배열을 넘길 때는 객체에 담아서 보내는 게 서버에서 받기 편합니다)

        let title = ""; // 기본값 설정

        if (readOrDelOrImpt == "retrieve") {
            title = "복구처리";
        } else if (readOrDelOrImpt == "isImpt") {
            title = "중요설정";
        }
        console.log("readOrDelOrImpt는",readOrDelOrImpt,"이고요 title은", title,"입니다.");
        Swal.fire({
            title: "정말 "+title+" 하시겠습니까?",
            icon: "question",
            showCancelButton: true,
            confirmButtonColor: '#7579ff',
            confirmButtonText: '확인',
            cancelButtonText: '취소'
        }).then((result) => {

            if (result.isConfirmed) {
                axios.post('/email/readOrDelOrImpt', {
                    readOrDelOrImpt: readOrDelOrImpt,
                    emlNos: selectedEmlNos
                }).then(res => {
                    Swal.fire({
                        title: title + " 완료",
                        icon: "success",
                        confirmButtonText: '목록으로',
                        /*alert("삭제된 메일은 '휴지통'에서 확인할 수 있습니다.");*/
                    }).then(result => {
                        location.href = "/email/trashCan";
                    });

                }).catch(e => {
                    Swal.fire({
                        title: "오류 발생",
                        text: e,
                        icon: "error",
                        confirmButtonText: '목록으로',
                    }).then(result => {
                        location.href = "/email/trashCan";
                    });
                });
            }//if 끝
        })
    };
//단일건수 처리
    const trashcandeletePmntOrRecall = (deletePmntOrRecall, emlRcvrId) => {

        let title = ""; // 기본값 설정

        if (deletePmntOrRecall == "retrieve") {
            title = "복귀";
        } else if (deletePmntOrRecall == "deletePermanent") {
            title = "영구삭제";
        }
        console.log("readOrDelOrImpt는",deletePmntOrRecall,"이고요 title은", title,"입니다.");
        Swal.fire({
            title: "정말 "+title+" 하시겠습니까?",
            icon: "question",
            showCancelButton: true,
            confirmButtonColor: '#7579ff',
            confirmButtonText: '확인',
            cancelButtonText: '취소'
        }).then((result) => {

            if (result.isConfirmed) {
                axios.post('/email/trashcandeletePmntOrRecall', {
                    deletePmntOrRecall: deletePmntOrRecall,
                    emlRcvrId: emlRcvrId
                }).then(res => {
                    Swal.fire({
                        title: title + " 완료",
                        icon: "success",
                        confirmButtonText: '목록으로',
                        /*alert("삭제된 메일은 '휴지통'에서 확인할 수 있습니다.");*/
                    }).then(result => {
                        location.href = "/email/trashCan";
                    });

                }).catch(e => {
                    Swal.fire({
                        title: "오류 발생",
                        text: e,
                        icon: "error",
                        confirmButtonText: '목록으로',
                    }).then(result => {
                        location.href = "/email/trashCan";
                    });
                });
            }//if 끝
        })
    };


    //영구삭제
    const deletePermanent = () => {
        // 1. 체크된 체크박스들만 가져오기
        const checkedInputs = document.querySelectorAll('.mail-item-check:checked');

        // 2. 체크박스의 value(emlNo)를 추출해서 배열로 만들기
        const selectedEmlNos = Array.from(checkedInputs).map(input => input.value);

        // 3. 선택된 게 하나도 없을 때 예외 처리
        if (selectedEmlNos.length === 0) {
            alert("선택된 메일이 없습니다.");
            return;
        }

        // 4. 전송 (배열을 넘길 때는 객체에 담아서 보내는 게 서버에서 받기 편합니다)
        Swal.fire({
            title: "영구삭제하면 복구할 수 없습니다.",
            text: "정말 선택 메일을 영구적으로 삭제하시겠습니까?",
            icon: "error",
            showCancelButton: true,
            confirmButtonColor: '#7579ff',
            confirmButtonText: '확인',
            cancelButtonText: '취소'
        }).then((result) => {

            if (result.isConfirmed) {
                axios.post('/email/deletePermanent', {
                    readOrDelOrImpt:"deletePermanent",
                    emlNos: selectedEmlNos
                }).then(res => {
                    if (res.data > 0) {
                        Swal.fire({
                            title: "선택 메일을 영구적으로 삭제하였습니다.",
                            icon: "success",
                            confirmButtonText: '목록으로',
                            /*alert("삭제된 메일은 '휴지통'에서 확인할 수 있습니다.");*/

                        }).then(result => {
                            location.href = "/email/trashCan";
                        });
                    }
                }).catch(e => {
                    Swal.fire({
                        title: "오류 발생",
                        text: e,
                        icon: "error",
                        confirmButtonText: '목록으로',
                    }).then(result => {
                        location.href = "/email/trashCan";
                    });
                });
            }//if 끝
        })
       /* // 4. 전송 (배열을 넘길 때는 객체에 담아서 보내는 게 서버에서 받기 편합니다)
        if (confirm("영구 삭제하면 복구할 수 없습니다. 정말 삭제하시겠습니까?")) {
            axios.post('/email/deletePermanent', {
                readOrDelOrImpt:"deletePermanent",
                emlNos: selectedEmlNos
            })
                .then(res => {
                    if (res.data > 0) {
                        alert("처리되었습니다.");
                        location.reload(); // 리스트 새로고침
                    }
                })
                .catch(err => console.error("에러 발생:", err));
        }*/
    };


    /////전역함수 끝//////////////////////////////////////////////////////////////////////////////////////////////////////////////


</script>