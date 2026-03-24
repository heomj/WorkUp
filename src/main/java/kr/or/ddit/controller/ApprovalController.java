package kr.or.ddit.controller;

import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.service.AttendanceService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.*;
import kr.or.ddit.vo.project.ProjectVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/approval")
@Controller
public class ApprovalController {

    @Autowired
    private ApprovalService approvalService;

    //알람 발송
    @Autowired
    private AlarmController alarmController;

    //연차테이블관리하기
    @Autowired
    private AttendanceService attendanceService;

    //test화면 가는 컨트롤러
    @GetMapping("/test")
    public String test(){
        return "approval/test";
    }


    //메인화면 가는 컨트롤러
    @GetMapping("/main")
    public String main(){
        return "main";
    }


    //부서 문서함 가는 컨트롤러
    @GetMapping("/deptAprvList")
    public String goDeptAprvList(Model model){

        model.addAttribute("contentPage", "approval/deptAprvList");

        return "main";
    }


    /**
     * 내가 상신한 문서 목록으로 이동
     *
     * @param model 정보를 담을 model객체
     * @param auth 로그인 정보
     * @return 내가 상신한 문서 jsp파일
     */
    @GetMapping("/myAprvBoard")
    public String aprvDashBoard(Model model, Authentication auth) {
        model.addAttribute("contentPage", "approval/myAprvBoard");

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        log.info("결재로 가기 전 현재 로그인 한 아이디? : " + empId);

        //진행중, 반려, 결재대기, 미열람참조, 내상신내역, 회수문서개수를 가져오기....
        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", 1);// /list?currentPage=3 => 3, /list => 1
        map.put("mode", ""); // 진행중을 하기위한 검색 모드 작성
        map.put("stts", "Ing"); // 진행중을 하기위한 검색 모드 작성
        map.put("keyword", ""); //첫 접속시 ""
        map.put("empId", empId); //아이디 값 넣기
        map.put("url", "/approval/myAprvBoard");

        //진행중
        int ingTotal = this.approvalService.getTotal(map);
        log.info("진행중 문서 개수 : "+ ingTotal);

        //반려
        map.put("stts", "return"); // 반려..
        int retrunTotal = this.approvalService.getTotal(map);
        log.info("반려 문서 개수 : "+ retrunTotal);

        //완료 문서
        map.put("stts", "done"); // 완료
        int doneTotal = this.approvalService.getTotal(map);
        log.info("내상신 완료 문서 개수 : "+ doneTotal);

        //회수
        map.put("stts", "recall"); // 회수
        int recallTotal = this.approvalService.getWithDrawTotal(map);
        log.info("회수 문서 개수 : "+ recallTotal);

        //전체 상신내역
        map.put("stts", "");
        int aprvTotal = this.approvalService.getTotal(map);
        log.info("전체 상신 개수 : "+ aprvTotal);

        model.addAttribute("ingTotal", ingTotal);
        model.addAttribute("retrunTotal", retrunTotal);
        model.addAttribute("doneTotal", doneTotal);
        model.addAttribute("recallTotal", recallTotal);
        model.addAttribute("aprvTotal", aprvTotal);

        return "main";
    }



    /**
     * 내가 수신한 문서 목록 화면으로 이동
     * @param model 정보를 담을 model객체
     * @param auth 로그인 정보
     * @return 내가 문서 문서 화면
     */
    @GetMapping("/receiveAprvBoard")
    public String receiveAprvBoard(Model model, Authentication auth) {
        model.addAttribute("contentPage", "approval/receiveAprvBoard");

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        log.info("결재로 가기 전 현재 로그인 한 아이디? : " + empId);

        //결재대기, 미열람참조(아직 안함), 결재 완료(아직안함) 개수를 가져오기....
        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", 1);// /list?currentPage=3 => 3, /list => 1
        map.put("mode", ""); // 진행중을 하기위한 검색 모드 작성
        map.put("keyword", ""); //첫 접속시 ""
        map.put("empId", empId); //아이디 값 넣기
        map.put("url", "/approval/getMyPendingAprvAxios");

        //결재대기개수
        map.put("stts", "pending"); //결재대기
        int pendingTotal = this.approvalService.getPendingTotal(map);
        log.info("결재대기문서 개수 : "+ pendingTotal);


        //결재 수신함에서 내가 결재 완료한 문서 개수
        map.put("stts", "pendingDone"); //결재대기
        int pendingDoneTotal = this.approvalService.getPendingDoneTotal(map);
        log.info("결재대기문서 개수 : "+ pendingTotal);

        model.addAttribute("pendingTotal", pendingTotal);
        model.addAttribute("pendingDoneTotal", pendingDoneTotal);

        return "main";

    }



    /**
     * 내가 상신한 문서 비동기 페이지네이션(검색)
     *
     * @param approvalVO 검색어, 검색카테고리, 현재페이지 등의 정보가 담겨있음
     * @param auth 로그인 정보
     * @return ArticlePage<ApprovalVO> 검색 결과
     */
    @ResponseBody
    @PostMapping("/aprvDashBoardAxios")
    public ArticlePage<ApprovalVO> aprvListAxios(
            @RequestBody ApprovalVO approvalVO, Authentication auth
    ){

        //가져와야 하는것 : 내 최근 결재 전체 목록, 상태 별 개수
        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();


        log.info("list->mode : " + approvalVO.getMode());//mode : 값 or mode : ""
        log.info("list->keyword : " + approvalVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", approvalVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", approvalVO.getMode()); // 첫 접속시 ""
        map.put("keyword", approvalVO.getKeyword()); //첫 접속시 ""
        map.put("empId", empId); //아이디 값 넣기
        map.put("url", "/approval/aprvDashBoardAxios"); //내 상신 문서 목록 비동기로 불러오기..

        //한 화면에 10행씩 보여주자
        int size = 10;

        log.info("list->map : " + map);

        //전체 행의 수(검색 시 검색 반영)
        int total = this.approvalService.getTotal(map);
        log.info("list->total : " + total);

        List<ApprovalVO> aprvVOList = this.approvalService.list(map);
        log.info("list->aprvVOList : " + aprvVOList);

        //*** 페이지네이션
        ArticlePage<ApprovalVO> articlePage
                = new ArticlePage<ApprovalVO>(total, approvalVO.getCurrentPage(), size, approvalVO.getKeyword(), aprvVOList
                , approvalVO.getMode(), map); //오버로딩 한 생성자(map 추가) 생성

        log.info("list->articlePage : " + articlePage);

        //ArticlePage를 리턴
        return articlePage;
    }



