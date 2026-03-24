package kr.or.ddit.controller.admin.board;

import java.util.stream.Collectors;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.service.EmployeeService;
import kr.or.ddit.service.NoticeService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.NoticeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/admin/notice")
public class NotAdminController {

    @Autowired
    private NoticeService noticeService;

    // ✨ UploadController를 주입받아 다운로드 로직 재활용
    @Autowired
    private UploadController uploadController;
    
    @Autowired
    private AlarmController alarmController;

    @Autowired
    private EmployeeService employeeService; // 모든 사원 리스트를 가져오기

    // 1. 관리자 공지사항 목록
    @PostMapping("/list")
    public ArticlePage<NoticeVO> adminList(@RequestBody NoticeVO noticeVO, Authentication auth) {
        Map<String, Object> map = new HashMap<>();
        int currentPage = (noticeVO.getCurrentPage() <= 0) ? 1 : noticeVO.getCurrentPage();
        int size = 10;
        
        map.put("currentPage", currentPage);
        map.put("keyword", noticeVO.getKeyword());
        map.put("size", size);
        
        int total = this.noticeService.selectNoticeCount(map);
        List<NoticeVO> noticeList = this.noticeService.selectNoticeList(map);

        return new ArticlePage<>(total, currentPage, size, noticeVO.getKeyword(), noticeList);
    }

    // 2. 상세 조회
    @GetMapping("/detail/{ntcNo}")
    public NoticeVO adminDetail(@PathVariable("ntcNo") int ntcNo) {
        log.info("관리자 상세조회 ntcNo: {}", ntcNo);
        NoticeVO noticeVO = new NoticeVO();
        noticeVO.setNtcNo(ntcNo);
        
        // Mapper의 resultMap="noticeMap" 덕분에 첨부파일 리스트가 함께 포함됩니다.
        return this.noticeService.selectNoticeDetail(noticeVO);
    }

    // 3. 공지사항 등록 (파일 업로드 대응)
    @PostMapping("/create")
    public Map<String, Object> adminCreate(NoticeVO noticeVO, 
                                         @RequestParam(value="uploadFiles", required=false) MultipartFile[] uploadFiles,
                                         Authentication auth) {
        Map<String, Object> response = new HashMap<>();

        // 1. 인증 객체 및 유저 타입 체크 (ClassCastException 방지)
        if (auth == null || !(auth.getPrincipal() instanceof CustomUser)) {
            log.error("인증되지 않은 사용자 접근 또는 세션 만료");
            response.put("result", "fail");
            response.put("message", "로그인 정보가 없거나 세션이 만료되었습니다.");
            return response;
        }

        // 2. 로그인한 사용자 정보 세팅
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int currentEmpId = customUser.getEmpVO().getEmpId(); // 발신자(관리자) ID
        String currentEmpNm = customUser.getEmpVO().getEmpNm();
        
        noticeVO.setEmpId(currentEmpId);
        
        // 만약 부서코드가 필요한 경우 (JSP 예제 참고)
        if (noticeVO.getNtcDeptCd() == null) {
            noticeVO.setNtcDeptCd(customUser.getEmpVO().getDeptCd());
        }

        // 3. 파일 처리 (파일이 존재하고 첫 번째 파일이 비어있지 않은지 확인)
        if (uploadFiles != null && uploadFiles.length > 0 && !uploadFiles[0].isEmpty()) {
            log.info("업로드할 파일 개수: {}", uploadFiles.length);
            noticeVO.setUploadFiles(uploadFiles);
        } else {
            log.info("첨부파일 없음");
            noticeVO.setUploadFiles(null);
        }

        // 4. 서비스 호출 및 결과 반환
        try {
            int result = this.noticeService.insertNotice(noticeVO);
            
            if (result > 0) {
                // --- 🚨 [전체 사원 알람 발송 로직 추가 시작] 🚨 ---
                
                // 1) 알람 VO 및 수신인 리스트 생성
                AlarmVO alarmVO = new AlarmVO();
                
                // 2) 서비스의 기존 emplist()를 활용해 전체 사원 정보 가져오기
                List<EmployeeVO> allEmployees = this.employeeService.emplist(); 
                
                // 3) Stream을 이용해 EmployeeVO 객체 리스트에서 사번(Integer)만 추출
                List<Integer> allEmpIds = allEmployees.stream()
                                                      .map(EmployeeVO::getEmpId)
                                                      .collect(Collectors.toList());
                
                // 4) 알람 데이터 세팅
                alarmVO.setAlmMsg("새로운 공지사항이 등록되었습니다.");
                alarmVO.setAlmDtl(
                    "<span class=\"fw-bold\">" + currentEmpNm + "</span>님이 " +
                    "<span class=\"fw-bold text-primary\">'" + noticeVO.getNtcTtl() + "'</span> 공지사항을 등록했습니다."
                );
                alarmVO.setAlmRcvrNos(allEmpIds); // 전체 사원 사번 리스트 세팅
                alarmVO.setAlmIcon("info");      // 공지 알람 아이콘

                // 5) 알람 컨트롤러 호출
                // 파라미터: 발신자사번, 알람VO, 이동할URL, 알람타입
                String alarmRes = this.alarmController.sendAlarm(
                    currentEmpId,
                    alarmVO,
                    "/notice/list", 
                    "공지"
                );

                log.info("공지사항 전체 알람 발신 결과 : " + alarmRes);
                // --- 🚨 [알람 로직 끝] 🚨 ---

                response.put("result", "success");
                response.put("ntcNo", noticeVO.getNtcNo()); // 생성된 번호 확인용
            } else {
                response.put("result", "fail");
            }
        } catch (Exception e) {
            log.error("공지사항 등록 중 오류 발생: ", e);
            response.put("result", "fail");
            response.put("message", e.getMessage());
        }

        return response;
    }

