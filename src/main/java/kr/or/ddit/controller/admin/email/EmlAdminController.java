package kr.or.ddit.controller.admin.email;

import kr.or.ddit.service.EmailService;
import kr.or.ddit.service.EmployeeService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.EmailVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequestMapping("/admin/email")
@Slf4j
@CrossOrigin(origins = "http://localhost:5173")
@Controller
public class EmlAdminController {

    @Autowired
    EmployeeService employeeService;
    @Autowired
    EmailService emailService;

    @ResponseBody
    @GetMapping("/search")
    public List<EmployeeVO> searchMember(@RequestParam("query") String query) {
        log.info("email/search=>query 파라미터가 잘 갔나요? {}", query);
        // DB에서 이름이나 사원번호로 검색 (예: WHERE name LIKE %query%)
        List<EmployeeVO> list = this.employeeService.findMembersByQuery(query);
        log.info("리스트가 왔나요?=>list {}", list);
        return this.employeeService.findMembersByQuery(query);
    }

    //이메일 전송
    @ResponseBody
    @PostMapping("/send")
    public ResponseEntity<?> send (EmailVO emailVO, Authentication auth){
        try {
            log.info("send->emailVO : {}", emailVO);
            log.info("send->multipartFiles : {}", emailVO.getMultipartFiles());
            //로그인한 사원아이디추출
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();
            //로그인한 사원아이디 값넣기
            emailVO.setEmlSndrId(employeeVO.getEmpId());

            int result = this.emailService.sendMail(emailVO, null);
            if (result > 0) {
                // 성공 시 200 OK와 함께 결과값 전달
                return ResponseEntity.ok(result);
            } else {
                // 로직상 실패 시 400 Bad Request 등 전달
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("전송 실패");
            }
        } catch (Exception e) {
            // 서버 에러 발생 시 500 Internal Server Error 전달
            log.error("메일 전송 중 에러 발생: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
        }
    }

    /**
     *
     * 관리자 전용 리스트 => 모든 이메일
     * @param mav
     * @param pageNum
     * @param pageFilter
     * @param emailVO
     * @param auth
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/AdminlistAllAxios", method = RequestMethod.POST)
    public ArticlePage<EmailVO> AdminlistAllAxios(ModelAndView mav,
                                          @CookieValue(name = "pageNum", defaultValue = "10") int pageNum,
                                          @CookieValue(name = "pageFilter", defaultValue = "All") String pageFilter,
                                          @RequestBody EmailVO emailVO,
                                          Authentication auth) {
        log.info("list->mode : " + emailVO.getMode());
        log.info("list->keyword : " + emailVO.getKeyword());
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
        log.info("현재 페이지 정보 : {} ",emailVO.getCurrentPage());
        map.put("currentPage", emailVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", emailVO.getMode());
        map.put("keyword", emailVO.getKeyword());
        map.put("empId", employeeVO.getEmpId());
        map.put("url","/list");
        System.out.println("쿠키에서 가져온 페이지 번호: " + pageNum);
        System.out.println("쿠키에서 가져온 pageFilter: " + pageFilter);

        map.put("pageFilter",pageFilter);

        //log.info("list->map : " + map);

        //전체 행의 수 (검색 시 검색 반영)
        int total = this.emailService.getAdminListAllTotalCount(map);
        //log.info("list->total : " + total);
        //리액트니까 모든 VO 걍 다 넣어버려
        int size = total;
        List<EmailVO> emailVOList = this.emailService.getAdminListAllList(map);
        //log.info("list->bookVOList : " + emailVOList);

        //***페이지네이션
        ArticlePage<EmailVO> articlePage = new ArticlePage<EmailVO>(total, emailVO.getCurrentPage(), size, emailVO.getKeyword(), emailVOList
                , emailVO.getMode(), map);
        //log.info("list->articlePage : " + articlePage);

        //forwarding
        return articlePage;
    }

//리스트 불러오기 (페이징처리되어있음)
    @ResponseBody
    @RequestMapping(value = "/listAxios", method = RequestMethod.POST)
    public ArticlePage<EmailVO> listAxios(ModelAndView mav,
                                          @CookieValue(name = "pageNum", defaultValue = "10") int pageNum,
                                          @CookieValue(name = "pageFilter", defaultValue = "All") String pageFilter,
                                         @RequestBody EmailVO emailVO,
                                          Authentication auth) {
        log.info("list->mode : " + emailVO.getMode());
        log.info("list->keyword : " + emailVO.getKeyword());
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
        log.info("현재 페이지 정보 : {} ",emailVO.getCurrentPage());
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

        log.info("list->map : " + map);

        //전체 행의 수 (검색 시 검색 반영)
        int total = this.emailService.getTotalCount(map);
        log.info("list->total : " + total);

        List<EmailVO> emailVOList = this.emailService.getList(map);
        log.info("list->bookVOList : " + emailVOList);

        //***페이지네이션
        ArticlePage<EmailVO> articlePage = new ArticlePage<EmailVO>(total, emailVO.getCurrentPage(), size, emailVO.getKeyword(), emailVOList
                , emailVO.getMode(), map);
        log.info("list->articlePage : " + articlePage);

        //forwarding
        return articlePage;
    }


    //보낸 메일함 리스트 불러오기 (페이징처리되어있음)
    @ResponseBody
    @RequestMapping(value = "/listSendAxios", method = RequestMethod.POST)
    public ArticlePage<EmailVO> listSendAxios(ModelAndView mav,
                                          @CookieValue(name = "pageNum", defaultValue = "10") int pageNum,
                                          @CookieValue(name = "pageFilter", defaultValue = "All") String pageFilter,
                                          @RequestBody EmailVO emailVO,
                                          Authentication auth) {
        log.info("list->mode : " + emailVO.getMode());
        log.info("list->keyword : " + emailVO.getKeyword());
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

        log.info("list->map : " + map);

        //전체 행의 수 (검색 시 검색 반영)
        int total = this.emailService.getTotalSendCount(map);
        log.info("list->total : " + total);

        List<EmailVO> emailVOList = this.emailService.getSendList(map);
        log.info("list->bookVOList : " + emailVOList);

        //***페이지네이션
        ArticlePage<EmailVO> articlePage = new ArticlePage<EmailVO>(total, emailVO.getCurrentPage(), size, emailVO.getKeyword(), emailVOList
                , emailVO.getMode(), map);
        log.info("list->articlePage : " + articlePage);

        //forwarding
        return articlePage;
    }


    //휴지통 리스트 불러오기 (페이징처리되어있음)
    @ResponseBody
    @RequestMapping(value = "/listTrashAxios", method = RequestMethod.POST)
    public ArticlePage<EmailVO> listTrashAxios(ModelAndView mav,
                                          @CookieValue(name = "pageNum", defaultValue = "10") int pageNum,
                                          @CookieValue(name = "pageFilter", defaultValue = "All") String pageFilter,
                                          @RequestBody EmailVO emailVO,
                                          Authentication auth) {
        log.info("list->mode : " + emailVO.getMode());
        log.info("list->keyword : " + emailVO.getKeyword());
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

        log.info("list->map : " + map);

        //전체 행의 수 (검색 시 검색 반영)
        int total = this.emailService.getTotalTrashCount(map);
        log.info("list->total : " + total);

        List<EmailVO> emailVOList = this.emailService.getTrashList(map);
        log.info("list->bookVOList : " + emailVOList);

        //***페이지네이션
        ArticlePage<EmailVO> articlePage = new ArticlePage<EmailVO>(total, emailVO.getCurrentPage(), size, emailVO.getKeyword(), emailVOList
                , emailVO.getMode(), map);
        log.info("list->articlePage : " + articlePage);

        //forwarding
        return articlePage;
    }

    //상세보기 - 비동기처리
    @ResponseBody
    @PostMapping("/detailAxios")
    public EmailVO detailAxios(@RequestBody Map<String, Integer> param){

        log.info("detailAxios->emlNo : {}", param);

        int emlRcvrId= param.get("emlRcvrId");
        log.info("detailAxios->emlNo : {}", emlRcvrId);

        //emlRcvrId 넘겨서 상세 받아오기
        EmailVO emailVO = this.emailService.findByNo(emlRcvrId);
        log.info("detailAxios->emailVO : {}", emailVO);
        return emailVO;
    }
    //상세보기 - 비동기처리
    @ResponseBody
    @PostMapping("/detailSendAxios")
    public EmailVO detailSendAxios(@RequestBody Map<String, Integer> param){

        log.info("detailAxios->emlNo : {}", param);

        int emlNo= param.get("emlNo");
        log.info("detailAxios->emlNo : {}", emlNo);

        //emlRcvrId 넘겨서 상세 받아오기
        EmailVO emailVO = this.emailService.findByNoSend(emlNo);
        log.info("detailAxios->emailVO : {}", emailVO);
        return emailVO;
    }

    //체크박스 중요,삭제,읽음처리
    @ResponseBody
    @PostMapping("/readOrDelOrImpt")
    public ResponseEntity<?> readOrDelOrImpt (@RequestBody Map<String, Object> params,Authentication auth){

    try {
        log.info("readOrDelOrImpt->params : {}", params);
        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        //로그인한 사원아이디 값넣기
        params.put("empId", employeeVO.getEmpId());
        int result = this.emailService.readOrDelOrImpt(params);
        log.info("readOrDelOrImpt->result : {}", result);

        if (result > 0) {
            // 성공 시 200 OK와 함께 결과값 전달
            return ResponseEntity.ok(result);
        } else {
            // 로직상 실패 시 400 Bad Request 등 전달
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
        }
    } catch (Exception e) {
        // 서버 에러 발생 시 500 Internal Server Error 전달
        log.error("메일 상태 변경 중 에러 발생: ", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
    }

    }

    // 개별
    @ResponseBody
    @PostMapping("/updateIsImpt")
    public ResponseEntity<?> updateIsImpt(@RequestBody Map<String, Object> map){
        //테이블 기본키
        String emlIdStr = String.valueOf(map.get("dataId"));
        int emlRcvrId=Integer.valueOf(emlIdStr);
        //토글이므로 원래 상태와 반대값 세팅 (N or Y)
        String setImpt = String.valueOf(map.get("setImpt"));
        log.info("updateIsImpt->emlRcvrId : {}", emlRcvrId);
        try {
            int res = this.emailService.isImpt(setImpt,emlRcvrId);
            log.info("updateIsImpt->res(1이면성공) : {}", res);
            if(res>0){
                return ResponseEntity.ok(res);
            }else {
                return  ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
            }
        } catch (Exception e) {
            log.error("개별 중요업데이트 에러남 : ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버오류");
        }
    }
    //영구삭제
    @ResponseBody
    @PostMapping("/deletePermanent")
    public ResponseEntity<?> deletePermanent (@RequestBody Map<String, Object> params,Authentication auth){

        try {
            log.info("readOrDelOrImpt->params : {}", params);
            //로그인한 사원아이디추출
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            EmployeeVO employeeVO = customUser.getEmpVO();
            //로그인한 사원아이디 값넣기
            params.put("empId", employeeVO.getEmpId());
            int result = this.emailService.readOrDelOrImpt(params);
            log.info("readOrDelOrImpt->result : {}", result);

            if (result > 0) {
                // 성공 시 200 OK와 함께 결과값 전달
                return ResponseEntity.ok(result);
            } else {
                // 로직상 실패 시 400 Bad Request 등 전달
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("메일 상태 변경 실패");
            }
        } catch (Exception e) {
            // 서버 에러 발생 시 500 Internal Server Error 전달
            log.error("메일 상태 변경 중 에러 발생: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
        }

    }
    //상단바 메일 알람
    @ResponseBody
    @GetMapping("/mailAlarm")
    public List<EmailVO> mailAlarm(Authentication auth){
        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        List<EmailVO> emailVOList = this.emailService.getNotReadMail(employeeVO.getEmpId());
        log.info("mailAlarm->employeeVO.getEmpId() : {}", employeeVO.getEmpId());
        return emailVOList;
    }


//디테일보기 테스트
    @GetMapping("/detail/{emlNo}")
    public String detail(@PathVariable int emlNo, Model mav){
        log.info("test->emlNo : {}", emlNo);
        EmailVO emailVO = this.emailService.findByNo(emlNo);
        log.info("test->emailVO : {}", emailVO);
        mav.addAttribute("contentPage", "email/detail");
        mav.addAttribute("emailVO", emailVO);
        return "main";
    }

}
