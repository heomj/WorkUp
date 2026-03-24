package kr.or.ddit.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.security.Principal;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpSession;
import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.service.DataService;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.DataVO;
import lombok.extern.slf4j.Slf4j;
import kr.or.ddit.vo.EmployeeVO;

@Slf4j
@RequestMapping("/data")
@Controller
public class DataController {

    @Autowired
    private DataService dataService;
    
    @Autowired
    private EmployeeMapper employeeMapper;

    @Autowired
    private DepartmentMapper departmentMapper;
    
    /**
     * 자료실 메인 화면 (기존 calendarMain 로직 통합)
     * URL: /notice/main
     */
	/*
	 * @GetMapping("/main") public String dataMain(Model model, Authentication
	 * authentication) { model.addAttribute("contentPage", "data/list");
	 * 
	 * if (authentication != null) { CustomUser customUser = (CustomUser)
	 * authentication.getPrincipal(); EmployeeVO loginUserVO =
	 * customUser.getEmpVO();
	 * 
	 * // 팀원 출력 로직(teamList)을 삭제해도 무방함 model.addAttribute("deptNm",
	 * loginUserVO.getDeptNm()); } return "main"; }
	 */

    /**
     * 자료실 목록 화면 호출
     */
	/*
	 * @GetMapping("/list") public ModelAndView list(ModelAndView mav,
	 * Authentication authentication) { // 1. 절대 "notice/list"를 직접 setViewName 하면 안
	 * 됩니다! // 그러면 껍데기 없이 알맹이만 나오거나, 설정에 따라 무한 중첩이 발생합니다. mav.setViewName("main");
	 * // 껍데기(layout) 파일명
	 * 
	 * // 2. main.jsp 내부의 <jsp:include page="/WEB-INF/views/${contentPage}.jsp" />
	 * 부분에 // 갈아끼워질 실제 파일 경로만 넘깁니다. mav.addObject("contentPage", "data/list");
	 * 
	 * // 3. 사이드바에 유저 이름이 나오게 하려면 세션 정보도 함께 보냅니다. if (authentication != null) {
	 * CustomUser customUser = (CustomUser) authentication.getPrincipal();
	 * mav.addObject("employeeVO", customUser.getEmpVO()); }
	 * 
	 * return mav; }
	 */

    /**
     * 비동기 자료실 목록 조회 (NoticeController 구조와 통일)
     */
    @ResponseBody
    @PostMapping("/listAxios")
    public ArticlePage<DataVO> listAxios(@RequestBody DataVO dataVO, 
                                         Authentication auth) {
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        Map<String, Object> map = new HashMap<>();
        
        int currentPage = dataVO.getCurrentPage();
        if(currentPage <= 0) currentPage = 1;
        
        int size = 10; 
        
        map.put("currentPage", currentPage);
        map.put("keyword", dataVO.getKeyword());
        map.put("mode", dataVO.getMode());
        
        // [수정 포인트] JSP에서 보낸 dataType(카테고리 번호)을 Map에 담아야 Mapper의 <if>문이 작동합니다.
        map.put("dataType", dataVO.getDataType()); 
        
        map.put("empId", employeeVO.getEmpId()); 
        map.put("size", size);

        log.info("자료실 요청 map : " + map);

        int total = this.dataService.selectDataCount(map);
        List<DataVO> dataList = this.dataService.selectDataList(map);

        // 페이징 객체 생성 시에도 dataType을 유지하기 위해 마지막 인자로 map을 넘깁니다.
        ArticlePage<DataVO> articlePage = new ArticlePage<DataVO>(
                total, 
                currentPage, 
                size, 
                dataVO.getKeyword(), 
                dataList, 
                dataVO.getMode(), 
                map
        );
        
        return articlePage;
    }
    /**
     * 자료실 상세 화면 호출 및 조회수 제어 (24시간 로직 반영)
     */
    @GetMapping("/detail")
    public ModelAndView detail(int dataNo, ModelAndView mav, HttpSession session) {
        log.info("자료실 상세 조회 시작 -> 번호: {}", dataNo);
        
        // 1. 세션에서 읽은 기록 Map 추출 및 타입 안전성 체크
        Object sessionObj = session.getAttribute("readDataList");
        Map<Integer, Long> readDataList = (sessionObj instanceof Map) ? (Map<Integer, Long>) sessionObj : new HashMap<>();

        long currentTime = System.currentTimeMillis();
        long dayInMillis = 24 * 60 * 60 * 1000L;
        boolean isFirstReadOrExpired = false;

        // 2. 24시간 이내 조회 여부 판단
        if (!readDataList.containsKey(dataNo)) {
            isFirstReadOrExpired = true;
        } else {
            long lastReadTime = readDataList.get(dataNo);
            if (currentTime - lastReadTime > dayInMillis) {
                isFirstReadOrExpired = true;
            }
        }

        // 3. 조회수 증가 처리
        if (isFirstReadOrExpired) {
            this.dataService.incrementViewCount(dataNo);
            readDataList.put(dataNo, currentTime);
            session.setAttribute("readDataList", readDataList);
            log.info("자료실 조회수 증가 완료: 번호 {}", dataNo);
        }

        // 4. 상세 데이터 가져오기
        DataVO dataVO = new DataVO();
        dataVO.setDataNo(dataNo);
        DataVO data = this.dataService.selectDataDetail(dataVO);
        
        // 화면에 뿌릴 데이터 담기
        mav.addObject("dataVO", data);
        
        // LoginController에서 하셨던 것과 같은 원리입니다.
        mav.addObject("contentPage", "data/detail"); 
        
        //뷰 이름을 "data/detail"이 아니라 레이아웃 파일인 "main"으로 변경
        mav.setViewName("main"); 
        
        return mav;
    }

