package kr.or.ddit.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface AttendanceWorkStatusMapper {
    // 근무자 상태값 받아오기
    public String getWorkStatus(int empId);

    // DB 활동량 데이터 훔쳐오기 귀찮아서 잠시 빌려씁니다.
    public List<Map<String, Object>> getDbTrafficData();
}
