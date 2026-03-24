package kr.or.ddit.controller;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.Principal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpSession;
import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.BoardService;
import kr.or.ddit.service.CommentService;
import kr.or.ddit.service.ComplaintService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.BoardVO;
import kr.or.ddit.vo.CommentVO;
import kr.or.ddit.vo.ComplaintVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequestMapping("/board")
@Controller
public class BoardController {
	
	@Autowired
	private BoardService boardService;
	
	@Autowired
    private EmployeeMapper employeeMapper;

    @Autowired
    private DepartmentMapper departmentMapper;
    
    @Autowired
    private CommentService commentService;

    @Autowired
    private ComplaintService complaintService;
    
    //알람 발송
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
     * 비동기 부서별 게시판 목록 조회 (NoticeController 구조와 통일)
     */
    @ResponseBody
    @PostMapping("/listAxios")
    public ArticlePage<BoardVO> listAxios(@RequestBody BoardVO boardVO, 
                                         Authentication auth) {
        // 1. 로그인한 사용자 정보 추출
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        // 2. 서비스에 전달할 Map 생성 및 데이터 세팅
        Map<String, Object> map = new HashMap<>();
        
        // 기본 페이징 데이터 처리
        int currentPage = boardVO.getCurrentPage();
        if(currentPage <= 0) currentPage = 1;
        
        int size = 10; 
        
        // 부서 코드 처리
        int myDeptCd = employeeVO.getDeptCd();
        int deptCd = (boardVO.getDeptCd() == 0) ? myDeptCd : boardVO.getDeptCd();

        map.put("currentPage", currentPage);
        map.put("size", size);
        
        // --- [수정 영역] ---
        // VO의 bbsType 필드 값을 가져와서 Mapper가 기대하는 "boardType" 키로 Map에 저장
        map.put("bbsType", boardVO.getBbsType());
        // ------------------
        
        map.put("keyword", boardVO.getKeyword());
        map.put("mode", boardVO.getMode());
        map.put("deptCd", deptCd);
        map.put("empId", employeeVO.getEmpId());

        log.info("부서별 게시판 요청 map : " + map);

        // 3. 전체 행 수 조회 (수정된 map 전달)
        int total = this.boardService.selectBoardCount(map);

        // 4. 목록 조회
        List<BoardVO> boardList = this.boardService.selectBoardList(map);

        // 5. ArticlePage 객체 생성
        ArticlePage<BoardVO> articlePage = new ArticlePage<BoardVO>(
                total, 
                currentPage, 
                size, 
                boardVO.getKeyword(), 
                boardList, 
                boardVO.getMode(), 
                map
        );
        
        return articlePage;
    }
    
