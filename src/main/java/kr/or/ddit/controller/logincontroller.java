package kr.or.ddit.controller;

import kr.or.ddit.mapper.EmailMapper;
import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.service.EmailService;
import kr.or.ddit.service.EmployeeService;
import kr.or.ddit.service.avatarService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.service.impl.EmailServiceImpl;
import kr.or.ddit.service.project.AdminService;
import kr.or.ddit.service.project.MyWorkService;
import kr.or.ddit.vo.AvatarVO;
import kr.or.ddit.vo.EmailVO;
import kr.or.ddit.vo.EmpAvtVO;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Controller
public class logincontroller {

    @Value("${file.prfFolder}")
    private String prfFolder;

    @Autowired
    avatarService avtservice;

    @Autowired
    private EmailService emailService;

    @Autowired
    EmployeeService empservice;

    @Autowired
    AdminService adminService;  // 팀장만(프로젝트 관리)

    @Autowired
    ApprovalService approvalService;

    @Autowired
    private MyWorkService myWorkService;

    // 프로젝트 관리(팀장)
    @GetMapping("/projectmanage")
    public String projectmanage (Model model, Authentication auth) {
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        int empid =  customUser.getEmpVO().getEmpId();

        // 내가 만든 프로젝트 List 불러오기
        List<ProjectVO> projectList = this.adminService.myprojectlist(empid);
        log.info("projectList:{}",projectList);
        model.addAttribute("contentPage", "project/projectmanage");
        model.addAttribute("projectList", projectList);

        log.info("팀장 프로젝트 관리 : {}", projectList);
        return "main";
    }

    // 나의업무
    @GetMapping("/myWork")
    public String myWorkList(Model model, Authentication auth) {
        // 1. 시큐리티 컨텍스트에서 로그인된 사번(empId) 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();

        int empId = customUser.getEmpVO().getEmpId();
        log.info("리스트 사번: {}", empId);

        // 2. 아까 그 마스터 쿼리로 리스트 싹 긁어오기
        /*List<TaskVO> taskList = this.myWorkService.getMyWorkList(empId);
        log.info("가져온 일감 개수: {}", taskList.size());*/
        List<ProjectVO> List = this.myWorkService.toMyWorkList(empId);
        log.info("가져온 일감 개수: {}", List);
        // 3. 모델에 담아서 JSP로 쏴주기
        model.addAttribute("projectList", List);
        model.addAttribute("contentPage", "project/myWork");

        return "main";
    }

    // 비밀번호 찾기
    @ResponseBody
    @PostMapping("/findpw")
    public String findpw(@RequestParam("empId") int empId,
                         @RequestParam("phone") String phone) {
        log.info("전화번호 : {}", phone);
        log.info("ㅇㅇㄷ : {}", empId);

        EmployeeVO vo = new EmployeeVO();
        vo.setEmpId(empId);
        vo.setEmpPhone(phone);

        String result = empservice.findpw(vo);

        return result;
    }

    // 로그인 Page 띄우기
    @GetMapping("/")
    public String home(){
        return "home";
    }


    // 로그인 Page 띄우기
    @GetMapping("/login")
    public String login(){ return "login"; }


    @GetMapping("/main")
    public String main(Model model, Authentication auth) {
        // 너는 누구니
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        log.info("너는 누구니 :" + customUser.getEmpVO().getEmpId());
        model.addAttribute("contentPage", "dashboard");


        //결재 대기 문서 개수 가져오기
        Map<String, Object> map = new HashMap<String,Object>();
        map.put("empId", customUser.getEmpVO().getEmpId()); //아이디 값 넣기
        int pendingTotal = this.approvalService.getPendingTotal(map); //개수 구하기
        model.addAttribute("pendingTotal", pendingTotal); //모델에 값 넣기
        log.info("결재대기문서 개수 : "+ pendingTotal); //확인용
        //결재 대기 문서 개수 가져오기 끝


        return "main";
    }

    @GetMapping("/attendance-view")
    public String attendance(Model model) {
        model.addAttribute("contentPage", "attendance");
        return "main";
    }

    // 이메일 - 받은 메일함
    @GetMapping("/email")
    public String email(Model model) {
        model.addAttribute("contentPage", "email/email");
        return "main";
    }
    // 이메일 - 보낸 메일함
    @GetMapping("/email/send")
    public String emailSend(Model model) {
        model.addAttribute("contentPage", "email/send");
        return "main";
    }
    // 이메일 - 휴지통
    @GetMapping("/email/trashCan")
    public String emailTrashCan(Model model) {
        model.addAttribute("contentPage", "email/trashCan");
        return "main";
    }
    // 이메일 - 상세보기
    @GetMapping("/detail/{emlNo}")
    public String emailDetail(@PathVariable int emlNo, ModelAndView mav) {
            log.info("test->emlNo : {}", emlNo);
        EmailServiceImpl emailService= new EmailServiceImpl();
            EmailVO emailVO = this.emailService.findByNo(emlNo);
            log.info("test->emailVO : {}", emailVO);
            mav.addObject("emailVO", emailVO);
        mav.addObject("contentPage", "email/detail");
        return "main";
    }
    
    @GetMapping("/notice")
    public String notice(Model model) {
        model.addAttribute("contentPage", "notice/list"); 
        
        return "main";
    }
    
    @GetMapping("/data")
    public String data(Model model) {
        model.addAttribute("contentPage", "data/list"); 
        
        return "main";
    }
    
    @GetMapping("/board")
    public String board(Model model) {
        model.addAttribute("contentPage", "board/list"); 
        
        return "main";
    }
    
    @GetMapping("/chat")
    public String chat(Model model) {
        model.addAttribute("contentPage", "chat/list"); 
        
        return "main";
    }

    @GetMapping("/shop")
    public String shop(Model model){
        List<AvatarVO> avtlist = this.avtservice.getallavtlist(null,null);
        model.addAttribute("contentPage", "avatar/shop");
        model.addAttribute("avtlist", avtlist);

        return "main";
    }

    // 아바타 상점
    @GetMapping("/shop/select")
    @ResponseBody
    public List<AvatarVO> shop(Model model,
                               @RequestParam(value = "sortSelect", required = false) String sortSelect,
                               @RequestParam (value = "category", required = false) String cate) {

        log.info("sortSelect(머가 넘어왔늬) : {}", sortSelect);
        log.info("sortSelect(머가 넘어왔늬) : {}", cate);

        List<AvatarVO> avtlist = this.avtservice.getallavtlist(sortSelect,cate);

        log.info("아바타 전체 : {}", avtlist);

        return avtlist;
    }

    // 내 아바타
    @GetMapping("/myavatar")
    public String myavatar(Model model, Authentication auth) {
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        int empid =  customUser.getEmpVO().getEmpId();

        List<EmpAvtVO> myavtlist = this.avtservice.myavtlist(empid);
        log.info("내가 보유하고 있는 아바타 목록 : {}", myavtlist);

        model.addAttribute("contentPage", "avatar/myavatar");
        model.addAttribute("myavtlist", myavtlist);

        return "main";
    }

    // 마이페이지
    @GetMapping("/mypage")
    public String mypage (Model model) {
        model.addAttribute("contentPage", "mypage/myinfo");
        return "main";
    }

    // 프로필 사진
    @GetMapping("/displayPrf")
    @ResponseBody
    public Resource display(@RequestParam("fileName") String fileName) {
        return new FileSystemResource(prfFolder + fileName);
    }

    // 급여명세서
    @GetMapping("/payslip")
    public String payslip (Model model) {
        model.addAttribute("contentPage", "mypage/payslip");
        return "main";
    }


    

}
