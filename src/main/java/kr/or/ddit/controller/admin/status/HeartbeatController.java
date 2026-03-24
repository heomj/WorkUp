package kr.or.ddit.controller.admin.status;

import kr.or.ddit.service.AttendanceWorkStatusService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/admin/status")   // /admin << 써쥬셔야 합니당
@CrossOrigin(origins = "http://localhost:5173")  // 이것두 설정해쥬셔야 함!
@RestController
public class HeartbeatController {
    // 💓 박동이의 기억장치 (서버가 켜져있는 동안 유지됨)
    public static String lastMethod = "none";
    public static long lastTime = 0;

    @Autowired
    private AttendanceWorkStatusService service;
    /**
     * 리액트(박동이)가 1초마다 신호를 훔쳐가는 통로
     */
    @GetMapping("/heartbeat")
    public Map<String, Object> getHeartbeat() {
        Map<String, Object> response = new HashMap<>();

        // 1. 메서드 이름을 정제해서 "모듈 카테고리"를 판별
        String category = refineMethodName(lastMethod);

        response.put("method", category); // 예: "Attendance", "Mail" 등 깔끔하게 나감
        response.put("rawMethod", lastMethod); // 혹시 모르니 원본도 넣어줌
        response.put("time", lastTime);

        // ✨ [추가] DB 박동 신호 생성
        // lastMethod가 "none"이 아니거나 GW-Server가 아니라면 DB도 열일 중인 걸로 간주!
        if (category != null && !category.equals("none") && !category.equals("GW-Server")) {
            response.put("dbStatus", "DB-Storage");
        } else {
            response.put("dbStatus", "none");
        }

        return response;
    }

    /**
     * 준삣삐의 초간결 정제소
     * 패키지 경로에 포함된 모듈명 하나로 모든 기능을 낚아챔. 노가다 0%.
     */
    private String refineMethodName(String methodName) {
        if (methodName == null || methodName.equals("none")) return "none";

        String lower = methodName.toLowerCase();

        // 🏆 [우선순위 1위] 근태(Attendance)
        // 메서드에 calendar가 섞여있어도 'attendance'가 적혀있으면 무조건 근태로 판별!
        if (lower.contains("attendance")) {
            return "Attendance";
        }

        // 🏆 [우선순위 2위] 일정(Schedule/Calendar)
        // 위에서 근태를 먼저 걸렀기 때문에, 여기서 걸리는 calendar는 순수 '일정' 모듈임.
        if (lower.contains("calendar") || lower.contains("calendar")) {
            return "Schedule";
        }

        // 🏆 [우선순위 3위] 메일(Mail)
        if (lower.contains("mail")) return "Mail";

        // 🏆 [우선순위 4위] 결재(Approval)
        if (lower.contains("approval")) return "Approval";

        // 🏆 [우선순위 5위] 프로젝트(Project)
        if (lower.contains("project")) return "Project";

        // 그 외 나머지는 메인 서버!
        return "GW-Server";

    }

    /**
     * [최종 진화] DB 트래픽 데이터 조회
     */
    @GetMapping("/db-traffic")
    public List<Map<String, Object>> getDbTraffic() {
        log.info("준삣삐, 서비스 통해서 DB 트래픽 훔쳐오는 중... 📡");

        // 서비스에서 가져온 데이터 바로 슛!
        List<Map<String, Object>> trafficData = service.getDbTrafficData();

        return trafficData;
    }

}
