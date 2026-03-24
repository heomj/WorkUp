package kr.or.ddit.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry; // 수정됨
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    // @Value 부분을 주석 처리하고 직접 경로 입력
    private String prfFolder = "C:/team1/upload/profile/";

    private String uploadFolder = "C:/team1/upload/";

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/profile/**")
                .addResourceLocations("file:///" + prfFolder);

        registry.addResourceHandler("/upload/**")
                .addResourceLocations("file:///" + uploadFolder);
                
        registry.addResourceHandler("/resources/**")
                .addResourceLocations("/resources/");
    }
}