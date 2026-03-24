package kr.or.ddit.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kr.or.ddit.util.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

// 로그인 성공 핸들러 ~!~!!!!!!
@Slf4j
@Component
public class CustomLoginSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler {

    @Autowired
    JwtUtil jwtUtil;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {

        log.info("인증되셨어욥 ㅎ {}", authentication);
        if(authentication.getAuthorities().stream().anyMatch(
                auth -> auth.getAuthority().equals("ROLE_관리자"))) {
            log.info("헐 관리자임");
            String name = authentication.getName();
            log.info("관리자 이름임 헐 {}", name);

            String token = jwtUtil.generateToken(name);

            log.info("관리자 토큰 token : {}", token);

            ResponseCookie cookie = ResponseCookie.from("admintoken", token)
                    .path("/")
                    .httpOnly(false)  // 이건 크롬에서는 상관없구 엣지는 안 먹히드라 ..
                    .maxAge(3600)
                    .sameSite("Lax")
                    .build();

            response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());


            response.setStatus(HttpServletResponse.SC_OK);
            response.setContentType("application/json;charset=UTF-8");

            response.getWriter().write("{\"token\":\"" + token);
            response.sendRedirect("http://localhost:5173/");
            return ;
        }

        // 로그인 성공하면 가던 길로 가자(?)
        response.sendRedirect("/main");
        // super.onAuthenticationSuccess(request, response, authentication);
    }

}
