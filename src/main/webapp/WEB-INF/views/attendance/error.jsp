<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>인증 실패 | 근태 관리 시스템</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .success-card { background: #ffffff; border-radius: 16px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); padding: 40px 24px; text-align: center; width: 90%; max-width: 380px; }
        .icon-box { width: 70px; height: 70px; background-color: #f8d7da; color: #dc3545; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px; }
        .icon-box i { font-size: 32px; font-style: normal; font-weight: bold; }
        h1 { font-size: 1.5rem; font-weight: 700; color: #212529; margin-bottom: 12px; }
        .message { color: #495057; font-size: 1rem; line-height: 1.6; }
        .btn-close-window { margin-top: 30px; width: 100%; padding: 12px; font-weight: 600; border-radius: 8px; background-color: #dc3545; border: none; color: white; transition: 0.3s; }
        .btn-close-window:hover { background-color: #c82333; }
        .footer-text { margin-top: 20px; font-size: 0.8rem; color: #adb5bd; }
    </style>
</head>
<body>

    <div class="success-card">
        <div class="icon-box">
            <i>!</i>
        </div>
        <h1>인증 실패</h1>
        <div class="message">
            <p>사용자 인증 과정에서 문제가 발생했습니다.</p>
            <p class="mb-0 text-muted" style="font-size: 0.9rem;">QR 코드를 다시 스캔하거나<br>잠시 후 다시 시도해 주세요.</p>
        </div>

        <button onclick="handleClose()" class="btn-close-window">창 닫기</button>

        <p class="footer-text">지속적으로 발생 시 관리자에게 문의하세요.</p>
    </div>

    <script>
        function handleClose() {
            window.close();
        }
        // 실패 화면은 사용자가 읽어야 하므로 자동 닫기는 5초로 넉넉하게! 🦾
        setTimeout(function() {
            window.close();
        }, 5000);
    </script>
</body>
</html>