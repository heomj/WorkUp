package kr.or.ddit.controller.admin.budget;

import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.service.BudgetService;
import kr.or.ddit.service.avatarService;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/admin/budget")   // /admin << 써쥬셔야 합니당
@CrossOrigin(origins = "http://localhost:5173")  // 이것두 설정해쥬셔야 함!
@RestController
public class BudgetAdminController {

    @Autowired
    BudgetService budgetService;


    /**
     * 관리자) 예산 등록하기
     * @param payload 예산 등록 정보
     * @return
     */
    @ResponseBody
    @PostMapping("/allocate")
    public ResponseEntity<String> allocate(@RequestBody BudgetMasterVO payload){

        log.info("신규 예산 배정 요청 데이터: {}", payload);

        try {
            // 서비스로 데이터 넘기기
            this.budgetService.insertNewBudget(payload);
            return ResponseEntity.ok("success");

        } catch (Exception e) {
            log.error("예산 배정 중 오류 발생!", e);
            return ResponseEntity.internalServerError().body("fail");
        }
    }


    /**
     * 관리자 페이지) 예산에서 전자결재 담당자 선택하기(검색)
     * @param keyword 검색어
     * @return 담당자 검색 결과 List
     */
    @ResponseBody
    @GetMapping("/searchBudgetEmp")
    public List<EmployeeVO> searchBudgetEmp(
            @RequestParam("keyword") String keyword
    ){

        log.info("관리자 list->keyword : " + keyword);//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("keyword", keyword); // 첫 접속시 ""

        map.put("url", "");

        List<EmployeeVO> EmployeeVOList = this.budgetService.searchBudgetEmp(map);

        log.info("관리자 예산 담당자 검색.. list->searchBudgetEmp : " + EmployeeVOList);

        //결재문서 리스트를 리턴
        return EmployeeVOList;
    }


    //예산 목록
    @ResponseBody
    @GetMapping("/list")
    public List<BudgetDetailVO> getBudgetList(@RequestParam("year") int year) {

        log.info("예산 목록 조회 요청 연도: {}", year);

        // 서비스 호출하여 결과 리턴
        return this.budgetService.getBudgetList(year);
    }


    @GetMapping("/stats/usage")
    public List<Map<String, Object>> getUsageStats(@RequestParam("year") int year) {
        return this.budgetService.getUsageStats(year);
    }

    @GetMapping("/stats/monthly")
    public List<Map<String, Object>> getMonthlyStats(@RequestParam("year") int year) {
        return this.budgetService.getMonthlyStats(year);
    }


    //관리자 로그보기
    @ResponseBody
    @PostMapping("/logs")
    public List<BudgetLogVO> getLogList(
            @RequestBody BudgetLogVO budgetLogVO
    ){


        log.info("관리자 list->budgetLogVO : " + budgetLogVO);
        log.info("관리자 list->keyword : " + budgetLogVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("keyword", budgetLogVO.getKeyword()); // 첫 접속시 ""
        map.put("bgtChgSe", budgetLogVO.getBgtChgSe()); // 첫 접속시 ""
        map.put("bgtYr", budgetLogVO.getBgtYr()); // 첫 접속시 ""

        map.put("deptCd", budgetLogVO.getDeptCd()); // 부서코드

        List<BudgetLogVO> budgetLogList = this.budgetService.allLogList(map);
        log.info("관리자페이지에서 로그 전체(검색) list->BudgetLogList : " + budgetLogList);

        //로그 리스트 넘김
        return budgetLogList;
    }








}

