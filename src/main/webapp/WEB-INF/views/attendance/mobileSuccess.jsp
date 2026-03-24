<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>인증 완료 | 근태 관리 시스템</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            background-color: #f4f6f9; /* AdminLTE 배경색 🦾 */
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        .success-card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            padding: 40px 24px;
            max-width: 360px;
            width: 90%;
            text-align: center;
            border-top: 5px solid #28a745; /* Success 컬러 포인트 🦾 */
        }
        .icon-box {
            width: 80px;
            height: 80px;
            background-color: #eafaf1;
            color: #28a745;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            margin: 0 auto 20px;
        }
        h1 {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1f2d3d;
            margin-bottom: 10px;
        }
        .user-email {
            color: #007bff;
            font-weight: 600;
            background: #eef6ff;
            padding: 2px 8px;
            border-radius: 4px;
        }
        .message {
            color: #6c757d;
            font-size: 0.95rem;
            line-height: 1.6;
        }
        .btn-close-window {
            margin-top: 30px;
            width: 100%;
            padding: 12px;
            font-weight: 600;
            border-radius: 8px;
            background-color: #343a40;
            border: none;
            color: white;
            transition: 0.3s;
        }
        .footer-text {
            margin-top: 20px;
            font-size: 0.8rem;
            color: #adb5bd;
        }
    </style>
</head>
<body>

    <div class="success-card">
        <div class="icon-box">
            <i class="bi bi-check-lg">✓</i>
        </div>
        <h1>인증 완료</h1>
        <div class="message">
            <p><span class="user-email">${userEmail}</span>님,<br>
            정상적으로 출근 인증이 처리되었습니다.</p>
            <p class="mb-0">오늘 하루도 건승하시길 바랍니다.</p>
        </div>
        
        <button onclick="handleClose()" class="btn-close-window">확인</button>
        
        <p class="footer-text">이 창은 잠시 후 자동으로 닫힙니다.</p>
    </div>

    <script>
        function handleClose() {
            window.close();
            // 카카오톡 등에서 window.close()가 안 먹힐 때를 대비한 안내 🦾
            setTimeout(function() {
                alert("인증이 완료되었습니다. 브라우저의 닫기 버튼을 눌러주세요.");
            }, 300);
        }

        // 페이지 로드 3초 후 자동 닫기 시도 (UX 향상! 🦾🔥)
        window.onload = function() {
            setTimeout(function() {
                window.close();
            }, 3000);
        };
    </script>
</body>
</html>