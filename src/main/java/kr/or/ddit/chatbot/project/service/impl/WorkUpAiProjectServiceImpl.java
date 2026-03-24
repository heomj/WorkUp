package kr.or.ddit.chatbot.project.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.or.ddit.chatbot.service.ChatAIService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service("workUpProjectService")
public class WorkUpAiProjectServiceImpl implements ChatAIService {

	@Autowired
	private WorkUpAiProjectMapper projectMapper;

    // DB에서 프로젝트 가져오기
    public String project(int empId, String message) {

        List<ProjectVO> projectlist = this.projectMapper.project(empId);
        StringBuilder sb = new StringBuilder();

		log.info("가져온 list : {}", projectlist);

        for (ProjectVO p : projectlist) {
            // 프로젝트명
            sb.append(String.format("\n[P] 프로젝트명: %s [PRGRT] 진행률 : %s\n", p.getProjTtl(), p.getProjPrgrt()));

            // 현황 질문일 때만 일감 추가
            if (p.getTaskVOList() != null) {
                for (TaskVO t : p.getTaskVOList()) {
                    if ("완료".equals(t.getTaskStts())) continue;
                    sb.append(String.format("- [T] 일감: %s(상태: %s) | 시작일 : %s  종료일 :%s | 진행률 : %s%% \n"
							, t.getTaskTtl(), t.getTaskStts(),t.getTaskBgngDt(), t.getTaskEndDt(), t.getTaskPrgrt()));
                }
            }
        }
        return sb.toString();
    }

	@Override
	public String buildUser(String question, CustomUser customUser) {
		String userName = customUser.getEmpVO().getEmpNm();

		String instruction = "";
		String role = "";
		String Format = "";

		System.out.println("질문 :" + question);

		// 프로젝트 봇 전용 로직
		String userquestion = question.trim();

		switch (userquestion) {
			case "오늘까지 끝내야 하는 일감들":
				instruction = "- [REFERENCE]에서 오늘 마감인 일감 개수를 세어 [N]에 넣으세요.";
				role = "일감이 없으면 [Format]을 출력하지 말고'" + userName  +"'님, 확인해보니 오늘 마감인 일감이 없네요! ✨'라고만 하세요.";
				Format = """
				📅 오늘 마감 예정인 일감이 [N]건 있습니다. <br>
				📂 [프로젝트명] - [일감명] (진행률: [진행률]%)<br>
				""";
				break;
			case "마감기한이 임박한 일감들":
				instruction = "- [REFERENCE]에서 마감일이 3일 이내인 일감 개수를 세어 [N]에 넣으세요.";
				role = "마감일이 3일 이내인 일감이 없으면 [Format]을 출력하지 말고'" + userName  +"'님, 확인해보니 마감일이 임박한 일감이 없네요! ✨'라고만 하세요.";
				Format = """
				📅 마감기한이 임박한 일감이 [N]건 있습니다. <br>
				📂 [프로젝트명] <br>
				- [일감명] (진행률: [진행률]%) 마감일 : [마감일]<br>
				""";
				break;

			case "내가 참여하고 있는 프로젝트":
				instruction = "- [REFERENCE]에서 참여 중인 프로젝트 목록을 추출하세요.";
				role = "프로젝트가 없으면'"+ userName +"'님, 📂 참여하고 있는 프로젝트가 없습니다.'라고만 하세요.";
				Format = "📂 [프로젝트명]";
				break;

			default:
				instruction = "- [REFERENCE]을 참고하여 답변을 하세요";
				role = "답변은 짧고 간단하게 하십시오.";
				Format = userName +"님 질문하신 ~ 내용입니다";

				break;

		}
		return String.format("""
			[지시사항]
			%s
			%s
			
			[답변 포맷]
			%s
			
			오늘도 힘내세요!🔥
			
			[사용자 질문]
			%s
			""", instruction, role, Format, userquestion);

	}

	@Override
	public String buildSystem(String question, CustomUser customUser) {

		// DB에서 프로젝트 조회 할고임
		String dbContext = this.project(customUser.getEmpVO().getEmpId(), question);

		return """
				[SYSTEM]
				 - 너는 친절한 PM 비서다.
				 - 서론이나 인사 없이 즉시 본론(지시사항)에 맞춰 답변한다.
				 - [REFERENCE] 데이터에만 기반하여 답변하라

				[REFERENCE]
				%s

				""".formatted(dbContext);
	}

}
