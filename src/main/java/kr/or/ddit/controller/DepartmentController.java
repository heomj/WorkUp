package kr.or.ddit.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.service.DepartmentService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.vo.DepartmentVO;
import kr.or.ddit.vo.EmployeeVO;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.web.bind.annotation.RequestParam;


@Controller
public class DepartmentController {
	
	
	@Autowired
	private DepartmentService departmentService;
	
	
	@RequestMapping(value="/tree", method= {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView tree(ModelAndView mav) {
		mav.setViewName("tree");
		return mav;
	}
	
	
	// 개인별 리스트
	@ResponseBody
	@RequestMapping(value="/indivList", method= {RequestMethod.GET, RequestMethod.POST})
	public List<DepartmentVO> indivList() {
		List<DepartmentVO> iList = departmentService.indivList();
		return iList;
	}
	
	
	
	// 부서별 리스트
	@RequestMapping(value="/partList", method= {RequestMethod.GET, RequestMethod.POST})
	@ResponseBody
	public List<DepartmentVO> partList() {
		List<DepartmentVO> list = departmentService.partList();
		return list;
	}
	
	
	
	// 전체 
	@RequestMapping(value="/allList", method= {RequestMethod.GET, RequestMethod.POST})
	@ResponseBody
	public List<DepartmentVO> allList() {
		List<DepartmentVO> alist = departmentService.allList();
		return alist;
	}
	
	
	
	// ========================================================================
	// 조직도
	// 메인
	@GetMapping("/deptStructure")
	public String calendarMain(Model model, EmployeeVO employeeVO, Authentication authentication) {
		model.addAttribute("contentPage", "deptStructure");

		return "main";
	}
	
	

}
