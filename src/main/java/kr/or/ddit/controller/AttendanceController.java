package kr.or.ddit.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kr.or.ddit.service.*;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.ModelAndView;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Controller
@RequestMapping("/attendance")
public class AttendanceController {

    @Autowired
    private AttendanceOutService attendanceOutService;
    @Autowired
    private AttendanceWorkStatusService attendanceWorkStatusService;
    @Autowired
    private AttendanceService attendanceService;
    @Autowired
    private EmployeeService employeeService;
    @Autowired
    private AttendanceStatusService attendanceStatusService;


    private final String CLIENT_ID = "";
    private final String REDIRECT_URI = "";

    // PC와 폰이 서로 다른 세션을 가져도 여기서 데이터를 공유
    private static final Map<String, String> authCache = new ConcurrentHashMap<>();

    /**
     * [STEP 1] 폰에서 QR 스캔 시 호출되는 메인 콜백
     * 클래스 레벨 @RequestMapping("/attendance")와 결합되어 주소는 /attendance 가 됨
     */
    @GetMapping("")
    public ModelAndView kakaoCallback(@RequestParam(value = "code", required = false) String code,
                                      HttpSession session,
                                      HttpServletRequest request) {
        ModelAndView mav = new ModelAndView();

        // 1. 코드 유효성 검사
        if (code == null || code.isEmpty()) {
            log.warn("⚠️ 카카오 인증 코드가 누락되었습니다.");
            mav.setViewName("attendance/error");
            return mav;
        }

        log.info("🚀 1. 카카오 인증 코드 획득: {}", code);

        try {
            // 2. 카카오 Access Token 받기
            RestTemplate rt = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

            MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
            params.add("grant_type", "authorization_code");
            params.add("client_id", CLIENT_ID);
            params.add("redirect_uri", REDIRECT_URI);
            params.add("code", code);

            HttpEntity<MultiValueMap<String, String>> kakaoTokenRequest = new HttpEntity<>(params, headers);
            ResponseEntity<String> response = rt.exchange("https://kauth.kakao.com/oauth/token", HttpMethod.POST, kakaoTokenRequest, String.class);

            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonNode = objectMapper.readTree(response.getBody());
            String accessToken = jsonNode.get("access_token").asText();

            // 3. 카카오 사용자 프로필(이메일) 가져오기
            HttpHeaders headers2 = new HttpHeaders();
            headers2.add("Authorization", "Bearer " + accessToken);
            headers2.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

            HttpEntity<MultiValueMap<String, String>> kakaoProfileRequest = new HttpEntity<>(headers2);
            ResponseEntity<String> response2 = rt.exchange("https://kapi.kakao.com/v2/user/me", HttpMethod.POST, kakaoProfileRequest, String.class);

            JsonNode userNode = objectMapper.readTree(response2.getBody());
            String email = userNode.get("kakao_account").get("email").asText();
            log.info("🚀 2. 카카오 이메일 확인: {}", email);

            // 4. DB에서 사원 정보 조회
            EmployeeVO empVO = employeeService.findEmployeeByEmail(email);

            if (empVO != null) {
                log.info("✅ 3. 사원 매칭 성공: {} ({})", empVO.getEmpNm(), empVO.getEmpId());

                // 5. 스프링 시큐리티 수동 인증 처리
                CustomUser userDetails = new CustomUser(empVO);
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

                // SecurityContext에 설정
                SecurityContextHolder.getContext().setAuthentication(authentication);

                // 세션에 Security Context 강제 주입 (이게 없으면 폰 세션 유지가 안 됨)
                request.getSession().setAttribute("SPRING_SECURITY_CONTEXT", SecurityContextHolder.getContext());

                // 6. 근태 처리 로직 (이미 출근했는지 확인)
                int empId = empVO.getEmpId();
                int isAttended = this.attendanceService.checkTodayAttendance(empId);

                if (isAttended == 0) {
                    AttendanceVO attendanceVO = new AttendanceVO();
                    attendanceVO.setEmpId(empId);
                    this.attendanceService.insertAttendance(attendanceVO);
                    log.info("✅ 4. 사번 {}번, 출근 처리 완료!", empId);

                    // 7. 전역 캐시에 성공 상태 기록 (PC의 Axios가 이걸 보고 창을 닫음)
                    authCache.put("status", "SUCCESS");
                    authCache.put("email", email);
                    authCache.put("empId", String.valueOf(empId));

                    mav.addObject("userEmail", email);
                    mav.setViewName("attendance/mobileSuccess");
                } else {
                    log.info("⚠️ 이미 출근 처리된 사원입니다.");
                    // PC 화면용: 이미 찍힌 사람이니 "ALREADY" 상태를 보냄
                    authCache.put("status", "ALREADY");
                    authCache.put("email", email);

                    // 모바일용: "이미 완료" 페이지 또는 에러 메시지 처리
                    mav.addObject("userEmail", email);
                    mav.addObject("errorMsg", "이미 오늘 출근 처리가 완료되었습니다.");
                    mav.setViewName("attendance/moblieFail");
                }

            } else {
                // DB에 이메일이 없는 경우
                log.error("❌ 3. 등록되지 않은 이메일 사원: {}", email);
                mav.setViewName("attendance/error");
            }

        } catch (Exception e) {
            log.error("🚨 카카오 인증 또는 데이터 처리 중 중대한 에러 발생!", e);
            mav.setViewName("attendance/error");
        }
        log.info("🚀 [최종 점검] 캐시에 들어간 상태: {}", authCache.get("status"));
        log.info("🚀 [최종 점검] 캐시에 들어간 이메일: {}", authCache.get("email"));
        return mav;
    }

