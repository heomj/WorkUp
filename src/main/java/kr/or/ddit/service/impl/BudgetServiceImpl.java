package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.BudgetMapper;
import kr.or.ddit.service.BudgetService;
import kr.or.ddit.vo.BudgetDetailVO;
import kr.or.ddit.vo.BudgetLogVO;
import kr.or.ddit.vo.BudgetMasterVO;
import kr.or.ddit.vo.EmployeeVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class BudgetServiceImpl implements BudgetService {


    @Autowired
    private BudgetMapper budgetMapper;



    @Transactional // 하나라도 실패하면 전체 롤백!
    @Override
    public void insertNewBudget(BudgetMasterVO vo) {

        // 1. 마스터 테이블 INSERT (총액, 연도, 부서)
        this.budgetMapper.mergeBudgetMaster(vo);

        // 2. 방금 작업한 해당 부서/연도의 마스터 PK(BGT_M_CD)를 조회해 옵니다!
        Integer currentBgtMCd = budgetMapper.findBgtMCd(vo.getDeptCd(), vo.getBgtYr());

        // 찾아온 마스터 코드를 세팅 (나중에 로그 찍을 때 쓰기 위함)
        vo.setBgtMCd(currentBgtMCd);

        // 3. 디테일 MERGE (비목 개수만큼 반복)
        for (BudgetDetailVO detail : vo.getDetails()) {
            // 찾아온 마스터 코드를 디테일에 같이 넘겨줍니다.
            budgetMapper.mergeBudgetDetail(currentBgtMCd, detail);
        }


        // 3. 예산 변경 로그 테이블 INSERT (결재번호, 변경사유 등등.. 기록)
        this.budgetMapper.insertBudgetLog(vo);
    }

    //담당자 검색하기
    @Override
    public List<EmployeeVO> searchBudgetEmp(Map<String, Object> map) {
        return this.budgetMapper.searchBudgetEmp(map);
    }


    //예산 목록 불러오기
    @Override
    public List<BudgetDetailVO> getBudgetList(int year) {
        return this.budgetMapper.getBudgetList(year);
    }

    //부서별 예산 소진 현황(차트)
    @Override
    public List<Map<String, Object>> getUsageStats(int year) {
        return this.budgetMapper.getUsageStats(year);
    }

    //부서별 예산 사용량(차트)
    @Override
    public List<Map<String, Object>> getMonthlyStats(int year) {
        return this.budgetMapper.getMonthlyStats(year);
    }

    //로그 리스트
    @Override
    public List<BudgetLogVO> allLogList(Map<String, Object> map) {
        return this.budgetMapper.allLogList(map);
    }


    // 부서 예산 차트 구하기
    @Override
    public Map<String, Object> getDeptBudgetSum(int deptCd, int currentYear) {
        return this.budgetMapper.getDeptBudgetSum(deptCd ,currentYear);
    }

}