    /**
     * 비동기 페이지네이션(내 상신 내역 중 완료 문서/검색)
     *
     * @param approvalVO 검색어, 검색카테고리, 현재페이지 등의 정보가 담겨있음
     * @param auth 로그인 정보
     * @return ArticlePage<ApprovalVO> 검색 결과
     */
    @ResponseBody
    @PostMapping("/aprvDashBoardDoneAxios")
    public ArticlePage<ApprovalVO> aprvDashBoardDoneAxios(
            @RequestBody ApprovalVO approvalVO, Authentication auth
    ){

        //가져와야 하는것 : 내 최근 결재 전체 목록, 상태 별 개수
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();


        log.info("list->mode : " + approvalVO.getMode());//mode : 값 or mode : ""
        log.info("list->keyword : " + approvalVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", approvalVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", approvalVO.getMode()); // 첫 접속시 ""
        map.put("keyword", approvalVO.getKeyword()); //첫 접속시 ""
        map.put("stts", "done"); // 완료
        map.put("empId", empId); //아이디 값 넣기
        map.put("url", "/approval/aprvDashBoardDoneAxios"); //내 상신 문서 목록 비동기로 불러오기..

        //한 화면에 10행씩 보여주자
        int size = 10;

        log.info("list->map : " + map);

        //전체 행의 수(완료)
        int total = this.approvalService.getTotal(map);
        log.info("list->total : " + total);

        List<ApprovalVO> aprvVOList = this.approvalService.list(map);
        log.info("list->aprvVOList : " + aprvVOList);

        //*** 페이지네이션
        ArticlePage<ApprovalVO> articlePage
                = new ArticlePage<ApprovalVO>(total, approvalVO.getCurrentPage(), size, approvalVO.getKeyword(), aprvVOList
                , approvalVO.getMode(), map); //오버로딩 한 생성자(map 추가) 생성

        log.info("list->articlePage : " + articlePage);

        //ArticlePage를 리턴
        return articlePage;
    }


    /**
     * 비동기 페이지네이션(내가 상신한 것중에 진행중(미완료)문서 조회)
     *
     * @param approvalVO 검색어, 검색카테고리, 현재페이지 등의 정보가 담겨있음
     * @param auth 로그인 정보
     * @return ArticlePage<ApprovalVO> 검색 결과
     */
    @ResponseBody
    @PostMapping("/aprvIngAxios")
    public ArticlePage<ApprovalVO> aprvIngAxios(
            @RequestBody ApprovalVO approvalVO, Authentication auth
    ){

        //가져와야 하는것 : 내 최근 결재 전체 목록, 상태 별 개수
        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();

        log.info("list->mode : " + approvalVO.getMode());//mode : 값 or mode : ""
        log.info("list->keyword : " + approvalVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", approvalVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", approvalVO.getMode()); //검색유형
        map.put("stts", "Ing"); // 진행중(내가 상신한 미완료)을 하기위한 검색 모드 작성
        map.put("keyword", approvalVO.getKeyword()); //첫 접속시 ""
        map.put("empId", empId); //아이디 값 넣기
        map.put("url", "/approval/aprvIngAxios");

        //한 화면에 10행씩 보여주자
        int size = 10;

        log.info("list->map : " + map);

        //전체 행의 수(검색 시 검색 반영)
        int total = this.approvalService.getTotal(map);
        log.info("list->total : " + total);

        List<ApprovalVO> aprvVOList = this.approvalService.list(map);
        log.info("list->aprvVOList : " + aprvVOList);

        //*** 페이지네이션
        ArticlePage<ApprovalVO> articlePage
                = new ArticlePage<ApprovalVO>(total, approvalVO.getCurrentPage(), size, approvalVO.getKeyword(), aprvVOList
                , approvalVO.getMode(), map); //오버로딩 한 생성자(map 추가) 생성

        log.info("list->articlePage : " + articlePage);

        //ArticlePage를 리턴
        return articlePage;
    }



