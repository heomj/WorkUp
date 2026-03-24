package kr.or.ddit.service;

import kr.or.ddit.vo.*;
import kr.or.ddit.vo.project.ProjectVO;

import java.util.List;
import java.util.Map;

public interface BudgetService {




    //관리자) 예산 등록(혹은 추가)하기
    public void insertNewBudget(BudgetMasterVO payload);

    //담당자 검색하기
    public List<EmployeeVO> searchBudgetEmp(Map<String, Object> map);


    //예산 리스트 받아오기..
    public List<BudgetDetailVO> getBudgetList(int year);


    //예산 소진률(차트)
    public List<Map<String, Object>> getUsageStats(int year);

    //부서별 예산 소진(차트)
    public List<Map<String, Object>> getMonthlyStats(int year);

    //로그 리스트
    public List<BudgetLogVO> allLogList(Map<String, Object> map);

    //(사용자) 부서 대시보드 차트
    public Map<String, Object> getDeptBudgetSum(int deptCd, int currentYear);
}
