package kr.or.ddit.controller.admin.calendar;


import kr.or.ddit.mapper.CalendarMapper;
import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.AlarmService;
import kr.or.ddit.service.CalendarService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.*;
import kr.or.ddit.vo.project.ProjectVO;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;


@RequestMapping("/admin/schedule")
@Slf4j
@CrossOrigin(origins = "http://localhost:5173")
@RestController
public class CalendarAdminController {



	@Autowired
	CalendarService calendarService;

	@Autowired
	private AlarmService alarmService;

	@Autowired
	private AlarmController alarmController;

	/**
	 * 데이터 임시 저장소
	 */
	private static List<Map<String, Object>> dataList = new ArrayList<>();

	@Autowired
	private EmployeeMapper employeeMapper;

	@Autowired
	private DepartmentMapper departmentMapper;

	@Autowired
	private CalendarMapper calendarMapper;

	@Autowired
	private SimpMessagingTemplate template;



	/**
	 * 드래그 앤 드롭 일정 수정
	 * @param calendarVO
	 * @return null
	 */
	@PatchMapping("/updateRange")
	public String updateRange(@RequestBody CalendarVO calendarVO) {
		int result = this.calendarService.updateRange(calendarVO);
		log.info("updateRange -> result : {}", result);

		if(result > 0) {
			return "SUCCESS";
		}else {
			return null;
		}
	}



	/**
	 * 일정 삭제
	 * @param calendarVO
	 * @param auth
	 * @return map
	 */
	@PatchMapping("/delete")
	public Map<String, Object> delete(@RequestBody CalendarVO calendarVO, Authentication auth) {
		log.info("일정 삭제 요청 -> calendarVO : {}", calendarVO);

		int loginId = 0;
		String loginName = "";
		if (auth != null) {
			CustomUser customUser = (CustomUser) auth.getPrincipal();
			loginId = customUser.getEmpVO().getEmpId();
			loginName = customUser.getEmpVO().getEmpNm();
		}

		CalendarVO detailVO = this.calendarService.detail(calendarVO.getCalNo());

		int result = this.calendarService.delete(calendarVO);

		// 삭제 성공 시 알림 발송
		if (result > 0 && detailVO != null) {
			List<CalendarShareVO> shareList = detailVO.getCalendarShareList();

			if (shareList != null && !shareList.isEmpty()) {
				List<Integer> rcvrNoList = new ArrayList<>();
				for (CalendarShareVO shareVO : shareList) {
					// 본인 제외 및 유효한 사번 체크
					if (shareVO.getCalShareId() != 0 && shareVO.getCalShareId() != loginId) {
						rcvrNoList.add(shareVO.getCalShareId());
					}
				}

				if (!rcvrNoList.isEmpty()) {
					AlarmVO alarmVO = new AlarmVO();
					alarmVO.setAlmIcon("trash"); // 삭제니까 휴지통 혹은 경고 아이콘
					alarmVO.setAlmMsg("일정이 취소되었습니다.");
					alarmVO.setAlmDtl(
							"<span class=\"fw-bold\">" + loginName + "</span>님이 <span class=\"fw-bold text-danger\">"
									+ detailVO.getCalTtl() + "</span> 일정을 삭제했습니다."
					);
					alarmVO.setAlmRcvrNos(rcvrNoList);

					// 알람 발송
					this.alarmController.sendAlarm(loginId, alarmVO, "/calendar/main", "캘린더");
					log.info("삭제 알림 발송 완료: {}명", rcvrNoList.size());
				}
			}
		}

		Map<String, Object> map = new HashMap<>();
		map.put("result", result);
		return map;
	}





	// [관리자 페이지] ---------------------------------------------------------------------------	

	/**
	 * 일정 목록 출력
	 * @param empId
	 * @param auth
	 * @return new ArrayList<>()
	 */
	@ResponseBody
	@GetMapping("/adminList")
	public List<CalendarVO> adminList(
			@RequestParam(value="empId", required = false) String empId,
			Authentication auth) {

		if (empId == null || empId.isEmpty()) {
			if (auth != null) {
				CustomUser customUser = (CustomUser) auth.getPrincipal();
				empId = String.valueOf(customUser.getEmpVO().getEmpId());
			} else {
				log.warn("empId 파라미터 없고 인증 정보도 없습니다.");
				return new ArrayList<>();
			}
		}

		log.info("관리자 일정 리스트 요청 대상 사번: {}", empId);

		try {
			List<CalendarVO> clist = this.calendarService.adminList(Integer.parseInt(empId));
			return (clist != null) ? clist : new ArrayList<>();
		} catch (Exception e) {
			log.error("일정 조회 중 에러 발생: ", e);
			return new ArrayList<>();
		}
	}