    /**
     * 부서별 게시판 상세 화면 호출 및 조회수 제어
     */
    @GetMapping("/detail")
    public ModelAndView detail(int bbsNo, ModelAndView mav, HttpSession session, Authentication authentication) {
        log.info("부서별 게시판 상세 조회 시작 -> 번호: {}", bbsNo);
        
        // 1. 로그인 정보 가져오기 (기존 유지)
        EmployeeVO loginMember = (EmployeeVO) session.getAttribute("employeeVO");
        int empId = 0;
        if (loginMember != null) {
            empId = loginMember.getEmpId();
        } else if (authentication != null && authentication.getPrincipal() instanceof CustomUser) {
            CustomUser userDetails = (CustomUser) authentication.getPrincipal();
            empId = userDetails.getEmpVO().getEmpId();
        }

        // 2. 조회수 관련 로직 (기존 유지)
        Object sessionObj = session.getAttribute("readBoardList");
        Map<Integer, Long> readBoardList = (sessionObj instanceof Map) ? (Map<Integer, Long>) sessionObj : new HashMap<>();
        long currentTime = System.currentTimeMillis();
        long dayInMillis = 24 * 60 * 60 * 1000L;
        boolean isFirstReadOrExpired = false;

        if (!readBoardList.containsKey(bbsNo)) {
            isFirstReadOrExpired = true;
        } else {
            long lastReadTime = readBoardList.get(bbsNo);
            if (currentTime - lastReadTime > dayInMillis) {
                isFirstReadOrExpired = true;
            }
        }

        if (isFirstReadOrExpired) {
            this.boardService.incrementViewCount(bbsNo);
            readBoardList.put(bbsNo, currentTime);
            session.setAttribute("readBoardList", readBoardList);
        }

        // 3. [수정] 상세 데이터 및 댓글/파일 통합 가져오기
        // 이제 맵 설정을 쓰지 않고 서비스에서 직접 합친 VO를 받아옵니다.
        BoardVO boardVO = this.boardService.selectBoardDetailAll(bbsNo); 
        
        if(boardVO == null) {
            mav.setViewName("error/404");
            return mav;
        }

        // 4. [강화] DB 기반 상태 체크 로직 (기존 유지)
        if (empId != 0) {
            Map<String, Object> paramMap = new HashMap<>();
            paramMap.put("bbsNo", bbsNo);
            paramMap.put("empId", empId);

            List<String> userActions = this.boardService.selectUserActionList(paramMap);
            if (userActions != null && !userActions.isEmpty()) {
                boardVO.setUserLiked(userActions.stream().anyMatch(a -> a.trim().equalsIgnoreCase("LIKE")));
                boardVO.setUserDisliked(userActions.stream().anyMatch(a -> a.trim().equalsIgnoreCase("DISLIKE")));
                boardVO.setUserRecomed(userActions.stream().anyMatch(a -> a.trim().equalsIgnoreCase("RECOM")));
            }
        }

        mav.addObject("boardVO", boardVO);
        mav.addObject("contentPage", "board/detail"); 
        mav.setViewName("main"); 
        
        return mav;
    }
    
    /**
     * 비동기 상세 데이터 조회 (Axios 호출용)
     */
    @ResponseBody
    @PostMapping("/detailAxios")
    public BoardVO detailAxios(@RequestBody Map<String, Object> map) {
        // Axios에서 보낸 JSON 데이터에서 bbsNo 추출
        int bbsNo = Integer.parseInt(map.get("bbsNo").toString());
        log.info("board detailAxios -> bbsNo : {}", bbsNo);
        
        // 동일하게 통합 서비스 호출
        return this.boardService.selectBoardDetailAll(bbsNo);
    }
    
    /**
     * 자료 등록 페이지 호출
     */
    @GetMapping("/create")
    public ModelAndView create(ModelAndView mav) {
        // 1. 실제 알맹이가 될 JSP 경로를 모델에 담습니다.
        // main.jsp의 <jsp:include page="/WEB-INF/views/${contentPage}.jsp" /> 부분으로 전달됩니다.
        mav.addObject("contentPage", "board/create");
        
        // 2. 뷰 이름을 반드시 "main"으로 설정해야 레이아웃(사이드바, CSS 등)이 적용됩니다.
        mav.setViewName("main");
        
        return mav;
    }
    
