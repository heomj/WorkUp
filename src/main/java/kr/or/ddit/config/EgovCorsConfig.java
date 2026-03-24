package kr.or.ddit.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

/**
 * EgovCorsConfig
 *
 * - Spring에서 CORS 정책을 글로벌하게 설정
 *
 * - 외부 도메인에서 API 요청이 들어와도 허용
 *
 * - 주로 프론트엔드가 다른
 *
 * 포트/도메인에서 요청할 때 필요
 */
@Configuration
public class EgovCorsConfig {

	/**
	 * CorsFilter Bean 등록
	 *
	 * @return CorsFilter 인스턴스
	 *
	 *         작동 방식: - 모든 요청 URL("/**")에 대해 CORS 정책 적용 - 외부에서 들어오는 요청 헤더, 메서드,
	 *         출처(origin)를 허용
	 */
	//아무 서버에서 호출해도 응답해 주겠다는 설정 (보안문제)
	@Bean
	protected CorsFilter corsFilter() {
		// 1. CORS 설정 객체 생성
		CorsConfiguration cfg = new CorsConfiguration();
		// 모든 출처 허용 (http://example.com, http://localhost:3000 등)
		cfg.addAllowedOriginPattern("*");
		// 모든 HTTP 헤더 허용
		cfg.addAllowedHeader("*");
		// 모든 HTTP 메서드 허용 (GET, POST, PUT, DELETE 등)
		cfg.addAllowedMethod("*");
		// 자격 증명(Cookie, 인증 헤더) 허용
		cfg.setAllowCredentials(true);

		// 2. URL 패턴과 CORS 설정 매핑
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		// 모든 URL 패턴("/**")에 대해 위 설정 적용
		source.registerCorsConfiguration("/**", cfg);

		// 3. CorsFilter 생성 후 반환
		// 이 필터가 Spring Security 이전에 작동하여 CORS 정책 적용
		return new CorsFilter(source);
	}
}
