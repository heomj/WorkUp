<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />

<sec:csrfMetaTags />

    <style>
    /* --- 우측 마일리지 요약 카드 전용 CSS --- */

    .header-right {
        display: flex;
        align-items: center;
    }

    /* 마일리지 카드 전체 박스 */
    .current-status {
        background: #ffffff;
        padding: 12px 20px;
        border-radius: 20px;
        display: flex;
        align-items: center;
        gap: 15px;
        /* 은은한 보라색 그림자 효과 */
        box-shadow: 0 10px 20px rgba(117, 121, 255, 0.05);
        border: 1px solid #f0f3ff;
    }

    /* 텍스트 영역 (레이블 + 수치) */
    .status-info {
        display: flex;
        flex-direction: column;
        text-align: right;
    }

    /* 'My Mileage' 글자 스타일 */
    .status-label {
        font-size: 0.75rem;
        color: var(--text-muted); /* #a3aed0 */
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* 숫자(P) 스타일 */
    .status-value {
        font-size: 1.1rem;
        color: var(--point-color); /* #7579ff */
        font-weight: 800;
    }

    /* 아이콘을 감싸는 배경 박스 */
    .status-icon-box {
        width: 45px;
        height: 45px;
        background: #f0f3ff;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: transform 0.3s ease;
    }

    /* 마우스 올렸을 때 아이콘 살짝 움직이는 효과 (선택사항) */
    .current-status:hover .status-icon-box {
        transform: scale(1.05);
    }

    :root {
        --point-color: #7579ff; 
        --point-hover: #5a5edb;
        --bg-light: #f4f7fe;
        --text-dark: #1b2559;
        --text-muted: #a3aed0;
    }

    .inventory-container {
        font-family: 'Pretendard', sans-serif;
        background-color: var(--bg-light);
        min-height: 100vh;
        width: 100%;
        display: flex;
        flex-direction: column;
        padding-bottom: 50px;
    }
    .inventory-header {
        display: flex;
        justify-content: space-between; 
        align-items: center; /* 제목과 마일리지 카드의 높이를 맞추기 위해 center 추천 */
        padding-bottom: 40px;
    }

    .header-title {
        font-size: 1.6rem;
        font-weight: 800;
        color: var(--text-dark);
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .header-subtitle {
        color: var(--text-muted);
        font-size: 0.95rem;
        margin-top: 8px;
        font-weight: 500;
    }
    .inventory-content-box {
        background: #ffffff;

        padding: 40px;
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.03);
    }

    .avt-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 25px;
    }
    .avt-card {
        background: #fff;
        border: 2px solid #f0f3ff;
        border-radius: 24px;
        overflow: hidden;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        display: flex;
        flex-direction: column;
    }
    .avt-card.active {
        border: 2px solid var(--point-color) !important;
        background: #f9f9ff;
        box-shadow: 0 10px 20px rgba(117, 121, 255, 0.15) !important;
    }

    .active-badge {
        position: absolute;
        top: 15px;
        left: 15px;
        background: var(--point-color);
        color: white;
        padding: 5px 12px;
        border-radius: 12px;
        font-size: 0.75rem;
        font-weight: 800;
        z-index: 2;
    }

    .img-area {
        height: 180px;
        background: #f8faff;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: 0.3s;
    }
    .avt-card:hover .img-area { background: #f0f3ff; }
    .img-area img { width: 100px; filter: drop-shadow(0 5px 10px rgba(0,0,0,0.1)); }

    .info-area { padding: 20px; text-align: center; }
    .avt-name { font-size: 1.1rem; font-weight: 700; color: var(--text-dark); margin-bottom: 4px; }
    
    .purchase-date {
        display: block;
        font-size: 0.75rem;
        color: var(--text-muted);
        margin-bottom: 15px;
        font-weight: 500;
    }

    .btn-group { display: flex; gap: 8px; }
    .btn-action {
        flex: 1;
        border: none;
        padding: 10px;
        border-radius: 12px;
        font-weight: 700;
        font-size: 0.9rem;
        cursor: pointer;
        transition: 0.2s;
    }

    .btn-wear { background: var(--point-color); color: #fff; }
    .btn-wear:hover { background: var(--point-hover); }
    .btn-wear.disabled { background: #e0e5f2; color: #707eae; cursor: not-allowed !important; }

    .btn-delete { background: #fff; color: #ff5b5b; border: 1px solid #ff5b5b; }
    .btn-delete:hover { background: #ff5b5b; color: #fff; }
 
    .btn-delete.disabled {
        border-color: #e0e5f2 !important;
        color: #a3aed0 !important;
        background: #f4f7fe !important;
        cursor: not-allowed !important;
        opacity: 0.5;
    }

</style>

    <div class="inventory-container">
        <div class="inventory-header" style="display: flex; justify-content: space-between; align-items: flex-end;">
            <div>
                <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                    <span class="material-icons" style="color: #696cff; font-size: 20px;">
                        <i class="fas fa-pen"></i>
                    </span>
                    <div style="display: flex; align-items: baseline; gap: 8px;">
                        <span style="font-size: x-large; font-weight: 800;">내 아바타 관리</span>
                    </div>
                </div>
                <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                    나만의 특별한 아바타로 오늘을 꾸며보세요.
                </div>
            </div>

        <div class="header-right">
            <div class="current-status">
                <div class="status-info">
                    <span class="status-label">My Mileage</span>
                    <span class="status-value" id="myMlg" data-value="<sec:authentication property='principal.empVO.empMlg'/>">
                        <sec:authentication property="principal.empVO.empMlg"/> P
                    </span>
                </div>
                <div class="status-icon-box">
                    <span class="material-icons" style="color: var(--point-color);">payments</span>
                </div>
            </div>
        </div>
    </div>

    <div class="inventory-content-box">
        <div class="avt-grid">
            <c:choose>    
                <c:when test="${not empty myavtlist}">
                    <c:forEach var="avt" items="${myavtlist}">
                        <div class="avt-card ${avt.ownAvtWearYn == 'Y' ? 'active' : ''}" id="avt-${avt.avtNo}">
                            <c:if test="${avt.ownAvtWearYn == 'Y'}">
                                <div class="active-badge">착용 중</div>
                            </c:if>
                            
                            <div class="img-area">
                                <img src="/avatar/displayAvt?fileName=${avt.avtSaveNm}">
                            </div>

                            <div class="info-area">
                                <div class="avt-name">${avt.avtNm}</div>
                                <span class="purchase-date">구매일: 
                                    <fmt:formatDate value="${avt.ownAvtDt}" pattern="yyyy.MM.dd" />
                                </span>
                                
                                <div class="btn-group">
                                    <c:choose>
                                        <c:when test="${avt.ownAvtWearYn == 'Y'}">
                                            <button class="btn-action btn-wear disabled" disabled>착용중</button>
                                            <button class="btn-action btn-delete disabled" disabled>삭제</button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn-action btn-wear" onclick="wearItem('${avt.avtNo}', '${avt.avtSaveNm}')">착용하기</button>
                                            <button class="btn-action btn-delete" onclick="removeItem('${avt.avtNo}')">삭제</button>
                                        </c:otherwise>
                                    </c:choose>                
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="no-data" style="width: 100%; text-align: center; padding: 50px;">
                        보유 중인 아바타가 없습니다.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script>
    const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
    const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
    if (csrfToken && csrfHeader) {
        axios.defaults.headers.common[csrfHeader] = csrfToken;
    }

    /**
     * 아바타 착용 처리
     */
    function wearItem(avtNo,avtSaveNm) {
        console.log("번호" + avtNo);
        console.log(avtSaveNm);

        const avatarData = {
            avtNo: avtNo,
            avtSaveNm: avtSaveNm
        };

        axios.patch("/avatar/wearavt", avatarData)
            .then(res => {
                if(res.data == 1) {
                    updateWearUI(avtNo);
                Swal.fire({
                    icon: 'success',
                    title: '착용 완료',
                    showConfirmButton: false,
                    timer: 800
                }).then(() => {
                    location.reload(); 
                });
                } else {
                    Swal.fire('오류', '착용 처리에 실패했습니다.', 'error');
                }
            })
            .catch(err => {
                console.error(err);
                Swal.fire('에러', '서버와 통신할 수 없습니다.', 'error');
            });
    }

    /**
     * 착용 시 화면 UI 실시간 업데이트
     */
    function updateWearUI(avtNo) {
        // 1. 기존 모든 카드 초기화
        document.querySelectorAll('.avt-card').forEach(card => {
            card.classList.remove('active');
            const badge = card.querySelector('.active-badge');
            if(badge) badge.remove();
            
            const wearBtn = card.querySelector('.btn-wear');
            if(wearBtn) {
                wearBtn.classList.remove('disabled');
                wearBtn.disabled = false;
                wearBtn.innerText = "착용하기";
                wearBtn.setAttribute("onclick", `wearItem('${card.id.split('-')[1]}')`);
            }

            const delBtn = card.querySelector('.btn-delete');
            if(delBtn) {
                delBtn.classList.remove('disabled');
                delBtn.disabled = false;
                delBtn.setAttribute("onclick", `removeItem('${card.id.split('-')[1]}')`);
            }
        });

        const target = document.getElementById('avt-' + avtNo);
        if(target) {
            target.classList.add('active');
            target.insertAdjacentHTML('afterbegin', '<div class="active-badge">착용 중</div>');
            
            const targetWearBtn = target.querySelector('.btn-wear');
            targetWearBtn.classList.add('disabled');
            targetWearBtn.disabled = true;
            targetWearBtn.innerText = "착용중";
            targetWearBtn.removeAttribute("onclick");

            const targetDelBtn = target.querySelector('.btn-delete');
            targetDelBtn.classList.add('disabled');
            targetDelBtn.disabled = true;
            targetDelBtn.removeAttribute("onclick");
        }
    }

    // 아바타 삭제
    function removeItem(avtNo) {
        Swal.fire({
            title: '아바타 삭제',
            text: "정말 이 아바타를 목록에서 삭제하시겠습니까?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#7579ff', 
            cancelButtonColor: '#ff5b5b',
            cancelButtonText: '취소',
            confirmButtonText: '삭제',
        }).then((result) => {
            if (result.isConfirmed) {
                axios.patch("/avatar/deleteavt/" + avtNo) 
                    .then(res => {
                        if (res.data == 1) {
                            const el = document.getElementById('avt-' + avtNo);
                            if (el) {
                                el.style.transition = '0.3s';
                                el.style.opacity = '0';
                                el.style.transform = 'translateY(20px)';
                                
                                setTimeout(() => { 
                                    el.remove(); 
                                    Swal.fire({
                                        icon: 'success',
                                        title: '삭제 완료',
                                        showConfirmButton: false,
                                        timer: 1000
                                    });
                                }, 300);
                            }
                        } else {
                            Swal.fire('실패', '삭제 처리에 실패했습니다.', 'error');
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        Swal.fire('에러', '서버 통신 중 오류가 발생했습니다.', 'error');
                    });
            }
        });
    }
</script>