    @GetMapping("/checkStatus")
    @ResponseBody
    public Map<String, String> checkStatus(Authentication auth) {
        Map<String, String> result = new HashMap<>();

        // 1. 시큐리티 컨텍스트에서 현재 PC에 로그인된 사번 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        String myEmpId = String.valueOf(customUser.getEmpVO().getEmpId());

        // 2. 공유 게시판에서 상태와 사번 읽기
        String sharedStatus = authCache.get("status");
        String sharedEmail = authCache.get("email");
        String sharedEmpId = authCache.get("empId"); // 폰에서 넣어준 사번

        log.info("📡 [PC 체크] 내 사번: {}, 게시판 사번: {}, 상태: {}", myEmpId, sharedEmpId, sharedStatus);

        // 🚀 [Giga-Chad Logic] 게시판에 정보가 있고, 그게 '내 사번'이랑 일치할 때만 SUCCESS를 준다!
        if ("SUCCESS".equals(sharedStatus) && myEmpId.equals(sharedEmpId)) {
            result.put("status", "SUCCESS");
            result.put("email", sharedEmail);
            result.put("empId", sharedEmpId);

            // ✅ 내가 확인했으니까 이제 게시판 비워도 됨!
            authCache.clear();
            log.info("✅ 내 출근 확인 완료! 게시판 청소 ");

        } else if ("ALREADY".equals(sharedStatus) && myEmpId.equals(sharedEmpId)) {
            result.put("status", "ALREADY");
            authCache.clear(); // 이미 된 것도 확인했으니 비우기!
        } else {
            // 내 정보가 아니거나 아직 안 찍었으면 대기!

            result.put("status", "WAITING");
        }

        return result;
    }

    // --- 퇴근 도장 찍기  ---
    @ResponseBody
    @PostMapping("/end")
    public Map<String, Object> checkOut(Authentication auth) {
        Map<String, Object> response = new HashMap<>();

        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        log.info("로그인된 퇴근 신청 사번: {}", empId);
        // 1. 퇴근 서비스 호출
        int result = attendanceService.updateCheckout(empId);

        if (result > 0) {
            response.put("status", "SUCCESS");
            response.put("message", "오늘 하루도 고생하셨습니다.");
        } else {
            response.put("status", "FAIL");
            response.put("message", "퇴근 처리에 실패했습니다. 관리자에게 문의해주세요.");
        }

        return response;
    }


    // 1. 외출 신청 (Insert)
    @PostMapping("/out/start")
    @ResponseBody
    public Map<String, Object> startOuting(@RequestBody AttendanceOutVO outVO,
                                           Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        outVO.setEmpId(empId);
        log.info("외출 시작 신청 데이터: {}", outVO);

        int result = this.attendanceOutService.startOuting(outVO);
        Map<String, Object> response = new HashMap<>();

        if (result > 0) {
            response.put("status", "SUCCESS");
            response.put("message", "외출 처리가 완료되었습니다.");
        } else {
            response.put("status", "FAIL");
            response.put("message", "DB 저장에 실패했어. 데이터 확인해봐!");
        }

        return response;
    }

