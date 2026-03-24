package kr.or.ddit.controller.project;


import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.service.project.AdminService;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.PrtpntVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

// 프로젝트 관리 ( 팀장 )
@Slf4j
@RequestMapping("/adpjt")
@Controller
public class AdminController {

    @Autowired
    AdminService adminService;

    @Autowired
    private AlarmController alarmController;

    // 프로젝트 생성 시 "사원들 조회하기(팀장/관리자 빼고)"
    @ResponseBody
    @GetMapping("/emplist")
    public List<EmployeeVO> emplist(){

        List<EmployeeVO> emplist = this.adminService.emplist();
        log.info("사원List : {}",emplist);
        return emplist;
    }

    // 프로젝트 생성 !
    @ResponseBody
    @PostMapping("/create")
    public String create(@RequestBody ProjectVO projectVO, Authentication auth) {
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        int empid =  customUser.getEmpVO().getEmpId();
        String empnm = customUser.getEmpVO().getEmpNm();

        log.info("프로젝트 생성 : {}", projectVO);

        // 리더(방생성자)도 참여자로 넣기 ======
        PrtpntVO prtpntVO = new PrtpntVO();
        prtpntVO.setEmpId(empid);
        prtpntVO.setPrtpntNm(empnm);

        projectVO.getPrtpntVOList().add(prtpntVO);

        String result = this.adminService.create(projectVO);

        if(result == "success") {

            AlarmVO alarmVO = new AlarmVO();

            // Stream 사용해보기
            List<Integer> empIds = projectVO.getPrtpntVOList().stream()
                    .map(PrtpntVO::getEmpId)
                    .toList();

            // 한 명이지만 .. List에 담기 ㅇ_ㅇ
//           List<Integer> empList = new ArrayList<>();
//
//            empList.add(firstApproverId);

            alarmVO.setAlmMsg(projectVO.getProjTtl()+" 프로젝트 생성");
            alarmVO.setAlmDtl(
                    "<span class=\"fw-bold text-primary\">'" + projectVO.getProjTtl() + "</span>'프로젝트에 참여되었습니다.");
            alarmVO.setAlmRcvrNos(empIds);
            alarmVO.setAlmIcon("info");

            // 파라미터 순서: 관리자(empId), 알람VO, 상세이동URL, 알람타입(알람 앞에 붙는 구분메시지)
            String alarmRes = this.alarmController.sendAlarm(
                    empid,  // 관리자인뎅..
                    alarmVO,
                    "/myproject/detail/"+projectVO.getProjNo(),
                    "프로젝트"
            );
        }

        return result;
    }

    // 중요도(별) Y, N
    @ResponseBody
    @PatchMapping("/staript")
    public String create(@RequestBody ProjectVO projectVO) {
        log.info("별 머니? : {}", projectVO);

        int result = this.adminService.staript(projectVO);

        if(result > 0) { return  "success"; }
        else {return "fail";}
    }

    // 프로젝트 (완료)
    @ResponseBody
    @PostMapping("/finishpjt")
    public String finishpjt(@RequestBody ProjectVO projectVO) {
        log.info("완료 할 프로젝트가 머닝 : {}", projectVO);

        int result = this.adminService.finishpjt(projectVO);

        if(result > 0) { return  "success"; }
        else {return "fail";}
    }


    /**
     * 프로젝트 참여자 제외하기
     * @return success / fail
     */
    @ResponseBody
    @PostMapping("removeParticipant")
    public String removeParticipant(@RequestBody TaskVO vo, Authentication auth){
        log.info("누가 왔늬 ? {}", vo);

        CustomUser customUser = (CustomUser)auth.getPrincipal();
        int empid =  customUser.getEmpVO().getEmpId();

        if(empid == vo.getEmpId()) {
            return "no";
        }

        int result = this.adminService.removeParticipant(vo);


        log.info("result : {}", result);
        if(result == 1) {
            return "success";
        } else if (result == 2) {
            return "isTask";
        }
        else {
            return "fail";
        }
    }

    /**
     * 대시보드에서 진행중인 프로젝트 List 불러오기
     * @param auth 사용자 ID
     * @return 프로젝트 List
     */
    @ResponseBody
    @GetMapping("/dashboardProject")
    public List<ProjectVO> dashboardProject (Authentication auth) {
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        int empid =  customUser.getEmpVO().getEmpId();

        List<ProjectVO> projectlist = this.adminService.dashboardProject(empid);

        return projectlist;
    }


    /**
     * 프로젝트에 참여자 추가하기
     * @param prtpntVO 참여자(id, name), 프로젝트id
     * @return 성공여부 (success / fail)
     */
    @ResponseBody
    @PostMapping("/addParticipant")
    public String addParticipant(@RequestBody PrtpntVO prtpntVO, Authentication auth){

        CustomUser customUser = (CustomUser)auth.getPrincipal();
        int empid =  customUser.getEmpVO().getEmpId();

        log.info("참여자 : {}",prtpntVO);
        int result = this.adminService.addParticipant(prtpntVO);

        String name = this.adminService.projectname(prtpntVO.getProjNo());

        if(result > 0) {
            AlarmVO alarmVO = new AlarmVO();

            // Stream 사용해보기

            List<Integer> empList = new ArrayList<>();
            empList.add(prtpntVO.getEmpId());

            alarmVO.setAlmMsg("'"+name+"' 프로젝트 신규 멤버 참여");
            alarmVO.setAlmDtl(
                    "<span class=\"fw-bold text-primary\">'" + name + "'</span>프로젝트에 참여되었습니다.");
            alarmVO.setAlmRcvrNos(empList);
            alarmVO.setAlmIcon("info");

            // 파라미터 순서: 관리자(empId), 알람VO, 상세이동URL, 알람타입(알람 앞에 붙는 구분메시지)
            String alarmRes = this.alarmController.sendAlarm(
                    empid,  // 관리자인뎅..
                    alarmVO,
                    "/myproject/detail/"+prtpntVO.getProjNo(),
                    "프로젝트"
            );

            return "success";
        }
        else {
            return "fail";
        }
    }

}
