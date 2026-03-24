package kr.or.ddit.vo;

import java.util.List;

import lombok.Data;

@Data
public class DepartmentVO {

    private int deptCd;
    private String deptNm;

    // 해당 부서의 팀장들 리스트
    private List<EmployeeVO> teamLeaders;
    
    private EmployeeVO memberVO;

    // 부서원 수 계산 변수
    private int deptCount;


    private List<EmployeeVO> deptLeaders;   // 팀장 목록
    private List<EmployeeVO> deptEmployee;   // 팀장 목록

    //관리자근태확인용 alias 프로퍼티
    private int totalCount;       // TOTAL_COUNT
    private int workingCount;     // WORKING_COUNT
    private int specialCount;     // SPECIAL_COUNT
    private int workRate;         // WORK_RATE

}
