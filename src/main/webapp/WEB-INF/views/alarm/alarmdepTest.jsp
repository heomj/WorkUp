<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script src="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tributejs/5.1.3/tribute.css">
<html lang="ko">

<div class="container">
    <div class="tree-content" id="main_jstree"></div>
</div>

<script type="text/javascript">
    const selectedEmployees = new Map();
    const renderAvatarHtml = (emp, isLarge = false) => {
        const className = isLarge ? 'detail-avatar-lg' : 'emp-avatar';
        const iconSize = isLarge ? '50px' : '24px';

        // 대표이사(CEO_1)이며 상세 패널용(isLarge)인 경우 고정 이미지 사용
        if (emp.empId === 'CEO_1' && isLarge) {
            const ceoImgPath = '../images/ohho.png';
            return `<div class="\${className}"><img src="\${ceoImgPath}" alt="CEO"></div>`;
        }

        // 일반 사원 또는 배치도용 대표 이미지
        if (emp.avtSaveNm && emp.avtSaveNm !== '') {
            const avtSrc = `/avatar/displayAvt?fileName=\${emp.avtSaveNm}`;
            return `<div class="\${className}"><img src="\${avtSrc}" onerror="this.parentElement.innerHTML='<i class=\\'material-icons\\' style=\\'font-size:\${iconSize}\\'>person</i>'"></div>`;
        } else {
            return `<div class="\${className}"><i class="material-icons" style="font-size:\${iconSize}; color:#ccc;">person_outline</i></div>`;
        }
    };
    const rankPriority = { '대표': 0, '팀장': 1, '대리': 2, '주임': 3, '사원': 4 };
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


    /** 데이터 로드 및 가공 **/
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
        let list = [{ empId: 'CEO_1', empNm: '000', empJbgd: '대표', deptNm: '경영진', empEml: 'ceo@workup.com', empPhone: '010-0000-0000' }];
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


    /** 트리 초기화 **/
    function initJsTree(deptData, allEmployees) {
        if ($('#main_jstree').jstree(true)) $('#main_jstree').jstree('destroy');

        const treeData = [
            {id: 'ROOT_NODE', parent: '#', text: 'WORK UP', type: 'root', state: {opened: true}},
            {id: 'TEMP_CEO', parent: 'ROOT_NODE', text: '000 (대표이사)', type: 'leader', originalData: allEmployees[0]}
        ];

        deptData.forEach(dept => {
            treeData.push({id: 'DEPT_' + dept.deptNm, parent: 'ROOT_NODE', text: dept.deptNm, type: 'dept'});
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

        $('#main_jstree').jstree({
            core: {
                data: treeData.map(node => {
                    const iconStyle = "style='font-size:18px; vertical-align:middle; margin-right:6px;'";

                    if (node.id === 'ROOT_NODE') {
                        // 최상위 루트 아이콘
                        node.text = `<i class="material-icons" \${iconStyle} style="color:#1e293b">business</i>\${node.text}`;
                    } else if (node.type === 'dept') {
                        // 부서 아이콘
                        node.text = `<i class="material-icons" \${iconStyle} style="color:#3b82f6">groups</i>\${node.text}`;
                    } else if (node.originalData) {
                        const isLeader = node.type === 'leader';
                        const iconColor = isLeader ? '#f59e0b' : '#94a3b8';
                        const iconName = isLeader ? 'person' : 'person_outline';

                        const icon = `<i class="material-icons" \${iconStyle} style="color:\${iconColor}">\${iconName}</i>`;
                        node.text = icon + node.text;
                    }
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

    /** 시각적 배치도 렌더링 **/
    function renderVisualOrg(allEmployees) {
        const area = $('#visualOrgArea').empty();
        const ceo = allEmployees.find(e => e.empJbgd === '대표');
        const depts = {};

        allEmployees.forEach(e => {
            if(e.empJbgd !== '대표') {
                if(!depts[e.deptNm]) depts[e.deptNm] = [];
                depts[e.deptNm].push(e);
            }
        });

        if(ceo) {
            area.append(`
                <div class="ceo-card" onclick='addEmployeeDetail(\${JSON.stringify(ceo)})'>
                    \${renderAvatarHtml(ceo, true)}
                    <div class="fw-bold mt-2">\${ceo.empNm}</div>
                    <div class="small text-muted">\${ceo.empJbgd}</div>
                </div>
            `);
        }

        Object.entries(depts).forEach(([name, members]) => {
            members.sort((a,b) => (rankPriority[a.empJbgd]||99) - (rankPriority[b.empJbgd]||99));
            let html = `<div class="team-column"><div class="team-title">\${name}</div>`;
            members.forEach(m => {
                html += `
                    <div class="emp-card rank-\${m.empJbgd}" onclick='addEmployeeDetail(\${JSON.stringify(m)})'>
                        \${renderAvatarHtml(m, false)}
                        <div class="emp-info"><div class="emp-name">\${m.empNm}</div><div class="emp-rank">\${m.empJbgd}</div></div>
                    </div>`;
            });
            area.append(html + `</div>`);
        });
    }

    /** 상세 정보 관리 **/
    function addEmployeeDetail(emp) {
        const empObj = typeof emp === 'string' ? JSON.parse(emp) : emp;
        if(selectedEmployees.has(String(empObj.empId))) {
            $(`#detail-\${empObj.empId}`).css('transform', 'scale(1.05)');
            setTimeout(() => $(`#detail-\${empObj.empId}`).css('transform', 'scale(1)'), 200);
            return;
        }
        selectedEmployees.set(String(empObj.empId), empObj);
        renderDetailPanel();
    }

    function removeEmployeeDetail(id) {
        selectedEmployees.delete(String(id));
        renderDetailPanel();
    }

    function clearAllDetails() {
        selectedEmployees.clear();
        renderDetailPanel();
    }

    function renderDetailPanel() {
        const area = $('#detailArea').empty();
        if(selectedEmployees.size === 0) {
            area.append('<div id="emptyDetailMsg" class="text-center text-muted mt-5"><i class="material-icons" style="font-size: 48px; color:#eee;">person_search</i><br>사원을 선택해주세요.</div>');
            return;
        }

        if(selectedEmployees.size > 1) {
            area.append(`
                <button class="mail-action-btn mb-3" style="background:#1e293b" onclick="sendGroupMail()">
                    <i class="fas fa-users"></i> \${selectedEmployees.size}명에게 단체메일
                </button><hr>
            `);
        }

        Array.from(selectedEmployees.values()).reverse().forEach(emp => {
            // 위에서 이미 정의하신 renderAvatarHtml 함수를 사용하여 아바타 HTML 생성 (isLarge = true)
            const avatarHtml = renderAvatarHtml(emp, true);

            area.append(`
                <div class="profile-detail-card" id="detail-\${emp.empId}">
                    <button class="btn-remove-card" onclick="removeEmployeeDetail('\${emp.empId}')"><i class="material-icons">close</i></button>
                    <div class="detail-header">
                        \${avatarHtml}
                        <div>
                            <h5 class="mb-1 fw-bold">\${emp.empNm} \${emp.empJbgd}</h5>
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
    }
</script>