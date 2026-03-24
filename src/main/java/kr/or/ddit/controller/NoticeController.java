package kr.or.ddit.controller;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpSession;
import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.NoticeService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.NoticeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequestMapping("/notice")
@Controller
public class NoticeController {

    @Autowired
    NoticeService noticeService;
    
    @Autowired
    private EmployeeMapper employeeMapper;

    @Autowired
    private DepartmentMapper departmentMapper;
    
    
    /**
     * 공지사항 메인 화면 (기존 calendarMain 로직 통합)
     * URL: /notice/main
     */
	/*
	 * @GetMapping("/main") public String noticeMain(Model model, Authentication
	 * authentication) { model.addAttribute("contentPage", "notice/list");
	 * 
	 * if (authentication != null) { CustomUser customUser = (CustomUser)
	 * authentication.getPrincipal(); EmployeeVO loginUserVO =
	 * customUser.getEmpVO();
	 * 
	 * // 팀원 출력 로직(teamList)을 삭제해도 무방함 model.addAttribute("deptNm",
	 * loginUserVO.getDeptNm()); } return "main"; }
	 */
    
    /**
     * 공지사항 목록 화면 호출
     */
	/*
	 * @GetMapping("/list") public ModelAndView list(ModelAndView mav,
	 * Authentication authentication) { // 1. 절대 "notice/list"를 직접 setViewName 하면 안
	 * 됩니다! // 그러면 껍데기 없이 알맹이만 나오거나, 설정에 따라 무한 중첩이 발생합니다. mav.setViewName("main");
	 * // 껍데기(layout) 파일명
	 * 
	 * // 2. main.jsp 내부의 <jsp:include page="/WEB-INF/views/${contentPage}.jsp" />
	 * 부분에 // 갈아끼워질 실제 파일 경로만 넘깁니다. mav.addObject("contentPage", "notice/list");
	 * 
	 * // 3. 사이드바에 유저 이름이 나오게 하려면 세션 정보도 함께 보냅니다. if (authentication != null) {
	 * CustomUser customUser = (CustomUser) authentication.getPrincipal();
	 * mav.addObject("employeeVO", customUser.getEmpVO()); }
	 * 
	 * return mav; }
	 */
    
    @GetMapping("/list")
    public ModelAndView noticeList(ModelAndView mav, Authentication authentication) {
        // 1. 실제 화면의 껍데기(layout)인 main.jsp를 호출합니다.
        mav.setViewName("main"); 
        
        // 2. main.jsp 안의 <jsp:include>가 불러올 실제 공지사항 목록 파일 경로입니다.
        // /WEB-INF/views/notice/list.jsp 를 불러오게 됩니다.
        mav.addObject("contentPage", "notice/list");
        
        // 3. 사이드바와 헤더에 로그인한 사용자 정보(고누리 사원 등)가 나오게 데이터를 주입합니다.
        if (authentication != null) {
            CustomUser customUser = (CustomUser) authentication.getPrincipal();
            // JSP에서 사용하는 변수명인 employeeVO로 넘겨줍니다.
            mav.addObject("employeeVO", customUser.getEmpVO());
        }
        
        log.info("공지사항 목록 페이지 호출 (레이아웃 포함)");
        return mav;
    }
    
