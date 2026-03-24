package kr.or.ddit.controller;


import java.util.*;

import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.*;
import kr.or.ddit.vo.project.ProjectVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import java.util.stream.Collectors;

import kr.or.ddit.mapper.CalendarMapper;
import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.AlarmService;
import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.service.CalendarService;
import kr.or.ddit.service.impl.CustomUser;
import lombok.extern.slf4j.Slf4j;



@RequestMapping("/calendar")
@Slf4j
@Controller
public class CalendarController {

	@Autowired
	private CalendarService calendarService;

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
	 * 메인
	 * @param model
	 * @param employeeVO
	 * @param auth
	 * @return main
	 */
	@GetMapping("/main")
	public String calendarMain(Model model, EmployeeVO employeeVO, Authentication auth) {
		model.addAttribute("contentPage", "calendar/main");

		if (auth != null) {
			CustomUser customUser = (CustomUser) auth.getPrincipal();

			EmployeeVO loginUserVO = customUser.getEmpVO();

			log.info("디버깅 - 시큐리티 세션에서 가져온 부서명: {}", loginUserVO.getDeptNm());
			log.info("디버깅 - 로그인 유저 정보 전체: {}", loginUserVO);

			// 로그인한 계정의 팀원 출력
			List<EmployeeVO> teamList = this.calendarService.teamList(loginUserVO.getDeptCd());

			model.addAttribute("loginId", loginUserVO.getEmpId());
			model.addAttribute("deptNm", loginUserVO.getDeptNm());
			model.addAttribute("teamList", teamList);
		}
		return "main";
	}


	/**
	 * 일정 목록 출력
	 * @param auth
	 * @param selectedEmpId
	 * @return new ArrayList<>()
	 */
	@ResponseBody
	@GetMapping("/list")
	public List<CalendarVO> list(Authentication auth,
								 @RequestParam(value="empId", required = false) String selectedEmpId) {

		// 1. 인증 객체 체크 (로그인 안 된 경우 대비)
		if (auth == null && (selectedEmpId == null || selectedEmpId.isEmpty())) {
			log.warn("인증 정보가 없고 선택된 사번도 없습니다.");
			return new ArrayList<>();
		}

		// 2. 사번 결정
		String empId = (selectedEmpId != null && !selectedEmpId.isEmpty())
				? selectedEmpId
				: auth.getName();

		log.info("일정 리스트 요청 대상 사번: {}", empId);

		try {
			// 3. 서비스 호출
			List<CalendarVO> clist = this.calendarService.list(Integer.parseInt(empId));
			List<ReserveVO> rsvList = this.calendarService.roomReservationList(Integer.parseInt(empId));

			if (rsvList != null) {
				for (ReserveVO rsv : rsvList) {
					CalendarVO cal = new CalendarVO();

					// resId가 null인지 먼저 체크하여 NumberFormatException 방지
					if (rsv.getResId() != null && !rsv.getResId().isEmpty()) {
						cal.setCalNo(Integer.parseInt(rsv.getResId()));
					} else {
						log.error("데이터 매핑 실패: resId가 null입니다. 쿼리의 별칭을 확인하세요.");
						continue; // 에러 방지를 위해 이번 루프는 건너뜀
					}

					cal.setCalTtl(rsv.getTitle());
					cal.setCalBgngDt(rsv.getBgngDt());
					cal.setCalEndDt(rsv.getEndDt());
					cal.setCalColor("#566a7f");
					cal.setCalAllday("N");
					cal.setReserve(rsv);
					cal.setIsReservation("Y");

					clist.add(cal);
				}
			}

			// 3. 프로젝트 일정 조회 및 통합
			java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");

			List<ProjectVO> projList = this.calendarService.projectCalendarList(empId);
			if (projList != null) {
				for (ProjectVO proj : projList) {
					CalendarVO cal = new CalendarVO();
					cal.setCalNo(proj.getProjNo());
					cal.setCalTtl(proj.getProjTtl());

					if (proj.getProjBgngDt() != null) {
						cal.setCalBgngDt(sdf.format(proj.getProjBgngDt()));
					}

					// 종료일
					if (proj.getProjEndDt() != null) {
						Calendar c = Calendar.getInstance();
						c.setTime(proj.getProjEndDt());
						c.add(Calendar.DATE, 1); // 하루를 더하기
						cal.setCalEndDt(sdf.format(c.getTime()));
					}

					cal.setCalColor(proj.getProjColor() != null ? proj.getProjColor() : "#91d4a8");
					cal.setCalAllday("Y");
					cal.setIsReservation("P"); // JS에서 판별할 핵심 값

					// 상세 데이터 매핑
					cal.setCalContent(proj.getProjDtl());
					cal.setProjIpt(proj.getProjIpt());
					cal.setProjPrgrt(proj.getProjPrgrt());

					clist.add(cal);
				}
			}


			// 4. 데이터가 없으면 빈 리스트 반환 (map 에러 방지 핵심)
			return (clist != null) ? clist : new ArrayList<>();

		} catch (Exception e) {
			log.error("일정 조회 중 에러 발생: ", e);
			return new ArrayList<>();
		}
	}
	/*
	@ResponseBody
	@GetMapping("/list")
    public List<CalendarVO> list(Authentication auth,
								 @RequestParam(value="empId", required = false) String selectedEmpId) {
		// 만약 파라미터로 넘어온 empId가 있으면 그것을 사용, 없으면 로그인한 본인 사번 사용
		String empId = (selectedEmpId != null && !selectedEmpId.isEmpty())
						? selectedEmpId
						: auth.getName();
		log.info("로그인한 사번: {}", empId);

        log.info("일정 리스트 요청");
        List<CalendarVO> clist = this.calendarService.list(Integer.parseInt(empId));
        log.info("list : {}", clist);

        return clist;
    }
*/


