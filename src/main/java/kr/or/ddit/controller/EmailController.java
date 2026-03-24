package kr.or.ddit.controller;

import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.EmailService;
import kr.or.ddit.service.EmployeeService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;
import retrofit2.http.Path;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequestMapping("/email")
@Slf4j
@Controller
public class EmailController {

    @Autowired
    EmployeeService employeeService;
    @Autowired
    EmailService emailService;
    @Autowired
    private SimpMessagingTemplate template;

    /**
     * 멘션 기능 (사원 검색)
     * @param query
     * @return
     */
    @ResponseBody
    @GetMapping("/search")
    public List<EmployeeVO> searchMember(@RequestParam("query") String query) {
        //log.info("email/search=>query 파라미터가 잘 갔나요? {}", query);
        // DB에서 이름이나 사원번호로 검색 (예: WHERE name LIKE %query%)
        List<EmployeeVO> list = this.employeeService.findMembersByQuery(query);
        //log.info("리스트가 왔나요?=>list {}", list);
        return this.employeeService.findMembersByQuery(query);
    }

    /**
     * 이메일 전송
     * @param emailVO
     * @param auth
     * @return
     */
    @ResponseBody
    @PostMapping("/send")
    public ResponseEntity<?> send (EmailVO emailVO,
                                   @RequestParam(value="keepFileIds", required=false) List<String> keepFileIds,
                                   Authentication auth){


        try {
            //log.info("send->emailVO : {}", emailVO);
            //log.info("send->multipartFiles : {}", emailVO.getMultipartFiles());
            //로그인한 사원아이디추출
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();
            //로그인한 사원아이디 값넣기
            emailVO.setEmlSndrId(employeeVO.getEmpId());
                AlarmVO alarmVO=new AlarmVO();
            alarmVO.setAlmMsg("새 메일이 도착했습니다.");
            alarmVO.setAlmType("메일");
            alarmVO.setAlmIcon("success");
            int result = this.emailService.sendMail(emailVO, keepFileIds);
            if (result > 0) {
                for (int almRcvrNo : emailVO.getEmlRcvrIds()) {
                    this.template.convertAndSend("/sub/alarm/" + almRcvrNo, alarmVO);
                }

                // 성공 시 200 OK와 함께 결과값 전달
                return ResponseEntity.ok(result);
            } else {
                // 로직상 실패 시 400 Bad Request 등 전달
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("전송 실패");
            }
        } catch (Exception e) {
            // 서버 에러 발생 시 500 Internal Server Error 전달
            //log.error("메일 전송 중 에러 발생: ", e);
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
        }
    }

    /**
     * 답장
     * @param emlRcvrId
     * @param model
     * @return
     */
    @PostMapping("/reply")
    public String reply (int emlRcvrId, Model model){
        log.info("emlRcvrId:{}",emlRcvrId);
        EmailVO emailVO = this.emailService.findByNo(emlRcvrId);
        emailVO.setReplyorforward("reply");
        log.info("emailVO:{}",emailVO);
        model.addAttribute("emailVO", emailVO);
        model.addAttribute("contentPage", "email/write");
        return "main";
    }
    /**
     * 전달
     * @param emlRcvrId
     * @param model
     * @return
     */
    @PostMapping("/forward")
    public String forward (int emlRcvrId, Model model){
        log.info("emlRcvrId:{}",emlRcvrId);
        EmailVO emailVO = this.emailService.findByNo(emlRcvrId);
        emailVO.setReplyorforward("forward");
        log.info("emailVO:{}",emailVO);
        model.addAttribute("emailVO", emailVO);
        model.addAttribute("contentPage", "email/write");
        return "main";
    }
    /**
     * 보낸메일함전달
     * @param emlRcvrId
     * @param model
     * @return
     */
    @PostMapping("/forwardsend")
    public String forwardsend (int emlRcvrId, Model model){
        log.info("emlRcvrId:{}",emlRcvrId);
        EmailVO emailVO = this.emailService.findByNoSend(emlRcvrId);
        emailVO.setReplyorforward("forward");
        log.info("emailVO:{}",emailVO);
        model.addAttribute("emailVO", emailVO);
        model.addAttribute("contentPage", "email/write");
        return "main";
    }

