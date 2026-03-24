package kr.or.ddit.service;

import java.util.List;
import java.util.Map;
import kr.or.ddit.vo.ReserveVO;

public interface ReserveService {
    // 1. 공통 및 현황
    List<Map<String, Object>> getAllReserveList();
    Map<String, Object> getMyTeamLeader(String empId); 
    List<ReserveVO> getMyReserveList(String empId);
    
    // 2. 회의실 관련
    List<ReserveVO> getMtgRoomList();
    List<String> getReservedTimes(Map<String, Object> map);
    int insertMtgRoomReserve(ReserveVO reserveVO);
    int updateMtgRoomReserve(ReserveVO reserveVO);
    int deleteMtgRoomReserve(String resId);
    
    // 3. 비품 및 자산 관련
    List<ReserveVO> getFixtList();
    int insertFixtReserve(ReserveVO reserveVO);
    int updateFixtReserve(ReserveVO reserveVO);
    int deleteFixtReserve(String resId);
    
    // 4. 결재 관련
    List<ReserveVO> getPendingApprovalList(String empId);
    int approveReserve(Map<String, String> paramMap);
   
    int checkRoomOverlap(ReserveVO reserveVO);
    int checkFixtOverlap(ReserveVO reserveVO);
    
    // 5. 관리자 전용 자산 마스터 데이터 관리
    List<ReserveVO> getAdminRoomList();
    List<ReserveVO> getAdminFixtList();
    
    int insertAdminRoom(ReserveVO reserveVO);
    int updateAdminRoom(ReserveVO reserveVO);
    int deleteAdminRoom(int rmNo);
    
    int insertAdminFixt(ReserveVO reserveVO);
    int updateAdminFixt(ReserveVO reserveVO);
    int deleteAdminFixt(int fixtNo);
}