    /**
     * 부서별 게시판 등록 처리 (MultipartFile 포함)
     */
    @ResponseBody
    @PostMapping("/createAjax")
    public Map<String, Object> createAjax(BoardVO boardVO, MultipartFile[] uploadFile, Authentication authentication) {
        Map<String, Object> map = new HashMap<>();

        // 1. 사용자 인증 체크 (기존 로직)
        if (authentication != null && authentication.isAuthenticated()) {
            CustomUser userDetails = (CustomUser) authentication.getPrincipal();
            EmployeeVO empVO = userDetails.getEmpVO(); 
            boardVO.setEmpId(empVO.getEmpId());         
            boardVO.setDeptCd(empVO.getDeptCd());   
        } else {
            map.put("result", "login_required");
            return map;
        }

        // 🚩 [강화된 검증] 제목/내용 글자수 체크
        // 제목이 null이거나 100자를 초과하는 경우
        if (boardVO.getBbsNm() == null || boardVO.getBbsNm().trim().isEmpty()) {
            map.put("result", "failed");
            map.put("message", "제목을 입력해주세요.");
            return map;
        }
        if (boardVO.getBbsNm().length() > 100) {
            log.warn("등록 거부: 제목 글자수 초과 ({}자)", boardVO.getBbsNm().length());
            map.put("result", "failed");
            map.put("message", "제목은 100자 이내로 작성 가능합니다.");
            return map; // 🚩 여기서 리턴되므로 아래 insertBoard는 절대 실행 안 됨
        }

        // 내용이 null이거나 2000자를 초과하는 경우
        if (boardVO.getBbsCn() == null || boardVO.getBbsCn().trim().isEmpty()) {
            map.put("result", "failed");
            map.put("message", "내용을 입력해주세요.");
            return map;
        }
        if (boardVO.getBbsCn().length() > 2000) {
            log.warn("등록 거부: 내용 글자수 초과 ({}자)", boardVO.getBbsCn().length());
            map.put("result", "failed");
            map.put("message", "내용은 2000자 이내로 작성 가능합니다.");
            return map; // 🚩 여기서 차단
        }

        // 2. 분류 설정 및 로그 기록 (기존 로직)
        log.info("최종 확인 - empId: {}, deptCd: {}, bbsType: {}", 
                boardVO.getEmpId(), boardVO.getDeptCd(), boardVO.getBbsType());

        if(boardVO.getBbsType() == null || boardVO.getBbsType().isEmpty()) {
            boardVO.setBbsType("1"); 
        }

        log.info("로그인 정보가 주입된 boardVO : {}", boardVO);
        
        // 3. 실제 DB 저장 (위의 모든 return을 통과해야만 여기까지 옴)
        int result = this.boardService.insertBoard(boardVO, uploadFile);
        
        map.put("result", result > 0 ? "success" : "failed");
        map.put("bbsNo", boardVO.getBbsNo());
        
        return map;
    }
    
    /**
     * 자료 수정 페이지 호출 (GET)
     */
    @GetMapping("/update")
    public ModelAndView update(int bbsNo, ModelAndView mav, Authentication authentication) {
    	BoardVO boardVO = new BoardVO();
    	boardVO.setBbsNo(bbsNo);
    	BoardVO board = this.boardService.selectBoardDetail(bbsNo);
        
        String loginId = authentication.getName();
        boolean isAdmin = authentication.getAuthorities().stream()
                            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        // 작성자 본인이거나 관리자이면 통과, 아니면 튕겨내기
        if (!String.valueOf(board.getEmpId()).equals(loginId) && !isAdmin) {
            mav.setViewName("redirect:/board/detail?bbsNo=" + bbsNo);
            return mav;
        }
        
        mav.addObject("boardVO", board);
        mav.addObject("contentPage", "board/update");
        mav.setViewName("main");
        return mav;
    }
    
    /**
     * 비동기 자료 수정 (POST)
     */
    @ResponseBody
    @PostMapping("/updateAxios") 
    public Map<String, Object> updateAxios(BoardVO boardVO, MultipartFile[] uploadFile, Principal principal) { 
        log.info("board updateAxios -> boardVO : {}", boardVO);
        
        Map<String, Object> map = new HashMap<>();
        
        // 1. [보안] 작성자 본인 확인 (기존 로직 유지)
        BoardVO checkBoard = this.boardService.selectBoardDetail(boardVO.getBbsNo());
        String loginId = principal.getName();
        
        if (checkBoard == null || !String.valueOf(checkBoard.getEmpId()).equals(loginId)) {
            map.put("result", "failed");
            map.put("message", "수정 권한이 없습니다.");
            return map;
        }

        // 🚩 [검증 강화] 제목 글자수 제한 체크 (100자 이상 차단)
        if (boardVO.getBbsNm() == null || boardVO.getBbsNm().trim().isEmpty()) {
            map.put("result", "failed");
            map.put("message", "수정할 제목을 입력해주세요.");
            return map;
        }
        if (boardVO.getBbsNm().length() >= 100) { // 100자 포함 이상이면 차단
            log.warn("수정 거절: 제목 글자수 초과 ({}/100)", boardVO.getBbsNm().length());
            map.put("result", "failed");
            map.put("message", "제목은 100자 미만으로만 수정 가능합니다.");
            return map;
        }

        // 🚩 [검증 강화] 내용 글자수 제한 체크 (2000자 이상 차단)
        if (boardVO.getBbsCn() == null || boardVO.getBbsCn().trim().isEmpty()) {
            map.put("result", "failed");
            map.put("message", "수정할 내용을 입력해주세요.");
            return map;
        }
        if (boardVO.getBbsCn().length() >= 2000) { // 2000자 포함 이상이면 차단
            log.warn("수정 거절: 내용 글자수 초과 ({}/2000)", boardVO.getBbsCn().length());
            map.put("result", "failed");
            map.put("message", "내용은 2000자 미만으로만 수정 가능합니다.");
            return map;
        }
        
        // 2. 수정 진행 (위의 모든 검증을 통과해야만 실행됨)
        int result = this.boardService.updateBoard(boardVO);
        
        if(result > 0) {
            map.put("result", "success");
        } else {
            map.put("result", "failed");
            map.put("message", "데이터 수정 중 서버 오류가 발생했습니다.");
        }
        
        return map;
    }
    