    /**
     * 받은 메일함 리스트 (페이징)
     * @param mav
     * @param pageNum
     * @param pageFilter
     * @param emailVO
     * @param auth
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/listAxios", method = RequestMethod.POST)
    public ArticlePage<EmailVO> listAxios(ModelAndView mav,
                                          @CookieValue(name = "pageNum", defaultValue = "10") int pageNum,
                                          @CookieValue(name = "pageFilter", defaultValue = "All") String pageFilter,
                                          @CookieValue(name = "emlBoxNo", defaultValue = "0") int emlBoxNo,
                                         @RequestBody EmailVO emailVO,
                                          Authentication auth) {
        //log.info("list->mode : " + emailVO.getMode());
        //log.info("list->keyword : " + emailVO.getKeyword());
        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

		/*
		 Map의 종류
		 맵다...				 하..     하..        쏘..맵다
		 Map  				 HashMap  Hashtable  SortedMap ->구현->TreeMap
		 순서   				 X        X          					X
		 정렬  				 X   	  X							    O
		 null허용(key/value)  O/O	  X/X							X/O
		*/

        Map<String, Object> map = new HashMap<String,Object>();
        //log.info("현재 페이지 정보 : {} ",emailVO.getCurrentPage());
        map.put("currentPage", emailVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", emailVO.getMode());
        map.put("keyword", emailVO.getKeyword());
        map.put("empId", employeeVO.getEmpId());
        map.put("url","/list");
        System.out.println("쿠키에서 가져온 페이지 번호: " + pageNum);
        System.out.println("쿠키에서 가져온 pageFilter: " + pageFilter);
        // 한 화면에 10행씩 보여주자
        int size = pageNum;
        map.put("pageNum",pageNum);
        map.put("pageFilter",pageFilter);
        map.put("emlBoxNo",emlBoxNo);

        //log.info("list->map : " + map);

        //전체 행의 수 (검색 시 검색 반영)
        int total = this.emailService.getTotalCount(map);
        //log.info("list->total : " + total);

        List<EmailVO> emailVOList = this.emailService.getList(map);
        //log.info("list->bookVOList : " + emailVOList);

        //***페이지네이션
        ArticlePage<EmailVO> articlePage = new ArticlePage<EmailVO>(total, emailVO.getCurrentPage(), size, emailVO.getKeyword(), emailVOList
                , emailVO.getMode(), map);
        ////log.info("list->articlePage : " + articlePage);

        //forwarding
        return articlePage;
    }


    /**
     * 보낸 메일함 리스트 (페이징)
     * @param mav
     * @param pageNum
     * @param pageFilter
     * @param emailVO
     * @param auth
     * @return
     */

    @ResponseBody
    @RequestMapping(value = "/listSendAxios", method = RequestMethod.POST)
    public ArticlePage<EmailVO> listSendAxios(ModelAndView mav,
                                          @CookieValue(name = "pageNum", defaultValue = "10") int pageNum,
                                          @CookieValue(name = "pageFilter", defaultValue = "All") String pageFilter,
                                          @RequestBody EmailVO emailVO,
                                          Authentication auth) {
        ////log.info("list->mode : " + emailVO.getMode());
        ////log.info("list->keyword : " + emailVO.getKeyword());
        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

		/*
		 Map의 종류
		 맵다...				 하..     하..        쏘..맵다
		 Map  				 HashMap  Hashtable  SortedMap ->구현->TreeMap
		 순서   				 X        X          					X
		 정렬  				 X   	  X							    O
		 null허용(key/value)  O/O	  X/X							X/O
		*/

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", emailVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", emailVO.getMode());
        map.put("keyword", emailVO.getKeyword());
        map.put("empId", employeeVO.getEmpId());
        map.put("url","/list");
        System.out.println("쿠키에서 가져온 페이지 번호: " + pageNum);
        System.out.println("쿠키에서 가져온 pageFilter: " + pageFilter);
        // 한 화면에 10행씩 보여주자
        int size = pageNum;
        map.put("pageNum",pageNum);
        map.put("pageFilter",pageFilter);

