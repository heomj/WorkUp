package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.SalaryMapper;
import kr.or.ddit.service.SalaryService;
import kr.or.ddit.vo.SalaryMasterVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class SalaryServiceImple implements SalaryService {
    @Autowired
    SalaryMapper mapper;

    //전체 행수구하기
    @Override
    public int getTotalPayslip(Map<String, Object> map) {
        return this.mapper.getTotalPayslip(map);
    }
    //해당 페이지리스트 가져오기
    @Override
    public List<SalaryMasterVO> getPayslipList(Map<String, Object> map) {
        return this.mapper.getPayslipList(map);
    }

    //급여상세
    @Override
    public SalaryMasterVO getPayslipDetail(Map<String, Object> map) {
        return this.mapper.getPayslipDetail(map);
    }

    // #{searchMonth} 파라미터를 받아서 XML의 id="selectSalaryList"를 실행함
    @Override
    public List<Map<String, Object>> selectSalaryList(String searchMonth) {
        return this.mapper.selectSalaryList(searchMonth);
    }

    //급여확정
    @Override
    public int insertSalary(Map<String, Object> salaryData) {
        return this.mapper.insertSalary(salaryData);
    }

    /**
     * 부서별 평균 급여 통계 조회
     * @param searchMonth 조회할 년-월 (예: "2026-03")
     * @return 부서명(deptNm), 평균급여(avgPayment), 기준월(thisMonth)을 담은 맵 리스트
     */
    @Override
    public List<Map<String, Object>> getDeptAvgPayment(String searchMonth) {
        return this.mapper.getDeptAvgPayment(searchMonth);
    }

    // 직급별 평균 급여 통계 조회
    @Override
    public List<Map<String, Object>> getRankAvgPayment(String searchMonth) {
        return this.mapper.getRankAvgPayment(searchMonth);
    }
}
