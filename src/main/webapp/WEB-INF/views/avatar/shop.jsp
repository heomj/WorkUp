<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    :root {
        --point-color: #7579ff;
        --point-hover: #5a5edb;
        --bg-light: #f4f7fe;
        --text-dark: #1b2559;
        --text-muted: #a3aed0;
    }

    .shop-container {
        font-family: 'Pretendard', sans-serif;
        background-color: var(--bg-light);
        min-height: 100vh;
        width: 100%;
        display: flex;
        flex-direction: column;
    }

    .inventory-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        padding-bottom: 30px;
        flex-shrink: 0;
    }

    .header-title {
        font-size: 1.6rem;
        font-weight: 800;
        color: var(--text-dark);
        display: flex;
        align-items: center; gap: 10px;
    }
    .current-status {
        background: #ffffff;
        padding: 12px 20px;
        border-radius: 20px;
        display: flex;
        align-items: center;
        gap: 15px;
        box-shadow: 0 10px 20px rgba(117, 121, 255, 0.05);
        border: 1px solid #f0f3ff;
    }

    .status-info { display: flex; flex-direction: column; text-align: right; }
    .status-label { font-size: 0.75rem; color: var(--text-muted); font-weight: 700; }
    .status-value { font-size: 1.1rem; color: var(--point-color); font-weight: 800; }

    .status-icon-box {
        width: 45px; height: 45px;
        background: #f0f3ff;
        border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
    }

    .shop-header-line {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        height: 55px;
        flex-shrink: 0;
    }

    .tab-group { display: flex; gap: 5px; height: 100%; align-items: flex-end; }

    .tab-item {
        border: none;
        background: #e0e5f2;
        color: #707eae;
        padding: 0 30px;
        height: 42px;
        font-size: 0.95rem;
        font-weight: 700;
        border-radius: 10px 10px 0 0;
        cursor: pointer;
        transition: all 0.2s;
        position: relative;
    }

    .tab-item.active {
        background: #ffffff;
        color: var(--point-color);
        height: 48px;
        box-shadow: 0 -5px 15px rgba(0,0,0,0.05);
        z-index: 3;
    }

    .shop-content-box {
        background: #ffffff;
        padding: 30px;
        border-radius: 0 20px 20px 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.03);
    }

    .custom-row {
        display: flex;
        flex-wrap: wrap;
        margin: -10px;
    }

    .item-wrapper {
        width: 20%;
        padding: 10px;
        box-sizing: border-box;
    }

    .item-card {
        background: #fff;
        border: 1px solid #f0f3ff;
        border-radius: 20px;
        overflow: hidden;
        transition: all 0.3s ease;
        height: 100%;
        display: flex;
        flex-direction: column;
    }

    .item-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(117, 121, 255, 0.15);
        border-color: var(--point-color);
    }

    .img-area {
        height: 280px;
        background: #f8faff;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 10px;
        overflow: hidden;
    }

    .img-area img {
        max-width: 100%;
        max-height: 100%;
        width: auto;
        height: auto;
        object-fit: contain;
    }

    .info-area { padding: 15px; background: white; }
    .item-title { font-size: 0.9rem; font-weight: 700; color: var(--text-dark); margin-bottom: 8px; }
    .price-text { color: var(--point-color); font-weight: 800; font-size: 1rem; }

    .buy-btn {
        background: var(--bg-light);
        color: var(--point-color);
        border: none;
        padding: 6px 12px;
        border-radius: 8px;
        font-weight: 700;
        cursor: pointer;
        transition: 0.2s;
        font-size: 0.85rem;
    }
    .buy-btn:hover { background: var(--point-color); color: #fff; }

    #sortSelect { padding: 8px 12px; border-radius: 10px; border: 1px solid #e0e5f2; color: #707eae; font-weight: 700; outline: none; }
</style>

<sec:authentication property="principal.empVO.empMlg" var="currentMlg" />

<div class="shop-container">
    <div class="inventory-header" style="display: flex; justify-content: space-between; align-items: flex-end;">
        <div>
            <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                <span class="material-icons" style="color: #696cff; font-size: 20px;">
                    <i class="fas fa-shopping-bag"></i>
                </span>
                <div style="display: flex; align-items: baseline; gap: 8px;">
                    <span style="font-size: x-large; font-weight: 800;">아바타 Shop</span>
                </div>
            </div>
            <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                모아둔 마일리지로 귀여운 아바타를 수집할 시간 !
            </div>
        </div>

        <div class="header-right">
            <div class="current-status">
                <div class="status-info">
                    <span class="status-label">My Mileage</span>
                    <span class="status-value" id="myMlg" data-value="${currentMlg}">
                        <fmt:formatNumber value="${currentMlg}" type="number"/> P
                    </span>
                </div>
                <div class="status-icon-box">
                    <span class="material-icons" style="color: var(--point-color);">payments</span>
                </div>
            </div>
        </div>
    </div>

    <div class="shop-header-line">
        <div class="tab-group" id="tabGroup">
            <button class="tab-item active" data-filter="all">전체보기</button>
            <button class="tab-item" data-filter="pokemon">포켓몬스터</button>
            <button class="tab-item" data-filter="digimon">디지몬어드벤처</button>
            <button class="tab-item" data-filter="sanrio">산리오</button>
            <button class="tab-item" data-filter="teenieping">잔망루피</button>
            <button class="tab-item" data-filter="cookierun">쿠키런</button>
        </div>

        <div style="padding-bottom: 8px; padding-right: 30px;">
            <select id="sortSelect">
                <option value="newest">최신순</option>
                <option value="popular">인기도순</option>
                <option value="price-low">높은가격순</option>
                <option value="price-high">낮은가격순</option>
            </select>
        </div>
    </div>

    <div class="shop-content-box">
        <div class="custom-row" id="itemList">
            <c:forEach var="avt" items="${avtlist}">
              <c:if test="${avt.avtYn == 'Y'}">
                <div class="item-wrapper" data-category="${avt.avtCtg}">
                    <div class="item-card">
                        <div class="img-area">
                            <img src="/avatar/displayAvt?fileName=${avt.avtSaveNm}">
                        </div>
                        <div class="info-area">
                            <div class="item-title">${avt.avtNm}</div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="price-text"><fmt:formatNumber value="${avt.avtPrice}" type="number"/> P</span>
                                <button class="buy-btn" data-avtPrice="${avt.avtPrice}" data-avtNo="${avt.avtNo}" data-avtNm="${avt.avtNm}">구매</button>
                            </div>
                        </div>
                    </div>
                </div>
              </c:if>
            </c:forEach>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const tabs = document.querySelectorAll('.tab-item');
    const sortSelect = document.querySelector("#sortSelect");
    const container = document.querySelector("#itemList");

    function updateList() {
        const cate = document.querySelector(".tab-item.active").dataset.filter;
        const sort = sortSelect.value;

        axios.get("/shop/select",{
            params: { category: cate, sortSelect: sort }
        })
        .then(res => {
            let list = res.data;
            container.innerHTML = "";

            list.forEach(avt => {
                if(avt.avtYn === 'Y') {
                    let html = `
                        <div class="item-wrapper" data-category="\${avt.avtCtg}">
                            <div class="item-card">
                                <div class="img-area">
                                    <img src="/avatar/displayAvt?fileName=\${avt.avtSaveNm}">
                                </div>
                                <div class="info-area">
                                    <div class="item-title">\${avt.avtNm}</div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="price-text">\${Number(avt.avtPrice).toLocaleString()} P</span>
                                        <button class="buy-btn"
                                                data-avtPrice="\${avt.avtPrice}"
                                                data-avtNo="\${avt.avtNo}"
                                                data-avtNm="\${avt.avtNm}">구매</button>
                                    </div>
                                </div>
                            </div>
                        </div>`;
                    container.innerHTML += html;
                }
            });
        })
        .catch(err => console.error("데이터 로드 실패:", err));
    }

    tabs.forEach(tab => {
        tab.addEventListener('click', function() {
            tabs.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            updateList();
        });
    });

    if(sortSelect) {
        sortSelect.addEventListener('change', updateList);
    }
});

