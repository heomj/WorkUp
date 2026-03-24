package kr.or.ddit.mapper;

import kr.or.ddit.vo.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AttendanceMapper {
    //오늘 출근여부를 조회
    public int checkTodayAttendance(int empId);

    // 출근 도장 찍기
    public int insertAttendance(AttendanceVO attendanceVO);

    // 퇴근 도장 찍기
    public int updateCheckout(int empId);

    // 금일 마일리지 조회
    public AttendanceVO selectTodayMlg(int empId);

    // 사원테이블에 마일리지(+)
    public int updateEmpMlg(EmployeeVO empVO);

    // 출근 시 상태 업데이트
    public int updateWorkStatusStart(int empId);

    // 퇴근 시 상태 업데이트
    public int updateWorkStatusEnd(int empId);

    /* 여기서 부턴 휴가,출장,초과근무 신청 및 업뎃.. 귀찮아서 걍 attendanceService 빌려씀 */
    //휴가 신청 인서트
    public int insertVacation(VacationDocumentVO vacationDoc);

    //출장 신청 인서트
    public int insertTrip(TripDocumentVO tripDoc);
    //초과근무 신청 인서트
    public int insertOvertime(OvertimeDocumentVO overtimeDoc);


    // 달력에 띄울 list
    public List<AttendanceVO> getAttendanceByMonth(int empId, String year, String month);
    //달력에 띄울 신청목록
    public List<AttendanceTypeVO> getApprovedCalendarEvents(Map<String, Object> params);

    // 전체 행 수 가져오기
    public int getTotalApplication(Map<String, Object> map);
    // 통합 리스트 가져오기
    public List<AttendanceTypeVO> getApplicationList(Map<String, Object> map);

    // ATT_TYPE_ID 아이디가 있는 테이블의 컬럼을 삭제
    public int deleteVacation(@Param("empId") int empId, @Param("attTypeId") int attTypeId); //휴가
    public int deleteBusinessTrip(@Param("empId") int empId, @Param("attTypeId") int attTypeId); //출장
    public int deleteOvertime(@Param("empId") int empId, @Param("attTypeId") int attTypeId); //초과근무

    // 부모테이블 해당 ATT_TYPE_ID삭제
    public void deleteCommonDoc(@Param("empId") int empId, @Param("attTypeId") int attTypeId);

    // ATT_TYPE_ID 아이디가 있는 테이블의 상태을 '신청중' 으로 변경
    public int updateVacationStatus(@Param("empId") int empId, @Param("attTypeId") int attTypeId); //휴가
    public int updateBusinessTripStatus(@Param("empId") int empId, @Param("attTypeId") int attTypeId); //출장
    public int updateOvertimeStatus(@Param("empId") int empId, @Param("attTypeId") int attTypeId); //초과근무

    //연차 차감 및 사용량 업데이트
    public int updateEmpLeave(@Param("empId") int empId, @Param("attTypeId") int attTypeId);


    // 부서별 사원검색조회 (다른사람 서비스에 만들기 좀 그래서 만든 ㅇㅅㅇ)
    public List<EmployeeVO> getEmployeesByDept(String deptNm);

    // 사원별 근태(현황)
    public List<Map<String, Object>> getMonthlyAttendanceReport(String empId, String startDate, String endDate);

    // 부서별 통계
    public List<DepartmentVO> getDeptAttendanceStats();

    // 근태수정
    public int updateAttendance(AttendanceVO attendanceVO);

    // 근태삭제
    public int deleteAttendance(AttendanceVO attendanceVO);

    // 사원들 통계(표)
    public List<Map<String, Object>> getMonthlyAttendanceReport2(String empId);

    // 근태상테 없데이트
    public int updateWorkStatus(AttendanceVO attendanceVO);

    /// ////////근태 리메이크 추가 호출 시작/////////////
    public AttendanceVO getTodayDetail(int empId);
    public AttendanceOutVO getTodayOutDetail(int empId);
    ///////////근태 리메이크 추가 호출 끝/////////////

    /// /// ////////데쉬보드/////////////
    public List<EmployeeVO> teamStatus(int empId);
}
