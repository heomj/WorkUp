package kr.or.ddit.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketTransportRegistration;
import org.springframework.web.socket.server.standard.ServletServerContainerFactoryBean;
import org.springframework.web.socket.server.support.HttpSessionHandshakeInterceptor;

import kr.or.ddit.config.ChatHandler;

@Configuration
@EnableWebSocket              // 1. 기존 채팅 핸들러 방식 활성화
@EnableWebSocketMessageBroker // 2. STOMP 메시지 브로커 활성화
public class WebSocketConfig implements WebSocketConfigurer, WebSocketMessageBrokerConfigurer {

    @Autowired
    private ChatHandler chatHandler;
    
    @Bean
    public ServletServerContainerFactoryBean createWebSocketContainer() {
        ServletServerContainerFactoryBean container = new ServletServerContainerFactoryBean();
        container.setMaxTextMessageBufferSize(50 * 1024 * 1024);   // 최대 텍스트 크기: 50MB
        container.setMaxBinaryMessageBufferSize(50 * 1024 * 1024); // 최대 바이너리 크기: 50MB
        return container;
    }
    
    // 🌟 [추가된 핵심 설정] 메시지 전송 용량 제한 해제
    // 이 설정이 없으면 이미지가 포함된 메시지를 연속으로 보낼 때 소켓이 터집니다.
    @Override
    public void configureWebSocketTransport(WebSocketTransportRegistration registration) {
        registration.setMessageSizeLimit(50 * 1024 * 1024);      // 메시지 최대 크기: 50MB
        registration.setSendBufferSizeLimit(50 * 1024 * 1024);   // 전송 버퍼 크기: 50MB
        registration.setSendTimeLimit(20 * 1000);                // 전송 시간 제한: 20초
    }

    // ---------------- [ 기존 채팅용: WebSocketConfigurer (핸들러) ] ----------------
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // 기존 채팅 주소: /chat
        registry.addHandler(chatHandler, "/chat")
                .setAllowedOriginPatterns("*")
                .addInterceptors(new HttpSessionHandshakeInterceptor()) // 세션 정보 연동
                .withSockJS(); 
    }

    // ----------- [ 알람 및 STOMP용: WebSocketMessageBrokerConfigurer (브로커) ] -----------
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 클라이언트 연결 엔드포인트: /alarm
        registry.addEndpoint("/alarm")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // 구독(수신) 경로 설정: /sub
        // 만약 기존 코드의 /topic, /queue도 쓰고 싶다면 같이 넣을 수 있습니다.
        config.enableSimpleBroker("/sub", "/topic", "/queue");

        // 발행(송신) 경로 설정: /pub
        config.setApplicationDestinationPrefixes("/pub", "/app");
    }
}