    // 2. 외출 복귀 (Update)
    @PostMapping("/out/end")
    @ResponseBody
    public Map<String, Object> endOuting(Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        AttendanceOutVO outVO = new AttendanceOutVO();
        outVO.setEmpId(empId);
        log.info("외출 복귀 신청 데이터: {}", outVO.getEmpId());

        int result = this.attendanceOutService.endOuting(outVO);
        Map<String, Object> response = new HashMap<>();

        if (result > 0) {
            response.put("status", "SUCCESS");
            response.put("message", "외출 처리가 완료되었습니다.");
        } else {
            response.put("status", "FAIL");
            response.put("message", "DB 저장에 실패했어. 데이터 확인해봐!");
        }

        return response;
    }

    //현재 근무 상태값 가져오기
    @GetMapping("/currentStatus")
    @ResponseBody
    public Map<String, Object> getCurrentStatus(Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        log.info("조회 요청온 ID: {}", empId);

        // DB에서 상태값 조회
        String status = this.attendanceWorkStatusService.getWorkStatus(empId);
        Map<String, Object> response = new HashMap<>();
        response.put("status", status != null ? status : "출근 전");

        return response;

    }

    //지각/근무시간/연차 확인
    @GetMapping("/getDashboardSummary")
    @ResponseBody
    public Map<String, Object> getDashboardSummary(Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();

        // 2. 서비스 호출 (Mapper에서 resultMap으로 가져온 데이터)
        Map<String, Object> result = attendanceStatusService.getDashboardSummary(empId);
        log.info("getDashboardSummary->result : {}", result);

        // 3. 만약 데이터가 없으면 기본값 세팅
        if (result == null || result.isEmpty()) {
            result = new HashMap<>();
            result.put("attLateCt", 0);      // 이달 지각 횟수
            result.put("attMonTime", 0);     // 이달 근무 시간
            result.put("annLeaveRemain", 15); // 잔여 연차 (ANNUAL_LEAVE 테이블 기준)
            result.put("VCT_COUNT", 0);    //  추가: 이번 달 휴가 0건
            result.put("BZTRP_COUNT", 0);  //  추가: 이번 달 출장 0건
        }

        return result;
    }

    //  휴가 신청 인서트
    @PostMapping("/insertVacation")
    @ResponseBody
    public Map<String, Object> insertVacation(@RequestBody VacationDocumentVO vacationDoc,
                                              Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        vacationDoc.setEmpId(empId);
        log.info("insertVacation->vacationDoc {}", vacationDoc);

        Map<String, Object> response = new HashMap<>();
        int result = attendanceService.insertVacation(vacationDoc);

        if (result > 0) {
            response.put("status", "success");
            response.put("message", "휴가 신청 완료! 결재신청을 진행하셔야 승인이 가능합니다.");
        } else {
            response.put("status", "fail");
            response.put("message", "오류 발생!");
        }
        return response;
    }

    // 출장 신청 인서트
    @PostMapping("/insertTrip")
    @ResponseBody
    public Map<String, Object> insertTrip(@RequestBody TripDocumentVO tripDoc,
                                          Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        tripDoc.setEmpId(empId);
        log.info("출장 슛! ->{}", tripDoc);

        Map<String, Object> response = new HashMap<>();
        int result = attendanceService.insertTrip(tripDoc);

        if (result > 0) {
            response.put("status", "success");
            response.put("message", "출장 신청 완료! 결재신청을 진행하셔야 승인이 가능합니다.");
        } else {
            response.put("status", "fail");
            response.put("message", "오류 발생!");
        }
        return response;
    }

    //  초과근무 신청 인서트
    @PostMapping("/insertOvertime")
    @ResponseBody
    public Map<String, Object> insertOvertime(@RequestBody OvertimeDocumentVO overtimeDoc,
                                              Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        overtimeDoc.setEmpId(empId);
        log.info("초과근무 슛! -> {}", overtimeDoc);

        Map<String, Object> response = new HashMap<>();
        int result = attendanceService.insertOvertime(overtimeDoc);

        if (result > 0) {
            response.put("status", "success");
            response.put("message", "초과근무 신청 완료! 결재신청을 진행하셔야 승인이 가능합니다.");
        } else {
            response.put("status", "fail");
            response.put("message", "오류 발생!");
        }
        return response;
    }

