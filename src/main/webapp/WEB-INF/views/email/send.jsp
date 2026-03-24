<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<title>WORK UP 그룹웨어 - 전문가 모드</title>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap"
      rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.css">
<link type="text/css" href="/ckeditor5/sample/css/sample.css" rel="stylesheet" media="screen" />
<script type="text/javascript" src="/ckeditor5/ckeditor.js"></script>

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
                <span style="font-weight: normal; color: #717171; font-size: 15px;">| 보낸 메일함</span>
            </div>
        </div>
        <div class="d-flex gap-2">
            <div class="input-group input-group-sm" style="width: 250px;">
                <select class="form-select" name="mode" style="max-width: 80px; padding-right: 20px; background-position: right 5px center; background-size: 10px;">
                    <option value="" selected>전체</option>
                    <option value="emlTtl">제목</option>
                    <option value="emlCn">내용</option>
                    <option value="emlRcvrId">사번</option>
                </select>
                <input type="text" class="form-control"  name="keyword" placeholder="메일 검색...">
                <button class="btn btn-outline-primary d-inline-flex align-items-center"  style="border-color: var(--point-color); color: var(--point-color);"  id="btnSearch"><span class="material-icons fs-6">search</span></button>
            </div>
            <a class="btn btn-primary btn-sm d-flex align-items-center" href="/email/write"  style="background-color:var(--point-color); border-color: var(--point-color);">
                <span class="material-icons fs-6 me-1">edit</span>메일쓰기
            </a>
        </div>
    </div>

    <div class="dashboard-card mb-3">
        <div class="p-2 d-flex align-items-center justify-content-between border-bottom">
            <div class="d-flex align-items-center gap-3 ps-2">
                <div class="form-check ms-2">
                    <input class="form-check-input" type="checkbox" id="checkAll" onclick="toggleAllChecks(this)">
                </div>

                <%-- <button class="btn btn-sm btn-light border text-secondary d-inline-flex align-items-center" onclick="handleMailAction('isDeleted')"><span
                         class="material-icons fs-6 v-align-middle">delete_outline</span> 휴지통
                 </button>
                 <button class="btn btn-sm btn-light border text-secondary d-inline-flex align-items-center" onclick="handleMailAction('isRead')"><span
                         class="material-icons fs-6 v-align-middle">mark_email_read</span> 읽음처리
                 </button>--%>
                <button class="btn btn-sm btn-light border text-secondary d-inline-flex align-items-center" onclick="handleMailAction('reCallEmail')"><span
                        class="material-icons fs-6 v-align-middle">history</span> &nbsp;회수
                </button>
                <div class="vr mx-2"></div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-light border dropdown-toggle" data-bs-toggle="dropdown">필터</button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item fw-bold" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'All')">전체 메일</a>
                        </li>
                        <%--<li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'isNotRead')">안읽은 메일</a>
                        </li>--%>
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
            <div class="d-flex align-items-center " > <!-- justify-content-between-->
                <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=mail" id="empProfile" class="rounded-circle me-2" width="40">
                <div>
                    <div class="fw-bold" id="detail-sender"></div>
                    <div class="text-muted small" id="detail-time"></div>
                </div >
                <div id="forthebtn" class=" ms-2">
                </div>
            </div>
        </div>
        <div id="detail-file" class="pt-0"></div>
        <div id="detail-content" class="py-4" style=" max-height: 600px; overflow: auto;min-height: 200px; line-height: 1.6;"></div>
        <div id="detail-btns-footer" style="margin-top:10px;">버튼 만들어보려고요</div>
    </div>
</div>

<!-- 메일 발송 성공 페이지 -->

<div id="mail-success-view" style="display: none;">
    <div class="mb-4 d-flex align-items-center justify-content-between">
        <h4 class="fw-bold mb-0">전송 완료</h4>
    </div>

    <div class="dashboard-card p-5 text-center">
        <div class="mb-4">
            <span class="material-icons" style="font-size: 80px; color: var(--primary-color); background-color: rgba(105, 108, 255, 0.1); padding: 20px; border-radius: 50%;">
                check_circle_outline
            </span>
        </div>

        <h3 class="fw-bold mb-2">메일을 성공적으로 보냈습니다.</h3>
        <p class="text-muted mb-4">
            작성하신 메일이 상대방에게 안전하게 전달되었습니다.<br>
            보낸 메일함에서 전송 기록을 확인할 수 있습니다.
        </p>

        <hr class="my-4" style="border-top: 1px solid #e1e4e8; width: 50%; margin: 0 auto;">

        <div class="d-flex justify-content-center gap-3">
            <button class="btn btn-primary d-inline-flex align-items-center px-4" onclick="firstListFn()">
                <span class="material-icons fs-6 me-1">list</span>
                목록으로 이동
            </button>
            <button class="btn btn-outline-secondary d-inline-flex align-items-center px-4" onclick="showWriteView()">
                <span class="material-icons fs-6 me-1">edit</span>
                메일 더 쓰기
            </button>
        </div>
    </div>
