package kr.or.ddit.mapper;


import kr.or.ddit.vo.ClubBoradVO;
import kr.or.ddit.vo.ClubMemberVO;
import kr.or.ddit.vo.ClubNoticeVO;
import kr.or.ddit.vo.ClubVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;


@Mapper
public interface ClubMapper {

    //동아리 회원인지 아닌지 확인
    public ClubMemberVO getClubMember(ClubMemberVO clubMemberVO);

    //가입
    public int join(ClubMemberVO clubMemberVO);

    //동아리 회원 목록 가져오기
    public List<ClubMemberVO> getClubMemberList(int clubNo);

    //동호회 번호로 동호회 정보 가져오기(소개 페이지 용)
    public ClubVO getClubInfo(int i);

    //동호회 멤버수 가져오기
    public int getClubMemberCount(int i);

    //동호회 탈퇴
    public int leaveClub(ClubMemberVO clubMemberVO);


    //동호회 공지사항 총 개수
    public int getClubNoticeTotal(Map<String, Object> map);

    //동호회 공지사항 리스트 가져오기
    public List<ClubNoticeVO> clubNoticeListAxios(ClubNoticeVO clubNoticeVO);

    //동호회 공지사항 조회수 ++
    public int plusClubNoticeCnt(int clubNtcNo);

    //동호회 공지사항 상세 가져오기
    public ClubNoticeVO clubNoticeDetail(int clubNtcNo);

    //동호회 공지사항 쓰기
    public int noticeWrite(ClubNoticeVO clubNoticeVO);

    //공지사항 삭제하기
    public int noticeDelete(int clubNtcNo);

    //포토갤러리 작성하기
    public int galleryWrite(ClubBoradVO clubBoradVO);

    //포토 갤러리 총 개수
    public int getClubBoardTotal(Map<String, Object> map);

    //포토갤러리 목록 가져오기
    public List<ClubBoradVO> clubBoardListAxios(ClubBoradVO clubBoradVO);

    //동호회 포토갤러리 조회수 ++
    public int plusClubBoardCnt(int clubBbsNo);

    //동호회 포토갤러리 상세 가져오기
    public ClubBoradVO clubBoardDetail(int clubBbsNo);

    //포토 갤러리 삭제하기
    public int galleryDelete(int clubBbsNo);

    /**
     * (관리자) 동호회 목록 가져오기(동호회 정보)
     * @return List<ClubVO> 동호회 목록
     */
    public List<ClubVO> getClubList();

    /**
     * 관리자 페이지 동호회 게시글 월별 차트 값
     * @return 월별 게시글 List Map
     */
    public List<Map<String, Object>> getClubMonthlyActivity();


    //대시보드에 띄울 포토갤러리 사진
    public List<ClubBoradVO> getRecentClubPhotos();


    //(관리자) 동호회 회원 리스트
    public List<ClubMemberVO> clubMemberList();

    //(관리자) 동호회 공지사항 리스트
    public List<ClubNoticeVO> clubNoticeList();

    //(관리자) 동호회 갤러리 리스트
    public List<ClubBoradVO> clubGalleryList();



}
