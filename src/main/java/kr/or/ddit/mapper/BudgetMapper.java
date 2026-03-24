package kr.or.ddit.mapper;

import kr.or.ddit.vo.BudgetDetailVO;
import kr.or.ddit.vo.BudgetLogVO;
import kr.or.ddit.vo.BudgetMasterVO;
import kr.or.ddit.vo.EmployeeVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface BudgetMapper {

    //예산 생성
    public void mergeBudgetMaster(BudgetMasterVO vo);

    // 🌟 [추가] 부서코드와 연도로 마스터 PK(BGT_M_CD) 찾아오기
    public Integer findBgtMCd(@Param("deptCd") int deptCd, @Param("bgtYr") int bgtYr);

    // 2. 디테일 UPSERT
    public void mergeBudgetDetail(@Param("bgtMCd") Integer bgtMCd, @Param("detail") BudgetDetailVO detail);


    //로그 등록
    public void insertBudgetLog(BudgetMasterVO vo);


    //담당자 검색하기
    public List<EmployeeVO> searchBudgetEmp(Map<String, Object> map);

    //예산 리스트 받아오기..
    public List<BudgetDetailVO> getBudgetList(int year);

    //예산 소진률(차트) 오류 무시 가능
    public List<Map<String, Object>> getUsageStats(int year);

    //부서별 예산 소진(차트) 오류 무시 가능
    public List<Map<String, Object>> getMonthlyStats(int year);

    //로그 리스트
    public List<BudgetLogVO> allLogList(Map<String, Object> map);

    //(사용자) 부서 대시보드 차트
    public Map<String, Object> getDeptBudgetSum(@Param("deptCd") int deptCd,
                                                @Param("currentYear") int currentYear);

}
