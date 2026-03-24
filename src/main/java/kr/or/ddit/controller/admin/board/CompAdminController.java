package kr.or.ddit.controller.admin.board;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.or.ddit.service.ComplaintService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.ComplaintVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/admin/complaint")
public class CompAdminController {

    @Autowired
    private ComplaintService complaintService;
    
    //알람 발송
    @Autowired
    private AlarmController alarmController;

    /**
     * 1. 신고 목록 조회 (관리자 메인)
     */
    @GetMapping("/list")
    @ResponseBody // 중요! 이 어노테이션이 있어야 리액트로 데이터(JSON)가 전달됩니다.
    public List<ComplaintVO> complaintList(@RequestParam Map<String, Object> map) {
        // 1. 서비스에서 DB 데이터를 가져옵니다.
        List<ComplaintVO> list = this.complaintService.selectComplaintList(map);
        
        // 2. JSP 경로를 리턴하는 대신, 데이터 자체를 리턴합니다.
        return list; 
    }

    /**
     * 2. 신고 상세 조회 (Ajax 또는 모달용)
     */
    @ResponseBody
    @GetMapping("/detail")
    public ComplaintVO complaintDetail(@RequestParam int dclNo) {
        return this.complaintService.selectComplaintDetail(dclNo);
    }

    /**
     * 3. 신고 처리 실행 (상태 변경 및 처리 내용 저장)
     * 화면에서 JSON 형태로 dclNo, dclStts, dclPrcsCn을 던진다고 가정합니다.
     */
    @ResponseBody
    @PostMapping("/updateStatus")
    public Map<String, Object> updateStatus(@RequestBody ComplaintVO complaintVO, Authentication auth) {
        Map<String, Object> response = new HashMap<>();
        
        log.info("### [신고 처리 요청] 데이터 확인: {}", complaintVO);

        // 1. 인증 체크 (ClassCastException 방지 및 세션 체크)
        if (auth == null || !(auth.getPrincipal() instanceof CustomUser)) {
            log.warn("### [인증 에러] 권한이 없거나 세션이 만료되었습니다.");
            response.put("result", "timeout");
            return response;
        }

        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO loginMember = customUser.getEmpVO();
        int adminId = loginMember.getEmpId();

        // 2. 신고 기록 업데이트 
        // 서비스(ServiceImpl) 내부 로직에 의해 DB의 BBS_REPORT_CNT가 +1 증가하고, 
        // 3회 이상일 시 블라인드 처리가 수행된 후, 최신 결과값이 complaintVO에 담겨 돌아옵니다.
        complaintVO.setDclPrcsId(adminId);
        int result = this.complaintService.updateComplaintStatus(complaintVO);

        if (result > 0) {
            try {
                int bbsNo = complaintVO.getDclBbsNo(); 
                String currentStatus = complaintVO.getDclStts(); 
                
                // 서비스에서 +1 처리되어 돌아온 최신 누적 횟수를 가져옵니다.
                int currentReportCnt = complaintVO.getReportCnt();
                
                // [수정 핵심] 
                // 이전 코드에 있던 'resetReportCount'를 여기서 삭제했습니다! 
                // 관리자가 '경고'를 주는 것은 카운트를 1 올리는 행위이지, 0으로 만드는 행위가 아니기 때문입니다.
                
                if (currentReportCnt >= 3) {
                    log.warn("### [블라인드 확정] 게시글 {}번이 3회 누적 상태입니다.", bbsNo);
                } else {
                    log.info("### [경고 누적 성공] 게시글 {}번의 현재 누적 횟수: {}", bbsNo, currentReportCnt);
                }

                // --- [A] 신고자(Reporter) 알림 --- (기존 유지)
                if (complaintVO.getEmpId() != 0) {
                    AlarmVO reportAlarm = new AlarmVO();
                    reportAlarm.setAlmSndrIcon("myProfile");
                    reportAlarm.setAlmIcon("info");
                    reportAlarm.setAlmMsg("신고 처리 결과 안내");
                    
                    String detail = "반려".equals(currentStatus) 
                        ? "회원님이 신고하신 '" + complaintVO.getBbsTitle() + "' 게시글은 검토 결과 반려되었습니다."
                        : "회원님이 신고하신 '" + complaintVO.getBbsTitle() + "' 게시글 처리가 완료되었습니다.";
                    
                    reportAlarm.setAlmDtl(detail);
                    reportAlarm.setAlmRcvrNos(List.of(complaintVO.getEmpId()));

                    String reportDetailUrl = "/board/detail?bbsNo=" + bbsNo;
                    this.alarmController.sendAlarm(adminId, reportAlarm, reportDetailUrl, "신고");
                }

                // --- [B] 게시글 작성자(Target) 알림 --- (로직 최적화)
                if (complaintVO.getWriterId() != 0) {
                    AlarmVO targetAlarm = new AlarmVO();
                    targetAlarm.setAlmSndrIcon("myProfile");
                    targetAlarm.setAlmIcon("warning");
                    targetAlarm.setAlmMsg("게시물 신고 조치 안내");
                    
                    String alarmDetail = "";
                    if ("반려".equals(currentStatus)) {
                        alarmDetail = "회원님의 게시물 '" + complaintVO.getBbsTitle() + "'에 대한 신고가 검토 결과 반려되었습니다.";
                    } else if (currentReportCnt >= 3) {
                        alarmDetail = "회원님의 게시물 '" + complaintVO.getBbsTitle() + "'이(가) 신고 3회 누적되어 블라인드 처리되었습니다.";
                    } else if ("경고".equals(currentStatus)) {
                        // 이제 여기서는 초기화 멘트가 아니라 '경고가 누적되었다'는 멘트를 보냅니다.
                        alarmDetail = "회원님의 게시물 '" + complaintVO.getBbsTitle() + "'에 대해 관리자 경고 조치가 취해졌습니다. (누적: " + currentReportCnt + "회)";
                    } else {
                        alarmDetail = "회원님의 게시물 '" + complaintVO.getBbsTitle() + "'에 신고가 접수되었습니다. (현재 누적: " + currentReportCnt + "회)";
                    }
                    targetAlarm.setAlmDtl(alarmDetail);
                    targetAlarm.setAlmRcvrNos(List.of(complaintVO.getWriterId()));

                    String targetDetailUrl = "/board/detail?bbsNo=" + bbsNo;
                    this.alarmController.sendAlarm(adminId, targetAlarm, targetDetailUrl, "신고");
                }
                
                response.put("result", "success");
                response.put("reportCnt", currentReportCnt); 

            } catch (Exception e) {
                log.error("알림 처리 중 오류: ", e);
                response.put("result", "error");
            }
        } else {
            response.put("result", "fail");
        }

        return response;
    }
}