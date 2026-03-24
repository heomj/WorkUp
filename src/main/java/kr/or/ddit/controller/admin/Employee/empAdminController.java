package kr.or.ddit.controller.admin.Employee;

import kr.or.ddit.service.EmployeeService;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.util.JwtUtil;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/admin/emp")
@CrossOrigin(origins = "http://localhost:5173")
@RestController
public class empAdminController {

    @Autowired
    EmployeeService service;

    @Value("${file.prfFolder}")
    private String prfFolder;

    @Autowired
    JwtUtil jwtutill;

    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    @Autowired
    private AlarmController alarmController;

    @GetMapping("/check-auth")
    public ResponseEntity<String> checkAuth(Authentication authentication) {
        // 1. 시큐리티 세션에 인증 정보가 있는지 확인
        if (authentication != null && authentication.isAuthenticated()) {
            // 인증 성공: 리액트의 .then()으로 이동
            System.out.println("관리자 인증 성공: " + authentication.getName());
            return ResponseEntity.ok("success");
        }

        // 2. 인증 정보가 없으면 401 에러 반환: 리액트의 .catch()로 이동
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("fail");
    }

    // 사원들 정보 다 가져오기 (관리자에서)
    @GetMapping("/emplist")
    public List<EmployeeVO> emplist () {
        List<EmployeeVO> emplist = this.service.adminemplist();

        log.info("사우너 정보 : {}", emplist);
        return emplist;
    }

    // 사원 부서 이동 시키기
    @ResponseBody
    @PatchMapping("/updateDept")
    public String updateDept(@RequestBody EmployeeVO vo){
        log.info("사원 id : {}", vo.getEmpId());
        log.info("부서코드 : {}", vo.getDeptCd());

        int result =  this.service.updateDept(vo);

        if(result > 0) {
            // 알람 처리 해볼까..나
            AlarmVO alarmVO = new AlarmVO();
            int firstApproverId = vo.getEmpId();  // 부서 이동된 사원 ID

            // 한 명이지만 .. List에 담기 ㅇ_ㅇ
            List<Integer> empList = new ArrayList<>();
            empList.add(firstApproverId);

            alarmVO.setAlmMsg("인사발령에 따른 부서 재배치 안내드립니다.");
            log.info("vo값 머임?  {}", vo);
            alarmVO.setAlmDtl(
                    "<span class=\"fw-bold text-primary\">'개발 "+vo.getDeptCd()+"'팀</span>에 재배치되었습니다.");
            alarmVO.setAlmRcvrNos(empList);
            alarmVO.setAlmIcon("info");

            // 파라미터 순서: 관리자(empId), 알람VO, 상세이동URL, 알람타입(알람 앞에 붙는 구분메시지)
            String alarmRes = this.alarmController.sendAlarm(
                    12,  // 관리자인뎅..
                    alarmVO,
                    "/main",
                    "부서이동"
            );

            return "success";
        } else {
            return "fail";
        }
    }

    // 사원 직급 변경하기
    @ResponseBody
    @PatchMapping("/updatejbgd")
    public String updatejbgd(@RequestBody EmployeeVO vo){
        log.info("사원 id : {}", vo.getEmpId());
        log.info("부서코드 : {}", vo.getDeptCd());
        log.info("변경할 직급 : {}", vo.getEmpJbgd());

        int result =  this.service.updatejbgd(vo);

        if(result > 0) {
            // 알람 처리 해볼까..나
            AlarmVO alarmVO = new AlarmVO();
            int firstApproverId = vo.getEmpId();  // 부서 이동된 사원 ID

            // 한 명이지만 .. List에 담기 ㅇ_ㅇ
            List<Integer> empList = new ArrayList<>();
            empList.add(firstApproverId);

            alarmVO.setAlmMsg("인사 발령에 따른 직급 변경 안내드립니다.");
            log.info("vo값 머임?  {}", vo);
            alarmVO.setAlmDtl(
                    "<span class=\"fw-bold text-primary\">'개발 "+ vo.getDeptCd() +"'팀</span>의 " +
                            "<span class=\"fw-bold text-success\">" + vo.getEmpJbgd() + "</span>(으)로 변경되었습니다."
            );
            alarmVO.setAlmRcvrNos(empList);
            alarmVO.setAlmIcon("info");

            // 파라미터 순서: 관리자(empId), 알람VO, 상세이동URL, 알람타입(알람 앞에 붙는 구분메시지)
            String alarmRes = this.alarmController.sendAlarm(
                    12,  // 관리자인뎅..
                    alarmVO,
                    "/main",
                    "부서이동"
            );

            return "success";
        } else {
            return "fail";
        }
    }




    // 관리자 정보 가져오기
    @GetMapping("/profile")
    public EmployeeVO profile(@CookieValue(name = "admintoken", required = false) String token){
        String userId = jwtutill.getUserIdFromToken(token);
        log.info("관리자 ID {}",userId);


        EmployeeVO vo = this.service.whoadmin(Integer.parseInt(userId));


        return vo;
    }

    // 프로필 사진
    @GetMapping("/displayPrf")
    public byte[] display(@RequestParam("fileName") String fileName) {

        if (fileName == null) {
            log.error("파일이 존재하지 않습니다: {}");

            return null;
        }

        try {
            // 1. 한글 파일명 디코딩 (필수!)
            String decodedName = java.net.URLDecoder.decode(fileName, "UTF-8");

            // 2. 경로 조합 (슬래시 누락 방지)
            String path = prfFolder + (prfFolder.endsWith("/") ? "" : "/") + decodedName;

            log.info("이미지 로드 경로: {}", path);

            // 3. 파일을 바이트 배열로 읽어서 전송
            // 이렇게 하면 스프링이 자동으로 적절한 Content-Type을 시도합니다.
            return java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(path));

        } catch (Exception e) {
            log.error("이미지 표시 실패", e);
            return null; // 에러 시 엑박 방지를 위해 null 리턴
        }
    }


    // 사원 등록하기
    @PostMapping("/insert")
    public EmployeeVO insert(@RequestBody EmployeeVO vo) {
        log.info("누구 등록하니 ? {}", vo);

        String deptName = vo.getDeptNm();


        switch (deptName) {
            case "개발1팀": vo.setDeptCd(1); break;
            case "개발2팀": vo.setDeptCd(2); break;
            case "개발3팀": vo.setDeptCd(3); break;
            case "영업팀": vo.setDeptCd(4); break;
            case "경영지원팀": vo.setDeptCd(5); break;
        }

        String pw = bCryptPasswordEncoder.encode(vo.getEmpPw());
        vo.setEmpPw(pw); // 암호화 하기

        int result = this.service.insert(vo);

        if(result > 0) {
            log.info("머징 , {}",vo);
            vo.setEmpStts("Y");
            return vo;
        } else {
            return vo;
        }
    }

    // 상태 변경하기 (재직, 퇴직)
    @PatchMapping("/sttschg")
    public String sttschg(@RequestBody EmployeeVO vo){

        log.info("누구의 상태를 바꾸니 ? : {}", vo);
        int result = this.service.sttschg(vo);

        if(result > 0) {
            return "ok";
        }
        else  {
            return "no";
        }
    }

    // 사원 차트 데이터 가져오깅
    @GetMapping("/empstts")
    public List<Map<String,Object>> empstts () {
        log.info("차트용");

        List<Map<String,Object>> list = this.service.empstts();

        return list;
    }

}
