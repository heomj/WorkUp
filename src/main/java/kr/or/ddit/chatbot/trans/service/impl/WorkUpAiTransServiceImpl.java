package kr.or.ddit.chatbot.trans.service.impl;

import org.springframework.stereotype.Service;

import kr.or.ddit.chatbot.service.ChatAIService;
import kr.or.ddit.service.impl.CustomUser;

@Service("workUpTransService")
public class WorkUpAiTransServiceImpl implements ChatAIService {

	@Override
	public String buildUser(String question, CustomUser customUser) {
        // 공통 라인을 타고 온 일괄 문자열을 내 전용 구분자로 쪼개기
        String[] parts = question.split(":::SEP:::");

        if (parts.length >= 2) {
            String selectedTone = parts[0]; // "정중한 말투"
            String originalText = parts[1]; // "확인 안했냐??"

            return String.format("[말투: %s]\n내용: %s\n위 지시대로 처리해.", selectedTone, originalText);
        }

        // 구분자가 없는 일반 요청일 경우의 예외 처리
        return question;
	}

	@Override
	public String buildSystem(String question, CustomUser customUser) {

        return """
                [ROLE]
                당신은 전문 문장 교정 AI입니다.
                
                [RULES]
                """

+
                 """
                 [QUESTION]
                 %s
            
                 [OUTPUT FORMAT]
                 - 교정 결과인 텍스트만 출력하십시오.
                 - 줄바꿈이 필요한 곳에는 반드시 <br> 태그를 추가하십시오.
                             - 연속된 공백이 필요하다면 &nbsp;를 사용하여 HTML에서 그대로 보이게 하십시오.
                 """
                .formatted(question);
	}

}
