package kr.or.ddit.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import kr.or.ddit.vo.ComplaintVO;

@Mapper
public interface ComplaintMapper {
    
    // 1. 신고 정보 등록
    public int insertComplaint(ComplaintVO complaintVO);
    
    // 2. 신고 목록 조회 (검색/페이징 조건 포함)
    public List<ComplaintVO> selectComplaintList(Map<String, Object> map);
    
    // 3. 전체 신고 건수 조회 (페이징 처리를 위함)
    public int selectComplaintCount(Map<String, Object> map);
    
    // 4. 신고 상태 변경 (접수 -> 처리중 -> 처리완료 등)
    public int updateComplaintStatus(ComplaintVO complaintVO);
    
    // 5. 특정 신고 상세 내역 조회
    public ComplaintVO selectComplaintDetail(int dclNo);
    
    // [추가] 게시글의 신고 누적 횟수를 1 증가시킴
    public int incrementBoardReportCnt(int bbsNo);

    // [추가] 현재 게시글의 신고 누적 횟수를 조회 (1, 2회인지 3회인지 판단용)
    public Integer getBoardReportCnt(int bbsNo);

    // [추가] 신고 3회 누적 시 게시글 상태를 'D'(Blind)로 변경
    public int blindBoard(int bbsNo);
    
    // 기존 삭제 로직 (필요 시 유지)
    public int deleteBoard(int bbsNo);
    
    // 게시글 신고 횟수를 0으로 업데이트
    public int resetReportCount(int bbsNo);
}