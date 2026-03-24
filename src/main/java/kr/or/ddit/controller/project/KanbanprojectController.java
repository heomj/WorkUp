package kr.or.ddit.controller.project;

import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.service.project.KanbanprojectService;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// 칸반용 임시 ..
@Slf4j
@RequestMapping("/kanban")
@Controller
public class KanbanprojectController {


    @Autowired
    KanbanprojectService kanbanprojectService;


    @ResponseBody
    @GetMapping("/search")
    public List<EmployeeVO> searchMember(@RequestParam("query") String query
                                       , @RequestParam("projNo") int projNo) {
        log.info("(프로젝트 참여자 검색.. )kanban/search=> query: {}, projNo: {}", query, projNo);
        // DB에서 이름이나 사원번호로 검색 (예: WHERE name LIKE %query%)
        List<EmployeeVO> list = this.kanbanprojectService.findMembersByQuery(query, projNo);

        log.info("리스트가 왔나요?=>list {}", list);
        return list;
    }


    //////////////// 임시 칸반 보드 보이기 ////////////////////
    @GetMapping("/kanban")
    public String gokanban(@RequestParam(value="projNo", required=false, defaultValue="305305") int projNo, Model model){
        log.info("gokanban 접속 - 전달받은 projNo: {}", projNo);
        
        // 1. 객체를 생성해서 담아주는 방법 (나중에 DB 조회 로직으로 대체 가능)
        ProjectVO projectVO = new ProjectVO();
        projectVO.setProjNo(projNo);
        // projectVO.setProjTtl("내 프로젝트 제목"); // 나중에 제목 등 추가 가능
        
        // 2. 모델에 "projectVO"라는 이름으로 담기
        model.addAttribute("projectVO", projectVO); 
        
        // JSP에서 ${projNo}로도 바로 쓸 수 있게 하나 더 담아두면 편합니다.
        model.addAttribute("projNo", projNo); 
        model.addAttribute("contentPage", "project/kanbanTest");

        return "main";
    }

    // 칸반보드 리스트 불러오기
    @ResponseBody
    @GetMapping("/tasklist")
    public List<TaskVO> getTasklist(@RequestParam("projNo")int projNo){

        List<TaskVO> taskVOList = this.kanbanprojectService.getTasklist(projNo);

        log.info("칸반 일감 리스트 조회 결과 : "+ taskVOList);
        return taskVOList;
    }

    //프로젝트 명 불러오기
    @ResponseBody
    @GetMapping("/getProject")
    public ProjectVO getProject(@RequestParam("projNo") int projNo) {
        // 프로젝트 단건 조회 후 프론트로 반환 (Service단 거치는 로직은 기존처럼 작성해주세요!)
        return kanbanprojectService.getProject(projNo);
    }


    // 칸반보드 상태 업데이트하기
    @ResponseBody
    @PostMapping("/updateTaskStts")
    public int updateTaskStts(@RequestBody TaskVO taskVO, Authentication auth){


        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        String taskNm = employeeVO.getEmpNm();

        //수정할때마다 수정자의 이름과 사번이 업뎃되게 함ㄴ
        taskVO.setEmpId(empId);
        taskVO.setTaskNm(taskNm);

        //상태 업데이트(프로젝트 상태 지연<->진행은 서비스에서 처리함)
        int result = this.kanbanprojectService.updateTaskStts(taskVO);

        log.info("칸반 일감 상태 업데이트 결과 : "+ result);
        return result;
    }


    //새일감 insert
    @ResponseBody
    @PostMapping("/insertTask")
    public int insertTask(@RequestBody TaskVO taskVO, Authentication auth){

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId(); //작성자 사번
        String taskNm = employeeVO.getEmpNm(); //작성자 이름

        taskVO.setEmpId(empId);
        taskVO.setTaskNm(taskNm);

        log.info("insert할 일감 확인 : "+taskVO);

        int result = this.kanbanprojectService.insertTask(taskVO);

        log.info("칸반 일감 insert 결과 : "+ result);

        return result;
    }


    /**
     * 일감 수정하기(팀장만)
     * @param taskVO 일감 폼 데이터
     * @param auth 스프링 시큐리티
     * @return update 된 수
     */
    @ResponseBody
    @PostMapping("/updateTask")
    public int updateTask(@RequestBody TaskVO taskVO, Authentication auth){

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId(); //작성자 사번
        String taskNm = employeeVO.getEmpNm(); //작성자 이름

        taskVO.setEmpId(empId);
        taskVO.setTaskNm(taskNm);

        log.info("update할 일감 확인 : "+taskVO);

        //업뎃
        int result = this.kanbanprojectService.updateTask(taskVO);

        log.info("칸반 일감 update 결과 : "+ result);

        return result;
    }















}