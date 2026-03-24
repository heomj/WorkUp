<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
    /* 1. myinfo.jsp와 완벽 일치하는 레이아웃 스타일 [cite: 1, 2, 3] */
    .mypage-content-area { width: 100%; padding: 1.5rem; }
    .mp-card { background: #fff; border-radius: 0.5rem; box-shadow: 0 2px 6px 0 rgba(67, 89, 113, 0.12); margin-bottom: 1.5rem; overflow: hidden; }
    .detail-info-card { min-height: 650px; display: flex; flex-direction: column; padding: 1.5rem; }
    
    /* 네비게이션 탭 [cite: 21, 22, 23] */
    .mp-nav-tabs { border-bottom: 1px solid #d9dee3; margin-bottom: 1.5rem; display: flex; gap: 1rem; list-style: none; padding: 0; }
    .mp-nav-link { padding: 0.7rem 1.2rem; color: #697a8d; text-decoration: none; border-bottom: 2px solid transparent; transition: all 0.3s; font-weight: 500; }
    .mp-nav-link.active { color: #696cff; border-bottom-color: #696cff; }

    /* 좌측 프로필 영역 스타일 (myinfo 복제) [cite: 6, 12, 13, 30] */
    .mp-profile-header { padding: 2.5rem 1.5rem; text-align: center; display: flex; flex-direction: column; align-items: center; }
    .mp-avatar-wrapper { position: relative; width: 160px; height: 160px; margin-bottom: 1.5rem; }
    .mp-avatar { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; border: 5px solid #fff; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    .mp-emp-name { font-weight: 700; color: #566a7f; font-size: 1.4rem; margin-bottom: 0.75rem !important; }
    .bg-label-primary { background-color: #e7e7ff !important; color: #696cff !important; padding: 0.5rem 0.8rem; border-radius: 0.25rem; font-weight: 600; margin-bottom: 1.5rem !important; }

    /* 급여 리스트 전용 스타일 */
    .filter-wrapper { background: #fcfcfd; padding: 1rem; display: flex; gap: 8px; align-items: center; border-bottom: 1px solid #f0f2f4; margin-bottom: 1rem; border-radius: 0.4rem; }
    .table thead th { background-color: #f5f5f9; color: #566a7f; font-size: 0.8rem; text-transform: uppercase; padding: 0.75rem; border: none; }
    .amount-masked { cursor: pointer; background: #eceef1; color: transparent; border-radius: 4px; padding: 2px 8px; transition: 0.2s; user-select: none; }
    .amount-masked.unmask { background: transparent; color: #696cff; font-weight: 600; }
    .btn-detail { background-color: rgba(105, 108, 255, 0.1); color: #696cff; border: none; padding: 5px 12px; border-radius: 4px; font-size: 0.85rem; font-weight: 500; }

    /* 명세서 모달 내부 (PDF용) */
    .slip-container { padding: 40px; background: #fff; font-family: 'Malgun Gothic', 'Apple SD Gothic Neo', sans-serif; color: #333;line-height: 1.5;}
    .slip-header { text-align: center; margin-bottom: 30px; }
    .slip-title { font-size: 28px; font-weight: 800; letter-spacing: 15px; text-decoration: underline;text-underline-offset: 8px;margin-bottom: 15px;}
    .slip-table { width: 100%; border-collapse: collapse; margin-bottom: -1px;font-size: 13px; }
    .slip-table th, .slip-table td { border: 1px solid #666; padding: 8px 12px; }
    .slip-table th { background: #f2f2f2; width: 15%; font-weight: 600; text-align: center;}
    .pay-grid { display: flex; border: 1px solid #666;border-top: none;}
    .pay-col { flex: 1; }
    .pay-col:first-child {border-right: 1px solid #666;}
    .inner-table { width: 100%; border-collapse: collapse; }
    .inner-table th { background: #f2f2f2; border-bottom: 1px solid #666; padding: 8px; font-size: 14px;}
    .inner-table td { border-bottom: 1px solid #eee; padding: 8px 12px; font-size: 13px;}
    .total-row { background: #fafafa; font-weight: bold; border-top: 1px solid #666;}
    .net-pay-area {margin-top: -1px;border: 1px solid #666;padding: 15px 20px;display: flex;justify-content: space-between;align-items: center;background: #f9f9f9;}
    .stamp-area { text-align: center;margin-top: 40px; position: relative; }
    .company-name {font-size: 18px;font-weight: bold;letter-spacing: 2px;}
    .company-stamp { width: 65px; position: absolute; left: 60%; top: -15px;opacity: 0.9; }
</style>

<div class="mypage-content-area">
    <ul class="mp-nav-tabs">
        <li><a href="/mypage" class="mp-nav-link">마이페이지</a></li>
        <li><a href="/payslip" class="mp-nav-link active">급여명세서</a></li>
    </ul>

    <div class="row">
        <div class="col-md-4">
            <div class="mp-card">
                <div class="mp-profile-header">
                    <div class="mp-avatar-wrapper">
                        <sec:authentication property="principal.empVO.empProfile" var="userProfile" />
                        <c:choose>
                            <c:when test="${not empty userProfile}">
                                <img src="/displayPrf?fileName=${userProfile}" class="mp-avatar" alt="Profile">
                            </c:when>
                            <c:otherwise>
                                <img src="/resources/images/default-avatar.png" class="mp-avatar" alt="Default">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <h4 class="mp-emp-name"><sec:authentication property="principal.empVO.empNm" /></h4>
                    <span class="badge bg-label-primary">
                        <sec:authentication property="principal.empVO.empJbgd" /> / <sec:authentication property="principal.empVO.deptNm" />
                    </span>
                    <div style="width: 100%; border-top: 1px solid #f0f2f4; padding-top: 1.2rem; display: flex; justify-content: space-between;">
                        <div class="text-start">
                            <span style="font-size: 0.8rem; color: #a1acb8; display: block;">사원번호</span>
                            <span style="font-weight: 600; color: #566a7f;"><sec:authentication property="principal.empVO.empId" /></span>
                        </div>
                        <div class="text-end">
                            <span style="font-size: 0.8rem; color: #a1acb8; display: block;">입사일</span>
                            <span style="font-weight: 600; color: #566a7f;">
                                <sec:authentication property="principal.empVO.empRegistDt" var="dt" />
                                <fmt:formatDate value="${dt}" pattern="yyyy/MM/dd" />
                            </span>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="mp-card p-3">
                <div class="d-flex align-items-center gap-2 mb-2">
                    <i class="material-icons text-primary" style="font-size: 20px;">info</i>
                    <span class="fw-bold" style="color: #566a7f;">안내사항</span>
                </div>
                <p class="text-muted small mb-0">급여명세서는 본인만 조회가 가능하며, 실수령액 클릭 시 금액이 표시됩니다. PDF 다운로드 후 외부 유출에 주의하세요.</p>
            </div>
        </div>

        <div class="col-md-8">
            <div class="mp-card detail-info-card">
                <h5 class="fw-bold mb-4" style="color: #566a7f;">급여 지급 내역</h5>
                
                <div class="filter-wrapper">
                    <select class="form-select form-select-sm" id="searchYear" style="width: 100px;">
                        <option value="2026">2026년</option>
                        <option value="2025">2025년</option>
                    </select>
                    <div class="input-group input-group-sm" style="width: 200px;">
                        <input type="text" class="form-control" id="searchKeyword" placeholder="검색">
                        <button class="btn btn-primary" id="btnSearch">조회</button>
                    </div>
                </div>

                <div class="table-responsive flex-grow-1">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>귀속연월</th>
                                <th>지급유형</th>
                                <th>지급일자</th>
                                <th>실수령액</th>
                                <th class="text-center">상세보기</th>
                            </tr>
                        </thead>
                        <tbody id="payslipTableBody">
                            <tr>
                                <td colspan="5" class="text-center">데이터를 불러오는 중입니다...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="mt-4" id="pagingArea">
                    </div>
            </div>
        </div>
    </div>
</div>

<script>
    // 1. 상세보기 함수 (salId로 단건 조회 AJAX 추가)
    function showSlip(salId) {
        // 실제 운영 시 salId를 이용해 DB에서 상세 정보를 가져옴
        axios.get("/emp/payslipDetail", { params: { salId: salId } })
        .then(res => {
            const d = res.data; // 서버에서 반환한 SalaryMasterVO (empNm, salMonth 등 포함)
            
            Swal.fire({
                width: '750px',
                background: '#f8f9fa',
                showConfirmButton: true,
                confirmButtonText: 'PDF 다운로드',
                confirmButtonColor: '#696cff',
                showCloseButton: true,
                html: `
                <div class="slip-container" id="pdfArea">
                    <div class="slip-header">
                        <div class="slip-title">급여명세서</div>
                        <div style="font-size: 14px;">( 귀속연월 : \${d.salMonth} )</div>
                    </div>
                    
                    <table class="slip-table">
                        <tr>
                            <th style="width: 15%;">성 명</th>
                            <td style="width: 35%; font-weight: bold;">\${d.empNm}</td>
                            <th style="width: 15%;">사 번</th>
                            <td style="width: 35%;">\${d.empId}</td>
                        </tr>
                        <tr>
                            <th>부 서</th>
                            <td>\${d.deptNm || 'IT개발팀'}</td>
                            <th>직 급</th>
                            <td>\${d.empJbgd}</td>
                        </tr>
                        <tr>
                            <th>지급일</th>
                            <td colspan="3">\${d.salMonth}-25</td>
                        </tr>
                    </table>

                    <div class="pay-grid">
                        <div class="pay-col">
                            <table class="inner-table">
                                <thead><tr><th colspan="2">지 급 항 목</th></tr></thead>
                                <tbody>
                                    <tr><td>기본급</td><td align="right">\${d.salBasePay.toLocaleString()}</td></tr>
                                    <tr><td>연장근무수당</td><td align="right">\${d.salOtPay.toLocaleString()}</td></tr>
                                    <tr><td>출장비수당</td><td align="right">\${d.salTripPay.toLocaleString()}</td></tr>
                                    <tr class="total-row"><td>지급총액</td><td align="right">\${(d.salBasePay + d.salOtPay + d.salTripPay).toLocaleString()}</td></tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="pay-col">
                            <table class="inner-table">
                                <thead><tr><th colspan="2">공 제 항 목</th></tr></thead>
                                <tbody>
                                    <tr><td>공제합계</td><td align="right">\${d.salDeductionTotal.toLocaleString()}</td></tr>
                                    <tr><td>소득세/지방세</td><td align="right">0</td></tr>
                                    <tr><td>&nbsp;</td><td></td></tr>
                                    <tr class="total-row"><td>공제총액</td><td align="right">\${d.salDeductionTotal.toLocaleString()}</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="net-pay-area">
                        <span class="fw-bold" style="font-size:15px;">실 수 령 액</span>
                        <span style="font-size:18px; font-weight:800;">금 \${d.salNetPay.toLocaleString()} 원</span>
                    </div>

                    <div class="stamp-area">
                        <div class="company-name">일업주식회사 대표이사</div>
                        <img src="/images/workup_signature.png" class="company-stamp">
                        <div style="font-size:11px; color:#777; margin-top:10px;">※ 본 명세서는 내부 확인용이며 외부 제출 시 직인이 날인된 원본을 사용하시기 바랍니다.</div>
                    </div>
                </div>
            `,
                preConfirm: () => {
                    downloadPDF(d.salMonth + '_급여명세서_' + d.empNm);
                    return false; 
                }
            });
        });
    }

    // 2. PDF 생성 로직
    async function downloadPDF(fileName) {
        const element = document.getElementById('pdfArea');
        const canvas = await html2canvas(element, { scale: 2 });
        const imgData = canvas.toDataURL('image/png');
        
        const { jsPDF } = window.jspdf;
        const pdf = new jsPDF('p', 'mm', 'a4');
        const imgProps = pdf.getImageProperties(imgData);
        const pdfWidth = pdf.internal.pageSize.getWidth();
        const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;
        
        pdf.addImage(imgData, 'PNG', 0, 10, pdfWidth, pdfHeight);
        pdf.save(fileName + '.pdf');
        
        Swal.fire({ icon: 'success', title: '다운로드 완료!', showConfirmButton: false, timer: 1000 });
    }

    // 3. 메인 로드 및 이벤트 바인딩
    $(function() {
        loadPayslipList(1);

        $("#btnSearch").on("click", function() {
            loadPayslipList(1);
        });

        // 🔥 페이지네이션 동적 클릭 이벤트 바인딩
        // ArticlePage에서 생성된 <a> 태그들은 동적으로 생성되므로 $(document).on 을 사용해야함
        $(document).on("click", ".pagination a", function(e) {
            e.preventDefault();
            // ArticlePage의 pagingArea 내 <a>태그가 data-page 혹은 onclick 형식을 쓰는지 확인 필요
            // 만약 클래스로 제어한다면 아래와 같이 처리 가능
            let page = $(this).data("page"); 
            if(page) {
                loadPayslipList(page);
            }
        });
    });

    // 4. 리스트 비동기 호출 함수
    function loadPayslipList(page) {
        let keyword = $("#searchKeyword").val(); // 검색어 input ID 확인
        
        axios.get("/emp/payslipList", {
            params: {
                currentPage: page,
                keyword: keyword
            }
        })
        .then(res => {
            const data = res.data; // ArticlePage 객체
            let html = "";
            
            if(data.content && data.content.length > 0) {
                data.content.forEach(vo => {
                    html += `
                    <tr>
                        <td class="fw-bold">\${vo.salMonth}</td>
                        <td>정기급여</td>
                        <td>\${vo.salMonth}-25</td>
                        <td>
                            <span class="amount-masked" onclick="this.classList.toggle('unmask')">
                                \${vo.salNetPay.toLocaleString()}
                            </span>
                        </td>
                        <td class="text-center">
                            <button class="btn-detail" onclick="showSlip('\${vo.salId}')">보기</button>
                        </td>
                    </tr>`;
                });
            } else {
                html = `<tr><td colspan="5" class="text-center">지급 내역이 없습니다.</td></tr>`;
            }

            // 리스트 본문 교체
            $("#payslipTableBody").html(html);
            
            // 🔥 핵심: ArticlePage가 계산해준 페이징 HTML을 그대로 꽂아줌
            $("#pagingArea").html(data.pagingArea);
        });
    }
</script>