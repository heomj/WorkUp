package kr.or.ddit;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration; // 이 줄이 있는지 확인!

@SpringBootApplication(exclude = { SecurityAutoConfiguration.class })
@ComponentScan(basePackages = "kr.or.ddit")
public class Application {
	/**
	 * 여기가 수정 포인트 충돌 예정
	 * @param args
	 */


    public static void main(String[] args) { 
        SpringApplication.run(Application.class, args);

    }
}