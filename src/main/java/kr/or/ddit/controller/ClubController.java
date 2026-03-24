package kr.or.ddit.controller;

import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.service.BudgetService;
import kr.or.ddit.service.ClubService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/club")
@Controller
public class ClubController {

    @Autowired
    ClubService clubService;

    //대시보드용..
    @Autowired
    BudgetService budgetService;




    //메인화면 가는 컨트롤러
    @GetMapping("/main")
    public String main(){
        return "main";
    }



    //천문동아리 가는 컨트롤러
    @GetMapping("/1")
    public String atsro(Model model, Authentication auth){

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        log.info("동호회로 가기 전 현재 로그인 한 아이디? : " + empId);



        model.addAttribute("contentPage", "club/astro");
        Boolean isMember = false;
        Boolean isPresident = false;

        ClubMemberVO clubMemberVO = new ClubMemberVO();
        clubMemberVO.setEmpId(empId);
        clubMemberVO.setClubNo(1); //아스트로 동호회 번호는 1

        //내가 동아리 회원인지아닌지 + 회장인지 아닌지 가져오기
        clubMemberVO = this.clubService.getClubMember(clubMemberVO);

        if(clubMemberVO !=null){
            isMember = true;
            if("회장".equals(clubMemberVO.getClubMbrAuth())){
                isPresident = true;
            }
        }
        log.info("isMember , isPresident : "+isMember+", "+isPresident);


        //동호회 설명, 설립일 가져오기...
        ClubVO clubVO = this.clubService.getClubInfo(1);
        log.info("동호회 정보 가져오기 : "+clubVO);

        //동호회 회원 수 .. 가져오기...
        int memberCount = this.clubService.getClubMemberCount(1);
        log.info("동호회 회원수 몇명? : "+memberCount);


        model.addAttribute("isMember", isMember);
        model.addAttribute("isPresident", isPresident);
        model.addAttribute("clubVO", clubVO);
        model.addAttribute("memberCount", memberCount);

        return "main";
    }


    //독서동아리 가는 컨트롤러
    @GetMapping("/2")
    public String reading(Model model, Authentication auth){

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        log.info("동호회로 가기 전 현재 로그인 한 아이디? : " + empId);

        model.addAttribute("contentPage", "club/reading");

        Boolean isMember = false;
        Boolean isPresident = false;

        ClubMemberVO clubMemberVO = new ClubMemberVO();
        clubMemberVO.setEmpId(empId);
        clubMemberVO.setClubNo(2); //독서 동호회 번호는 2

        //내가 동아리 회원인지아닌지 + 회장인지 아닌지 가져오기
        clubMemberVO = this.clubService.getClubMember(clubMemberVO);

        if(clubMemberVO !=null){
            isMember = true;
            if("회장".equals(clubMemberVO.getClubMbrAuth())){
                isPresident = true;
            }
        }
        log.info("isMember , isPresident : "+isMember+", "+isPresident);


        //동호회 설명, 설립일 가져오기...
        ClubVO clubVO = this.clubService.getClubInfo(2);
        log.info("동호회 정보 가져오기 : "+clubVO);

        //동호회 회원 수 .. 가져오기...
        int memberCount = this.clubService.getClubMemberCount(2);
        log.info("동호회 회원수 몇명? : "+memberCount);


        model.addAttribute("isMember", isMember);
        model.addAttribute("isPresident", isPresident);
        model.addAttribute("clubVO", clubVO);
        model.addAttribute("memberCount", memberCount);

        return "main";
    }


    //등산동아리 가는 컨트롤러
    @GetMapping("/3")
    public String hiking(Model model, Authentication auth){

        //로그인안하면 리턴해버리기!
        if(auth==null) {
            return null;
        }

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        log.info("동호회로 가기 전 현재 로그인 한 아이디? : " + empId);

        model.addAttribute("contentPage", "club/hiking");
        Boolean isMember = false;
        Boolean isPresident = false;

        ClubMemberVO clubMemberVO = new ClubMemberVO();
        clubMemberVO.setEmpId(empId);
        clubMemberVO.setClubNo(3); //독서 동호회 번호는 2

        //내가 동아리 회원인지아닌지 + 회장인지 아닌지 가져오기
        clubMemberVO = this.clubService.getClubMember(clubMemberVO);

        if(clubMemberVO !=null){
            isMember = true;
            if("회장".equals(clubMemberVO.getClubMbrAuth())){
                isPresident = true;
            }
        }
        log.info("isMember , isPresident : "+isMember+", "+isPresident);


        //동호회 설명, 설립일 가져오기...
        ClubVO clubVO = this.clubService.getClubInfo(3);
        log.info("동호회 정보 가져오기 : "+clubVO);

        //동호회 회원 수 .. 가져오기...
        int memberCount = this.clubService.getClubMemberCount(3);
        log.info("동호회 회원수 몇명? : "+memberCount);


        model.addAttribute("isMember", isMember);
        model.addAttribute("isPresident", isPresident);
        model.addAttribute("clubVO", clubVO);
        model.addAttribute("memberCount", memberCount);

        return "main";
    }


