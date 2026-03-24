package kr.or.ddit.mapper.project;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.TaskVO;

@Mapper
public interface ScheduleMapper {
    List<TaskVO> getScheduleList(int projNo);
    
    public List<EmployeeVO> getProjectMembers(int projNo);
}
