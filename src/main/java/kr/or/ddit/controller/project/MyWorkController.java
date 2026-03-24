package kr.or.ddit.controller.project;

import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.service.project.MyWorkService;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Controller
@RequestMapping("/mywork")
public class MyWorkController {
    @Autowired
    private MyWorkService myWorkService;

    @PostMapping("/update")
    @ResponseBody
    public Map<String, Object> updateMyWork(@RequestBody TaskVO taskVO, Authentication auth) {
        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId(); //작성자 사번
        String taskNm = employeeVO.getEmpNm(); //작성자 이름

        taskVO.setEmpId(empId);
        taskVO.setTaskNm(taskNm);
        log.info("데이터 확인 : {}", taskVO);

        int result = this.myWorkService.updateTask(taskVO);
        Map<String, Object> map = new HashMap<String, Object>();
        if (result > 0) {
            map.put("result", "success");
        } else {
            map.put("result", "fail");
        }

        return map;

    }

    // 대시보드에서 AJAX로 호출할 JSON 전용 엔드포인트
    @ResponseBody  // 👈 이게 있어야 JSP가 아니라 JSON으로 나감!
    @GetMapping("/dashboardMyTask")
    public List<TaskVO> dashboardMyTask(Authentication auth) {
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();

        // 1. 일단 마스터 쿼리로 내 프로젝트+업무 싹 가져오기
        List<ProjectVO> projectList = this.myWorkService.toMyWorkList(empId);

        // 2. [GigaChad Filter] 모든 프로젝트를 돌면서 '진행 중'인 내 일감만 쏙쏙 뽑기
        List<TaskVO> myOngoingTasks = new ArrayList<>();

        for (ProjectVO project : projectList) {
            // 프로젝트가 완료된 건 제외 (아까 준삣삐가 원했던 로직!)
            if (!"완료".equals(project.getProjStts()) && "진행".equals(project.getProjStts())) {
                for (TaskVO task : project.getTaskVOList()) {
                    // 내 일감이면서 + 상태가 '진행'인 것만 필터링
                    // (참고: taskVO에 empId가 본인인지 확인하는 로직이 필요할 수 있음)
                    if ("진행".equals(task.getTaskStts())) {
                        myOngoingTasks.add(task);
                    }
                }
            }
        }

        // 3. 필터링된 '진행 중인 일감'만 JSON으로 뙇!
        return myOngoingTasks;
    }


}
