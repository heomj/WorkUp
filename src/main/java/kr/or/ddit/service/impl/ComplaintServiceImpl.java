package kr.or.ddit.service.impl;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import kr.or.ddit.mapper.ComplaintMapper;
import kr.or.ddit.service.ComplaintService;
import kr.or.ddit.service.AlarmService;
import kr.or.ddit.vo.ComplaintVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ComplaintServiceImpl implements ComplaintService {

    @Autowired
    private ComplaintMapper complaintMapper; // 모든 신고/게시글 제어 메서드가 여기 들어있음

    @Autowired
    private AlarmService alarmService;

    @Override
    public int insertComplaint(ComplaintVO complaintVO) {
        return this.complaintMapper.insertComplaint(complaintVO);
    }

    @Override
    public List<ComplaintVO> selectComplaintList(Map<String, Object> map) {
        return this.complaintMapper.selectComplaintList(map);
    }

    /**
     * 3. 신고 상태 변경 및 3진 아웃 자동 처리
     */
    @Transactional
    @Override
    public int updateComplaintStatus(ComplaintVO complaintVO) {
        // 1. 신고 내역 상태 업데이트 (COMPLAINT 테이블 상태 변경)
        int result = this.complaintMapper.updateComplaintStatus(complaintVO);
        
        // 2. 상태가 '처리완료'이거나 '경고'인 경우에만 실행
        if(result > 0 && ("처리완료".equals(complaintVO.getDclStts()) || "경고".equals(complaintVO.getDclStts()))) {
            int bbsNo = complaintVO.getDclBbsNo(); 
            
            // (1) 핵심: 여기서 Mapper가 실제 COMPLAINT 개수를 세서 BBS_BOARD를 업데이트합니다.
            this.complaintMapper.incrementBoardReportCnt(bbsNo);
            
            // (2) 업데이트된 DB 값을 다시 가져옵니다 (가장 정확한 최신값)
            int currentReportCnt = this.complaintMapper.getBoardReportCnt(bbsNo);
            
            // (3) 3회 이상이면 블라인드 처리
            if(currentReportCnt >= 3) {
                this.complaintMapper.blindBoard(bbsNo);
                log.warn("신고 {}회 누적으로 게시글 {}번이 자동 블라인드(D) 처리되었습니다.", currentReportCnt, bbsNo);
            }
            
            // 최신 횟수 세팅
            complaintVO.setReportCnt(currentReportCnt);
        }
        
        return result;
    }

    @Override
    public ComplaintVO selectComplaintDetail(int dclNo) {
        return this.complaintMapper.selectComplaintDetail(dclNo);
    }

    // --- 인터페이스 추가 메서드 구현부 (에러 해결 핵심) ---
    
    @Override
    public int incrementAndGetReportCnt(int bbsNo) {
        // 1. 신고 누적 횟수 증가 (UPDATE 실행)
        this.complaintMapper.incrementBoardReportCnt(bbsNo);
        
        // 2. 현재 누적 횟수 가져오기 (SELECT 실행)
        Integer count = this.complaintMapper.getBoardReportCnt(bbsNo);
        
        // 3. 만약 DB에 데이터가 없어 null이 오면 0을 반환하도록 방어
        return (count == null) ? 0 : count;
    }

    @Override
    public int blindBoard(int bbsNo) {
        return this.complaintMapper.blindBoard(bbsNo);
    }

    @Override
    public Integer getBoardReportCnt(int bbsNo) {
        // 조회 메서드도 Mapper의 반환값(Integer)을 그대로 넘깁니다.
        return this.complaintMapper.getBoardReportCnt(bbsNo);
    }
    
    /**
     * 게시글의 신고 누적 횟수를 0으로 강제 초기화
     */
    @Override
    public void resetReportCount(int bbsNo) {
        // Mapper를 통해 DB의 BBS_REPORT_CNT 컬럼을 0으로 업데이트합니다.
        int result = this.complaintMapper.resetReportCount(bbsNo);
        
        if(result > 0) {
            log.info("### 게시글 {}번의 신고 누적 횟수가 성공적으로 초기화되었습니다.", bbsNo);
        } else {
            log.error("### 게시글 {}번 신고 횟수 초기화 실패!", bbsNo);
        }
    }
}