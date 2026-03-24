package kr.or.ddit.controller.admin.survey;

import kr.or.ddit.mapper.SurveyMapper;
import kr.or.ddit.service.AlarmService;
import kr.or.ddit.service.SurveyService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.SurveyVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequestMapping("/admin/survey")
@Slf4j
@CrossOrigin(origins = "http://localhost:5173")
@RestController

public class SurveyAdminController {



	@Autowired
	private SurveyService surveyService;

	@Autowired
	private AlarmController alarmController;


	// [관리자 페이지] --------------------------------------------------------------------------

	/**
	 * [관리자 페이지] 설문 생성
	 * @param surveyVO
	 * @param auth
	 */
	@PostMapping("/insertSurvey")
	public Map<String, Object> insertSurvey(@RequestBody SurveyVO surveyVO, Authentication auth) {
		Map<String, Object> map = new HashMap<>();
		int loginId = 0;

		try {
			if (auth != null && auth.isAuthenticated()) {
				Object principal = auth.getPrincipal();

				if (principal instanceof CustomUser) {
					CustomUser customUser = (CustomUser) principal;
					loginId = customUser.getEmpVO().getEmpId();
				} else if (principal instanceof String) {
					try {
						loginId = Integer.parseInt((String) principal);
					} catch (NumberFormatException e) {
						log.error("사번 파싱 실패: {}", principal);
					}
				}
			}

			// 인증 실패 시
			if (loginId == 0) {
				map.put("status", "fail");
				map.put("message", "유효한 사용자 정보를 찾을 수 없습니다.");
				return map;
			}

			surveyVO.setSrvyEmpId(loginId);
			log.info("설문 등록 시도 (작성자: {}): {}", loginId, surveyVO);

			// 설문 등록
			int result = this.surveyService.insertSurvey(surveyVO);

			if (result > 0) {
				AlarmVO alarmVO = new AlarmVO();
				alarmVO.setAlmMsg("새로운 설문이 게시되었습니다.");

				// 제목이 없을 경우
				String surveyTitle = (surveyVO.getSrvyTtl() != null) ? surveyVO.getSrvyTtl() : surveyVO.getSrvyCn();
				alarmVO.setAlmDtl("<span class=\"fw-bold text-primary\">" + surveyTitle + "</span> 설문이 게시되었습니다.");
				alarmVO.setAlmIcon("clipboard-list");

				// 전체 사원 리스트
				List<EmployeeVO> allEmpList = this.surveyService.SurveyAllEmpIds();
				log.info("조회된 전체 사원 수: {}", allEmpList.size());

				List<Integer> rcvrNoList = new ArrayList<>();
				for (EmployeeVO emp : allEmpList) {
					int empId = emp.getEmpId();
					// 작성자 제외
					if (empId != loginId) {
						rcvrNoList.add(empId);
					}
				}

				alarmVO.setAlmRcvrNos(rcvrNoList);

				if (!rcvrNoList.isEmpty()) {
					String alarmRes = this.alarmController.sendAlarm(
							loginId,
							alarmVO,
							"/survey/detail?srvyNo=" + surveyVO.getSrvyNo(),
							"설문"
					);
					log.info("전체 대상 설문 알람 발송 결과 : " + alarmRes);
				}

				map.put("status", "success");
				map.put("message", "설문이 성공적으로 게시되었습니다.");
				map.put("srvyNo", surveyVO.getSrvyNo());
			} else {
				map.put("status", "fail");
				map.put("message", "설문 등록에 실패했습니다.");
			}
		} catch (Exception e) {
			log.error("설문 등록 중 서버 에러 발생: ", e);
			map.put("status", "error");
			map.put("message", "서버 오류가 발생했습니다.");
		}

		return map;
	}


	/**
	 * [관리자 페이지] 설문 리스트
	 */
	@GetMapping("/listData")
	public List<SurveyVO> surveyList() {
		// 리스트를 조회하기 전에 먼저 설문 종료 처리 일괄 수행
		surveyService.updateStts();
		log.info("설문 리스트 조회 요청");
		return surveyService.allList();
	}


	/**
	 * [관리자 페이지] 설문 수정
	 * @param surveyVO
	 */
	@PostMapping("/update")
	public String updateSurvey(@RequestBody SurveyVO surveyVO) {
		log.info("수정 데이터: {}", surveyVO);
		int result = this.surveyService.updateSurvey(surveyVO);
		return result > 0 ? "success" : "fail";
	}

	/**
	 * [관리자 페이지] 설문 삭제
	 * @param srvyNo
	 */
	@PostMapping("/delete")
	public String deleteSurveys(@RequestBody List<SurveyVO> srvyNo) {
		log.info("삭제할 번호 리스트: {}", srvyNo);
		int result = this.surveyService.deleteSurveys(srvyNo);
		return result > 0 ? "success" : "fail";
	}


	/**
	 * [관리자 페이지] 설문 상태 일괄 종료로 변경
	 * @param surveyList
	 * @return
	 */
	@PostMapping("/updateSttsSurvey")
	public String updateSttsSurvey(@RequestBody List<SurveyVO> surveyList) {
		log.info("상태 변경 리스트: {}", surveyList);
		int result = this.surveyService.updateSttsSurvey(surveyList);
		return result > 0 ? "success" : "fail";
	}


	/**
	 * [관리자 페이지] 설문 통계
	 * @return stats
	 */
	@GetMapping("/surveyStats")
	public SurveyVO surveyStats() {

		SurveyVO stats = surveyService.surveyStats();

		return stats;
	}


	/**
	 * [관리자 페이지] 부서별 통계
	 * @param srvyNo
	 * @return
	 */
	@GetMapping("/dept")
	public List<Map<String, Object>> deptChartData(
			@RequestParam(value = "srvyNo", required = false, defaultValue = "0") int srvyNo) {
		// 리액트에서 번호를 안 보내면 srvyNo는 0이 됨 -> 전체 통계 호출
		return surveyService.deptStatsList(srvyNo);
	}

	/**
	 * [관리자 페이지] 직급별 통계
	 * @param srvyNo
	 * @return
	 */
	@GetMapping("/rank")
	public List<Map<String, Object>> rankChartData(
			@RequestParam(value = "srvyNo", required = false, defaultValue = "0") int srvyNo) {
		return surveyService.rankStatsList(srvyNo);
	}


	/**
	 * 개별 응답 상세
	 */
	@GetMapping("/rsponses/{srvyNo}")
	public List<Map<String, Object>> individualAnswer(@PathVariable("srvyNo") Long srvyNo) {
		return surveyService.individualAnswer(srvyNo);
	}



	/**
	 * [사용자 페이지] 설문 통계 - 설문별 통계
	 * @param srvyNo
	 * @return surveyService.statsData(srvyNo)
	 */
	@GetMapping("/statsData")
	public SurveyVO statsData(@RequestParam(value="srvyNo", required = true) int srvyNo) {
		log.info("통계 데이터 요청 - srvyNo: {}", srvyNo);

		// 해당 설문의 기본 통계 데이터
		SurveyVO stats = surveyService.statsData(srvyNo);

		// 전체 사원 수
		if (stats != null) {
			int totalCount = surveyService.totalEmpCount();
			stats.setTotalEmpCount(totalCount);
		}

		return stats;
	}

}
