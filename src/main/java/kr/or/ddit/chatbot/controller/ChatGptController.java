package kr.or.ddit.chatbot.controller;

import java.time.Duration;

import kr.or.ddit.chatbot.calendar.service.impl.CalendarAiServiceImpl;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.chatbot.service.ChatAIService;
import kr.or.ddit.chatbot.support.ApiSupportManager;
import kr.or.ddit.service.impl.CustomUser;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Flux;

/**
 * ChatGptController
 *
 * - Spring AI ChatClient를 사용하여 AI와 채팅 스트리밍 제공
 *
 * - StopManager를 통해 클라이언트에서 중단 요청
 *
 *
 * 처리 - SSE (Server-Sent Events)를 활용한 실시간 스트리밍
 */
@Slf4j
@RestController
@RequiredArgsConstructor
public class ChatGptController {

	private final ChatClient chatClient; // Spring AI ChatClient (AI 모델 호출용)

	private final ApiSupportManager apiSupportManager; // Stop 요청 관리용 컴포넌트

	@Autowired
	@Qualifier("workUpProjectService")
	ChatAIService workUpProjectService;

	@Autowired
	@Qualifier("calendarAiService")
	ChatAIService calendarAiService;


	@Autowired
	@Qualifier("workUpTransService")
	ChatAIService workUpTransService;

	@Autowired
	@Qualifier("workUpApprovalService")
	ChatAIService workUpApprovalService;







	/**
	 * 헬스 체크용 엔드포인트
	 *
	 * - 클라이언트 또는 모니터링 서버에서 호출 가능
	 *
	 * - 단순히 서버가 살아 있는지 확인용 예: GET /api/ping
	 */

	@GetMapping("/api/ping")
	public String ping() {
		return "pong";
	}

	/**
	 * SSE 기반 채팅 스트리밍 엔드포인트
	 *
	 * - 클라이언트가 메시지를 보내면 AI 응답을 실시간으로 스트리밍
	 *
	 * - StopManager와 연동하여 Stop 버튼 클릭 시 스트리밍 중단 가능
	 *
	 * 호출 예: /api/chat/stream?message=안녕&requestId=xxxx 반환: text/event-stream
	 *
	 * (EventSource 수신용)
	 *
	 * @param message   사용자가 입력한 메시지
	 * @param requestId 특정 요청 식별용 ID (Stop 기능에 사용)
	 * @return Flux<String> AI 응답 스트리밍
	 */


//	@GetMapping(value = "/api/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
//	public Flux<String> stream(
//
//			@RequestParam String message, @RequestParam String requestId
//
//	) {
//
//		log.debug("requestId : {}", requestId);
//
//		// Stop 플래그 초기화
//		// 이전에 Stop 요청이 남아있으면 제거하여 새로운 요청을 받을 준비
//		apiSupportManager.clear(requestId);
//
//		// Spring AI ChatClient를 사용하여 사용자 메시지 전송
//		// Flux<String>으로 AI의 응답을 스트리밍
//		Flux<String> origin = chatClient.prompt().user(
//
//				prompt.build(message)
//
//				).stream() // 스트리밍 모드 활성화
//				.content() // 응답 내용 추출
//				.delayElements(Duration.ofMillis(20))
//		// --- 이 부분을 추가하세요 ---
//				.map(content -> String.format(" %s \n\n", content)); // 각 메시지 덩어리 뒤에 엔터 두 번 추가
//		// --------------------------; // 부드러운 전송 위해 딜레이 추가
//
//		return origin
//				// Stop 버튼 클릭 시 스트리밍 중단
//				.takeUntil(chunk -> apiSupportManager.shouldStop(requestId))
//				// 브라우저 종료나 네트워크 단절 시 IOException 발생 가능
//				.onErrorResume(ex -> {
//					// IOException이나 기타 예외 발생 시 로그만 남기고 정상 종료
//					log.warn("Stream aborted: {}", ex.getMessage());
//					return Flux.empty(); // 스트림 종료
//				})
//
//				// 스트림 종료 시 항상 Stop 플래그 초기화
//				.doFinally(signalType -> apiSupportManager.clear(requestId));
//	}

