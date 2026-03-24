package kr.or.ddit.controller;

import kr.or.ddit.mapper.SurveyMapper;
import kr.or.ddit.service.AlarmService;
import kr.or.ddit.service.SurveyService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.SurveyVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequestMapping("/survey")
@Slf4j
@Controller
public class SurveyController {



	@Autowired
	private SurveyService surveyService;

	@Autowired
	private AlarmService alarmService;

	@Autowired
	private AlarmController alarmController;
    @Autowired
    private SurveyMapper surveyMapper;


	// [사용자 페이지] -------------------------------------------------------------------------

	/**
	 * [사용자 페이지] 참여 가능한 설문 조회
	 * @param model
	 * @param auth
	 * @return
	 */
	@GetMapping("/survey")
	public String survey(Model model, Authentication auth) {

		int loginId = 0;
		String loginName = "";

		if(auth != null) {
			CustomUser customUser = (CustomUser) auth.getPrincipal();
			loginId = customUser.getEmpVO().getEmpId();
			loginName = customUser.getEmpVO().getEmpNm();
		}

		log.info("접속 사번(loginId) : {}", loginId);
		log.info("접속 성명(loginName) : {}", loginName);

		// 참여 가능한 설문
		List<SurveyVO> newList = surveyService.newList(loginId);
		log.info("▶ 참여 가능 설문(newList) 개수 : {}건", newList != null ? newList.size() : 0);

		// 참여한 설문
		List<SurveyVO> mineList = surveyService.mineList(loginId);

		// 종료된 설문
		List<SurveyVO> closedList = surveyService.closedList(loginId);

		model.addAttribute("newList", newList);
		model.addAttribute("mineList", mineList);
		model.addAttribute("closedList", closedList);

		model.addAttribute("loginId", loginId);
		model.addAttribute("loginName", loginName);

		model.addAttribute("contentPage", "survey/survey");

		return "main";
	}


	/**
	 * [사용자 페이지] 설문 상세 조회
	 * @param srvyNo
	 */
	@ResponseBody
	@GetMapping("/detail")
	public SurveyVO detail(@RequestParam(value="srvyNo") int srvyNo) {
		log.info("설문 상세 조회 요청(srvyNo) : {}", srvyNo);
		return surveyService.surveyDetail(srvyNo);
	}


	/**
	 * [사용자 페이지] 설문 응답 제출
	 * @param surveyVO
	 * @param auth
	 */
	@ResponseBody
	@PostMapping("/submit")
	public Map<String, Object> submitSurvey(@RequestBody SurveyVO surveyVO, Authentication auth) {
		Map<String, Object> result = new HashMap<>();

		try {
			if (auth == null) {
				result.put("status", "error");
				return result;
			}

			CustomUser customUser = (CustomUser) auth.getPrincipal();
			int loginId = customUser.getEmpVO().getEmpId();
			surveyVO.setEmpId(loginId);

			// 1. 설문 마스터 정보 조회 (실제 DB에 등록된 마일리지와 제목을 가져옴)
			SurveyVO infoVO = this.surveyService.surveyDetail(surveyVO.getSrvyNo());

			if (infoVO == null) {
				result.put("status", "error");
				result.put("message", "설문 정보를 찾을 수 없습니다.");
				return result;
			}

			int currentMlg = infoVO.getSrvyMlg();
			String srvyCn = infoVO.getSrvyCn(); // 설문 제목(내용)

			surveyVO.setSrvyMlg(currentMlg);
			if (surveyVO.getQuestions() != null) {
				for (SurveyVO q : surveyVO.getQuestions()) {
					q.setEmpId(loginId);
					q.setSrvyNo(surveyVO.getSrvyNo());
					q.setSrvyMlg(currentMlg);
				}
			}

			// 3. 설문 응답 저장 (SURVEY_ANSWER 및 SURVEY_EMP MERGE 실행)
			int row = this.surveyService.surveySubmit(surveyVO);

			if (row >= 0) {
				log.info("설문 제출 성공 - 사원: {}, 설문: {}, 적립 마일리지: {}", loginId, srvyCn, currentMlg);

				// [알림 전송 로직]
				AlarmVO alarmVO = new AlarmVO();
				alarmVO.setAlmMsg("마일리지 <span class=\"fw-bold text-warning\">" + currentMlg + " P</span>가 적립되었습니다.");

				alarmVO.setAlmDtl(
						"<span class=\"fw-bold text-warning\">[" + srvyCn + "]</span> 설문 참여로 "
								+ "<span class=\"fw-bold text-warning\">" + currentMlg + " P</span>가 적립되었습니다."
				);
				// 아이콘
				alarmVO.setAlmIcon("mileage");

				// 이동할 URL
				String targetUrl = "/survey/survey?tab=mine";
				alarmVO.setAlmUrl(targetUrl);

				// 수신자 설정 (본인)
				List<Integer> rcvrNoList = new ArrayList<>();
				rcvrNoList.add(loginId);
				alarmVO.setAlmRcvrNos(rcvrNoList);

				// 실시간 알림 발송 (AlarmController의 STOMP 로직 실행)
				new Thread(() -> {
					try {
						Thread.sleep(800); // 0.8초 정도 대기 (이동 후 연결될 시간)
						this.alarmController.sendAlarm(loginId, alarmVO, targetUrl, "마일리지");
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}).start();

				result.put("status", "success");
			}
		} catch (Exception e) {
			log.error("설문 제출 처리 중 에러: ", e);
			result.put("status", "error");
		}
		return result;
	}
	/*
	@ResponseBody
	@PostMapping("/submit")
	public Map<String, Object> submitSurvey(@RequestBody SurveyVO surveyVO, Authentication auth) {
		Map<String, Object> result = new HashMap<>();

		// 로그 추가: 요청 데이터가 잘 들어오는지 확인
		log.info("제출된 설문 데이터: {}", surveyVO);

		try {
			if (auth == null) {
				result.put("status", "error");
				result.put("message", "로그인 세션이 만료되었습니다. 다시 로그인해주세요.");
				return result;
			}

			CustomUser customUser = (CustomUser) auth.getPrincipal();
			int loginId = customUser.getEmpVO().getEmpId();
			surveyVO.setEmpId(loginId);

			log.info("설문 제출자 사번: {}", loginId);

			int row = this.surveyService.surveySubmit(surveyVO);

			if (row >= 0) {
				result.put("status", "success");
			} else {
				result.put("status", "error");
				result.put("message", "데이터 저장에 실패했습니다.");
			}
		} catch (Exception e) {
			log.error("설문 제출 에러 발생!!!", e); // 서버 콘솔(STS/IntelliJ)을 꼭 확인하세요!
			result.put("status", "error");
			result.put("message", "서버 오류: " + e.getMessage());
		}
		return result;
	}
*/


	/**
	 * [사용자 페이지] 설문 통계 - 설문별 통계
	 * @param srvyNo
	 * @return surveyService.statsData(srvyNo)
	 */
	@ResponseBody
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



	/**
	 * [대시보드] 참여 가능한 최신 설문 리스트
	 */
	@ResponseBody
	@GetMapping("/dashboardList")
	public List<SurveyVO> dashboardList(Authentication auth) {
		int loginId = 0;
		if (auth != null) {
			CustomUser customUser = (CustomUser) auth.getPrincipal();
			loginId = customUser.getEmpVO().getEmpId();
		}

		// 참여 가능한 설문 리스트 조회
		List<SurveyVO> newList = surveyService.newList(loginId);

		// 리스트 개수 제한
		if (newList != null && newList.size() > 2) {
			return newList.subList(0, 2);
		}

		return newList;
	}



}
