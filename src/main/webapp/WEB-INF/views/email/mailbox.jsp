<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<style>
    /* 1. 컨테이너: 기존 코드 유지 */
    .mail-folder-container {
        width: 240px;
        background: #ffffff;
        border-right: 1px solid #e1e4e8;
        display: flex;
        flex-direction: column;
        transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        overflow: hidden;
        position: relative; /* 버튼 위치 기준 */
    }

    .mail-folder-container.closed {
        width: 0px;
        border-right: none;
    }

    /* 2. 토글 버튼: 메인 영역 내부(절대 위치)로 고정 */
    .folder-toggle-handle {
        position: sticky; /* 스크롤해도 따라오게 고정 */
        left: 0;
        top: 20px;
        width: 24px;
        height: 44px;
        background: #fff;
        border: 1px solid #e1e4e8;
        border-left: none;
        border-radius: 0 5px 5px 0;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        z-index: 999; /* 네비바보다는 낮고 콘텐츠보다는 높게 */
        box-shadow: 2px 0 5px rgba(0,0,0,0.05);
        margin-left: -1px; /* 트리 경계선에 딱 붙임 */
        align-self: flex-start; /* flex 라인 최상단 고정 */
    }

    .folder-toggle-handle:hover {
        background: #f8f9ff;
    }

    .folder-toggle-handle i {
        font-size: 20px;
        color: #696cff;
    }

    /* 나머지 스타일 유지 */
    .folder-header {/* padding: 20px; display: flex; align-items: center; justify-content: space-between; white-space: nowrap; }*/
        padding: 12px 20px; display: flex; align-items: center; cursor: pointer; color: #444; font-size: 14px; white-space: nowrap; transition: background 0.2s;
    }
    .folder-item { padding: 12px 20px; display: flex; align-items: center; cursor: pointer; color: #444; font-size: 14px; white-space: nowrap; transition: background 0.2s; }
    .folder-item:hover { background: #f0f2ff; color: #696cff; }
    .folder-item i { margin-right: 10px; font-size: 18px; color: #a3aed0; }
    .page-content{
        padding-left:0 !important;
        padding-top:0 !important;
        padding-bottom:0 !important;
    }

    #inserbtn{
        background-color: #FFFFFF;
        color:var(--point-color);
        border-radius: 5px;
        border : none;
        /*border: var(--point-color) solid 1px;*/
    }
     .sub-menu {
         border-left: 1px dashed #ddd;
         margin-left: 20px;
         transition: all 0.2s;
     }
    .folder-item {
        display: flex;
        align-items: center;
        padding: 10px 15px;
        cursor: pointer;
        font-size: 14px;
        color: #444;
    }
    .folder-item:hover { background: #f0f2ff; color: #696cff; }
    .folder-item i { font-size: 18px; margin-right: 8px; }
    .ms-auto { margin-left: auto; } /* 화살표 오른쪽 정렬 */

    #customMailboxListFrame{
        overflow: auto;
        width: 100%;
        /* 패딩이 너비 100%를 초과하지 않게 설정 */
        box-sizing: border-box;
        /* 액자 틀의 두께 */
        padding: 10px;
        /* 배경색 설정 */
        background-color: #F4F6FF;
        /* 배경색을 패딩 안쪽(콘텐츠)에만 채워서 액자 효과 내기 */
        background-clip: padding-box;
        clip-path: inset(10px 10px 0 10px);
    }
         /* 다른 CSS랑 안 겹치게 고유 접두어 사용 */
     #my-mailbox-context-menu {
         font-family: sans-serif;
     }

    .mailbox-action-item {
        padding: 10px 16px;
        font-size: 14px;
        color: #374151 !important; /* 강제 색상 지정 */
        cursor: pointer;
        display: block !important;
        text-decoration: none;
        transition: background 0.15s;
    }

    .mailbox-action-item:hover {
        background-color: #f3f4f6 !important;
        color: #696cff !important;
    }

    .mailbox-action-divider {
        height: 1px;
        background-color: #e5e7eb;
        margin: 4px 0;
    }

    .mailbox-action-item.text-danger {
        color: #ef4444 !important;
    }
</style>
<div class="mail-folder-container" id="mailFolderTree1" >
    <div class="folder-header">
        <span class="fw-bold" style="font-size: 1.1rem; ">개인 보관함</span>

    </div>

    <div class="folder-list">
        <div class="folder-item" onclick="setCookieNum('pageFilter', 'All')">
            <i class="material-icons">all_inbox</i>전체보기
        </div>

        <div class="folder-item" onclick="setCookieNum('pageFilter', 'isImpt')">
            <i class="material-icons">star_outline</i>중요 보관
        </div>


        <div class="mail-folder-container" id="mailFolderTree2" style="width:100%;">
            <div class="folder-header" style="display: flex; justify-content: space-between">
                개인 보관함
                <i class="material-icons" style="color: var(--point-color)"
                onclick="createRootBox()">add</i>
            </div>
            <div class="folder-list" id="customMailboxListFrame">

                <div class="folder-list" id="customMailboxList">
                <div class="text-center py-3 text-muted" style="font-size:12px;">불러오는 중...</div>
                </div>
            </div>
        </div>



    </div>
</div>
<div class="folder-toggle-handle" onclick="toggleMailFolder()" id="folderToggleBtn">
    <span class="material-icons" id="toggleIcon" style="font-size: 20px; color: #696cff;">chevron_left</span>
</div>

<script>

    document.addEventListener("DOMContentLoaded", function() {
        // 페이지 로드 시 메일함 목록 호출
        getMailboxList();
    });

    // "이동"클릭시 가져오기
    function toMailBoxFun(){
        const toMailBox=document.getElementById("toMailBox");
        toMailBox.innerHTML=`<li style="font-weight: bold; padding-left: 10px;" onclick="handleMailBoxAction(0,'')">메일함에서 빼기</li>`
        axios.post("/email/mailboxlist")
            .then(res => {
                const mailBoxes = res.data;
                mailBoxes.forEach( mailbox=>{
/*                    <ul class="dropdown-menu">
                      <ul class="dropdown-menu" id="toMailBox">
                        <li><a class="dropdown-item fw-bold" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'All')">전체 메일</a>
                        </li>
                        <li><a class="dropdown-item" href="javascript:void(0)" onclick="setCookieNum('pageFilter', 'isNotRead')">안읽은 메일</a>
                        </li>*/
                    const li = document.createElement('li');
                    const a = document.createElement('a');
                    a.classList="dropdown-item"
                    a.href="javascript:void(0)"
                    //아래 코드는 사용불가
                    /*a.onClick=`setCookieNum('pageFilter', '\${mailbox.emlBoxNo}')`*/
                        a.addEventListener('click', function() {
                            console.log("클릭된 박스 번호:", mailbox.emlBoxNo);
                            handleMailBoxAction(mailbox.emlBoxNo, mailbox.emlBoxTtl);
                        });
                    //str 초기화
                        let prefix = "";

                        if (mailbox.level > 1) {
                            // (level - 1)만큼 공백을 반복하고 끝에 "ㄴ"을 붙임
                            prefix = "&nbsp;".repeat((mailbox.level - 2) * 4) + "┕";
                        }

                        a.innerHTML = prefix + mailbox.emlBoxTtl; // (알람 리팩토링 - 텍스트 처리)
                        li.appendChild(a);
                        toMailBox.appendChild(li);

                    }
                )
            })
    .catch(err => console.error("메일함 로드 실패:", err));

    }
    // 메일함 목록 호출
    function getMailboxList() {
        axios.post("/email/mailboxlist")
            .then(res => {
                const list = res.data;
                const container = document.getElementById('customMailboxList');
                container.style.overflow="auto";
                container.style.width="100%";
                container.style.background="#F4F6FF";
                container.style.backgroundClip="content-box"
                container.style.boxSizing="border-box"

                container.style.paddingRight="10px";
                container.innerHTML = ""; // 초기화

                // 1. 최상위 부모들 찾기 (EML_BOX_UP_NO가 null이거나 0인 것)
                const parents = list.filter(item => !item.emlBoxUpNo || item.emlBoxUpNo == 0);

                if(parents.length === 0) {
                    container.innerHTML = '<div class="ps-4 py-2 text-muted" style="font-size:12px;">생성된 보관함이 없습니다.</div>';
                    return;
                }

                // 2. 부모별로 트리 생성
                parents.forEach(parent => {

                    container.appendChild(createBoxTree(parent, list));
                });
            })
            .catch(err => console.error("메일함 로드 실패:", err));
    }

    /**
     * 계층형 트리 생성 (재귀 함수)
     */
    function createBoxTree(item, allList) {
        // 자식들 찾기
        const children = allList.filter(child => child.emlBoxUpNo == item.emlBoxNo);
        const hasChildren = children.length > 0;

        // 부모/폴더 노드 생성
        const wrapper = document.createElement('div');
        /*wrapper.style.paddingRight="20px";*/
        const toggleBtn = hasChildren
            ? '<span class="material-icons fs-6 ms-auto" style="color: #adb5bd; cursor: pointer;" onclick="toggleSub(\'sub-' + item.emlBoxNo + '\')">expand_more</span>'
            : '';
        // 폴더 아이템 HTML
        let html =
////여기 onclick에서 toggleSub도 하고 setCookieNumMailBox도 함 (자식있으면)
            `<div class="folder-item" id="folder-\${item.emlBoxNo}"
            onclick=" setCookieNumMailBox(\${item.emlBoxNo},'\${item.emlBoxTtl}')"
            style="display: flex; align-items: center; padding-right: 20px;">
            <i class="material-icons">\${hasChildren ? 'folder_shared' : 'label'}</i>

            <span id="text-area-\${item.emlBoxNo}" style="padding-right:15px;">\${item.emlBoxTtl}</span>

`+toggleBtn+`

             <span class="material-icons fs-6 ms-auto"
            style="color: #adb5bd; cursor: pointer;"
            onclick="event.stopPropagation(); showBoxMenu(this, \${item.emlBoxNo}, '\${item.emlBoxTtl}')">
            more_vert
            </span>

            </div>
            `;
        /*<span className="material-icons fs-6 v-align-middle ms-auto" style="color: #adb5bd;">more_vert</span>*/
        // 자식이 있다면 서브 메뉴 div 생성
        if (hasChildren) {
            html += `<div id="sub-\${item.emlBoxNo}" class="sub-menu" style="display:none; /*background:#f9f9f9;*/"></div>`;
        }

        wrapper.innerHTML = html;

        // 자식 노드들을 서브 메뉴 div에 재귀적으로 추가
        if (hasChildren) {
            const subDiv = wrapper.querySelector("#sub-" + item.emlBoxNo);
            children.forEach(child => {
                // 자식은 한 단계 더 들어간 느낌을 주기 위해 ps-4 등 클래스 추가 가능
                const childNode = createBoxTree(child, allList);
                childNode.style.paddingLeft = "15px"; // 계층 깊이 표현
                subDiv.appendChild(childNode);
            });
        }

        return wrapper;
    }

    function showBoxMenu(target, boxNo, boxTtl) {
        // 1. 기존 메뉴 제거
        const existing = document.getElementById('my-mailbox-context-menu');
        if (existing) existing.remove();

        // 2. 메뉴 생성 (고유 ID 부여)
        const menu = document.createElement('div');
        menu.id = 'my-mailbox-context-menu';

        // 3. 인라인 스타일로 레이아웃 강제 고정 (납작함 방지)
        Object.assign(menu.style, {
            position: 'fixed',
            zIndex: '99999',
            background: '#ffffff',
            border: '1px solid #d1d5db',
            borderRadius: '6px',
            boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
            minWidth: '100px',
            width: 'max-content', // 내용물 길이에 맞게 벌어짐
            height: 'auto',
            overflow: 'visible',  // 내용물 안 잘리게
            display: 'block'
        });

        // 4. 고유한 클래스명을 가진 내부 HTML
        menu.innerHTML = `
        <div class="mailbox-action-item" onclick="changeToInput(\${boxNo}, '\${boxTtl}', 'update')">이름 수정</div>
        <div class="mailbox-action-item" onclick="changeToInput(\${boxNo}, '', 'insert')">하위 생성</div>
        <div class="mailbox-action-divider"></div>
        <div class="mailbox-action-item text-danger" onclick="validateAndDelete(\${boxNo})">메일함 삭제</div>
    `;

        // 5. 좌표 설정
        const rect = target.getBoundingClientRect();
        menu.style.top = (rect.bottom + 5) + "px";
        menu.style.left = (rect.left) + "px";

        document.body.appendChild(menu);

        // 메뉴 닫기 로직
        setTimeout(() => {
            const closer = (e) => {
                if (!menu.contains(e.target)) {
                    menu.remove();
                    document.removeEventListener('click', closer);
                } else{menu.remove();}
            };
            document.addEventListener('click', closer);
        }, 0);
    }
//새 메일함 추가
    function createRootBox() {
        // 1. 메일함 전체를 감싸고 있는 가장 바깥쪽 ID (예: 'mail-box-list')
        const rootContainer = document.getElementById("customMailboxList");

        if (!rootContainer) {
            console.error("메일함 목록 컨테이너를 찾을 수 없습니다.");
            return;
        }

        // 2. 이미 열려있는 임시 입력창이 있다면 삭제 (중복 생성 방지)
        const existingTemp = document.getElementById("new-box-temp");
        if (existingTemp) existingTemp.remove();

        // 3. 새로운 입력창을 담을 div 생성
        const newDiv = document.createElement('div');
        newDiv.id = "new-box-temp";
        newDiv.className = "folder-item"; // 기존 스타일 유지용 클래스

        // 4. Input 구조 넣기 (부모가 없으므로 boxNo는 0 또는 null 전달)
        // mode는 'insertRoot' 등으로 구분해서 서버에서 부모 없이 처리하게 함
        newDiv.innerHTML = `
        <i class="material-icons">label</i>
        <input type="text" id="active-input" value="" placeholder="새 메일함 이름"
               style="width:120px; border:1px solid #696cff; outline:none;"
               onkeyup="if(window.event.keyCode==13) processBox('insertRoot', 0)">
    `;

        // 5. 목록의 맨 위에 추가 (prepend)
        rootContainer.prepend(newDiv);

        // 6. 바로 입력 가능하게 포커스
        document.getElementById("active-input").focus();
    }

// 이름변경 또는 메일함 추가
    function changeToInput(boxNo, boxTtl, mode) {
        const textArea = document.getElementById("text-area-" + boxNo);
        let subArea = document.getElementById("sub-" + boxNo);
        const folderItem = textArea.closest('.folder-item');
        let targetArea = textArea;
        if(mode === 'insert') {
            // 하위생성이면 서브메뉴 열고 맨 위에 빈 input 추가

            if (!subArea) {
// 1. subArea 생성 (예시 HTML 구조와 동일하게 padding-left가 들어간 div로 감쌈)
                const wrapper = document.createElement('div');
                wrapper.style.paddingLeft = "15px";

                subArea = document.createElement('div');
                subArea.id = "sub-" + boxNo;
                subArea.className = "sub-menu";


                wrapper.appendChild(subArea);

                // [핵심] folder-item의 형제로 넣어줘야 옆으로 안 붙고 아래로 떨어집니다.
                folderItem.insertAdjacentElement('afterend', wrapper);
            }
            subArea.style.display = "block";
            if (document.getElementById("new-box-temp")) document.getElementById("new-box-temp").remove();

            const newDiv = document.createElement('div');
            newDiv.id = "new-box-temp";
            newDiv.style.paddingLeft = "20px";
            subArea.prepend(newDiv);
            targetArea = newDiv;
        }

        targetArea.innerHTML = `
        <input type="text" id="active-input" value="\${boxTtl}"
               style="width:120px; border:1px solid #696cff;"
               onkeyup="if(window.event.keyCode==13) processBox('\${mode}', \${boxNo})">
    `;
        document.getElementById("active-input").focus();
    }

    function processBox(mode, boxNo) {
        const inputVal = document.getElementById("active-input").value;
        if(!inputVal) return;

        const msg = (mode === 'update') ? `메일함 이름을 다음과 같이 바꾸시겠습니까?<br> "\${inputVal}" ` : `다음 이름으로 메일함을 생성하시겠습니까?<br> "\${inputVal}"`;

        // 사용자님의 AppAlert 사용
        AppAlert.confirm("확인", msg, ).then((result) => {
            let url = (mode === 'update') ? "/email/updateBox" : "/email/insertBox";
            let data = (mode === 'update')
                ? {emlBoxNo: boxNo, emlBoxTtl: inputVal}
                : {emlBoxUpNo: boxNo, emlBoxTtl: inputVal};

            axios.post(url, data).then(res => {
                const scsmsg= (mode === 'update') ?'메일함 이름이 변경되었습니다.':'메일함이 추가되었습니다.';
                AppAlert.success("성공", scsmsg);
                getMailboxList(); // 목록 새로고침
            });
        })
    }

    function validateAndDelete(boxNo) {
        // 1단계: 하위 박스 존재 여부 (DOM에서 체크)
        const subContainer = document.getElementById("sub-" + boxNo);
        if(subContainer && subContainer.children.length > 0) {
            AppAlert.error("실패", "하위 메일함이 존재하여 삭제할 수 없습니다.");
            return;
        }

        // 2단계: 메일 존재 여부 (서버 비동기 체크)
        axios.post("/email/checkMailExist", { emlBoxNo: boxNo }).then(res => {
            if(res.data > 0) {
                AppAlert.error("실패", "메일함에 보관된 메일이 있어 삭제할 수 없습니다.");
            } else {
                // 3단계: 최종 삭제 컨펌
                AppAlert.confirm("삭제", "정말 삭제하시겠습니까?").then(result =>{
                    axios.post("/email/deleteBox", { emlBoxNo: boxNo })
                        .then(res => {
                            console.log(res.data);
                                AppAlert.success("성공", "메일함이 삭제되었습니다.");
                            getMailboxList();
                        }).catch(error=> {
                        console.error("에러입니다", error)
                    });
                })

            }
        });
    }


    //메일박스 수정 토글
    function toggleEditButtons(boxNo) {
        const area = document.getElementById(`edit-area-\${boxNo}`);

        // 버튼 세트로 교체 (수정 아이콘 + 삭제 아이콘)
        area.innerHTML = `
        <span class="material-icons fs-6 text-primary me-2" onclick="event.stopPropagation(); editBoxName(\${boxNo})">add_circle_outline</span>
        <span class="material-icons fs-6 text-danger" onclick="event.stopPropagation(); deleteBoxConfirm(\${boxNo})">highlight_off</span>
    `;
    }

    // 삭제 확인 예시 (AppAlert 활용)
    function deleteBoxConfirm(boxNo) {
        AppAlert.confirm('메일함 삭제', '정말 이 메일함을 삭제하시겠습니까?', '삭제', '취소', 'delete_forever', 'danger')
            .then((result) => {
                if (result.isConfirmed) {
                    // 여기에 삭제 Ajax 로직 작성
                    console.log(boxNo + "번 메일함 삭제 로직 실행");
                }
            }); // (알람 리팩토링)
    }


    //메일박스 토들
    function toggleMailFolder() {
        const tree = document.getElementById('mailFolderTree1');
        const icon = document.getElementById('toggleIcon');

        // 클래스 토글
        tree.classList.toggle('closed');

        // 아이콘 방향 변경
        if(tree.classList.contains('closed')) {
            icon.innerText = 'chevron_right';
        } else {
            icon.innerText = 'chevron_left';
        }
    }

    function toggleSub(id) {
        const sub = document.getElementById(id);
        sub.style.display = (sub.style.display === 'none') ? 'block' : 'none';
    }

    function loadBox(boxId) {
        // 기존 함수들 호출
        if(typeof hideAll === 'function') hideAll();
        const listView = document.getElementById('mail-list-view');
        if(listView) listView.style.display = 'block';

        listFn(1, 1, "boxId", boxId);
    }

    ///



</script>