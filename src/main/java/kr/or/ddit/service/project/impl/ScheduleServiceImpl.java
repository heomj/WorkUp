package kr.or.ddit.service.project.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.or.ddit.mapper.project.ScheduleMapper;
import kr.or.ddit.service.project.ScheduleService;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.TaskVO;

@Service
public class ScheduleServiceImpl implements ScheduleService {

	@Autowired
    private ScheduleMapper scheduleMapper;

    @Override
    public List<TaskVO> getScheduleList(int projNo) {
        return scheduleMapper.getScheduleList(projNo);
    }
    
    @Override
    public List<EmployeeVO> getProjectMembers(int projNo) {
        // ⭐ 매퍼를 호출해서 DB에서 사원 목록을 가져옵니다.
        return scheduleMapper.getProjectMembers(projNo); 
    }

}
