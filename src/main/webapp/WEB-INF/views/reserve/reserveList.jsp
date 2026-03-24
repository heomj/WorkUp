<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<sec:authentication property="principal.empVO.empId" var="loginEmpId" />

<style>
    /* 카드 및 테이블 디테일 */
    .card { border-radius: 0.5rem; }
    
    /* 헤더 텍스트 스타일 */
    .table thead th { 
        background-color: #f5f5f9 !important; 
        color: #a1acb8 !important; 
        font-weight: 600;
        text-transform: uppercase;
        font-size: 0.8125rem;
        letter-spacing: 1px;
        border-bottom: 1px solid #d9dee3;
    }

    .table tbody td { 
        color: #697a8d;
        font-size: 0.9375rem;
        padding: 0.75rem 1.25rem !important;
    }

    /* 배지 스타일 */
    .badge-category-custom { 
        font-size: 0.8125rem !important; padding: 0.42em 0.493em !important; 
        font-weight: 600 !important; border-radius: 0.375rem !important; 
        display: inline-flex; align-items: center; gap: 4px; 
    }
    .badge-room-solid { background-color: #e7e7ff; color: #696cff !important; }
    .badge-fixt-solid { background-color: #e8fadf; color: #71dd37 !important; }
    
    /* 취소 버튼 아이콘 스타일 */
    .btn-icon { width: 32px; height: 32px; padding: 0; display: inline-flex; align-items: center; justify-content: center; }
	
    /* 상태(Status) 열 가독성 강화 */
    .table tbody td:nth-child(5) { 
        font-weight: 700;
        font-size: 0.9rem;
    }

    /* 🔥 상태 배지 색상 강제 지정 (흐리게 보이는 현상 해결 및 반려 상태 추가) */
    .bg-label-success { background-color: #dcf6e8 !important; color: #28c76f !important; font-weight: 700 !important; }
    .bg-label-warning { background-color: #fff2d6 !important; color: #ff9f43 !important; font-weight: 700 !important; }
    .bg-label-danger { background-color: #ffe0e0 !important; color: #ff3e1d !important; font-weight: 700 !important; }

</style>

<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<div class="container-fluid py-4" style="background-color: #f5f5f9; min-height: 100vh;">
    <h3 class="fw-bold mt-0 mb-3 px-2">
        <span class="material-icons align-middle me-1 text-primary">assignment</span>
        나의 예약 및 신청 내역
    </h3>

    <div class="card shadow-sm border-0">
        <div class="card-header d-flex justify-content-between align-items-center border-bottom">
            <div class="d-flex align-items-center gap-3">
                <div class="input-group input-group-merge" style="width: 300px;">
                    <span class="input-group-text"><i class="material-icons" style="font-size: 20px; color: #d9dee3;">search</i></span>
                    <input type="text" id="searchInput" class="form-control" placeholder="항목명 또는 사유 검색" oninput="searchData()">
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="text-muted small">보기:</span>
                <select id="itemsPerPageSelect" class="form-select form-select-sm" style="width: 110px;" onchange="changeItemsPerPage()">
                    <option value="5">5개씩</option>
                    <option value="10" selected>10개씩</option>
                    <option value="20">20개씩</option>
                </select>
            </div>
        </div>

        <div class="card-body p-0"> 
            <div class="table-responsive text-nowrap">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="text-center" style="width: 15%;">구분</th>
                            <th style="width: 25%;">항목명</th>
                            <th style="width: 30%;">사용목적/사유</th>
                            <th class="text-center" style="width: 15%;">사용기간</th>
                            <th class="text-center" style="width: 10%;">상태</th>
                            <th class="text-center" style="width: 5%;">관리</th>
                        </tr>
                    </thead>
                    <tbody id="myReserveTbody">
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card-footer bg-white border-top-0 py-4">
            <nav aria-label="Page navigation">
                <ul class="pagination justify-content-center mb-0" id="paginationArea"></ul>
            </nav>
        </div>
    </div>
</div>

<script>
let allData = [];      
let filteredData = [];
let currentPage = 1;   
let itemsPerPage = 10;

document.addEventListener('DOMContentLoaded', function() {
    loadMyReserveList();
});

function loadMyReserveList() {
    axios.get('/reserve/api/my/' + '${loginEmpId}')
        .then(res => {
            allData = res.data || [];
            filteredData = [...allData];
            displayPage(1); 
        })
        .catch(err => { 
            console.error('로드 실패:', err);
            document.getElementById('myReserveTbody').innerHTML = '<tr><td colspan="6" class="py-5 text-center text-danger">데이터 로딩에 실패했습니다.</td></tr>';
        });
}

function searchData() {
    const keyword = document.getElementById('searchInput').value.toLowerCase().trim();
    filteredData = allData.filter(item => {
        const title = (item.TITLE || item.title || '').toLowerCase();
        const expln = (item.EXPLN || item.expln || '').toLowerCase();
        return title.includes(keyword) || expln.includes(keyword);
    });
    displayPage(1);
}

function cancelReservation(resId, type) {
    if(!resId) {
        Swal.fire('알림', '유효한 예약 번호를 찾을 수 없습니다.', 'warning');
        return;
    }
    Swal.fire({
        title: '내역을 삭제(취소)하시겠습니까?',
        text: "해당 예약 내역은 즉시 삭제되며 복구할 수 없습니다.",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ff3e1d',
        cancelButtonColor: '#8592a3',
        confirmButtonText: '삭제 실행',
        cancelButtonText: '닫기'
    }).then((result) => {
        if (result.isConfirmed) {
            const url = '/reserve/api/delete' + (type === 'ROOM' ? 'Room' : 'Fixt');
            axios.post(url, { resId: resId })
                .then(res => {
                    Swal.fire('처리 완료', '정상적으로 삭제(취소)되었습니다.', 'success');
                    loadMyReserveList(); 
                })
                .catch(err => {
                    Swal.fire('오류', '처리 중 문제가 발생했습니다.', 'error');
                });
        }
    });
}

function changeItemsPerPage() {
    itemsPerPage = parseInt(document.getElementById('itemsPerPageSelect').value);
    displayPage(1);
}

function displayPage(page) {
    currentPage = page;
    const tbody = document.getElementById('myReserveTbody');
    tbody.innerHTML = '';

    if (filteredData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="py-5 text-center text-muted">예약 내역이 존재하지 않습니다.</td></tr>';
        renderPagination(0);
        return;
    }

    const startIndex = (page - 1) * itemsPerPage;
    const paginatedItems = filteredData.slice(startIndex, startIndex + itemsPerPage);

    paginatedItems.forEach(item => {
        // ID 추출
        let rawId = item.resId || item.RESID || item.RES_ID || item.RM_RSVT_NO || item.FIXT_RSVT_NO;
        const resId = rawId ? String(rawId).replace(/[^0-9]/g, '') : '';

        const type = (item.type || item.TYPE || '').toUpperCase();
        const title = item.title || item.TITLE || '제목 없음';
        
        // 🔥 상태(stts) 변수 추출 추가
        const stts = String(item.stts || item.STTS || '').toUpperCase();
        const aprvDt = item.aprvDt || item.APRV_DT;
        const bgngDt = item.bgngDt || item.BGNG_DT || '';
        const endDt = item.endDt || item.END_DT || '';
        const expln = item.expln || item.EXPLN || '-';
        const fixtCat = item.fixtCat || item.FIXTCAT || item.FIXT_CAT || ''; 
        
        // 기간 표시
        let period = '';
        if (fixtCat === '소모품') {
            period = '<div class="small fw-bold">' + bgngDt + '</div>';
        } else {
            period = '<div class="small fw-bold">' + bgngDt + '</div><div class="small text-muted">' + endDt + '</div>';
        }
        
        let isRoom = (type === 'ROOM');
        let badgeClass = isRoom ? 'badge-room-solid' : 'badge-fixt-solid';
        let icon = isRoom ? 'meeting_room' : 'inventory_2';
        let typeTxt = isRoom ? '회의실' : '비품';

        let typeBadge = '<span class="badge badge-category-custom ' + badgeClass + '"><i class="material-icons">' + icon + '</i> ' + typeTxt + '</span>';
        
        // 🔥 상태 배지 렌더링 수정 (반려됨 처리)
        let statusBadge = '';
        let titleDisplay = '';
        
        if (stts === 'REJECTED' || stts === '반려됨') {
            statusBadge = '<span class="badge bg-label-danger px-2 py-1" style="font-size: 0.8rem;">반려됨</span>';
            titleDisplay = '<span class="fw-bold text-muted" style="text-decoration: line-through;">' + title + '</span>';
        } else if (stts === 'CONFIRMED' || stts === '예약 확정' || aprvDt) {
            statusBadge = '<span class="badge bg-label-success px-2 py-1" style="font-size: 0.8rem;">예약 확정</span>';
            titleDisplay = '<span class="fw-bold text-dark">' + title + '</span>';
        } else {
            statusBadge = '<span class="badge bg-label-warning px-2 py-1" style="font-size: 0.8rem;">승인 대기</span>';
            titleDisplay = '<span class="fw-bold text-dark">' + title + '</span>';
        }

        let cancelBtn = '<button class="btn btn-icon btn-outline-danger btn-sm" onclick="cancelReservation(\'' + resId + '\', \'' + type + '\')"><i class="material-icons" style="font-size:18px;">delete_outline</i></button>';
		
        const tr = document.createElement('tr');
        tr.innerHTML = '<td class="text-center">' + typeBadge + '</td>' +
                     '<td>' + titleDisplay + '</td>' +
                     '<td class="text-wrap" style="max-width: 300px;">' + expln + '</td>' +
                     '<td class="text-center">' + period + '</td>' + 
                     '<td class="text-center">' + statusBadge + '</td>' +
                     '<td class="text-center">' + cancelBtn + '</td>';
        tbody.appendChild(tr);
    });

    renderPagination(filteredData.length);
}

function renderPagination(totalItems) {
    const paginationArea = document.getElementById('paginationArea');
    paginationArea.innerHTML = '';
    const totalPages = Math.ceil(totalItems / itemsPerPage);
    if (totalPages === 0) return;

    let html = '';
    html += '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '"><a class="page-link" href="javascript:void(0)" onclick="displayPage(' + (currentPage - 1) + ')"><i class="material-icons" style="font-size:18px;">chevron_left</i></a></li>';

    for (let i = 1; i <= totalPages; i++) {
        html += '<li class="page-item ' + (currentPage === i ? 'active' : '') + '"><a class="page-link" href="javascript:void(0)" onclick="displayPage(' + i + ')">' + i + '</a></li>';
    }

    html += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '"><a class="page-link" href="javascript:void(0)" onclick="displayPage(' + (currentPage + 1) + ')"><i class="material-icons" style="font-size:18px;">chevron_right</i></a></li>';
    paginationArea.innerHTML = html;
}
</script>