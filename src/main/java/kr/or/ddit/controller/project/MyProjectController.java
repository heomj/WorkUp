package kr.or.ddit.controller.project;

import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.service.project.MyProjectService;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@RequestMapping("/myproject")
@Controller
public class MyProjectController {
    @Autowired
    MyProjectService myProjectService;
    // 리스트 불러오기 (내가 속한 프로젝트)
    @GetMapping("/list")
    public String myprojectlist(Model model, Authentication auth) {

        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        // 리스트 불러오기 (내가 속한 프로젝트)
        List<ProjectVO> projectList=this.myProjectService.getMyProjectList(empId);
        model.addAttribute("projectList", projectList);
        model.addAttribute("contentPage", "project/myprojectList");
        return "main";
    }
@ResponseBody
    @GetMapping("/chartLoad/{projNo}")
    public Map<String, Long> chartLoad (@PathVariable("projNo") int projNo){

        ProjectVO projectVO=this.myProjectService.getProjectByNo(projNo);
        //가져올 것들..
        // 1. 총업무 totalTaskCnt (진행 inProgressCnt/총) 2. 진행률(내장) 3.지연업무 delayedCnt  4. 프로젝트 일정 (내장
    Long todoCnt=0L;
    Long inProgressCnt=0L;
    Long doneCnt=0L;
    Long onHoldCnt=0L;
    Long delayedCnt=0L;
        List<TaskVO> taskVOList = projectVO.getTaskVOList();
        for(TaskVO taskVO : taskVOList){
            if("대기".equals(taskVO.getTaskStts())) todoCnt++;
            if("진행".equals(taskVO.getTaskStts())) inProgressCnt++;
            if("완료".equals(taskVO.getTaskStts())) doneCnt++;
            if("보류".equals(taskVO.getTaskStts())) onHoldCnt++;
            if("지연".equals(taskVO.getTaskStts())) delayedCnt++;
        }

        // 1) Date를 LocalDate로 변환 (필수 과정)
        LocalDate today = LocalDate.now();
        LocalDate end = projectVO.getProjEndDt().toInstant().atZone(ZoneId.systemDefault()).toLocalDate();

    // 5. 상태별 업무 건수 6. 막대차트 4건 => 9개 ;;미친듯
    //맵 "key명" 변수
    String mapKeyName= "";
    int cnt = 0;
    Map<String, Long> result = taskVOList.stream()
                .collect(Collectors.groupingBy(
                        task -> convertToKey(task.getTaskImpt(), task.getTaskStts()), // 여기서 영어 키가 생성됨
                        Collectors.counting()
                ));

    // 2) 두 날짜 사이의 일수 계산
    Long dDay = ChronoUnit.DAYS.between(end,today);
    result.put("dDay", dDay);
    log.info("디데이 :{}", dDay);

    int totalTaskCnt =  taskVOList.toArray().length;
    Long totalTaskCntL = Long.valueOf(totalTaskCnt);
    result.put("totalTaskCnt", totalTaskCntL);
    result.put("todoCnt", todoCnt);
    result.put("inProgressCnt", inProgressCnt);
    result.put("doneCnt", doneCnt);
    result.put("onHoldCnt", onHoldCnt);
    result.put("delayedCnt", delayedCnt);

    //편의에 의해서 percent와 enddt를 보냄
    int projPrgrt = projectVO.getProjPrgrt();
    int timePrgrt = projectVO.getTimePrgrt();
    log.info("timePrgrt : {}", timePrgrt);
    Long projPrgrtL =Long.valueOf(projPrgrt);
    Long timePrgrtL =Long.valueOf(timePrgrt);

    LocalDate localEndDate = projectVO.getProjEndDt().toInstant()
            .atZone(ZoneId.systemDefault())
            .toLocalDate();

    LocalDate localBgngDate = projectVO.getProjBgngDt().toInstant()
            .atZone(ZoneId.systemDefault())
            .toLocalDate();

    // 2. "yyyyMMdd" 형식으로 포맷팅
    String formattedEnd = localEndDate.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
    String formattedBgng = localBgngDate.format(DateTimeFormatter.ofPattern("yyyyMMdd"));

    // 3. String -> Long 변환
    Long projEndDtL = Long.parseLong(formattedEnd);
    Long projBgngDtL = Long.parseLong(formattedBgng);

    result.put("percent", projPrgrtL);
    result.put("timePrgrt", timePrgrtL);
    log.info("timePrgrt : {}", result.get("timePrgrt"));
    result.put("enddt", projEndDtL);
    result.put("bgngdt", projBgngDtL);
    log.info("지연 일감 :{}", delayedCnt);

        log.info("result 차트 : {}", result);
        //어마어마한게 들어간... 맵..
        return result;
    }

    @GetMapping("/detail/{projNo}")
    public String myprojectdetail(Model model, Authentication auth, @PathVariable int projNo ) {

        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        // 프로젝트 불러오기
        ProjectVO projectVO=this.myProjectService.getProjectByNo(projNo);

        log.info("myprojectdetail=>project : {}", projectVO);
/*        */
        model.addAttribute("project", projectVO);
        model.addAttribute("contentPage", "project/kanbanTest");
        return "main";
    }

    //task의 한글을 영어로 바꿈
    private String convertToKey(String priority, String status) {
        // 디버깅: 어떤 값이 들어오는지 먼저 확인
        if (priority == null || status == null) {
            log.warn("Null detected! priority: {}, status: {}", priority, status);
            return "unknown";
        }

        // trim()을 사용하여 혹시 모를 공백 제거
        String p = priority.trim();
        String s = status.trim();
        // 입력이 "낮음"이어도 반환값은 "low"가 됩니다.
        String pKey = switch (priority) {
            case "낮음" -> "low";
            case "보통" -> "mid";
            case "높음" -> "high";
            default -> "unknown";
        };

        // 입력이 "진행"이어도 반환값은 "todo"가 됩니다.
        String sKey = switch (status) {
            case "진행" -> "todo";
            case "완료" -> "done";
            case "지연" -> "dlyd";
            default -> "unknown";
        };

        return pKey + sKey; // 최종적으로 "lowtodo" 같은 영어 키가 반환됨
    }
}