	/**
	 * 일정 추가
	 * @param calendarVO
	 * @param auth
	 * @return map
	 */
	@ResponseBody
	@PostMapping("/addAdmin")
	public Map<String, Object> addAdmin(@RequestBody CalendarVO calendarVO, Authentication auth) {
		int loginId = 0;
		String loginName = "";

		if(auth != null) {
			CustomUser customUser = (CustomUser) auth.getPrincipal();
			loginId = customUser.getEmpVO().getEmpId();
			loginName = customUser.getEmpVO().getEmpNm();
		}

		// 관리자용 기본 설정
		calendarVO.setEmpId(loginId);
		calendarVO.setCalStts("Y");
		calendarVO.setCalAllday("Y");

		// 1. 일정 등록
		int result = this.calendarService.addSchedule(calendarVO);

		// 2. 등록 성공 시 공유 대상에게 알림
		if(result > 0) {
			List<CalendarShareVO> shareList = calendarVO.getCalendarShareList(); // 공유 대상

			if(shareList != null && !shareList.isEmpty()) {
				AlarmVO alarmVO = new AlarmVO();
				alarmVO.setAlmMsg("새로운 일정이 공유되었습니다.");
				alarmVO.setAlmDtl(
						"<span class=\"fw-bold\">" + "관리자" + "</span>님이 <span class=\"fw-bold text-primary\">"
								+ calendarVO.getCalTtl() + "</span> 일정을 공유했습니다."
				);
				alarmVO.setAlmIcon("calendar"); // 캘린더용 아이콘

				// 수신자 리스트 세팅 (발신자 제외)
				List<Integer> rcvrNoList = new ArrayList<>();
				for(CalendarShareVO shareVO : shareList) {
					// 본인이 아닐 때 추가
					if(shareVO.getCalShareId() != 0 && shareVO.getCalShareId() != loginId) {
						rcvrNoList.add(shareVO.getCalShareId());
					}
				}
				alarmVO.setAlmRcvrNos(rcvrNoList);

				// 알람 컨트롤러 호출
				if(!rcvrNoList.isEmpty()) {
					String alarmRes = this.alarmController.sendAlarm(
							loginId,
							alarmVO,
							"/calendar",
							"캘린더"
					);
					log.info("관리자 공유 알람 발송 결과 : " + alarmRes);
				}
			}
		}

		// 반환값도 사원용과 똑같이 Map으로 통일
		Map<String, Object> map = new HashMap<>();
		map.put("result", result);
		map.put("calNo", calendarVO.getCalNo());
		return map;
	}
/*
		// 인증 객체 체크
		if (auth == null) {
			log.warn("인증 정보가 없습니다. 일정 추가를 거부합니다.");
			return "fail"; // 또는 적절한 에러 코드 반환
		}

		try {
			// 현재 로그인한 사용자의 사번 추출 및 세팅
			String currentEmpId = auth.getName();
			calendarVO.setEmpId(Integer.parseInt(currentEmpId));

			if (calendarVO.getCalStts() == null) {
				calendarVO.setCalStts("Y");
			}
			log.info("일정 추가 요청자: {}, 일정 제목: {}", currentEmpId, calendarVO.getCalTtl());

			calendarVO.setCalStts("Y");
			calendarVO.setCalAllday("Y");

			int result = this.calendarService.addSchedule(calendarVO);
			return (result > 0) ? "success" : "fail";

		} catch (NumberFormatException e) {
			log.error("사번 형식이 올바르지 않습니다: {}", auth.getName());
			return "fail";
		} catch (Exception e) {
			log.error("일정 등록 중 에러 발생: ", e);
			return "fail";
		}
	}
*/

	/**
	 * 일정 수정
	 * @param calendarVO
	 * @return null
	 */
	@ResponseBody
	@PostMapping("/updateAdmin")
	public String updateAdmin(@RequestBody CalendarVO calendarVO) {
		log.info("일정 수정 요청: {}", calendarVO);

		int result = this.calendarService.updateAdmin(calendarVO);
		log.info("update -> result : {}", result);

		if(result > 0) {
			return "SUCCESS";
		} else {
			return null;
		}
	}


	// [식단표] ---------------------------------------------------------------------------------------------------------

	/**
	 * 일반 사원용 (보기 전용)
	 * @param model
	 * @return "main"
	 */
	@GetMapping("/mealSchedule")
	public String mealSchedule(Model model) {
		model.addAttribute("contentPage", "calendar/mealSchedule");
		return "main";
	}


	/**
	 * 관리자용 (편집 가능)
	 * @return "calendar/mealAdmin"
	 */
	@GetMapping("/mealAdmin")
	public String mealAdmin() {
		return "calendar/mealAdmin";
	}




}
