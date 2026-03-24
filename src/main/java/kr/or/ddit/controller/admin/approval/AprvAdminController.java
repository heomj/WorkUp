package kr.or.ddit.controller.admin.approval;

import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.service.avatarService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.ApprovalVO;
import kr.or.ddit.vo.AvatarVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/admin/aprv")   // /admin << 써쥬셔야 합니당
@CrossOrigin(origins = "http://localhost:5173")  // 이것두 설정해쥬셔야 함!
@RestController
public class AprvAdminController {
    @Autowired
    avatarService avatarService;

    @Autowired
    ApprovalService approvalService;



    //관리자가 전체 부서 목록 보기...
    @ResponseBody
    @PostMapping("/allAprvListAxios")
    public ArticlePage<ApprovalVO> aprvListAxios(
            @RequestBody ApprovalVO approvalVO
    ){

        log.info("관리자 list->mode : " + approvalVO.getMode());//mode : 값 or mode : ""
        log.info("관리자 list->keyword : " + approvalVO.getKeyword());//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", approvalVO.getCurrentPage());// /list?currentPage=3 => 3, /list => 1
        map.put("mode", approvalVO.getMode()); // 첫 접속시 ""
        map.put("keyword", approvalVO.getKeyword()); // 첫 접속시 ""

        map.put("deptFilter", approvalVO.getDeptFilter()); // 부서코드
        map.put("statusFilter", approvalVO.getStatusFilter()); // 상태코드
        map.put("url", "");

        //한 화면에 10행씩 보여주자
        int size = 10;

        //전체 행의 수(검색 시 검색 반영)
        int total = this.approvalService.getTotalAll(map);
        log.info("관리자페이지에서 전자결재 전체 list->total : " + total);

        List<ApprovalVO> aprvVOList = this.approvalService.allList(map);
        log.info("관리자페이지에서 전자결재 전체(검색) list->aprvVOList : " + aprvVOList);

        //*** 페이지네이션
        ArticlePage<ApprovalVO> articlePage
                = new ArticlePage<ApprovalVO>(total, approvalVO.getCurrentPage(), size, approvalVO.getKeyword(), aprvVOList
                , approvalVO.getMode(), map); //오버로딩 한 생성자(map 추가) 생성


        log.info("관리자 결재 list->articlePage : " + articlePage);

        //ArticlePage를 리턴
        return articlePage;
    }


    /**
     * 관리자 페이지) 예산에서 전자결재 선택하기(검색)
     * @param keyword 검색어
     * @return 전자결재 검색 List
     */
    @ResponseBody
    @GetMapping("/searchBudgetAprv")
    public List<ApprovalVO> searchBudgetAprv(
            @RequestParam("keyword") String keyword
    ){

        log.info("관리자 list->keyword : " + keyword);//keyword : 값 or keyword : ""

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("keyword", keyword); // 첫 접속시 ""

        map.put("url", "");

        List<ApprovalVO> aprvVOList = this.approvalService.searchBudgetAprvList(map);

        log.info("관리자 결재 list->searchBudgetAprv : " + aprvVOList);

        //결재문서 리스트를 리턴
        return aprvVOList;
    }







    //관리자가 결재문서 차트 보기..
    @ResponseBody
    @GetMapping("/getChartAxios")
    public ResponseEntity<Map<String, Object>> getChartAxios(){
        /*
        Spring이랑 react 연결 시 이렇게 하는게 백앤드 메너라고 하네여
        ResponseEntity는 상태코드까지 같이 보낼 수 있대요
        ResponseEntity.ok(resultMap)는 HTTP 상태 코드가 정상, (OK)일때만 보낼 수 있게 하는거고
        */
        //결과 담을 map
        Map<String, Object> resultMap = new HashMap<>();


        //맵에 담아보기..
        resultMap.put("donutData", this.approvalService.getDeptDocCount());
        resultMap.put("monthlyData", this.approvalService.getMonthlyDeptVolume());

        log.info("관리자페이지 차트 데이터  : " + resultMap);

        return ResponseEntity.ok(resultMap);
    }
















}

