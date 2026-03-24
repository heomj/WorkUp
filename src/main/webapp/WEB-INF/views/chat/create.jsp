<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    :root {
        --bs-card-box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, 0.08);
        --primary-blue: #696cff;
        --primary-light: #e7e7ff;
        --danger-red: #ff3e1d;
    }

    .create-wrapper {
        width: 100%;
        min-height: calc(100vh - 150px);
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 2rem;
    }

    .create-container { 
        width: 100%; 
        max-width: 800px; 
        background: #fff; 
        border-radius: 1rem; 
        box-shadow: var(--bs-card-box-shadow); 
        overflow: hidden; 
        border: 1px solid #eee; 
    }

    .create-header { 
        padding: 1.75rem; 
        background: var(--primary-blue); 
        color: white; 
        text-align: center; 
    }
    .create-header h2 { margin: 0; font-size: 1.5rem; font-weight: 700; }

    .create-body { padding: 2.5rem; }

    .selected-users-container { 
        display: flex; 
        flex-wrap: wrap; 
        gap: 10px; 
        padding: 15px; 
        border: 1px solid #dee2e6; 
        border-radius: 0.5rem; 
        min-height: 60px; 
        margin-bottom: 1.5rem; 
        background: #fcfcfc; 
    }
    .user-chip { 
        display: inline-flex; 
        align-items: center; 
        background: var(--primary-light); 
        color: var(--primary-blue); 
        padding: 6px 14px; 
        border-radius: 50px; 
        font-size: 0.9rem; 
        font-weight: 600; 
    }
    .user-chip .remove-btn { margin-left: 10px; cursor: pointer; color: var(--danger-red); }

    .search-wrapper { position: relative; margin-bottom: 1rem; }
    .search-wrapper .material-icons { 
        position: absolute; 
        left: 15px; 
        top: 50%; 
        transform: translateY(-50%); 
        color: #adb5bd; 
        font-size: 1.3rem; 
    }
    .search-input { 
        width: 100%; 
        padding: 0.8rem 1rem 0.8rem 3rem; 
        border: 1px solid #dee2e6; 
        border-radius: 0.5rem; 
        font-size: 1rem; 
    }

    .user-select-box { 
        border: 1px solid #dee2e6; 
        border-radius: 0.5rem; 
        max-height: 450px; 
        overflow-y: auto; 
        background: #fff; 
    }

    /* 부서 헤더 스타일 보완 */
	.dept-divider {
	    background-color: #f8f9ff;
	    padding: 10px 20px;
	    font-size: 0.85rem;
	    font-weight: 700;
	    color: var(--primary-blue);
	    border-bottom: 1px solid #eef0f2;
	    display: flex;
	    align-items: center;
	    cursor: pointer; /* 클릭 가능하도록 변경 */
	    user-select: none;
	    transition: background-color 0.2s;
	}
	
	.dept-divider:hover {
	    background-color: #f0f2ff;
	}
	
	/* 화살표 아이콘 애니메이션 */
	.dept-divider .toggle-icon {
	    transition: transform 0.3s ease;
	    margin-left: auto; /* 화살표를 오른쪽 끝으로 */
	}
	
	/* 접혔을 때 화살표 회전 */
	.dept-divider.collapsed .toggle-icon {
	    transform: rotate(-90deg);
	}

    .user-item { 
        display: flex; 
        align-items: center; 
        padding: 12px 20px; 
        border-bottom: 1px solid #f8f9fa; 
        cursor: pointer; 
        transition: background 0.2s;
    }
    .user-item:hover { background-color: #f5f5ff; }
    .user-item input { margin-right: 15px; width: 18px; height: 18px; }
    
    .user-name { font-weight: 600; color: #333; font-size: 1rem; }
    .user-info { font-size: 0.85rem; color: #888; }
    .user-badge {
        font-size: 0.7rem;
        padding: 2px 8px;
        border-radius: 4px;
        background: #f1f2f3;
        color: #666;
        margin-left: 8px;
    }
</style>

<div class="create-wrapper">
    <div class="create-container">
        <div class="create-header">
            <h2>새 채팅방 만들기</h2>
        </div>
        
        <form action="<c:url value='/chat/create'/>" method="post" class="create-body" id="createForm">
            <input type="hidden" name="chatRmType" value="GROUP">
            
            <div class="mb-4">
                <label class="form-label fw-bold small text-muted">채팅방 제목</label>
                <input type="text" id="chatRmTtl" name="chatRmTtl" class="form-control form-control-lg shadow-sm" placeholder="채팅방 이름을 입력하세요" required>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold small text-muted">참여 인원 선택</label>
                <div class="selected-users-container" id="selectedContainer">
                    <span class="text-muted small my-auto ps-2">선택된 인원이 없습니다.</span>
                </div>

                <div class="search-wrapper">
                    <span class="material-icons">search</span>
                    <input type="text" class="search-input shadow-sm" id="searchInput" placeholder="이름 또는 부서로 검색">
                </div>

                <div class="user-select-box shadow-sm">
				    <%-- 1. 루프 시작 전 변수 초기화 --%>
				    <c:set var="lastDept" value="" />
				
				    <c:forEach var="user" items="${userList}">
				        <c:if test="${user.empId ne loginId}">
				            
				            <%-- [여기에 넣으세요!] 부서가 바뀔 때만 구분선 출력 --%>
				            <c:if test="${user.deptNm ne lastDept}">
				                <div class="dept-divider" data-dept="${user.deptNm}">
				                    <span class="material-icons" style="font-size: 1rem; margin-right: 6px;">corporate_fare</span>
				                    ${user.deptNm}
				                    <span class="material-icons toggle-icon">expand_more</span>
				                </div>
				                <%-- 출력 후 현재 부서를 lastDept에 저장 --%>
				                <c:set var="lastDept" value="${user.deptNm}" />
				            </c:if>
				
				            <%-- 사원 아이템 (기존 코드에서 data-dept-group 속성만 추가) --%>
				            <div class="user-item" data-dept-group="${user.deptNm}">
				                <input type="checkbox" id="user_${user.empId}" name="empIds" value="${user.empId}" class="form-check-input">
				                <div class="d-flex flex-column">
				                    <div class="d-flex align-items-center">
				                        <span class="user-name">${user.empNm}</span>
				                        <span class="user-badge">${user.empJbgd}</span>
				                    </div>
				                    <span class="user-info">사번: ${user.empId}</span>
				                </div>
				            </div>
				            
				        </c:if>
				    </c:forEach>
				    
				    <c:if test="${empty userList}">
				        <div class="p-4 text-center text-muted">조회된 사원 정보가 없습니다.</div>
				    </c:if>
				</div>
            </div>

            <div class="d-flex gap-3 mt-5">
                <a href="<c:url value='/chat/list'/>" class="btn btn-light flex-grow-1 fw-bold border py-2 text-decoration-none d-flex align-items-center justify-content-center">취소</a>
                <button type="submit" class="btn btn-primary flex-grow-1 fw-bold shadow-sm py-2" style="background-color: var(--primary-blue); border:none;">채팅방 개설</button>
            </div>
        </form>
    </div>
</div>

<script>
	document.addEventListener('DOMContentLoaded', function() {
		const searchInput = document.getElementById('searchInput');
		const userItems = document.querySelectorAll('.user-item');
		const deptDividers = document.querySelectorAll('.dept-divider'); // 부서 헤더들
		const selectedContainer = document.getElementById('selectedContainer');

		function updateUserChips() {
			selectedContainer.innerHTML = '';
			const checkedOnes = document.querySelectorAll('.user-item input[type="checkbox"]:checked');

			checkedOnes.forEach(checkbox => {
				const userName = checkbox.closest('.user-item').querySelector('.user-name').textContent;
				const userId = checkbox.id;

				const chip = document.createElement('div');
				chip.className = 'user-chip';
				chip.innerHTML = `\${userName} <span class="material-icons remove-btn" style="font-size:1.1rem; cursor:pointer;" data-target="\${userId}">cancel</span>`;
				selectedContainer.appendChild(chip);
			});

			if(checkedOnes.length === 0) {
				selectedContainer.innerHTML = '<span class="text-muted small my-auto ps-2">선택된 인원이 없습니다.</span>';
			}
		}




		// [프로젝트에서 채팅방 생성] --------------------------------------------------------------
		const urlParams = new URLSearchParams(window.location.search);
		const targetId = urlParams.get('targetId');
		const targetNm = urlParams.get('targetNm');
		const projectNm = urlParams.get('projectNm');

		if (targetId && targetNm) {
			// 채팅방 제목 자동 세팅 (프로젝트명 + 상대방 이름)
			const chatTitleInput = document.getElementById('chatRmTtl');
			if (chatTitleInput) {
				chatTitleInput.value = `[\${projectNm}] \${targetNm}님과의 채팅`;
			}

			// 해당 사용자 체크박스 자동 선택
			const targetCheckbox = document.getElementById('user_' + targetId);
			if (targetCheckbox) {
				targetCheckbox.checked = true;

				// 부서별로 접혀있다면, 해당 부서는 펼쳐주기
				const userItem = targetCheckbox.closest('.user-item');
				const deptName = userItem.getAttribute('data-dept-group');
				const divider = document.querySelector(`.dept-divider[data-dept="\${deptName}"]`);
				if (divider) {
					divider.classList.remove('collapsed');
					// 부서 내 아이템들 보여주기
					document.querySelectorAll(`.user-item[data-dept-group="\${deptName}"]`)
							.forEach(el => el.style.display = 'flex');
				}

				// 선택된 유저 칩 업데이트 (기존 함수 호출)
				updateUserChips();
			}
		}
		// [프로젝트에서 채팅방 생성] ---------------------------------------------------------





		selectedContainer.addEventListener('click', function(e) {
			if (e.target.classList.contains('remove-btn')) {
				const targetId = e.target.getAttribute('data-target');
				const checkbox = document.getElementById(targetId);
				if (checkbox) {
					checkbox.checked = false;
					updateUserChips();
				}
			}
		});

		userItems.forEach(item => {
			item.addEventListener('click', function(e) {
				if (e.target.tagName !== 'INPUT') {
					const cb = item.querySelector('input[type="checkbox"]');
					if(cb) {
						cb.checked = !cb.checked;
						updateUserChips();
					}
				}
			});
			const input = item.querySelector('input');
			if(input) input.addEventListener('change', updateUserChips);
		});

		// 1. 검색 기능 (부서 헤더 연동 및 접기 상태 고려)
		searchInput.addEventListener('input', function(e) {
			const keyword = e.target.value.toLowerCase();

			// 사용자 아이템 필터링
			userItems.forEach(item => {
				const text = item.textContent.toLowerCase();
				// 검색어 포함 여부 확인
				const isMatch = text.includes(keyword);
				item.style.display = isMatch ? 'flex' : 'none';
			});

			// 부서 헤더 제어: 내부에 검색 결과가 있는 사원이 하나도 없으면 헤더도 숨김
			deptDividers.forEach(divider => {
				const deptName = divider.getAttribute('data-dept');
				const hasVisible = Array.from(document.querySelectorAll(`.user-item[data-dept-group="\${deptName}"]`))
						.some(el => el.style.display !== 'none');

				divider.style.display = hasVisible ? 'flex' : 'none';

				// 검색 시에는 자동으로 접힌 것을 펼쳐주는 것이 사용자 경험상 좋습니다 (선택 사항)
				if(keyword.length > 0 && hasVisible) {
					divider.classList.remove('collapsed');
				}
			});
		});

		// 2. [추가] 부서별 접기/펴기 기능 로직
		deptDividers.forEach(divider => {
			divider.addEventListener('click', function() {
				const deptName = this.getAttribute('data-dept');
				const targetItems = document.querySelectorAll(`.user-item[data-dept-group="\${deptName}"]`);

				// 검색어 유무 확인
				const keyword = searchInput.value.trim();

				// 헤더 상태 토글
				this.classList.toggle('collapsed');
				const isCollapsed = this.classList.contains('collapsed');

				targetItems.forEach(item => {
					if (isCollapsed) {
						// 접을 때는 무조건 숨김
						item.style.display = 'none';
					} else {
						// 펼칠 때는 '검색어'에 맞는 데이터만 다시 보여줌
						const text = item.textContent.toLowerCase();
						if (text.includes(keyword.toLowerCase())) {
							item.style.display = 'flex';
						}
					}
				});
			});
		});

		updateUserChips();
	});
</script>