</div>


<!-- 메일 작성 -->
<div id="mail-write-view" >
    <div class="mb-4 d-flex align-items-center justify-content-between">
        <h4 class="fw-bold mb-0">메일 작성</h4>
        <button class="btn btn-outline-secondary btn-sm" onclick="firstListFn()">취소</button>
    </div>
    <div class="dashboard-card p-4">
        <ul class="nav nav-tabs" id="myTab" role="tablist">
            <li class="nav-item">
                <button class="nav-link active" id="internal-tab" data-toggle="tab" data-target="#internal" type="button">내부 메일</button>
            </li>
            <li class="nav-item">
                <button class="nav-link " id="external-tab" data-toggle="tab" data-target="#external" type="button">외부 메일</button>
            </li>
        </ul>
        <div class="tab-content pt-3" id="myTabContent">
            <div class="tab-pane fade show active" id="internal">
                <form action="/email/send" method="post" enctype="multipart/form-data" id="sendMailForm">

                    <div class="mb-3"><label class="form-label fw-bold">받는 사람</label>
                        <div class="form-control" id="receiver" name="emlNo" contenteditable="true"></div></div>

                    <div class="mb-3"><label class="form-label fw-bold">참조자</label>
                        <div class="form-control" id="cC" name="emlCcId" contenteditable="true"></div></div>
                    <div class="mb-3"><label class="form-label fw-bold" >제목&nbsp;&nbsp;&nbsp;&nbsp;</label>
                        <input type="hidden" id="emlEmrgYn" name="emlEmrgYn" value="N"/>
                        <button type="button" id="emrgBtn" class="btn btn-outline-danger btn-xs" onclick="toggleEmrg()">
                            긴급 X
                        </button>
                        <input type="text" class="form-control" id="write-subject" name="emlTtl"></div>


                    <!--<div class="mb-3"><label class="form-label fw-bold">첨부파일</label>
                        <input type="file" class="form-control" id="write-subject"></div>-->

                    <div class="mb-3">
                        <label class="form-label fw-bold" for="multipartFiles">첨부파일</label>
                        <div class="input-group">
                            <input
                                    type="file"
                                    class="form-control"
                                    id="multipartFiles"
                                    name="multipartFiles"
                                    multiple
                            />
                        </div>
                        <div class="form-text">여러 파일을 선택하려면 Ctrl 키를 누른 채 클릭하세요.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">내용</label>
                        <div class="form-control" id="contentsTemp"></div>
                    </div>
                    <div class="mb-3">
                        <div class="text-end"><button class="btn btn-primary px-4"  style="background-color:var(--point-color); border-color: var(--point-color);"type="button" onclick="sendMail()">보내기</button></div></div></form>
            </div>
        </div>
    </div>
</div>


