package kr.or.ddit.controller;

import kr.or.ddit.service.EmployeeService;

import kr.or.ddit.service.SalaryService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.SalaryMasterVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/emp")
@Controller
public class EmployeeController {


    @Value("${file.prfFolder}")
    private String prfFolder;

    @Value("${file.signFolder}")
    private String signFolder;

    @Autowired
    EmployeeService employeeService;

    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    @Autowired
    private SalaryService salaryService;


    // 비밀번호 변경 시 기존 비밀번호랑 일치 하는지
    @ResponseBody
    @GetMapping("/chkpw")
    public boolean chkpw(EmployeeVO vo, Authentication auth) {
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        String empPw = customUser.getEmpVO().getEmpPw();

        // 비밀번호 ㅏㅁㅈ는지 check
        String chgPw = vo.getEmpPw();
        log.info(chgPw);

        // matches는 반드시 (평문 비밀번호 , 암호화된 비밀번호) 순서로 해줘야한대
        return bCryptPasswordEncoder.matches(chgPw,empPw);
    }

    // 결재사인
    @GetMapping("/displaySign")
    @ResponseBody
    public Resource displaySign(@RequestParam("fileName") String fileName) {
        return new FileSystemResource(signFolder + fileName);
    }

    // 마이페이지 변경사항 저장하기
    @ResponseBody
    @PutMapping("/updateprof")
    public String updateprof(@ModelAttribute EmployeeVO vo, Authentication auth) {
        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmployeeVO securityVO = customUser.getEmpVO(); // 기존의 있는 시큐리티 세션값
        vo.setEmpId(securityVO.getEmpId());

        if (vo.getEmpPw() != null && !vo.getEmpPw().isEmpty()) {
            // 비밀번호가 null이 아니면 암호화
            String encodedPw = bCryptPasswordEncoder.encode(vo.getEmpPw());
            vo.setEmpPw(encodedPw);
        } else {
            // 아니면 null 처리 => 이건 쿼리에서 업데이트에서 제외되게 짯음!
            vo.setEmpPw(null);
        }

        // 파일 처리 (사인/프로필)
        MultipartFile signfile = vo.getSign();
        MultipartFile proffile = vo.getProf();

        // 사인 처리
        if(signfile != null && !signfile.isEmpty()) {
            String signFileName = signfile.getOriginalFilename();
            File saveFile = new File(signFolder, signFileName);
            try {
                signfile.transferTo(saveFile);
                vo.setEmpSign(signFileName);
            } catch (Exception e) { log.error(e.getMessage()); }
        } else {
            vo.setEmpSign(securityVO.getEmpSign());
        }

        // 프로필 처리
        if(proffile != null && !proffile.isEmpty()) {
            String priFileName = proffile.getOriginalFilename();
            File saveFile = new File(prfFolder, priFileName);
            try {
                proffile.transferTo(saveFile);
                vo.setEmpProfile(priFileName);
            } catch (Exception e) { log.error(e.getMessage()); }
        } else {
            vo.setEmpProfile(securityVO.getEmpProfile());
        }

        int result = this.employeeService.updateprof(vo);

        // 시큐리티 upate!
        if(result > 0) {
            // 비밀번호는 수정되었을 때만 d업뎃
            if(vo.getEmpPw() != null) {
                securityVO.setEmpPw(vo.getEmpPw());
            }

            securityVO.setEmpPhone(vo.getEmpPhone());
            securityVO.setEmpEml(vo.getEmpEml());
            securityVO.setEmpZip(vo.getEmpZip());
            securityVO.setEmpAdd1(vo.getEmpAdd1());
            securityVO.setEmpAdd2(vo.getEmpAdd2());
            securityVO.setEmpProfile(vo.getEmpProfile());
            securityVO.setEmpSign(vo.getEmpSign());

            Authentication newAuth = new UsernamePasswordAuthenticationToken(
                    customUser,  // 주체
                    auth.getCredentials(),   // 비밀번호
                    auth.getAuthorities()   // 권한리스트
            );

            // 이게 사원증(?) 시큐리티를 교체하는거래
            SecurityContextHolder.getContext().setAuthentication(newAuth);

            // SecurityContextHolder : 혀재 접속중인 사용자의 인증 정보가 보관되는 보관함
            // setAuthentication(newAuth) : newAuth는 새 사원증(내가 방금 수정한거)으로 교체된대

            return "success";
        } else {
            return "fail";
        }
    }

    // 급여 명세서 비동기 목록 조회
    @ResponseBody
    @RequestMapping(value = "/payslipList", method = RequestMethod.GET)
    public ArticlePage<SalaryMasterVO> payslipList(
            @RequestParam(value = "currentPage", required = false, defaultValue = "1") int currentPage,
            @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
            Authentication auth) {

        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();

        Map<String, Object> map = new HashMap<>();
        map.put("currentPage", currentPage);
        map.put("keyword", keyword); // 연도/월 검색용
        map.put("empId", empId);

        int size = 10; // 한 페이지에 10개

        // 1. 전체 행 수 구하기
        int total = this.salaryService.getTotalPayslip(map);
        // 2. 해당 페이지 리스트 가져오기
        List<SalaryMasterVO> list = this.salaryService.getPayslipList(map);

        // ArticlePage 생성 (기존 유틸 그대로 활용 🦾)
        ArticlePage<SalaryMasterVO> articlePage =
                new ArticlePage<>(total, currentPage, size, keyword, list);

        log.info("급여 리스트 호출 성공! -> {}", articlePage);

        return articlePage;
    }

    // 2. 급여 상세 조회 (보안 강화)
    @ResponseBody
    @GetMapping("/payslipDetail")
    public SalaryMasterVO getPayslipDetail(@RequestParam("salId") String salId, Authentication auth) {

        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();

        Map<String, Object> map = new HashMap<>();
        map.put("salId", salId);
        map.put("empId", empId); // 쿼리 조건에 내 사번을 넣어서 남의 급여를 못 보게 차단!

        SalaryMasterVO salaryVO = this.salaryService.getPayslipDetail(map);

        log.info("getPayslipDetail -> salaryVO: " + salaryVO);

        return salaryVO;
    }
}