    // 달력에 근태리스트 불러오기
    @GetMapping("/calenderList")
    @ResponseBody
    public Map<String, Object> attendanceCalender(Authentication auth,
                                                  @RequestParam(value = "year", required = false) String year,
                                                  @RequestParam(value = "month", required = false) String month) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        // 만약 파라미터가 없으면 현재 날짜 기준으로 세팅
        if (year == null || month == null) {
            LocalDate now = LocalDate.now();
            year = String.valueOf(now.getYear());
            month = String.format("%02d", now.getMonthValue());
        }

        List<AttendanceVO> attendanceList = attendanceService.getAttendanceByMonth(empId, year, month);
        log.info("attendanceCalender->attendanceList : {}", attendanceList);

        //  결재 완료된 신청건(휴가, 출장, 초과근무) 싹 다 긁어오기
        List<AttendanceTypeVO> eventList = attendanceService.getApprovedCalendarEvents(empId, year, month);

        Map<String, Object> map = new HashMap<String, Object>();
        map.put("attendanceList", attendanceList);
        map.put("eventList", eventList);

        return map;
    }

    //통합목록조회 and 페이지네이션
    // 비동기(AJAX) 전용 목록 조회
    @ResponseBody
    @RequestMapping(value = "/applicationList", method = RequestMethod.GET)
    public ArticlePage<AttendanceTypeVO> applicationList(
            @RequestParam(value = "currentPage", required = false, defaultValue = "1") int currentPage,
            @RequestParam(value = "mode", required = false, defaultValue = "") String mode,
            @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
            Authentication auth) {

        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();

        Map<String, Object> map = new HashMap<>();
        map.put("currentPage", currentPage);
        map.put("mode", mode);
        map.put("keyword", keyword);
        map.put("empId", empId);

        int size = 10;
        int total = this.attendanceService.getTotalApplication(map);
        List<AttendanceTypeVO> list = this.attendanceService.getApplicationList(map);

        //  ArticlePage 그대로 생성
        ArticlePage<AttendanceTypeVO> articlePage =
                new ArticlePage<>(total, currentPage, size, keyword, list);
        articlePage.setMode(mode);

        log.info("비동기 리스트 호출 성공! -> {}", articlePage);

        return articlePage;
    }

    //신청서 삭제
    @ResponseBody
    @PostMapping("/deleteApplication")
    public String deleteApplication(@RequestBody Map<String, Integer> payload, Authentication auth) {
        int attTypeId = payload.get("attTypeId"); // JSON의 Key값과 맞춰야 함!
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();
        log.info("신청서 삭제 요청 empId: {}, attTypeId: {}", empId, attTypeId);

        int result = attendanceService.deleteApplication(empId, attTypeId);

        return result > 0 ? "success" : "fail";
    }

    //신청서 결재
    @ResponseBody
    @PostMapping("/updateStatus")
    public String updateStatus(@RequestBody Map<String, Integer> payload, Authentication auth) {
        int attTypeId = payload.get("attTypeId");
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();

        log.info("결재 신청 요청(상태 업데이트) empId: {}, attTypeId: {}", empId, attTypeId);

        int result = attendanceService.updateStatusToPending(empId, attTypeId);

        return result > 0 ? "success" : "fail";
    }

    /// ////////근태 리메이크 추가 호출 시작/////////////
    //현재 근무 상태값 가져오기
    @GetMapping("/getTodayDetail")
    @ResponseBody
    public Map<String, Object> getTodayDetail(Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        log.info("조회 요청온 ID: {}", empId);

        // DB에서 상태값 조회
        AttendanceVO attendanceVO = this.attendanceService.getTodayDetail(empId);
        AttendanceOutVO outVO = this.attendanceService.getTodayOutDetail(empId);
        Map<String, Object> map = new HashMap<>();
        map.put("attendance", attendanceVO);
        map.put("outInfo", outVO);


        return map;

    }

    /// ////////근태 리메이크 추가 호출 끝/////////////
    /// ////////데쉬보드/////////////
    @GetMapping("/teamStatus")
    @ResponseBody
    public List<EmployeeVO> teamStatus(Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        log.info("조회 요청온 ID: {}", empId);

        // DB에서 상태값 조회
        List<EmployeeVO> list = this.attendanceService.teamStatus(empId);

        return list;

    }
}