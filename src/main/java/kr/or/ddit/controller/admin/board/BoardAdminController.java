package kr.or.ddit.controller.admin.board;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.service.BoardService;
import kr.or.ddit.service.CommentService;
import kr.or.ddit.service.ComplaintService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.BoardVO;
import kr.or.ddit.vo.CommentVO;
import kr.or.ddit.vo.ComplaintVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/admin/board")
public class BoardAdminController {

    @Autowired
    private BoardService boardService;

    @Autowired
    private CommentService commentService;

    @Autowired
    private ComplaintService complaintService;

    @Autowired
    private UploadController uploadController;

    @Autowired
    private AlarmController alarmController;
    
    /**
     * 아바타 이미지를 웹 화면에 출력해주는 메서드
     */
    @GetMapping("/display")
    @ResponseBody
    public ResponseEntity<Resource> display(@RequestParam("fileName") String fileName) {
        log.info("이미지 출력 요청 파일명: {}", fileName);
        
        // 기본 업로드 경로 (AvatarVO의 avtSaveDt와 맞춰야 함)
        String baseDir = "C:\\team1\\upload\\avt\\"; 
        Resource resource = new FileSystemResource(baseDir + fileName);

        // 만약 파일이 없으면 404 에러 대신 로그를 남기고 빈 응답을 보냄
        if (!resource.exists()) {
            log.warn("파일을 찾을 수 없습니다: {}", baseDir + fileName);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        HttpHeaders header = new HttpHeaders();
        try {
            Path filePath = Paths.get(baseDir + fileName);
            // 파일의 확장자에 맞춰 MIME 타입을 자동으로 설정 (image/png 등)
            header.add("Content-Type", Files.probeContentType(filePath));
        } catch (Exception e) {
            log.error("파일 헤더 설정 중 에러 발생", e);
        }

        return new ResponseEntity<>(resource, header, HttpStatus.OK);
    }
    
    /**
     * 1. 관리자용 게시판 목록 조회
     */
    @PostMapping("/list")
    public ArticlePage<BoardVO> adminList(@RequestBody BoardVO boardVO) {
        Map<String, Object> map = new HashMap<>();
        int currentPage = (boardVO.getCurrentPage() <= 0) ? 1 : boardVO.getCurrentPage();
        int size = 10;
        
        map.put("currentPage", currentPage);
        map.put("keyword", boardVO.getKeyword());
        map.put("deptCd", boardVO.getDeptCd()); 
        map.put("mode", boardVO.getMode());
        map.put("size", size);
        
        log.info("관리자 목록 조회: {}", map);
        
        int total = this.boardService.selectBoardCount(map);
        List<BoardVO> boardList = this.boardService.selectBoardList(map);

        return new ArticlePage<>(total, currentPage, size, boardVO.getKeyword(), boardList, boardVO.getMode(), map);
    }

    /**
     * 2. 게시글 상세 조회 (통합 데이터)
     */
    @GetMapping("/detail/{bbsNo}")
    public BoardVO adminDetail(@PathVariable("bbsNo") int bbsNo, Authentication auth) {
        BoardVO boardVO = this.boardService.selectBoardDetailAll(bbsNo);
        
        if (boardVO != null && auth != null) {
            CustomUser userDetails = (CustomUser) auth.getPrincipal();
            int empId = userDetails.getEmpVO().getEmpId();

            Map<String, Object> paramMap = new HashMap<>();
            paramMap.put("bbsNo", bbsNo);
            paramMap.put("empId", empId);

            List<String> userActions = this.boardService.selectUserActionList(paramMap);
            if (userActions != null) {
                boardVO.setUserLiked(userActions.stream().anyMatch(a -> a.trim().equalsIgnoreCase("LIKE")));
                boardVO.setUserDisliked(userActions.stream().anyMatch(a -> a.trim().equalsIgnoreCase("DISLIKE")));
                boardVO.setUserRecomed(userActions.stream().anyMatch(a -> a.trim().equalsIgnoreCase("RECOM")));
            }
        }
        return boardVO;
    }

    /**
     * 3. 관리자 게시글 등록
     */
    @PostMapping("/create")
    public Map<String, Object> adminCreate(BoardVO boardVO, 
                                         @RequestParam(value="uploadFile", required=false) MultipartFile[] uploadFile,
                                         Authentication auth) {
        Map<String, Object> response = new HashMap<>();
        
        if (auth == null) {
            response.put("result", "fail");
            return response;
        }

        // 1. 사용자 정보 및 기본값 설정
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        boardVO.setEmpId(customUser.getEmpVO().getEmpId());
        
        if (boardVO.getDeptCd() == 0) boardVO.setDeptCd(customUser.getEmpVO().getDeptCd());
        if (boardVO.getBbsType() == null) boardVO.setBbsType("1");

        // [핵심] 2. 파라미터로 받은 파일을 VO 객체에 심어줍니다.
        // Service의 handleFileUpload 메서드가 boardVO.getUploadFiles()를 사용하기 때문입니다.
        if (uploadFile != null && uploadFile.length > 0) {
            log.info("컨트롤러에 수신된 파일 개수: {}", uploadFile.length);
            boardVO.setUploadFiles(uploadFile);
        }

        // 3. 서비스 호출
        int result = this.boardService.insertBoard(boardVO, uploadFile);
        
        response.put("result", result > 0 ? "success" : "fail");
        response.put("bbsNo", boardVO.getBbsNo());
        
        return response;
    }

    /**
     * 4. 게시글 수정
     */
    @PostMapping("/update")
    public Map<String, Object> adminUpdate(BoardVO boardVO,
            @RequestParam(value="delFileDtlIds", required=false) String[] delFileDtlIds, 
            @RequestParam(value="uploadFile", required=false) MultipartFile[] uploadFile) {
        
        boardVO.setDelFileDtlIds(delFileDtlIds);
        int result = this.boardService.updateBoard(boardVO);
        
        Map<String, Object> response = new HashMap<>();
        response.put("result", result > 0 ? "success" : "fail");
        return response;
    }

    /**
     * 5. 게시글 삭제 (관리자 강제 삭제)
     */
    @DeleteMapping("/delete/{bbsNo}")
    public Map<String, Object> adminDelete(@PathVariable("bbsNo") int bbsNo) {
        int result = this.boardService.deleteBoard(bbsNo);
        Map<String, Object> response = new HashMap<>();
        response.put("result", result > 0 ? "success" : "fail");
        return response;
    }

    /**
     * 6. [이식] 댓글 등록 및 알람 발송
     */
    @PostMapping("/registComment")
    public List<CommentVO> registComment(@RequestBody CommentVO commentVO, Authentication auth) {
        if (auth != null) {
            CustomUser userDetails = (CustomUser) auth.getPrincipal();
            EmployeeVO empVO = userDetails.getEmpVO();
            commentVO.setEmpId(empVO.getEmpId());

            // 1. 댓글 등록
            List<CommentVO> commentList = this.commentService.insertCommentAndList(commentVO);

            // 2. 알람 전송 (원글 작성자에게)
            BoardVO boardVO = this.boardService.selectBoardDetail(commentVO.getCmntBbsNo());
            if (boardVO != null && boardVO.getEmpId() != empVO.getEmpId()) {
                AlarmVO alarmVO = new AlarmVO();
                List<Integer> rcvrNoList = new ArrayList<>();
                rcvrNoList.add(boardVO.getEmpId());

                String rawCn = commentVO.getCmntCn();
                String shortComment = (rawCn != null && rawCn.length() > 20) ? rawCn.substring(0, 20) + "..." : rawCn;

                alarmVO.setAlmMsg("[관리자 댓글] " + shortComment);
                alarmVO.setAlmDtl("<span class=\"fw-bold\">관리자(" + empVO.getEmpNm() + "): </span>" + shortComment);
                alarmVO.setAlmRcvrNos(rcvrNoList);
                alarmVO.setAlmIcon("info");

                this.alarmController.sendAlarm(empVO.getEmpId(), alarmVO, "/board/detail?bbsNo=" + boardVO.getBbsNo(), "댓글");
            }
            return commentList;
        }
        return null;
    }

    /**
     * 7. [이식] 댓글 수정 및 삭제
     */
    @PostMapping("/updateComment")
    public List<CommentVO> updateComment(@RequestBody CommentVO commentVO) {
        return this.commentService.updateCommentAndList(commentVO);
    }

    @PostMapping("/deleteComment")
    public List<CommentVO> deleteComment(@RequestBody CommentVO commentVO) {
        return this.commentService.deleteCommentAndList(commentVO);
    }

    /**
     * 8. [이식] 게시글 반응(좋아요/싫어요/추천)
     */
    @PostMapping("/processAction")
    public Map<String, Object> processAction(@RequestBody Map<String, Object> map, Authentication auth) {
        if (auth == null) return null;
        CustomUser userDetails = (CustomUser) auth.getPrincipal();
        int empId = userDetails.getEmpVO().getEmpId();
        
        int bbsNo = Integer.parseInt(map.get("bbsNo").toString());
        String actionType = map.get("actionType").toString();

        return this.boardService.processBoardAction(bbsNo, empId, actionType);
    }

    /**
     * 9. [이식] 신고 접수 (신고 시 관리자 자신에게 혹은 특정 관리자 팀에게 알람)
     */
    @PostMapping("/report")
    public int report(@RequestBody ComplaintVO complaintVO, Authentication auth) {
        if (auth != null) {
            CustomUser userDetails = (CustomUser) auth.getPrincipal();
            complaintVO.setEmpId(userDetails.getEmpVO().getEmpId());
        }
        int result = this.complaintService.insertComplaint(complaintVO);
        
        if (result > 0) {
            AlarmVO alarmVO = new AlarmVO();
            List<Integer> rcvrNoList = new ArrayList<>();
            rcvrNoList.add(1); // 예: 대표 관리자 사번
            
            alarmVO.setAlmMsg("새로운 신고 접수(관리자 확인)");
            alarmVO.setAlmDtl("게시글 " + complaintVO.getDclBbsNo() + "번에 대한 신고가 접수되었습니다.");
            alarmVO.setAlmRcvrNos(rcvrNoList);
            alarmVO.setAlmIcon("warning");
            
            this.alarmController.sendAlarm(complaintVO.getEmpId(), alarmVO, "/admin/complaintList", "신고");
        }
        return result;
    }

    /**
     * 10. 파일 다운로드
     */
    @GetMapping("/download")
    public ResponseEntity<Resource> downloadFile(@RequestParam("fileDtlId") Long fileDtlId) {
        return uploadController.downloadFile(fileDtlId);
    }
}