        ////log.info("list->map : " + map);

        //전체 행의 수 (검색 시 검색 반영)
        int total = this.emailService.getTotalSendCount(map);
        ////log.info("list->total : " + total);

        List<EmailVO> emailVOList = this.emailService.getSendList(map);
        ////log.info("list->bookVOList : " + emailVOList);

        //***페이지네이션
        ArticlePage<EmailVO> articlePage = new ArticlePage<EmailVO>(total, emailVO.getCurrentPage(), size, emailVO.getKeyword(), emailVOList
                , emailVO.getMode(), map);
        ////log.info("list->articlePage : " + articlePage);

        //forwarding
        return articlePage;
    }


    /**
     * 휴지통 리스트
     * @param mav
     * @param pageNum
     * @param pageFilter
     * @param emailVO
     * @param auth
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/listTrashAxios", method = RequestMethod.POST)
    public ArticlePage<EmailVO> listTrashAxios(ModelAndView mav,
                                          @CookieValue(name = "pageNum", defaultValue = "10") int pageNum,
                                          @CookieValue(name = "pageFilter", defaultValue = "All") String pageFilter,
                                          @RequestBody EmailVO emailVO,
                                          Authentication auth) {
        ////log.info("list->mode : " + emailVO.getMode());
        ////log.info("list->keyword : " + emailVO.getKeyword());
        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

		/*
		 Map의 종류
		 맵다...				 하..     하..        쏘..맵다
		 Map  				 HashMap  Hashtable  SortedMap ->구현->TreeMap
		 순서   				 X        X          					X
		 정렬  				 X   	  X							    O
		 null허용(key/value)  O/O	  X/X							X/O
		*/

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", emailVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", emailVO.getMode());
        map.put("keyword", emailVO.getKeyword());
        map.put("empId", employeeVO.getEmpId());
        map.put("url","/list");
        System.out.println("쿠키에서 가져온 페이지 번호: " + pageNum);
        System.out.println("쿠키에서 가져온 pageFilter: " + pageFilter);
        // 한 화면에 10행씩 보여주자
        int size = pageNum;
        map.put("pageNum",pageNum);
        map.put("pageFilter",pageFilter);

        ////log.info("list->map : " + map);

        //전체 행의 수 (검색 시 검색 반영)
        int total = this.emailService.getTotalTrashCount(map);
        ////log.info("list->total : " + total);

        List<EmailVO> emailVOList = this.emailService.getTrashList(map);
        ////log.info("list->bookVOList : " + emailVOList);

        //***페이지네이션
        ArticlePage<EmailVO> articlePage = new ArticlePage<EmailVO>(total, emailVO.getCurrentPage(), size, emailVO.getKeyword(), emailVOList
                , emailVO.getMode(), map);
        ////log.info("list->articlePage : " + articlePage);

        //forwarding
        return articlePage;
    }

    //상세보기 - 비동기처리
    @ResponseBody
    @PostMapping("/detailAxios")
    public EmailVO detailAxios(@RequestBody Map<String, Integer> param){

        //log.info("detailAxios->emlNo : {}", param);

        int emlRcvrId= param.get("emlRcvrId");
        //log.info("detailAxios->emlNo : {}", emlRcvrId);

        //emlRcvrId 넘겨서 상세 받아오기
        EmailVO emailVO = this.emailService.findByNo(emlRcvrId);
        //log.info("detailAxios->emailVO : {}", emailVO);
        return emailVO;
    }
    //상세보기 - 비동기처리
    // 아래의 메서드와 다른 점은 보낸사람 나열이 있다는 것
    @ResponseBody
    @PostMapping("/detailSendAxios")
    public EmailVO detailSendAxios(@RequestBody Map<String, Integer> param){

        //log.info("detailAxios->emlNo : {}", param);

        int emlNo= param.get("emlNo");
        //log.info("detailAxios->emlNo : {}", emlNo);

        //emlRcvrId 넘겨서 상세 받아오기
        EmailVO emailVO = this.emailService.findByNoSend(emlNo);
        //log.info("detailAxios->emailVO : {}", emailVO);
        return emailVO;
    }

    /**
     * 수신확인을 위해 emailVO에 다수의 emailRcvrVO리스트를 포함해 가져옴
     * (참조자 포함)
     * @param emlNostr
     * @return
     */
    @ResponseBody
    @PostMapping("/receiptchk")
    public EmailVO receiptchk(@RequestBody String emlNostr){

        //log.info("receiptchk=>emlNo : {} ",emlNostr);
        int emlNo = Integer.valueOf(emlNostr);
        EmailVO emailVO;

        //log.info("receiptchk=>emlNo : {} ",emlNo);

        emailVO=this.emailService.findByEmlNoForRcpchk(emlNo);
        //log.info("receiptchk=>emailVO : {} ",emailVO);

        return emailVO;
    }

    /**
     * 체크박스 중요,삭제,읽음처리
     * @param params
     * @param auth
     * @return
     */
    @ResponseBody
    @PostMapping("/readOrDelOrImpt")
    public ResponseEntity<?> readOrDelOrImpt (@RequestBody Map<String, Object> params,Authentication auth){

    try {
        //log.info("readOrDelOrImpt->params : {}", params);
        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        //로그인한 사원아이디 값넣기
        params.put("empId", employeeVO.getEmpId());
        int result = this.emailService.readOrDelOrImpt(params);
        //log.info("readOrDelOrImpt->result : {}", result);

        if (result > 0) {
            // 성공 시 200 OK와 함께 결과값 전달
            return ResponseEntity.ok(result);
        } else {
            // 로직상 실패 시 400 Bad Request 등 전달
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
        }
    } catch (Exception e) {
        // 서버 에러 발생 시 500 Internal Server Error 전달
        //log.error("메일 상태 변경 중 에러 발생: ", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
    }

    }

    /**
     * 개별 중요 토글
     * @param map
     * @return
     */
    @ResponseBody
    @PostMapping("/updateIsImpt")
    public ResponseEntity<?> updateIsImpt(@RequestBody Map<String, Object> map){
        //테이블 기본키
        String emlIdStr = String.valueOf(map.get("dataId"));
        int emlRcvrId=Integer.valueOf(emlIdStr);

        //토글이므로 원래 상태와 반대값 세팅 (N or Y)
        String setImpt = String.valueOf(map.get("setImpt"));
        //log.info("updateIsImpt->emlRcvrId : {}", emlRcvrId);

        try {
            int res = this.emailService.isImpt(setImpt,emlRcvrId);
            //log.info("updateIsImpt->res(1이면성공) : {}", res);
            if(res>0){
                return ResponseEntity.ok(res);
            }else {
                return  ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
            }
        } catch (Exception e) {
            //log.error("개별 중요업데이트 에러남 : ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버오류");
        }
    }

    @ResponseBody
    @GetMapping("/reCallOne/{emlNo}")
    public ResponseEntity<?> reCallOne(@PathVariable int emlNo ){
        //log.info("emlNo:{}",emlNo);
            try{
                int result=this.emailService.reCallEmail(emlNo);
                if(result>0){
                    return ResponseEntity.ok(result);
                }else{return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("실패");}
            } catch(Exception e){
                //log.error("회수 중 에러 발생 : ",e);
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("이건 서버오류인가");
            }
    }

    //영구삭제
    @ResponseBody
    @PostMapping("/deletePermanent")
    public ResponseEntity<?> deletePermanent (@RequestBody Map<String, Object> params,Authentication auth){

        try {
            //log.info("readOrDelOrImpt->params : {}", params);
            //로그인한 사원아이디추출
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();
            //로그인한 사원아이디 값넣기
            params.put("empId", employeeVO.getEmpId());
            int result = this.emailService.readOrDelOrImpt(params);
            //log.info("readOrDelOrImpt->result : {}", result);

            if (result > 0) {
                // 성공 시 200 OK와 함께 결과값 전달
                return ResponseEntity.ok(result);
            } else {
                // 로직상 실패 시 400 Bad Request 등 전달
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
            }
        } catch (Exception e) {
            // 서버 에러 발생 시 500 Internal Server Error 전달
            //log.error("메일 상태 변경 중 에러 발생: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
        }

    }

    /**
     * 휴지통 단건 처리
     * @param params
     * @param auth
     * @return
     */
    @ResponseBody
    @PostMapping("/trashcandeletePmntOrRecall")
    public ResponseEntity<?> trashcandeletePmntOrRecall (@RequestBody Map<String, Object> params,Authentication auth){

        try {
            //log.info("readOrDelOrImpt->params : {}", params);
            //로그인한 사원아이디추출
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();
            //로그인한 사원아이디 값넣기
            params.put("empId", employeeVO.getEmpId());
            int result = this.emailService.deletePmntOrRecall(params);
            //log.info("readOrDelOrImpt->result : {}", result);

            if (result > 0) {
                // 성공 시 200 OK와 함께 결과값 전달
                return ResponseEntity.ok(result);
            } else {
                // 로직상 실패 시 400 Bad Request 등 전달
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
            }
        } catch (Exception e) {
            // 서버 에러 발생 시 500 Internal Server Error 전달
            //log.error("메일 상태 변경 중 에러 발생: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
        }

    }
    /**
     * 헤더 메일 알람 처리
     * @param auth
     * @return
     */
    //상단바 메일 알람
    @ResponseBody
    @GetMapping("/mailAlarm")
    public List<EmailVO> mailAlarm(Authentication auth){
        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        List<EmailVO> emailVOList = this.emailService.getNotReadMail(employeeVO.getEmpId());
        //log.info("mailAlarm->employeeVO.getEmpId() : {}", employeeVO.getEmpId());
        return emailVOList;
    }


