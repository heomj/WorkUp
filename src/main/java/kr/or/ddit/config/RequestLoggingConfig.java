package kr.or.ddit.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.CommonsRequestLoggingFilter;

@Configuration
public class RequestLoggingConfig {

	@Bean
	public CommonsRequestLoggingFilter commonsRequestLoggingFilter() {

		CommonsRequestLoggingFilter filter = new CommonsRequestLoggingFilter();

		// ▶ Query String (?a=1&b=2) 로그 출력
		filter.setIncludeQueryString(true);

		// ▶ Request Body 출력 (JSON, form-data 등)
		filter.setIncludePayload(true);

		// ▶ HTTP Header 출력
		filter.setIncludeHeaders(true);

		// ▶ 최대 Payload 길이 (초과 시 잘림)
		filter.setMaxPayloadLength(10_000);

		// ▶ 로그 prefix / suffix
		filter.setBeforeMessagePrefix("[REQUEST START] ");
		filter.setAfterMessagePrefix("[REQUEST END] ");

		return filter;
	}
}
