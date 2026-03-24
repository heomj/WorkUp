<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>인증 알림 | 근태 관리 시스템</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; font-family: 'Inter', sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .success-card { background: #ffffff; border-radius: 16px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); padding: 40px 24px; text-align: center; width: 90%; max-width: 380px; }
        .icon-box { width: 70px; height: 70px; background-color: #fff3cd; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px; color: #856404; }
        .icon-box i { font-size: 32px; font-style: normal; font-weight: bold; }
        h1 { font-size: 1.5rem; font-weight: 700; color: #212529; margin-bottom: 12px; }
        .message { color: #495057; font-size: 1rem; line-height: 1.6; }
        .user-email { color: #007bff; font-weight: 600; }
        .btn-close-window { margin-top: 30px; width: 100%; padding: 12px; font-weight: 600; border-radius: 8px; background-color: #6c757d; border: none; color: white; transition: 0.3s; }
        .footer-text { margin-top: 20px; font-size: 0.8rem; color: #adb5bd; }
    </style>
</head>
<body>

    <div class="success-card">
        <div class="icon-box">
            <i>!</i>
        </div>
        <h1>인증 알림</h1>
        <div class="message">
            <p><span class="user-email">${userEmail}</span>님,<br>
            ${errorMsg}</p>
            <p class="mb-0">이미 완료된 요청이거나 잘못된 접근입니다.</p>
        </div>

        <button onclick="handleClose()" class="btn-close-window">확인</button>
        <p class="footer-text">이 창은 잠시 후 자동으로 닫힙니다.</p>
    </div>

    <script>
        function handleClose() {
            window.close();
        }
        // 3초 후 자동 닫기 🦾
        setTimeout(function() {
            window.close();
        }, 3000);
    </script>
</body>
</html>