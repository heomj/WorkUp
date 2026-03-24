<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- 폰트 및 아이콘 라이브러리 -->
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />

<style>
    /* 레이아웃 및 패널 공통 */
    .org-container { display: flex; height: calc(100vh - 200px); gap: 20px; padding: 20px; font-family: 'Pretendard', sans-serif; }
    .org-panel { background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); display: flex; flex-direction: column; overflow: hidden; }
    .panel-header { padding: 15px 20px; border-bottom: 1px solid #eee; font-weight: 600; background-color: #fff; display: flex; justify-content: space-between; align-items: center; }

    /* 좌측 트리 패널 */
    .tree-panel { width: 260px; flex-shrink: 0; }
    .tree-search { padding: 12px 15px; border-bottom: 1px solid #eee; }
    .tree-content { padding: 10px; overflow-y: auto; flex-grow: 1; }
    .jstree-default .jstree-node { min-height: 32px; line-height: 32px; }

    /* 조직도 인원수 스타일 */
    .tree-count {
        font-size: 0.75rem;
        font-weight: 500;
        color: #888;
        margin-left: 4px;
        vertical-align: middle;
    }


    /* 중앙 시각화 패널 */
    .visual-panel { flex-grow: 1; min-width: 0; position: relative; transition: all 0.3s ease; }
    .visual-scroll-area {
        display: flex;
        flex-direction: row;
        align-items: flex-start;
        gap: 20px;
        padding: 20px;
        overflow-x: auto;
        flex-grow: 1;
        justify-content: center;
        align-items: flex-start;

        overflow-x: auto;
        flex-grow: 1;
        scroll-behavior: smooth;
    }
    .visual-scroll-area::-webkit-scrollbar { height: 10px; width: 10px;}
    .visual-scroll-area::-webkit-scrollbar-thumb { background: #ddd; border-radius: 10px; }

    /* CEO 정보 영역 */
    .ceo-card {
        min-width: 220px;
        background: #fff;
        border: 1px solid #dee2e6;
        border-radius: 12px;
        padding: 15px 20px;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: center;
        text-align: center;
        gap: 15px;
        cursor: pointer;
        transition: 0.2s;
        margin-bottom: 10px;
    }
    .ceo-card:hover { transform: translateY(-3px); border-color: #6366f1; box-shadow: 0 5px 15px rgba(0,0,0,0.08); }
    .ceo-row {
        width: 100%;
        display: flex;
        justify-content: center;
        padding: 20px 0 10px 0;
        background-color: #fff;
        border-bottom: 1px dashed #ddd;
        flex-shrink: 0;
    }
    .ceo-info { display: flex; flex-direction: column; text-align: left; gap: 4px; }
    .ceo-name-row { display: flex; align-items: baseline; gap: 8px; }
    .ceo-name { font-size: 1.2rem; font-weight: 800; color: #1e293b; margin: 0; }
    .ceo-rank { font-size: 0.9rem; color: #717171; font-weight: 500; }


    .team-column { min-width: 210px; background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 12px; display: flex; flex-direction: column; gap: 10px; padding: 15px; }
    .team-title {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-weight: 700;
        color: #495057;
        padding-bottom: 10px;
        border-bottom: 2px solid #dee2e6;
        margin-bottom: 5px;
        font-size: 0.95rem;
    }

    .emp-card { background: #fff; border: 1px solid #dee2e6; border-radius: 8px; padding: 10px; display: flex; align-items: center; gap: 10px; cursor: pointer; transition: 0.2s; }
    .emp-card:hover { border-color: #6366f1; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
    .emp-avatar { width: 36px; height: 36px; border-radius: 50%; background: #e9ecef; display: flex; align-items: center; justify-content: center; overflow: hidden; flex-shrink: 0; }
    .emp-avatar img { width: 100%; height: 100%; object-fit: cover; }
    .rank-팀장 { border-left: 4px solid #3b82f6; }
    .rank-대리 { border-left: 4px solid #10b981; }
    .rank-주임 { border-left: 4px solid #f59e0b; }
    .rank-사원 { border-left: 4px solid #9ca3af; }

    /* 선택된 상태 스타일링 */
    .emp-card.active, .ceo-card.active {
        background-color: #eef2ff !important;
        box-shadow: 0 8px 20px rgba(99, 102, 241, 0.15) !important;
        transform: translateY(-4px) scale(1.02);
        z-index: 5;
        outline: 1px solid #6366f1;
        outline-offset: -2px;
    }
    .detail-content {
        position: relative;
        padding: 15px;
        overflow-y: auto;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        gap: 15px;
        scroll-behavior: smooth;
    }

    /* 우측 상세 패널 */
    .detail-panel { width: 300px; flex-shrink: 0; background: #fdfdfd; border-left: 1px solid #eef0f2; display: none; height: 100%;}
    .detail-content { position: relative; padding: 15px; overflow-y: auto; flex-grow: 1; display: flex; flex-direction: column; gap: 15px; }
    .profile-detail-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); border: 1px solid #eee; position: relative; animation: slideUp 0.3s ease-out; }
    @keyframes slideUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }

    /* 단체 메일 버튼을 감싸는 컨테이너 스타일 */
    .group-mail-container {
        position: sticky;
        top: 0;
        z-index: 100;
        background-color: #fdfdfd;
        padding-bottom: 15px;
        margin-bottom: 5px;
    }

    .btn-remove-card { position: absolute; top: 12px; right: 12px; border: none; background: none; color: #ccc; cursor: pointer; }
    .btn-remove-card:hover { color: #ef4444; }

    .detail-header { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 12px; border-bottom: 1px solid #f1f1f1; padding-bottom: 20px; margin-bottom: 10px; }
    .detail-avatar-lg { width: 90px; height: 90px; border-radius: 50%; border: 3px solid #fff; box-shadow: 0 4px 12px rgba(0,0,0,0.1); overflow: hidden; background: #f3f4f6; display: flex; align-items: center; justify-content: center; }
    .detail-avatar-lg img { width: 100%; height: 100%; object-fit: cover; }
    .detail-text p { margin: 8px 0; font-size: 0.9rem; color: #555; display: flex; align-items: center; gap: 10px; }
    .detail-text .material-icons { font-size: 18px; color: #6366f1; }

    #detailScrollArea {
        position: relative;
        padding: 15px;
        overflow-y: auto !important;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        gap: 15px;
        height: 0;
        min-height: 100%;
    }

    .scroll-btn { position: absolute; top: 50%; transform: translateY(-50%); width: 36px; height: 36px; background: rgba(255,255,255,0.9); border: 1px solid #ddd; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; z-index: 10; transition: 0.2s; }
    .scroll-btn:hover { background: #fff; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    .scroll-left { left: 10px; }
    .scroll-right { right: 10px; }



    .mail-action-btn {
        display: flex; align-items: center; justify-content: center; gap: 8px;
        width: 100%; padding: 12px; border-radius: 10px; border: none;
        background: #6366f1; color: white !important; font-weight: 600; cursor: pointer; transition: 0.2s;
    }

    /* 버튼 내부 아이콘에 애니메이션 */
    .mail-action-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

    @keyframes paperPlaneMove {
        0% { transform: translate(0, 0); }
        50% { transform: translate(3px, -3px); }
        100% { transform: translate(0, 0); }
    }

    /* 부서 전체 선택 버튼 스타일 */
    .btn-dept-select {
        font-size: 10px !important;
        padding: 2px 8px !important;
        border-radius: 6px !important;
        color: #6366f1 !important;
        border: 1px solid #e0e7ff !important;
        background: #f0f4ff;
        transition: all 0.2s;
        font-weight: 600;
        white-space: nowrap;
    }
    .btn-dept-select:hover { background: #6366f1 !important; color: #fff !important; }


    /* 직급 범례 */
    .rank-legend { display: flex; align-items: center; gap: 12px; font-size: 0.8rem; color: #666; }
    .legend-item { display: flex; align-items: center; gap: 5px; }
    .color-dot { width: 12px; height: 12px; border-radius: 3px; }

    .dot-팀장 { background-color: #3b82f6; }
    .dot-대리 { background-color: #10b981; }
    .dot-주임 { background-color: #f59e0b; }
    .dot-사원 { background-color: #9ca3af; }
</style>


<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
            <span class="material-icons" style="color: #696cff; font-size: 32px;">account_tree</span>
            <div style="display: flex; align-items: baseline; gap: 8px;">
                <span style="font-size: x-large; font-weight: 800;">조직도</span>
            </div>
        </div>
        <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
            부서별 조직 구성 및 임직원 정보를 한눈에 확인할 수 있는 페이지입니다.
        </div>
    </div>
</div>

<div class="org-container">
    <div class="org-panel tree-panel">
        <div class="panel-header" ><span>조직도</span></div>
        <div class="tree-search">
            <input type="text" id="treeSearchInput" class="form-control form-control-sm" placeholder="이름 또는 부서 검색...">
        </div>
        <div class="tree-content" id="main_jstree"></div>
    </div>

    <div class="org-panel visual-panel">
        <div class="panel-header">
            <span>부서별 배치도</span>
            <div class="rank-legend">
                <div class="legend-item"><span class="color-dot dot-팀장"></span> 팀장</div>
                <div class="legend-item"><span class="color-dot dot-대리"></span> 대리</div>
                <div class="legend-item"><span class="color-dot dot-주임"></span> 주임</div>
                <div class="legend-item"><span class="color-dot dot-사원"></span> 사원</div>
            </div>
        </div>
        <button class="scroll-btn scroll-left" onclick="scrollVisual(-300)"><i class="material-icons">chevron_left</i></button>
        <button class="scroll-btn scroll-right" onclick="scrollVisual(300)"><i class="material-icons">chevron_right</i></button>
        <div class="visual-scroll-area" id="visualOrgArea"></div>
    </div>

    <div class="org-panel detail-panel">
        <div class="panel-header">
            <span>상세 정보</span>
            <button class="btn btn-sm btn-link text-muted" onclick="clearAllDetails()">초기화</button>
        </div>
        <div class="detail-content" id="detailScrollArea">
            </div>
    </div>
</div>

<script>
    const selectedEmployees = new Map();
    const rankPriority = { '대표': 0, '팀장': 1, '대리': 2, '주임': 3, '사원': 4 };

    const detailPanel = $('.detail-panel');

    const renderAvatarHtml = (emp, isLarge = false) => {
        const className = isLarge ? 'detail-avatar-lg' : 'emp-avatar';
        const iconSize = isLarge ? '50px' : '24px';

        // 대표이사이며 상세 패널용인 경우 고정 이미지 사용
        if (emp.empId === 'CEO_1' && isLarge) {
            const ceoImgPath = '../images/ohho.png';
            return `<div class="\${className}"><img src="\${ceoImgPath}" alt="CEO"></div>`;
        }

        // 일반 사원 또는 배치도용 대표 이미지
        if (emp.avtSaveNm && emp.avtSaveNm !== '') {
            const avtSrc = `/avatar/displayAvt?fileName=\${emp.avtSaveNm}`;
            return `<div class="\${className}"><img src="\${avtSrc}" onerror="this.parentElement.innerHTML='<i class=\\'material-icons\\' style=\\'font-size:\${iconSize}\\'>person</i>'"></div>`;
        } else {
            return `<div class="\${className}"><i class="material-icons" color:#ccc;">person_outline</i></div>`;
        }
    };


    $(document).ready(function() {
        loadOrgData();

        let searchTimer = false;
        $('#treeSearchInput').on('keyup', function () {
            if(searchTimer) clearTimeout(searchTimer);
            searchTimer = setTimeout(() => {
                $('#main_jstree').jstree(true).search($(this).val());
            }, 250);
        });
    });

    /* 데이터 로드 및 가공 */
    async function loadOrgData() {
        try {
            const res = await axios.get("/indivList");
            const allEmployees = flattenData(res.data);
            initJsTree(res.data, allEmployees);
            renderVisualOrg(allEmployees);
        } catch (err) {
            console.error("조직도 데이터를 불러오지 못했습니다.", err);
        }
    }

    function flattenData(data) {
        let list = [{ empId: 'CEO_1', empNm: '000', empJbgd: '대표', deptNm: '경영진', empEml: 'ceo@workup.com', empPhone: '010-5050-5050' }];
        data.forEach(dept => {
            const employees = [...(dept.deptLeaders || []), ...(dept.deptEmployee || [])];
            employees.forEach(e => {
                if(!list.some(exist => exist.empId === e.empId)) {
                    list.push({...e, deptNm: dept.deptNm});
                }
            });
        });
        return list;
    }

    /* 트리 초기화 */
    function initJsTree(deptData, allEmployees) {
        if ($('#main_jstree').jstree(true)) $('#main_jstree').jstree('destroy');

        // 1. 인원수 계산
        const totalCount = allEmployees.length;
        const deptCounts = {};
        allEmployees.forEach(e => {
            if (e.empJbgd !== '대표') {
                deptCounts[e.deptNm] = (deptCounts[e.deptNm] || 0) + 1;
            }
        });

        // 2. 트리 데이터 구성
        const treeData = [
            {
                id: 'ROOT_NODE',
                parent: '#',
                // 최상단 WORK UP 옆에 총 인원 표시
                text: `WORK UP <span class="tree-count"> (\${totalCount})</span>`,
                type: 'root',
                state: {opened: true}
            },
            {
                id: 'TEMP_CEO',
                parent: 'ROOT_NODE',
                text: '000 (대표이사)',
                type: 'leader',
                originalData: allEmployees[0]
            }
        ];

        deptData.forEach(dept => {
            const count = deptCounts[dept.deptNm] || 0;
            treeData.push({
                id: 'DEPT_' + dept.deptNm,
                parent: 'ROOT_NODE',
                // 부서명 옆에 부서별 인원 표시
                text: `\${dept.deptNm} <span class="tree-count"> (\${count})</span>`,
                type: 'dept'
            });

            allEmployees
                .filter(e => e.deptNm === dept.deptNm && e.empJbgd !== '대표')
                .sort((a, b) => (rankPriority[a.empJbgd] || 99) - (rankPriority[b.empJbgd] || 99))
                .forEach(emp => {
                    treeData.push({
                        id: String(emp.empId),
                        parent: 'DEPT_' + dept.deptNm,
                        text: `\${emp.empNm} (\${emp.empJbgd})`,
                        type: emp.empJbgd === '팀장' ? 'leader' : 'default',
                        originalData: emp
                    });
                });
        });

        // jstree 로드 (아이콘 스타일 적용 부분 포함)
        $('#main_jstree').jstree({
            core: {
                data: treeData.map(node => {
                    const iconStyle = "style='font-size:18px; vertical-align:middle; margin-right:6px;'";
                    let icon = "";

                    if (node.id === 'ROOT_NODE') {
                        icon = `<i class="material-icons" \${iconStyle} style="color:#1e293b">business</i>`;
                    } else if (node.type === 'dept') {
                        icon = `<i class="material-icons" \${iconStyle} style="color:#3b82f6">groups</i>`;
                    } else if (node.originalData) {
                        const isLeader = node.type === 'leader';
                        const iconName = isLeader ? 'person' : 'person_outline';
                        icon = `<i class="material-icons" \${iconStyle} style="color:\${isLeader ? '#f59e0b' : '#94a3b8'}">\${iconName}</i>`;
                    }

                    node.text = icon + node.text;
                    return node;
                }),
                themes: { dots: false, icons: false }
            },
            plugins: ["search", "wholerow"]
        }).on("select_node.jstree", (e, data) => {
            if (data.node.original.originalData) addEmployeeDetail(data.node.original.originalData);
            $('#main_jstree').jstree('toggle_node', data.node);
        });
    }

    /* 시각적 배치도 렌더링 */
    function renderVisualOrg(allEmployees) {
        const area = $('#visualOrgArea').empty();
        const panel = $('.visual-panel');
        panel.find('.ceo-row').remove();

        const ceo = allEmployees.find(e => e.empJbgd === '대표');
        const depts = {};

        // 2. 상단 CEO 영역 생성
        if(ceo) {
            // 백틱 내부에서 함수 호출을 피하고 미리 변수에 담으세요
            const avatarHtml = renderAvatarHtml(ceo, true);
            const ceoData = JSON.stringify(ceo).replace(/'/g, "&apos;"); // 따옴표 에러 방지

            const ceoRow = $(`<div class="ceo-row"></div>`);
            ceoRow.append(`
                <div class="ceo-card" id="card-\${ceo.empId}" onclick='addEmployeeDetail(\${ceoData})'>
                    \${avatarHtml}
                    <div class="ceo-info">
                        <div class="ceo-name-row">
                            <span class="ceo-name">\${ceo.empNm}</span>
                            <span class="ceo-rank">\${ceo.empJbgd}</span>
                        </div>
                        <div class="small text-muted" style="font-size: 0.8rem;">WORK UP CEO</div>
                    </div>
                </div>
            `);
            area.before(ceoRow);
        }

        // 3. 데이터 분류
        allEmployees.forEach(e => {
            if(e.empJbgd !== '대표') {
                if(!depts[e.deptNm]) depts[e.deptNm] = [];
                depts[e.deptNm].push(e);
            }
        });

        // 4. 하단 부서 영역
        Object.entries(depts).forEach(([name, members]) => {
            members.sort((a,b) => (rankPriority[a.empJbgd]||99) - (rankPriority[b.empJbgd]||99));

            let html = `
                <div class="team-column">
                    <div class="team-title d-flex justify-content-between align-items-center">
                        <span>\${name}</span>
                        <button class="btn btn-dept-select" onclick='selectDeptMembers(\${JSON.stringify(members).replace(/'/g, "&apos;")})'>
                            전체 선택
                        </button>
                    </div>`;

            members.forEach(m => {
                const empAvatar = renderAvatarHtml(m, false);
                const empData = JSON.stringify(m).replace(/'/g, "&apos;");

                html += `
                    <div class="emp-card rank-\${m.empJbgd}" id="card-\${m.empId}" onclick='addEmployeeDetail(\${empData})'>
                        \${empAvatar}
                        <div class="emp-info">
                            <div class="emp-name">\${m.empNm}</div>
                            <div class="emp-rank">\${m.empJbgd}</div>
                        </div>
                    </div>`;
            });
            area.append(html + `</div>`);
        });
    }

    /* 부서원 일괄 선택 함수 */
    function selectDeptMembers(members) {
        let addedCount = 0;

        members.forEach(emp => {
            const empId = String(emp.empId);
            // 이미 추가된 사원은 건너뛰기
            if(!selectedEmployees.has(empId)) {
                selectedEmployees.set(empId, emp);
                addedCount++;
            }
        });

        if(addedCount > 0) {
            renderDetailPanel();
            // 일괄 추가 후 알림 (선택사항)
            // console.log(`\${addedCount}명의 사원이 추가되었습니다.`);
        } else {
            alert("이미 모든 부서원이 선택되어 있습니다.");
        }
    }

    /* 상세 정보 관리 */
    function addEmployeeDetail(emp) {
        const empObj = typeof emp === 'string' ? JSON.parse(emp) : emp;
        const empId = String(empObj.empId);

        if(selectedEmployees.has(empId)) {
            /*
                사원카드 재클릭 시 상세정보 카드에서 호버효과 주는 스타일
            $(`#detail-\${empId}`)[0]?.scrollIntoView({ behavior: 'smooth', block: 'center' });
            $(`#detail-\${empId}`).css('transform', 'scale(1.05)');
            setTimeout(() => $(`#detail-\${empId}`).css('transform', 'scale(1)'), 200);
            return;
           */
           removeEmployeeDetail(empId, true);
           return;
        }

        selectedEmployees.set(empId, empObj);
        renderDetailPanel(false);
    }

    function removeEmployeeDetail(id, isRemoval = true) {
        selectedEmployees.delete(String(id));
        renderDetailPanel(isRemoval);
    }

    function clearAllDetails() {
        selectedEmployees.clear();
        renderDetailPanel();
    }

    function renderDetailPanel(isRemoval = false) {
        const area = $('#detailScrollArea').empty();

        $('.emp-card, .ceo-card').removeClass('active');

        // 선택된 사원이 없을 때
        if(selectedEmployees.size === 0) {
            detailPanel.hide();
            return;
        }

        // 선택된 사원이 있을 때
        detailPanel.show();

        if(selectedEmployees.size > 1) {
            area.append(`
                <div class="group-mail-container" >
                    <button class="mail-action-btn" style="background:#1e293b" onclick="sendGroupMail()">
                        <i class="fas fa-users"></i> \${selectedEmployees.size}명에게 단체메일 보내기
                    </button>
                </div>
                <hr/>
            `);
        }

        Array.from(selectedEmployees.values()).forEach(emp => {
            let profileSrc = '';

            // 대표이사인 경우 고정 이미지 적용
            if (emp.empJbgd === '대표' || emp.empId === 'CEO_1') {
                profileSrc = '../images/ohhoProfile.png';
            } else {
                // 일반 사원
                profileSrc = (emp.empProfile && emp.empProfile !== '')
                    ? `/displayPrf?fileName=\${emp.empProfile}`
                    : `/images/defaultProf.png`;
            }

            // 아바타 HTML 구성 (기존 CSS 클래스 유지)
            const avatarHtml = `
        <div class="detail-avatar-lg">
            <img src="\${profileSrc}" alt="\${emp.empNm} 프로필" onerror="this.src='/images/defaultProf.png'">
        </div>
    `;

            // 카드 렌더링
            area.append(`
                <div class="profile-detail-card" id="detail-\${emp.empId}">
                    <button class="btn-remove-card" onclick="removeEmployeeDetail('\${emp.empId}')"><i class="material-icons">close</i></button>
                    <div class="detail-header">
                        \${avatarHtml}
                        <div>
                            <h5 class="mb-1 fw-bold">\${emp.empNm} \${emp.empJbgd}</h5>
                            <div class="text-muted mb-2" style="font-size: 0.8rem;">사번 \${emp.empId}</div>
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle">\${emp.deptNm}</span>
                        </div>
                    </div>
                    <div class="detail-text">
                        <p><i class="material-icons">mail</i> \${emp.empEml && emp.empEml !== '-' ? emp.empEml : 'workup@naver.com'}</p>
                        <p><i class="material-icons">phone_iphone</i> \${emp.empPhone && emp.empPhone !== '-' ? emp.empPhone : '010-2345-7384'}</p>
                    </div>
                    <button class="mail-action-btn" onclick="sendMail('\${emp.empId}', '\${emp.empEml}')">
                        <i class="fas fa-paper-plane"></i> 메일 보내기
                    </button>
                </div>
            `);
        });
        /* <p><i class="material-icons">badge</i>\${emp.empId}</p> */

        // 선택된 사원 .active 스타일 추가
        selectedEmployees.forEach((value, key) => {
            $(`#card-\${key}`).addClass('active');
        });

        // 상세정보 - 사원 추가시 추가한 사원 카드 위치로 스크롤 이동 (삭제가 아닐 경우만 스크롤)
        if (!isRemoval) {
            setTimeout(() => {
                const container = document.getElementById('detailScrollArea');
                if (container) {
                    container.scrollTo({
                        top: container.scrollHeight,
                        behavior: 'smooth'
                    });
                }
            }, 100);
        }
    }

    /* 메일 전송 로직 */
    function sendMail(id, email) {
        if(!email || email === '-') return alert("이메일 정보가 없습니다.");
        location.href = `/email/write?targetEmpIds=\${id}`;
    }

    function sendGroupMail() {
        const ids = Array.from(selectedEmployees.keys()).join(',');
        location.href = `/email/write?targetEmpIds=\${ids}`;
    }

    function scrollVisual(amt) {
        document.getElementById('visualOrgArea').scrollBy({ left: amt, behavior: 'smooth' });
    }
</script>