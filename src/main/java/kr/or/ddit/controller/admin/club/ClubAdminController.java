package kr.or.ddit.controller.admin.club;

import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.service.ClubService;
import kr.or.ddit.service.avatarService;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequestMapping("/admin/club")   // /admin << 써쥬셔야 합니당
@CrossOrigin(origins = "http://localhost:5173")  // 이것두 설정해쥬셔야 함!
@RestController
public class ClubAdminController {
    @Autowired
    avatarService avatarService;


    @Autowired
    ClubService clubService;




    /**
     * 관리자가 동호회 리스트(3개 고정) 불러오기 - 검색 파라미터 없음!
     * @return 동호회 리스트 VO
     */
    @ResponseBody
    @GetMapping("/clubList")
    public List<ClubVO> clubList() {

        log.info("🔍 관리자 동호회 현황 전체 리스트 조회 요청");

        List<ClubVO> list = this.clubService.getClubList();

        return list;
    }


    /**
     * 관리자 페이지 동호회 게시글 월별 차트 값
     * @return 월별 게시글 List Map
     */
    @ResponseBody
    @GetMapping("/activityStats")
    public List<Map<String, Object>> getClubMonthlyActivity() {
        return this.clubService.getClubMonthlyActivity();
    }


    /**
     * 관리자 페이지 동아리 회원리스트
     * @return 동아리 회원 List
     */
    @ResponseBody
    @GetMapping("/memberList")
    public List<ClubMemberVO> clubMemberList() {
        return this.clubService.clubMemberList();
    }


    /**
     * 관리자 페이지 동아리 공지사항 리스트
     * @return 동아리 회원 List
     */
    @ResponseBody
    @GetMapping("/noticeList")
    public List<ClubNoticeVO> clubNoticeList() {
        return this.clubService.clubNoticeList();
    }


    /**
     * 관리자 페이지 동아리 갤러리 리스트
     * @return 동아리 회원 List
     */
    @ResponseBody
    @GetMapping("/galleryList")
    public List<ClubBoradVO> clubGalleryList() {
        return this.clubService.clubGalleryList();
    }
















}