    //동아리 가입하기..
    @ResponseBody
    @PostMapping("/join")
    public int join(Authentication auth, @RequestBody ClubMemberVO clubMemberVO){

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        int empId = employeeVO.getEmpId();
        String empNm = employeeVO.getEmpNm();
        String empJbgd = employeeVO.getEmpJbgd();
        String deptNm = employeeVO.getDeptNm();

        //가입 정보에 아이디, 이름, 직급, 부서명 담아두기(공지사항에 쓰자..)
        clubMemberVO.setEmpId(empId);
        clubMemberVO.setEmpNm(empNm);
        clubMemberVO.setEmpJbgd(empJbgd);
        clubMemberVO.setDeptNm(deptNm);

        log.info("동아리 가입 정보 확인 : "+clubMemberVO);

        int result = 0;

        result = this.clubService.join(clubMemberVO);

        return result;
    } //가입 끝..



    //동호회 회원 목록 가져오기..
    @ResponseBody
    @GetMapping("/members")
    public List<ClubMemberVO> getClubMemberList(@RequestParam("clubNo")int clubNo){
        List<ClubMemberVO> clubMemberVOList = this.clubService.getClubMemberList(clubNo);

        return clubMemberVOList;
    }

    //동호회 탈퇴
    @ResponseBody
    @PostMapping("/leave")
    public String leaveClub(@RequestBody ClubMemberVO clubMemberVO, Authentication auth){

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();
        log.info("동호회로 가기 전 현재 로그인 한 아이디? : " + empId);

        clubMemberVO.setEmpId(empId);

        int result = this.clubService.leaveClub(clubMemberVO);

        if(result == 1){
            return "SUCCESS";
        }else {


        return "FAIL";}
    }



