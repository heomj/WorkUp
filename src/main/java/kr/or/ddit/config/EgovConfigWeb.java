package kr.or.ddit.config;

import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.i18n.SessionLocaleResolver;

/**
 * Spring MVC 웹 설정 클래스
 *
 * - Thymeleaf 템플릿 엔진 설정
 *
 * - 정적 리소스(css, js, images) 매핑
 *
 * - 다국어 지원 설정 - 예외 처리 커스터마이징 (주석)
 */
@Configuration
public class EgovConfigWeb implements WebMvcConfigurer, ApplicationContextAware {

	// Spring ApplicationContext를 주입받기 위한 필드
	// 템플릿 리졸버 등에서 필요
	private ApplicationContext applicationContext;

	/**
	 * ApplicationContext 주입
	 *
	 * - Spring 컨테이너를 통해 Bean을 조회하거나 리소스 접근 가능
	 */
	@Override
	public void setApplicationContext(

			final ApplicationContext applicationContext

	) {
		this.applicationContext = applicationContext;
	}

	/**
	 * 정적 리소스 핸들러 설정
	 *
	 * - 브라우저 요청 URL과 실제 리소스 경로 매핑 - /css/** 요청 → classpath:/static/css/ 폴더의 파일 반환
	 *
	 * - /js/** 요청 → classpath:/static/js/ 폴더의 파일 반환
	 *
	 * - /images/** 요청 → classpath:/static/images/ 폴더의 파일 반환
	 */
	@Override
	public void addResourceHandlers(ResourceHandlerRegistry registry) {

		registry.addResourceHandler("/css/**").addResourceLocations("classpath:/static/css/");
		registry.addResourceHandler("/images/**").addResourceLocations("classpath:/static/images/");
		registry.addResourceHandler("/js/**").addResourceLocations("classpath:/static/js/");

	}

	/**
	 * 다국어 지원: SessionLocaleResolver
	 *
	 * - 세션에 Locale 정보를 저장
	 *
	 * - 페이지 이동/새로고침 시에도 동일한 Locale 유지
	 */
	@Bean
	protected SessionLocaleResolver localeResolver() {
		return new SessionLocaleResolver();
	}

	/**
	 * LocaleChangeInterceptor 설정
	 *
	 * - 요청 파라미터(language)로 Locale 변경 가능
	 *
	 * - 예: /page?language=ko → 한국어로 변경
	 */
	@Bean
	protected LocaleChangeInterceptor localeChangeInterceptor() {

		LocaleChangeInterceptor interceptor = new LocaleChangeInterceptor();
		interceptor.setParamName("language"); // 파라미터 이름 지정

		return interceptor;
	}

	/**
	 * 인터셉터 등록
	 *
	 * - LocaleChangeInterceptor 등록
	 *
	 * - 스프링 MVC 요청 처리 시 인터셉터를 통해 Locale 변경 가능
	 */
	@Override
	public void addInterceptors(InterceptorRegistry registry) {

		registry.addInterceptor(localeChangeInterceptor());

	}

	/*
	 * // 예외 처리 커스터마이징 (주석 처리됨) // 특정 예외 발생 시 egovSampleError 뷰로 이동 // -
	 * DataAccessException, TransactionException 등 처리 // -
	 * SimpleMappingExceptionResolver를 사용하여 예외별 뷰 및 상태코드 지정
	 *
	 * @Override public void
	 * configureHandlerExceptionResolvers(List<HandlerExceptionResolver> resolvers)
	 * { Properties prop = new Properties();
	 * prop.setProperty("org.springframework.dao.DataAccessException",
	 * "egovSampleError");
	 * prop.setProperty("org.springframework.transaction.TransactionException",
	 * "egovSampleError");
	 * prop.setProperty("org.egovframe.rte.fdl.cmmn.exception.EgovBizException",
	 * "egovSampleError");
	 * prop.setProperty("org.springframework.security.AccessDeniedException",
	 * "egovSampleError"); prop.setProperty("java.lang.Throwable",
	 * "egovSampleError");
	 *
	 * Properties statusCode = new Properties();
	 * statusCode.setProperty("egovSampleError", "400");
	 * statusCode.setProperty("egovSampleError", "500");
	 *
	 * SimpleMappingExceptionResolver smer = new SimpleMappingExceptionResolver();
	 * smer.setDefaultErrorView("egovSampleError"); // 기본 오류 페이지
	 * smer.setExceptionMappings(prop); // 예외-뷰 매핑 smer.setStatusCodes(statusCode);
	 * // HTTP 상태 코드 매핑 resolvers.add(smer); }
	 */
}
