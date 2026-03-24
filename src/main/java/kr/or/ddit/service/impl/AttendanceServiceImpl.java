package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.AttendanceMapper;
import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.AttendanceService;
import kr.or.ddit.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class AttendanceServiceImpl implements AttendanceService {
    @Autowired
    private AttendanceMapper mapper;

    @Autowired
    private EmployeeMapper employeeMapper;

    //오늘 출근여부를 조회
    @Override
    public int checkTodayAttendance(int empId) {
        return this.mapper.checkTodayAttendance(empId);
    }

    // 출근 도장 찍기
    @Transactional
    @Override
    public int insertAttendance(AttendanceVO attendanceVO) {
        AttendanceWorkStatusVO workStatusVO = new AttendanceWorkStatusVO();
        workStatusVO.setEmpId(attendanceVO.getEmpId());
        int result = this.mapper.updateWorkStatusStart(workStatusVO.getEmpId());


        // 2. 현재 근무 상태 테이블 업데이트
        if(result > 0) {
            int result2 = this.mapper.insertAttendance(attendanceVO);

            return result2;
        }

        return 0;
    }

    // 퇴근 도장 찍기
    @Transactional
    @Override
    public int updateCheckout(int empId) {

        int result = this.mapper.updateCheckout(empId);
        int result2 = 0;
        if (result > 0) {
            AttendanceVO todayAttendance = this.mapper.selectTodayMlg(empId);
            int mlg = todayAttendance.getAttDayMlg();

            EmployeeVO empVO = new EmployeeVO();
            empVO.setEmpId(empId);
            empVO.setEmpMlg(mlg);
            result2 = this.mapper.updateEmpMlg(empVO);

        }

        // 2. 현재 근무 상태 테이블 업데이트
        if(result2 > 0) {
            AttendanceWorkStatusVO workStatusVO = new AttendanceWorkStatusVO();
            workStatusVO.setEmpId(empId);
            int result3 = this.mapper.updateWorkStatusEnd(workStatusVO.getEmpId());
            return result3;
        }

        return 0;
    }

    /* 여기서 부턴 휴가,출장,초과근무 신청 및 업뎃.. 귀찮아서 걍 attendanceService 빌려씀 */
    //휴가 신청 인서트
    @Override
    @Transactional
    public int insertVacation(VacationDocumentVO vacationDoc) {
        int result = this.mapper.insertVacation(vacationDoc);
        return result;
    }
    //출장 신청 인서트
    @Override
    public int insertTrip(TripDocumentVO tripDoc) {
        return this.mapper.insertTrip(tripDoc);
    }
    //초과근무 신청 인서트
    @Override
    public int insertOvertime(OvertimeDocumentVO overtimeDoc) {
        return this.mapper.insertOvertime(overtimeDoc);
    }
    /* 여기서 부턴 휴가,출장,초과근무 신청 및 업뎃.. 귀찮아서 걍 attendanceService 빌려씀 끝*/

    // 달력에 띄울 list
    @Override
    public List<AttendanceVO> getAttendanceByMonth(int empId, String year, String month) {
        return this.mapper.getAttendanceByMonth(empId, year, month);
    }
    //달력에 띄울 신청목록
    @Override
    public List<AttendanceTypeVO> getApprovedCalendarEvents(int empId, String year, String month) {
        Map<String, Object> params = new HashMap<>();
        params.put("empId", empId);
        params.put("year", year);
        params.put("month", month);
        return mapper.getApprovedCalendarEvents(params);
    }

    // 전체 행 수 가져오기
    @Override
    public int getTotalApplication(Map<String, Object> map) {
        return this.mapper.getTotalApplication(map);
    }

    // 통합 리스트 가져오기
    @Override
    public List<AttendanceTypeVO> getApplicationList(Map<String, Object> map) {
        return this.mapper.getApplicationList(map);
    }

    @Transactional
    @Override
    public int deleteApplication(int empId, int attTypeId) {
        int result = 0;

        // 1. 자식 테이블(휴가, 출장, 초과근무) 삭제 시도
        // 셋 중 하나만 삭제되어도 result는 1
        result = mapper.deleteVacation(empId, attTypeId);

        if (result == 0) {
            result = mapper.deleteBusinessTrip(empId, attTypeId);
        }

        if (result == 0) {
            result = mapper.deleteOvertime(empId, attTypeId);
        }

        // 2. 자식 삭제 성공 시 부모 테이블(통합 관리) 삭제
        if (result > 0) {
            mapper.deleteCommonDoc(empId, attTypeId);
            log.info("자식 데이터 삭제 완료 후 부모 데이터까지 완벽하게 소거 ID: {}", attTypeId);
        }

        return result;
    }

    @Override
    @Transactional
    public int updateStatusToPending(int empId, int attTypeId) {
        log.info("[INFO] 메서드 진입 확인: {}, {}", empId, attTypeId);
        int result = 0;

        //  1. 휴가 신청 상태 업데이트 시도 ('대기' -> '신청중')
        result = mapper.updateVacationStatus(empId, attTypeId);
        log.info("1단계 휴가 업데이트 결과(result): {}", result);
        if (result > 0) {
            // 휴가 신청 업데이트 성공 시에만 연차 차감
            // 쿼리 안에서 '신청중' 상태인 데이터를 찾아 계산.
            int leaveResult = mapper.updateEmpLeave(empId, attTypeId);

            if (leaveResult > 0) {
                log.info("휴가 신청 및 연차 차감 성공! 사원ID: {}, 신청ID: {}", empId, attTypeId);
            } else {
                log.warn("휴가 상태는 바뀌었으나 연차 테이블 업데이트는 실패했습니다. ID: {}", attTypeId);
            }
        }
        //  2. 휴가 신청 건이 아닐 경우(result == 0) 출장으로
        else {
            result = mapper.updateBusinessTripStatus(empId, attTypeId);

            // 3. 출장도 아니면 초과근무로
            if (result == 0) {
                result = mapper.updateOvertimeStatus(empId, attTypeId);
            }
        }

        if (result > 0) {
            log.info("최종 결재 신청 처리 완료! ID: {}", attTypeId);
        }

        return result;
    }

    // 부서별 사원검색조회 (다른사람 서비스에 만들기 좀 그래서 만든 ㅇㅅㅇ)
    @Override
    public List<EmployeeVO> getEmployeesByDept(String deptNm) {
        return this.mapper.getEmployeesByDept(deptNm);
    }

    // 사원별 근태현황
    @Override
    public List<Map<String, Object>> getMonthlyAttendanceReport(String empId, String startDate, String endDate) {
        return this.mapper.getMonthlyAttendanceReport(empId,startDate,endDate);
    }

    // 부서별 통계
    @Override
    public List<DepartmentVO> getDeptAttendanceStats() {
        return this.mapper.getDeptAttendanceStats();
    }

    // 근태수정
    @Override
    @Transactional
    public int updateAttendance(AttendanceVO attendanceVO) {
        log.info("관리자 근태 업테이트 요청상태 :{}", attendanceVO.getAttStts());

        int result = this.mapper.updateWorkStatus(attendanceVO);

        int result2 = 0;
        if (result > 0) {
            result2 = this.mapper.updateAttendance(attendanceVO);
        }
        return result2;
    }

    // 근태삭제
    @Override
    public int deleteAttendance(AttendanceVO attendanceVO) {
        return this.mapper.deleteAttendance(attendanceVO);
    }

    // 사원별 근태차트
    @Override
    public List<Map<String, Object>> getMonthlyAttendanceReport2(String empId) {
        return this.mapper.getMonthlyAttendanceReport2(empId);
    }

    /// ////////근태 리메이크 추가 호출 시작/////////////
    @Override
    public AttendanceVO getTodayDetail(int empId) {
        return this.mapper.getTodayDetail(empId);
    }

    @Override
    public AttendanceOutVO getTodayOutDetail(int empId) {
        return this.mapper.getTodayOutDetail(empId);
    }

    ///////////근태 리메이크 추가 호출 끝/////////////

    /// /// ////////데쉬보드/////////////
    @Override
    public List<EmployeeVO> teamStatus(int empId) {
        return this.mapper.teamStatus(empId);
    }
}
