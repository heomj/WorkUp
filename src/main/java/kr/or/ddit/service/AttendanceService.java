package kr.or.ddit.service;

import kr.or.ddit.vo.*;

import java.util.List;
import java.util.Map;

public interface AttendanceService {
    //오늘 출근여부를 조회
    public int checkTodayAttendance(int empId);

    // 출근 도장 찍기
    public int insertAttendance(AttendanceVO attendanceVO);

    // 퇴근 도장 찍기
    public int updateCheckout(int empId);

    /* 여기서 부턴 휴가,출장,초과근무 신청 및 업뎃.. 귀찮아서 걍 attendanceService 빌려씀 시작*/
    //휴가 신청 인서트
    public int insertVacation(VacationDocumentVO vacationDoc);
    //출장 신청 인서트
    public int insertTrip(TripDocumentVO tripDoc);
    //초과근무 신청 인서트
    public int insertOvertime(OvertimeDocumentVO overtimeDoc);

    // 달력에 띄울 list
    public List<AttendanceVO> getAttendanceByMonth(int empId, String year, String month);
    //달력에 띄울 신청목록
    public List<AttendanceTypeVO> getApprovedCalendarEvents(int empId, String year, String month);

    // 전체 행 수 가져오기
    public int getTotalApplication(Map<String, Object> map);
    // 통합 리스트 가져오기
    public List<AttendanceTypeVO> getApplicationList(Map<String, Object> map);
    // 통합신청 목록 삭제
    public int deleteApplication(int empId, int attTypeId);
    // 통합신청 목록 결재
    public int updateStatusToPending(int empId, int attTypeId);

    // 부서별 사원검색조회 (다른사람 서비스에 만들기 좀 그래서 만든 ㅇㅅㅇ)
    public List<EmployeeVO> getEmployeesByDept(String deptNm);

    // 사원별 근태현황
    public List<Map<String, Object>> getMonthlyAttendanceReport(String empId, String startDate, String endDate);

    // 부서별 통계
    public List<DepartmentVO> getDeptAttendanceStats();

    // 근태수정
    public int updateAttendance(AttendanceVO attendanceVO);

    // 근태삭제
    public int deleteAttendance(AttendanceVO attendanceVO);
    // 사원별 통계(통계표)
    public List<Map<String, Object>> getMonthlyAttendanceReport2(String empId);

    /// ////////근태 리메이크 추가 호출 시작/////////////
    public AttendanceVO getTodayDetail(int empId);
    public AttendanceOutVO getTodayOutDetail(int empId);

    ///////////근태 리메이크 추가 호출 끝/////////////
    /// /// ////////데쉬보드/////////////
    public List<EmployeeVO> teamStatus(int empId);
}
