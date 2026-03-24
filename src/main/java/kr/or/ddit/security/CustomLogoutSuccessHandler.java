package kr.or.ddit.security;

import jakarta.annotation.Nullable;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;

import java.io.IOException;

// 사용자 정의 로그아웃 성공 핸들러
public class CustomLogoutSuccessHandler implements LogoutSuccessHandler {

    @Override
    public void onLogoutSuccess(HttpServletRequest request, HttpServletResponse response,
                                @Nullable Authentication authentication) throws IOException, ServletException {

        if(authentication != null && authentication.getDetails() != null) {
            try {
                // 세션 만료 처리 (=로그아웃)
                // 서버 메모리에 남아있는 사용자의 세션 정보를 모두 지움 => 비로그인 상태
                request.getSession().invalidate();
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        // 서버가 요청을 정상적으로 처리했다   << 는 신호
        response.setStatus(HttpServletResponse.SC_OK);

    }
}