    /**
     * 자료 삭제 처리 (작성자 본인 또는 관리자만 가능)
     */
    @GetMapping("/delete")
    public String delete(int bbsNo, Authentication authentication) {
        log.info("자료 삭제 요청 -> 번호: {}, 요청자: {}", bbsNo, authentication.getName());
        
        // 1. 상세 데이터 조회
        BoardVO boardVO = new BoardVO();
        boardVO.setBbsNo(bbsNo);
        BoardVO board = this.boardService.selectBoardDetail(bbsNo);
        
        if (board == null) {
            return "redirect:/board";
        }

        // 2. 권한 체크
        String loginId = authentication.getName(); // 사번 (String)
        
        // 관리자 권한 여부 확인 (ROLE_ADMIN 권한이 있는지 체크)
        boolean isAdmin = authentication.getAuthorities().stream()
                            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        
        // 작성자 본인도 아니고 관리자도 아니라면 차단
        if (!String.valueOf(board.getEmpId()).equals(loginId) && !isAdmin) {
            log.warn("권한 없는 삭제 시도 차단! 사번: {}, 권한: {}", loginId, authentication.getAuthorities());
            return "redirect:/board/detail?bbsNo=" + bbsNo;
        }
        
        // 3. 권한 통과 시 삭제 수행
        int result = this.boardService.deleteBoard(bbsNo);
        
        if(result > 0) {
            log.info("자료 삭제 완료 -> 번호: {}", bbsNo);
            return "redirect:/board"; 
        } else {
            return "redirect:/board/detail?bbsNo=" + bbsNo;
        }
    }
    
    /**
     * 비동기 자료 삭제
     */
    @ResponseBody
    @PostMapping("/deleteAxios")
    public Map<String, Object> deleteAxios(@RequestBody Map<String, Integer> map) {
        int bbsNo = map.get("bbsNo");
        log.info("board deleteAxios -> bbsNo : {}", bbsNo);
        
        int result = this.boardService.deleteBoard(bbsNo);
        Map<String, Object> response = new HashMap<>();
        response.put("result", result > 0 ? "success" : "failed");
        return response;
    }
    
