<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<style>
    .mypage-content-area { width: 100%; padding: 1.5rem; }
    .mp-card { background: #fff; border-radius: 0.5rem; box-shadow: 0 2px 6px 0 rgba(67, 89, 113, 0.12); margin-bottom: 1.5rem; }
    .detail-info-card { min-height: 650px; display: flex; flex-direction: column; }
    .detail-info-card .card-body-content { flex-grow: 1; }
    .mp-profile-header { padding: 2.5rem 1.5rem; text-align: center; display: flex; flex-direction: column; align-items: center; }

    /* 프로필 이미지 크기 수정: 120px -> 160px */
    .mp-avatar-wrapper { position: relative; width: 160px; height: 160px; margin-bottom: 1.5rem; }
    .mp-avatar { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; border: 5px solid #fff; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }

    /* 편집 아이콘 크기 및 위치 조정 */
    .mp-edit-icon { position: absolute; bottom: 5px; right: 5px; background: #696cff; color: #fff; width: 38px; height: 38px; border-radius: 50%; border: 3px solid #fff; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: transform 0.2s; }
    .mp-edit-icon:hover { transform: scale(1.1); }

    .mp-emp-name { font-weight: 700; margin-bottom: 0.75rem !important; color: #566a7f; font-size: 1.4rem; }
    .bg-label-primary { background-color: #e7e7ff !important; color: #696cff !important; padding: 0.5rem 0.8rem; border-radius: 0.25rem; display: inline-block; font-weight: 600; margin-bottom: 1.5rem !important; }
    .mp-info-footer { width: 100%; border-top: 1px solid #f0f2f4; padding-top: 1.2rem; margin-top: auto; display: flex; justify-content: space-between; }
    .mp-sign-header { padding: 1rem; border-bottom: 1px solid #f0f2f4; display: flex; justify-content: space-between; align-items: center; }
    .mp-sign-box { background: #fcfcfd; border: 1px dashed #d9dee3; border-radius: 0.4rem; padding: 15px; text-align: center; min-height: 120px; display: flex; align-items: center; justify-content: center; }
    .mp-sign-img { max-height: 80px; width: auto; }
    .mp-label { font-size: 0.8rem; text-transform: uppercase; color: #a1acb8; font-weight: 600; margin-bottom: 0.4rem; display: block; }
    .mp-value { font-weight: 600; color: #566a7f; }
    .label-with-btn { display: flex; align-items: center; gap: 8px; margin-bottom: 0.4rem; }
    .label-with-btn .mp-label { margin-bottom: 0; }
    .mp-nav-tabs { border-bottom: 1px solid #d9dee3; margin-bottom: 1.5rem; display: flex; gap: 1rem; list-style: none; padding: 0; }
    .mp-nav-link { padding: 0.7rem 1.2rem; color: #697a8d; text-decoration: none; border-bottom: 2px solid transparent; transition: all 0.3s; font-weight: 500; }
    .mp-nav-link.active { color: #696cff; border-bottom-color: #696cff; }
</style>

<div class="mypage-content-area">
    <ul class="mp-nav-tabs">
        <li><a href="/mypage" class="mp-nav-link ${contentPage == 'mypage/myinfo' ? 'active' : ''}">마이페이지</a></li>
        <li><a href="/payslip" class="mp-nav-link ${contentPage == 'mypage/payslip' ? 'active' : ''}">급여명세서</a></li>
    </ul>

    <form id="profileForm" enctype="multipart/form-data">
        <div class="row">
            <div class="col-md-4">
                <div class="mp-card">
                    <div class="mp-profile-header">
                        <div class="mp-avatar-wrapper">
                            <sec:authentication property="principal.empVO.empProfile" var="userProfile" />
                                <c:choose>
                                    <c:when test="${not empty userProfile and userProfile != ''}">
                                        <img src="/displayPrf?fileName=${userProfile}" id="empProfile" class="mp-avatar" alt="Profile">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="/images/defaultProf.png" id="empProfile" class="mp-avatar" alt="Default Profile">
                                    </c:otherwise>
                                </c:choose>
                            <label for="profileFile" class="mp-edit-icon">
                                <i class="material-icons" style="font-size: 20px;">camera_alt</i>
                                <input type="file" id="profileFile" name="prof" hidden accept="image/*" onchange="previewImage(this, 'empProfile')">
                            </label>
                        </div>
                        <h4 class="mp-emp-name"><sec:authentication property="principal.empVO.empNm" /></h4>
                        <span class="badge bg-label-primary">
                            <sec:authentication property="principal.empVO.empJbgd" /> / <sec:authentication property="principal.empVO.deptNm" />
                        </span>
                        <div class="mp-info-footer">
                            <div class="text-start">
                                <span class="mp-label">마일리지</span>
                                <span class="mp-value text-primary"><sec:authentication property="principal.empVO.empMlg" />P</span>
                            </div>
                            <div class="text-end">
                                <span class="mp-label">입사일</span>
                                <span class="mp-value">
                                    <sec:authentication property="principal.empVO.empRegistDt" var="dt" scope="page" />
                                    <fmt:formatDate value="${dt}" pattern="yyyy/MM/dd" />
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mp-card">
                    <div class="mp-sign-header">
                        <span class="mp-label m-0" style="color: #566a7f;">전자결재 사인</span>
                        <div class="d-flex gap-1">
                            <button type="button" class="btn btn-xs btn-outline-primary py-0 px-2" style="font-size: 11px;" data-bs-toggle="modal" data-bs-target="#signModal">사인 만들기</button>
                            <label for="signFile" class="btn btn-xs btn-outline-secondary py-0 px-2 mb-0" style="font-size: 11px; cursor: pointer;">파일 변경</label>
                            <input type="file" id="signFile" name="sign" hidden accept="image/*" onchange="previewImage(this, 'previewSign')">
                        </div>
                    </div>
                    <div class="p-3">
                        <div class="mp-sign-box" id="signBox">
                            <sec:authentication property="principal.empVO.empSign" var="userSign" />
                            <c:choose>
                                <c:when test="${not empty userSign and userSign != ''}">
                                    <img src="/emp/displaySign?fileName=${userSign}" id="previewSign" class="mp-sign-img" alt="Sign">
                                </c:when>
                                <c:otherwise>
                                    <p id="noSignMsg">등록된 결재사인이 없습니다.</p>
                                    <img src="" id="previewSign" class="mp-sign-img" style="display:none;" alt="Sign">
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-8">
                <div class="mp-card p-4 detail-info-card">
                    <div class="card-body-content">
                        <h5 class="mb-4 fw-bold">상세 정보 관리</h5>
                        <div class="row g-3">
                            <div class="col-sm-6">
                                <label class="mp-label">사번</label>
                                <input type="text" class="form-control bg-light" value="<sec:authentication property='principal.empVO.empId' />" readonly>
                            </div>
                            <div class="col-sm-6">
                                <div class="label-with-btn">
                                    <label class="mp-label">비밀번호</label>
                                    <button type="button" id="check" class="btn btn-xs btn-primary py-0 px-2" style="font-size: 10px;" data-bs-toggle="modal" data-bs-target="#pwCheckModal">본인 인증</button>
                                </div>
                                <input type="password" id="newPw" name="empPw" class="form-control" placeholder="인증 후 입력 가능" disabled>
                            </div>
                            <div class="col-sm-6">
                                <label class="mp-label">연락처</label>
                                <input type="text" name="empPhone" class="form-control" value="<sec:authentication property='principal.empVO.empPhone' />" />
                            </div>
                            <div class="col-sm-6">
                                <label class="mp-label">생년월일</label>
                                <input type="text" name="empBir" class="form-control" value="<sec:authentication property='principal.empVO.empBir' />" disabled />
                            </div>
                            <div class="col-12">
                                <label class="mp-label">개인 이메일</label>
                                <input type="email" name="empEml" class="form-control" value="<sec:authentication property='principal.empVO.empEml' />">
                            </div>
                            <div class="col-sm-4">
                                <label class="mp-label">우편번호</label>
                                <div class="input-group input-group-sm">
                                    <input type="text" id="postcode" name="empZip" class="form-control" value="<sec:authentication property='principal.empVO.empZip' />" readonly>
                                    <button class="btn btn-outline-primary" type="button" onclick="execDaumPostcode()">검색</button>
                                </div>
                            </div>
                            <div class="col-sm-8">
                                <label class="mp-label">기본 주소</label>
                                <input type="text" id="address" name="empAdd1" class="form-control" value="<sec:authentication property='principal.empVO.empAdd1' />" readonly>
                            </div>
                            <div class="col-12">
                                
                                <label class="mp-label">상세 주소</label>
                                <input type="text" id="detailAddress" name="empAdd2" class="form-control" value="<sec:authentication property='principal.empVO.empAdd2' />">
                            </div>
                        </div>
                    </div>
                    <div class="mt-auto pt-4 text-end">
                        <button type="button" class="btn btn-primary px-4 fw-bold" onclick="updateProfile()">변경 사항 저장</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<!-- (나머지 모달 및 스크립트 부분은 기존과 동일) -->
<div class="modal fade" id="pwCheckModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-bottom-0">
                <h6 class="modal-title fw-bold">비밀번호 재확인</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body pt-0">
                <p class="text-muted small">정보 수정을 위해 기존 비밀번호를 입력해주세요.</p>
                <input type="password" id="modalPwInput" class="form-control" placeholder="기존 비밀번호 입력">
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary btn-sm" onclick="verifyPassword()">확인</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="signModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-bottom-0">
                <h6 class="modal-title fw-bold">결재사인 만들기</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body pt-0">
                <p class="text-muted small">아래 사각형 안에 사인을 그려주세요.</p>
                <canvas id="sig-canvas" width="265" height="150" style="border: 1px solid #ddd; border-radius: 4px; background: #fff; cursor: crosshair;"></canvas>
                <div class="mt-3 d-flex gap-2">
                    <button type="button" class="btn btn-outline-secondary btn-sm flex-fill" onclick="clearCanvas()">지우기</button>
                    <button type="button" class="btn btn-primary btn-sm flex-fill" onclick="saveSignature()">사인 등록</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
    const empname = '<sec:authentication property="principal.empVO.empNm" htmlEscape="false"/>';
    let canvas, ctx, drawing = false;

    document.addEventListener("DOMContentLoaded", function() {
        const signModal = document.getElementById('signModal');
        if(signModal) {
            signModal.addEventListener('shown.bs.modal', function () {
                initCanvas();
            });
        }
    });

    // 사진 그리는 곳
    function initCanvas() {
        canvas = document.getElementById("sig-canvas");
        if(!canvas) return;
        ctx = canvas.getContext("2d");
        ctx.strokeStyle = "#000";
        ctx.lineWidth = 3;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";

        canvas.onmousedown = (e) => {
            drawing = true;
            ctx.beginPath();
            ctx.moveTo(e.offsetX, e.offsetY);
        };
        canvas.onmousemove = (e) => {
            if (drawing) {
                ctx.lineTo(e.offsetX, e.offsetY);
                ctx.stroke();
            }
        };
        window.onmouseup = () => { drawing = false; };
    }

    function clearCanvas() {
        if(ctx) ctx.clearRect(0, 0, canvas.width, canvas.height);
    }

    // 사인 저장
    function saveSignature() {
        if(!canvas) return;
        const dataUrl = canvas.toDataURL("image/png");
        const now = new Date();
        const timestamp = now.getFullYear() + ("0" + (now.getMonth() + 1)).slice(-2) + ("0" + now.getDate()).slice(-2) + "_" + ("0" + now.getHours()).slice(-2) + ("0" + now.getMinutes()).slice(-2);
        const fileName = empname + "_signature_" + timestamp + ".png";

        const preview = document.getElementById("previewSign");
        preview.src = dataUrl;
        preview.style.display = 'block';
        const noSign = document.getElementById("noSignMsg");
        if(noSign) noSign.style.display = 'none';

        fetch(dataUrl).then(res => res.blob()).then(blob => {
            const file = new File([blob], fileName, { type: "image/png" });
            const dataTransfer = new DataTransfer();
            dataTransfer.items.add(file);
            document.getElementById('signFile').files = dataTransfer.files;
        });

        Swal.fire({
            title: '사인이 적용되었습니다.',
            text: "사인을 PC에도 저장하시겠습니까?",
            icon: 'success',
            showCancelButton: true,
            confirmButtonColor: '#696cff',
            cancelButtonColor: '#8592a3',
            confirmButtonText: '네, 저장합니다',
            cancelButtonText: '아니오'
        }).then((result) => {
            if (result.isConfirmed) {
                const link = document.createElement('a');
                link.download = empname + '_signature.png';
                link.href = dataUrl;
                link.click();
            }
        });

        const modalEl = document.getElementById('signModal');
        bootstrap.Modal.getInstance(modalEl).hide();
    }

    // ㅣㅇ미지 미리보기
    function previewImage(input, previewId) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const preview = document.getElementById(previewId);
                if (preview) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                    if(previewId === 'previewSign') {
                        const noSign = document.getElementById("noSignMsg");
                        if(noSign) noSign.style.display = 'none';
                    }
                }
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    // 비밀번호 바꾸기
    function verifyPassword() {
        const empPw = document.getElementById('modalPwInput').value;

        if(!empPw) {
            alert("비밀번호를 입력해주세요."); return;
        }

        // 비밀번호 맞는지 체크
        axios.get("/emp/chkpw", { params: { empPw: empPw } })
        .then(res => {
            if (res.data) {
                Swal.fire({ icon: 'success', title: '인증 완료', text: '새 비밀번호를 입력할 수 있습니다.', confirmButtonColor: '#666CFF' });
                const modalEl = document.getElementById('pwCheckModal');
                bootstrap.Modal.getInstance(modalEl).hide();
                const newPwInput = document.getElementById('newPw');
                newPwInput.disabled = false;
                newPwInput.value = "";
                newPwInput.placeholder = "새 비밀번호를 입력하세요";
                newPwInput.focus();
                const authBtn = document.getElementById('check');
                authBtn.disabled = true;
                authBtn.innerText = "인증 완료";
                authBtn.classList.replace('btn-primary', 'btn-secondary');
            } else {
                Swal.fire({ icon: 'error', title: '인증 실패', text: '비밀번호가 일치하지 않습니다.', confirmButtonColor: '#d33' });
            }
        });
    }

    // 다음 API
    function execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                let addr = data.userSelectedType === 'R' ? data.roadAddress : data.jibunAddress;
                document.getElementById('postcode').value = data.zonecode;
                document.getElementById("address").value = addr;
                document.getElementById("detailAddress").focus();
            }
        }).open();
    }

     // 프로필 업데이트
    function updateProfile() {
        const form = document.querySelector("#profileForm");
        const empPhone = form.querySelector("input[name='empPhone']").value.trim();
        const empEml = form.querySelector("input[name='empEml']").value.trim();
        const empZip = form.querySelector("input[name='empZip']").value.trim();
        const empAdd1 = form.querySelector("input[name='empAdd1']").value.trim();
        const empAdd2 = form.querySelector("input[name='empAdd2']").value.trim();
        const newPwInput = document.getElementById('newPw');

        // 유효성 검사
        if (!empPhone) { return showValidationError("연락처를 입력해주세요."); }
        if (!empEml) { return showValidationError("이메일을 입력해주세요."); }
        if (!empZip || !empAdd1) { return showValidationError("주소를 검색하여 입력해주세요."); }
        if (!empAdd2) { return showValidationError("상세 주소를 입력해주세요."); }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(empEml)) { return showValidationError("올바른 이메일 형식이 아닙니다."); }

        const formData = new FormData(form);
        if (newPwInput.disabled) {
            formData.delete("empPw");
        } else {
            const newPwValue = newPwInput.value.trim();
            if (!newPwValue) { return showValidationError("새 비밀번호를 입력하거나 수정을 취소해주세요."); }
            if (newPwValue.length < 4) { return showValidationError("비밀번호는 4자 이상이어야 합니다."); }
        }

        axios.put("/emp/updateprof", formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        })
        .then(res => {
            if (res.data === "success") {
                Swal.fire({
                    icon: 'success', title: '저장 완료', text: '변경 사항이 저장되었습니다.', confirmButtonColor: '#3085d6'
                }).then(() => { window.location.reload(); });
            } else {
                Swal.fire({ icon: 'error', title: '저장 실패', text: '변경 사항 저장에 실패했습니다.', confirmButtonColor: '#d33' });
            }
        });
    }

    // 유효성 검사 시 Swal 따로 관리하는 ?
    function showValidationError(message) {
        Swal.fire({ icon: 'warning', title: '입력 오류', text: message, confirmButtonColor: '#696cff' });
        return false;
    }
</script>