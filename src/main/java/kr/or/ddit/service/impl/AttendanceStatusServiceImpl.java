package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.AttendanceStatusMapper;
import kr.or.ddit.service.AttendanceStatusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class AttendanceStatusServiceImpl implements AttendanceStatusService {
    @Autowired
    private AttendanceStatusMapper attendanceStatusMapper;

    //회원의 월별 상태가져오기
    @Override
    public Map<String, Object> getDashboardSummary(int empId) {
        return this.attendanceStatusMapper.getDashboardSummary(empId);
    }
}