    //공지사항 리스트 불러오기(비동기 페이지네이션..+검색..)
    @ResponseBody
    @PostMapping("/clubNoticeListAxios")
    public ArticlePage<ClubNoticeVO> clubNoticeListAxios(@RequestBody ClubNoticeVO clubNoticeVO){

        log.info("동호회공지사항->mode : " + clubNoticeVO.getMode());//mode : 값 or mode : ""
        log.info("동호회공지사항->keyword : " + clubNoticeVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", clubNoticeVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("clubNo", clubNoticeVO.getClubNo());// 동호회 번호
        map.put("mode", clubNoticeVO.getMode()); // 첫 접속시 ""
        map.put("keyword", clubNoticeVO.getKeyword()); //첫 접속시 ""
        map.put("url", "/club/clubNoticeListAxios");

        //한 화면에 10행씩 보여주자
        int size = 10;

        log.info("공지사항 리스트 불러오기->map : " + map);

        //전체 행의 수(검색 시 검색 반영)
        int total = this.clubService.getClubNoticeTotal(map);
        log.info("동호회 공지사항->total : " + total);

        List<ClubNoticeVO> clubNoticeVOList = this.clubService.clubNoticeListAxios(clubNoticeVO);


        //*** 페이지네이션
        ArticlePage<ClubNoticeVO> articlePage
                = new ArticlePage<ClubNoticeVO>(total, clubNoticeVO.getCurrentPage(), size, clubNoticeVO.getKeyword(), clubNoticeVOList
                , clubNoticeVO.getMode(), map); //오버로딩 한 생성자(map 추가) 생성


        return articlePage;
    }



    //공지사항 상세
    //공지사항 리스트 불러오기(비동기 페이지네이션..+검색..)
    @ResponseBody
    @GetMapping("/noticeDetail")
    public ClubNoticeVO clubNoticeDetail(@RequestParam("clubNtcNo")int clubNtcNo){

        //일단 조회수 up
        int result = this.clubService.plusClubNoticeCnt(clubNtcNo);

        return this.clubService.clubNoticeDetail(clubNtcNo);
    }


    // 공지사항 등록
    @ResponseBody
    @PostMapping("/noticeWrite")
    public String noticeWrite(@RequestBody ClubNoticeVO clubNoticeVO, Authentication auth){

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId = employeeVO.getEmpId();

        clubNoticeVO.setEmpId(empId);

        int result = this.clubService.noticeWrite(clubNoticeVO);

        String res = "";

        if(result >0 ){
            res = "SUCCESS";
        }else{
            res = "FAIL";
        }

        return res;
    }

    //동호회 공지사항 삭제하기
    @ResponseBody
    @PostMapping("/noticeDelete")
    public int noticeDelete(@RequestBody int clubNtcNo){

        int result = this.clubService.noticeDelete(clubNtcNo);

        return result;
    }//공지사항 삭제하기


    //동호회 포토갤러리 등록하기
    @ResponseBody
    @PostMapping("/galleryWrite")
    public int galleryWrite(ClubBoradVO clubBoradVO, Authentication auth){


        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        int empId = employeeVO.getEmpId(); //로그인한 아이디...
        int deptCd = employeeVO.getDeptCd(); //부서코드도 넣기

        //작성자 사번, 부서코드 넣기
        clubBoradVO.setClubMbrNo(empId);
        clubBoradVO.setDeptCd(deptCd);

        //insert!(첨부파일은 서비스 임플에서 함)
        int result = this.clubService.galleryWrite(clubBoradVO);

        return result;
    }//동호회 등록하기


    //포토 갤러리 리스트 불러오기(비동기 페이지네이션..+검색..)
    @ResponseBody
    @PostMapping("/clubBoardListAxios")
    public ArticlePage<ClubBoradVO> clubBoardListAxios(@RequestBody ClubBoradVO clubBoradVO){

        log.info("동호회 갤러리->mode : " + clubBoradVO.getMode());// 무조건 갤러리인데 맞니?
        log.info("동호회갤러리->keyword : " + clubBoradVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", clubBoradVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("clubNo", clubBoradVO.getClubNo());// 동호회 번호
        map.put("mode", "gallery"); // 무조건 갤러리..
        map.put("keyword", clubBoradVO.getKeyword()); //첫 접속시 ""
        map.put("url", "/club/clubBoardListAxios");

        //한 화면에 6개씩 보여주자
        int size = 6;

        log.info("포토갤러리 리스트 불러오기->map : " + map);

        //전체 행의 수(검색 시 검색 반영)
        int total = this.clubService.getClubBoardTotal(map);
        log.info("포토갤러리 리스트->total : " + total);

        List<ClubBoradVO> clubBoradVOList = this.clubService.clubBoardListAxios(clubBoradVO);


        //*** 페이지네이션 => 나중에 getMode() 해서 갤러리 리스트 따로 페이징 처리 해봅시다!!!!!
        ArticlePage<ClubBoradVO> articlePage
                = new ArticlePage<ClubBoradVO>(total, clubBoradVO.getCurrentPage(), size, clubBoradVO.getKeyword(), clubBoradVOList
                , "gallery", map);


        return articlePage;
    }



    //포토갤러리 상세
    //공지사항 리스트 불러오기(비동기 페이지네이션..+검색..)
    @ResponseBody
    @GetMapping("/boardDetail")
    public ClubBoradVO clubBoardDetail(@RequestParam("clubBbsNo")int clubBbsNo){

        //일단 조회수 up
        int result = this.clubService.plusClubBoardCnt(clubBbsNo);

        ClubBoradVO clubBoradVO = this.clubService.clubBoardDetail(clubBbsNo);
        log.info("포토갤러리 상세 잘 가져와짐? : {}", clubBoradVO);

        return clubBoradVO;
    }


    //동호회 갤러리 삭제하기
    @ResponseBody
    @PostMapping("/galleryDelete")
    public int galleryDelete(@RequestBody int clubBbsNo){

        int result = this.clubService.galleryDelete(clubBbsNo);

        return result;
    }//갤러리 삭제하기





    /// /////////////API////////////////////
    @GetMapping("/books")
    public ResponseEntity<List<Map<String, Object>>> getLibraryBooks() {
        List<Map<String, Object>> contents = this.clubService.getDynamicBookContents();
        return ResponseEntity.ok(contents);
    }
    /// /////////////API////////////////////


    @ResponseBody
    @GetMapping("/dashboardBudget")
    public Map<String, Object> dashboardBudget(Authentication auth){

        // 시큐리티로 현재 로그인한 아이디 가져오기
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        int deptCd = employeeVO.getDeptCd(); //부서코드 가져오기

        // 현재 연도 구하기
        int currentYear = LocalDate.now().getYear();

        log.info("대시보드 예산 차트값확인 (사실 지금 동호회 컨트롤러) 부서코드: {}, 연도: {}", deptCd, currentYear);

        // 서비스 호출하여 총 배정액(bgtAmt)과 총 사용액(bgtExcn)을 Map 형태로 받아옴
        Map<String, Object> budgetMap = this.budgetService.getDeptBudgetSum(deptCd, currentYear);

        // 만약 결과가 null이면 빈 Map 반환 (프론트 에러 방지용)
        if (budgetMap == null) {
            budgetMap = new HashMap<>();
            budgetMap.put("BGTAMT", 0);
            budgetMap.put("BGTEXCN", 0);
        }

        return budgetMap;

    }//대시보드 예산 차트 끝


    @ResponseBody
    @GetMapping("/dashboardPhotos")
    public List<ClubBoradVO> dashboardPhotos(){

        log.info("대시보드 동호회 최근 사진 조회 요청!");

        // 🌟 서비스 호출하여 최근 올라온 동호회 사진 리스트(VO)를 받아옴
        List<ClubBoradVO> photoList = this.clubService.getRecentClubPhotos();

        // 데이터가 없으면 빈 리스트를 반환
        if (photoList == null) {
            photoList = new ArrayList<>();
        }

        return photoList;
    }










}
