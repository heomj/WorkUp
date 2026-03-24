package kr.or.ddit.controller.project;

import com.fasterxml.jackson.databind.ObjectMapper;
import kr.or.ddit.mapper.project.ProjectMemberMapper;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.service.project.KanbanprojectService;
import kr.or.ddit.service.project.ProjectMemberSerivce;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.PrtpntVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/proMem")
@Controller
public class ProjectMemberController {

    @Autowired
    private ProjectMemberMapper projectmemberMapper;

    @Autowired
    private ProjectMemberSerivce projectMemberSerivce;

    @Autowired
    private KanbanprojectService kanbanprojectService;

    /*
    @GetMapping("/main")
    public String test(Model model, EmployeeVO employeeVO, Authentication auth) {
        model.addAttribute("contentPage", "project/test");

        if (auth != null) {
            CustomUser customUser = (CustomUser) auth.getPrincipal();

            EmployeeVO loginUserVO = customUser.getEmpVO();

            log.info("디버깅 - 시큐리티 세션에서 가져온 부서명: {}", loginUserVO.getDeptNm());
            log.info("디버깅 - 로그인 유저 정보 전체: {}", loginUserVO);


            model.addAttribute("loginId", loginUserVO.getEmpId());
            model.addAttribute("deptNm", loginUserVO.getDeptNm());
            //model.addAttribute("contentPage", "calendar/main");
        }
        return "main";
    }
*/

    /*
    @GetMapping("/main")
    public String memberStatus(@RequestParam("projNo") int projNo, Model model, Authentication auth) {

        // 1. 서비스 호출 (PrtpntVO 내부에 집계 필드들이 채워져 있어야 함)
        List<PrtpntVO> memberStList = projectMemberSerivce.memberStatus(projNo);
        model.addAttribute("memberStList", memberStList);

        ProjectVO projectVO = projectmemberMapper.projectTitle(projNo);
        model.addAttribute("projectVO", projectVO);

        // 2. JSON 변환 (차트용)
        try {
            ObjectMapper mapper = new ObjectMapper();
            String chartDataJson = mapper.writeValueAsString(memberStList);
            model.addAttribute("chartDataJson", chartDataJson);
            log.info("디버깅 - 차트 JSON: {}", chartDataJson);
        } catch (Exception e) {
            log.error("JSON 변환 중 오류 발생", e);
        }

        // 3. 로그인 정보 처리 (필요 시)
        if (auth != null) {
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO loginUserVO = customUser.getEmpVO();
            model.addAttribute("loginId", loginUserVO.getEmpId());
            model.addAttribute("loginDept", loginUserVO.getDeptNm());
        }

        // 4. 페이지 리턴
        // Tiles를 사용한다면 "main"을 리턴하고 contentPage를 세팅
        // 레이아웃 없이 직접 가려면 "project/test" 리턴
        model.addAttribute("contentPage", "project/test");
        return "main";
    }
    */


    @ResponseBody
    @GetMapping("/members")
    public Map<String, Object> getProjectMembers(@RequestParam("projNo") int projNo) {
        Map<String, Object> result = new HashMap<>();
        log.info("프로젝트 구성원 로드 시작 - projNo: {}", projNo);

        // 구성원 리스트 조회
        List<PrtpntVO> memberList = projectmemberMapper.memberStatus(projNo);

        // 구성원 통계 데이터 조회
        List<PrtpntVO> chartData = projectMemberSerivce.memberTaskStatus(projNo);

        log.info("로드된 구성원 수: {}", memberList.size());

        result.put("memberList", memberList);
        result.put("chartData", chartData);

        return result;
    }

    // 프로젝트 타이틀 정보 가져오기 (필요 시)
    @ResponseBody
    @GetMapping("/title")
    public ProjectVO getProjectTitle(@RequestParam("projNo") int projNo) {
        return projectmemberMapper.projectTitle(projNo);
    }


    /**
     * 프로젝트 상세 페이지 메인 (초기 로딩용)
     */
    @GetMapping("/detail/{projNo}")
    public String projectMain(@PathVariable("projNo") int projNo, Model model, Authentication auth) {
        log.info("프로젝트 상세 접속 - 번호: {}", projNo);

        model.addAttribute("projNo", projNo);

        // 프로젝트 정보 조회 (기존 매퍼 활용)
        ProjectVO projectVO = projectmemberMapper.projectTitle(projNo);
        model.addAttribute("projectVO", projectVO);

        // 구성원 리스트 조회
        List<PrtpntVO> memberStList = projectMemberSerivce.memberStatus(projNo);
        model.addAttribute("memberStList", memberStList);

        // 구성원 통계 데이터 조회
        List<PrtpntVO> chartData = projectMemberSerivce.memberTaskStatus(projNo);
        model.addAttribute("chartData", chartData);

        try {
            ObjectMapper mapper = new ObjectMapper();
            model.addAttribute("chartDataJson", mapper.writeValueAsString(memberStList));
        } catch (Exception e) {
            model.addAttribute("chartDataJson", "[]");
        }

        if (auth != null) {
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO loginUserVO = customUser.getEmpVO();
            model.addAttribute("loginId", loginUserVO.getEmpId());
            model.addAttribute("loginNm", loginUserVO.getEmpNm());
        }

        model.addAttribute("contentPage", "project/kanbanTest");
        return "main";
    }

    /**
     * 프로젝트 정보 비동기 조회 (요청하신 칸반 방식 그대로!)

    @ResponseBody
    @GetMapping("/getProject")
    public ProjectVO getProject(@RequestParam("projNo") int projNo) {
        log.info("프로젝트 정보 비동기 요청 - projNo: {}", projNo);
        // 3. 여기서 칸반 서비스를 사용하여 데이터를 가져옵니다.
        return kanbanprojectService.getProject(projNo);
    }
     */
    /**
     * 구성원 탭 데이터 비동기 조회

    @ResponseBody
    @GetMapping("/members")
    public List<PrtpntVO> getMemberStatus(@RequestParam("projNo") int projNo) {
        log.info("구성원 데이터 비동기 요청 - projNo: {}", projNo);
        return projectMemberSerivce.memberStatus(projNo);
    }
*/

}
