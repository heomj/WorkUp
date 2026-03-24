<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <title>Materio 스타일 로그인</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <link rel="stylesheet" href="/css/login.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

    <!--  임시 파비콘 -->
    <link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/images/test.png">

    <style>
        /* --- 프리미엄 모달 커스텀 디자인 --- */
        .modal-content {
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .modal-header {
            background-color: #f8f7fa;
            border-bottom: 1px solid #ebebed;
            padding: 1.5rem;
        }

        .modal-title {
            color: #4c4e64;
            font-size: 1.25rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .modal-body {
            padding: 2rem 1.5rem;
        }

        .instruction-text {
            color: #6d6f89;
            margin-bottom: 1.5rem;
            line-height: 1.5;
        }

        .custom-input-group .form-control {
            border: 1px solid #dbdade;
            border-radius: 8px;
            padding: 0.6rem 1rem;
            transition: all 0.2s ease;
        }

        .custom-input-group .form-control:focus {
            border-color: rgb(105, 108, 255);
            box-shadow: 0 0 0 0.2rem rgba(140, 87, 255, 0.15);
            outline: none;
        }

        .modal-footer {
            border-top: none;
            padding: 0 1.5rem 1.5rem 1.5rem;
        }

        .btn-premium {
            background-color: rgb(105, 108, 255);
            border: none;
            color: white;
            font-weight: 600;
            padding: 0.5rem 1.5rem;
            border-radius: 8px;
            transition: all 0.3s ease;
            box-shadow: 0 2px 4px rgb(63, 66, 246);
        }

        .btn-premium:hover {
            background-color: rgb(14, 18, 247);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgb(63, 66, 246);
            color: white;
        }
    </style>
</head>
<body>
    <div class="d-flex flex-column align-items-center justify-content-center main-content-wrapper">
        <div class="tab-buttons-container">
            <button class="login-tab-button active" id="employeeLoginBtn">
                <i class="material-icons">person</i> 사원
            </button>
            <button class="login-tab-button" id="adminLoginBtn">
                <i class="material-icons">admin_panel_settings</i> 관리자
            </button>
        </div>

        <div class="login-container">
            <div class="card">
                <div class="card-header">
                    <img src="images/icon.png" alt="로고" style="max-width: 100%; display: block; margin: 0 auto;">
                    <!-- 개발자용 빠른로그인 버튼 -->

                    <!-- 개발자용 빠른로그인 버튼 -->
                </div>
                <div class="card-body">
                    <form id="loginForm" action="/loginProcess" method="post">
                        <input type="hidden" name="loginType" id="loginType" value="employee">
                        <div class="form-group">
                            <label for="employeeId" class="form-label" id="idLabel">사번</label>
                            <div class="input-group">
                                <input name="empId" type="text" class="form-control" id="employeeId" placeholder="사번을 입력하세요" autofocus >
                                <span class="input-group-text"><i class="material-icons">badge</i></span>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="d-flex justify-content-between">
                                <label class="form-label" for="password">비밀번호</label>
                                <a href="#" data-bs-toggle="modal" data-bs-target="#forgotPwModal">
                                    <small style="color: #385df1b0; font-weight: 500;">비밀번호를 잊으셨나요?</small>
                                </a>
                            </div>
                            <div class="input-group">
                                <input type="password" name="empPw" id="password" class="form-control" placeholder="············">
                                <span class="input-group-text"><i class="material-icons">lock</i></span>
                            </div>
                        </div>
                        <div class="form-check-group">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="remember-me">
                                <label class="form-check-label" for="remember-me">로그인 정보 기억하기</label>
                            </div>
                        </div>
                        <div class="d-grid login-button-container">
                            <button class="btn btn-primary" type="submit" id="loginBtn">로그인</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="forgotPwModal" tabindex="-1" aria-labelledby="forgotPwModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="forgotPwModalLabel">
                        <i class="material-icons" style="color: #8C57FF;">lock_reset</i>
                        비밀번호 찾기
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="inputSection">
                        <p class="instruction-text small">
                            사번과 등록된 전화번호를 입력해 주세요.<br>
                            정보가 일치하면 <strong>새로운 임시 비밀번호</strong>를 문자로 즉시 발송해 드립니다.
                        </p>
                        <div class="custom-input-group mb-3">
                            <label for="resetId" class="form-label fw-semibold small" style="color: #4c4e64;">사번</label>
                            <input type="text" class="form-control" id="resetId" placeholder="사번을 입력하세요">
                        </div>
                        <div class="custom-input-group">
                            <label for="resetTel" class="form-label fw-semibold small" style="color: #4c4e64;">전화번호</label>
                            <input type="tel" class="form-control" id="resetTel" placeholder="01012345678 (숫자만 입력)">
                        </div>
                    </div>
                    </div>
                <div class="modal-footer" id="modalFooter">
                    <button type="button" class="btn btn-premium btn-sm" id="sendResetMailBtn">임시 비밀번호 발급</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>

        const shortcut=(empId)=>{
            document.getElementById("employeeId").value=empId;
            document.getElementById("password").value="java";
            document.getElementById("loginBtn").click();
        }
        const shortcutadmin=()=>{
            document.getElementById("employeeId").value='12';
            document.getElementById("password").value="java";
            document.getElementById("loginType").value="admin";
            document.getElementById("loginBtn").click();
        }

        document.addEventListener('DOMContentLoaded', () => {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('error')) {
                Swal.fire({
                    title: '로그인 실패',
                    text: '아이디, 비밀번호 또는 접속 모드를 확인해주세요.',
                    icon: 'error',
                    confirmButtonColor: '#696cff'
                }).then(() => {
                    window.history.replaceState({}, document.title, window.location.pathname);
                });
            }

            const adminLoginBtn = document.getElementById('adminLoginBtn');
            const employeeLoginBtn = document.getElementById('employeeLoginBtn');
            const idInput = document.getElementById('employeeId');
            const idLabel = document.getElementById('idLabel');
            const loginBtn = document.getElementById('loginBtn');

            adminLoginBtn.addEventListener('click', () => setLoginMode('admin'));
            employeeLoginBtn.addEventListener('click', () => setLoginMode('employee'));

            function setLoginMode(mode) {

            document.getElementById('loginType').value = mode;

                if (mode === 'admin') {
                    idLabel.textContent = '관리자 아이디';
                    idInput.placeholder = '관리자 아이디를 입력하세요';
                    loginBtn.textContent = '관리자 로그인';
                    adminLoginBtn.classList.add('active');
                    employeeLoginBtn.classList.remove('active');
                } else {
                    idLabel.textContent = '사번';
                    idInput.placeholder = '사번을 입력하세요';
                    loginBtn.textContent = '로그인';
                    adminLoginBtn.classList.remove('active');
                    employeeLoginBtn.classList.add('active');
                }

        }



        //////////// 임시 비밀번호 즉시 발급 //////////////
        document.getElementById('sendResetMailBtn').addEventListener('click', () => {
            const userId = document.getElementById('resetId').value;
            const userTel = document.getElementById('resetTel').value;

            if(!userId || !userTel) {
                Swal.fire('알림', '사번과 전화번호를 모두 입력해주세요.', 'warning');
                return;
            }

            Swal.fire({
                title: '정보 확인 및 문자 발송 중...',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading(); }
            });

            const params = new URLSearchParams();
            params.append('empId', userId);
            params.append('phone', userTel);

            axios.post("/findpw", params)
            .then(res => {
                if (res.data === "success") {
                    Swal.fire({
                        title: '발송 완료!',
                        text: '임시 비밀번호가 문자로 전송되었습니다. 다시 로그인해주세요.',
                        icon: 'success',
                        confirmButtonColor: '#696cff'
                    }).then(() => {
                        // 모달을 닫거나 페이지를 새로고침
                        location.reload();
                    });
                } else if (res.data === "not_found") {
                    Swal.fire('정보 불일치', '사번 또는 전화번호가 일치하지 않습니다.', 'error');
                } else {
                    Swal.fire('발송 실패', '문자 서비스에 문제가 발생했습니다. 관리자에게 문의하세요.', 'error');
                }
            })
            .catch(err => {
                console.error(err);
                Swal.fire('오류', '서버 통신 중 오류가 발생했습니다.', 'error');
            });
        });
        });
    </script>
</body>
</html>