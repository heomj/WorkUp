package kr.or.ddit.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.service.DepartmentService;
import kr.or.ddit.vo.DepartmentVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class DepartmentServiceImpl implements DepartmentService {

	@Autowired
	DepartmentMapper departmentMapper;
	
	// 개별 리스트
	@Override
	public List<DepartmentVO> indivList() {
		return departmentMapper.indivList();
	}
	
	// 부서별 리스트
	@Override
	public List<DepartmentVO> partList() {
		return departmentMapper.partList();
	}
	
	
	// 부서별 리스트
	@Override
	public List<DepartmentVO> allList() {
		return departmentMapper.allList();
	}
	

}
