<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<sec:authentication property="principal.empVO.empId" var="loginEmpId" />

<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<div class="container-fluid py-4">
    <div class="card shadow border-0">
        <div class="card-header bg-white py-3">
            <h5 class="mb-0 fw-bold text-primary">📋 회의실 및 비품 결재 대기 목록</h5>
            <p class="text-muted small mb-0">귀하가 결재권자로 지정된 신청 내역입니다.</p>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>신청번호</th>
                            <th>구분</th>
                            <th>항목명</th>
                            <th>신청자</th>
                            <th>사용사유</th>
                            <th>사용기간</th>
                            <th class="text-center">관리</th>
                        </tr>
                    </thead>
                    <tbody id="pendingTbody">
                        </tbody>
                </table>
            </div>
            <div id="emptyMsg" class="text-center py-5 d-none">
                <span class="material-icons text-light" style="font-size: 4rem;">inventory_2</span>
                <p class="mt-3 text-muted">결재 대기 중인 내역이 없습니다.</p>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    loadPendingList();
});

function loadPendingList() {
    axios.get('/reserve/api/pending/' + '${loginEmpId}')
        .then(res => {
            const list = res.data;
            console.log("결재 대기 데이터:", list);

            const tbody = document.getElementById('pendingTbody');
            const emptyMsg = document.getElementById('emptyMsg');
            tbody.innerHTML = '';

            if (!list || list.length === 0) {
                emptyMsg.classList.remove('d-none');
                return;
            }

            emptyMsg.classList.add('d-none');
            list.forEach(item => {
                // 데이터 매핑 (대소문자 혼용 방지)
                const resId = item.resId || item.RES_ID || '';
                const title = item.title || item.TITLE || '제목 없음';
                const type = item.type || item.TYPE || ''; 
                const empNm = item.empNm || item.EMP_NM || '';
                const empId = item.empId || item.EMP_ID || '';
                const expln = item.expln || item.EXPLN || '-';
                const bgngDt = item.bgngDt || item.BGNG_DT || '';
                const endDt = item.endDt || item.END_DT || '';

                // 구분 배지 설정 (회의실과 비품을 시각적으로 분류)
                const typeBadge = type === 'ROOM' 
                    ? `<span class="badge bg-label-info">회의실</span>` 
                    : `<span class="badge bg-label-success">비품</span>`;

                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td class="fw-bold">\${resId}</td>
                    <td>\${typeBadge}</td>
                    <td><span class="fw-bold text-dark">\${title}</span></td>
                    <td>\${empNm} (\${empId})</td>
                    <td class="text-truncate" style="max-width: 200px;">\${expln}</td>
                    <td class="small">\${bgngDt}<br>~ \${endDt}</td>
                    <td class="text-center">
                        <div class="d-flex justify-content-center gap-2">
                            <button class="btn btn-primary btn-sm px-3" onclick="approveReserve('\${resId}', '\${type}')">승인</button>
                            <button class="btn btn-outline-danger btn-sm px-3" onclick="rejectReserve('\${resId}', '\${type}')">반려</button>
                        </div>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        })
        .catch(err => {
            console.error("데이터 로드 에러:", err);
            Swal.fire('오류', '데이터를 불러오는 중 문제가 발생했습니다.', 'error');
        });
}

/**
 * 승인 처리 함수
 * @param resId 신청 일련번호
 * @param type  예약 구분 (ROOM 또는 FIXTURE)
 */
function approveReserve(resId, type) {
    if(!resId || !type) {
        Swal.fire('오류', '필수 정보(ID 또는 타입)가 누락되어 승인할 수 없습니다.', 'error');
        return;
    }

    Swal.fire({
        title: '결재 승인',
        text: '해당 신청을 최종 승인하시겠습니까?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: '승인',
        cancelButtonText: '취소',
        confirmButtonColor: '#696cff'
    }).then((result) => {
        if (result.isConfirmed) {
            // 서버로 전송 시 resId와 type을 객체 형태로 정확히 전달
            axios.post('/reserve/api/approve', { 
                resId: resId,
                type: type 
            })
            .then(res => {
                if (res.data === 'success') {
                    Swal.fire({
                        icon: 'success',
                        title: '성공',
                        text: '승인 처리가 완료되었습니다.',
                        timer: 1500
                    }).then(() => {
                        loadPendingList(); // 리스트 새로고침
                    });
                } else {
                    Swal.fire('알림', '이미 처리되었거나 승인 중 오류가 발생했습니다.', 'warning');
                }
            })
            .catch(err => {
                console.error("승인 API 통신 에러:", err);
                Swal.fire('에러', '서버 통신 중 문제가 발생했습니다. 관리자에게 문의하세요.', 'error');
            });
        }
    });
}

/**
 * 반려(기각) 처리 함수
 * @param resId 신청 일련번호
 * @param type  예약 구분 (ROOM 또는 FIXTURE)
 */
function rejectReserve(resId, type) {
    if(!resId || !type) {
        Swal.fire('오류', '필수 정보(ID 또는 타입)가 누락되어 반려할 수 없습니다.', 'error');
        return;
    }

    Swal.fire({
        title: '결재 반려',
        text: '해당 신청을 반려(기각)하시겠습니까?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: '반려',
        cancelButtonText: '취소',
        confirmButtonColor: '#ff3e1d'
    }).then((result) => {
        if (result.isConfirmed) {
            axios.post('/reserve/api/reject', { 
                resId: resId, 
                type: type 
            })
            .then(res => {
                if (res.data === 'success') {
                    Swal.fire({ 
                        icon: 'success', 
                        title: '반려 완료', 
                        text: '정상적으로 반려 처리되었습니다.', 
                        timer: 1500 
                    }).then(() => {
                        loadPendingList(); // 리스트 새로고침
                    });
                } else {
                    Swal.fire('알림', '처리에 실패했습니다.', 'warning');
                }
            })
            .catch(err => {
                console.error("반려 API 통신 에러:", err);
                Swal.fire('에러', '서버 통신 중 문제가 발생했습니다. 관리자에게 문의하세요.', 'error');
            });
        }
    });
}
</script>

<style>
    .bg-label-primary { background-color: #e7e7ff !important; color: #696cff !important; padding: 0.5em 0.8em; border-radius: 0.375rem; }
    .bg-label-info { background-color: #d7f5fc !important; color: #03c3ec !important; padding: 0.5em 0.8em; border-radius: 0.375rem; }
    .bg-label-success { background-color: #e8fadf !important; color: #71dd37 !important; padding: 0.5em 0.8em; border-radius: 0.375rem; }
    
    .table thead th { font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; border-top: none; }
    .table td { border-bottom: 1px solid #f4f4f4; }
    .card-header { border-bottom: 1px solid #f4f4f4 !important; }
</style>