	/**
	 * [챗봇] 공통으로 요청받는 controller
	 * @param message 사용자가 보낸 메시지
	 * @param requestId (중지)를 위한 임의 ID
	 * @param botType 챗봇 종류(말 다듬, 프로젝트, 근태, 일정, 전자결재, ...)
	 * @param auth 사용자 정보
	 * @return
	 */
	@GetMapping(value = "/api/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
	public Flux<String> stream(
			@RequestParam String message, @RequestParam String requestId, @RequestParam String botType, Authentication auth
	) {

		CustomUser customUser = (CustomUser)auth.getPrincipal();

		// Stop 플래그 초기화
		// 이전에 Stop 요청이 남아있으면 제거하여 새로운 요청을 받을 준비
		apiSupportManager.clear(requestId);

		Flux<String> origin = null;

		log.info("여기까지 왔나? botType : {}", botType);
		log.info("message 여기까지 왔나? message : {}", message);

		switch (botType) {
		case "trans":  // 번역 ===================================================================
			origin = chatClient.prompt()
					.system(workUpTransService.buildSystem(message, customUser))
					.user(workUpTransService.buildUser(message, customUser))  // AI에게 질문을 던짐
					.stream() // 스트리밍 모드 활성화 (답변을 한꺼번에 받지 않고 조각조각 받겠다 !)
					.content(); // 응답 내용 추출 (텍스트만 추출)
			break;
		case "project": // 프로젝트 ===============================================================
			origin = chatClient.prompt()
					.system(workUpProjectService.buildSystem(message, customUser))
					.user(workUpProjectService.buildUser(message, customUser))
					.stream()  // AI에게 질문을 던짐
					.content(); // 응답 내용 추출 (텍스트만 추출)
			break;

			case "calendar":
				// 프로젝트 관리
				// 스트리밍 모드 활성화 (답변을 한꺼번에 받지 않고 조각조각 받겠다 !)
				origin = chatClient.prompt()
						.system(calendarAiService.buildSystem(message, customUser))
						.user(calendarAiService.buildUser(message, customUser))
						.stream()  // AI에게 질문을 던짐
						.content(); // 응답 내용 추출 (텍스트만 추출)
				break;

			case "approval": // 전자결재 ===============================================================
				// 스트리밍 모드 활성화 (답변을 한꺼번에 받지 않고 조각조각 받겠다 !)
				origin = chatClient.prompt()
						.system(workUpApprovalService.buildSystem(message, customUser))
						.user(workUpApprovalService.buildUser(message, customUser))
						.stream()  // AI에게 질문을 던짐
						.content(); // 응답 내용 추출 (텍스트만 추출)
				break;

		default:
			// 프로젝트 관리
			// 스트리밍 모드 활성화 (답변을 한꺼번에 받지 않고 조각조각 받겠다 !)
			origin = chatClient.prompt()
					.system(workUpProjectService.buildSystem(message, customUser))
					.user(workUpProjectService.buildUser(message, customUser))
					.stream()  // AI에게 질문을 던짐
					.content(); // 응답 내용 추출 (텍스트만 추출)
			break;
		}

/*		// 여긴 공통으로 처리할 부분 (딜레이, 줄바꿈)============================================================
		origin = origin.delayElements(Duration.ofMillis(20))
				.map(content -> content.replace("\n", "<br>")) // 줄바꿈 처리
				.concatWith(Flux.just("[DONE]"));   // 종료시 [DONE] 메시지 추가
				//		.map(content -> String.format(" %s \n\n", content)) // 각 메시지 덩어리 뒤에 엔터 두 번 추가
		// 여긴 공통으로 처리할 부분 (딜레이, 줄바꿈)============================================================*/


        origin = origin
                .bufferTimeout(10, Duration.ofMillis(100))
                .map(list -> String.join("", list))
                .map(content -> content
                        .replace("\n", "<br>") // 줄바꿈 처리
                        .replace(" ", "&nbsp;") // 띄어쓰기를 HTML 공백 문자로 변환 ✨
                )
                .delayElements(Duration.ofMillis(30))
                .concatWith(Flux.just("[DONE]"));

		return origin
				// Stop 버튼 클릭 시 스트리밍 중단
				.takeUntil(chunk -> apiSupportManager.shouldStop(requestId))
				// 브라우저 종료나 네트워크 단절 시 IOException 발생 가능
				.onErrorResume(ex -> {
					// IOException이나 기타 예외 발생 시 로그만 남기고 정상 종료
					log.warn("Stream aborted: {}", ex.getMessage());
					return Flux.empty(); // 스트림 종료
				})

				// 스트림 종료 시 항상 Stop 플래그 초기화
				.doFinally(signalType -> apiSupportManager.clear(requestId));
	}

	/**
	 * 클라이언트 Stop 요청 엔드포인트
	 *
	 * - 사용자가 Stop 버튼 클릭 시 호출
	 *
	 * - StopManager에 Stop 요청 등록
	 *
	 * 호출 예: POST /api/chat/stop?requestId=xxxx
	 *
	 * @param requestId 중단할 요청 식별용 ID
	 * @return "stopping" 문자열 반환
	 */

	@PostMapping("/api/chat/stop")
	public String stop(@RequestParam String requestId) {
		// 해당 requestId에 대해 Stop 요청 등록
		apiSupportManager.requestStop(requestId);
		return "stopping";
	}
}