<!-- 수신자 확인 모달 -->
<div class="modal fade modal-right-align" id="commonRecipientModal" data-bs-backdrop="false" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border border-secondary border-opacity-25" style="border-radius: 8px;background-color: white">
            <div class="modal-header border-bottom-0 py-2">
                <h6 class="modal-title" style="font-size: 0.9rem;">수신 확인</h6>
                <button type="button" class="btn-close" style="transform: scale(0.7);" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body bg-white py-1" id="recipientTableContainer">
            </div>
        </div>
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
    /*async function openRecipientModal(mailId) {
        const container = document.getElementById('recipientTableContainer');
        console.log(typeof mailId)

        data = {

            "emlNostr" : mailId
        }
        // 1. 기존 내용 비우기
        container.innerHTML = '';
// 2. 테이블 생성
        let tableHtml = `
        <table class="table bg-white table-hover" style="background-color: white;">
            <thead class="text-center">
                <tr>
                    <th>수신자</th>
                    <th>읽은 시간</th>
                </tr>
            </thead>
            <tbody class="text-center">
    `;

        axios.post("/email/receiptchk", mailId, {
            headers : {"Content-Type":"application/json;"}
        }).then(
            res=> {
                console.log(res.data);
                emailReceiverVOList = res.data.emailReceiverVOList;
                console.log(emailReceiverVOList);

                emailReceiverVOList.forEach(vo =>
                    {
                        console.log("vo 자체를 보자",vo);
                        console.log("vo에서 값이?",vo.empNm);
                    const readTime = vo.emlRcvngDt ? vo.emlRcvngDt.substring(0, 10)+"<br> "+vo.emlRcvngDt.substring(11, 16) : '<span class="text-secondary">읽지 않음</span>';
                        tableHtml += `
                            <tr>
                                <td>\${vo.empNm}</td>
                                <td>\${readTime}</td>
                            </tr>
                            `;
                });

                // 3. 데이터 루프

                tableHtml += `</tbody></table>`;

                // 4. 모달에 내용 주입 후 띄우기
                container.innerHTML = tableHtml;
                var myModal = new bootstrap.Modal(document.getElementById('commonRecipientModal'));
                myModal.show();
            }
        ).catch(err => console.error("에러났다! : ",err))


    }*/
    async function openRecipientModal(btn, mailId, yorn) {
        // 1. 이미 팝오버가 떠 있다면 닫기 (중복 방지)
        const existingPopover = bootstrap.Popover.getInstance(btn);
        if (existingPopover) {
            existingPopover.dispose();
        }

        // 2. 서버 데이터 호출
        axios.post("/email/receiptchk", mailId, {
            headers: { "Content-Type": "application/json;" }
        }).then(res => {
            const emailReceiverVOList = res.data.emailReceiverVOList;

            // 3. 테이블 HTML 생성
            let tableHtml = `
            <table class="table table-sm table-hover mb-0" style="font-size: 0.85rem; min-width: 200px;">
                <thead class="text-center table-light">
                    <tr>
                        <th style="padding: 5px;">수신구분</th>
                        <th style="padding: 5px;">수신자</th>
                        <th style="padding: 5px;">읽은 시간</th>
                    </tr>
                </thead>
                <tbody class="text-center">
        `;

            emailReceiverVOList.forEach(vo => {
                const readTime = vo.emlRcvngDt
                    ? `\${vo.emlRcvngDt.substring(0, 10)}<br>\${vo.emlRcvngDt.substring(11, 16)}`
                    : `<span class="text-secondary`+(`\${vo.emlRcvrType}`==='참조자'?'color:green;':'')+`">읽지 않음</span>`;

                tableHtml += `
                <tr>
                    <td style="padding: 5px; vertical-align: middle;`+(`\${vo.emlRcvrType}`==='참조자'?'color:green;':'')+`">\${vo.emlRcvrType}</td>
                    <td style="padding: 5px; vertical-align: middle;`+(`\${vo.emlRcvrType}`==='참조자'?'color:green;':'')+`">\${vo.empNm}</td>
                    <td style="padding: 5px; vertical-align: middle;`+(`\${vo.emlRcvrType}`==='참조자'?'color:green;':'')+`">\${readTime}</td>
                </tr>`;
            });

            tableHtml += `</tbody></table>`;

//만약 본문이면 오른쪽에 띄우기
            let leftorright = '';
            if(yorn=='y'){
                leftorright='right';
            }else{ leftorright='left';}

            // 4. 팝오버 생성 및 실행
            const popover = new bootstrap.Popover(btn, {
                title: '수신 확인',
                content: tableHtml,
                html: true,         // HTML 태그(테이블) 사용 허용
                placement: leftorright, // 버튼 오른쪽에 띄우기 (마우스 클릭 위치 근처)
                trigger: 'manual',  // 수동으로 제어
                sanitize: false,    // 테이블 태그 필터링 방지
                container: 'body'   // 화면 레이어 꼬임 방지
            });

            popover.show();

            // 5. 바깥 클릭하면 팝오버 닫기 기능
            document.addEventListener('click', function closePopover(e) {
                if (!btn.contains(e.target)) {
                    popover.hide();
                    document.removeEventListener('click', closePopover);
                }
            });

        }).catch(err => console.error("에러났다! : ", err));
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
        document.getElementById('mail-write-view').style.display = 'none';//메일쓰기
        document.getElementById('mail-success-view').style.display = 'none';//메일보내기 성공
    }


    document.addEventListener("DOMContentLoaded", function () {
        clearMailCookies()
        firstListFn();
// CKEditor
        ClassicEditor
            .create(document.querySelector('#contentsTemp'), {
                // 툴바 구성 (필요한 기능만 넣으세요)
                toolbar: [
                    'heading', '|', 'bold', 'italic', 'link', 'bulletedList',
                    'numberedList', '|', 'outdent', 'indent', '|',
                    'insertTable', 'blockQuote', 'undo', 'redo'
                ],
                placeholder: '내용을 입력해주세요.'
            })
            .then(editor => {
                // 나중에 폼 제출 시 값을 가져올 때 사용: editor.getData()
                editor.editing.view.change(writer => {
                    writer.setStyle('height', '500px', editor.editing.view.document.getRoot());
                });
                window.editor=editor;
                console.log('에디터가 성공적으로 로드되었습니다.');
            })
            .catch(error => {
                console.error('에디터 로드 중 오류 발생:', error);
            });
//검색 또는 페이지 이동 listFn
        const btnSearch=document.querySelector("#btnSearch");
        btnSearch.addEventListener("click",()=>{

            const data = {
                "currentPage":1,
                "mode":document.querySelector("select[name='mode']").value||"",
                "keyword":document.querySelector("input[name='keyword']").value||"",
            }
            console.log("btnSearch->data : ",data);
            axios.post("/email/listSendAxios",data,{
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
        axios.post("/email/listSendAxios", data, {
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
            row.setAttribute('data-id', item.emlNo);
            // 1. 데이터 ID를 요소에 명시적으로 저장
            row.dataset.emlNo = item.emlNo;

            // 2. 이벤트 핸들러 수정
            row.onclick = function (e) {
                // 체크박스 클릭 시에는 상세보기로 넘어가지 않게 방어
                if (e.target.classList.contains('mail-item-check')) return;
                if (e.target.classList.contains('material-icons')) {
                                       return}
                if (e.target.classList.contains('btn-light')) return;

                // 클릭된 row의 dataset에서 번호를 가져옴
                const id = this.dataset.emlNo;
                viewDetail(id);
            };
// ---  발송자 정보 : 이름 + 직위 + (팀)
            html += '<div class="form-check ms-2">'
                + '<input class="form-check-input mail-item-check"value="'+item.emlNo+'"type="checkbox"';

            if(!item.emailReceiverVOList || item.emailReceiverVOList.length == 0){
                html +=' disabled'
            }else if(item.emailReceiverVOList && item.emailReceiverVOList.length > 0) {
                    const allNull = item.emailReceiverVOList.every(vo => vo.emlRcvngDt == null);
                    // 조건에 따라 'disabled' 문자열을 생성
/*                    const disabledAttr = allNull ? '' : ' disabled';
                    html +=disabledAttr*/
                console.log("allNull",allNull )
                console.log("item.emlSndrDelYn",item.emlSndrDelYn )
                if(!allNull || item.emlSndrDelYn=='Y'){
                    html += 'disabled'
                }
            }

            html +='></div>';
            //html += '<span class="material-icons ms-3 ' + (item.emlImptYn === 'Y' ? 'text-warning' : 'text-secondary') + '" style="font-size:1.2rem; cursor:pointer;" data-impt="' + item.emlImptYn + '">' + (item.emlImptYn === 'Y' ? 'star' : 'star_border') + '</span>';

// ---  CC 전용 그리드 (너비를 40px로 고정하여 제목 시작 위치를 통일) ---
            html += '<div class="text-center" style="width:40px;">';
            if (item.emlOtsdYn == 'Y'){
                html += '<span class="badge bg-primary" style="font-size: 0.65rem; padding: 2px 4px; vertical-align: middle;">외부</span>';
            } else {
                if(item.emlSndrDelYn =='Y'){
                    html += '<span class="badge bg-secondary" style="font-size: 0.65rem; padding: 2px 4px; background-color: #C3C3C3 !important; vertical-align: middle;">회수</span>';
                }else {
                    html += '<span class="badge bg-secondary" style="font-size: 0.65rem; padding: 2px 4px; vertical-align: middle;">내부</span>';
                }
            }
            html += '</div>';

// 1. 제목 영역
            // 모든 사람이 안읽은 경우
            let titleallRcvrNullhtml='';
            if(item.emailReceiverVOList && item.emailReceiverVOList.length > 0) {
                const titleallRcvrNull = item.emailReceiverVOList.every(vo => vo.emlRcvngDt == null);
                // 모든 사람이 안읽은 경우
                titleallRcvrNullhtml = titleallRcvrNull ? ` fw-bold` : ``;
            }
            // 회수된 메일일 경우
            let emlSndrDelYn=''
            if(item.emlSndrDelYn=='Y'){
                emlSndrDelYn='color:#C3C3C3 '
            }
            html += '<div class="flex-grow-1 text-truncate px-2'+titleallRcvrNullhtml+'"style="max-width: 1080px; min-width: 0; word-break: break-all;'+ (item.emlEmrgYn==='Y' ? ' color:red;' : '') +emlSndrDelYn + '">';
            html +=     '<span>' + (item.emlEmrgYn==='Y' ? '[긴급]' : '') + item.emlTtl + '</span>';
            html += '</div>';

// 2. 클립 전용 그리드 (세로 줄 유지)
            html += '<div class="text-center" style="width:40px;">';
            html +=     (item.fileId !== 0 ? '<span class="fas fa-paperclip text-muted"></span>' : '');
            html += '</div>';

// 3. 날짜 영역 (보낸날짜)

            html += '<div class="text-end text-muted small pe-2" style="width:100px;'+emlSndrDelYn+'!important;">'
                + item.emlSndngDt.substring(5, 10)
                + '&nbsp;&nbsp;&nbsp;' + item.emlSndngDt.substring(11, 16) + '</div>';
//받은 사람 (수신인)
        if(item.emlSndrDelYn=='N') {
            if (item.emailReceiverVOList.length > 1) {

                html += `<div class="text-center text-muted small pe-2 ms-4 text-truncate" style="width:150px;">`
                html += `<button class="btn btn-sm btn-light border text-secondary d-inline-flex align-items-center"
                            onclick="openRecipientModal(this,\${item.emlNo}, 'n')">수신확인</button></div>`;

            } else if (item.emailReceiverVOList.length === 1) {

                html += '<div class="ms-4 text-truncate '
                    //+ (!item.emlRcvngDt ? 'fw-bold' : '')
                    + '" style="width:150px;" ' +
                    'title="' + (item.emailReceiverVOList[0].empNm != null ? item.emailReceiverVOList[0].empNm : "") + ' ' +
                    (item.emailReceiverVOList[0].empJbgd != null ? item.emailReceiverVOList[0].empJbgd : item.emlOtsdSndrAddr + "&nbsp;") +
                    '(' + (item.emailReceiverVOList[0].deptNm != null ? item.emailReceiverVOList[0].deptNm : "외부") + ')' + '">'
                    + (item.emailReceiverVOList[0].empNm != null ? item.emailReceiverVOList[0].empNm : "") + ' '
                    + (item.emailReceiverVOList[0].empJbgd != null ? item.emailReceiverVOList[0].empJbgd : item.emlOtsdSndrAddr + "&nbsp;") +
                    '(' + (item.emailReceiverVOList[0].deptNm != null ? item.emailReceiverVOList[0].deptNm : "외부") + ')'
                    + '</div>';

            } else if (item.emailReceiverVOList.length === 0) {
                html += '<div class="ms-4 text-truncate '
                    //+ (!item.emlRcvngDt ? 'fw-bold' : '')
                    + '" style="width:150px;">'
                    + item.emlOtsdRcvrAddr +
                    '</div>';
            }
//수신 날짜
            if (item.emailReceiverVOList.length === 1) {
                //
                html += '<div class="text-end text-muted small pe-2" style="width:100px; color: black;font-weight: bold">'
                    + (item.emailReceiverVOList[0].emlRcvngDt != null ? item.emailReceiverVOList[0].emlRcvngDt.substring(5, 10) : "")
                    + '&nbsp;&nbsp;&nbsp;' + (item.emailReceiverVOList[0].emlRcvngDt != null ? item.emailReceiverVOList[0].emlRcvngDt.substring(11, 16) :
                        `
                    <button class="btn-sm btn-light border text-secondary d-inline-flex align-items-center" style="background-color:white; border-radius: 20%">
                            읽지 않음 </button>`)
                    + '</div>';
            } else if (item.emailReceiverVOList.length === 0) {
                //외부메일 -확인불가 : 발송일시 출력
                html += '<div class="text-end text-muted small pe-2" style="width:100px;">'
                    + item.emlSndngDt.substring(5, 10)
                    + '&nbsp;&nbsp;&nbsp;' + item.emlSndngDt.substring(11, 16) + '</div>';
            } else {
                html += '<div class="text-end text-muted small pe-2" style="width:100px; color: black;font-weight: bold">'
                const noreadallRcvrNull = item.emailReceiverVOList.every(vo => vo.emlRcvngDt == null);
                // 모든 사람이 안읽은 경우
                const noread = noreadallRcvrNull ? `<button class="btn-sm btn-light border text-secondary d-inline-flex align-items-center" style="background-color:white; border-radius: 20%">
                            읽지 않음 </button>` : ``;

                html += noread + '</div>';
            }
        } else if(item.emlSndrDelYn=='Y'){ html += `<div class="text-muted small pe-2" style="width: 250px; color: #C3C3C3 !important; text-align: center !important; margin-left: 1.5rem !important;"> 회수된 메일입니다. </div>`;}

////////////////////////////////////// 아래는 페이지
            const min = Math.min(...articlePage.content.map(vo => vo.rnum));

            const max = Math.max(...articlePage.content.map(vo => vo.rnum));
            let str ='';
            str+='<b id="page-info">'+min+'-'+max+'</b> of <span id="total-count">'+articlePage.total+'</span>'

            if(articlePage.content.length===0){ //결과 없을 때 처리
                html = '메일이 0건입니다.'
                str ='<b id="page-info">0</span>'
            }
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
        clearWriteForm();
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
        axios.post("/email/listSendAxios", data, {
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
                    str='<b id="page-info">0</b>';
                }

                str+='<b id="page-info">'+min+'-'+max+'</b> of <span id="total-count">'+articlepage.total+'</span>'
                document.getElementById("count").innerHTML=str;

            })
            .catch(err => {
                console.error("err : ", err);
            });
    }//end firstListFn




    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //상세보기 비동기
    async function viewDetail(emlNo) {
        //let mail = allMails.find(function(m) { return m.emlNo === emlNo; });
        //클릭 메일의 VO를 가져올 것
/*        const data = {"emlNo": emlNo}
        axios.post("/email/detailSendAxios", data, {
            headers: {
                "Content-Type": "application/json"
            }*/
        axios.post("/email/receiptchk", emlNo, {
            headers : {"Content-Type":"application/json;"}
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
            }``
            let profileSrc='';
            //상세보기에서 이미지 띄우기 - 1명일때는 프로필사진, 여러명일 때는 기본이미지
            if(mail.emailReceiverVOList && mail.emailReceiverVOList.length === 1) {
                 profileSrc =
                    `/displayPrf?fileName=\${mail.emailReceiverVOList[0].empProfile}` ;
                console.log("프로필이미지?? 111", profileSrc);
            }else{
                 profileSrc =  '/displayPrf?fileName=defaultimg.png';
                console.log("프로필이미지?? 222", profileSrc);

            }
            document.getElementById('detail-title').innerText = mail.emlTtl;
            document.getElementById('empProfile').src= profileSrc
            //초기화
            document.getElementById('detail-sender').innerHTML = `<span class="flex-grow-1">\${mail.empNm}</sapn>`;
            //초기화
            document.getElementById('forthebtn').innerHTML ='';
            if(mail.emailReceiverVOList && mail.emailReceiverVOList.length>0) {
                document.getElementById('forthebtn').innerHTML =
                    `<button class="btn btn-sm btn-light border text-secondary"
                            onclick="openRecipientModal(this,\${mail.emlNo}, 'y')">수신확인</button>`
            }
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
                mail.emlCn;

            document.getElementById("detail-btns-footer").innerHTML=
            //보낸 메일함은 답장 기능이 없다
                //+'<button class="btn btn-success btn-sm" onclick="showWriteView()">답장</button>'
                '&nbsp;&nbsp;<button class="btn btn-success btn-sm"  style="background-color:var(--point-color); border-color: var(--point-color);" onclick=" emailForward('+mail.emlNo+')">전달</button>';
            //회수가능시에만 보이게 하기
            if(mail.emailReceiverVOList && mail.emailReceiverVOList.length > 0) {
                const titleallRcvrNull = mail.emailReceiverVOList.filter(vo => vo.emlRcvrType === '수신자').every(vo => vo.emlRcvngDt == null);
                if(titleallRcvrNull) {
                    document.getElementById("detail-btns-footer").innerHTML +=
                        '&nbsp;&nbsp;<button class="btn btn-secondary btn-sm float-end" onclick="isDeleted(' + mail.emlNo + ')">회수</button>';
                }
            }
            // 모든 사람이 안읽은 경우

            hideAll();
            document.getElementById('mail-detail-view').style.display = 'block';

            //답장에 넣을 요소들
            //받는사람 (참조자는 X) div
/*            let reReceiver=
                '<span class="mention-btn" data-no="' + mail.emlSndrId + '" contenteditable="false">'
                + '@' + mail.empNm
                + '<a class="del-mention">X</a>' // x 버튼 추가
                + '</span>&nbsp; <input type=hidden name="emlNo" value="'+mail.emlSndrId+'">';
            document.getElementById('receiver').innerHTML=reReceiver;*/
            //제목 input
            document.getElementById('write-subject').value='(전달)'+mail.emlTtl;
            //내용
            if (window.editor) {
                const originalContent = `
            <br><br>
            ------------ 원본 메일 ------------<br>
            <b>보낸 사람:</b> \${mail.empNm}<br>
            <b>날짜:</b>\${mail.emlSndngDt.substring(0, 10)}\${['일','월','화','수','목','금','토'][new Date(mail.emlSndngDt).getDay()]}\${mail.emlSndngDt.substring(12, 16)}<br>
            <b>제목:</b> \${mail.emlTtl}<br>
            <b>내용:</b><br>
            \${mail.emlCn}
            `;
                window.editor.setData(originalContent);
            }


        })
            .catch(err => {
                console.error("err : ", err);
            });

        //mail.isRead = true;
        //listFn(0,1);
    }//상세보기 끝

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
            requireAnyChar: true,
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
                    + '</span>&nbsp; <input type=hidden name="emlNo" value="'+item.original.empId+'">';
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
            requireAnyChar: true,
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
                    + '</span>&nbsp; <input type=hidden name="emlNoCc" value="'+item.original.empId+'">';
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
    //메일 발송
    const sendMail = async ()=>{

        const formElement = document.getElementById('sendMailForm');

        const mentionSpans = document.querySelectorAll('#receiver .mention-btn'); //받는사람
        const mentionSpansCc = document.querySelectorAll('#cC .mention-btnCc');   //참조자

        //1. 유효성 검사 : 받는사람 - 받는 사람 없으면 경고창 출력
        console.log("받는사람이 없나?", mentionSpans);
        if(mentionSpans.length === 0){
            alert("받는 사람을 한 명 이상 설정해야 합니다.");
            return;
        }

        const formData = new FormData(formElement);
        formData.append('emlCn', window.editor.getData()); //내용
        // 각 span의 data-no 값을 뽑아서 formData에 추가
        mentionSpans.forEach(span => {
            const empNo = span.getAttribute('data-no'); // 사원번호 추출
            if (empNo) {
                // 서버의 List<String> emlNos 필드와 이름을 맞추기
                formData.append('emlNos', empNo);
            }
        });
        mentionSpansCc.forEach(span => {
            const empNo = span.getAttribute('data-no'); // 사원번호 추출
            if (empNo) {
                // 서버의 List<String> emlCcIds 필드와 이름을 맞추기
                formData.append('emlCcIds', empNo);
            }
        });

        //2. 서버 전송
        axios.post("/email/send", formData
        ).then(function (response) {
            //요청 성공 시 응답 데이터 출력
            console.log("result : ", response.data);
            alert("전송되었습니다.");

            document.getElementById('mail-write-view').style.display = 'none';//메일쓰기

            document.getElementById('mail-success-view').style.display = 'block';

            // --- [ 폼 초기화 시작 ] ---

            clearWriteForm();

            // --- [ 폼 초기화 끝 ] ---

        })
            .catch(function (error) {
                //오류 발생 시 콘솔에 출력
                alert("전송에 실패했습니다. 다시 시도해 주세요.");
                console.log("error : ", error);
            });
    }
    ///////////////////////////////////메일 보내기 영역 끝/////////////////////////////////////////////////////////////////////////

    /////////전역함수 /////////////////////////////////////////////////////////////////////////////////////////
    // 이미지 미리보기///

    function handleImgFileSelect(e) {
        // 2. 값 가져오기
        // 3. 파일 목록 가져오기
        const files = e.target.files;
        // 4. 배열로 변환 (Array.from은 최신 자바스크립트 문법입니다)
        const fileArr = Array.from(files);
        // 5. 반복문 실행
        fileArr.forEach(function (f) {
            // MIME 타입 확인 (동일)
            /*if (!f.type.match("image.*")) {
                //이미지만 미리보기 되어야 함.
                alert("이미지 확장자만 가능합니다.");
                return;
            }*/
            //파일 리더 준비
            const reader = new FileReader();
            //이미지를 모두 읽었다면 함수 실행
            //e : 파일을 읽은 이벤트
            reader.onload = function (e) {
                // 6. 템플릿 리터럴
                const str = `
                     <div class="product-image-thumb divFileSave" style="cursor:pointer;" data-file-sn="1" data-file-group-no="${fileGroupNo}">
                        <img src="\${e.target.result}" alt="Product Image">
                     </div>
                  `;
                // 7. HTML 추가하기
                // insertAdjacentHTML('beforeend', html문자열)은
                // jQuery의 append()와 똑같이 '자식 요소들의 맨 뒤'에 추가해줍니다.
                /*
                                  */
                const divImg = document.getElementById("divImg");
                if (divImg) {
                    divImg.insertAdjacentHTML("beforeend", str);
                }
            };
            reader.readAsDataURL(f);
        });
    }


    function toggleAllChecks(main) {
        var checks = document.querySelectorAll('.mail-item-check');
        checks.forEach(function(c) { if (!c.disabled) {
            c.checked = main.checked;
        } });
    }


    //체크박스 처리
    const handleMailAction = (readOrDelOrImpt) => {
        // 1. 체크된 체크박스들만 가져오기
        const checkedInputs = document.querySelectorAll('.mail-item-check:checked');

        // 2. 체크박스의 value(emlNo)를 추출해서 배열로 만들기
        const selectedEmlNos = Array.from(checkedInputs).map(input => input.value);

        // 3. 선택된 게 하나도 없을 때 예외 처리
        if (selectedEmlNos.length === 0) {
            // 1. 선택된 메일이 없을 때 경고창 (알람 리팩토링)
            AppAlert.warning('선택된 메일 없음', '회수할 메일을 선택해 주세요.', null, 'priority_high'); // (알람 리팩토링)
            return;
        }

// 4. 전송 (배열을 넘길 때는 객체에 담아서 보내는 게 서버에서 받기 편합니다)

// 2. 회수 여부 확인 컨펌창 (알람 리팩토링)
        AppAlert.confirm('메일 회수', '회수 후에는 복구가 불가합니다. <br>정말 회수하시겠습니까?', '확인', '취소', 'restore_from_trash', 'danger') // (알람 리팩토링)
            .then((result) => {
                if (result.isConfirmed) {
                    axios.post('/email/readOrDelOrImpt', {
                        readOrDelOrImpt: readOrDelOrImpt,
                        emlNos: selectedEmlNos
                    })
                        .then(res => {
                            if (res.data > 0) {
                                // 3. 처리 완료 후 자동 닫힘 알림 (알람 리팩토링)
                                AppAlert.autoClose('회수 완료', '회수 및 삭제 처리되었습니다.', 'check_circle', 'success') // (알람 리팩토링)
                                    .then(() => {
                                        location.reload(); // 리스트 새로고침
                                    });
                            }
                        })
                        .catch(err => {
                            // 4. 에러 발생 시 알림 (알람 리팩토링)
                            AppAlert.error('오류 발생', '처리 중 문제가 발생했습니다.', null, 'report_gmailerrorred'); // (알람 리팩토링)
                            console.error("에러 발생:", err);
                        });
                }
            });

    };

    //회수 단건 처리
    const isDeleted=(emlNo)=>{
        // 1. 회수 확인 컨펌창 호출 (알람 리팩토링)
        AppAlert.confirm('이메일 회수', '해당 이메일을 회수하시겠습니까?', '회수하기', '취소', 'settings_backup_restore', 'primary')
            .then((result) => {
                if (result.isConfirmed) {
                    // 2. 확인 버튼 클릭 시에만 axios 호출
                    axios.get("/email/reCallOne/" + emlNo)
                        .then(res => {
                            // 성공 시 자동 닫힘 알림 (알람 리팩토링)
                            AppAlert.autoClose('회수 성공', '이메일이 정상적으로 회수되었습니다.', 'check_circle', 'success');
                        })
                        .catch(error => {
                            // 에러 발생 시 알림 (알람 리팩토링)
                            AppAlert.error('회수 실패', '회수 처리 중 오류가 발생했습니다.', null, 'error_outline');
                            console.error(error);
                        });
                }
            });
    }


    const clearWriteForm=()=>{
        const formElements = document.getElementById('sendMailForm');

        // 1) 기본 input, select, file 필드 초기화
        formElements.reset();

        // 2) ContentEditable 레이어 (받는 사람, 참조자) 비우기
        document.getElementById('receiver').innerHTML = '';
        document.getElementById('cC').innerHTML = '';

        // 3) CKEditor5 내용 비우기
        if (window.editor) {
            window.editor.setData('');
        }

        // 4) 긴급 버튼 상태 초기화 (필요 시)
        const emrgBtn = document.getElementById('emrgBtn');
        const emrgInput = document.getElementById('emlEmrgYn');
        emrgInput.value = 'N';
        emrgBtn.classList.remove('btn-danger');
        emrgBtn.classList.add('btn-outline-danger');
        emrgBtn.innerText = '긴급 X';

    }

    /////전역함수 끝//////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //전달//
    function emailForward(emlRcvrId){
// 1. 동적으로 form 생성
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '/email/forwardsend'; // 컨트롤러의 @PostMapping 주소

        // 2. emlNo 데이터를 담을 input 생성
        const hiddenField = document.createElement('input');
        hiddenField.type = 'hidden';
        hiddenField.name = 'emlRcvrId'; // 컨트롤러 파라미터 이름과 일치해야 함
        hiddenField.value = emlRcvrId;
        console.log("emlRcvrId", emlRcvrId);
        form.appendChild(hiddenField);

        // 3. body에 붙여서 전송
        document.body.appendChild(form);
        form.submit();

    }

</script>