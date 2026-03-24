package kr.or.ddit.controller.project;

import kr.or.ddit.service.project.ScheduleService;
import kr.or.ddit.vo.project.TaskParticipantVO;
import kr.or.ddit.vo.project.TaskVO;
import kr.or.ddit.vo.EmployeeVO; // 사원 VO 패키지 추가
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Slf4j
@RestController
@RequestMapping("/schedule")
public class ScheduleController {

    @Autowired
    private ScheduleService scheduleService;

    @GetMapping("/list")
    public Map<String, Object> getScheduleList(@RequestParam("projNo") int projNo) {
        Map<String, Object> resultMap = new HashMap<>();

        // 1. 일감 리스트 조회 (이제 JOIN을 통해 empNm이 채워져서 나옵니다)
        List<TaskVO> eventList = scheduleService.getScheduleList(projNo);
        
        // 2. 일감 데이터에서 참여자 이름만 중복 없이 추출 (Set 활용)
        // 별도의 서비스 메서드(getProjectMembers) 없이도 화면에 이름을 뿌릴 수 있는 꼼수입니다.
        Set<String> participantNames = new HashSet<>();
        for(TaskVO task : eventList) {
            if(task.getEmpNm() != null) participantNames.add(task.getEmpNm());
            // 참여자 리스트에서도 이름을 수집
            if(task.getTaskParticipantVOList() != null) {
                for(TaskParticipantVO p : task.getTaskParticipantVOList()) {
                    if(p.getEmpNm() != null) participantNames.add(p.getEmpNm());
                }
            }
        }

        resultMap.put("events", eventList);
        resultMap.put("participants", participantNames); // 이름 문자열 리스트로 전달

        return resultMap;
    }
}