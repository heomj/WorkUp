package kr.or.ddit.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.Map;

@Mapper
public interface AttendanceStatusMapper {
    //회원의 월별 상태가져오기
    public Map<String, Object> getDashboardSummary(int empId);
}