	/**
	 * 드래그 앤 드롭 일정 수정
	 * @param calendarVO
	 * @return null
	 */
	@ResponseBody
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
	 * 일정 상세보기
	 * @param calNo
	 * @return calendarVO
	 */
	@ResponseBody
	@GetMapping("/detail")
	public CalendarVO detail(@RequestParam(value="id", required = true) int calNo) {
		CalendarVO calendarVO = this.calendarService.detail(calNo);

		return calendarVO;
	}


	/**
	 * 일정 추가
	 * @param calendarVO
	 * @param auth
	 * @return map
	 */
	@ResponseBody
	@PostMapping("/addSchedule")
	public Map<String, Object> addSchedule(CalendarVO calendarVO, Authentication auth) {
		int loginId = 0;
		String loginName = "";
		if(auth != null) {
			CustomUser customUser = (CustomUser) auth.getPrincipal();
			loginId = customUser.getEmpVO().getEmpId();
			loginName = customUser.getEmpVO().getEmpNm();

			calendarVO.setEmpId(loginId);
		}

		// 1. 일정 등록
		int result = this.calendarService.addSchedule(calendarVO);

		// 2. 등록 성공 시 공유 대상에게 알림
		if(result > 0) {
			List<CalendarShareVO> shareList = calendarVO.getCalendarShareList(); // 공유 대상
			if(shareList != null && !shareList.isEmpty()) {

				AlarmVO alarmVO = new AlarmVO();
				alarmVO.setAlmMsg("새로운 일정이 공유되었습니다.");
				alarmVO.setAlmDtl(
						"<span class=\"fw-bold\">" + loginName + "</span>님이 <span class=\"fw-bold text-primary\">"
								+ calendarVO.getCalTtl() + "</span> 일정을 공유했습니다."
				);
				alarmVO.setAlmIcon("calendar");

				// 수신자 리스트 세팅 (발신자 제외)
				List<Integer> rcvrNoList = new ArrayList<>();
				for(CalendarShareVO shareVO : shareList) {
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
					log.info("공유 대상에게 알람 발송 결과 : " + alarmRes);
				}
			}
		}

		Map<String, Object> map = new HashMap<>();
		map.put("result", result);
		map.put("calNo", calendarVO.getCalNo());
		return map;
	}

	/*
	@ResponseBody
	@PostMapping("/addSchedule")
	public Map<String, Object> addSchedule(CalendarVO calendarVO) {

		int result = this.calendarService.addSchedule(calendarVO);

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("result", result);
		map.put("calNo", calendarVO.getCalNo());

		return map;
	}
	 */


