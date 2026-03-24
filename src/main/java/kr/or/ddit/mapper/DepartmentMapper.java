package kr.or.ddit.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.vo.DepartmentVO;
import kr.or.ddit.vo.EmployeeVO;

@Mapper
public interface DepartmentMapper {

	// 개별 tree 리스트 불러오기
	List<DepartmentVO> indivList();
	
	// 부서별 tree 리스트 불러오기
	List<DepartmentVO> partList();
	
	// 전체 리스트 불러오기
	List<DepartmentVO> allList();
	
	// 직급별 불러오기 (팀장, 대리, 주임, 사원)
	List<EmployeeVO> TeamLeaders(String deptCd);
    List<EmployeeVO> TeamEmployee(String deptCd);
	List<EmployeeVO> seniorEmployee(String deptCd);
	List<EmployeeVO> associateEmployee(String deptCd);


    // 전체 직원 불러오기
	List<EmployeeVO> getAllEmpList();
	


	EmployeeVO getEmpDetail(int calShareId);

}
