package kr.or.ddit.service;

import java.util.Map;

public interface AttendanceStatusService {
    //회원의 월별 상태가져오기
    public Map<String, Object> getDashboardSummary(int empId);
}