    // 4. 공지사항 수정 (기존 파일 유지 로직 추가)
    @ResponseBody
    @PostMapping("/update")
    public Map<String, Object> adminUpdate(
            NoticeVO noticeVO,
            // ✨ 프론트엔드에서 삭제하지 않고 남겨둔 파일 ID 리스트를 받습니다.
            @RequestParam(value="existingFileIds", required=false) List<Long> existingFileIds, 
            @RequestParam(value="uploadFiles", required=false) MultipartFile[] uploadFiles,
            Authentication auth) {
        
        log.info("관리자 수정 요청 ntcNo: {}", noticeVO.getNtcNo());
        log.info("유지될 기존 파일 ID 목록: {}", existingFileIds);
        
        Map<String, Object> response = new HashMap<>();

        // 1. [권한 체크] 예제 코드처럼 인증 정보 확인 (필요 시)
        if (auth == null || !(auth.getPrincipal() instanceof CustomUser)) {
            response.put("result", "fail");
            response.put("message", "세션이 만료되었습니다.");
            return response;
        }

        // 2. 새로 추가된 파일이 있다면 VO에 세팅
        if(uploadFiles != null && uploadFiles.length > 0 && !uploadFiles[0].isEmpty()) {
            noticeVO.setUploadFiles(uploadFiles);
        }

        // 3. ⭐️ 유지할 기존 파일 ID 목록을 VO에 세팅
        // 이 정보가 담겨야 ServiceImpl에서 기존 파일을 보존하거나 선별 삭제할 수 있습니다.
        noticeVO.setExistingFileIds(existingFileIds); 

        try {
            // 4. 서비스 호출 (기존 파일 유지 로직이 포함된 updateNotice 실행)
            int result = this.noticeService.updateNotice(noticeVO);
            
            if (result > 0) {
                response.put("result", "success");
                response.put("status", "200");
            } else {
                response.put("result", "fail");
                response.put("status", "500");
            }
        } catch (Exception e) {
            log.error("수정 중 오류 발생: ", e);
            response.put("result", "fail");
            response.put("message", e.getMessage());
        }

        return response;
    }

    // 5. 공지사항 삭제
    @DeleteMapping("/delete/{ntcNo}")
    public Map<String, Object> adminDelete(@PathVariable("ntcNo") int ntcNo) {
        int result = this.noticeService.deleteNotice(ntcNo);
        Map<String, Object> response = new HashMap<>();
        response.put("result", result > 0 ? "success" : "fail");
        return response;
    }

    /**
     * 6. 첨부파일 다운로드 (UploadController의 로직 호출)
     * URL: GET /admin/notice/download?fileDtlId=...
     */
    @GetMapping("/download")
    public ResponseEntity<Resource> downloadFile(@RequestParam("fileDtlId") Long fileDtlId) {
        log.info("관리자 모달에서 파일 다운로드 요청 ID: {}", fileDtlId);
        
        // ✨ 직접 로직을 짜지 않고 이미 만든 UploadController의 메서드에 일감을 넘깁니다.
        return uploadController.downloadFile(fileDtlId);
    }
}