    /**
     * 비동기 공지사항 목록 조회 (Axios 전용)
     * 카드형 레이아웃(한 줄에 6개)에 최적화하여 수정
     */
    @ResponseBody
    @PostMapping("/listAxios")
    public ArticlePage<NoticeVO> listAxios(@RequestBody NoticeVO noticeVO, Authentication auth) {
        // 1. 사용자 정보 추출
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        // 2. null 방어 로직
        String keyword = (noticeVO.getKeyword() == null) ? "" : noticeVO.getKeyword();
        String mode = (noticeVO.getMode() == null) ? "" : noticeVO.getMode();
        // [중요] JSP에서 보낸 카테고리(긴급/중요/일반) 값을 가져옵니다.
        String ntcStts = (noticeVO.getNtcStts() == null) ? "" : noticeVO.getNtcStts();
        
        int currentPage = (noticeVO.getCurrentPage() <= 0) ? 1 : noticeVO.getCurrentPage();
        int size = 10;

        // 3. 서비스 전달용 Map 구성
        Map<String, Object> map = new HashMap<>();
        map.put("currentPage", currentPage);
        map.put("mode", mode);       
        map.put("keyword", keyword); 
        map.put("ntcStts", ntcStts); // ⭐ 이 한 줄이 빠져있어서 필터링이 안 됐던 겁니다!
        map.put("empId", employeeVO.getEmpId());
        map.put("size", size);
        map.put("url", "/notice/list"); 

        log.info("공지사항 요청 map (ntcStts 포함) : " + map);

        // 4. 데이터 조회 (이제 map 안에 ntcStts가 있으므로 Mapper의 <if>문이 작동합니다)
        int total = this.noticeService.selectNoticeCount(map);
        List<NoticeVO> noticeList = this.noticeService.selectNoticeList(map);

        // 5. ArticlePage 객체 생성 
        ArticlePage<NoticeVO> articlePage = new ArticlePage<NoticeVO>(
                total, 
                currentPage, 
                size, 
                keyword,    
                noticeList, 
                mode,       
                map
        );
        
        // [참고] ArticlePage 생성자에서 ntcStts를 따로 관리하지 않는다면 
        // 나중에 페이징 클릭 시 필터가 유지되도록 articlePage 구성도 확인이 필요할 수 있습니다.

        return articlePage;
    }
    /**
     * 공지사항 상세 화면 호출 및 조회수 제어
     * @param ntcNo   조회할 게시글 번호
     * @param mav     ModelAndView 객체
     * @param session 사용자의 브라우저 세션 (조회 기록 저장용)
     * @param authentication 스프링 시큐리티 권한 정보 (사이드바 출력용)
     * @return 공지사항 상세 페이지 및 데이터
     */
    @GetMapping("/detail")
    public ModelAndView detail(int ntcNo, ModelAndView mav, HttpSession session, Authentication authentication) {
        log.info("공지사항 상세 조회 시작 -> 글번호: {}", ntcNo);
        
        // 1~4. 조회수 제어 로직
        Object sessionObj = session.getAttribute("readNotices");
        Map<Integer, Long> readNotices = (sessionObj instanceof Map) ? (Map<Integer, Long>) sessionObj : new HashMap<>();

        long currentTime = System.currentTimeMillis();
        long dayInMillis = 24 * 60 * 60 * 1000L;
        boolean isFirstReadOrExpired = !readNotices.containsKey(ntcNo) || (currentTime - readNotices.get(ntcNo) > dayInMillis);

        if (isFirstReadOrExpired) {
            this.noticeService.incrementViewCount(ntcNo);
            readNotices.put(ntcNo, currentTime);
            session.setAttribute("readNotices", readNotices);
            log.info("조회수 증가 처리 완료: 글번호 {}", ntcNo);
        }

        // 5. 실제 게시글 상세 데이터 가져오기
        NoticeVO noticeVO = new NoticeVO();
        noticeVO.setNtcNo(ntcNo);
        NoticeVO data = this.noticeService.selectNoticeDetail(noticeVO);
        
        // 6. [수정] 껍데기(main.jsp) 호출 및 데이터 전달
        mav.addObject("noticeVO", data);
        
        // 6-1. main.jsp를 뷰로 설정
        mav.setViewName("main"); 
        
        // 6-2. main.jsp의 <jsp:include>가 불러올 알맹이 경로 설정
        mav.addObject("contentPage", "notice/detail");
        
        // 6-3. [중요] 사이드바 및 헤더에 필요한 유저 정보 주입
        if (authentication != null) {
            CustomUser customUser = (CustomUser) authentication.getPrincipal();
            // main.jsp나 sidebar.jsp에서 사용하는 변수명(employeeVO)에 맞게 전달
            mav.addObject("employeeVO", customUser.getEmpVO());
        }
        
        return mav;
    }
    /**
     * 비동기 상세 데이터 조회 (Axios 호출용)
     * 화면 이동 방식(detail)을 사용한다면 이 메서드는 조회수를 올리지 않아야 합니다.
     */
    @ResponseBody
    @PostMapping("/detailAxios")
    public NoticeVO detailAxios(@RequestBody NoticeVO noticeVO) {
        log.info("detailAxios -> noticeVO : {}", noticeVO);
        
        // 화면 이동 시 이미 올렸다면 여기서는 조회수를 올리지 않습니다. (중복 방지)
        // 만약 화면 이동 없이 순수하게 데이터만 새로고침하는 용도라면 유지하되 
        // 서비스 내부 로직과 겹치는지 꼭 확인하세요.
        return this.noticeService.selectNoticeDetail(noticeVO);
    }
    
    /**
     * 공지사항 등록 페이지 호출
     */
    @ResponseBody
    @PostMapping("/createAjax")
    public Map<String, Object> createAjax(NoticeVO noticeVO, MultipartFile[] uploadFiles) {
        log.info("createAjax -> noticeVO : {}", noticeVO);
        
        // 1. 전달받은 파일 배열을 NoticeVO 객체 내부의 필드에 저장합니다.
        if(uploadFiles != null && uploadFiles.length > 0) {
            log.info("uploadFiles count : {}", uploadFiles.length);
            noticeVO.setUploadFiles(uploadFiles); // VO 내부에 선언된 필드에 세팅
        }
        
        // 2. 이제 서비스의 insertNotice는 파라미터를 하나만(noticeVO) 받으면 됩니다.
        // 서비스 내부의 handleFileUpload(noticeVO)가 이 파일을 꺼내서 처리할 것입니다.
        int result = this.noticeService.insertNotice(noticeVO); 
        
        Map<String, Object> map = new HashMap<>();
        map.put("result", result > 0 ? "success" : "failed");
        map.put("ntcNo", noticeVO.getNtcNo());
        
        return map;
    }

    /**
     * 비동기 공지사항 수정
     */
    @ResponseBody
    @PostMapping("/updateAxios")
    public Map<String, Object> updateAxios(@RequestBody NoticeVO noticeVO) {
        log.info("updateAxios -> noticeVO : {}", noticeVO);
        
        int result = this.noticeService.updateNotice(noticeVO);
        Map<String, Object> map = new HashMap<>();
        map.put("result", result > 0 ? "success" : "failed");
        return map;
    }

    /**
     * 비동기 공지사항 삭제 (논리 삭제 처리)
     */
    @ResponseBody
    @PostMapping("/deleteAxios")
    public Map<String, Object> deleteAxios(@RequestBody Map<String, Integer> map) {
        int ntcNo = map.get("ntcNo");
        log.info("deleteAxios -> ntcNo : {}", ntcNo);
        
        int result = this.noticeService.deleteNotice(ntcNo);
        Map<String, Object> response = new HashMap<>();
        response.put("result", result > 0 ? "success" : "failed");
        return response;
    }
    
    @ResponseBody
    @GetMapping("/urgent")
    public NoticeVO getUrgentNotice() {
        // 1. 상태가 '긴급'이고
        // 2. 삭제되지 않았으며
        // 3. 가장 최근에 등록된 공지 1건을 가져오는 로직
        return this.noticeService.selectLatestUrgentNotice();
    }
}