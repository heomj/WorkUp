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

    <!-- 알람 커스텀 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="/js/common-alert.js"></script>



    <style>
        body { background-color: #f4f7ff; padding: 20px; font-family: 'Malgun Gothic', sans-serif; }
        .document-container { max-width: 900px; margin: 0 auto; background: white; padding: 60px; border: 1px solid #ddd; box-shadow: 0 0 10px rgba(0,0,0,0.1); }

        /* [1] 최상단 헤더: 로고 키우기(1.3배) */
        .top-center-header {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            margin-bottom: 40px;
        }
        .slogan { font-size: 14px; color: #666; margin-bottom: 5px; width: 100%; text-align: center; }
        .logo-company-wrapper {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .logo-company-wrapper img {
            width: 52px; /* 40px에서 1.3배인 52px로 확대 */
            height: auto;
        }
        .company-name { font-size: 26px; font-weight: bold; }

        /* [2] 정보 및 결재라인 (결재 칸 0.85배 축소) */
        .info-approval-wrapper { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 15px; }
        .doc-info { font-size: 15px; line-height: 1.8; font-weight: bold; }

        .approval-table { border-collapse: collapse; font-size: 11px; } /* 폰트 소폭 축소 */
        .approval-table td {
            border: 1px solid #000;
            width: 68px; /* 80px에서 0.85배인 약 68px로 축소 */
            text-align: center;
            padding: 4px;
        }
        .aprv-side-title { background-color: #f8f9fa; width: 22px !important; }

        /* [추가] 구분선 스타일 미세 조정 */
        .section-divider {
            border: 0;
            border-top: 2px solid #000; /* 선 두께를 살짝 키워 본문과의 경계를 확실히 함 */
            margin: 0 0 30px 0;         /* 상단 여백은 없애고 하단 여백만 유지 */
        }

        /* [수정] 문서 제목: 크기 조절, 여백 축소, 정렬 변경 */
        .doc-title {
            text-align: left;        /* 공문서 스타일을 위해 왼쪽 정렬 (필요시 center 유지 가능) */
            font-size: 22px;         /* 30px에서 22px로 축소하여 격식 강조 */
            font-weight: bold;
            margin-top: 40px;        /* 상단 여백 추가 */
            margin-bottom: 10px;     /* hr과의 거리를 좁히기 위해 60px에서 10px로 대폭 축소 */
            letter-spacing: 1px;     /* 가독성을 위해 자간 조정 */
            padding-left: 5px;       /* 왼쪽 여백 살짝 추가 */
        }

        /* 본문 데이터 테이블 */
        .main-content-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .main-content-table th, .main-content-table td { border: 1px solid #000; padding: 12px; text-align: center; font-size: 14px; }
        .bg-label { background-color: #f8f9fa; font-weight: bold; }
        .text-start { text-align: left !important; }

        .action-area { position: sticky; bottom: 0; background: #fff; padding: 20px; border-top: 1px solid #eee; margin-top: 30px; box-shadow: 0 -5px 10px rgba(0,0,0,0.05); z-index: 1000; }

    /* 첨부파일 css 시작*/
        /* --- 첨부파일 영역 스타일 (이메일 모듈과 동일) --- */
        .attachment-box {
            background-color: #f1f2f4;
            border-radius: 6px;
            padding: 1rem; /* 하단 영역에 맞게 패딩 살짝 축소 */
            border: 1px solid #e1e4e8;
        }

        .attachment-item {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #ffffff;
            border: 1px solid #dcdfe6;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 0.8rem;
            color: #444;
            text-decoration: none;
            white-space: nowrap;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: all 0.2s ease-in-out;
        }

        .attachment-item:hover {
            border-color: #696cff;
            background-color: #f8f9ff;
            color: #696cff;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(105, 108, 255, 0.15);
        }
    /* 첨부파일 css 끝*/




        /* --- 승인/반려/닫기 버튼 커스텀 --- */

        /* 1. 승인 버튼 (메인 컬러) */
        .btn-aprv-confirm {
            background-color: #696cff;
            color: #ffffff;
            border: 1px solid #696cff;
            border-radius: 8px;
            font-weight: 700;
            transition: all 0.2s ease-in-out;
            box-shadow: 0 2px 4px rgba(105, 108, 255, 0.3);
        }

        .btn-aprv-confirm:hover {
            background-color: #5f61e6;
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(105, 108, 255, 0.4);
        }

        /* 2. 반려 버튼 (세련된 레드 포인트) */
        .btn-aprv-reject {
            background-color: #ffffff;
            color: #ff3e1d;
            border: 1px solid #ff3e1d;
            border-radius: 8px;
            font-weight: 700;
            transition: all 0.2s ease-in-out;
            box-shadow: 0 2px 4px rgba(255, 62, 29, 0.1);
        }

        .btn-aprv-reject:hover {
            background-color: #fff2f0;
            color: #ff3e1d;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(255, 62, 29, 0.2);
        }

        /* 3. 닫기 버튼 (차분하고 깔끔한 회색톤) */
        .btn-aprv-close {
            background-color: #ffffff;
            color: #8592a3;
            border: 1px solid #d9dee3;
            border-radius: 8px;
            font-weight: 700;
            transition: all 0.2s ease-in-out;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
        }

        .btn-aprv-close:hover {
            background-color: #f4f5f7;
            color: #566a7f;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }ㄴ





    </style>






</head>
<body>

<div class="document-container">
    <div class="top-center-header">
        <div class="slogan">개발자가 행복한 회사</div>
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

    <!-- /// docBody 시작 /// -->
    <div id="docBody">

        <p class="mb-2">다음과 같이 출장을 신청합니다.</p>

            <table class="main-content-table">
                <tr>
                    <th class="bg-label" style="width: 15%;">소속부서</th>
                    <td id="deptNm" style="width: 18%;">로딩중...</td>
                    <th class="bg-label" style="width: 15%;">직급</th>
                    <td id="posNm" style="width: 18%;">로딩중..</td>
                    <th class="bg-label" style="width: 15%;">성명</th>
                    <td id="writerNm" style="width: 19%;">로딩중...</td>
                </tr>

                <tr>
                    <th class="bg-label">출장기간</th>
                    <td id="aprvDt" colspan="3" class="data-cell">로딩중...</td>
                    <th class="bg-label">출장지</th>
                    <td id="location" class="data-cell">로딩중...</td>
                </tr>

                <tr>
                    <th class="bg-label">출장내용</th>
                    <td id="aprvCn" colspan="5" class="data-cell">
                        데이터를 불러오는 중입니다...
                    </td>
                </tr>
            </table>
        <div class="mt-4 fw-bold">&nbsp;&nbsp;끝.</div>
    </div>
    <!-- /// docBody 끝 /// -->


</div>

<div class="action-area">
    <div style="max-width: 850px; margin: 0 auto;">

        <div id="detail-file" class="mb-2"></div>

        <div class="mb-3">
            <label for="aprvComment" class="form-label fw-bold">결재 의견</label>
            <textarea class="form-control" id="aprvComment" rows="2" maxlength="150" placeholder="결재 의견을 입력하세요 (최대 150자)"></textarea>
        </div>

        <div class="d-flex justify-content-center gap-2">
            <button type="button" class="btn btn-aprv-confirm px-4 py-2 d-flex align-items-center" onclick="processApproval('CONFIRM')">
                <span class="material-icons me-1" style="font-size: 1.1rem;">check_circle</span> 승인
            </button>

            <button type="button" class="btn btn-aprv-reject px-4 py-2 d-flex align-items-center" onclick="processApproval('REJECT')">
                <span class="material-icons me-1" style="font-size: 1.1rem;">cancel</span> 반려
            </button>

            <button type="button" class="btn btn-aprv-close px-4 py-2 d-flex align-items-center" onclick="window.close()">
                <span class="material-icons me-1" style="font-size: 1.1rem;">close</span> 닫기
            </button>
        </div>



    </div>
</div>

<div id="floatingAttachTab" class="floating-attach-tab" style="display: none;">
    <div class="floating-attach-icon">
        <span class="material-icons">attach_file</span>
        <span class="badge" id="attachCountBadge">0</span>
    </div>
    <div class="floating-attach-content">
        <h6 class="fw-bold text-primary mb-3" style="font-size: 14px;">첨부파일 목록</h6>
        <div id="floatingAttachList">
        </div>
    </div>
</div>


<script>
    //전역변수
    let isVctDoc = ""; // 휴가 여부 판별
    let vctDocCd = ""; // 휴가 종류 판별
    let vctUsedDays = 0; //휴가 사용 일수(가짜임)
    let vctTotalDays = 0; //진짜임
    let aprvDocNo = 0; // 결재 상세 문서 번호()
    let aprvSe = ""; //문서 종류
    let isAttDoc = ""; //근태문서여부
    let docWriterId = 0;//문서작성자

    //DOM
    document.addEventListener("DOMContentLoaded", function() {
        const aprvNo = "${aprvNo}";
        if(aprvNo) { loadApprovalDetail(aprvNo); }
    });

    // 근태 표시 용 날짜 포맷팅 함수
    function getFormatDateWithDay(dateString) {
        if (!dateString) return '';
        const datePart = dateString.substring(0, 10); // 10자리만 자르기
        const days = ['일', '월', '화', '수', '목', '금', '토'];
        const dayName = days[new Date(datePart).getDay()];
        return datePart + ' (' + dayName + ')';
    }

    //본문 가져오기
    function loadApprovalDetail(aprvNo) {

        //결재선과 본문 2개 한번에 가져오기
        Promise.all([
            axios.get(`/approval/getAprvLine?aprvNo=\${aprvNo}`),
            axios.get(`/approval/getPendingDoc?aprvNo=\${aprvNo}`)
        ])
            .then(response => {
                const aprvLineList = response[0].data;
                console.log("가져온 결재선", aprvLineList);

                const data = response[1].data;
                console.log("가져온 상세내용", data);
                aprvDocNo = data.aprvDocNo;
                console.log("가져온 상세문서번호", aprvDocNo);
                aprvSe = data.aprvSe;
                console.log("가져온 상세문서 종류 변수에 넣음 : ", aprvSe);
                docWriterId = data.docWriterId;
                console.log("문서작성자 아이디 잘 받아와지나요? : ", docWriterId);

                //일단 첫번째 결재칸에 결재작성자 정보 넣기
                document.getElementById("posNm1").innerText = data.posNm;
                //사인(서명)넣기
                if (data.docWriterEmpSign) {
                    document.getElementById("aprvLine1").innerHTML = `<img src="/emp/displaySign?fileName=\${data.docWriterEmpSign}" class="mp-sign-img" alt="Sign" style="max-width: 100%; max-height: 40px; object-fit: contain;">`;
                } else {
                    document.getElementById("aprvLine1").innerHTML = `<span class="fw-bold">\${data.docWriterNm || '상신'}</span>`;
                }

                //작성자 부서명
                document.getElementById("deptNmDisplay").innerText = data.docWriterDeptNm;

                //결재 문서 제목 쓰기
                document.getElementById("aprvTtlDisplay").innerText = data.aprvTtl;

                //결재라인 채우기
                aprvLineList.forEach(function(aprvLine, i){
                    let posNmId = "posNm" + (i + 2);
                    let aprvLineId = "aprvLine" + (i + 2);
                    //결재라인 직급넣기
                    document.getElementById(posNmId).innerText = aprvLine.empJbgd;

                    //결재자 서명 넣기
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
                });//end 결재라인 forEach

                let str = "";
                //결재 종류에따라 본문 바꿔 끼우기....흑흑흑...
                switch (aprvSe) {
                    case 'APRV01001':
                        console.log("지출결의서(1:N) 데이터를 처리합니다.");

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

                        let totalSum = 0;

                        // 2. 리스트(expndDocList)를 돌면서 행(Row) 생성
                        if (data.expndDocList && data.expndDocList.length > 0) {
                            data.expndDocList.forEach(item => {
                                const amt = item.expndAmt || 0;
                                totalSum += amt;

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
                                        <td class="text-end px-3 text-danger">\${totalSum.toLocaleString()} 원</td>
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
                        isVctDoc = 'Y';
                        isAttDoc = 'Y';
                        vctDocCd = data.vctDocCd;
                        console.log("휴가신청서 여부 잘 받아와지니? : ", isVctDoc);
                        console.log("휴가신청서 여부 잘 받아와지니? : ", vctDocCd);

                        console.log("DB에 있는 휴가 실제 사용일수 잘 받아와짐?? : ", data.vctTotalDays);
                        //그럼 전역변수에 담기
                        vctTotalDays = data.vctTotalDays;
                        //날짜 포맷팅 함수
                        const bgngDateHtml = getFormatDateWithDay(data.vctDocBgng);
                        const endDateHtml = getFormatDateWithDay(data.vctDocEnd);

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
                                    <td colspan="5" class="text-center align-middle">
                                        \${data.vctDocCd || ''}
                                    </td>
                                </tr>
                                <tr>
                                    <th class="bg-label py-2">시작일자</th>
                                    <td class="text-center align-middle" style="line-height: 1.4;">
                                        \${bgngDateHtml}
                                    </td>
                                    <th class="bg-label py-2">종료일자</th>
                                    <td class="text-center align-middle" style="line-height: 1.4;">
                                        \${endDateHtml}
                                    </td>
                                    <th class="bg-label py-2">사용 일수</th>
                                    <td class="text-center align-middle">
                                        \${vctTotalDays > 0 ? vctTotalDays + ' 일' : '-'}
                                    </td>
                                </tr>
                                <tr>
                                    <th class="bg-label py-4">신청 사유</th>
                                    <td colspan="5" class="align-top text-start" style="padding: 15px; white-space: pre-wrap; height: 160px; line-height: 1.6;">\${data.vctDocRsn || ''}</td>
                                </tr>
                            </table>

                            <div class="mt-4 fw-bold text-start ps-2">끝.</div>
                        `;
                        // 본문 바꿔 끼우기
                        document.getElementById("docBody").innerHTML = str;
                        break;

                    case 'APRV01003':
                        console.log("출장신청서입니다.");
                        isAttDoc = 'Y';

                        // 출장 시작일, 종료일 일자 + 요일 출력
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
                                    <td colspan="5" class="text-center align-middle">
                                        \${data.bztrpPlc || ''}
                                    </td>
                                </tr>

                                <tr>
                                    <th class="bg-label py-2">시작일자</th>
                                    <td colspan="2" class="text-center align-middle" style="line-height: 1.4;">
                                        \${bzBgngDateHtml}
                                    </td>

                                    <th class="bg-label py-2">종료일자</th>
                                    <td colspan="2" class="text-center align-middle" style="line-height: 1.4;">
                                        \${bzEndDateHtml}
                                    </td>
                                </tr>

                                <tr>
                                    <th class="bg-label py-4">신청 사유</th>
                                    <td colspan="5" class="align-top text-start" style="padding: 15px; white-space: pre-wrap; height: 160px; line-height: 1.6;">\${data.bztrpRsn || ''}</td>
                                </tr>
                            </table>
                            <div class="mt-4 fw-bold text-start ps-2">끝.</div>
                        `;
                        // 본문 바꿔 끼우기
                        document.getElementById("docBody").innerHTML = str;
                        break;

                    case 'APRV01004':
                        console.log("초과근무신청입니다.");
                        isAttDoc = 'Y'; //근태 문서 여부

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
                                    <th class="bg-label py-4">신청 사유</th>
                                    <td colspan="5" class="align-top text-start" style="padding: 15px; white-space: pre-wrap; height: 160px; line-height: 1.6;">\${data.excsWorkDocRes || ''}</td>
                                </tr>
                            </table>
                            <div class="mt-4 fw-bold text-start ps-2">끝.</div>
                        `;
                        // 본문 바꿔 끼우기
                        document.getElementById("docBody").innerHTML = str;
                        break;

                    case 'APRV01005':
                        console.log("일일보고입니다.");
                        break;

                    case 'APRV01006':
                        console.log("일반기안입니다.");
                        str = `
                            <div class="aprv-content-box" style="min-height: 400px; padding: 10px; line-height: 1.8; font-size: 1.05rem;">
                                <div style="white-space: pre-wrap; word-break: break-all;">\${data.nmlCn}</div>
                            </div>

                            <div style="margin-top: 50px;">
                                <div class="fw-bold text-end" style="margin-bottom: 10px;">위와 같이 기안하오니 검토 후 결재 바랍니다.</div>
                                <div class="fw-bold text-center" style="font-size: 1.2rem; margin-top: 20px;">
                                    \${data.aprvDt ? data.aprvDt.substring(0, 10) : ''}
                                </div>

                                <div class="mt-4 fw-bold">&nbsp;&nbsp;끝.</div>
                            </div>
                        `;
                        //본문 바꿔 끼우기
                        document.getElementById("docBody").innerHTML = str;
                        break;

                    case 'APRV01007':
                        console.log("사직서입니다.");
                        break;

                    default:
                        console.log("알 수 없는 양식...");
                        break;
                }

                let fileHtml = '';
                if (data.fileTbVO && data.fileTbVO.fileDetailVOList && data.fileTbVO.fileDetailVOList.length > 0) {
                    const fileList = data.fileTbVO.fileDetailVOList;
                    // 하단 공간 차지를 막기 위해 max-height와 overflow-y 추가
                    fileHtml += `
                    <div class="attachment-box" style="max-height: 85px; overflow-y: auto;">
                        <div class="fw-bold mb-2 d-flex align-items-center" style="font-size: 13px;">
                            <span class="material-icons me-1" style="font-size: 1.1rem;">attach_file</span>
                            첨부파일 (\${fileList.length}개)
                        </div>
                        <div class="d-flex flex-wrap gap-2">`;
                    fileList.forEach(fileDtl => {
                        fileHtml += `
                        <a href="/download?fileDtlId=\${fileDtl.fileDtlId}" class="attachment-item">
                            <span class="material-icons me-1" style="font-size: 0.9rem;">description</span>
                            \${fileDtl.fileDtlONm} (\${fileDtl.fileDtlExt})
                        </a>`;
                    });
                    fileHtml += `</div></div>`;
                }

                // 만들어진 첨부파일 HTML을 결재의견 위쪽에 꽂아줌
                document.getElementById('detail-file').innerHTML = fileHtml;
            })
            .catch(err => {
                console.error("데이터 로딩 실패:", err);
                AppAlert.error('데이터 로딩 실패', '결재 상세 정보를 가져오는데 실패했습니다.'); // (알람 리팩토링)
            });
    }

    //상태업데이트
    function processApproval(status) {

        const commentVal = document.getElementById('aprvComment').value || "";

        // 코멘트 길이 유효성 검사 (150자 제한)
        if (commentVal.length > 150) {
            AppAlert.warning(
                '의견 길이 초과',
                '결재 의견은 최대 150자까지만 입력할 수 있습니다.<br><span class="text-danger">(현재 글자 수: ' + commentVal.length + '자)</span>',
                'aprvComment',
                'chat'
            );
            return; // 150자가 넘으면 통신 중단!
        }



        const aprvNo = "${aprvNo}";
        const comment = document.getElementById("aprvComment").value;
        let aprvLnStts = ""; //결재 상태 코드 넘기기

        let titleText = status === 'CONFIRM' ? "승인하시겠습니까?" : "반려하시겠습니까?";
        let confirmBtnText = status === 'CONFIRM' ? "승인" : "반려";

        // (알람 리팩토링) 상태에 따른 테마 색상과 아이콘 변경
        let themeColor = status === 'CONFIRM' ? "success" : "danger";
        let iconName = status === 'CONFIRM' ? "check_circle" : "cancel";

        if(status === 'CONFIRM'){ //승인
            aprvLnStts ="APRV02002"
        }else if(status === 'REJECT'){ //반려
            aprvLnStts ="APRV02003"
        }else{
            console.log("결재 상태 이상");
            return;
        }

        // (알람 리팩토링) AppAlert 컨펌창 적용
        AppAlert.confirm(titleText, "결재 상태는 되돌릴 수 없습니다.", confirmBtnText, '취소', iconName, themeColor) // (알람 리팩토링)
            .then((result) => {
                if (result.isConfirmed) {
                    // 사용자가 '승인' 또는 '반려' 버튼을 눌렀을 때만 아래 로직 실행

                    //휴가 판별하기 위한 값도 함께 넣기(isVctDoc, vctDocCd)
                    //혹시 모르니까 vctUsedDays(가짜 데이터) 변수도 살려놓고 진짜 변수로 담아둠
                    const data = {
                        "aprvNo" : aprvNo,
                        "isVctDoc" : isVctDoc,
                        "vctDocCd" : vctDocCd,
                        "vctUsedDays" : vctTotalDays,
                        "vctTotalDays" : vctTotalDays,
                        "aprvDocNo" : aprvDocNo,
                        "aprvSe" : aprvSe,
                        "isAttDoc" : isAttDoc,
                        "docWriterId" : docWriterId,
                        "aprvLnStts" : aprvLnStts,
                        "aprvLnCn" : comment
                    };

                    console.log("결재 처리 버튼 눌렀을때(승인/반려) data 확인 : ", data);


                    axios.post("/approval/processAprvAxios", data)
                        .then(response => {
                            // (알람 리팩토링) AppAlert 성공창 적용
                            AppAlert.success('결재 완료', '결재 처리가 성공적으로 완료되었습니다.') // (알람 리팩토링)
                                .then(() => {
                                    if (window.opener && !window.opener.closed) {
                                        // 부모 창을 수신함으로 이동(새로고침 효과)
                                        window.opener.location.href = '/approval/receiveAprvBoard';
                                    }
                                    // 그리고 팝업창 닫기!
                                    window.close();
                                });
                        })
                        .catch(error => {
                            console.error("결재 처리 에러:", error);
                            // (알람 리팩토링) AppAlert 에러창 적용
                            AppAlert.error('오류 발생', '처리 중 오류가 발생했습니다. 다시 시도해 주세요.'); // (알람 리팩토링)
                        });
                } // end if (result.isConfirmed)
            });
    }
</script>


</body>
</html>