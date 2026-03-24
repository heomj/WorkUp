package kr.or.ddit.chatbot.calendar.service.impl;

import kr.or.ddit.chatbot.service.ChatAIService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.vo.CalendarVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import kr.or.ddit.mapper.CalendarMapper;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service("calendarAiService")
public class CalendarAiServiceImpl implements ChatAIService {

	@Autowired
	private CalendarMapper calendarMapper;

	/**
	 * DB에서 현재 사용자의 일정 데이터를 가져와 텍스트로 변환 (REFERENCE용)
	 */
	public String getCalendarData(int empId) {
		List<CalendarVO> list = this.calendarMapper.list(empId);
		if (list == null || list.isEmpty()) {
			return "현재 등록된 일정이 없습니다.";
		}

		return list.stream()
				.map(c -> {
					// 1. 날짜 포맷팅 (YYYY-MM-DD 형식만 남기기)
					String startDate = (c.getCalBgngDt() != null && c.getCalBgngDt().length() >= 10)
							? c.getCalBgngDt().substring(0, 10) : c.getCalBgngDt();
					String endDate = (c.getCalEndDt() != null && c.getCalEndDt().length() >= 10)
							? c.getCalEndDt().substring(0, 10) : c.getCalEndDt();

					// 2. 시간 값 분리 및 null 체크
					String startTime = (c.getCalBgngTm() != null) ? c.getCalBgngTm() : "시간 미지정";
					String endTime = (c.getCalEndTm() != null) ? c.getCalEndTm() : "시간 미지정";

					// 3. 장소 null 처리
					String location = (c.getCalLocation() != null && !c.getCalLocation().trim().isEmpty())
							? c.getCalLocation() : "장소 정보 없음";

					return String.format("- 제목: %s, 날짜: %s", c.getCalTtl(), startDate);
				})
				.collect(Collectors.joining("\n"));
	}

	@Override
	public String buildSystem(String question, CustomUser customUser) {
		String today = LocalDate.now().toString();
		String dbContext = this.getCalendarData(customUser.getEmpVO().getEmpId());

		return """
		[ROLE] 사내 일정 비서 '에이아이'
          [기준 날짜] %s

			[핵심 규칙]
			1. 일정 조회/검색 요청 시:
			   - **절대로 DB 데이터를 직접 텍스트로 나열하지 마십시오.**
			  - 사용자가 말한 날짜나 키워드를 문장에 자연스럽게 포함하여 대답하십시오.
			  - 문장 맨 끝에 `[SEARCH_DATA:키워드]`를 붙이십시오.
			  - 예: "조회하신 날짜 2026-03-16 일정을 찾고 있습니다. [SEARCH_DATA:2026-03-16]"
			   - 키워드는 날짜(예: 2026-03-16) 혹은 제목이 될 수 있습니다.
			   - 사용자가 '오늘', '내일' 혹은 특정 날짜를 물으면 반드시 YYYY-MM-DD 형식으로 변환하여 키워드를 만드세요.
			   - 예: "내일 일정 뭐야?" (오늘이 3/15라면) -> [SEARCH_DATA:2026-03-16]
			   - 사용자가 '3월'처럼 월 단위로 물으면 [SEARCH_DATA:2026-03] 형식으로 만드세요.
			2. 일정 등록 요청 시:
			   - `[SAVE_DATA:JSON]` 태그만 생성하십시오.
				       

			[JSON 작성 규칙 - 중요]
			 - 역슬래시(\\\\)를 절대 넣지 마세요.
			 - 큰따옴표(")만 사용하세요.
			 - 예시: [SAVE_DATA:{"calTtl":"팀 회의","calBgngDt":"2026-03-16"}]

			[중요 지침]
			 1. 제목(calTtl)에 절대로 &nbsp; 같은 HTML 엔티티를 사용하지 마세요. 순수 텍스트와 일반 공백만 사용하세요.
			 2. 날짜는 반드시 YYYY-MM-DD 형식을 지키세요.
			 3. 종료일(calEndDt)이 언급되지 않았다면 시작일(calBgngDt)과 동일한 값을 넣으세요.

			[금지 사항]
			1. "검색된 일정입니다:" 하고 리스트를 읊는 행위는 절대 금지합니다.
			2. 데이터가 참조 데이터에 있더라도 직접 읽어주지 마세요. 검색은 브라우저가 담당합니다.
			3. JSON 주의사항:
				- **역슬래시(\\\\)를 절대 사용하지 마세요.**
				- 큰따옴표(")만 사용하여 순수한 JSON 객체를 만드세요.
				- 필드명: calTtl, calBgngDt, calEndDt, calBgngTm, calEndTm
				- 예시: [SAVE_DATA:{"calTtl":"회의","calBgngDt":"2026-03-16"}]

		  [응답 예시]
		  - 사용자: "3월 30일 일정 알려줘" -> 응답: "조회하신 날짜의 일정을 찾고 있습니다. [SEARCH_DATA:3월 30일]"
		  - 사용자: "이번주 회의 언제야?" -> 응답: "이번주 회의 일정을 검색합니다. [SEARCH_DATA:회의]"
		  - 사용자: "내일 오후 2시 팀미팅 등록해줘" -> 응답: "네, 일정을 등록하겠습니다. [SAVE_DATA:{"calTtl":"회의","calBgngDt":"2026-03-16"}]"
   
   		[일정 등록 규칙]
		   - 답변 시 반드시 자연스러운 문장 뒤에 [SAVE_DATA:{"key":"value"}] 형식을 포함하세요.
		   - JSON 내부에는 역슬래시(\\)를 절대 사용하지 마세요.
		   - 필드명: "calTtl", "calBgngDt", "calBgngTm", "calEndDt", "calEndTm"
		   - 예시: "네, 회의 일정을 등록할게요. [SAVE_DATA:{"calTtl":"회의","calBgngDt":"2026-03-16"}]"
   
          [참조용 DB 데이터]
          %s
        """.formatted(today, dbContext);
	}

	@Override
	public String buildUser(String question, CustomUser customUser) {
		String today = LocalDate.now().toString();

		return """
             [명령]\s
				다음 사용자 질문이 '단순 조회/확인'인지 '신규 등록'인지 판단하여 규격에 맞게 응답하세요.
				이미 있는 일정을 묻는 것이라면 절대 SAVE_DATA를 생성하지 마세요.
				
            [사용자 입력]
            "%s"
            """.formatted(question);
	}
}