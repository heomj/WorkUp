package kr.or.ddit.service;

import java.util.List;

import kr.or.ddit.vo.DepartmentVO;

public interface DepartmentService {

	// 개별 tree 리스트 불러오기
	List<DepartmentVO> indivList();

	
	// 부서 리스트 불러오기
	List<DepartmentVO> partList();
	
	
	// 부서 리스트 불러오기
	List<DepartmentVO> allList();
}
