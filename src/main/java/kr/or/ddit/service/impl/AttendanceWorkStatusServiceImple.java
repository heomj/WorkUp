package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.AttendanceWorkStatusMapper;
import kr.or.ddit.service.AttendanceWorkStatusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class AttendanceWorkStatusServiceImple implements AttendanceWorkStatusService {
    @Autowired
    private AttendanceWorkStatusMapper mapper;

    // 근무자 상태값 받아오기
    @Override
    public String getWorkStatus(int empId) {
        return this.mapper.getWorkStatus(empId);
    }

    // DB 활동량 데이터 훔쳐오기 귀찮아서 잠시 빌려씁니다.
    @Override
    public List<Map<String, Object>> getDbTrafficData() {
        return this.mapper.getDbTrafficData();
    }
}