	/**
	 * 일정 수정
	 * @param calendarVO
	 * @param auth
	 * @return null
	 */
	@ResponseBody
	@PostMapping("/update")
	public String update(CalendarVO calendarVO, Authentication auth) {

		int loginId = 0;
		String loginName = "";
		if(auth != null) {
			CustomUser customUser = (CustomUser) auth.getPrincipal();
			loginId = customUser.getEmpVO().getEmpId();
			loginName = customUser.getEmpVO().getEmpNm();
		}

		int result = this.calendarService.update(calendarVO);
		log.info("update -> result : {}", result);

		String empId = auth.getName();
		log.info("현재 로그인 사용자 : {}", empId);

		if(result > 0) {
			AlarmVO alarmVO = new AlarmVO();

			// 수신자: 일정 작성자
			int receiverId = calendarVO.getEmpId();
			List<Integer> rcvrList = new ArrayList<>();
			rcvrList.add(receiverId);

			// 메시지 설정
			alarmVO.setAlmMsg("일정이 수정되었습니다");
			alarmVO.setAlmDtl(
					"<span class='fw-bold'>" + loginName + "</span>님이 " +
							"<span class='fw-bold text-primary'>" + calendarVO.getCalTtl() + "</span> 일정을 수정했습니다."
			);
			alarmVO.setAlmRcvrNos(rcvrList);
			alarmVO.setAlmIcon("info");

			// 알람 발송
			alarmController.sendAlarm(
					receiverId,
					alarmVO,
					"/calendar/view",
					"일정"
			);
			return "SUCCESS";
		}else {
			return null;
		}

	}

	/*
	@ResponseBody
	@PostMapping("/update")
	public String update(CalendarVO calendarVO) {
		int result = this.calendarService.update(calendarVO);
		log.info("update -> result : {}", result);

		if(result > 0) {
			return "SUCCESS";
		}else {
			return null;
		}

	}
	 */


	/**
	 * 일정 삭제
	 * @param calendarVO
	 * @param auth
	 * @return map
	 */
	@ResponseBody
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
	/*// 일정 삭제
	@ResponseBody
	@PatchMapping("/delete")
	public Map<String, Object> delete(@RequestBody CalendarVO calendarVO) {
		log.info("일정 삭제 -> calendarVO : {}", calendarVO);

		int result = this.calendarService.delete(calendarVO);

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("result", result);

		return map;
	}
*/


	// [부서 일정 보기] ------------------------------------------------------------------------------------------------

	/**
	 * 로그인한 계정의 부서명 가져오기
	 * @param auth
	 * @param model
	 * @return "calendar/calendarMain"
	 */
	@GetMapping("/getDeptNm")
	public String getDeptNm(Authentication auth, Model model) {
		String empIdStr = auth.getName();
		int empId = Integer.parseInt(empIdStr);

		DepartmentVO departmentVO = calendarMapper.getDeptNm(empId);
		log.info("디버깅 - 조회된 부서객체: {}", departmentVO);


		if (departmentVO != null) {
			model.addAttribute("deptNm", departmentVO.getDeptNm());

			if(departmentVO.getMemberVO() != null) {
				model.addAttribute("empId", departmentVO.getMemberVO().getEmpId());
			}
		} else {
			model.addAttribute("deptNm", "부서 없음");
		}

		return "calendar/calendarMain";
	}



	// [내 일정] ---------------------------------------------------------------------------------------------

	/**
	 * 출장
	 * @param auth
	 * @param empId
	 * @return this.calendarService.bztrpList(map)
	 */
	@ResponseBody
	@GetMapping("/bztrip")
	public List<ApprovalVO> bztrp(Authentication auth,
								  @RequestParam(value="empId", required = false) String empId) {
		int targetEmpId;

		if (empId != null && !empId.isEmpty()) {
			targetEmpId = Integer.parseInt(empId);
		} else {
			CustomUser customUser = (CustomUser)auth.getPrincipal();
			targetEmpId = customUser.getEmpVO().getEmpId();
		}

		Map<String, Object> map = new HashMap<>();
		map.put("empId", targetEmpId);
		map.put("bztrpStts", "결재완료");

		return this.calendarService.bztrpList(map);
	}