// 아바타 구매
document.querySelector("#itemList").addEventListener("click", (e) => {
    if (!e.target.classList.contains('buy-btn')) return;

    let avtprice = e.target.dataset.avtprice;
    let mymlg = document.querySelector("#myMlg").dataset.value;
    let avtNo = e.target.dataset.avtno;
    let avtNm = e.target.dataset.avtnm;

    if(parseInt(avtprice) > parseInt(mymlg)) {
        Swal.fire({ title: '구매 실패', text: '마일리지가 부족합니다.', icon: 'error', timer: 1500, showConfirmButton: false });
        return;
    }

    Swal.fire({
        title: '아바타 구매',
        text: avtNm + "을(를) 구매하시겠습니까?",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#7579ff',
        cancelButtonColor: '#707eae',
        confirmButtonText: '구매하기',
        cancelButtonText: '취소'
    }).then((result) => {
        if (result.isConfirmed) {
            const params = new URLSearchParams();
            params.append('avtNo', avtNo);
            params.append('avtPrice', avtprice);

            axios.post("/avatar/buyavt", params)
            .then(res => {
                let title = "";
                if (res.data === "success") title = "구매 완료!";
                else if (res.data === "having") title = "이미 보유하신 아바타입니다!";
                else return Swal.fire('구매 실패', '처리 중 오류가 발생했습니다.', 'error');

                Swal.fire({
                    title: title,
                    text: res.data === "success" ? '아바타가 인벤토리에 추가되었습니다.' : '',
                    icon: "success",
                    showCancelButton: true,
                    confirmButtonColor: '#7579ff',
                    confirmButtonText: '보러가기',
                    cancelButtonText: '쇼핑 계속하기'
                }).then((result) => {
                    if (result.isConfirmed) location.href = "/myavatar";
                    else location.reload();
                });
            });
        }
    });
});
</script>