    @ResponseBody
    @PostMapping("/registComment")
    public List<CommentVO> registComment(@RequestBody CommentVO commentVO, Authentication authentication) {
        int empId = 0;
        String empNm = "사용자";
        String empJbgd = "";

        if (authentication != null) {
            CustomUser userDetails = (CustomUser) authentication.getPrincipal();
            empId = userDetails.getEmpVO().getEmpId();
            empNm = userDetails.getEmpVO().getEmpNm();
            empJbgd = userDetails.getEmpVO().getEmpJbgd();
            commentVO.setEmpId(empId);
        }

        // 1. 댓글 등록 실행
        List<CommentVO> commentList = this.commentService.insertCommentAndList(commentVO);

        // 2. 알람 로직: 원글 작성자에게 전송
        BoardVO boardVO = this.boardService.selectBoardDetail(commentVO.getCmntBbsNo()); 
        int boardWriterId = boardVO.getEmpId();

        // 자기 자신이 쓴 글에 댓글을 남긴 게 아닐 때만 알람 전송
        if (boardWriterId != 0 && boardWriterId != empId) {
            AlarmVO alarmVO = new AlarmVO();
            List<Integer> rcvrNoList = new ArrayList<>();
            rcvrNoList.add(boardWriterId);

            // 댓글 내용이 너무 길면 잘라주기 (말줄임 처리)
            String rawComment = commentVO.getCmntCn(); // 댓글 내용 추출
            String shortComment = (rawComment != null && rawComment.length() > 20) 
                                  ? rawComment.substring(0, 20) + "..." 
                                  : rawComment;

            // [변경] 알람 상단 문구를 댓글 내용으로 설정
            alarmVO.setAlmMsg("[댓글] " + shortComment);

            // [변경] 상세 내용을 "이름 직급 : 댓글내용" 형식으로 변경하여 채팅 알람과 통일
            alarmVO.setAlmDtl("<span class=\"fw-bold\">" + empNm + " " + empJbgd + " : </span>" + shortComment);
            
            alarmVO.setAlmRcvrNos(rcvrNoList);
            alarmVO.setAlmIcon("info");

            // 상세페이지 이동 URL
            String detailUrl = "/board/detail?bbsNo=" + commentVO.getCmntBbsNo();
            
            // alarmController의 sendAlarm을 통해 웹소켓 실시간 전송 및 DB 저장
            this.alarmController.sendAlarm(empId, alarmVO, detailUrl, "댓글");
        }

        return commentList;
    }

    /**
     * 댓글 수정 (Axios 비동기)
     */
    @ResponseBody
    @PostMapping("/updateComment")
    public List<CommentVO> updateComment(@RequestBody CommentVO commentVO) {
        log.info("updateComment->commentVO : {}", commentVO);
        return this.commentService.updateCommentAndList(commentVO);
    }

    /**
     * 댓글 삭제 (Axios 비동기)
     */
    @ResponseBody
    @PostMapping("/deleteComment")
    public List<CommentVO> deleteComment(@RequestBody CommentVO commentVO) {
        log.info("deleteComment->commentVO : {}", commentVO);
        return this.commentService.deleteCommentAndList(commentVO);
    }

    @ResponseBody
    @PostMapping("/toggleLike")
    public int toggleLike(@RequestBody Map<String, Object> map, Authentication authentication) {
        int empId = 0;
        String empNm = "사용자";
        if (authentication != null) {
            CustomUser userDetails = (CustomUser) authentication.getPrincipal();
            empId = userDetails.getEmpVO().getEmpId();
            empNm = userDetails.getEmpVO().getEmpNm();
        }

        // 1. 좋아요 토글 실행
        int result = this.commentService.toggleCommentLike(map);

        // 2. 알람 로직: 좋아요가 추가(result > 0)된 경우에만 전송
        if (result > 0) {
            // map에 담겨온 댓글 번호를 꺼냄
            int cmntNo = Integer.parseInt(map.get("cmntNo").toString());
            
            // [방금 추가한 메서드 사용] 댓글 정보를 가져옴
            CommentVO commentVO = this.commentService.selectCommentDetail(cmntNo);
            
            if (commentVO != null) {
                int commentWriterId = commentVO.getEmpId(); // 댓글 작성자 사번

                // 본인 댓글이 아닐 때만 알람 발송
                if (commentWriterId != 0 && commentWriterId != empId) {
                    AlarmVO alarmVO = new AlarmVO();
                    List<Integer> rcvrNoList = new ArrayList<>();
                    rcvrNoList.add(commentWriterId);

                    alarmVO.setAlmMsg("내 댓글에 좋아요가 눌렸습니다");
                    alarmVO.setAlmDtl("<span class=\"fw-bold\">" + empNm + "</span>님이 회원님의 댓글을 좋아합니다.");
                    alarmVO.setAlmRcvrNos(rcvrNoList);
                    alarmVO.setAlmIcon("warning");

                    // 상세페이지 이동 URL (게시글 번호 사용)
                    String detailUrl = "/board/detail?bbsNo=" + commentVO.getCmntBbsNo();
                    this.alarmController.sendAlarm(empId, alarmVO, detailUrl, "좋아요");
                }
            }
        }
        return result;
    }

