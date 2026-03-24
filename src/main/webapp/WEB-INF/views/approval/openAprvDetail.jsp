<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>결재 상세 정보</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">


    <script src="/js/html2canvas.min.js"></script>
    <script src="/js/jspdf.umd.min.js"></script>

    <style>
        body { background-color: #f4f7ff; padding: 20px; font-family: 'Malgun Gothic', sans-serif; }

        /* 버튼 영역 스타일 추가 */
        .btn-action-area { max-width: 900px; margin: 0 auto 10px auto; text-align: right; }

        .document-container { max-width: 900px; margin: 0 auto; background: white; padding: 60px; border: 1px solid #ddd; box-shadow: 0 0 10px rgba(0,0,0,0.1); }

        /* [1] 최상단 헤더: 로고 키우기(1.3배) */
        .top-center-header {
            display: flex; flex-direction: column;
            align-items: center; justify-content: center; margin-bottom: 40px;
        }
        .slogan { font-size: 14px; color: #666; margin-bottom: 5px; width: 100%; text-align: center; }
        .logo-company-wrapper { display: flex; align-items: center; gap: 12px; }
        .logo-company-wrapper img { width: 52px; height: auto; }
        .company-name { font-size: 26px; font-weight: bold; }

        /* [2] 정보 및 결재라인 (결재 칸 0.85배 축소) */
        .info-approval-wrapper { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 15px; }
        .doc-info { font-size: 15px; line-height: 1.8; font-weight: bold; }

        .approval-table { border-collapse: collapse; font-size: 11px; }
        .approval-table td {
            border: 1px solid #000; width: 68px; text-align: center; padding: 4px;
        }
        .aprv-side-title { background-color: #f8f9fa; width: 22px !important; }

        /* [추가] 구분선 스타일 미세 조정 */
        .section-divider { border: 0; border-top: 2px solid #000; margin: 0 0 30px 0; }

        /* [수정] 문서 제목: 크기 조절, 여백 축소, 정렬 변경 */
        .doc-title { text-align: left; font-size: 22px; font-weight: bold; margin-top: 40px; margin-bottom: 10px; letter-spacing: 1px; padding-left: 5px; }

        /* 본문 데이터 테이블 */
        .main-content-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .main-content-table th, .main-content-table td { border: 1px solid #000; padding: 12px; text-align: center; font-size: 14px; }
        .bg-label { background-color: #f8f9fa; font-weight: bold; }
        .text-start { text-align: left !important; }

        /* 인쇄용 CSS: 버튼 영역 숨김 처리 */
        @media print {
            body { background-color: white; padding: 0; }
            .btn-action-area { display: none !important; }
            .document-container { box-shadow: none; border: none; padding: 20px; }
        }

        /* --- 유틸리티 버튼 (PDF, 인쇄) 커스텀 --- */

        /* PDF 다운로드 버튼 (고급스러운 파스텔 레드 -> 호버 시 쨍하게) */
        .btn-aprv-pdf {
            background-color: #ffe0db;
            color: #ff3e1d;
            border: 1px solid #ffc5bb;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.85rem;
            padding: 6px 14px;
            transition: all 0.2s ease;
        }
        .btn-aprv-pdf:hover {
            background-color: #ff3e1d;
            color: #ffffff;
            border-color: #ff3e1d;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(255, 62, 29, 0.25);
        }

        /* 인쇄하기 버튼 (차분하고 깔끔한 그레이 -> 호버 시 다크하게) */
        .btn-aprv-print {
            background-color: #f4f5f7;
            color: #566a7f;
            border: 1px solid #d9dee3;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.85rem;
            padding: 6px 14px;
            transition: all 0.2s ease;
        }
        .btn-aprv-print:hover {
            background-color: #566a7f;
            color: #ffffff;
            border-color: #566a7f;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(86, 106, 127, 0.2);
        }



    </style>
</head>
<body>

<div class="btn-action-area d-flex align-items-center justify-content-end gap-2">
    <span id="attachmentDropdownArea"></span>

    <button type="button" id="btnPdf" class="btn btn-aprv-pdf d-flex align-items-center">
        <span class="material-icons me-1" style="font-size: 16px;">picture_as_pdf</span> PDF 다운로드
    </button>

    <button type="button" class="btn btn-aprv-print d-flex align-items-center" onclick="printSpecificElement('pdfArea')">
        <span class="material-icons me-1" style="font-size: 16px;">print</span> 인쇄하기
    </button>
</div>

<div class="document-container" id="pdfArea">
    <div class="top-center-header">
        <div class="slogan">개발자가 행복한 회사 결재완료문서</div>
        <div class="logo-company-wrapper">
            <img src="/images/icon.png" alt="Logo">
            <div class="company-name">일업주식회사</div>
        </div>
    </div>

    <div class="info-approval-wrapper">
        <div class="doc-info">
            <div>결재문서번호: <span id="aprvNoDisplay">${aprvNo}</span></div>
            <div>부서명: <span id="deptNmDisplay">로딩중...</span></div>
        </div>

        <div class="approval-section">
            <table class="approval-table">
                <tr>
                    <td rowspan="2" class="aprv-side-title">결<br>재</td>
                    <td id="posNm1">-</td>
                    <td id="posNm2">-</td>
                    <td id="posNm3">-</td>
                    <td id="posNm4">-</td>
                    <td id="posNm5">-</td>
                </tr>
                <tr style="height: 47px;">
                    <td id="aprvLine1">-</td>
                    <td id="aprvLine2">-</td>
                    <td id="aprvLine3">-</td>
                    <td id="aprvLine4">-</td>
                    <td id="aprvLine5">-</td>
                </tr>
            </table>
        </div>
    </div>


    <div class="doc-title">
        제목 : <span id="aprvTtlDisplay">결재 문서 제목</span>
    </div>
    <hr class="section-divider">

    <div id="docBody">
    </div>

</div>


<script>
    document.addEventListener("DOMContentLoaded", function() {
        const aprvNo = "${aprvNo}";
        if(aprvNo) {
            loadApprovalDetail(aprvNo);
        }

        // ==========================================
        // 1. PDF 다운로드 이벤트
        // ==========================================
        document.getElementById("btnPdf").addEventListener("click", () => {
            const target = document.getElementById("pdfArea");

            // html2canvas로 캡처 (해상도를 위해 scale: 2 적용)
            html2canvas(target, { scale: 2 }).then(canvas => {
                const imgData = canvas.toDataURL("image/png");

                // A4 규격 (210mm x 297mm)
                const imgWidth = 210;
                const imgHeight = imgWidth * canvas.height / canvas.width;

                // jsPDF 객체 생성 및 이미지 추가
                const { jsPDF } = window.jspdf;
                const doc = new jsPDF("p", "mm", "a4");

                doc.addImage(imgData, "PNG", 0, 0, imgWidth, imgHeight);

                // 파일명 설정 후 저장
                const currentAprvNo = document.getElementById("aprvNoDisplay").innerText || aprvNo;
                doc.save(`결재문서_\${currentAprvNo}.pdf`);
            }).catch(err => {
                console.error("PDF 생성 중 오류 발생:", err);
                // (알람 리팩토링) PDF 생성 실패 에러 알림
                AppAlert.error("다운로드 실패", "PDF 생성 중 오류가 발생했습니다.");
            });
        });
    });

    // ==========================================
    // 2. 화면 특정 영역 인쇄 함수 (프린터 출력)
    // ==========================================
    function printSpecificElement(elementId) {
        const targetElement = document.getElementById(elementId);
        if (!targetElement) {
            console.error("인쇄할 영역을 찾을 수 없습니다.");
            return;
        }

        // 임시 iframe 생성
        const printFrame = document.createElement("iframe");
        printFrame.style.display = "none";
        document.body.appendChild(printFrame);

        const frameDoc = printFrame.contentWindow.document;

        // 인쇄할 내용 가져오기
        const printContent = targetElement.innerHTML;
        // iframe 내부에 HTML 구성 (CSS 포함)
        frameDoc.open();
        frameDoc.write(`
            <html>
            <head>
                <title>결재문서 인쇄</title>
                <style>
                    /* 인쇄 시 필요한 기본 스타일 복사 */
                    body { background-color: white; font-family: 'Malgun Gothic', sans-serif; padding: 20px; }
                    .document-container { margin: 0 auto; background: white; padding: 20px; }
                    .top-center-header { display: flex; flex-direction: column; align-items: center; justify-content: center; margin-bottom: 40px; }
                    .slogan { font-size: 14px; color: #666; margin-bottom: 5px; text-align: center; }
                    .logo-company-wrapper { display: flex; align-items: center; gap: 12px; }
                    .logo-company-wrapper img { width: 52px; height: auto; }
                    .company-name { font-size: 26px; font-weight: bold; }
                    .info-approval-wrapper { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 15px; }
                    .doc-info { font-size: 15px; line-height: 1.8; font-weight: bold; }
                    .approval-table { border-collapse: collapse; font-size: 11px; }
                    .approval-table td { border: 1px solid #000; width: 68px; text-align: center; padding: 4px; }
                    .aprv-side-title { background-color: #f8f9fa; width: 22px !important; }
                    .section-divider { border: 0; border-top: 2px solid #000; margin: 0 0 30px 0; }
                    .doc-title { text-align: left; font-size: 22px; font-weight: bold; margin-top: 40px; margin-bottom: 10px; padding-left: 5px; }
                    .main-content-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
                    .main-content-table th, .main-content-table td { border: 1px solid #000; padding: 12px; text-align: center; font-size: 14px; }
                    .bg-label { background-color: #f8f9fa; font-weight: bold; }
                    @media print {
                        @page { margin: 10mm; }
                    }
                </style>
            </head>
            <body>
                <div class="document-container">
                    \${printContent}
                </div>
            </body>
            </html>
        `);
        frameDoc.close();

        // 렌더링 대기 후 인쇄 실행
        setTimeout(function() {
            printFrame.contentWindow.focus();
            printFrame.contentWindow.print();

            // 인쇄 후 iframe 제거
            setTimeout(function() {
                document.body.removeChild(printFrame);
            }, 1000);
        }, 500);
    }

    // ==========================================
    // 3. 결재 상세 데이터 로딩
    // ==========================================

    // 근태 표시 용 날짜 포맷팅 함수
    function getFormatDateWithDay(dateString) {
        if (!dateString) return '';
        const datePart = dateString.substring(0, 10); // 10자리만 자르기
        const days = ['일', '월', '화', '수', '목', '금', '토'];
        const dayName = days[new Date(datePart).getDay()];
        return datePart + ' (' + dayName + ')';
    }


    function loadApprovalDetail(aprvNo) {
        Promise.all([
            axios.get(`/approval/getAprvLine?aprvNo=\${aprvNo}`),
            axios.get(`/approval/getPendingDoc?aprvNo=\${aprvNo}`)
        ])
            .then(response => {
                const aprvLineList = response[0].data; //결재선..
                console.log("결재선 결재이미지 가져오나 확인합시다. : ", aprvLineList);
                const data = response[1].data;
                console.log("결재문서 본문 data확인 : ", data);

                // 기본 정보 세팅 (상단 헤더 영역)
                document.getElementById("posNm1").innerText = data.posNm || '';

                //결재자 결재 이미지도 넣기
                console.log("결재작성자 결재이미지 가져오나 확인합시다. : ", data.docWriterEmpSign);
                if (data.docWriterEmpSign) {
                    document.getElementById("aprvLine1").innerHTML = `<img src="/emp/displaySign?fileName=\${data.docWriterEmpSign}" class="mp-sign-img" alt="Sign" style="max-width: 100%; max-height: 40px; object-fit: contain;">`;
                } else {
                    document.getElementById("aprvLine1").innerHTML = `<span class="fw-bold">\${data.docWriterNm || '상신'}</span>`;
                }

                document.getElementById("deptNmDisplay").innerText = data.docWriterDeptNm || '';
                document.getElementById("aprvTtlDisplay").innerText = data.aprvTtl || '';

                // 결재라인(결재선) 채우기
                aprvLineList.forEach(function(aprvLine, i) {
                    //두번째 칸부터 채우기!
                    let posNmId = "posNm" + (i + 2);
                    let aprvLineId = "aprvLine" + (i + 2);

                    //직급넣기
                    if(document.getElementById(posNmId)) {
                        document.getElementById(posNmId).innerText = aprvLine.empJbgd || '';
                    }

                    if(document.getElementById(aprvLineId)) {
                        if (aprvLine.aprvLnStts == 'APRV02001') {
                            document.getElementById(aprvLineId).innerText = '미결재';
                        } else if (aprvLine.aprvLnStts == 'APRV02002') {

                            //서명 이미지가 있으면 <img> 태그 삽입, 없으면 이름 텍스트 출력
                            if (aprvLine.empSign) {
                                document.getElementById(aprvLineId).innerHTML = `<img src="/emp/displaySign?fileName=\${aprvLine.empSign}" class="mp-sign-img" alt="Sign" style="max-width: 100%; max-height: 40px; object-fit: contain;">`;
                            } else {
                                document.getElementById(aprvLineId).innerHTML = `<span class="fw-bold">\${aprvLine.aprvNm || '승인'}</span>`;
                            }
                        } else {
                            document.getElementById(aprvLineId).innerText = '반려';
                        }
                    }
                });

                // 문서 종류별 본문 세팅
                let str = "";
                switch (data.aprvSe) {
                    case 'APRV01001':
                        console.log("지출결의서(1:N) 완료 문서를 처리합니다.");

                        // 1. 지출 내역 테이블의 헤더와 기본 틀 생성
                        str = `
                            <div class="text-center fw-bold" style="font-size: 26px; letter-spacing: 15px; margin-top: 20px; margin-bottom: 40px;">지 출 품 의 서</div>
                            <p class="mb-2 fw-bold">다음과 같이 지출 품의를 신청하오니 재가하여 주시기 바랍니다.</p>

                            <table class="main-content-table text-center">
                                <thead>
                                    <tr class="bg-label">
                                        <th style="width: 25%;">예산 비목</th>
                                        <th style="width: 20%;">지출 금액</th>
                                        <th style="width: 55%;">적요 (사유)</th>
                                    </tr>
                                </thead>
                                <tbody>
                        `;

                        // 변수 충돌 방지를 위해 expndTotalSum으로 이름 지정
                        let expndTotalSum = 0;

                        // 2. 리스트(expndDocList)를 돌면서 행(Row) 생성
                        if (data.expndDocList && data.expndDocList.length > 0) {
                            data.expndDocList.forEach(item => {
                                const amt = item.expndAmt || 0;
                                expndTotalSum += amt;

                                str += `
                                    <tr>
                                        <td class="bg-light fw-bold">\${item.bgtItmNm || '-'}</td>
                                        <td class="text-end px-3">\${amt.toLocaleString()} 원</td>
                                        <td class="text-start px-3">\${item.expndRsn || '-'}</td>
                                    </tr>
                                `;
                            });
                        } else {
                            str += `<tr><td colspan="3" class="py-3 text-muted">입력된 지출 내역이 없습니다.</td></tr>`;
                        }

                        // 3. 총계 행 추가 및 테이블 닫기
                        str += `
                                </tbody>
                                <tfoot>
                                    <tr class="bg-light fw-bold">
                                        <td>총 합 계</td>
                                        <td class="text-end px-3 text-danger">\${expndTotalSum.toLocaleString()} 원</td>
                                        <td></td>
                                    </tr>
                                </tfoot>
                            </table>
                            <div class="mt-4 fw-bold text-start ps-2">위와 같이 기안하오니 재가하여 주시기 바랍니다.</div>
                            <div class="mt-2 fw-bold text-start ps-2">끝.</div>
                        `;

                        // 4. 최종적으로 docBody 영역에 꽂아넣기!
                        document.getElementById("docBody").innerHTML = str;
                        break;

                    case 'APRV01002':
                        console.log("휴가신청서입니다.");
                        console.log("DB에 있는 휴가 실제 사용일수 잘 받아와짐?? : ", data.vctTotalDays);

                        //날짜 포맷팅
                        const vctBgngDateHtml = getFormatDateWithDay(data.vctDocBgng);
                        const vctEndDateHtml = getFormatDateWithDay(data.vctDocEnd);

                        str = `
                        <div class="text-center fw-bold" style="font-size: 26px; letter-spacing: 15px; margin-top: 20px; margin-bottom: 40px;">휴 가 신 청 서</div>
                        <p class="mb-2 fw-bold">다음과 같이 휴가를 신청하오니 재가하여 주시기 바랍니다.</p>
                        <table class="main-content-table">
                            <tr>
                                <th class="bg-label" style="width: 15%;">소속부서</th>
                                <td style="width: 18%; text-align: center;" class="align-middle">\${data.docWriterDeptNm || ''}</td>
                                <th class="bg-label" style="width: 15%;">직급</th>
                                <td style="width: 18%; text-align: center;" class="align-middle">\${data.posNm || ''}</td>
                                <th class="bg-label" style="width: 15%;">성명</th>
                                <td style="width: 19%; text-align: center;" class="align-middle">\${data.docWriterNm || ''}</td>
                            </tr>
                            <tr>
                                <th class="bg-label py-2">휴가 구분</th>
                                <td colspan="5" class="text-center align-middle">\${data.vctDocCd || ''}</td>
                            </tr>
                            <tr>
                                <th class="bg-label py-2">시작일자</th>
                                <td class="text-center align-middle" style="line-height: 1.4;">\${vctBgngDateHtml}</td>
                                <th class="bg-label py-2">종료일자</th>
                                <td class="text-center align-middle" style="line-height: 1.4;">\${vctEndDateHtml}</td>
                                <th class="bg-label py-2">사용 일수</th>
                                <td class="text-center align-middle">\${data.vctTotalDays > 0 ? data.vctTotalDays + ' 일' : '-'}</td>
                            </tr>
                            <tr>
                                <th class="bg-label py-4">신청 사유</th>
                                <td colspan="5" class="align-top text-start" style="padding: 15px; white-space: pre-wrap; height: 160px; line-height: 1.6;">\${data.vctDocRsn || ''}</td>
                            </tr>
                        </table>
                        <div class="mt-4 fw-bold text-start ps-2">끝.</div>
                        `;
                        document.getElementById("docBody").innerHTML = str;
                        break;

                    case 'APRV01003':
                        console.log("출장신청서입니다.");
                        //날짜 포맷팅
                        const bzBgngDateHtml = getFormatDateWithDay(data.bztrpStart);
                        const bzEndDateHtml = getFormatDateWithDay(data.bztrpEnd);

                        str = `
                        <div class="text-center fw-bold" style="font-size: 26px; letter-spacing: 15px; margin-top: 20px; margin-bottom: 40px;">출 장 신 청 서</div>
                        <p class="mb-2 fw-bold">다음과 같이 출장을 신청하오니 재가하여 주시기 바랍니다.</p>
                        <table class="main-content-table">
                            <tr>
                                <th class="bg-label" style="width: 15%;">소속부서</th>
                                <td style="width: 18%; text-align: center;" class="align-middle">\${data.docWriterDeptNm || ''}</td>
                                <th class="bg-label" style="width: 15%;">직급</th>
                                <td style="width: 18%; text-align: center;" class="align-middle">\${data.posNm || ''}</td>
                                <th class="bg-label" style="width: 15%;">성명</th>
                                <td style="width: 19%; text-align: center;" class="align-middle">\${data.docWriterNm || ''}</td>
                            </tr>
                            <tr>
                                <th class="bg-label py-2">출장지</th>
                                <td colspan="5" class="text-center align-middle">\${data.bztrpPlc || ''}</td>
                            </tr>
                            <tr>
                                <th class="bg-label py-2">시작일자</th>
                                <td colspan="2" class="text-center align-middle" style="line-height: 1.4;">\${bzBgngDateHtml}</td>
                                <th class="bg-label py-2">종료일자</th>
                                <td colspan="2" class="text-center align-middle" style="line-height: 1.4;">\${bzEndDateHtml}</td>
                            </tr>
                            <tr>
                                <th class="bg-label py-4">신청 사유</th>
                                <td colspan="5" class="align-top text-start" style="padding: 15px; white-space: pre-wrap; height: 160px; line-height: 1.6;">\${data.bztrpRsn || ''}</td>
                            </tr>
                        </table>
                        <div class="mt-4 fw-bold text-start ps-2">끝.</div>
                        `;
                        document.getElementById("docBody").innerHTML = str;
                        break;

                    case 'APRV01004':
                        console.log("초과근무신청입니다.");
                        //날짜 포맷팅
                        const excsDateHtml = getFormatDateWithDay(data.excsWorkDocBgng);
                        str = `
                            <div class="text-center fw-bold" style="font-size: 26px; letter-spacing: 10px; margin-top: 20px; margin-bottom: 40px;">초 과 근 무 신 청 서</div>
                            <p class="mb-2 fw-bold">다음과 같이 초과근무를 신청하오니 재가하여 주시기 바랍니다.</p>
                            <table class="main-content-table">
                                <tr>
                                    <th class="bg-label" style="width: 15%;">소속부서</th>
                                    <td style="width: 18%; text-align: center;" class="align-middle">\${data.docWriterDeptNm || ''}</td>
                                    <th class="bg-label" style="width: 15%;">직급</th>
                                    <td style="width: 18%; text-align: center;" class="align-middle">\${data.posNm || ''}</td>
                                    <th class="bg-label" style="width: 15%;">성명</th>
                                    <td style="width: 19%; text-align: center;" class="align-middle">\${data.docWriterNm || ''}</td>
                                </tr>
                                <tr>
                                    <th class="bg-label py-2">초과근무 일자</th>
                                    <td colspan="5" class="text-center align-middle" style="line-height: 1.4; height: 45px;">
                                        \${excsDateHtml}
                                    </td>
                                </tr>
                                <tr>
                                    <th class="bg-label py-4">신청 사유<br>(상세히 기재)</th>
                                    <td colspan="5" class="align-top text-start" style="padding: 15px; white-space: pre-wrap; height: 160px; line-height: 1.6;">\${data.excsWorkDocRes || ''}</td>
                                </tr>
                            </table>
                            <div class="mt-4 fw-bold">&nbsp;&nbsp;끝.</div>
                        `;
                        document.getElementById("docBody").innerHTML = str;
                        break;
                    case 'APRV01005':
                        console.log("일일보고입니다.");
                        break;

                    case 'APRV01006':
                        console.log("일반기안입니다.");
                        str = `
                        <div class="aprv-content-box" style="min-height: 400px; padding: 10px; line-height: 1.8; font-size: 1.05rem;">
                            <div style="white-space: pre-wrap; word-break: break-all;">\${data.nmlCn || ''}</div>
                        </div>
                        <div style="margin-top: 50px;">
                            <div class="fw-bold text-end" style="margin-bottom: 10px;">위와 같이 기안하오니 검토 후 결재 바랍니다.</div>
                            <div class="fw-bold text-center" style="font-size: 1.2rem; margin-top: 20px;">
                                \${data.aprvDt ? data.aprvDt.substring(0, 10) : ''}
                            </div>
                            <div class="mt-4 fw-bold">&nbsp;&nbsp;끝.</div>
                        </div>
                        `;
                        document.getElementById("docBody").innerHTML = str;
                        break;
                    case 'APRV01007':
                        console.log("사직서입니다.");
                        break;

                    default:
                        console.log("알 수 없는 양식...");
                        document.getElementById("docBody").innerHTML = "<p class='text-center mt-5'>양식을 불러올 수 없습니다.</p>";
                        break;
                }//end switch

                // ★ 첨부파일이 있을 경우 상단 영역에 드롭다운 버튼 생성!
                if (data.fileTbVO && data.fileTbVO.fileDetailVOList && data.fileTbVO.fileDetailVOList.length > 0) {
                    const fileList = data.fileTbVO.fileDetailVOList;
                    let attachHtml = `
                        <div class="btn-group d-inline-block">
                            <button type="button" class="btn btn-secondary btn-sm dropdown-toggle text-white d-flex align-items-center" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="material-icons me-1" style="font-size: 16px;">attach_file</i>
                                첨부파일 <span class="badge bg-danger ms-1" style="font-size: 10px;">\${fileList.length}</span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="font-size: 13px; max-height: 200px; overflow-y: auto;">
                    `;
                    fileList.forEach(fileDtl => {
                        attachHtml += `
                                <li>
                                    <a class="dropdown-item d-flex align-items-center py-2" href="/download?fileDtlId=\${fileDtl.fileDtlId}">
                                        <i class="material-icons text-muted me-2" style="font-size: 16px;">insert_drive_file</i>
                                        \${fileDtl.fileDtlONm} (\${fileDtl.fileDtlExt})
                                    </a>
                                </li>
                        `;
                    });
                    attachHtml += `
                            </ul>
                        </div>
                    `;
                    document.getElementById("attachmentDropdownArea").innerHTML = attachHtml;
                }

            })
            .catch(err => {
                console.error("데이터 로딩 실패:", err);
                // (알람 리팩토링) 문서 로딩 실패 시 에러 알림
                AppAlert.error("로딩 실패", "결재 문서 정보를 불러오는 데 실패했습니다.");
            });
    }
</script>





</body>
</html>