	/**
	 * 연차
	 * @param auth
	 * @param empId
	 * @return this.calendarService.vacationList(map)
	 */
	@ResponseBody
	@GetMapping("/vacation")
	public List<ApprovalVO> vacation(Authentication auth,
									 @RequestParam(value="empId", required = false) String empId) {
		int targetEmpId;

		if (empId != null && !empId.isEmpty()) {
			targetEmpId = Integer.parseInt(empId);
		} else {
			CustomUser customUser = (CustomUser)auth.getPrincipal();
			targetEmpId = customUser.getEmpVO().getEmpId();
		}

		Map<String, Object> map = new HashMap<>();
		map.put("empId", targetEmpId);
		map.put("vctStts", "결재완료");

		return this.calendarService.vacationList(map);
	}

	/**
	 * 연차/출장 통계 데이터 조회
	 * @param auth
	 * @param empId
	 * @param yearMonth
	 * @return result
	 */
	@ResponseBody
	@GetMapping("/stats")
	public Map<String, Object> getStats(Authentication auth,
										@RequestParam(value="empId", required = false) String empId,
										@RequestParam(value="yearMonth", required = false) String yearMonth) {
		int targetEmpId;
		if (empId != null && !empId.isEmpty()) {
			targetEmpId = Integer.parseInt(empId);
		} else {
			CustomUser customUser = (CustomUser)auth.getPrincipal();
			targetEmpId = customUser.getEmpVO().getEmpId();
		}

		String currentMonth = (yearMonth != null && !yearMonth.isEmpty())
				? yearMonth
				: java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM"));

		log.info("1. 사번(empId): {}", targetEmpId);
		log.info("2. 날짜(currentMonth): {}", currentMonth);

		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("empId", targetEmpId);
		paramMap.put("currentMonth", currentMonth);

		Map<String, Object> result = new HashMap<>();
		result.put("vctStats", this.calendarService.countVacation(paramMap));
		result.put("bzStats", this.calendarService.countBizTrip(paramMap));

		return result;
	}



	// [AI] --------------------------------------------------------------------------------------------
	/**
	 * [AI 일정 등록]
	 * @param calendarVO
	 * @param auth
	 * @return response
	 */
	@ResponseBody
	@PostMapping("/addScheduleAi")
	public Map<String, Object> addScheduleAi(@RequestBody CalendarVO calendarVO, Authentication auth) {
		log.info("AI 일정 등록 요청 발생: {}", calendarVO);

		if(auth != null) {
			CustomUser customUser = (CustomUser) auth.getPrincipal();
			calendarVO.setEmpId(customUser.getEmpVO().getEmpId());
			log.info("AI 등록 주체 사번: {}", calendarVO.getEmpId());
		}

		if ("null".equals(calendarVO.getCalBgngTm())) {
			calendarVO.setCalBgngTm(null);
		}
		if ("null".equals(calendarVO.getCalEndTm())) {
			calendarVO.setCalEndTm(null);
		}

		if (calendarVO.getCalAllday() == null) {
			calendarVO.setCalAllday("N");
		}

		int result = this.calendarService.addSchedule(calendarVO);
		log.info("AI 일정 등록 결과: {}, 생성된 번호: {}", result, calendarVO.getCalNo());

		Map<String, Object> response = new HashMap<>();
		response.put("result", result > 0 ? "SUCCESS" : "FAIL");
		response.put("calNo", calendarVO.getCalNo());

		return response;
	}



	// [DashBoard] ----------------------------------------------------------------------------
	@ResponseBody
	@GetMapping("/todayList")
	public List<CalendarVO> todayList(Authentication auth) {
		if (auth == null) return new ArrayList<>();

		String empId = auth.getName();
		// 오늘 날짜만 필터링
		List<CalendarVO> allList = this.list(auth, empId);

		// 날짜 문자열
		String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

		return allList.stream().filter(vo -> {
							// 시작일 <= 오늘 <= 종료일 확인 (FullCalendar 처럼 종료일 전날까지 포함)
							String start = vo.getCalBgngDt();
							String end = vo.getCalEndDt();
							return start != null && start.compareTo(today) <= 0 && (end == null || end.compareTo(today) >= 0);
						})
						.collect(Collectors.toList());
						// collect(Collectors.toList()) :  스트림으로 가공된 데이터를 다시 리스트 형태로 변환하는 역할
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