    /**
     * 신고 접수
     * 성공 시 결과 코드(1) 반환
     */
    @ResponseBody
    @PostMapping("/report")
    public int report(@RequestBody ComplaintVO complaintVO, Authentication authentication) {
        int empId = 0;
        String empNm = "신고자";

        if (authentication != null) {
            CustomUser userDetails = (CustomUser) authentication.getPrincipal();
            empId = userDetails.getEmpVO().getEmpId();
            empNm = userDetails.getEmpVO().getEmpNm();
            complaintVO.setEmpId(empId);
        }

        // 1. 신고 접수 실행
        int result = this.complaintService.insertComplaint(complaintVO);

        // 2. 알람 로직: 관리자에게 전송
        if (result > 0) {
            AlarmVO alarmVO = new AlarmVO();
            
            // 관리자 사번 설정 (예시: 1번)
            List<Integer> rcvrNoList = new ArrayList<>();
            rcvrNoList.add(1); 

            alarmVO.setAlmMsg("새로운 신고가 접수되었습니다");
            alarmVO.setAlmDtl(
                    "<span class=\"fw-bold\">" + empNm + "</span>님이 게시글 번호 <span class=\"fw-bold text-danger\">" + 
                    complaintVO.getDclBbsNo() + "</span>을 신고했습니다.");
            alarmVO.setAlmRcvrNos(rcvrNoList);
            alarmVO.setAlmIcon("warning");

            // 관리자용 신고 확인 페이지
            this.alarmController.sendAlarm(empId, alarmVO, "/admin/complaintList", "신고");
        }

        return result;
    }
    
    /**
     * [통합 액션 처리] 좋아요, 싫어요, 추천을 하나의 메서드에서 처리하네.
     */
    @ResponseBody
    @PostMapping("/processAction")
    public Map<String, Object> processAction(@RequestBody Map<String, Object> map, Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        
        // 1. 로그인 체크 및 사번 추출
        if (authentication == null || !authentication.isAuthenticated()) {
            response.put("resultCode", -2); // 비로그인 상태
            return response;
        }
        
        CustomUser userDetails = (CustomUser) authentication.getPrincipal();
        int empId = userDetails.getEmpVO().getEmpId(); // 현재 로그인한 사번

        // 2. 파라미터 추출
        int bbsNo = Integer.parseInt(map.get("bbsNo").toString());
        String actionType = map.get("actionType").toString(); // "LIKE", "DISLIKE", "RECOM"

        log.info("액션 요청 - 사번: {}, 글번호: {}, 타입: {}", empId, bbsNo, actionType);

        // 3. 서비스 호출 (DB 장부 기록 및 카운트 증감 처리를 한 번에!)
        // 이 메서드는 우리가 이전에 ServiceImpl에 만들기로 했던 그 메서드네.
        Map<String, Object> result = this.boardService.processBoardAction(bbsNo, empId, actionType);
        
        // 결과 반환 (resultCode: 1(등록), 2(취소), -1(본인글))
        return result; 
    }
    
    // 상세페이지 로드 시 사용자의 반응 리스트 조회
    @GetMapping("/board/userActions")
    @ResponseBody
    public List<String> getUserActions(@RequestParam int bbsNo, Principal principal) {
        // 1. 로그인 체크
        if (principal == null) return new ArrayList<>();
        
        // 2. 파라미터 설정
        Map<String, Object> map = new HashMap<>();
        map.put("bbsNo", bbsNo);
        map.put("empId", principal.getName()); // 시큐리티의 username(사번 등)
        
        // 3. 사용자가 해당 게시글에 취한 액션 리스트(['LIKE', 'RECOM'] 등) 조회하여 반환
        return boardService.selectUserActionList(map);
    }
    
}