    /**
     * 비동기 상세 데이터 조회 (Axios 호출용)
     */
    @ResponseBody
    @PostMapping("/detailAxios")
    public DataVO detailAxios(@RequestBody DataVO dataVO) {
        log.info("data detailAxios -> dataVO : {}", dataVO);
        return this.dataService.selectDataDetail(dataVO);
    }
    
    /**
     * 자료 등록 페이지 호출
     */
    @GetMapping("/create")
    public ModelAndView create(ModelAndView mav) {
        // 1. 실제 알맹이가 될 JSP 경로를 모델에 담습니다.
        // main.jsp의 <jsp:include page="/WEB-INF/views/${contentPage}.jsp" /> 부분으로 전달됩니다.
        mav.addObject("contentPage", "data/create");
        
        // 2. 뷰 이름을 반드시 "main"으로 설정해야 레이아웃(사이드바, CSS 등)이 적용됩니다.
        mav.setViewName("main");
        
        return mav;
    }

    /**
     * 자료 등록 처리 (MultipartFile 포함)
     */
    @ResponseBody
    @PostMapping("/createAjax")
    public Map<String, Object> createAjax(DataVO dataVO, MultipartFile[] uploadFile, Authentication authentication) {
        Map<String, Object> map = new HashMap<>();

        // 1. 사용자 인증 체크
        if (authentication != null && authentication.isAuthenticated()) {
            CustomUser userDetails = (CustomUser) authentication.getPrincipal();
            EmployeeVO empVO = userDetails.getEmpVO(); 
            dataVO.setEmpId(empVO.getEmpId());         
            dataVO.setDataDeptCd(empVO.getDeptCd());   
        } else {
            map.put("result", "login_required");
            return map;
        }

        // 🚩 [검증 강화] 제목 유효성 및 글자수 체크 (100자)
        if (dataVO.getDataNm() == null || dataVO.getDataNm().trim().isEmpty()) {
            map.put("result", "failed");
            map.put("message", "제목을 입력해주세요.");
            return map;
        }
        if (dataVO.getDataNm().length() > 100) {
            log.warn("등록 거부: 제목 글자수 초과 ({}자)", dataVO.getDataNm().length());
            map.put("result", "failed");
            map.put("message", "제목은 100자 이내로 작성 가능합니다.");
            return map;
        }

        // 🚩 [검증 강화] 내용 유효성 및 글자수 체크 (2000자)
        if (dataVO.getDataCn() == null || dataVO.getDataCn().trim().isEmpty()) {
            map.put("result", "failed");
            map.put("message", "내용을 입력해주세요.");
            return map;
        }
        if (dataVO.getDataCn().length() > 2000) {
            log.warn("등록 거부: 내용 글자수 초과 ({}자)", dataVO.getDataCn().length());
            map.put("result", "failed");
            map.put("message", "내용은 2000자 이내로 작성 가능합니다.");
            return map;
        }

        // 2. 카테고리 기본값 설정
        if(dataVO.getDataType() == null || dataVO.getDataType().isEmpty()) {
            dataVO.setDataType("1"); 
        }

        log.info("자료실 등록 시도 - empId: {}, dataVO : {}", dataVO.getEmpId(), dataVO);
        
        // 3. 실제 DB 저장
        int result = this.dataService.insertData(dataVO, uploadFile);
        
        map.put("result", result > 0 ? "success" : "failed");
        map.put("dataNo", dataVO.getDataNo());
        
        return map;
    }
    
