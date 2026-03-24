package kr.or.ddit.mapper;

import kr.or.ddit.vo.SalaryMasterVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface SalaryMapper {
    //전체 행수구하기
    public int getTotalPayslip(Map<String, Object> map);
    //해당 페이지리스트 가져오기
    public List<SalaryMasterVO> getPayslipList(Map<String, Object> map);

    //급여상세
    public SalaryMasterVO getPayslipDetail(Map<String, Object> map);

    // #{searchMonth} 파라미터를 받아서 XML의 id="selectSalaryList"를 실행함
    List<Map<String, Object>> selectSalaryList(@Param("searchMonth") String searchMonth);

    //급여확정
    public int insertSalary(Map<String, Object> salaryData);

    /**
     * 부서별 평균 급여 통계 조회
     * @param searchMonth 조회할 년-월 (예: "2026-03")
     * @return 부서명(deptNm), 평균급여(avgPayment), 기준월(thisMonth)을 담은 맵 리스트
     */
    List<Map<String, Object>> getDeptAvgPayment(String searchMonth);


    // 직급별 평균 급여 통계 조회
    List<Map<String, Object>> getRankAvgPayment(String searchMonth);
}
