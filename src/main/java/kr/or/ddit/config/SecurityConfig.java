package kr.or.ddit.config;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.Cookie;
import kr.or.ddit.security.CustomLoginSuccessHandler;
import kr.or.ddit.security.CustomLogoutSuccessHandler;
import kr.or.ddit.service.impl.RoleServiceImpl;
import kr.or.ddit.util.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;

import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;

import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;


import javax.sql.DataSource;
import java.util.Collections;
import java.util.List;

@Configuration  // 환경설정을 위한 자바빈 객체로 등록
@EnableWebSecurity(debug = false) // 웹에서 사용
@EnableMethodSecurity    //@preAuthorize/@postAuthorize 사용
public class SecurityConfig {

    @Autowired
    private DataSource datasource;

    // 시큐리티의 사용자 정보를 담은 DI
    @Autowired
    RoleServiceImpl roleServiceImpl;

    @Autowired
    CustomLoginSuccessHandler customLoginSuccessHandler;

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }


    // 정적 리소스 허용! 이라네요
    @Bean
    public WebSecurityCustomizer configure() {
        return (web) -> web.ignoring()
                .requestMatchers("/css/**", "/js/**", "/favicon.ico", "/images/**", "/adminlte/**", "/js/**");
    }

    // CORS 설정
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();

        config.setAllowedOrigins(List.of("http://localhost:5173"));

        config.setAllowCredentials(true);  // 데이터 보내주기 !

        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS","PATCH"));
        config.setAllowedHeaders(List.of("*"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    protected SecurityFilterChain filterChain (HttpSecurity http) throws Exception {
        // 내가 설계한 (Custom 로그인)으로 보안은 관리하겠다는 선언!

        return
                http.csrf(csrf -> csrf.disable()).httpBasic(hbasic -> hbasic.disable())
                        .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                        .headers(config -> config.frameOptions(customizer -> customizer.sameOrigin()))
                        .authorizeHttpRequests(
                                // forard이나 특수한 비동기 작업은 로그인 여부 따지기 X
                                authz -> authz.dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ASYNC).permitAll()
                                        .requestMatchers("/login", "/home","/","/findpw","/email/receiveext").permitAll()
                                        // 1. [카카오 인증용] 주소 뒤에 ?code= 가 붙어있을 때만 문 열어주기
                                        .requestMatchers(request ->
                                                request.getRequestURI().endsWith("/attendance") && request.getParameter("code") != null
                                        ).permitAll()

                                        // 권한이 '관리자'만 들어올 수 있는 곳
                                        .requestMatchers("/admin/**").hasRole("관리자")
                                        // 나머지 모든 요청은 최소한 로그인(인증)은 해야 함
                                        .anyRequest().authenticated())
                        .formLogin(formLogin -> formLogin
                                .loginPage("/login")  // 내가 Controller에서 작성한 GetMapping 주소 !
                                .loginProcessingUrl("/loginProcess")   // form에서 로그인 요청시 오는 ! (Post)
                                .usernameParameter("empId")
                                .passwordParameter("empPw")
                                .successHandler(customLoginSuccessHandler)
                                .failureHandler((request, response, exception) -> { System.out.println("🚨 로그인 실패 원인: " + exception.getMessage()); response.sendRedirect("/login?error"); })
                        )
                        // 동시 접속 가능한 최대 세션 개수 => 1개라고 설정
                        .sessionManagement(session -> session.maximumSessions(1))
                        // 로그아웃 처리
                        .logout(logout -> logout
                                .logoutUrl("/logout")
                                .addLogoutHandler((request, response, authentication) -> {
                                    // 관리자용 쿠키 삭제
                                    Cookie cookie = new Cookie("admintoken", null);
                                    cookie.setPath("/");
                                    cookie.setMaxAge(0);
                                    response.addCookie(cookie);
                                })
                                // 사원쪽 핸들러
                                .logoutSuccessHandler(customLogoutSuccessHandler())
                                .invalidateHttpSession(true)
                                .deleteCookies("JSESSIONID", "remember-me")
                        )
                        .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                        .build();
    }


    @Bean
    public AuthenticationManager authenticationManager(HttpSecurity http,
                                                       BCryptPasswordEncoder bCryptPasswordEncoder) throws Exception {
        AuthenticationManagerBuilder authenticationManagerBuilder =
                http.getSharedObject(AuthenticationManagerBuilder.class);

        // 여기서 서비스와 인코더를 한 번에 설정할 수 있습니다.
        authenticationManagerBuilder
                .userDetailsService(roleServiceImpl)
                .passwordEncoder(bCryptPasswordEncoder);

        return authenticationManagerBuilder.build();
    }


    @Bean
    public BCryptPasswordEncoder bCryptPasswordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // 암호화
//    @Bean
//    public BCryptPasswordEncoder bCryptPasswordEncoder() {
//        return new BCryptPasswordEncoder();
//    }


//    // 로그인 성공 핸들러
//    @Bean
//    public AuthenticationSuccessHandler customLoginSuccessHandler () {
//        return customLoginSuccessHandler();
//    }

    // 로그아웃 성공 핸들러
    @Bean
    public LogoutSuccessHandler customLogoutSuccessHandler() {
        return new CustomLogoutSuccessHandler();
    }

    // 예외처리 핸들러

    // SecurityConfig 클래스 내부 어딘가에 추가
    @Bean
    public FilterRegistrationBean<JwtAuthenticationFilter> jwtAuthenticationFilterRegistration(JwtAuthenticationFilter filter) {
        FilterRegistrationBean<JwtAuthenticationFilter> registration = new FilterRegistrationBean<>(filter);
        // 이 설정이 핵심입니다: 필터가 서블릿 컨테이너에 의해 자동으로 호출되는 것을 막습니다.
        registration.setEnabled(false);
        return registration;
    }
}
