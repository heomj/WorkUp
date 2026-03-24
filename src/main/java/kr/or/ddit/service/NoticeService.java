package kr.or.ddit.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.vo.NoticeVO;

public interface NoticeService {

    // 1. 공지사항 등록 (첨부파일 처리 로직 포함)
    public int insertNotice(NoticeVO noticeVO);

    // 2. 공지사항 상세 조회 (조회수 증가 로직 포함)
    public NoticeVO selectNoticeDetail(NoticeVO noticeVO);

    // 3. 공지사항 목록 조회 (검색 및 페이징 파라미터 포함)
    public List<NoticeVO> selectNoticeList(Map<String, Object> map);

    // 4. 전체 공지사항 행의 수 조회 (페이징 처리를 위함)
    public int selectNoticeCount(Map<String, Object> map);

    // 5. 공지사항 수정 실행
    public int updateNotice(NoticeVO noticeVO);

    // 6. 공지사항 삭제 실행
    public int deleteNotice(int ntcNo);

    // 7. 조회수 증가 (단독 호출용)
    public void incrementViewCount(int ntcNo);
    
    // 긴급 공지 최신글 1건 가져오기
    NoticeVO selectLatestUrgentNotice();
    
}