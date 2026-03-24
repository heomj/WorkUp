package kr.or.ddit.service;

import java.util.List;
import java.util.Map;
import kr.or.ddit.vo.ComplaintVO;

public interface ComplaintService {
    
    // 1. 신고 접수 (사원들이 사용하는 기능)
    public int insertComplaint(ComplaintVO complaintVO);
    
    // 2. 신고 목록 조회 (관리자용 - 페이징/검색 포함 가능)
    public List<ComplaintVO> selectComplaintList(Map<String, Object> map);
    
    // 3. 신고 상태 변경 (관리자가 '처리완료', '반려' 등을 수행)
    public int updateComplaintStatus(ComplaintVO complaintVO);
    
    // 4. 신고 상세 내역 확인
    public ComplaintVO selectComplaintDetail(int dclNo);
    
    // 게시글 신고 횟수 증가 및 현재 횟수 반환
    public int incrementAndGetReportCnt(int bbsNo);
    
    // 게시글 블라인드 처리 (상태 'D'로 변경)
    public int blindBoard(int bbsNo);
    
    // 현재 게시글의 신고 횟수 조회
    public Integer getBoardReportCnt(int bbsNo);
    
    // 게시글 신고 횟수 초기화 메서드 추가
    void resetReportCount(int bbsNo);
}