    /**
     * 내 결재대기 문서 조회(검색)
     *
     * @param approvalVO 검색어, 검색카테고리, 현재페이지 등의 정보가 담겨있음
     * @param auth 로그인 정보
     * @return ArticlePage<ApprovalVO> 검색 결과
     */
    @ResponseBody
    @PostMapping("/getMyPendingAprvAxios")
    public ArticlePage<ApprovalVO> getMyPendingAprvAxios(
            @RequestBody ApprovalVO approvalVO,
            Authentication auth
    ){

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();


        log.info("결재대기 문서조회 ->mode : " + approvalVO.getMode());//mode : 값 or mode : ""
        log.info("결재대기 문서조회 ->keyword : " + approvalVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", approvalVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("keyword", approvalVO.getKeyword()); //첫 접속시 ""
        map.put("empId", empId); //아이디 값 넣기
        map.put("url", "/approval/getMyPendingAprvAxios");

        //한 화면에 10행씩 보여주자
        int size = 10;

        log.info("list->map : " + map);

        //전체 행의 수(검색 시 검색 반영)
        int total = this.approvalService.getPendingTotal(map);
        log.info("결재대기->total : " + total);

        List<ApprovalVO> aprvVOList = this.approvalService.pendingList(map);
        log.info("결재대기->aprvVOList : " + aprvVOList);

        //*** 페이지네이션
        ArticlePage<ApprovalVO> articlePage
                = new ArticlePage<ApprovalVO>(total, approvalVO.getCurrentPage(), size, approvalVO.getKeyword(), aprvVOList
                , approvalVO.getMode(), map); //오버로딩 한 생성자(map 추가) 생성

        log.info("list->articlePage : " + articlePage);

        //ArticlePage를 리턴
        return articlePage;

    }



    /**
     * 내가 결재한(수신함에서 나는 결재완료인) 문서 조회(검색)
     *
     * @param approvalVO 검색어, 검색카테고리, 현재페이지 등의 정보가 담겨있음
     * @param auth 로그인 정보
     * @return ArticlePage<ApprovalVO> 검색 결과
     */
    @ResponseBody
    @PostMapping("/getPendingDoneAprvAxios")
    public ArticlePage<ApprovalVO> getPendingDoneAprvAxios(
            @RequestBody ApprovalVO approvalVO,
            Authentication auth
    ){

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();


        log.info("내가 결재한 문서조회 ->mode : " + approvalVO.getMode());//mode : 값 or mode : ""
        log.info("내가 결재한 문서조회 ->keyword : " + approvalVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", approvalVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("keyword", approvalVO.getKeyword()); //첫 접속시 ""
        map.put("empId", empId); //아이디 값 넣기
        map.put("url", "/approval/getPendingDoneAprvAxios");

        //한 화면에 10행씩 보여주자
        int size = 10;

        log.info("list->map : " + map);

        //전체 행의 수(검색 시 검색 반영)
        int total = this.approvalService.getPendingDoneTotal(map);
        log.info("결재한문서 전체 ->total : " + total);

        List<ApprovalVO> aprvVOList = this.approvalService.getPendingDonedoneList(map);
        log.info("결재한문서 전체 ->aprvVOList : " + aprvVOList);

        //*** 페이지네이션
        ArticlePage<ApprovalVO> articlePage
                = new ArticlePage<ApprovalVO>(total, approvalVO.getCurrentPage(), size, approvalVO.getKeyword(), aprvVOList
                , approvalVO.getMode(), map); //오버로딩 한 생성자(map 추가) 생성

        log.info("list->articlePage : " + articlePage);

        //ArticlePage를 리턴
        return articlePage;

    }



    /**
     * 결재대기에서 결재해야 하는 문서 새창 열기
     * @param aprvNo 결재 문서 번호
     * @param model 정보 담은 객체
     * @return 새창 화면
     */
    @GetMapping("/openPendingAprvDetail")
    public String openPendingAprvDetail(@RequestParam("aprvNo") int aprvNo, Model model) {
        model.addAttribute("aprvNo", aprvNo);
        return "approval/openPendingAprvDetail";
    }


    /**
     * 결재대기 외 문서에서 새창 열기
     *
     * @param aprvNo 결재 문서 번호
     * @param model 정보 담은 객체
     * @return 새창 화면
     */
    @GetMapping("/openAprvDetail")
    public String openAprvDetail(@RequestParam("aprvNo") int aprvNo, Model model) {
        model.addAttribute("aprvNo", aprvNo);
        return "approval/openAprvDetail";
    }


    /**
     * 전자결재 결재선 가져오기
     * @param aprvNo 전자결재 문서 번호
     * @return 전자결재 리스트
     */
    @ResponseBody
    @GetMapping("/getAprvLine")
    public List<AprvLineVO> getAprvLine(@RequestParam(value = "aprvNo") int aprvNo){
        log.info("getAprvLine->aprvNo : " + aprvNo);

        List<AprvLineVO> aprvLineList = this.approvalService.getAprvLine(aprvNo);

        return aprvLineList;
    }



    /**
     * 결재문서 본문 가져오기
     *
     * @param aprvNo 결재문서 번호
     * @return ApprovalVO 본문 정보
     */
    @ResponseBody
    @GetMapping("/getPendingDoc")
    public ApprovalVO getPendingDoc(@RequestParam(value = "aprvNo") int aprvNo){
        log.info("getPendingDoc->aprvNo : " + aprvNo);

        // 서비스 하나로 7개 양식 통합 처리
        ApprovalVO aprvVO =  this.approvalService.getCompleteDoc(aprvNo);
        log.info("getPendingDoc -> 상세 문서 : ", aprvVO);

        return aprvVO;
    }



    /**
     * 결재 승인 or 반려 처리하기
     *
     * @param aprvLineVO 결재선 정보(결재자 정보)
     * @param auth 로그인 정보
     * @return 승인/반려 성공 여부
     */
    @Transactional
    @ResponseBody
    @PostMapping("/processAprvAxios")
    public String processAprvAxios(@RequestBody AprvLineVO aprvLineVO, Authentication auth){

        log.info("processAprvAxios->aprvLineVO : " + aprvLineVO); //데이터 넘어온 것 확인

        //해당 결재선의 결재 상태를 바꾸기(승인 or 반려)
        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId(); //결재한 아이디..

        aprvLineVO.setEmpId(empId); //결재자 id 시큐리티로 넣기

        log.info("결재 승인/반려 전 현재 로그인 한 아이디 확인 : " + empId);

        //결재선 테이블 승인/반려 수정하기
        int aprvLineUpdateRes = this.approvalService.aprvLineUpdate(aprvLineVO);
        log.info("결재 승인/반려 성공여부  : " + aprvLineUpdateRes);


        //기안 상신자(작성자) 정보..(알람받을사람)
        //일단 먼저 기안 상신 정보 가져오기(상신자, 제목 가져오기)
        int aprvNo = aprvLineVO.getAprvNo();// 전자결재(approval) 번호
        ApprovalVO approvalVO = this.approvalService.getDocWriterId(aprvNo); //전자결재 번호로 사번 가져오기
        log.info("알람받을 기안작성자 사번 잘 가져오니? : "+approvalVO.getDocWriterId());



        ///// 결재완료(결재가 종료!) 반려 일때 상신인 한테 알람 보내기! /////
        //알람VO 생성
        AlarmVO alarmVO = new AlarmVO();
        //알람 받을 수신인 리스트 생성
        List<Integer> rcvrNoList = new ArrayList<>();

        int res = 0;
        // 2. 결재 테이블 상태 수정하기(반려/결재완료)
        if(aprvLineUpdateRes > 0 ){ //결과가 1이상(결재선 업데이트 성공 시에만) 결재 문서 상태 업데이트

            res = this.approvalService.updateAprvStatus(aprvLineVO); //결재(approval)테이블 반려/결재완료 업데이트


            //반려든, 결재완료든 상태가 업데이트 됐음 => 근태 상세 문서 상태를 결재완료/반려로 바꾸기
            // ==> AprvLineVO에 문서종류, 반려, 승인 여부도 담아둠..
            if(res > 0){
                
                //상태명 변경해주기
                if("APRV02003".equals(aprvLineVO.getAprvLnStts())){ //반려
                    aprvLineVO.setAprvLnStts("반려");

                    // 결재 상신인한테 반려 알람 보내기 시작 //
                    rcvrNoList.add(approvalVO.getDocWriterId());

                    //알람VO 데이터 넣기(메시지, 상세메시지, 수신자)
                    alarmVO.setAlmMsg("결재가 반려되었습니다.");
                    alarmVO.setAlmDtl(
                            "<span class=\"fw-bold\">"+employeeVO.getEmpNm()+ " "+employeeVO.getEmpJbgd()+
                                    "</span>님이 <span class=\"fw-bold text-primary\">'"+approvalVO.getAprvTtl()+"'</span> 결재를 반려했습니다.");
                    alarmVO.setAlmRcvrNos(rcvrNoList); // 리스트 통째로 세팅
                    alarmVO.setAlmIcon("warning"); // 아이콘 세팅
                    alarmVO.setAlmSndrIcon("myProfile");

                    // 알람 컨트롤러 호출
                    // 파라미터 순서: 상신자사번(empId), 알람VO, 상세이동URL, 알람타입(알람 앞에 붙는 구분메시지)
                    String alarmRes = this.alarmController.sendAlarm(
                            empId,
                            alarmVO,
                            "/approval/myAprvBoard",
                            "결재"
                    );

                    log.info("반려 알람 발신 결과 : " + alarmRes);

                    // 결재 상신인한테 반려 알람 보내기 끝 //

                }else{//결재완료면..
                    aprvLineVO.setAprvLnStts("결재완료");

                    // 결재 상신인한테 결재완료 알람 보내기 시작 //
                    rcvrNoList.add(approvalVO.getDocWriterId());

                    //알람VO 데이터 넣기(메시지, 상세메시지, 수신자)
                    alarmVO.setAlmMsg("결재가 완료되었습니다.");
                    alarmVO.setAlmDtl(
                            "상신하신 <span class=\"fw-bold text-primary\">'"+approvalVO.getAprvTtl()+"'</span> 문서의 결재가 완료되었습니다.");
                    alarmVO.setAlmRcvrNos(rcvrNoList); // 리스트 통째로 세팅
                    alarmVO.setAlmIcon("success"); // 아이콘 세팅
                    alarmVO.setAlmSndrIcon("myProfile");

                    // 알람 컨트롤러 호출
                    // 파라미터 순서: 상신자사번(empId), 알람VO, 상세이동URL, 알람타입(알람 앞에 붙는 구분메시지)
                    String alarmRes = this.alarmController.sendAlarm(
                            empId,
                            alarmVO,
                            "/approval/myAprvBoard",
                            "결재"
                    );

                    log.info("결재완료 알람 발신 결과 : " + alarmRes);

                    // 결재 상신인한테 결재완료 알람 보내기 끝 //

                }

                //-------------휴가면 휴가 더해주기/근태 상태 업데이트 시작----------

                // 🌟 1. 근태문서(휴가, 출장, 초과근무)일 때만 상세 문서 상태 업데이트!
                if ("Y".equals(aprvLineVO.getIsAttDoc())) {
                    int docSttsRes = this.approvalService.updateDocStts(aprvLineVO);
                }

                //만약 반려 && 휴가 라면 더해주기
                if("반려".equals(aprvLineVO.getAprvLnStts()) && "Y".equals(aprvLineVO.getIsVctDoc())){
                    log.info("반려 && 휴가 더해주기 로직안으로 들어오니? 반려 휴가일수도 확인해보쉴? : {}", aprvLineVO.getVctTotalDays());
                    int docReturnRes = this.approvalService.returnUseVct(aprvLineVO);
                }
                //-------------휴가면 휴가 더해주기/근태 상태 업데이트 끝----------

                //-------------🌟 지출품의서 반려 시 예산 복구 시작 🌟----------
                if("반려".equals(aprvLineVO.getAprvLnStts()) && "APRV01001".equals(aprvLineVO.getAprvSe())) {
                    log.info("지출품의서 반려 확인! 예산 복구 로직을 실행합니다. 문서번호: {}", aprvNo);

                    // 서비스로 결재번호(aprvNo)와 현재 반려를 누른 사람의 사번(empId)을 넘김
                    this.approvalService.refundBudget(aprvNo, empId);
                }
                //-------------지출품의서 반려 시 예산 복구 끝----------





            }//end 반려/결재완료든 상태가 업데이트 됐음
            else if (res == 0) { //상태가 업데이트 안됐음 = 다음 결재선이 있음

                //다음결재자한테 알람 보내기(혹시 모를  null값 대비로 Integer로 받음)
                Integer nextAprvLnId = this.approvalService.getNextAprvLnId(aprvNo);

                log.info("조회된 다음 결재자 사번: {}", nextAprvLnId);

                if (nextAprvLnId != null && nextAprvLnId > 0) {
                    rcvrNoList.add(nextAprvLnId);

                    //알람VO 데이터 넣기(메시지, 상세메시지, 수신자)
                    alarmVO.setAlmMsg("새로운 결재 요청이 도착했습니다");
                    alarmVO.setAlmDtl(
                            "<span class=\"fw-bold\">"+approvalVO.getDocWriterNm()+ " "+approvalVO.getPosNm()+
                                    "</span>님이 <span class=\"fw-bold text-primary\">'"+approvalVO.getAprvTtl()+"'</span> 결재를 상신했습니다.");
                    alarmVO.setAlmRcvrNos(rcvrNoList); // 리스트 통째로 세팅
                    alarmVO.setAlmIcon("warning"); // 아이콘 세팅
                    alarmVO.setAlmSndrIcon("myProfile");

                    // 알람 컨트롤러 호출
                    // 파라미터 순서: 상신자사번(empId), 알람VO, 상세이동URL, 알람타입(알람 앞에 붙는 구분메시지)
                    String alarmRes = this.alarmController.sendAlarm(
                            empId,
                            alarmVO,
                            "/approval/receiveAprvBoard",
                            "결재"
                    );

                    log.info("다음 결재자한테 알람 발신 결과 : " + alarmRes);
                }else {
                    // 스킵될경우 확인용
                    log.warn("다음 결재자 사번이 유효하지 않아 알람 발송실패...");
                }
            }//end 상태가 업데이트 안됐음

        }else{
            log.info("결재선 승인/반려 업데이트 실패");
        }//end if

        log.info("processAprvAxios -> 결재 처리 여부 : ");

        return "";

    }//결재/반려하기 끝



    /**
     * 전자결재 문서 회수 처리
     *
     * @param approvalVO 회수할 문서 정보
     * @param auth 로그인 정보
     * @return 회수 성공 여부
     */
    @Transactional
    @ResponseBody
    @PostMapping("/withdrawApproval")
    public String withdrawApproval(@RequestBody ApprovalVO approvalVO, Authentication auth) {

        // 1. 로그인 체크 및 사용자 정보 가져오기
        if (auth == null) return "로그인정보없음";

        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId(); // 현재 로그인한 사번 (기안자 본인)

        int aprvNo = approvalVO.getAprvNo();
        log.info("회수 요청 발생 - 문서번호: {}, 요청자: {}", aprvNo, empId);

        // 권한 방어 로직 (프론트에서 넘어온 기안자 ID와 현재 로그인한 사람이 일치하는지 확인)
        if (approvalVO.getDocWriterId() != empId) {
            return "권한없음";
        }
        //한번 확인
        log.info("너 결재 상태 머야! : {}", approvalVO.getAprvStts());

        // 진행중이아니면?
        if (!"진행중".equals(approvalVO.getAprvStts())) {
            log.info("진행중아니면 결재 상태 머야! : {}", approvalVO.getAprvStts());
            return "invalid_status";
        }

        // 문서 상태를 '회수'로 업데이트 (APPROVAL 테이블)
        int withdrawRes = this.approvalService.withdrawDocument(aprvNo);
        log.info("문서 회수 처리 결과 : {}", withdrawRes);

        //회수로 업뎃 성공햇다면?
        if (withdrawRes > 0) {
            // --- 🌟 리소스 복구 로직 시작 🌟 ---

            // 기존 반려 로직(processAprvAxios)에서 쓰던 매퍼를 그대로 사용스...
            //결국,, 결재선 VO에 정보 담음.....
            AprvLineVO recoveryVO = new AprvLineVO();
            recoveryVO.setAprvNo(aprvNo);
            recoveryVO.setAprvDocNo(approvalVO.getAprvDocNo()); //상세번호도 넣어야지..
            recoveryVO.setAprvSe(approvalVO.getAprvSe());
            recoveryVO.setIsAttDoc(approvalVO.getIsAttDoc());
            recoveryVO.setIsVctDoc(approvalVO.getIsVctDoc());
            recoveryVO.setVctTotalDays(approvalVO.getVctTotalDays()); // 휴가 복구용 일수
            recoveryVO.setDocWriterId(approvalVO.getDocWriterId());   // 휴가 복구 대상자
            recoveryVO.setAprvLnStts("대기"); // 근태 상세 문서 상태를 '대기'로 바꾸기 위한 값+


            // A. 휴가/근태 관련 복구
            if ("Y".equals(recoveryVO.getIsAttDoc())) {

                // 1) 근태 상세 문서(휴가, 출장 등) ***대기*** 상태 업데이트 -> 기존 메서드 재활용
                this.approvalService.updateDocStts(recoveryVO);

                // 2) 휴가 문서일 경우 휴가 일수 환불 -> 기존 반려 매퍼 재활용!
                if ("Y".equals(recoveryVO.getIsVctDoc())) {
                    log.info("회수 -> 휴가 일수 복구 시작. 복구일수: {}", recoveryVO.getVctTotalDays());
                    this.approvalService.returnUseVct(recoveryVO);
                }
            }

            // B. 지출품의서 예산 복구
            if ("APRV01001".equals(approvalVO.getAprvSe())) {
                log.info("회수 -> 지출품의 예산 복구 시작. 문서번호: {}", aprvNo);
                // 기존 반려 시 사용하던 예산 복구 서비스 호출
                this.approvalService.refundBudget(aprvNo, empId);
            }

            // --- 🌟 리소스 복구 로직 끝 🌟 ---

            log.info("문서번호 {} 회수 및 리소스 복구 완료", aprvNo);
            return "success";
        }

        return "fail";
    }


    /**
     * 부서 문서 목록 조회하기(+비동기 검색)
     *
     * @param approvalVO 검색어, 검색 카테고리 등 검색+조회 조건
     * @param auth 로그인 정보
     * @return 검색 결과
     */
    @ResponseBody
    @PostMapping("/deptAprvListAxios")
    public ArticlePage<ApprovalVO> getDeptAprvList(@RequestBody ApprovalVO approvalVO, Authentication auth){

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        int deptCd = employeeVO.getDeptCd(); //부서코드
        log.info("결재로 가기 전 현재 로그인 한 아이디? : " + empId);
        log.info("결재로 가기 전 현재 로그인 한 사람의 부서코드는? : " + deptCd);



        log.info("list->mode : " + approvalVO.getMode());//mode : 값 or mode : ""
        log.info("list->keyword : " + approvalVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", approvalVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", approvalVO.getMode()); // 첫 접속시 ""
        map.put("keyword", approvalVO.getKeyword()); //첫 접속시 ""
        map.put("empId", empId); //아이디 값 넣기
        map.put("deptCd", deptCd); //부서코드 넣기

        map.put("url", "/approval/deptAprvList");

        //한 화면에 10행씩 보여주자
        int size = 10;

        log.info("list->map : " + map);

        //전체 행의 수(검색 시 검색 반영)
        int total = this.approvalService.getDeptAprvTotal(map);
        log.info("(부서 문서함의 문서 total) list->total : " + total);

        //부서 문서 리스트 가져오기
        List<ApprovalVO> aprvVOList = this.approvalService.deptAprvlist(map);
        log.info("list->aprvVOList : " + aprvVOList);

        //*** 페이지네이션
        ArticlePage<ApprovalVO> articlePage
                = new ArticlePage<ApprovalVO>(total, approvalVO.getCurrentPage(), size, approvalVO.getKeyword(), aprvVOList
                , approvalVO.getMode(), map); //오버로딩 한 생성자(map 추가) 생성


        log.info("getDeptAprvList(부서문서목록)->articlePage : " + articlePage);

        //ArticlePage를 리턴
        return articlePage;
    }



    /**
     * 휴가 신청 문서로 이동
     * @param model 정보 담는 model 객체
     * @param auth 로그인 정보
     * @return 휴가신청 문서 화면
     */
    @GetMapping("/vctAprv")
    public String vctAprv(Model model, Authentication auth){
        model.addAttribute("contentPage", "approval/vctAprv");

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        log.info("employeeVO확인 : " + employeeVO);

        int empId = employeeVO.getEmpId(); //로그인한 아이디..

        String deptCd = employeeVO.getEmpJbgd(); //로그인한 부서 코드

        model.addAttribute("empJbgd", employeeVO.getEmpJbgd());//직급담기
        model.addAttribute("docWriterId", empId);//결재 신청자(문서작성자) 사번 담기
        model.addAttribute("empNm", employeeVO.getEmpNm());//이름 담기
        model.addAttribute("deptNm", employeeVO.getDeptNm());//부서명 담기

        //내가 신청한 휴가 목록 불러오기
        List<VacationDocumentVO> VacationDocumentVOList = this.approvalService.getVacationDocumentVOList(empId);
        log.info("vctAprv(휴가신청내역)->overtimeDocumentVOList : " + VacationDocumentVOList);

        //휴가 신청 페이지로 가기 전에 신청 목록 보내기
        model.addAttribute("VacationDocumentVOList", VacationDocumentVOList);


        //프로젝트 정보도 담읍시다..
        // 서비스 단을 호출해서 내 프로젝트 목록 2가지 가져오기
        List<ProjectVO> ingProjectList = this.approvalService.getIngProjectList(empId);
        List<ProjectVO> doneProjectList = this.approvalService.getDoneProjectList(empId);

        log.info("진행중 프로젝트 정보 잘 가져오니? : {}", ingProjectList);
        log.info("완료 프로젝트 정보 잘 가져오니? : {}", doneProjectList);

        // 모달에 담기
        model.addAttribute("ingProjectList", ingProjectList);
        model.addAttribute("doneProjectList", doneProjectList);

        return "main";
    }


    /**
     * 초과근무 신청으로 이동
     *
     * @param model 정보 담는 model 객체
     * @param auth 로그인 정보
     * @return 초과근무신청 문서 화면
     */
    @GetMapping("/excsAprv")
    public String excsAprv(Model model, Authentication auth){
        model.addAttribute("contentPage", "approval/excsAprv");


        //1. 해당 결재선의 결재 상태를 바꾸기(승인 or 반려)
        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        log.info("employeeVO확인 : " + employeeVO);

        int empId = employeeVO.getEmpId(); //로그인한 아이디..

        String deptCd = employeeVO.getEmpJbgd(); //로그인한 부서 코드

        model.addAttribute("empJbgd", employeeVO.getEmpJbgd());//직급담기
        model.addAttribute("docWriterId", empId);//결재 신청자(문서작성자) 사번 담기
        model.addAttribute("empNm", employeeVO.getEmpNm());//이름 담기
        model.addAttribute("deptNm", employeeVO.getDeptNm());//부서명 담기

        //내가 신청한 초과근무 목록 불러오기
        List<OvertimeDocumentVO> overtimeDocumentVOList = this.approvalService.getOvertimeDocumentVOList(empId);
        log.info("excsAprv(초과근무신청내역)->overtimeDocumentVOList : " + overtimeDocumentVOList);

        //초과근무 신청 페이지로 가기 전에 신청 목록 보내기
        model.addAttribute("overtimeDocumentVOList", overtimeDocumentVOList);


        //프로젝트 정보도 담읍시다..
        // 서비스 단을 호출해서 내 프로젝트 목록 2가지 가져오기
        List<ProjectVO> ingProjectList = this.approvalService.getIngProjectList(empId);
        List<ProjectVO> doneProjectList = this.approvalService.getDoneProjectList(empId);

        log.info("진행중 프로젝트 정보 잘 가져오니? : {}", ingProjectList);
        log.info("완료 프로젝트 정보 잘 가져오니? : {}", doneProjectList);

        // 모달에 담기
        model.addAttribute("ingProjectList", ingProjectList);
        model.addAttribute("doneProjectList", doneProjectList);

        return "main";
    }


    /**
     * 출장신청으로 이동
     *
     * @param model 정보 담는 model 객체
     * @param auth 로그인 정보
     * @return 출장신청 문서 화면
     */
    @GetMapping("/bztripAprv")
    public String bztripAprv(Model model, Authentication auth){
        model.addAttribute("contentPage", "approval/bztripAprv");

        //1. 해당 결재선의 결재 상태를 바꾸기(승인 or 반려)
        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        log.info("employeeVO확인 : " + employeeVO);

        int empId = employeeVO.getEmpId(); //로그인한 아이디..

        String deptCd = employeeVO.getEmpJbgd(); //로그인한 부서 코드

        model.addAttribute("empJbgd", employeeVO.getEmpJbgd());//직급담기
        model.addAttribute("docWriterId", empId);//결재 신청자(문서작성자) 사번 담기
        model.addAttribute("empNm", employeeVO.getEmpNm());//이름 담기
        model.addAttribute("deptNm", employeeVO.getDeptNm());//부서명 담기

        //내가 신청한 출장신청 목록 불러오기
        List<TripDocumentVO> tripDocumentVOList = this.approvalService.getTripDocumentVOList(empId);
        log.info("bztripAprv(출장신청내역)->tripDocumentVOList : " + tripDocumentVOList);

        //출장 신청 페이지로 가기 전에 신청 목록 보내기
        model.addAttribute("tripDocumentVOList", tripDocumentVOList);


        //프로젝트 정보도 담읍시다..
        // 서비스 단을 호출해서 내 프로젝트 목록 2가지 가져오기
        List<ProjectVO> ingProjectList = this.approvalService.getIngProjectList(empId);
        List<ProjectVO> doneProjectList = this.approvalService.getDoneProjectList(empId);

        log.info("진행중 프로젝트 정보 잘 가져오니? : {}", ingProjectList);
        log.info("완료 프로젝트 정보 잘 가져오니? : {}", doneProjectList);

        // 모달에 담기
        model.addAttribute("ingProjectList", ingProjectList);
        model.addAttribute("doneProjectList", doneProjectList);

        return "main";
    }


    /**
     * 일반기안문으로 이동
     *
     * @param model 정보 담는 model 객체
     * @param auth 로그인 정보
     * @return 일반기안문 문서 화면
     */
    @GetMapping("/nmlAprv")
    public String nmlAprv(Model model, Authentication auth){
        model.addAttribute("contentPage", "approval/nmlAprv");


        //1. 해당 결재선의 결재 상태를 바꾸기(승인 or 반려)
        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        log.info("employeeVO확인 : " + employeeVO);

        int empId = employeeVO.getEmpId(); //로그인한 아이디..

        String deptCd = employeeVO.getEmpJbgd(); //로그인한 부서 코드

        model.addAttribute("empJbgd", employeeVO.getEmpJbgd());//직급담기
        model.addAttribute("docWriterId", empId);//결재 신청자(문서작성자) 사번 담기
        model.addAttribute("empNm", employeeVO.getEmpNm());//이름 담기
        model.addAttribute("deptNm", employeeVO.getDeptNm());//부서명 담기


        //프로젝트 정보도 담읍시다..
        // 서비스 단을 호출해서 내 프로젝트 목록 2가지 가져오기
        List<ProjectVO> ingProjectList = this.approvalService.getIngProjectList(empId);
        List<ProjectVO> doneProjectList = this.approvalService.getDoneProjectList(empId);

        log.info("진행중 프로젝트 정보 잘 가져오니? : {}", ingProjectList);
        log.info("완료 프로젝트 정보 잘 가져오니? : {}", doneProjectList);

        // 모달에 담기
        model.addAttribute("ingProjectList", ingProjectList);
        model.addAttribute("doneProjectList", doneProjectList);


        return "main";
    }



    /**
     * 지출 품의로 이동
     *
     * @param model 정보 담는 model 객체
     * @param auth 로그인 정보
     * @return 지출품의 문서 화면
     */
    @GetMapping("/expndAprv")
    public String expndAprv(Model model, Authentication auth){
        model.addAttribute("contentPage", "approval/expndAprv");


        //1. 해당 결재선의 결재 상태를 바꾸기(승인 or 반려)
        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        log.info("employeeVO확인 : " + employeeVO);

        int empId = employeeVO.getEmpId(); //로그인한 아이디..

        int deptCd = employeeVO.getDeptCd(); //로그인한 부서 코드
        log.info("부서 코드도 잘 가져오니? : {}", deptCd);


        model.addAttribute("empJbgd", employeeVO.getEmpJbgd());//직급담기
        model.addAttribute("docWriterId", empId);//결재 신청자(문서작성자) 사번 담기
        model.addAttribute("empNm", employeeVO.getEmpNm());//이름 담기
        model.addAttribute("deptNm", employeeVO.getDeptNm());//부서명 담기

        // 🌟 추가된 로직: 현재 로그인한 사용자의 부서 코드로 예산 목록 가져오기
        // (올해 연도 기준 예산 목록을 리스트로 반환)
        List<BudgetDetailVO> budgetList = this.approvalService.getBudgetListByDept(deptCd);
        log.info("부서 예산 목록 잘 가져오니? : {}", budgetList);

        // JSP 화면으로 예산 리스트 데이터 넘기기
        model.addAttribute("budgetList", budgetList);

        //프로젝트 정보도 담읍시다..
        // 서비스 단을 호출해서 내 프로젝트 목록 2가지 가져오기
        List<ProjectVO> ingProjectList = this.approvalService.getIngProjectList(empId);
        List<ProjectVO> doneProjectList = this.approvalService.getDoneProjectList(empId);

        log.info("진행중 프로젝트 정보 잘 가져오니? : {}", ingProjectList);
        log.info("완료 프로젝트 정보 잘 가져오니? : {}", doneProjectList);

        // 모달에 담기
        model.addAttribute("ingProjectList", ingProjectList);
        model.addAttribute("doneProjectList", doneProjectList);


        return "main";
    }


    /**
     * 전자결재 상신하기
     * @param auth 로그인 정보
     * @param approvalVO 상신한 문서 정보
     * @return 상신 성공 여부
     */
    @ResponseBody
    @Transactional
    @PostMapping("/submit")
    public String aprvsubmit(Authentication auth, ApprovalVO approvalVO){

        try {
            //로그인안하면 리턴해버리기!
            if (auth == null) {
                return null;
            }

            // 시큐리티로 현재 로그인한 아이디 가져오기
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();

            int empId = employeeVO.getEmpId(); //로그인한 아이디..

            approvalVO.setEmpId(empId); //로그인한아이디 VO에 세팅
            approvalVO.setAprvDeptCd(employeeVO.getDeptCd()); //로그인한 아이디 부서코드

            //만약 일반기안이면 APPROVAL insert 전에 일반기안문 먼저 insert
            if("APRV01006".equals(approvalVO.getAprvSe())){
                int res = this.approvalService.insertNmlDoc(approvalVO); //NML_DOC_NO selectKey로 넣어둠
            } //만약 지출품의면 APPROVAL insert 전에 품의 먼저 insert
            else if ("APRV01001".equals(approvalVO.getAprvSe())) {
                // 매퍼의 selectKey를 통해 approvalVO.aprvDocNo에 번호 들어가짐!
                this.approvalService.insertExpndDoc(approvalVO);
                log.info("지출품의 생성 완! 전문번호도 잘받아와지니?: " + approvalVO.getAprvDocNo());
            }


            //APPROVAL 테이블 insert
            int insertRes = this.approvalService.insertAprv(approvalVO);
            log.info("APPROVAL 테이블 insert 성공여부 : " + insertRes);
            int generatedAprvNo = approvalVO.getAprvNo(); //selectKey 사용(시퀀스!)

            log.info("상신한 문서번호 잘 받아졌니? : " + generatedAprvNo);
            log.info("근태 문서 여부 잘 받아지니? : " + approvalVO.getAttTypeId());
            log.info("양식번호 확인해보자 : " + approvalVO.getAprvSe());



            // 만약 지출품의라면..
            // 지출품의 상세 내역(1:N) INSERT (APPROVAL 번호가 나온 뒤 실행!)
            if ("APRV01001".equals(approvalVO.getAprvSe()) && approvalVO.getExpndDocList() != null) {
                for (ExpndDocVO dtl : approvalVO.getExpndDocList()) {
                    dtl.setExpndDocNo(approvalVO.getAprvDocNo()); // 전문 마스터 번호 세팅

                    // (A) 상세 내역 INSERT
                    this.approvalService.insertExpndDtl(dtl);

                    // (B) 예산 사용량 업데이트 (BGT_EXCN 증가)
                    int updateCount = this.approvalService.updateBudgetUsage(dtl);

                    // 💡 만약 업데이트된 행이 0이라면? (그 사이 다른 사람이 예산을 써서 잔액이 부족해진 경우)
                    if (updateCount == 0) {
                        throw new RuntimeException("예산 잔액이 부족하여 상신할 수 없는 항목이 포함되어 있습니다. (비목코드: " + dtl.getBgtCd() + ")");
                    }

                    // (C) 🌟 맵 대신 VO 사용! 🌟
                    BudgetLogVO logVO = new BudgetLogVO();
                    logVO.setBgtMCd(dtl.getBgtMCd());
                    logVO.setBgtCd(dtl.getBgtCd());
                    logVO.setBgtChgSe("지출");
                    logVO.setBgtChgAmt((int)dtl.getExpndAmt()); // long을 int로 캐스팅
                    logVO.setBgtChgRsn(dtl.getExpndRsn());
                    logVO.setEmpId(empId);
                    logVO.setAprvNo(generatedAprvNo);

                    this.approvalService.insertBudgetLog(logVO);
                }
            }


            //휴가,초과근무, 출장 신청 내역 업데이트 => 신청중으로.........
            //          => 휴가일때에는 휴가 관리 테이블도 업뎃함(approval 서비스 임플에서 처리함)
            if (approvalVO.getAttTypeId() > 0) { //근태 신청 아이디가 있으면...
                int updateRes = this.approvalService.updateAttAprv(approvalVO);
                log.info("근태신청 테이블 update 성공여부 : " + updateRes);
            }

            int insertAprvLineRes = 0;

            //결재선 insert
            if (approvalVO.getAprvLineVOList() != null && !approvalVO.getAprvLineVOList().isEmpty()) {
                // 모든 결재선 객체에 생성된 문서번호(aprvNo) 세팅
                for (AprvLineVO line : approvalVO.getAprvLineVOList()) {
                    line.setAprvNo(generatedAprvNo);
                }
                //리스트 통째로 한번에 insert
                insertAprvLineRes = approvalService.insertAprvLineVOList(approvalVO.getAprvLineVOList());

            }

            // !!!!결재 상신 알람 시도!!!!

            //알람VO 생성
            AlarmVO alarmVO = new AlarmVO();

            //첫 번째 결재자 사번 가져오기(나는 첫번째 결재자만 알람 보낼거임요!)
            int firstApproverId = approvalVO.getAprvLineVOList().get(0).getEmpId();

            //수신자 리스트 생성 및 추가 (1명이라도 리스트에 담아야 함)=> 첫번째 결재자임
            List<Integer> rcvrNoList = new ArrayList<>();
            rcvrNoList.add(firstApproverId);

            //알람VO 데이터 넣기(메시지, 상세메시지, 수신자)
            alarmVO.setAlmMsg("새로운 결재 요청이 도착했습니다");
            alarmVO.setAlmDtl(
                    "<span class=\"fw-bold\">"+employeeVO.getEmpNm()+ " "+employeeVO.getEmpJbgd()+
                    "</span>님이 <span class=\"fw-bold text-primary\">'"+approvalVO.getAprvTtl()+"'</span> 결재를 상신했습니다.");
            alarmVO.setAlmRcvrNos(rcvrNoList); // 리스트 통째로 세팅
            alarmVO.setAlmIcon("warning"); // 아이콘 세팅
            alarmVO.setAlmSndrIcon("myProfile");


            // 알람 컨트롤러 호출
            // 파라미터 순서: 상신자사번(empId), 알람VO, 상세이동URL, 알람타입(알람 앞에 붙는 구분메시지)
            String alarmRes = this.alarmController.sendAlarm(
                    empId,
                    alarmVO,
                    "/approval/myAprvBoard",
                    "결재"
            );

            log.info("첫 번째 결재자에게 알람 발송 결과 : " + alarmRes);
            // !!!!결재 상신 알람 시도 끝!!!!


            return "SUCCESS";
        }catch (Exception e) {
            e.printStackTrace();
            //오류 발생 시 롤백!
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return "FAIL";
        }
    }//end 상신




    /**
     * 비동기 페이지네이션(내 상신 내역 중 회수 문서)
     *
     * @param approvalVO 회수문서 검색 정보
     * @param auth 로그인 정보
     * @return 검색 결과(ArticlePage<ApprovalVO>)
     */
    @ResponseBody
    @PostMapping("/aprvWithDrawListAxios")
    public ArticlePage<ApprovalVO> aprvWithDrawListAxios(
            @RequestBody ApprovalVO approvalVO, Authentication auth
    ){

        //가져와야 하는것 : 내 최근 결재 전체 목록, 상태 별 개수
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();

        log.info("회수 list->mode : " + approvalVO.getMode());//mode : 값 or mode : ""
        log.info("회수 list->keyword : " + approvalVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", approvalVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", approvalVO.getMode()); // 첫 접속시 ""
        map.put("keyword", approvalVO.getKeyword()); //첫 접속시 ""
        map.put("stts", "recall"); // 회수!
        map.put("empId", empId); //아이디 값 넣기
        map.put("url", "/approval/aprvDashBoardDoneAxios"); //내 상신 문서 목록 비동기로 불러오기..

        //한 화면에 10행씩 보여주자
        int size = 10;

        log.info("list->map : " + map);

        //전체 행의 수(회수만)
        int total = this.approvalService.getWithDrawTotal(map);
        log.info("회수.. list->total : " + total);

        List<ApprovalVO> aprvVOList = this.approvalService.withDrawlist(map);
        log.info("회수 list->aprvVOList : " + aprvVOList);

        //*** 페이지네이션
        ArticlePage<ApprovalVO> articlePage
                = new ArticlePage<ApprovalVO>(total, approvalVO.getCurrentPage(), size, approvalVO.getKeyword(), aprvVOList
                , approvalVO.getMode(), map);

        log.info("회수 list->articlePage : " + articlePage);

        //ArticlePage를 리턴
        return articlePage;
    }



}
