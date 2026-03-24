package kr.or.ddit.controller.admin.attendance;

import kr.or.ddit.service.*;
import kr.or.ddit.vo.AttendanceOutVO;
import kr.or.ddit.vo.AttendanceVO;
import kr.or.ddit.vo.DepartmentVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/admin/att")   // /admin << 써쥬셔야 합니당
@CrossOrigin(origins = "http://localhost:5173")  // 이것두 설정해쥬셔야 함!
@RestController
public class AttAdminController {
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
    @Autowired
    private DepartmentService departmentService;

    //부서 찾기
    @GetMapping("departments")
    public List<DepartmentVO> departments() {

        List<DepartmentVO> list = this.departmentService.allList();
        log.info("부서리스트 : {}", list);

        return list;
    }

    // 부서별 사원명 찾기
    @GetMapping("/dept-employees")
    public List<EmployeeVO> deptEmployees(@RequestParam(value = "deptNm") String deptNm) {
        log.info("부서별 사원 조회 시작! 부서명: {}", deptNm);
        // DB에서 이름이나 사원번호로 검색 (예: WHERE name LIKE %query%)
        List<EmployeeVO> list = this.attendanceService.getEmployeesByDept(deptNm);
        log.info("사원리스트 : {}", list);
        return this.attendanceService.getEmployeesByDept(deptNm);
    }

    // 사원들 통계
    @GetMapping("/monthly-report")
    public ResponseEntity<List<Map<String, Object>>> getMonthlyReport(@RequestParam String empId, @RequestParam String startDate,@RequestParam String endDate) {

        // 서비스 단에서 쿼리 실행 후 Map 리스트로 반환받음
        List<Map<String, Object>> result = attendanceService.getMonthlyAttendanceReport(empId, startDate, endDate);

        //  Chad는 데이터가 없어도 당황하지 않고 빈 리스트라도 쿨하게 쏴준다
        return ResponseEntity.ok(result);
    }
    // 사원들 통계
    @GetMapping("/monthly-report2")
    public ResponseEntity<List<Map<String, Object>>> getMonthlyReport2(@RequestParam String empId) {

        // 서비스 단에서 쿼리 실행 후 Map 리스트로 반환받음
        List<Map<String, Object>> result = attendanceService.getMonthlyAttendanceReport2(empId);

        //  Chad는 데이터가 없어도 당황하지 않고 빈 리스트라도 쿨하게 쏴준다
        return ResponseEntity.ok(result);
    }

    // 부서별 통계
    @GetMapping("/dept-stats")
    public ResponseEntity<List<DepartmentVO>> getDeptStats() {
        // 실시간 부서 통계 리스트 반환!
        List<DepartmentVO> stats = attendanceService.getDeptAttendanceStats();
        return ResponseEntity.ok(stats);
    }
    // 근태수정
    @PostMapping("update-record")
    public Map<String, Object> updateAttendance(@RequestBody AttendanceVO attendanceVO) {
        log.info("updateAttendance-> attendanceVO : {}", attendanceVO);
        Map<String, Object> response = new HashMap<>();

        try {
            int result = this.attendanceService.updateAttendance(attendanceVO);
            log.info("updateAttendance->result : {}", result);
            if (result > 0) {
                response.put("status", "success");
            } else {
                // 쿼리는 실행됐으나 업데이트된 행이 0개인 경우 (데이터가 없거나 조건이 안 맞음)
                response.put("status", "fail");
            }
        } catch (Exception e) {
            // DB 에러나 서버 로직 에러가 터졌을 때
            response.put("status", "error");
            e.printStackTrace(); // 서버 로그 확인용
        }

        return response;
    }

    // 근태삭제
    @PostMapping("delete-record")
    public Map<String, Object> deleteAttendance(@RequestBody AttendanceVO attendanceVO) {
        log.info("deleteAttendance-> attendanceVO : {}", attendanceVO);
        Map<String, Object> response = new HashMap<>();

        try {
            int result = this.attendanceService.deleteAttendance(attendanceVO);
            log.info("updateAttendance->result : {}", result);
            if (result > 0) {
                response.put("status", "success");
            } else {
                // 쿼리는 실행됐으나 업데이트된 행이 0개인 경우 (데이터가 없거나 조건이 안 맞음)
                response.put("status", "fail");
            }
        } catch (Exception e) {
            // DB 에러나 서버 로직 에러가 터졌을 때
            response.put("status", "error");
            e.printStackTrace(); // 서버 로그 확인용
        }

        return response;
    }
    //외출 수정
    @PostMapping("update-out-record")
    public Map<String, Object> updateAttendanceOut(@RequestBody AttendanceOutVO attendanceOutVO) {
        log.info("updateAttendanceOut-> attendanceOutVO : {}", attendanceOutVO);
        Map<String, Object> response = new HashMap<>();

        try {
            int result = this.attendanceOutService.updateAttendance(attendanceOutVO);
            log.info("updateAttendanceOut->result : {}", result);
            if (result > 0) {
                response.put("status", "success");
            } else {
                // 쿼리는 실행됐으나 업데이트된 행이 0개인 경우 (데이터가 없거나 조건이 안 맞음)
                response.put("status", "fail");
            }
        } catch (Exception e) {
            // DB 에러나 서버 로직 에러가 터졌을 때
            response.put("status", "error");
            e.printStackTrace(); // 서버 로그 확인용
        }

        return response;
    }
    // 외출삭제
    @PostMapping("delete-out-record")
    public Map<String, Object> deleteAttendanceOut(@RequestBody AttendanceOutVO attendanceOutVO) {
        log.info("deleteAttendanceOut-> attendanceOutVO : {}", attendanceOutVO);
        Map<String, Object> response = new HashMap<>();

        try {
            int result = this.attendanceOutService.deleteAttendance(attendanceOutVO);
            log.info("deleteAttendanceOut->result : {}", result);
            if (result > 0) {
                response.put("status", "success");
            } else {
                // 쿼리는 실행됐으나 업데이트된 행이 0개인 경우 (데이터가 없거나 조건이 안 맞음)
                response.put("status", "fail");
            }
        } catch (Exception e) {
            // DB 에러나 서버 로직 에러가 터졌을 때
            response.put("status", "error");
            e.printStackTrace(); // 서버 로그 확인용
        }

        return response;
    }


}
