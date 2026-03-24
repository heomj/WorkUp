package kr.or.ddit.util;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String token = null;
        Cookie[] cookies = request.getCookies();

        // 1. 쿠키에서 토큰 찾기
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("admintoken".equals(cookie.getName())) {
                    token = cookie.getValue();
                    break;
                }
            }
        }

        // 2. 토큰이 있다면 검증 시작
        if (token != null) {
            try {
                // jwtUtil에서 유효성 검사
                String userId = jwtUtil.getUserIdFromToken(token);

                if (userId != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                            userId, null, List.of(new SimpleGrantedAuthority("ROLE_관리자")));

                    SecurityContextHolder.getContext().setAuthentication(auth);

                    log.info("관리자 토큰 확인됨: 인증 통과");
                }
            } catch (Exception e) {
                log.error("유효하지 않은 관리자 토큰입니다.");
            }
        }

        String path = request.getRequestURI();

        // 로그아웃 경로나 인증 체크 경로는 JWT 검사를 하지 않고 바로 다음 필터로 넘김
        if (path.equals("/logout") || path.equals("/admin/check-auth") || path.equals("/login")) {
            filterChain.doFilter(request, response);
            return;
        }

        filterChain.doFilter(request, response);
    }
}