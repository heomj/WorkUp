package kr.or.ddit.controller.admin.salary;

import kr.or.ddit.service.SalaryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/admin/salary")   // /admin << 써쥬셔야 합니당
@CrossOrigin(origins = "http://localhost:5173")  // 이것두 설정해쥬셔야 함!
@RestController
public class SalaryController {
    @Autowired
    private SalaryService salaryService;

    /**
     * 급여 목록 조회 (가계산 포함)
     * @param searchMonth 조회할 년-월 (예: "2026-03")
     * @return 계산된 급여 리스트
     */
    @GetMapping("/list")
    public List<Map<String, Object>> getSalaryList(@RequestParam("searchMonth") String searchMonth) {
        log.info("급여 목록 조회 요청 - 조회월: {}", searchMonth);

        List<Map<String, Object>> list = salaryService.selectSalaryList(searchMonth);

        log.info("조회 결과 건수: {}건", list.size());
        return list;
    }

    @PostMapping("/pay")
    @ResponseBody // 일반 Controller라면 붙여주고, RestController면 생략 가능
    public Map<String, Object> processSalaryPayment(@RequestBody Map<String, Object> salaryData) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 1. 서비스 로직 수행
            int result = salaryService.insertSalary(salaryData);

            // 2. 성공 데이터 담기
            if (result > 0) {
                response.put("status", "success");
                response.put("message", salaryData.get("empNm") + "님의 급여 지급이 완료되었습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();

            // 3. 실패 데이터 담기
            response.put("status", "error");
            response.put("message", "서버 오류: " + e.getMessage());
        }

        return response; // 그냥 맵 자체를 던짐!
    }

    /**
     * 부서별 평균 급여 통계 조회
     * @param searchMonth 조회할 년-월 (예: "2026-03")
     * @return 부서명(deptNm), 평균급여(avgPayment), 기준월(thisMonth)을 담은 맵 리스트
     */
    @GetMapping("/getStatsAxios")
    public ResponseEntity<Map<String, Object>> getStatsAxios(@RequestParam String searchMonth) {
        // 1. 부서별 평균 데이터 가져오기
        List<Map<String, Object>> avgData = salaryService.getDeptAvgPayment(searchMonth);
        // 2. 직급별 데이터 (가로 바 차트용 - 형이 방금 짠 쿼리)
        List<Map<String, Object>> rankData = salaryService.getRankAvgPayment(searchMonth);

        Map<String, Object> response = new HashMap<>();
        response.put("donutData", avgData);
        response.put("rankData", rankData);

        return ResponseEntity.ok(response); // 객체 형태로 리턴!
    }
}