    /**
     * 자료 수정 페이지 호출 (GET)
     */
    @GetMapping("/update")
    public ModelAndView update(int dataNo, ModelAndView mav, Authentication authentication) {
        DataVO dataVO = new DataVO();
        dataVO.setDataNo(dataNo);
        DataVO data = this.dataService.selectDataDetail(dataVO);
        
        String loginId = authentication.getName();
        boolean isAdmin = authentication.getAuthorities().stream()
                            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        // 작성자 본인이거나 관리자이면 통과, 아니면 튕겨내기
        if (!String.valueOf(data.getEmpId()).equals(loginId) && !isAdmin) {
            mav.setViewName("redirect:/data/detail?dataNo=" + dataNo);
            return mav;
        }
        
        mav.addObject("dataVO", data);
        mav.addObject("contentPage", "data/update");
        mav.setViewName("main");
        return mav;
    }

    /**
     * 비동기 자료 수정 (POST)
     */
    @ResponseBody
    @PostMapping("/updateAxios") 
    public Map<String, Object> updateAxios(DataVO dataVO, MultipartFile[] uploadFile, Principal principal) { 
        log.info("data updateAxios -> dataVO : {}", dataVO);
        Map<String, Object> map = new HashMap<>();

        // 1. [보안 강화] 작성자 본인 확인
        DataVO checkData = this.dataService.selectDataDetail(dataVO);
        String loginId = principal.getName();
        
        if (checkData == null || !String.valueOf(checkData.getEmpId()).equals(loginId)) {
            map.put("result", "failed");
            map.put("message", "수정 권한이 없습니다.");
            return map;
        }

        // 🚩 [검증 강화] 수정 시 제목 글자수 체크
        if (dataVO.getDataNm() == null || dataVO.getDataNm().trim().isEmpty()) {
            map.put("result", "failed");
            map.put("message", "수정할 제목을 입력해주세요.");
            return map;
        }
        if (dataVO.getDataNm().length() > 100) {
            map.put("result", "failed");
            map.put("message", "제목은 100자 이내로 수정 가능합니다.");
            return map;
        }

        // 🚩 [검증 강화] 수정 시 내용 글자수 체크
        if (dataVO.getDataCn() == null || dataVO.getDataCn().trim().isEmpty()) {
            map.put("result", "failed");
            map.put("message", "수정할 내용을 입력해주세요.");
            return map;
        }
        if (dataVO.getDataCn().length() > 2000) {
            map.put("result", "failed");
            map.put("message", "내용은 2000자 이내로 수정 가능합니다.");
            return map;
        }
        
        // 2. 수정 진행
        int result = this.dataService.updateData(dataVO);
        
        if(result > 0) {
            map.put("result", "success");
        } else {
            map.put("result", "failed");
            map.put("message", "데이터 수정 중 오류가 발생했습니다.");
        }
        
        return map;
    }
    
    /**
     * 자료 삭제 처리 (작성자 본인 또는 관리자만 가능)
     */
    @GetMapping("/delete")
    public String delete(int dataNo, Authentication authentication) {
        log.info("자료 삭제 요청 -> 번호: {}, 요청자: {}", dataNo, authentication.getName());
        
        // 1. 상세 데이터 조회
        DataVO dataVO = new DataVO();
        dataVO.setDataNo(dataNo);
        DataVO data = this.dataService.selectDataDetail(dataVO);
        
        if (data == null) {
            return "redirect:/data";
        }

        // 2. 권한 체크
        String loginId = authentication.getName(); // 사번 (String)
        
        // 관리자 권한 여부 확인 (ROLE_ADMIN 권한이 있는지 체크)
        boolean isAdmin = authentication.getAuthorities().stream()
                            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        
        // 작성자 본인도 아니고 관리자도 아니라면 차단
        if (!String.valueOf(data.getEmpId()).equals(loginId) && !isAdmin) {
            log.warn("권한 없는 삭제 시도 차단! 사번: {}, 권한: {}", loginId, authentication.getAuthorities());
            return "redirect:/data/detail?dataNo=" + dataNo;
        }
        
        // 3. 권한 통과 시 삭제 수행
        int result = this.dataService.deleteData(dataNo);
        
        if(result > 0) {
            log.info("자료 삭제 완료 -> 번호: {}", dataNo);
            return "redirect:/data"; 
        } else {
            return "redirect:/data/detail?dataNo=" + dataNo;
        }
    }
    
    /**
     * 비동기 자료 삭제
     */
    @ResponseBody
    @PostMapping("/deleteAxios")
    public Map<String, Object> deleteAxios(@RequestBody Map<String, Integer> map) {
        int dataNo = map.get("dataNo");
        log.info("data deleteAxios -> dataNo : {}", dataNo);
        
        int result = this.dataService.deleteData(dataNo);
        Map<String, Object> response = new HashMap<>();
        response.put("result", result > 0 ? "success" : "failed");
        return response;
    }
}