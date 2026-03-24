package kr.or.ddit.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import kr.or.ddit.vo.NoticeVO;

@Mapper
public interface NoticeMapper {
	// 1. 공지사항 등록 (ntcNo는 xml의 selectKey에서 처리됨)
    public int insertNotice(NoticeVO noticeVO);

    // 2. [수정] 공지사항 상세 조회 
    // XML의 parameterType="int"와 맞추기 위해 int ntcNo를 직접 받습니다.
    public NoticeVO selectNoticeDetail(int ntcNo);

    // 3. 공지사항 목록 조회 (페이징/검색 파라미터 담긴 Map)
    public List<NoticeVO> selectNoticeList(Map<String, Object> map);

    // 4. 전체 행의 수 (페이징 계산용)
    public int selectNoticeCount(Map<String, Object> map);

    // 5. 공지사항 수정
    public int updateNotice(NoticeVO noticeVO);

    // 6. 공지사항 삭제 (NTC_DEL_YN = 'Y' 처리)
    public int deleteNotice(int ntcNo);

    // 7. 조회수 증가
    public int incrementViewCount(int ntcNo);
    
    // 기존 첨부파일 삭제
 	public int deleteFileDetail(String fileDtlId);
    
    // 기존 파일들을 새로운 FILE_ID 그룹으로 옮기는 메서드
 	public int migrateFiles(Map<String, Object> map);
 	
 	NoticeVO selectLatestUrgentNotice();
}