package kr.or.ddit.controller;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import kr.or.ddit.service.ReserveService;
import kr.or.ddit.vo.ReserveVO;

@CrossOrigin(origins = "http://localhost:5173")
@Controller
public class ReserveController {

    @Autowired
    private ReserveService reserveService;
    
    // ==========================================
    // 1. [사용자 화면 전용] JSP View Mapping
    // ==========================================
    @GetMapping("/reserveMain")
    public String mainView(Model model) { 
        model.addAttribute("contentPage", "reserve/reserveMain"); 
        return "main"; 
    }

    @GetMapping("/reserveList")
    public String listView(Model model) { 
        model.addAttribute("contentPage", "reserve/reserveList"); 
        return "main"; 
    }

    @GetMapping("/reserve/approval")
    public String approvalView(Model model) {
        model.addAttribute("contentPage", "reserve/approval"); 
        return "main"; 
    }

    // ==========================================
    // 2. 공통 및 현황 API
    // ==========================================
    @GetMapping("/reserve/api/all")
    @ResponseBody
    public List<Map<String, Object>> getAllReserveList() {
        return reserveService.getAllReserveList();
    }

    @GetMapping("/reserve/api/teamLeader/{empId}")
    @ResponseBody
    public Map<String, Object> getMyTeamLeader(@PathVariable("empId") String empId) {
        return reserveService.getMyTeamLeader(empId);
    }

    @GetMapping("/reserve/api/my/{empId}")
    @ResponseBody
    public List<ReserveVO> getMyReserveList(@PathVariable("empId") String empId) {
        return reserveService.getMyReserveList(empId);
    }

    // ==========================================
    // 3. 사용자용 회의실 & 비품 예약 API
    // ==========================================
    @GetMapping("/reserve/api/rooms")
    @ResponseBody
    public List<ReserveVO> getMtgRoomList() {
        return reserveService.getMtgRoomList();
    }

    @PostMapping("/reserve/api/room/reservedTimes")
    @ResponseBody
    public List<String> getReservedTimes(@RequestBody Map<String, Object> param) {
        return reserveService.getReservedTimes(param);
    }

    @PostMapping("/reserve/api/insertRoom")
    @ResponseBody
    public String insertMtgRoomReserve(@RequestBody ReserveVO reserveVO) {
        int overlap = reserveService.checkRoomOverlap(reserveVO);
        if(overlap > 0) return "overlap";
        int result = reserveService.insertMtgRoomReserve(reserveVO);
        return result > 0 ? "success" : "fail";
    }

    @PostMapping("/reserve/api/updateRoom")
    @ResponseBody
    public String updateMtgRoomReserve(@RequestBody ReserveVO reserveVO) {
        int result = reserveService.updateMtgRoomReserve(reserveVO);
        return result > 0 ? "success" : "fail";
    }

    @PostMapping("/reserve/api/deleteRoom")
    @ResponseBody
    public String deleteMtgRoomReserve(@RequestBody Map<String, String> payload) {
        int result = reserveService.deleteMtgRoomReserve(payload.get("resId"));
        return result > 0 ? "success" : "fail";
    }

    @GetMapping("/reserve/api/fixts")
    @ResponseBody
    public List<ReserveVO> getFixtList() {
        return reserveService.getFixtList();
    }

    @PostMapping("/reserve/api/insertFixt")
    @ResponseBody
    public String insertFixtReserve(@RequestBody ReserveVO reserveVO) {
        int overlap = reserveService.checkFixtOverlap(reserveVO);
        if(overlap > 0) return "overlap";
        int result = reserveService.insertFixtReserve(reserveVO);
        return result > 0 ? "success" : "fail";
    }

    @PostMapping("/reserve/api/updateFixt")
    @ResponseBody
    public String updateFixtReserve(@RequestBody ReserveVO reserveVO) {
        int result = reserveService.updateFixtReserve(reserveVO);
        return result > 0 ? "success" : "fail";
    }

    @PostMapping("/reserve/api/deleteFixt")
    @ResponseBody
    public String deleteFixtReserve(@RequestBody Map<String, String> payload) {
        int result = reserveService.deleteFixtReserve(payload.get("resId"));
        return result > 0 ? "success" : "fail";
    }
    
    // ==========================================
    // [추가] AI 챗봇 전용 회의실 예약 API
    // ==========================================
    @PostMapping("/reserve/api/insertAiReserve")
    @ResponseBody
    public org.springframework.http.ResponseEntity<String> insertAiReserve(@RequestBody ReserveVO reserveVO, org.springframework.security.core.Authentication auth) {
        try {
            if (reserveVO.getBgngDt() == null || reserveVO.getBgngDt().contains("undefined") ||
                reserveVO.getEndDt() == null || reserveVO.getEndDt().contains("undefined")) {
                return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.BAD_REQUEST).body("필수 예약 정보(시간)가 누락되었습니다.");
            }

            kr.or.ddit.service.impl.CustomUser customUser = (kr.or.ddit.service.impl.CustomUser) auth.getPrincipal();
            String empId = String.valueOf(customUser.getEmpVO().getEmpId());
            reserveVO.setEmpId(empId);
            reserveVO.setType("ROOM");

            Map<String, Object> leaderInfo = reserveService.getMyTeamLeader(empId);
            if (leaderInfo != null && leaderInfo.get("empId") != null) {
                reserveVO.setAprvId(String.valueOf(leaderInfo.get("empId")));
            }

            int overlap = reserveService.checkRoomOverlap(reserveVO);
            if (overlap > 0) {
                return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.CONFLICT).body("OVERLAP");
            }
            
