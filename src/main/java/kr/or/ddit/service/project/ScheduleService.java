package kr.or.ddit.service.project;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.TaskVO;
import java.util.List;

public interface ScheduleService {
    List<TaskVO> getScheduleList(int projNo);
    
    List<EmployeeVO> getProjectMembers(int projNo);
}