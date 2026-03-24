package kr.or.ddit.controller.admin.project;

import kr.or.ddit.service.project.AdminService;
import kr.or.ddit.vo.project.ProjectVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RequestMapping("/admin/pjt")
@CrossOrigin(origins = "http://localhost:5173")
@RestController
public class pjtAdminController {

    @Autowired
    AdminService adminService;

    /**
     * 부서별 프로젝트 List / 일감 List / 참여자 List 조회
     * @param deptCd : 부서번호
     * @return vo.deptCd 의 프로젝트 List / 일감 List / 참여자 List
     */
    @GetMapping("/deptProjectList")
    public List<ProjectVO> deptProjectList (@RequestParam("dept_cd") int deptCd) {
        log.info("어느 부서의 List ? : {}", deptCd);
        List<ProjectVO> projectlist = this.adminService.deptProjectList(deptCd);

        return projectlist;
    }
}