            int result = reserveService.insertMtgRoomReserve(reserveVO); 
            
            if (result > 0) {
                return org.springframework.http.ResponseEntity.ok("SUCCESS");
            } else {
                return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).body("FAIL");
            }
        } catch (Exception e) {
            e.printStackTrace(); 
            return org.springframework.http.ResponseEntity.internalServerError().body("ERROR");
        }
    }
    
    // ==========================================
    // 4. 결재/승인 관련 API
    // ==========================================
    @GetMapping("/reserve/api/pending/{empId}")
    @ResponseBody
    public List<ReserveVO> getPendingList(@PathVariable("empId") String empId) {
        return reserveService.getPendingApprovalList(empId);
    }

    @PostMapping("/reserve/api/approve")
    @ResponseBody
    public String approveReserve(@RequestBody Map<String, String> payload) {
        try {
            // 🔥 승인 시 CONFIRMED 상태를 주입하도록 수정
            Map<String, String> param = new java.util.HashMap<>(payload);
            param.put("status", "CONFIRMED");
            int result = reserveService.approveReserve(param);
            return result > 0 ? "success" : "fail";
        } catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }

    // 🔥 삭제 꼼수 제거! 반려 시 REJECTED 상태를 주입하여 업데이트 하도록 수정
    @PostMapping("/reserve/api/reject")
    @ResponseBody
    public String rejectReserve(@RequestBody Map<String, String> payload) {
        try {
            Map<String, String> param = new java.util.HashMap<>(payload);
            param.put("status", "REJECTED");
            int result = reserveService.approveReserve(param); 
            return result > 0 ? "success" : "fail";
        } catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }

    // ==========================================
    // 5. [관리자 전용] 자산 마스터 데이터 관리 API
    // ==========================================
    @GetMapping("/reserve/api/admin/rooms")
    @ResponseBody
    public List<ReserveVO> getAdminRoomList() { return reserveService.getAdminRoomList(); }

    @GetMapping("/reserve/api/admin/fixts")
    @ResponseBody
    public List<ReserveVO> getAdminFixtList() { return reserveService.getAdminFixtList(); }

    @PostMapping("/reserve/api/admin/room/insert")
    @ResponseBody
    public String insertAdminRoom(@RequestBody ReserveVO reserveVO) {
        int result = reserveService.insertAdminRoom(reserveVO);
        return result > 0 ? "success" : "fail";
    }

    @PostMapping("/reserve/api/admin/room/update")
    @ResponseBody
    public String updateAdminRoom(@RequestBody ReserveVO reserveVO) {
        int result = reserveService.updateAdminRoom(reserveVO);
        return result > 0 ? "success" : "fail";
    }

    @PostMapping("/reserve/api/admin/room/delete")
    @ResponseBody
    public String deleteAdminRoom(@RequestBody Map<String, Object> payload) {
        try {
            if (payload.get("id") == null) return "fail";
            
            int rmNo = Integer.parseInt(payload.get("id").toString());
            int result = reserveService.deleteAdminRoom(rmNo);
            return result > 0 ? "success" : "fail";
        } catch (Exception e) {
            return "error";
        }
    }

    @PostMapping("/reserve/api/admin/fixt/insert")
    @ResponseBody
    public String insertAdminFixt(@RequestBody ReserveVO reserveVO) {
        int result = reserveService.insertAdminFixt(reserveVO);
        return result > 0 ? "success" : "fail";
    }

    @PostMapping("/reserve/api/admin/fixt/update")
    @ResponseBody
    public String updateAdminFixt(@RequestBody ReserveVO reserveVO) {
        int result = reserveService.updateAdminFixt(reserveVO);
        return result > 0 ? "success" : "fail";
    }

    @PostMapping("/reserve/api/admin/fixt/delete")
    @ResponseBody
    public String deleteAdminFixt(@RequestBody Map<String, String> payload) {
        int fixtNo = Integer.parseInt(String.valueOf(payload.get("id")));
        int result = reserveService.deleteAdminFixt(fixtNo);
        return result > 0 ? "success" : "fail";
    }
    
    @GetMapping(value = {
            "/admin/reserve", 
            "/admin/reserve/**"
        })
        public String forwardAdminReactBridge(HttpServletRequest request) {
            String uri = request.getRequestURI();

            if (uri.matches(".*\\.[a-zA-Z0-9]+$")) {
                String realPath = uri.replaceAll("^/admin/reserve(/[a-zA-Z0-9_-]+)?", "");
                return "forward:" + realPath;
            }

            return "reserve/adminReactBridge"; 
        }
}