//디테일보기 링크 이동
    @GetMapping("/detail/{emlNo}")
    public String detail(@PathVariable int emlNo, Model mav){
        //log.info("test->emlNo : {}", emlNo);
        EmailVO emailVO = this.emailService.findByNo(emlNo);
        //log.info("test->emailVO : {}", emailVO);
        mav.addAttribute("contentPage", "email/detail");
        mav.addAttribute("emailVO", emailVO);
        return "main";
    }
    @Autowired
    private EmployeeMapper employeeMapper;

    /**
     * 주소록에서 메일 보내는 링크
     * @param targetEmpIds
     * @param model
     * @return
     */
//메일 쓰기 (아이디 자동 입력)
// 이메일 - 메일쓰기
@GetMapping("/write")
public String emailWrite(@RequestParam(required = false) String targetEmpIds, Model model) {
    //log.info("targetEmpIds {}", targetEmpIds);
    // 파라미터가 들어왔을 때 (1명이든 여러 명이든)
    if (targetEmpIds != null && !targetEmpIds.isEmpty()) {
        // 콤마로 나눔
        String[] idArray = targetEmpIds.split(",");
        List<EmployeeVO> recipients = new ArrayList<>();

        for (String id : idArray) {
            // 공백 제거 후 조회
            EmployeeVO emp = this.employeeMapper.findByEmpId(Integer.parseInt(id.trim()));
            if (emp != null) {
                recipients.add(emp);
            }
        }
        model.addAttribute("recipients", recipients);
        //log.info("recipients {}", recipients);
    }

    model.addAttribute("contentPage", "email/write");
    return "main";
}
    private final String apiKey = "";
    private final String domain = "";
    private final String url = "https://api.mailgun.net/v3/" + domain + "/messages";


    /**
     * 외부 메일 전송
     * @param emailVO
     * @param auth
     * @return
     */
    @ResponseBody
    @PostMapping("/sendext")
    public String sendext( EmailVO emailVO, Authentication auth){
        //log.info("extformData잘 왔나요? : {}", emailVO);
        RestTemplate restTemplate = new RestTemplate();

        // 1. Basic Auth 설정 (API Key)
        HttpHeaders headers = new HttpHeaders();
        headers.setBasicAuth("api", apiKey);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int userID = employeeVO.getEmpId();
        String userName = employeeVO.getEmpNm();
        //입력된 이메일주소 추출
        String emailAddr=emailVO.getEmlOtsdRcvrAddr();

        // 2. 메일 데이터 구성 (QueryString 대신 Form 데이터로)
        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("from", userName+" <"+userID+"@" + domain + ">");
        body.add("to", "WORKUP 고객사 <"+emailAddr+">");
        body.add("subject", emailVO.getEmlTtl());
        body.add("text", emailVO.getEmlCn());

        emailVO.setEmlOtsdYn("Y");
        emailVO.setEmlSndrId(userID);
        int res = this.emailService.sendMail(emailVO, null);

        // 3. 요청 전송
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(body, headers);
        ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);

        System.out.println("결과: " + response.getBody());
        return  "SUCCESS";
    }
    /**
     * 외부 메일 수신
     * @param sender
     * @param recipient
     * @param subject
     * @param bodyPlain
     * @return
     */
    @ResponseBody
    @PostMapping("/receiveext")
    public ResponseEntity<String> receiveext( @RequestParam("sender") String sender,
                              @RequestParam("recipient") String recipient,
                              @RequestParam("subject") String subject,
                              @RequestParam("body-plain") String bodyPlain){
        //외부에서 들어오는 메일 내용!!
        //log.info("receiveext 잘 왔나요? : {}", sender);
        //log.info("recipient 잘 왔나요? : {}", recipient);
        //log.info("subject 잘 왔나요? : {}", subject);
        //log.info("bodyPlain 잘 왔나요? : {}", bodyPlain);
        System.out.println("새 메일 도착!");
        System.out.println("발신자: " + sender);
        System.out.println("내용: " + bodyPlain);
        //내용을 우리  DB에 저장!
        EmailVO emailVO = new EmailVO();

        emailVO.setEmlOtsdYn("Y");
        emailVO.setEmlOtsdSndrAddr(sender);
        emailVO.setEmlTtl(subject);
        emailVO.setEmlCn(bodyPlain);
        String userId = recipient.split("@")[0];
        int empNo = Integer.valueOf(userId);
        List<Integer> emlRcvrIds= new ArrayList<>();
        emlRcvrIds.add(empNo);

        emailVO.setEmlRcvrIds(emlRcvrIds);

        int res = this.emailService.sendMail(emailVO,null);

        //log.info("결과 : {}", res);

        // 2. 리턴값: 반드시 200 OK를 보내야 한다고 한다.,,
        return ResponseEntity.ok("OK");
    }
    /// //////////////////////////////////메일박스/// //////////////////////////////////

    @GetMapping("/mailbox")
    public String attendance(Model model) {
        model.addAttribute("contentPage", "/email/mailbox");
        return "main";
    }

    @ResponseBody
    @PostMapping("/mailboxlist")
    public List<EmailBoxVO> mailboxlist(Authentication auth){
        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        List<EmailBoxVO> emailBoxVOList=
        this.emailService.getemailBoxVOList(employeeVO.getEmpId());
        log.info("emailBoxVOList : {}", emailBoxVOList);
        return emailBoxVOList;
    }

    /**
     * 메일박스 이름 변경
     * @param auth
     * @param emailBoxVO
     * @return
     */
    @ResponseBody
    @PostMapping("/updateBox")
    public ResponseEntity<?> updateBox(Authentication auth, @RequestBody EmailBoxVO emailBoxVO){

        log.info("updateBox->emailBoxVO 전 : {}", emailBoxVO);

            try {
                //log.info("readOrDelOrImpt->params : {}", params);
                //로그인한 사원아이디추출
                CustomUser customUser = (CustomUser) auth.getPrincipal();
                EmployeeVO employeeVO = customUser.getEmpVO();
                //로그인한 사원아이디 값넣기
                emailBoxVO.setEmpId(employeeVO.getEmpId());
                int result = this.emailService.updateBox(emailBoxVO);
                //log.info("readOrDelOrImpt->result : {}", result);

                log.info("updateBox->emailBoxVO 후  : {}", emailBoxVO);

                if (result > 0) {
                    // 성공 시 200 OK와 함께 결과값 전달
                    return ResponseEntity.ok(result);
                } else {
                    // 로직상 실패 시 400 Bad Request 등 전달
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
                }
            } catch (Exception e) {
                // 서버 에러 발생 시 500 Internal Server Error 전달
                //log.error("메일 상태 변경 중 에러 발생: ", e);
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
            }

    }

    /**
     * 새 메일박스 추가
     * @param auth
     * @param emailBoxVO
     * @return
     */
    @ResponseBody
    @PostMapping("/insertBox")
    public ResponseEntity<?> insertBox(Authentication auth, @RequestBody EmailBoxVO emailBoxVO){

        log.info("insertBox->emailBoxVO 전 : {}", emailBoxVO);

        try {
            //log.info("readOrDelOrImpt->params : {}", params);
            //로그인한 사원아이디추출
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();
            //로그인한 사원아이디 값넣기
            emailBoxVO.setEmpId(employeeVO.getEmpId());
            int result = this.emailService.insertBox(emailBoxVO);
            //log.info("readOrDelOrImpt->result : {}", result);

            log.info("insertBox->emailBoxVO 후  : {}", emailBoxVO);

            if (result > 0) {
                // 성공 시 200 OK와 함께 결과값 전달
                return ResponseEntity.ok(result);
            } else {
                // 로직상 실패 시 400 Bad Request 등 전달
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
            }
        } catch (Exception e) {
            // 서버 에러 발생 시 500 Internal Server Error 전달
            //log.error("메일 상태 변경 중 에러 발생: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
        }
    }
    /**
     * 새 메일박스 추가
     * @param auth
     * @param emailBoxVO
     * @return
     */
    @ResponseBody
    @PostMapping("/deleteBox")
    public ResponseEntity<?> deleteBox(Authentication auth, @RequestBody EmailBoxVO emailBoxVO){

        log.info("insertBox->emailBoxVO 전 : {}", emailBoxVO);

        try {
            //log.info("readOrDelOrImpt->params : {}", params);
            //로그인한 사원아이디추출
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();
            //로그인한 사원아이디 값넣기
            emailBoxVO.setEmpId(employeeVO.getEmpId());
            int result = this.emailService.deleteBox(emailBoxVO);
            //log.info("readOrDelOrImpt->result : {}", result);

            log.info("insertBox->emailBoxVO 후  : {}", emailBoxVO);

            if (result > 0) {
                // 성공 시 200 OK와 함께 결과값 전달
                return ResponseEntity.ok(result);
            } else {
                // 로직상 실패 시 400 Bad Request 등 전달
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
            }
        } catch (Exception e) {
            // 서버 에러 발생 시 500 Internal Server Error 전달
            //log.error("메일 상태 변경 중 에러 발생: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
        }
    }
    @ResponseBody
    @PostMapping("/checkMailExist")
    public int checkMailExist(Authentication auth, @RequestBody EmailBoxVO emailBoxVO) {

        log.info("insertBox->emailBoxVO 전 : {}", emailBoxVO);

            //log.info("readOrDelOrImpt->params : {}", params);
            //로그인한 사원아이디추출
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();
            //로그인한 사원아이디 값넣기
            emailBoxVO.setEmpId(employeeVO.getEmpId());
            int result = this.emailService.checkMailExist(emailBoxVO);
            //log.info("readOrDelOrImpt->result : {}", result);

            log.info("insertBox->emailBoxVO 후  : {}", emailBoxVO);
            return result;
    }


}
