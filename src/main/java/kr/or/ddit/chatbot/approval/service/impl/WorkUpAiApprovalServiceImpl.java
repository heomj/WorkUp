package kr.or.ddit.chatbot.approval.service.impl;

import kr.or.ddit.chatbot.service.ChatAIService;
import kr.or.ddit.mapper.ApprovalMapper;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.vo.ApprovalVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service("workUpApprovalService")
public class WorkUpAiApprovalServiceImpl implements ChatAIService {

	@Autowired
	private ApprovalMapper approvalMapper;

	// DB에서 전자결재 현황 텍스트로 가져오기 (오타 수정: getApprovla -> getApprovalContext)
	// DB에서 전자결재 현황 텍스트로 가져오기
	public String getApprovalContext(int empId, String message) {

		StringBuilder sb = new StringBuilder();

		// 1. 키워드 목록 세분화 (조회 vs 행동)
		// "내가 올린 문서 중 거절당한 걸 보여줘!" 라는 명확한 조회 의도만 필터링
		String[] returnViewKeywords = {"반려 된", "반려당한", "거절된", "까인", "반려 목록"};

		// 사용자의 메시지에 반려 '조회' 의도가 있는지 확인
		boolean isReturnView = Arrays.stream(returnViewKeywords).anyMatch(message::contains);

		int aprvCnt = 0;
		Map<String, Object> map = new HashMap<>();
		map.put("currentPage", 1);
		map.put("empId", empId);
		map.put("url", "");

		// 2. 명확하게 "반려된 문서를 보여줘"라고 했을 때만 반려 목록(return) 세팅
		if (isReturnView) {
			map.put("stts", "return"); // 반려 상태
			aprvCnt = this.approvalMapper.getTotal(map);
			log.info("반려문서 개수 : " + aprvCnt);

			sb.append("- 현재 사용자가 기안한 문서 중 [반려]된 문서는 총 ")
					.append(aprvCnt)
					.append("건 입니다.\n");

			if (aprvCnt > 0) {
				List<ApprovalVO> returnList = this.approvalMapper.list(map);
				sb.append("[📋 결재 반려 문서 목록]<br>");

				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
				for (ApprovalVO vo : returnList) {
					String date = vo.getAprvDt() != null ? sdf.format(vo.getAprvDt()) : "날짜 없음";
					// System Prompt에서 String.format 사용 시 에러 방지를 위해 변수 매칭 주의!
					sb.append(String.format(
							"🔹 %s | 📅 %s<br>",
							vo.getAprvTtl(),
							date
					));
				}
			}
		}
		// 3. 그 외의 모든 경우 (결재 대기 목록 보기, 승인해줘, 반려해줘, 일괄 결재 등)
		// 무조건 '결재 대기 목록'을 기본으로 AI에게 제공합니다.
		else {
			map.put("stts", "pending"); // 결재대기 상태
			aprvCnt = this.approvalMapper.getPendingTotal(map);
			log.info("결재대기문서 개수 : " + aprvCnt);

			sb.append("- 현재 결재해야 할 [대기] 문서는 총 ")
					.append(aprvCnt)
					.append("건 입니다.\n");

			if (aprvCnt > 0) {
				List<ApprovalVO> pendingList = this.approvalMapper.pendingList(map);
				sb.append("[📋 결재 대기 문서 목록] \n");

				SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
				for (ApprovalVO vo : pendingList) {
					String date = vo.getAprvDt() != null ? sdf.format(vo.getAprvDt()) : "날짜 없음";
					String rank = vo.getPosNm() != null ? vo.getPosNm() : "직급없음";
					String dept = vo.getDocWriterDeptNm() != null ? vo.getDocWriterDeptNm() : "소속없음";

					// String.format 짝꿍(알맹이) 개수 정확히 맞춤!
					sb.append(String.format(
							"🔹(문서번호 : %s) %s (%s, %s / %s) | 📅 %s \n",
							vo.getAprvNo(),
							vo.getAprvTtl(),
							vo.getDocWriterNm(),
							rank,
							dept,
							date
					));
				}
			} else {
				// 대기 문서가 없을 때 AI가 대응할 수 있도록 안내
				sb.append("- 현재 결재 대기 중인 문서가 없습니다. 사용자에게 처리할 문서가 없다고 안내하세요.\n");
			}
		}

		return sb.toString();
	}


	/**
	 * [AI에게 전달할 사용자 질문과 지시사항 세팅]
	 * 기존 프로젝트 흔적(일감 등)을 모두 지우고 심플하게 변경!
	 */
	@Override
	public String buildUser(String question, CustomUser customUser) {

		// 지시사항: 챗봇이 어떻게 대답해야 할지 가이드라인
		String instruction = "사용자의 질문을 파악하여 친절하게 답변해 주세요. 데이터 확인이 필요한 경우 시스템 프롬프트의 [REFERENCE] 데이터를 바탕으로 정확하게 답변하세요.";

		return """
          [지시사항]
          %s

          [USER QUESTION]
          %s
          """.formatted(instruction, question);
	}


	/**
	 * [AI의 페르소나(역할)와 DB 팩트 세팅]
	 */
	@Override
	public String buildSystem(String question, CustomUser customUser) {

		// DB에서 전자결재 현황(건수 등)을 조회해서 문자열로 가져옴
		String dbContext = this.getApprovalContext(customUser.getEmpVO().getEmpId(), question);

		return """
                [SYSTEM]
                 - 너는 그룹웨어의 똑똑한 '전자결재 관리 비서'다.
                 - 서론이나 불필요한 인사말 없이 묻는 말에 정확히 답변한다.
                 - 숫자를 안내할 때는 글씨를 굵게 표시해서 가독성을 높여라.
                 - 반드시 아래 [REFERENCE]에 제공된 데이터(건수, 목록)만 사용하여 답변하고, 없는 정보를 절대 지어내지 마라.
                 - 사용자가 특정 문서들의 '일괄 결재(일괄 승인)' 또는 '일괄 반려'를 요청하면, 반드시 답변 텍스트 마지막에 아래와 같은 JSON 태그를 덧붙여서 출력해
                 - 결재/일괄결재/승인/일괄승인 인 경우: [ACTION_DATA: {\"aprvNos\": [문서번호1, 문서번호2], \"action\": \"CONFIRM\"}]\n
                 - 반려/일괄반려 인 경우: [ACTION_DATA: {\"aprvNos\": [문서번호1, 문서번호2], \"action\": \"REJECT\"}]\n
                 - 문서 번호는 숫자 배열 형태로 넣어줘. \n
                 - 주의: [ACTION_DATA: ...] 태그와 JSON 데이터 안에는 절대 줄바꿈(Enter)이나 공백을 넣지 말고, 반드시 1줄의 텍스트로만 출력해!\n"
                 
                 - ⚠️ [매우 중요] 사용자가 결재/반려 등 실제 [처리]를 요청하여 ACTION_DATA를 출력할 때는, 절대 '진행하시겠습니까?', '확인해주세요' 같이 되묻는 멘트를 하지 마라.
                 - ⚠️ [매우 중요] 처리할 때는 반드시 '아래 조회된 결재 문서를 일괄 결재(또는 반려) 처리합니다.' 라는 확정적인 문장으로만 대답해라.\n

                [REFERENCE]
                %s

                [OUTPUT FORMAT]
                 - 답변은 가독성 좋게 줄바꿈(<br/>), 띄어쓰기, 폰트 굵기 조절을 통한 강조를 적절히 사용해라.
                """.formatted(dbContext);
	}
}